// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "oz-custom/contracts/internal-upgradeable/SignableUpgradeable.sol";

import "./internal-upgradeable/BaseUpgradeable.sol";
import "./internal-upgradeable/ProxyCheckerUpgradeable.sol";
import "./internal-upgradeable/FundForwarderUpgradeable.sol";

import "./internal-upgradeable/interfaces/IWithdrawableUpgradeable.sol";
import "oz-custom/contracts/oz-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "oz-custom/contracts/oz-upgradeable/token/ERC20/extensions/draft-IERC20PermitUpgradeable.sol";

import "oz-custom/contracts/libraries/Bytes32Address.sol";

contract IngameSwapV1 is
    BaseUpgradeable,
    SignableUpgradeable,
    ProxyCheckerUpgradeable,
    FundForwarderUpgradeable
{
    using Bytes32Address for address;
    using Bytes32Address for bytes32;

    bytes32 public constant VERSION =
        0xaf2ffe078b2e43887a43d5b326c9516f2e657107ea47641fba4f17113ff97ecc;

    ///@dev value is equal to keccak256("Permit(address user,uint256 amount,uint256 deadline,uint256 nonce)")
    bytes32 private constant _PERMIT_TYPE_HASH =
        0x90d5e22684e089d6743327f458c994a875c608cfd353008cabde7a3b9f1b2ccc;

    bytes32 private _token;
    mapping(bytes32 => uint256) public lockedAmts;

    event Locked();
    event Released();
    event Decreased();

    function init(
        address token_,
        IGovernanceV2 governance_,
        ITreasuryV2 treasury_
    ) external initializer {
        if (token_ == address(0)) revert();
        __Base_init(governance_, Roles.TREASURER_ROLE);
        __FundForwarder_init(treasury_);
        if (!_hasRole(Roles.PROXY_ROLE, _msgSender())) revert();
        __EIP712_init(type(IngameSwapV1).name, "1");

        _token = address(token_).fillLast12Bytes();
    }

    function token() public view returns (IERC20Upgradeable) {
        return IERC20Upgradeable(_token.fromFirst20Bytes());
    }

    function decrease(address user_, uint256 amount_)
        external
        onlyRole(Roles.PROXY_ROLE)
    {
        lockedAmts[user_.fillLast12Bytes()] -= amount_;
        emit Decreased();
    }

    function lock(
        uint256 amount_,
        uint256 deadline_,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        address user = _msgSender();
        bytes32 bytes32User = user.fillLast12Bytes();
        uint256 currentAmt = lockedAmts[bytes32User];
        if (currentAmt == 0) {
            _onlyEOA(user);
            _checkBlacklist(user);
        }
        address token_ = _token.fromFirst20Bytes();
        if (v != 0) {
            (bool ok, ) = token_.call(
                abi.encodeWithSelector(
                    IERC20PermitUpgradeable.permit.selector,
                    user,
                    address(this),
                    amount_,
                    deadline_,
                    v,
                    r,
                    s
                )
            );
            if (!ok) revert();
        }

        currentAmt += amount_;
        lockedAmts[bytes32User] = currentAmt;

        _safeTransferFrom(
            IERC20Upgradeable(token_),
            user,
            address(treasury()),
            amount_
        );

        emit Locked();
    }

    function withdraw(
        uint256 amount_,
        uint256 deadline_,
        bytes calldata signature_
    ) external whenNotPaused {
        if (block.timestamp > deadline_) revert();
        address user = _msgSender();
        if (
            !_hasRole(
                Roles.SIGNER_ROLE,
                _recoverSigner(
                    _hashTypedDataV4(
                        keccak256(
                            abi.encode(
                                _PERMIT_TYPE_HASH,
                                user,
                                amount_,
                                deadline_,
                                _useNonce(user)
                            )
                        )
                    ),
                    signature_
                )
            )
        ) revert();

        bytes32 bytes32User = user.fillLast12Bytes();
        uint256 currentAmt = lockedAmts[bytes32User];
        if (amount_ > currentAmt) revert();
        if (currentAmt == amount_) delete lockedAmts[bytes32User];
        else lockedAmts[bytes32User] = currentAmt - amount_;
        (bool ok, ) = address(treasury()).call(
            abi.encodeWithSelector(
                IWithdrawableUpgradeable.withdraw.selector,
                token(),
                user,
                amount_
            )
        );
        if (!ok) revert();
        emit Released();
    }

    function getLockedAmt(address[] calldata users_)
        external
        view
        returns (uint256[] memory amounts)
    {
        uint256 length = users_.length;
        amounts = new uint256[](length);
        bytes32[] memory users;
        {
            address[] memory _users = users_;
            assembly {
                users := _users
            }
        }
        for (uint256 i; i < length; ) {
            amounts[i] = lockedAmts[users[i]];
            unchecked {
                ++i;
            }
        }
    }

    function updateTreasury(ITreasuryV2 treasury_)
        external
        override
        whenPaused
        onlyRole(Roles.OPERATOR_ROLE)
    {
        emit TreasuryUpdated(treasury(), treasury_);
        _updateTreasury(treasury_);
    }

    uint256[48] private __gap;
}

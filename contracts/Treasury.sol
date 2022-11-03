// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "oz-custom/contracts/internal-upgradeable/SignableUpgradeable.sol";
import "oz-custom/contracts/internal-upgradeable/ProxyCheckerUpgradeable.sol";
import "oz-custom/contracts/internal-upgradeable/WithdrawableUpgradeable.sol";
import "oz-custom/contracts/oz-upgradeable/security/ReentrancyGuardUpgradeable.sol";

import "./internal-upgradeable/BaseUpgradeable.sol";

import "oz-custom/contracts/libraries/EnumerableSetV2.sol";

import "./interfaces/ITreasury.sol";
import {
    IERC721Upgradeable,
    ERC721TokenReceiverUpgradeable
} from "oz-custom/contracts/oz-upgradeable/token/ERC721/ERC721Upgradeable.sol";

import "oz-custom/contracts/oz-upgradeable/utils/introspection/ERC165CheckerUpgradeable.sol";

contract Treasury is
    ITreasury,
    BaseUpgradeable,
    SignableUpgradeable,
    ProxyCheckerUpgradeable,
    WithdrawableUpgradeable,
    ReentrancyGuardUpgradeable,
    ERC721TokenReceiverUpgradeable
{
    using Bytes32Address for address;
    using ERC165CheckerUpgradeable for address;
    using EnumerableSetV2 for EnumerableSetV2.AddressSet;

    ///@dev value is equal to keccak256("Treasury_v2")
    bytes32 public constant VERSION =
        0x48c79cba00677850a648b537b2558198a45e7f81d7643207ace134fa238f149f;

    ///@dev value is equal to keccak256("Permit(address token,address to,uint256 value,uint256 nonce,uint256 deadline)")
    bytes32 private constant __PERMIT_TYPE_HASH =
        0x78ecb86225a2600f4a19912d238c02ae4aba51082b8a69ebd615456f7e702c07;

    mapping(bytes32 => uint256) private __priceOf;
    EnumerableSetV2.AddressSet private _payments;

    function init(IAuthority governance_) external initializer {
        __Base_init_unchained(governance_, 0);
        __ReentrancyGuard_init_unchained();
        __Signable_init(type(Treasury).name, "2");
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external pure override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    function withdraw(
        address token_,
        address to_,
        uint256 value_
    ) external override onlyRole(Roles.TREASURER_ROLE) {
        __withdraw(token_, to_, value_);
    }

    function __withdraw(address token_, address to_, uint256 value_) private {
        if (supportedPayment(token_)) {
            if (token_.supportsInterface(type(IERC721Upgradeable).interfaceId))
                IERC721Upgradeable(token_).safeTransferFrom(
                    address(this),
                    to_,
                    value_
                );
            else _safeTransfer(IERC20Upgradeable(token_), to_, value_);
            emit Withdrawn(token_, to_, value_);
        }
    }

    function withdraw(
        address token_,
        address to_,
        uint256 value_,
        uint256 deadline_,
        bytes calldata signature_
    ) external whenNotPaused {
        _checkBlacklist(to_);
        _onlyEOA(_msgSender());

        if (block.timestamp > deadline_) revert Treasury__Expired();
        if (
            !_hasRole(
                Roles.SIGNER_ROLE,
                _recoverSigner(
                    keccak256(
                        abi.encode(
                            __PERMIT_TYPE_HASH,
                            token_,
                            to_,
                            value_,
                            _useNonce(to_),
                            deadline_
                        )
                    ),
                    signature_
                )
            )
        ) revert Treasury__InvalidSignature();

        __withdraw(token_, to_, value_);
    }

    function priceOf(address token_) external view returns (uint256) {
        return __priceOf[token_.fillLast12Bytes()];
    }

    function updatePrices(
        address[] calldata tokens_,
        uint256[] calldata prices_
    ) external onlyRole(Roles.TREASURER_ROLE) {
        uint256 length = tokens_.length;
        if (length != prices_.length) revert Treasury__LengthMismatch();
        bytes32[] memory tokens;
        {
            address[] memory _tokens;
            assembly {
                tokens := _tokens
            }
        }
        for (uint256 i; i < length; ) {
            __priceOf[tokens[i]] = prices_[i];
            unchecked {
                ++i;
            }
        }
        emit PricesUpdated();
    }

    function updatePayments(
        address[] calldata tokens_
    ) external onlyRole(Roles.TREASURER_ROLE) {
        _payments.add(tokens_);
        emit PaymentsUpdated();
    }

    function resetPayments() external onlyRole(Roles.TREASURER_ROLE) {
        _payments.remove();
        emit PaymentsRemoved();
    }

    function removePayment(
        address token_
    ) external onlyRole(Roles.TREASURER_ROLE) {
        if (_payments.remove(token_)) emit PaymentRemoved(token_);
    }

    function payments() external view returns (address[] memory) {
        return _payments.values();
    }

    function validPayment(address token_) external view returns (bool) {
        return __priceOf[token_.fillLast12Bytes()] != 0;
    }

    function supportedPayment(address token_) public view returns (bool) {
        return _payments.contains(token_);
    }
}

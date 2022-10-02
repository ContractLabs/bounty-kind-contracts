// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "oz-custom/contracts/internal-upgradeable/SignableUpgradeable.sol";

import "./internal-upgradeable/BaseUpgradeable.sol";

import "./interfaces/IBK20.sol";
import "./interfaces/IBK721.sol";
import "oz-custom/contracts/oz-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "oz-custom/contracts/oz-upgradeable/token/ERC721/IERC721Upgradeable.sol";
import "oz-custom/contracts/oz-upgradeable/token/ERC721/extensions/IERC721PermitUpgradeable.sol";
import "oz-custom/contracts/oz-upgradeable/token/ERC20/extensions/draft-IERC20PermitUpgradeable.sol";

import "oz-custom/contracts/libraries/Bytes32Address.sol";

contract PairV1 is BaseUpgradeable, SignableUpgradeable {
    using Bytes32Address for bytes32;
    using Bytes32Address for address;

    bytes32 private constant _TO_FT_TYPE_HASH = 0x0;
    bytes32 private constant _TO_NFT_TYPE_HASH = 0x0;

    bytes32 private _ft;
    bytes32 private _nft;

    function init(
        IBK20 erc20_,
        IBK721 erc721_,
        IGovernanceV2 governance_
    ) external initializer {
        _ft = address(erc20_).fillLast12Bytes();
        _nft = address(erc721_).fillLast12Bytes();

        __Base_init(governance_, 0);
        __EIP712_init(type(PairV1).name, "1");
    }

    function erc20() public view returns (address) {
        return _ft.fromFirst20Bytes();
    }

    function erc721() public view returns (address) {
        return _nft.fromFirst20Bytes();
    }

    function swap2NFT(
        uint256 amountIn_,
        uint256 typeIdOut_,
        uint256 deadline_,
        uint256 permitDeadline_,
        uint8 v,
        bytes32 r,
        bytes32 s,
        bytes calldata signature_
    ) external whenNotPaused {
        __checkDeadline(deadline_);
        address user = _msgSender();
        _checkBlacklist(user);
        __checkSignature(
            keccak256(
                abi.encode(
                    _TO_NFT_TYPE_HASH,
                    user,
                    amountIn_,
                    typeIdOut_,
                    deadline_,
                    _useNonce(user)
                )
            ),
            signature_
        );

        bool ok;
        address token = erc20();
        if (v != 0) {
            (ok, ) = token.call(
                abi.encodeWithSelector(
                    IERC20PermitUpgradeable.permit.selector,
                    user,
                    address(this),
                    amountIn_,
                    permitDeadline_,
                    v,
                    r,
                    s
                )
            );
            if (!ok) revert();
        }
        (ok, ) = token.call(
            abi.encodeWithSelector(
                IERC20Upgradeable.transferFrom.selector,
                user,
                address(this),
                amountIn_
            )
        );
        if (!ok) revert();

        (ok, ) = erc721().call(
            abi.encodeWithSelector(IBK721.safeMint.selector, user, typeIdOut_)
        );
        if (!ok) revert();
    }

    function swap2FT(
        uint256 tokenIdIn_,
        uint256 amountOut_,
        uint256 deadline_,
        uint256 permitDeadline_,
        uint8 v,
        bytes32 r,
        bytes32 s,
        bytes calldata signature_
    ) external whenNotPaused {
        __checkDeadline(deadline_);
        address user = _msgSender();
        _checkBlacklist(user);
        __checkSignature(
            keccak256(
                abi.encode(
                    _TO_FT_TYPE_HASH,
                    user,
                    tokenIdIn_,
                    amountOut_,
                    deadline_,
                    _useNonce(user)
                )
            ),
            signature_
        );

        bool ok;
        address nft = erc721();
        if (v != 0) {
            (ok, ) = nft.call(
                abi.encodeWithSelector(
                    IERC721PermitUpgradeable.permit.selector,
                    tokenIdIn_,
                    permitDeadline_,
                    address(this),
                    v,
                    r,
                    s
                )
            );
            if (!ok) revert();
        }

        (ok, ) = nft.call(
            abi.encodeWithSelector(
                IERC721Upgradeable.transferFrom.selector,
                user,
                address(this),
                tokenIdIn_
            )
        );
        if (!ok) revert();
        (ok, ) = erc20().call(
            abi.encodeWithSelector(
                IERC20Upgradeable.transferFrom.selector,
                address(this),
                user,
                amountOut_
            )
        );
        if (!ok) revert();
    }

    function __checkSignature(bytes32 structHash_, bytes calldata signature_)
        private
        view
    {
        if (
            !_hasRole(
                Roles.SIGNER_ROLE,
                _recoverSigner(_hashTypedDataV4(structHash_), signature_)
            )
        ) revert();
    }

    function __checkDeadline(uint256 deadline_) private view {
        if (block.timestamp > deadline_) revert();
    }

    uint256[48] private __gap;
}

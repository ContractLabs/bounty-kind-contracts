// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "oz-custom/contracts/oz-upgradeable/token/ERC721/extensions/ERC721RentableUpgradeable.sol";

import "./interfaces/IRBK721.sol";

import {IAuthority, IBKTreasury, BK721, Roles} from "./BK721.sol";

contract RBK721 is BK721, IRBK721, ERC721RentableUpgradeable {
    using SafeCastUpgradeable for uint256;

    ///@dev value is equal to keccak256("Permit(address user,uint256 tokenId,uint256 expires,uint256 deadline,uint256 nonce)")
    bytes32 private constant __PERMIT_TYPE_HASH =
        0x791d178915e3bc91599d5bc6c1eab516b25cb66fc0b46b415e2018109bbaa078;

    function initialize(
        string calldata name_,
        string calldata symbol_,
        string calldata baseURI_,
        uint96 feeAmt_,
        IERC20Upgradeable feeToken_,
        IAuthority authority_
    ) external initializer {
        __BK_init(
            name_,
            symbol_,
            baseURI_,
            feeAmt_,
            feeToken_,
            authority_,
            /// @dev value is equal to keccak256("RentableBK_v1")
            0xb2968efe7e8797044f984fc229747059269f7279ae7d4bb4737458dbb15e0f41
        );
    }

    function setUser(
        uint256 tokenId,
        uint64 expires_,
        uint256 deadline_,
        bytes calldata signature_
    ) external override whenNotPaused {
        if (block.timestamp > deadline_) revert RBK721__Expired();

        UserInfo memory userInfo; // = _users[tokenId];
        bytes32 userInfoKey;
        assembly {
            mstore(0, tokenId)
            mstore(32, _users.slot)
            userInfoKey := keccak256(0, 64)
            userInfo := sload(userInfoKey)
        }

        if (userInfo.expires > block.timestamp && userInfo.user != address(0))
            revert RBK721__Rented();
        userInfo.user = _msgSender();
        emit UserUpdated(tokenId, userInfo.user, expires_);

        if (
            !_hasRole(
                Roles.SIGNER_ROLE,
                _recoverSigner(
                    keccak256(
                        abi.encode(
                            __PERMIT_TYPE_HASH,
                            userInfo.user,
                            tokenId,
                            expires_,
                            deadline_,
                            _useNonce(tokenId)
                        )
                    ),
                    signature_
                )
            )
        ) revert RBK721__InvalidSignature();
        unchecked {
            userInfo.expires = (block.timestamp + expires_).toUint96();
        }
        assembly {
            sstore(userInfoKey, userInfo)
        }
    }

    function setUser(
        uint256 tokenId_,
        address user_,
        uint64 expires_
    ) public override whenNotPaused {
        if (!_isApprovedOrOwner(_msgSender(), tokenId_))
            revert Rentable__OnlyOwnerOrApproved();

        UserInfo memory info; // = _users[tokenId];
        bytes32 userInfoKey;
        assembly {
            mstore(0, tokenId_)
            mstore(32, _users.slot)
            userInfoKey := keccak256(0, 64)
            info := sload(userInfoKey)
        }

        if (info.expires > block.timestamp && info.user != address(0))
            revert RBK721__Rented();
        info.user = user_;
        unchecked {
            info.expires = (block.timestamp + expires_).toUint96();
        }

        assembly {
            sstore(userInfoKey, info)
        }

        emit UserUpdated(tokenId_, user_, expires_);
    }

    function supportsInterface(
        bytes4 interfaceId_
    ) public view override(BK721, ERC721RentableUpgradeable) returns (bool) {
        return super.supportsInterface(interfaceId_);
    }

    function _burn(uint256 tokenId_) internal override {
        super._burn(tokenId_);
    }

    function _beforeTokenTransfer(
        address from_,
        address to_,
        uint256 tokenId_
    ) internal override(BK721, ERC721RentableUpgradeable) {
        super._beforeTokenTransfer(from_, to_, tokenId_);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "oz-custom/contracts/oz-upgradeable/token/ERC721/extensions/ERC721RentableUpgradeable.sol";

import "./interfaces/IRBK721.sol";

import "./BK721.sol";

contract RentableBK721Upgradeable is
    IRBK721,
    BK721Upgradeable,
    ERC721RentableUpgradeable
{
    using SafeCastUpgradeable for uint256;

    ///@dev value is equal to keccak256("Permit(address user,uint256 tokenId,uint256 expires,uint256 deadline,uint256 nonce)")
    bytes32 private constant __PERMIT_TYPE_HASH =
        0x791d178915e3bc91599d5bc6c1eab516b25cb66fc0b46b415e2018109bbaa078;

    function init(
        string calldata name_,
        string calldata symbol_,
        string calldata baseURI_,
        uint256 feeAmt_,
        IERC20Upgradeable feeToken_,
        IAuthority governance_,
        ITreasury treasury_
    ) external initializer {
        __BK_init(
            name_,
            symbol_,
            baseURI_,
            feeAmt_,
            feeToken_,
            governance_,
            treasury_,
            /// @dev value is equal to keccak256("RentableBK_v1")
            0xb2968efe7e8797044f984fc229747059269f7279ae7d4bb4737458dbb15e0f41
        );
    }

    function setUser(
        uint256 tokenId,
        uint64 expires_,
        uint256 deadline_,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external override whenNotPaused {
        if (block.timestamp > deadline_) revert RBK721__Expired();

        UserInfo memory userInfo = _users[tokenId];
        if (userInfo.expires < block.timestamp && userInfo.user != address(0))
            revert RBK721__Rented();
        userInfo.user = _msgSender();
        emit UserUpdated(tokenId, userInfo.user, expires_);

        _verify(
            ownerOf(tokenId),
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
            v,
            r,
            s
        );
        unchecked {
            userInfo.expires = (block.timestamp + expires_).toUint96();
        }
        _users[tokenId] = userInfo;
    }

    function setUser(
        uint256 tokenId_,
        address user_,
        uint64 expires_
    ) public override whenNotPaused {
        if (!_isApprovedOrOwner(_msgSender(), tokenId_))
            revert Rentable__OnlyOwnerOrApproved();

        UserInfo memory info = _users[tokenId_];
        info.user = user_;
        unchecked {
            info.expires = (block.timestamp + expires_).toUint96();
        }

        _users[tokenId_] = info;

        emit UserUpdated(tokenId_, user_, expires_);
    }

    function supportsInterface(
        bytes4 interfaceId_
    )
        public
        view
        override(BK721Upgradeable, ERC721RentableUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId_);
    }

    function _burn(uint256 tokenId_) internal override {
        super._burn(tokenId_);
    }

    function _beforeTokenTransfer(
        address from_,
        address to_,
        uint256 tokenId_
    ) internal override(BK721Upgradeable, ERC721RentableUpgradeable) {
        super._beforeTokenTransfer(from_, to_, tokenId_);
    }
}

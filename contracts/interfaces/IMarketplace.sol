// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "oz-custom/contracts/oz-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "oz-custom/contracts/oz-upgradeable/token/ERC721/extensions/IERC721PermitUpgradeable.sol";
import {
    IERC20PermitUpgradeable
} from "oz-custom/contracts/oz-upgradeable/token/ERC20/extensions/draft-IERC20PermitUpgradeable.sol";

interface IMarketplace {
    error Marketplace__Expired();
    error Marketplace__InvalidSignature();

    struct Seller {
        uint8 v;
        bytes32 r;
        bytes32 s;
        uint256 tokenId;
        uint256 deadline;
        uint256 unitPrice;
        IERC20Upgradeable payment;
        IERC721PermitUpgradeable nft;
    }

    struct Buyer {
        uint8 v;
        bytes32 r;
        bytes32 s;
        uint256 deadline;
    }

    event ProtocolFeeUpdated(uint256 indexed feeFraction);

    event Redeemed(
        address indexed buyer,
        address indexed seller,
        uint256 indexed tokenId,
        IERC721PermitUpgradeable nft,
        IERC20Upgradeable payment,
        uint256 unitPrice
    );

    function setProtocolFee(uint256 feeFraction_) external;

    function redeem(
        uint256 deadline_,
        Buyer calldata buyer_,
        Seller calldata seller_,
        bytes calldata signature_
    ) external payable;
}

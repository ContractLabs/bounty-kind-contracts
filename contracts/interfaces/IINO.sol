// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "oz-custom/contracts/oz-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "oz-custom/contracts/oz-upgradeable/token/ERC721/IERC721Upgradeable.sol";

interface IINO {
    error INO__ExternalCallFailed();
    error INO__OnGoingCampaign();
    error INO__Unauthorized();
    error INO__CampaignEnded();
    error INO__AllocationExceeded();
    error INO__UnsupportedPayment(address);

    struct Campaign {
        //// slot #0 ////
        uint64 start;
        uint32 limit; // user buy limit
        address nft;
        //// slot #1 ////
        uint64 end;
        uint64 maxSupply;
        uint128 typeNFT;
        //// slot #2 ///
        uint256 bitmap;
        //// slot #3 ////
        Payment[] payments;
    }

    struct Payment {
        address paymentToken;
        uint96 unitPrices;
    }

    struct Ticket {
        address paymentToken;
        uint256 campaignId;
        uint256 amount;
    }

    event Registered(
        address indexed user,
        address indexed erc721,
        uint256[] tokenIds,
        uint256 price
    );

    event Redeemed(
        address indexed buyer,
        uint256 indexed ticketId,
        address indexed paymentToken,
        uint256 total
    );

    event Received(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId,
        bytes data
    );

    event NewCampaign(
        uint256 indexed campaignId,
        uint64 indexed startAt,
        uint64 indexed endAt
    );
}

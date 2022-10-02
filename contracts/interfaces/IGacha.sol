// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

interface IGacha {
    error Gacha__Expired();
    error Gacha__Unauthorized();
    error Gacha__InvalidTicket();
    error Gacha__InvalidPayment();
    error Gacha__PurchasedTicket();

    event BuyTicket(
        address _from,
        uint256 ticket,
        address erc20,
        uint256 amount
    );
    event BuyTicketNFT(
        address _from,
        uint256 ticket,
        address erc721,
        uint256 tokenId
    );
    event RewardMainCoin(uint256 ticket, address _to, uint256 amount);
    event RewardERC20(
        uint256 ticket,
        address _to,
        address erc20,
        uint256 amount
    );
    event RewardERC721(
        uint256 ticket,
        address _to,
        address erc721,
        uint256 tokenId
    );
}

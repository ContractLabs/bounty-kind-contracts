// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

interface IGacha {
    error Gacha__Unauthorized();
    error Gacha__InvalidTicket();
    error Gacha__InvalidPayment();
    error Gacha__PurchasedTicket();
    error Gacha__InsufficientAmount();

    struct Ticket {
        address account;
        bool isUsed;
    }

    event Rewarded(
        uint256 indexed ticketId,
        address indexed token,
        uint256 indexed value
    );

    event Redeemed(
        uint256 indexed ticketId,
        uint256 indexed typeId,
        address indexed user
    );
}

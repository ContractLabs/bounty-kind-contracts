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

    function batchExecute(
        bytes[] calldata data_
    ) external returns (bytes[] memory);

    function updateTicketPrice(
        uint256 typeId_,
        address[] calldata supportedPayments,
        uint96[] calldata unitPrices_
    ) external;

    function redeemTicket(
        uint256 id_,
        uint256 type_,
        address user_,
        address token_,
        uint256 value_
    ) external;

    function reward(address token_, uint256 ticketId_, uint256 value_) external;
}

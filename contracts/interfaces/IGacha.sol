// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

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
        address indexed operator,
        uint256 indexed ticketId,
        address indexed token,
        uint256 value
    );

    event Redeemed(
        address indexed account,
        uint256 indexed ticketId,
        uint256 indexed typeId
    );

    event TicketPricesUpdated(
        address indexed operator,
        uint256 indexed typeId,
        address[] supportedPayments,
        uint96[] unitPrices
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
        address user_,
        address token_,
        uint256 value_,
        uint256 id_,
        uint256 type_
    ) external;

    function reward(address token_, uint256 ticketId_, uint256 value_) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "oz-custom/contracts/internal-upgradeable/SignableUpgradeable.sol";

import "./internal-upgradeable/BaseUpgradeable.sol";
import "oz-custom/contracts/internal-upgradeable/TransferableUpgradeable.sol";
import "oz-custom/contracts/internal-upgradeable/ProxyCheckerUpgradeable.sol";
import "oz-custom/contracts/internal-upgradeable/FundForwarderUpgradeable.sol";

import "./interfaces/IGacha.sol";
import "./interfaces/ITreasuryV2.sol";
import "oz-custom/contracts/oz-upgradeable/token/ERC721/extensions/IERC721PermitUpgradeable.sol";

// import "./interfaces/IERC721Mintable.sol";
// import "./interfaces/IERC721Burnable.sol";
//import "./interfaces/IPaymentProvider.sol";
import "./interfaces/IBK721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-IERC20Permit.sol";

import "oz-custom/contracts/oz-upgradeable/utils/structs/BitMapsUpgradeable.sol";
import "oz-custom/contracts/libraries/Bytes32Address.sol";
import "oz-custom/contracts/oz-upgradeable/utils/introspection/ERC165CheckerUpgradeable.sol";

contract Gacha is
    IGacha,
    BaseUpgradeable,
    SignableUpgradeable,
    ProxyCheckerUpgradeable,
    TransferableUpgradeable,
    FundForwarderUpgradeable
{
    using Bytes32Address for address;
    using Bytes32Address for uint256;
    using ERC165CheckerUpgradeable for address;
    using BitMapsUpgradeable for BitMapsUpgradeable.BitMap;

    mapping(uint256 => Ticket) private __tickets;
    BitMapsUpgradeable.BitMap private __supportedPayments;
    mapping(uint256 => mapping(address => uint96)) private __unitPrices;

    function initialize(IGovernanceV2 authority_, ITreasuryV2 vault_)
        external
        initializer
    {
        __FundForwarder_init_unchained(address(vault_));
        __Base_init_unchained(authority_, Roles.TREASURER_ROLE);
    }

    function redeemTicket(
        uint256 id_,
        uint256 type_,
        address user_,
        address token_,
        uint256 value_
    ) external onlyRole(Roles.PROXY_ROLE) {
        Ticket memory ticket = __tickets[id_];
        if (ticket.account != address(0) || ticket.isUsed)
            revert Gacha__InvalidTicket();
        if (!__supportedPayments.get(token_.fillLast96Bits()))
            revert Gacha__InvalidPayment();
        if (!token_.supportsInterface(type(IERC721Upgradeable).interfaceId)) {
            uint256 unitPrice = ITreasuryV2(vault).priceOf(token_) *
                __unitPrices[type_][token_];
            if (unitPrice != value_) revert Gacha__InsufficientAmount();
        }

        ticket.account = user_;
        __tickets[id_] = ticket;

        emit Redeemed(id_, type_, user_);
    }

    function reward(
        address token_,
        uint256 ticketId_,
        uint256 value_
    ) external onlyRole(Roles.OPERATOR_ROLE) {
        Ticket memory ticket = __tickets[ticketId_];
        if (ticket.account == address(0)) revert Gacha__InvalidTicket();
        if (ticket.isUsed) revert Gacha__PurchasedTicket();
        if (!token_.supportsInterface(type(IERC721Upgradeable).interfaceId))
            IWithdrawableUpgradeable(vault).withdraw(
                token_,
                ticket.account,
                value_
            );
        else IBK721(token_).safeMint(ticket.account, value_);

        ticket.isUsed = true;
        __tickets[ticketId_] = ticket;
        emit Rewarded(ticketId_, token_, value_);
    }
}

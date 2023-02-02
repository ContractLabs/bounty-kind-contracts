// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./internal-upgradeable/BKFundForwarderUpgradeable.sol";

import "oz-custom/contracts/presets-upgradeable/base/ManagerUpgradeable.sol";

import "oz-custom/contracts/internal-upgradeable/TransferableUpgradeable.sol";
import "oz-custom/contracts/internal-upgradeable/ProxyCheckerUpgradeable.sol";
import "oz-custom/contracts/internal-upgradeable/MultiDelegatecallUpgradeable.sol";

import "./interfaces/IGacha.sol";
import "./interfaces/IBK721.sol";
import "./interfaces/IBKTreasury.sol";
import "oz-custom/contracts/oz-upgradeable/token/ERC721/extensions/IERC721PermitUpgradeable.sol";

import "oz-custom/contracts/libraries/Bytes32Address.sol";
import "oz-custom/contracts/oz-upgradeable/utils/structs/BitMapsUpgradeable.sol";
import "oz-custom/contracts/oz-upgradeable/utils/introspection/ERC165CheckerUpgradeable.sol";

contract Gacha is
    IGacha,
    ManagerUpgradeable,
    ProxyCheckerUpgradeable,
    TransferableUpgradeable,
    BKFundForwarderUpgradeable,
    MultiDelegatecallUpgradeable
{
    using Bytes32Address for *;
    using ERC165CheckerUpgradeable for address;
    using BitMapsUpgradeable for BitMapsUpgradeable.BitMap;

    mapping(uint256 => Ticket) private __tickets;
    BitMapsUpgradeable.BitMap private __supportedPayments;
    mapping(uint256 => mapping(address => uint96)) private __unitPrices;

    function initialize(IAuthority authority_) external initializer {
        __MultiDelegatecall_init_unchained();
        __Manager_init_unchained(authority_, Roles.TREASURER_ROLE);
        __FundForwarder_init_unchained(
            IFundForwarderUpgradeable(address(authority_)).vault()
        );
    }

    function batchExecute(
        bytes[] calldata data_
    ) external returns (bytes[] memory) {
        return _multiDelegatecall(data_);
    }

    function changeVault(
        address vault_
    ) external override onlyRole(Roles.TREASURER_ROLE) {
        _changeVault(vault_);
    }

    function updateTicketPrice(
        uint256 typeId_,
        address[] calldata supportedPayments_,
        uint96[] calldata unitPrices_
    ) external onlyRole(Roles.OPERATOR_ROLE) {
        uint256[] memory uintPayments;
        address[] memory _supportedPayments = supportedPayments_;
        assembly {
            uintPayments := _supportedPayments
        }
        uint256 length = supportedPayments_.length;
        for (uint256 i; i < length; ) {
            __supportedPayments.set(uintPayments[i]);
            __unitPrices[typeId_][supportedPayments_[i]] = unitPrices_[i];
            unchecked {
                ++i;
            }
        }
    }

    function supportedPayments(address payment_) external view returns (bool) {
        uint256 payment;
        assembly {
            payment := payment_
        }

        return __supportedPayments.get(payment);
    }

    function redeemTicket(
        address user_,
        address token_,
        uint256 value_,
        uint256 id_,
        uint256 type_
    ) external onlyRole(Roles.PROXY_ROLE) {
        Ticket memory ticket = __tickets[id_];
        if (ticket.account != address(0) || ticket.isUsed)
            revert Gacha__InvalidTicket();
        if (!__supportedPayments.get(token_.fillLast96Bits()))
            revert Gacha__InvalidPayment();
        if (!token_.supportsInterface(type(IERC721Upgradeable).interfaceId)) {
            uint256 unitPrice = IBKTreasury(vault()).priceOf(token_) *
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
            IWithdrawableUpgradeable(vault()).withdraw(
                token_,
                ticket.account,
                value_,
                "SAFE-WITHDRAW"
            );
        else IBK721(token_).safeMint(ticket.account, value_);

        ticket.isUsed = true;
        __tickets[ticketId_] = ticket;
        emit Rewarded(ticketId_, token_, value_);
    }
}

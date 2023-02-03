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
        address[] memory _supportedPayments = supportedPayments_;
        uint256[] memory uintPayments;
        assembly {
            uintPayments := _supportedPayments
            mstore(0, typeId_)
            mstore(32, __unitPrices.slot)
            mstore(32, keccak256(0, 64))
        }
        uint256 length = supportedPayments_.length;
        for (uint256 i; i < length; ) {
            __supportedPayments.set(uintPayments[i]);
            assembly {
                let idxAlloc := shl(5, i)
                mstore(
                    0,
                    calldataload(add(supportedPayments_.offset, idxAlloc))
                )
                sstore(
                    keccak256(0, 64),
                    calldataload(add(unitPrices_.offset, idxAlloc))
                )
                i := add(i, 1)
            }
        }

        emit TicketPricesUpdated(
            _msgSender(),
            typeId_,
            supportedPayments_,
            unitPrices_
        );
    }

    function supportedPayments(address payment_) external view returns (bool) {
        return __supportedPayments.get(payment_.fillLast96Bits());
    }

    function redeemTicket(
        address user_,
        address token_,
        uint256 value_,
        uint256 id_,
        uint256 type_
    ) external onlyRole(Roles.PROXY_ROLE) {
        bytes32 ticketKey;
        Ticket memory ticket;
        assembly {
            mstore(0x00, id_)
            mstore(0x20, __tickets.slot)
            ticketKey := keccak256(0, 64)
            ticket := sload(ticketKey)
        }

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
        assembly {
            sstore(ticketKey, ticket)
        }

        emit Redeemed(user_, id_, type_);
    }

    function reward(
        address token_,
        uint256 ticketId_,
        uint256 value_
    ) external onlyRole(Roles.OPERATOR_ROLE) {
        bytes32 ticketKey;
        Ticket memory ticket;
        assembly {
            mstore(0x00, ticketId_)
            mstore(0x20, __tickets.slot)
            ticketKey := keccak256(0, 64)
            ticket := sload(ticketKey)
        }

        if (ticket.account == address(0)) revert Gacha__InvalidTicket();

        if (ticket.isUsed) revert Gacha__PurchasedTicket();

        ticket.isUsed = true;

        assembly {
            sstore(ticketKey, ticket)
        }

        if (!token_.supportsInterface(type(IERC721Upgradeable).interfaceId))
            IWithdrawableUpgradeable(vault()).withdraw(
                token_,
                ticket.account,
                value_,
                "SAFE-WITHDRAW"
            );
        else IBK721(token_).safeMint(ticket.account, value_);

        emit Rewarded(_msgSender(), ticketId_, token_, value_);
    }
}

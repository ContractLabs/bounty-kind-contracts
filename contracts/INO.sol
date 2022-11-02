// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "oz-custom/contracts/internal-upgradeable/ProxyCheckerUpgradeable.sol";
import {
    ERC721TokenReceiverUpgradeable
} from "oz-custom/contracts/oz-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "oz-custom/contracts/oz-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "oz-custom/contracts/oz-upgradeable/token/ERC20/extensions/draft-IERC20PermitUpgradeable.sol";

import "./internal-upgradeable/BaseUpgradeable.sol";

import "./internal-upgradeable/FundForwarderUpgradeable.sol";

import "./interfaces/IINO.sol";
import "./interfaces/IBK721.sol";

import "oz-custom/contracts/oz-upgradeable/token/ERC20/extensions/draft-IERC20PermitUpgradeable.sol";

import "oz-custom/contracts/libraries/SSTORE2.sol";
import "oz-custom/contracts/libraries/BitMap256.sol";
import "oz-custom/contracts/libraries/Bytes32Address.sol";
import "oz-custom/contracts/libraries/EnumerableSetV2.sol";

contract INO is
    IINO,
    BaseUpgradeable,
    ProxyCheckerUpgradeable,
    FundForwarderUpgradeable,
    ReentrancyGuardUpgradeable,
    ERC721TokenReceiverUpgradeable
{
    using SSTORE2 for bytes;
    using SSTORE2 for bytes32;
    using BitMap256 for uint256;
    using Bytes32Address for address;
    using Bytes32Address for uint256;

    bytes32 public constant VERSION =
        0x3d277aecc6eab90208a3b105ab5e72d55c1c0c69bf67ccc488f44498aef41550;

    ///@dev value is equal to keccak256("Permit(address buyer,uint256 ticketId,uint256 amount,uint256 nonce,uint256 deadline)")
    bytes32 public constant _PERMIT_TYPE_HASH =
        0x5421fbeb44dd87c0132aceddf0c5325a43ac9ccb2291ee8cbf59d92a5fb63681;

    // campaignId => supplies
    mapping(uint256 => uint256) private _supplies;
    // campaignId => Campaign
    mapping(uint256 => bytes32) private _campaigns;
    // buyer => campaignId => purchasedAmt
    mapping(bytes32 => mapping(uint256 => uint256)) private _purchasedAmt;

    function __INO_init(IGovernanceV2 governance_, ITreasuryV2 treasury_)
        internal
        onlyInitializing
    {
        __INO_init_unchained();
        __ReentrancyGuard_init_unchained();
        __Base_init_unchained(governance_, 0);
        __FundForwarder_init_unchained(treasury_);
    }

    function __INO_init_unchained() internal onlyInitializing {}

    function redeem(
        uint256 ticketId_,
        uint256 deadline_,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external payable whenNotPaused nonReentrant {
        address sender = _msgSender();
        _onlyEOA(sender);
        _checkBlacklist(sender);

        Campaign memory _campaign;
        uint256 amount;
        // get rid of stack too deep
        {
            uint256 campaignId = (ticketId_ >> 32) & ~uint64(0);
            _campaign = abi.decode(_campaigns[campaignId].read(), (Campaign));
            if (
                _campaign.start > block.timestamp ||
                _campaign.end < block.timestamp
            ) revert INO__CampaignEnded();
            amount = ticketId_ & ~uint32(0);
            _supplies[campaignId] -= amount;
            if (
                (_purchasedAmt[sender.fillLast12Bytes()][
                    campaignId
                ] += amount) > _campaign.limit
            ) revert INO__AllocationExceeded();
        }

        address paymentToken;
        uint256 total;
        // get rid of stack too deep
        {
            paymentToken = ticketId_.fromLast160Bits();
            Payment memory payment;
            // get rid of stack too deep
            {
                uint256 pmt;
                assembly {
                    pmt := paymentToken
                }

                if (
                    !_campaign.bitmap.unsafeGet(pmt) ||
                    (payment = _campaign.payments[pmt.index()]).paymentToken !=
                    paymentToken
                ) revert INO__UnsupportedPayment(paymentToken);
            }
            total = payment.unitPrices * amount;
            if (paymentToken != address(0))
                IERC20PermitUpgradeable(paymentToken).permit(
                    sender,
                    address(this),
                    total,
                    deadline_,
                    v,
                    r,
                    s
                );
        }
        _safeTransferFrom(
            IERC20Upgradeable(paymentToken),
            sender,
            address(treasury()),
            total
        );
        IBK721(_campaign.nft).safeMintBatch(sender, _campaign.typeNFT, amount);

        if (msg.value != 0) _safeNativeTransfer(sender, msg.value);

        emit Redeemed(sender, ticketId_, paymentToken, total);
    }

    function setCampaign(uint256 campaignId_, Campaign calldata campaign_)
        external
        onlyRole(Roles.OPERATOR_ROLE)
    {
        bytes32 ptr = _campaigns[campaignId_];
        if (
            ptr != 0 && abi.decode(ptr.read(), (Campaign)).end > block.timestamp
        ) revert INO__OnGoingCampaign();
        Campaign memory _campaign = campaign_;
        emit NewCampaign(
            campaignId_,
            _campaign.start += uint64(block.timestamp),
            _campaign.end += uint64(block.timestamp)
        );
        _supplies[campaignId_] = _campaign.maxSupply;
        _campaigns[campaignId_] = abi.encode(_campaign).write();
    }

    function paymentOf(uint256 campaignId_)
        public
        view
        returns (Payment[] memory)
    {
        return abi.decode(_campaigns[campaignId_].read(), (Campaign)).payments;
    }

    function campaign(uint256 campaignId_)
        external
        view
        returns (Campaign memory campaign_)
    {
        bytes32 ptr = _campaigns[campaignId_];
        if (ptr == 0) return campaign_;
        campaign_ = abi.decode(ptr.read(), (Campaign));
    }

    function onERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external override returns (bytes4) {
        emit Received(from, to, tokenId, data);
        return type(ERC721TokenReceiverUpgradeable).interfaceId;
    }

    function updateTreasury(ITreasuryV2 treasury_)
        external
        override
        onlyRole(Roles.OPERATOR_ROLE)
        whenPaused
    {
        emit TreasuryUpdated(treasury(), treasury_);
        _updateTreasury(treasury_);
    }

    uint256[47] private __gap;
}

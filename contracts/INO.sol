// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "oz-custom/contracts/oz-upgradeable/security/ReentrancyGuardUpgradeable.sol";

import "oz-custom/contracts/presets-upgradeable/base/ManagerUpgradeable.sol";

import "./internal-upgradeable/BKFundForwarderUpgradeable.sol";
import "oz-custom/contracts/internal-upgradeable/MultiDelegatecallUpgradeable.sol";

import "./interfaces/IINO.sol";
import "./interfaces/IBK721.sol";
import "./interfaces/IBKTreasury.sol";

import {
    IERC20PermitUpgradeable
} from "oz-custom/contracts/oz-upgradeable/token/ERC20/extensions/draft-IERC20PermitUpgradeable.sol";

import "oz-custom/contracts/libraries/SSTORE2.sol";
import "oz-custom/contracts/libraries/structs/BitMap256.sol";
import "oz-custom/contracts/libraries/Bytes32Address.sol";
import "oz-custom/contracts/libraries/FixedPointMathLib.sol";

contract INO is
    IINO,
    ManagerUpgradeable,
    BKFundForwarderUpgradeable,
    ReentrancyGuardUpgradeable,
    MultiDelegatecallUpgradeable
{
    using SSTORE2 for *;
    using Bytes32Address for *;
    using BitMap256 for uint256;
    using FixedPointMathLib for *;

    bytes32 public constant VERSION =
        0x3d277aecc6eab90208a3b105ab5e72d55c1c0c69bf67ccc488f44498aef41550;

    /// @dev value is equal to keccak256("Permit(address buyer,uint256 ticketId,uint256 amount,uint256 nonce,uint256 deadline)")
    bytes32 public constant __PERMIT_TYPE_HASH =
        0x5421fbeb44dd87c0132aceddf0c5325a43ac9ccb2291ee8cbf59d92a5fb63681;

    // campaignId => supplies
    mapping(uint256 => uint256) private __supplies;
    // campaignId => Campaign
    mapping(uint256 => bytes32) private __campaigns;
    // buyer => campaignId => purchasedAmt
    mapping(bytes32 => mapping(uint256 => uint256)) private __purchasedAmt;

    function initialize(IAuthority authority_) external initializer {
        __ReentrancyGuard_init_unchained();
        __MultiDelegatecall_init_unchained();
        __Manager_init_unchained(authority_, 0);
        __FundForwarder_init_unchained(
            IFundForwarderUpgradeable(address(authority_)).vault()
        );
    }

    function changeVault(
        address vault_
    ) external override onlyRole(Roles.TREASURER_ROLE) {
        _changeVault(vault_);
    }

    function batchExecute(
        bytes[] calldata data_
    ) external returns (bytes[] memory) {
        return _multiDelegatecall(data_);
    }

    function ticketId(
        uint64 campaignId_,
        uint32 amount_
    ) external pure returns (uint256) {
        return (campaignId_ << 32) | (amount_ & ~uint32(0));
    }

    function redeem(
        address user_,
        address token_,
        uint256 value_,
        uint256 ticketId_
    ) external onlyRole(Roles.PROXY_ROLE) {
        Campaign memory _campaign;
        uint256 amount;
        // get rid of stack too deep
        {
            uint256 campaignId = (ticketId_ >> 32) & ~uint32(0);
            _campaign = abi.decode(__campaigns[campaignId].read(), (Campaign));

            if (
                _campaign.start > block.timestamp ||
                _campaign.end < block.timestamp
            ) revert INO__CampaignEndedOrNotYetStarted();

            amount = ticketId_ & ~uint32(0);
            __supplies[campaignId] -= amount;
            if (
                (__purchasedAmt[user_.fillLast12Bytes()][
                    campaignId
                ] += amount) > _campaign.limit
            ) revert INO__AllocationExceeded();
        }

        {
            uint256 length = _campaign.payments.length;
            bool contains;
            for (uint256 i; i < length; ) {
                if (token_ == _campaign.payments[i]) {
                    contains = true;
                    break;
                }
                unchecked {
                    ++i;
                }
            }
            if (!contains) revert INO__UnsupportedPayment(token_);
        }

        {
            address _vault = vault();
            // usd per token
            uint256 unitPrice = IBKTreasury(_vault).priceOf(token_);
            // amount tokens to usd
            uint256 usdPrice = value_.mulDivDown(unitPrice, 1 ether);
            // amount usd to pay
            uint256 usdTotal = _campaign.usdPrice * amount;
            if (usdPrice < usdTotal) revert INO__InsuficcientAmount();
        }

        IBK721(_campaign.nft).safeMintBatch(user_, _campaign.typeNFT, amount);

        emit Redeemed(user_, ticketId_, token_, value_);
    }

    function setCampaign(
        uint256 campaignId_,
        Campaign calldata campaign_
    ) external onlyRole(Roles.OPERATOR_ROLE) {
        bytes32 ptr = __campaigns[campaignId_];

        if (
            ptr != 0 && abi.decode(ptr.read(), (Campaign)).end > block.timestamp
        ) revert INO__OnGoingCampaign();

        Campaign memory _campaign = campaign_;

        emit NewCampaign(
            campaignId_,
            _campaign.start += uint64(block.timestamp),
            _campaign.end += uint64(block.timestamp)
        );

        __supplies[campaignId_] = _campaign.maxSupply;
        __campaigns[campaignId_] = abi.encode(_campaign).write();
    }

    function paymentOf(
        uint256 campaignId_
    ) public view returns (address[] memory) {
        return abi.decode(__campaigns[campaignId_].read(), (Campaign)).payments;
    }

    function campaign(
        uint256 campaignId_
    ) external view returns (Campaign memory campaign_) {
        bytes32 ptr = __campaigns[campaignId_];
        if (ptr == 0) return campaign_;
        campaign_ = abi.decode(ptr.read(), (Campaign));
    }

    uint256[47] private __gap;
}

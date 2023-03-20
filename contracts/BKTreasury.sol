// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {
    Roles,
    IAuthority,
    TreasuryUpgradeable
} from "oz-custom/contracts/presets-upgradeable/TreasuryUpgradeable.sol";

import {IBKTreasury} from "./interfaces/IBKTreasury.sol";
import {
    AggregatorV3Interface
} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

import {
    EnumerableSet
} from "oz-custom/contracts/oz/utils/structs/EnumerableSet.sol";

contract BKTreasury is TreasuryUpgradeable, IBKTreasury {
    using EnumerableSet for EnumerableSet.AddressSet;

    AggregatorV3Interface public priceFeed;

    mapping(address => uint256) private __priceOf;
    EnumerableSet.AddressSet private __supportedPayments;

    function initialize(
        string calldata name_,
        IAuthority authority_,
        AggregatorV3Interface priceFeed_
    ) external initializer {
        priceFeed = priceFeed_;
        __Treasury_init(authority_, name_);
    }

    function updatePrices(
        address[] calldata tokens_,
        uint256[] calldata prices_
    ) external onlyRole(Roles.TREASURER_ROLE) {
        uint256 length = tokens_.length;
        if (length != prices_.length) revert BKTreasury__LengthMismatch();

        for (uint256 i; i < length; ) {
            __priceOf[tokens_[i]] = prices_[i];
            __supportedPayments.add(tokens_[i]);
            unchecked {
                ++i;
            }
        }

        emit PricesUpdated(_msgSender(), tokens_, prices_);
    }

    function updatePayments(
        address[] calldata payments_,
        bool[] calldata statuses_
    ) external onlyRole(Roles.TREASURER_ROLE) returns (bool[] memory results) {
        uint256 length = payments_.length;
        if (length != statuses_.length) revert BKTreasury__LengthMismatch();

        results = new bool[](length);
        for (uint256 i; i < length; ) {
            results[i] = statuses_[i]
                ? __supportedPayments.add(payments_[i])
                : __supportedPayments.remove(payments_[i]);

            unchecked {
                ++i;
            }
        }

        emit PaymentsUpdated(_msgSender(), payments_, statuses_);
    }

    function priceOf(address token_) external view returns (uint256 usdPrice) {
        if (token_ == address(0)) {
            AggregatorV3Interface _priceFeed = priceFeed;
            (, int256 usdUnit, , , ) = _priceFeed.latestRoundData();
            return (uint256(usdUnit) * 1 ether) / (10 ** _priceFeed.decimals());
        }
        if ((usdPrice = __priceOf[token_]) == 0)
            revert BKTreasury__UnsupportedToken();
    }

    function supportedPayment(address token_) external view returns (bool) {
        return __supportedPayments.contains(token_);
    }

    function viewSupportedPayments() external view returns (address[] memory) {
        return __supportedPayments.values();
    }

    uint256[47] private __gap;
}

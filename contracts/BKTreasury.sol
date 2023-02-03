// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {
    Roles,
    Treasury,
    IAuthority
} from "oz-custom/contracts/presets-upgradeable/Treasury.sol";

import "./interfaces/IBKTreasury.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

import "oz-custom/contracts/oz/utils/structs/EnumerableSet.sol";

contract BKTreasury is Treasury, IBKTreasury {
    using EnumerableSet for EnumerableSet.AddressSet;

    AggregatorV3Interface public immutable priceFeed;

    mapping(address => uint256) private __priceOf;
    EnumerableSet.AddressSet private __supportedPayments;

    constructor(
        IAuthority authority_,
        AggregatorV3Interface priceFeed_,
        string memory name_
    ) payable Treasury(authority_, name_) {
        priceFeed = priceFeed_;
    }

    function updatePrices(
        address[] calldata tokens_,
        uint256[] calldata prices_
    ) external onlyRole(Roles.TREASURER_ROLE) {
        uint256 length = tokens_.length;
        if (length != prices_.length) revert BKTreasury__LengthMismatch();

        assembly {
            mstore(32, __priceOf.slot)
        }

        for (uint256 i; i < length; ) {
            assembly {
                let idx := shl(5, i)
                mstore(0, calldataload(add(tokens_.offset, idx)))
                sstore(keccak256(0, 64), calldataload(add(prices_.offset, idx)))
                i := add(1, i)
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
            if (statuses_[i])
                results[i] = __supportedPayments.add(payments_[i]);
            else results[i] = __supportedPayments.remove(payments_[i]);

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
}

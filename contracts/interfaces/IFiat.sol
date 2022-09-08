// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

interface IFiat {
    error Fiat__InvalidToken(address);
    error Fiat__UnsupportedPayment(address);
    error Fiat__LengthMismatch();

    event PriceSet(address indexed token, uint256 price);
    event PriceSetMulti(address[] indexed tokens, uint256[] prices);

    function setPrice(address token_, uint256 price_) external;

    function setPriceMulti(
        address[] calldata tokens_,
        uint256[] calldata prices_
    ) external;

    function priceOf(address token_) external view returns (uint256);
}

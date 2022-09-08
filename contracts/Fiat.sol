// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./external/utils/introspection/ERC165Checker.sol";

import "./internal/Base.sol";

import "./interfaces/IFiat.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Fiat is IFiat, Base {
    using AddressLib for address;
    using ERC165Checker for address;

    mapping(bytes32 => uint256) private _tokenPrices;

    constructor(address admin_) payable Base(admin_, false) {}

    function setPrice(address token_, uint256 price_)
        external
        override
        onlyOwner
    {
        __setPrice(token_, price_);
        emit PriceSet(token_, price_);
    }

    function setPriceMulti(
        address[] calldata tokens_,
        uint256[] calldata prices_
    ) external override onlyOwner {
        uint256 length = tokens_.length;
        if (length != prices_.length) revert Fiat__LengthMismatch();
        for (uint256 i; i < length; ) {
            __setPrice(tokens_[i], prices_[i]);
            unchecked {
                ++i;
            }
        }
        emit PriceSetMulti(tokens_, prices_);
    }

    function priceOf(address token_) external view override returns (uint256) {
        return _tokenPrices[token_.fillLast12Bytes()];
    }

    function __setPrice(address token_, uint256 price_) private {
        if (!token_.supportsInterface(type(IERC20).interfaceId))
            revert Fiat__InvalidToken(token_);
        if (!admin().acceptedPayment(token_))
            revert Fiat__UnsupportedPayment(token_);

        _tokenPrices[token_.fillLast12Bytes()] = price_;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "oz-custom/contracts/oz-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "oz-custom/contracts/internal-upgradeable/interfaces/IWithdrawableUpgradeable.sol";

interface IBKTreasury {
    error BKTreasury__LengthMismatch();
    error BKTreasury__UnsupportedToken();
    event PaymentsUpdated(
        address indexed operator,
        address[] payments,
        bool[] statuses
    );
    event PricesUpdated(
        address indexed operator,
        address[] tokens,
        uint256[] prices
    );

    function supportedPayment(address token_) external view returns (bool);

    function priceOf(address token_) external view returns (uint256);
}

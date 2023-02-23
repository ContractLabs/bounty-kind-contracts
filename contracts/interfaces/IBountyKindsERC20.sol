// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {
    IUniswapV2Pair
} from "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";

interface IBountyKindsERC20 {
    error BountyKindsERC20__Blacklisted();
    error BountyKindsERC20__InvalidArguments();

    event Refunded(address indexed operator, uint256 indexed refund);

    event Executed(
        address indexed operator,
        address indexed target,
        uint256 indexed value_,
        bytes callData,
        bytes returnData
    );

    event PoolSet(
        address indexed operator,
        IUniswapV2Pair indexed poolOld,
        IUniswapV2Pair indexed poolNew
    );

    function setPool(IUniswapV2Pair pool_) external;

    function mint(address to_, uint256 amount_) external;

    function execute(
        address target_,
        uint256 value_,
        bytes calldata calldata_
    ) external;
}

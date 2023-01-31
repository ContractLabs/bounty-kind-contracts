// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "hardhat/console.sol";

abstract contract Debugger {
    modifier logGas() {
        uint256 gas = gasleft();
        _;
        gas -= gasleft();
        console.log(gas);
    }
}

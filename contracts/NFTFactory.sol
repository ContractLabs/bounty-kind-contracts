// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "oz-custom/contracts/internal/Cloner.sol";
import "oz-custom/contracts/internal/FundForwarder.sol";
import "oz-custom/contracts/internal/MultiDelegatecall.sol";

contract NFTFactory is Cloner, FundForwarder, MultiDelegatecall {
    constructor(
        address implement_,
        address vault_
    ) payable Cloner(implement_) FundForwarder(vault_) {}

    function clone(
        bytes32 salt_,
        bytes4 initSelector_,
        bytes calldata initCode_
    ) external {
        _clone(salt_, initSelector_, initCode_);
    }
}

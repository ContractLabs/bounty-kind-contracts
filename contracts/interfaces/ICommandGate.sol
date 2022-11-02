// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {
    IERC20Permit
} from "oz-custom/contracts/oz/token/ERC20/extensions/draft-IERC20Permit.sol";

interface ICommandGate {
    error CommandGate__Expired();
    error CommandGate__ExecutionFailed();
    error CommandGate__UnknownAddress(address);

    function whitelistAddress(address addr_) external;

    function depositNativeTokenWithCommand(
        address contract_,
        bytes4 fnSig_,
        bytes calldata params_
    ) external payable;

    function depositERC20WithCommand(
        IERC20Permit token_,
        uint256 value_,
        uint256 deadline_,
        uint8 v,
        bytes32 r,
        bytes32 s,
        bytes4 fnSig_,
        address contract_,
        bytes calldata data_
    ) external;

    function withdrawTo(
        address token_,
        address to_,
        uint256 value_
    ) external;
}

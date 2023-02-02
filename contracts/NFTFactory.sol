// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./internal/BKFundForwarder.sol";

import "oz-custom/contracts/internal/Cloner.sol";
import "oz-custom/contracts/internal/MultiDelegatecall.sol";

import "oz-custom/contracts/presets/base/Manager.sol";

import "./interfaces/IBKTreasury.sol";
import {IBKNFT} from "./BK721.sol";

contract NFTFactory is Manager, Cloner, BKFundForwarder, MultiDelegatecall {
    bytes32 public constant VERSION =
        0xc42665b4953fdd2cb30dcf1befa0156911485f4e84e3f90b1360ddfb4fa2f766;

    constructor(
        address implement_,
        IAuthority authority_
    )
        payable
        Cloner(implement_)
        Manager(authority_, Roles.FACTORY_ROLE)
        FundForwarder(IFundForwarder(address(authority_)).vault())
    {}

    function changeVault(
        address vault_
    ) external override onlyRole(Roles.TREASURER_ROLE) {
        _changeVault(vault_);
    }

    function setImplement(
        address implement_
    ) external override onlyRole(Roles.OPERATOR_ROLE) {
        emit ImplementChanged(implement(), implement_);
        _setImplement(implement_);
    }

    function clone(
        string calldata name_,
        string calldata symbol_,
        string calldata baseURI_,
        uint256 feeAmt_,
        IERC20 feeToken_
    ) external onlyRole(Roles.OPERATOR_ROLE) returns (address) {
        bytes32 salt = keccak256(
            abi.encodePacked(name_, symbol_, address(this), VERSION)
        );
        return
            _clone(
                salt,
                IBKNFT.initialize.selector,
                abi.encode(name_, symbol_, baseURI_, feeAmt_, feeToken_)
            );
    }

    function cloneOf(
        string calldata name_,
        string calldata symbol_
    ) external view returns (address, bool) {
        bytes32 salt = keccak256(
            abi.encodePacked(name_, symbol_, address(this), VERSION)
        );
        return _cloneOf(salt);
    }
}

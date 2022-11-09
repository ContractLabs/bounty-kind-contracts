// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "oz-custom/contracts/internal/Cloner.sol";
import "oz-custom/contracts/internal/FundForwarder.sol";
import "oz-custom/contracts/internal/MultiDelegatecall.sol";

import "./internal/Base.sol";

import "./interfaces/ITreasury.sol";
import {IBKNFT} from "./BK721.sol";

contract NFTFactory is Base, Cloner, FundForwarder, MultiDelegatecall {
    bytes32 public constant VERSION =
        0xc42665b4953fdd2cb30dcf1befa0156911485f4e84e3f90b1360ddfb4fa2f766;

    constructor(
        address implement_,
        IAuthority authority_,
        ITreasury vault_
    )
        payable
        Cloner(implement_)
        FundForwarder(address(vault_))
        Base(authority_, Roles.FACTORY_ROLE)
    {}

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
                IBKNFT.init.selector,
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

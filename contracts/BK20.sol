// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "oz-custom/contracts/oz-upgradeable/token/ERC20/extensions/ERC20BurnableUpgradeable.sol";
import {
    ERC20PermitUpgradeable
} from "oz-custom/contracts/oz-upgradeable/token/ERC20/extensions/draft-ERC20PermitUpgradeable.sol";

import "./internal-upgradeable/BaseUpgradeable.sol";
import "./internal-upgradeable/FundForwarderUpgradeable.sol";

import "./interfaces/IBK20.sol";

contract BK20 is
    IBK20,
    BaseUpgradeable,
    ERC20PermitUpgradeable,
    ERC20BurnableUpgradeable,
    FundForwarderUpgradeable
{
    ///@dev value is equal to keccak256("RBK20_v2")
    bytes32 public constant VERSION =
        0x1e3e12e17166fc094bcca954a0694d36b0821cb6dff5e011e3ffef32e174d633;

    function init(
        IAuthority governance_,
        ITreasury treasury_,
        string calldata name_,
        string calldata symbol_,
        uint256 decimals_
    ) external initializer {
        __ERC20Permit_init_unchained(name_);
        __Base_init_unchained(governance_, 0);
        __FundForwarder_init_unchained(treasury_);
        __ERC20_init_unchained(name_, symbol_, decimals_);
    }

    function mint(
        address to_,
        uint256 amount_
    ) external onlyRole(Roles.MINTER_ROLE) {
        _mint(to_, amount_ * 10 ** decimals);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        _requireNotPaused();

        _checkBlacklist(to);
        _checkBlacklist(from);
        _checkBlacklist(_msgSender());

        super._beforeTokenTransfer(from, to, amount);
    }

    function updateTreasury(
        ITreasury treasury_
    ) external override onlyRole(Roles.OPERATOR_ROLE) {
        emit TreasuryUpdated(treasury(), treasury_);
        _updateTreasury(treasury_);
    }
}

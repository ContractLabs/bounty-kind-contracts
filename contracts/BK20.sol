// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {
    IFundForwarderUpgradeable,
    BKFundForwarderUpgradeable
} from "./internal-upgradeable/BKFundForwarderUpgradeable.sol";

import {
    IERC20Upgradeable,
    ERC20BurnableUpgradeable
} from "oz-custom/contracts/oz-upgradeable/token/ERC20/extensions/ERC20BurnableUpgradeable.sol";
import {
    ERC20PermitUpgradeable
} from "oz-custom/contracts/oz-upgradeable/token/ERC20/extensions/draft-ERC20PermitUpgradeable.sol";

import {
    Roles,
    IAuthority,
    ManagerUpgradeable
} from "oz-custom/contracts/presets-upgradeable/base/ManagerUpgradeable.sol";

import {IBK20} from "./interfaces/IBK20.sol";
import {
    ITreasury
} from "oz-custom/contracts/presets-upgradeable/interfaces/ITreasury.sol";

contract BK20 is
    IBK20,
    ManagerUpgradeable,
    ERC20PermitUpgradeable,
    ERC20BurnableUpgradeable,
    BKFundForwarderUpgradeable
{
    ///@dev value is equal to keccak256("RBK20_v2")
    bytes32 public constant VERSION =
        0x1e3e12e17166fc094bcca954a0694d36b0821cb6dff5e011e3ffef32e174d633;

    function initialize(
        IAuthority authority_,
        string calldata name_,
        string calldata symbol_
    ) external initializer {
        __ERC20Permit_init(name_);
        __Manager_init_unchained(authority_, 0);
        __ERC20_init_unchained(name_, symbol_, 18);
        __FundForwarder_init_unchained(
            IFundForwarderUpgradeable(address(authority_)).vault()
        );
    }

    function changeVault(
        address vault_
    ) external override onlyRole(Roles.TREASURER_ROLE) {
        _changeVault(vault_);
    }

    function mint(
        address to_,
        uint256 amount_
    ) external onlyRole(Roles.MINTER_ROLE) {
        _mint(to_, amount_ * 1 ether);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override whenNotPaused {
        _checkBlacklist(to);
        _checkBlacklist(from);
        _checkBlacklist(_msgSender());

        super._beforeTokenTransfer(from, to, amount);
    }

    uint256[50] private __gap;
}

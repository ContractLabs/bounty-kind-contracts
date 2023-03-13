// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {
    Roles,
    AuthorityUpgradeable
} from "oz-custom/contracts/presets-upgradeable/AuthorityUpgradeable.sol";

import {
    FundForwarderUpgradeable,
    BKFundForwarderUpgradeable
} from "./internal-upgradeable/BKFundForwarderUpgradeable.sol";
import {
    IFundForwarderUpgradeable
} from "oz-custom/contracts/internal-upgradeable/interfaces/IFundForwarderUpgradeable.sol";

contract BKAuthority is AuthorityUpgradeable, BKFundForwarderUpgradeable {
    function initialize(
        address admin_,
        bytes32[] calldata roles_,
        address[] calldata operators_
    ) external initializer {
        __BKAuthority_init_unchained();
        __Authority_init(admin_, "", roles_, operators_);
    }

    function __BKAuthority_init_unchained() internal onlyInitializing {
        _setRoleAdmin(Roles.MINTER_ROLE, Roles.OPERATOR_ROLE);
    }

    function _beforeRecover(
        bytes memory
    ) internal override onlyRole(Roles.OPERATOR_ROLE) whenPaused {}

    function _afterRecover(
        address,
        address,
        uint256,
        bytes memory
    ) internal override {}

    function _checkValidAddress(
        address vault_
    )
        internal
        view
        override(BKFundForwarderUpgradeable, FundForwarderUpgradeable)
    {
        BKFundForwarderUpgradeable._checkValidAddress(vault_);
    }

    uint256[50] private __gap;
}

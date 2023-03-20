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
        __Authority_init(admin_, roles_, operators_);
    }

    function __BKAuthority_init_unchained() internal onlyInitializing {
        _setRoleAdmin(Roles.MINTER_ROLE, Roles.OPERATOR_ROLE);
    }

    function _grantRole(bytes32 role_, address account_) internal override {
        if (
            !(role_ == Roles.PROXY_ROLE ||
                role_ == Roles.SIGNER_ROLE ||
                role_ == Roles.PAUSER_ROLE ||
                role_ == Roles.MINTER_ROLE ||
                role_ == Roles.OPERATOR_ROLE ||
                role_ == Roles.UPGRADER_ROLE ||
                role_ == Roles.TREASURER_ROLE ||
                role_ == DEFAULT_ADMIN_ROLE)
        ) revert AccessControl__Unauthorized();

        super._grantRole(role_, account_);
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

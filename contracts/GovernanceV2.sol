// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "oz-custom/contracts/oz-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "oz-custom/contracts/oz-upgradeable/security/PausableUpgradeable.sol";
import "oz-custom/contracts/internal-upgradeable/ProxyCheckerUpgradeable.sol";
import "oz-custom/contracts/internal-upgradeable/BlacklistableUpgradeable.sol";
import "oz-custom/contracts/oz-upgradeable/access/AccessControlEnumerableUpgradeable.sol";

import "./libraries/Roles.sol";
import "./interfaces/IGovernanceV2.sol";

contract GovernanceUpgradeable is
    IGovernanceV2,
    UUPSUpgradeable,
    PausableUpgradeable,
    ProxyCheckerUpgradeable,
    BlacklistableUpgradeable,
    AccessControlEnumerableUpgradeable
{
    bytes32 public constant VERSION =
        0xcab5b167ada4badb5ce0ed5f16a74aee744ece5365888dc008eb82537ed584dc;

    function init() external initializer {
        __Pausable_init_unchained();

        address sender = _msgSender();
        _grantRole(DEFAULT_ADMIN_ROLE, sender);

        _grantRole(Roles.PAUSER_ROLE, sender);
        _grantRole(Roles.MINTER_ROLE, sender);
        _grantRole(Roles.OPERATOR_ROLE, sender);
        _grantRole(Roles.UPGRADER_ROLE, sender);
        _grantRole(Roles.TREASURER_ROLE, sender);

        _setRoleAdmin(Roles.PAUSER_ROLE, Roles.OPERATOR_ROLE);
        _setRoleAdmin(Roles.MINTER_ROLE, Roles.OPERATOR_ROLE);
        _setRoleAdmin(Roles.TREASURER_ROLE, Roles.OPERATOR_ROLE);
    }

    function setRoleAdmin(bytes32 role, bytes32 adminRole)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        _setRoleAdmin(role, adminRole);
    }

    function requestAccess(bytes32 role) external whenNotPaused {
        address origin = _txOrigin();
        _checkRole(Roles.OPERATOR_ROLE, origin);

        address sender = _msgSender();
        _onlyProxy(sender, origin);

        _grantRole(Roles.PROXY_ROLE, sender);
        if (role != 0) _grantRole(role, sender);

        emit ProxyAccessGranted(sender);
    }

    function pause() external onlyRole(Roles.PAUSER_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(Roles.PAUSER_ROLE) {
        _unpause();
    }

    function paused()
        public
        view
        override(IGovernanceV2, PausableUpgradeable)
        returns (bool)
    {
        return PausableUpgradeable.paused();
    }

    function setUserStatus(address account_, bool status_)
        external
        override(BlacklistableUpgradeable, IBlacklistableUpgradeable)
        whenPaused
        onlyRole(Roles.PAUSER_ROLE)
    {
        _setUserStatus(account_, status_);
        if (status_) emit Blacklisted(account_);
        else emit Whitelisted(account_);
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        virtual
        override
        onlyRole(Roles.UPGRADER_ROLE)
    {}
}

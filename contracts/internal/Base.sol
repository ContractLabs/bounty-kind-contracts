// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "../interfaces/IGovernanceV2.sol";

import "../libraries/Roles.sol";

error Base__Paused();
error Base__NotPaused();
error Base__AlreadySet();
error Base__Blacklisted();
error Base__Unauthorized();

abstract contract Base {
    bytes32 private _authority;

    modifier onlyRole(bytes32 role) {
        _checkRole(role, msg.sender);
        _;
    }

    modifier onlyWhitelisted() {
        _checkBlacklist(msg.sender);
        _;
    }

    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    modifier whenPaused() {
        _requirePaused();
        _;
    }

    event AuthorityUpdated(
        IGovernanceV2 indexed from,
        IGovernanceV2 indexed to
    );

    constructor(IGovernanceV2 authority_, bytes32 role_) payable {
        authority_.requestAccess(role_);
        __updateAuthority(authority_);
    }

    function updateAuthority(IGovernanceV2 authority_)
        external
        onlyRole(Roles.OPERATOR_ROLE)
    {
        IGovernanceV2 old = authority();
        if (old == authority_) revert Base__AlreadySet();
        __updateAuthority(authority_);
        emit AuthorityUpdated(old, authority_);
    }

    function authority() public view returns (IGovernanceV2 authority_) {
        /// @solidity memory-safe-assembly
        assembly {
            authority_ := sload(_authority.slot)
        }
    }

    function _checkBlacklist(address account_) internal view {
        if (authority().isBlacklisted(account_)) revert Base__Blacklisted();
    }

    function _checkRole(bytes32 role_, address account_) internal view {
        if (!authority().hasRole(role_, account_)) revert Base__Unauthorized();
    }

    function __updateAuthority(IGovernanceV2 authority_) internal {
        /// @solidity memory-safe-assembly
        assembly {
            sstore(_authority.slot, authority_)
        }
    }

    function _requirePaused() internal view {
        if (!authority().paused()) revert Base__NotPaused();
    }

    function _requireNotPaused() internal view {
        if (authority().paused()) revert Base__Paused();
    }

    function _hasRole(bytes32 role_, address account_)
        internal
        view
        returns (bool)
    {
        return authority().hasRole(role_, account_);
    }
}

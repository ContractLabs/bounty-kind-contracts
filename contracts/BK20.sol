// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "oz-custom/contracts/oz-upgradeable/token/ERC20/extensions/draft-ERC20PermitUpgradeable.sol";

import "./internal-upgradeable/BaseUpgradeable.sol";
import "./internal-upgradeable/FundForwarderUpgradeable.sol";

import "./interfaces/IBK20.sol";

contract RBK20v2 is
    IBK20,
    BaseUpgradeable,
    FundForwarderUpgradeable,
    ERC20PermitUpgradeable
{
    ///@dev value is equal to keccak256("RBK20_v2")
    bytes32 public constant VERSION =
        0x1e3e12e17166fc094bcca954a0694d36b0821cb6dff5e011e3ffef32e174d633;

    function init(
        IGovernanceV2 governance_,
        ITreasuryV2 treasury_,
        string calldata name_,
        string calldata symbol_,
        uint256 decimals_
    ) external initializer {
        __ERC20Permit_init(name_);
        __Base_init(governance_, 0);
        __ERC20_init(name_, symbol_, decimals_);
        __FundForwarder_init(treasury_);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        _requireNotPaused();
        address sender = _msgSender();
        _checkBlacklist(sender);
        _checkBlacklist(from);
        _checkBlacklist(to);
        super._beforeTokenTransfer(from, to, amount);
    }

    function updateTreasury(ITreasuryV2 treasury_)
        external
        override
        whenPaused
        onlyRole(Roles.OPERATOR_ROLE)
    {
        emit TreasuryUpdated(treasury(), treasury_);
        _updateTreasury(treasury_);
    }
}

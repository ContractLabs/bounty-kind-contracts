// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./Base.sol";

error BusinessRole__Unauthorized();

abstract contract BusinessRole is Base {
    bytes32 private constant _BUSINESS_ROLE =
        0x966a00e53c991954f9346cf783097be60911b589dd69ff02c7a9fd1c79215029;

    modifier onlyManager() {
        _onlyManager(_msgSender());
        _;
    }

    function isBusiness(address account_) public view returns (bool) {
        return admin().hasRole(_BUSINESS_ROLE, account_);
    }

    function getBusinessAddresses() external view returns (address[] memory) {
        return admin().getRoleMulti(_BUSINESS_ROLE);
    }

    function setBusinessAddress(address[] calldata addrs_) external onlyOwner {
        admin().grantRoleMulti(_BUSINESS_ROLE, addrs_);
    }

    function _onlyManager(address sender_) internal view {
        if (!(sender_ == owner() || isBusiness(sender_)))
            revert BusinessRole__Unauthorized();
    }
}

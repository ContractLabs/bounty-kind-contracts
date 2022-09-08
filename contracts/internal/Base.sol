// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "../external/access/Ownable.sol";

import "../interfaces/IGovernance.sol";

import "../libraries/AddressLib.sol";

error Base__Unauthorized();
error Base__NonZeroAddress();
error Base__OnlyEOA(address sender);
error Base__NativeTransferFailed();

abstract contract Base is Ownable {
    using AddressLib for address;
    using AddressLib for bytes32;

    bytes32 private _admin;

    event AdminChanged(address indexed from, address indexed to);

    constructor(address admin_, bool register_) payable {
        _updateAdmin(admin_, register_);
    }

    function updateAdmin(address admin_, bool register_) external onlyOwner {
        emit AdminChanged(_admin.fromFirst20Bytes(), admin_);
        _updateAdmin(admin_, register_);
    }

    function admin() public view returns (IGovernance) {
        return IGovernance(_admin.fromFirst20Bytes());
    }

    function _updateAdmin(address admin_, bool register_) internal {
        _admin = admin_.fillLast12Bytes();
        if (register_) IGovernance(admin_).grantRoleProxy(address(this));
    }

    function nativeTransfer(address to_, uint256 amount_) external onlyOwner {
        (bool ok, ) = payable(to_).call{value: amount_}("");
        if (!ok) revert Base__NativeTransferFailed();
    }
}

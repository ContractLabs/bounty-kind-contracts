// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "../external/utils/Context.sol";

error OnlyProxy__OnlyContractAllowed();

abstract contract OnlyProxy is Context {
    modifier onlyProxy() {
        _onlyProxy(_msgSender());
        _;
    }

    function _isProxy(address sender_) internal view returns (bool) {
        return sender_ != tx.origin && sender_.code.length != 0;
    }

    function _onlyProxy(address sender_) internal view {
        if (!_isProxy(sender_))
            revert OnlyProxy__OnlyContractAllowed();
    }
}

// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.10;

error ReentrancyGuard__Locked();

abstract contract ReentrancyGuard {
    uint256 private _locked;

    modifier nonReentrant() virtual {
        if (_locked != 0) revert ReentrancyGuard__Locked();

        _locked = 1;

        _;

        _locked = 0;
    }
}

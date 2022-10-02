// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./IBK721.sol";

interface IRBK721 is IBK721 {
    error RBK721__Rented();
    error RBK721__Expired();

    function setUser(
        uint256 tokenId,
        uint64 expires_,
        uint256 deadline_,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;
}

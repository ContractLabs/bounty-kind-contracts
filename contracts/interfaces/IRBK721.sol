// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./IBK721.sol";

interface IRBK721 is IBK721 {
    error RBK721__Rented();
    error RBK721__Expired();
    error RBK721__InvalidSignature();

    function setUser(
        uint256 tokenId,
        uint64 expires_,
        uint256 deadline_,
        bytes calldata signature_
    ) external;
}

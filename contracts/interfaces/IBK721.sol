// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./IBKAsset.sol";

interface IBK721 is IBKAsset {
    error BK721__TokenNotSupported();
    event BatchMinted(address indexed to, uint256 indexed amount);

    function mint(address to_, uint256 tokenId_) external;

    function safeMint(address to_, uint256 tokenId_) external;

    function mintBatch(
        address to_,
        uint256 fromId_,
        uint256 length_
    ) external;

    function safeMintBatch(
        address to_,
        uint256 fromId_,
        uint256 length_
    ) external;
}

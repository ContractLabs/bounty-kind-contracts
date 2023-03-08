// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {IBKAsset} from "./IBKAsset.sol";

interface IBK721 is IBKAsset {
    error BK721__Expired();
    error BK721__Unauthorized();
    error BK721__LengthMismatch();
    error BK721__ExecutionFailed();
    error BK721__InvalidSignature();
    error BK721__TokenNotSupported();

    event Merged(address indexed account, uint256[] from, uint256 to);
    event BatchMinted(
        address indexed operator,
        address indexed to,
        uint256 indexed amount
    );

    event BatchTransfered(
        address indexed operator,
        address indexed from,
        uint256 indexed nextId,
        address[] ids
    );

    function safeTransferBatch(
        address from_,
        address[] calldata tos_,
        uint256[] calldata tokenIds_
    ) external;

    function mint(
        address to_,
        uint256 tokenId_
    ) external returns (uint256 tokenId);

    function safeMint(
        address to_,
        uint256 tokenId_
    ) external returns (uint256 tokenId);

    function mintBatch(
        address to_,
        uint256 fromId_,
        uint256 length_
    ) external returns (uint256[] memory tokenIds);

    function safeMintBatch(
        address to_,
        uint256 fromId_,
        uint256 length_
    ) external returns (uint256[] memory tokenIds);

    function merge(
        uint256[] calldata fromIds_,
        uint256 toId_,
        uint256 deadline_,
        bytes calldata signature_
    ) external;

    function nonces(address account_) external view returns (uint256);

    function nextIdFromType(uint256 typeId_) external view returns (uint256);

    function baseURI() external view returns (string memory);

    function setBaseURI(string calldata baseURI_) external;
}

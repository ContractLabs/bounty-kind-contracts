// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./IBKAsset.sol";
import "oz-custom/contracts/oz-upgradeable/token/ERC20/IERC20Upgradeable.sol";

interface IBK721 is IBKAsset {
    error BK721__Expired();
    error BK721__NotMinted();
    error BK721__NotLocked();
    error BK721__Unauthorized();
    error BK721__AlreadyMinted();
    error BK721__AlreadyLocked();
    error BK721__InvalidSignature();
    error BK721__TokenNotSupported();

    event FeeUpdated(IERC20Upgradeable indexed token, uint256 indexed amount);
    event Locked(uint256 indexed tokenId);
    event Merged(uint256[] indexed from, uint256 to);
    event Released(uint256 indexed tokenId);
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

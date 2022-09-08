// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

interface IERC721Mintable {
    function mint(address to) external returns (uint256);

    function safeMint(address to) external;

    function multipleMint(address to, uint256 numItems) external;

    function multipleMintAccounts(
        address[] memory tos,
        uint256[] memory numItems
    ) external;
}
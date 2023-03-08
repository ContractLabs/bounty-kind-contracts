// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

import {
    ERC721,
    IERC721,
    ERC721TokenReceiver
} from "oz-custom/contracts/oz/token/ERC721/ERC721.sol";

contract MockERC721 is ERC721 {
    constructor() ERC721("Token", "TKN") {}

    function tokenURI(
        uint256
    ) public pure virtual override returns (string memory) {}

    function mint(address to, uint256 tokenId) public virtual {
        _mint(to, tokenId);
    }

    function burn(uint256 tokenId) public virtual {
        _burn(tokenId);
    }

    function safeMint(address to, uint256 tokenId) public virtual {
        _safeMint(to, tokenId);
    }

    function safeMint(
        address to,
        uint256 tokenId,
        bytes memory data
    ) public virtual {
        _safeMint(to, tokenId, data);
    }

    function _baseURI()
        internal
        view
        virtual
        override
        returns (string memory)
    {}
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {IBKAsset} from "./IBKAsset.sol";

interface IBK721 is IBKAsset {
    /**
     * @dev Throws if the exchange request has already expired.
     */
    error BK721__Expired();
    /**
     * @dev Throws if the exchange request is not authorized.
     */
    error BK721__Unauthorized();
    /**
     * @dev Throws if the length of an array does not match the expected length.
     */
    error BK721__LengthMismatch();
    /**
     * @dev Throws if an execution fails.
     */
    error BK721__ExecutionFailed();
    /**
     * @dev Throws if the signature is invalid.
     */
    error BK721__InvalidSignature();
    /**
     * @dev Throws if the token is not supported.
     */
    error BK721__TokenNotSupported();

    /**
     * @dev Emitted when tokens are exchanged between two users.
     * @param sender The address of the sender.
     * @param forNFT The instance of IBK721.
     * @param forTypeId The type ID of the token.
     * @param forAmount The amount of tokens being exchanged.
     * @param senderNFTIds The token IDs being transferred.
     */
    event Exchanged(
        address indexed sender,
        IBK721 indexed forNFT,
        uint256 indexed forTypeId,
        uint256 forAmount,
        uint256[] senderNFTIds
    );

    /**
     * @dev Emitted when two or more NFTs are merged into a single NFT.
     * @param account The account to which the NFT is merged.
     * @param from The token IDs being merged.
     * @param to The token ID of the resulting merged NFT.
     */
    event Merged(address indexed account, uint256[] from, uint256 to);

    /**
     * @dev Emitted when tokens are redeemed by a user.
     * @param operator The address of the operator redeeming the tokens.
     * @param claimer The address of the user claiming the tokens.
     * @param typeId The type ID of the token.
     * @param amount The amount of tokens being redeemed.
     */
    event Redeemded(
        address indexed operator,
        address indexed claimer,
        uint256 indexed typeId,
        uint256 amount
    );

    /**
     * @dev Emitted when tokens are minted in bulk by an operator.
     * @param operator The address of the operator minting the tokens.
     * @param amount The amount of tokens being minted.
     * @param tos The addresses of the users receiving the tokens.
     */
    event BatchMinted(
        address indexed operator,
        uint256 indexed amount,
        address[] tos
    );

    /**
     * @dev Emitted when tokens are transferred in bulk from one user to multiple users.
     * @param operator The address of the operator performing the transfer.
     * @param from The address of the user transferring the tokens.
     * @param nextId The next available token ID.
     */
    event BatchTransfered(
        address indexed operator,
        address indexed from,
        uint256 indexed nextId
    );

    function exchangeAssets(
        IBK721 forNFT_,
        uint256 forAmount_,
        uint256 forTypeId_,
        uint256 nonce_,
        uint256 deadline_,
        uint256[] calldata myIds_,
        bytes calldata signature_
    ) external returns (uint256[] memory forIds);

    function redeemBulk(
        uint256 nonce_,
        uint256 amount_,
        uint256 typeId_,
        address claimer_,
        uint256 deadline_,
        bytes calldata signature_
    ) external;

    function transferBatch(
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
        uint256 typeId_
    ) external returns (uint256 tokenId);

    function mintBatch(uint256 typeId_, address[] calldata tos_) external;

    function safeMintBatch(
        address to_,
        uint256 typeId_,
        uint256 length_
    ) external returns (uint256[] memory tokenIds);

    function merge(
        uint256[] calldata fromIds_,
        uint256 toId_,
        uint256 deadline_,
        bytes calldata signature_
    ) external;

    function nonces(address account_) external view returns (uint256);

    function nonceBitMaps(
        address account_,
        uint256 nonce_
    ) external view returns (uint256 bitmap, bool isDirtied);

    function invalidateNonce(
        address account_,
        uint248 wordPos_,
        uint256 mask_
    ) external;

    function nextIdFromType(uint256 typeId_) external view returns (uint256);

    function baseURI() external view returns (string memory);

    function setBaseURI(string calldata baseURI_) external;
}

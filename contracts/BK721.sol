// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "oz-custom/contracts/oz-upgradeable/token/ERC721/extensions/ERC721PermitUpgradeable.sol";
import "oz-custom/contracts/oz-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";

import "oz-custom/contracts/presets-upgradeable/base/ManagerUpgradeable.sol";
import "oz-custom/contracts/internal-upgradeable/ProtocolFeeUpgradeable.sol";
import "oz-custom/contracts/internal-upgradeable/FundForwarderUpgradeable.sol";

import "./interfaces/IBK721.sol";
import "./interfaces/IBKTreasury.sol";

import "oz-custom/contracts/libraries/SSTORE2.sol";
import "oz-custom/contracts/libraries/StringLib.sol";

abstract contract BK721 is
    IBK721,
    ManagerUpgradeable,
    ProtocolFeeUpgradeable,
    ERC721PermitUpgradeable,
    FundForwarderUpgradeable,
    ERC721EnumerableUpgradeable
{
    using SSTORE2 for *;
    using Bytes32Address for *;
    using StringLib for uint256;
    using BitMapsUpgradeable for BitMapsUpgradeable.BitMap;

    ///@dev value is equal to keccak256("Swap(address user,uint256 toId,uint256 deadline,uint256 nonce,uint256[] fromIds)")
    bytes32 private constant __MERGE_TYPE_HASH =
        0x085ba72701c4339ed5b893f5421cabf9405901f059ff0c12083eb0b1df6bc19a;

    bytes32 public version;
    bytes32 private _baseTokenURIPtr;
    mapping(uint256 => uint256) public typeIdTrackers;

    function changeVault(
        address vault_
    ) external override onlyRole(Roles.TREASURER_ROLE) {
        _changeVault(vault_);
    }

    function setBaseURI(
        string calldata baseURI_
    ) external onlyRole(Roles.OPERATOR_ROLE) {
        _setBaseURI(baseURI_);
    }

    function merge(
        uint256[] calldata fromIds_,
        uint256 toId_,
        uint256 deadline_,
        bytes calldata signature_
    ) external {
        if (block.timestamp > deadline_) revert BK721__Expired();

        address user = _msgSender();
        if (
            !_hasRole(
                Roles.SIGNER_ROLE,
                _recoverSigner(
                    keccak256(
                        abi.encode(
                            __MERGE_TYPE_HASH,
                            user,
                            toId_,
                            deadline_,
                            _useNonce(user.fillLast12Bytes()), // @dev resitance to reentrancy
                            keccak256(abi.encodePacked(fromIds_))
                        )
                    ),
                    signature_
                )
            )
        ) revert BK721__InvalidSignature();

        uint256 length = fromIds_.length;
        uint256 fromId;
        for (uint256 i; i < length; ) {
            fromId = fromIds_[i];
            if (ownerOf(fromIds_[i]) != user) revert BK721__Unauthorized();
            _burn(fromId);
            unchecked {
                ++i;
            }
        }

        if (_ownerOf[toId_].fromFirst20Bytes() != address(0))
            revert BK721__AlreadyMinted();

        __mintTransfer(user, toId_);

        emit Merged(fromIds_, toId_);
    }

    function setFee(
        IERC20Upgradeable feeToken_,
        uint256 feeAmt_
    ) external onlyRole(Roles.OPERATOR_ROLE) {
        if (!IBKTreasury(vault).supportedPayment(address(feeToken_)))
            revert BK721__TokenNotSupported();
        _setRoyalty(feeToken_, uint96(feeAmt_));
        emit FeeUpdated(feeToken_, feeAmt_);
    }

    function safeMint(
        address to_,
        uint256 typeId_
    ) external onlyRole(Roles.PROXY_ROLE) returns (uint256 tokenId) {
        unchecked {
            _safeMint(
                to_,
                tokenId = (typeId_ << 32) | typeIdTrackers[typeId_]++
            );
        }
    }

    function mint(
        address to_,
        uint256 typeId_
    ) external onlyRole(Roles.MINTER_ROLE) returns (uint256 tokenId) {
        unchecked {
            _mint(to_, tokenId = (typeId_ << 32) | typeIdTrackers[typeId_]++);
        }
    }

    function mintBatch(
        address to_,
        uint256 typeId_,
        uint256 length_
    ) external onlyRole(Roles.MINTER_ROLE) returns (uint256[] memory tokenIds) {
        tokenIds = new uint256[](length_);
        uint256 cursor = nextIdFromType(typeId_);
        for (uint256 i; i < length_; ) {
            unchecked {
                _mint(to_, tokenIds[i] = cursor);
                ++cursor;
                ++i;
            }
        }
        typeIdTrackers[typeId_] = cursor;
        emit BatchMinted(to_, length_);
    }

    function safeMintBatch(
        address to_,
        uint256 typeId_,
        uint256 length_
    ) external onlyRole(Roles.PROXY_ROLE) returns (uint256[] memory tokenIds) {
        tokenIds = new uint256[](length_);
        uint256 cursor = nextIdFromType(typeId_);
        for (uint256 i; i < length_; ) {
            unchecked {
                _safeMint(to_, tokenIds[i] = cursor);
                ++cursor;
                ++i;
            }
        }
        typeIdTrackers[typeId_] = cursor;
        emit BatchMinted(to_, length_);
    }

    function baseURI() external view returns (string memory) {
        return string(_baseTokenURIPtr.read());
    }

    function metadataOf(
        uint256 tokenId_
    ) external view returns (uint256 typeId, uint256 index) {
        if (_ownerOf[tokenId_] == 0) revert BK721__NotMinted();
        typeId = tokenId_ >> 32;
        index = tokenId_ & ~uint32(0);
    }

    function nextIdFromType(uint256 typeId_) public view returns (uint256) {
        return (typeId_ << 32) | (typeIdTrackers[typeId_] + 1);
    }

    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        return
            string(
                abi.encodePacked(
                    _baseTokenURIPtr.read(),
                    address(this),
                    "/",
                    tokenId.toString()
                )
            );
    }

    function supportsInterface(
        bytes4 interfaceId_
    )
        public
        view
        virtual
        override(
            ERC721Upgradeable,
            IERC165Upgradeable,
            ERC721EnumerableUpgradeable
        )
        returns (bool)
    {
        return
            type(IERC165Upgradeable).interfaceId == interfaceId_ ||
            super.supportsInterface(interfaceId_);
    }

    function _setBaseURI(string calldata baseURI_) internal {
        _baseTokenURIPtr = bytes(baseURI_).write();
    }

    function __BK_init(
        string calldata name_,
        string calldata symbol_,
        string calldata baseURI_,
        uint256 feeAmt_,
        IERC20Upgradeable feeToken_,
        IAuthority authority_,
        bytes32 version_
    ) internal onlyInitializing {
        __ERC721Permit_init(name_, symbol_);
        __Manager_init_unchained(authority_, 0);
        __ERC721_init_unchained(name_, symbol_);
        __FundForwarder_init_unchained(
            IFundForwarderUpgradeable(address(authority_)).vault()
        );
        __BK_init_unchained(baseURI_, feeAmt_, feeToken_, version_);
    }

    function __BK_init_unchained(
        string calldata baseURI_,
        uint256 feeAmt_,
        IERC20Upgradeable feeToken_,
        bytes32 version_
    ) internal onlyInitializing {
        version = version_;
        _setBaseURI(baseURI_);
        _setRoyalty(feeToken_, uint96(feeAmt_));
    }

    function _beforeTokenTransfer(
        address from_,
        address to_,
        uint256 tokenId_
    )
        internal
        virtual
        override(ERC721EnumerableUpgradeable, ERC721Upgradeable)
    {
        _requireNotPaused();
        super._beforeTokenTransfer(from_, to_, tokenId_);

        address sender = _msgSender();
        _checkBlacklist(sender);
        _checkBlacklist(from_);
        _checkBlacklist(to_);

        if (
            from_ != address(0) &&
            to_ != address(0) &&
            !_hasRole(Roles.OPERATOR_ROLE, sender)
        ) {
            (IERC20Upgradeable feeToken, uint256 feeAmt) = feeInfo();
            if (feeAmt == 0) return;
            _safeTransferFrom(feeToken, sender, vault, feeAmt);
        }
    }

    function __mintTransfer(address to_, uint256 tokenId_) private {
        _mint(address(this), tokenId_);
        _transfer(address(this), to_, tokenId_);
    }

    function __safeMintTransfer(address to_, uint256 tokenId_) private {
        address sender = _msgSender();
        _safeMint(sender, tokenId_);
        _transfer(sender, to_, tokenId_);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return string(_baseTokenURIPtr.read());
    }

    uint256[47] private __gap;
}

interface IBKNFT {
    function initialize(
        string calldata name_,
        string calldata symbol_,
        string calldata baseURI_,
        uint256 feeAmt_,
        IERC20Upgradeable feeToken_,
        IAuthority authority_
    ) external;
}

contract BKNFT is IBKNFT, BK721 {
    function initialize(
        string calldata name_,
        string calldata symbol_,
        string calldata baseURI_,
        uint256 feeAmt_,
        IERC20Upgradeable feeToken_,
        IAuthority authority_
    ) external initializer {
        __BK_init(
            name_,
            symbol_,
            baseURI_,
            feeAmt_,
            feeToken_,
            authority_,
            /// @dev value is equal to keccak256("BKNFT_v1")
            0x379792d4af837d435deaf8f2b7ca3c489899f24f02d5309487fe8be0aa778cca
        );
    }

    uint256[50] private __gap;
}

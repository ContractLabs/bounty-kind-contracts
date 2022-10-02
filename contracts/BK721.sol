// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "oz-custom/contracts/oz-upgradeable/token/ERC721/extensions/ERC721PermitUpgradeable.sol";
import "oz-custom/contracts/oz-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";

import "./internal-upgradeable/BaseUpgradeable.sol";
import "./internal-upgradeable/AssetRoyaltyUpgradeable.sol";
import "./internal-upgradeable/FundForwarderUpgradeable.sol";

import "./interfaces/IBK721.sol";
import "./interfaces/IIngameSwap.sol";

import "oz-custom/contracts/libraries/SSTORE2.sol";
import "oz-custom/contracts/libraries/StringLib.sol";
import "oz-custom/contracts/oz-upgradeable/utils/structs/BitMapsUpgradeable.sol";

abstract contract BK721Upgradeable is
    IBK721,
    BaseUpgradeable,
    AssetRoyaltyUpgradeable,
    ERC721PermitUpgradeable,
    FundForwarderUpgradeable,
    ERC721EnumerableUpgradeable
{
    using SSTORE2 for bytes;
    using SSTORE2 for bytes32;
    using StringLib for uint256;
    using Bytes32Address for bytes32;
    using Bytes32Address for address;
    using BitMapsUpgradeable for BitMapsUpgradeable.BitMap;

    ///@dev value is equal to keccak256("Swap(address user,uint256[] fromIds,uint256 toId,uint256 deadline,uint256 nonce)")
    bytes32 private constant _SWAP_TYPE_HASH =
        0x3763ec6725b0aae11be7380c0fa9b2ac1c7658553079ea4adfb386f6d1245e13;
    ///@dev value is equal to keccak256("Withdraw(uint256 tokenId,uint256 pointFee,uint256 deadline,uint256 nonce)")
    bytes32 private constant _WITHDRAW_TYPE_HASH =
        0x29ed224349fce3aa6691d0ebaa0401e6397c11160fc1571d8de406ee323cb0de;

    bytes32 public version;

    bytes32 private _pointPool;
    bytes32 private _baseTokenURIPtr;
    BitMapsUpgradeable.BitMap private _lockedTokens;
    mapping(uint256 => uint256) public typeIdTrackers;

    event Locked();
    event Released();
    event Swapped();

    modifier notLocked(uint256 tokenId_) {
        __checkLock(tokenId_);
        _;
    }

    function swap(
        uint256[] calldata fromIds_,
        uint256 toId_,
        uint256 deadline_,
        bytes calldata signature_
    ) external {
        if (block.timestamp > deadline_) revert();
        if (_ownerOf[toId_].fromFirst20Bytes() != address(0)) revert();
        address user = _msgSender();

        __checkSignature(
            keccak256(
                abi.encode(
                    _SWAP_TYPE_HASH,
                    user,
                    fromIds_,
                    toId_,
                    deadline_,
                    _useNonce(user)
                )
            ),
            signature_
        );

        uint256 length = fromIds_.length;
        for (uint256 i; i < length; ) {
            if (ownerOf(fromIds_[i]) != user) revert();
            _burn(fromIds_[i]);
            unchecked {
                ++i;
            }
        }

        __mintTransfer(user, toId_);

        emit Swapped();
    }

    function lock(uint256 tokenId_) external notLocked(tokenId_) {
        if (ownerOf(tokenId_) != _msgSender()) revert();
        _lockedTokens.set(tokenId_);

        emit Locked();
    }

    function withdraw(
        uint256 tokenId_,
        uint256 pointFee_,
        uint256 deadline_,
        bytes calldata signature_
    ) external whenNotPaused {
        address user = _msgSender();
        if (user != ownerOf(tokenId_)) revert();
        if (block.timestamp > deadline_) revert();
        if (!isLocked(tokenId_)) revert();

        __checkSignature(
            keccak256(
                abi.encode(
                    _WITHDRAW_TYPE_HASH,
                    tokenId_,
                    pointFee_,
                    deadline_,
                    _useNonce(tokenId_)
                )
            ),
            signature_
        );
        __decreasePoint(user, pointFee_);
        _lockedTokens.unset(tokenId_);

        emit Released();
    }

    function updateTreasury(ITreasuryV2 treasury_)
        external
        override
        whenPaused
        onlyRole(Roles.OPERATOR_ROLE)
    {
        emit TreasuryUpdated(treasury(), treasury_);
        _updateTreasury(treasury_);
    }

    function setFee(IERC20Upgradeable feeToken_, uint256 feeAmt_)
        external
        override
        whenPaused
        onlyRole(Roles.OPERATOR_ROLE)
    {
        if (!treasury().supportedPayment(feeToken_))
            revert BK721__TokenNotSupported();
        _setfee(feeToken_, feeAmt_);
        emit FeeChanged();
    }

    function safeMint(address to_, uint256 typeId_)
        external
        onlyRole(Roles.PROXY_ROLE)
    {
        unchecked {
            __safeMintTransfer(
                to_,
                (typeId_ << 128) | typeIdTrackers[typeId_]++
            );
        }
    }

    function mint(address to_, uint256 typeId_)
        external
        override
        onlyRole(Roles.MINTER_ROLE)
    {
        unchecked {
            __mintTransfer(to_, (typeId_ << 128) | typeIdTrackers[typeId_]++);
        }
    }

    function mintBatch(
        address to_,
        uint256 typeId_,
        uint256 length_
    ) external override onlyRole(Roles.MINTER_ROLE) {
        uint256 ptr = nextIdFromType(typeId_);
        for (uint256 i; i < length_; ) {
            unchecked {
                __mintTransfer(to_, ptr);
                ++ptr;
                ++i;
            }
        }
        typeIdTrackers[typeId_] = ptr;
        emit BatchMinted(to_, length_);
    }

    function safeMintBatch(
        address to_,
        uint256 typeId_,
        uint256 length_
    ) external override onlyRole(Roles.PROXY_ROLE) {
        uint256 ptr = nextIdFromType(typeId_);
        for (uint256 i; i < length_; ) {
            unchecked {
                __safeMintTransfer(to_, ptr);
                ++ptr;
                ++i;
            }
        }
        typeIdTrackers[typeId_] = ptr;
        emit BatchMinted(to_, length_);
    }

    function pointPool() external view returns (IIngameSwap) {
        return IIngameSwap(_pointPool.fromFirst20Bytes());
    }

    function isLocked(uint256 tokenId) public view returns (bool) {
        return _lockedTokens.get(tokenId);
    }

    function metadataOf(uint256 tokenId_)
        external
        view
        override
        returns (uint256 typeId, uint256 index)
    {
        ownerOf(tokenId_);
        typeId = tokenId_ >> 128;
        index = tokenId_ & ~uint128(0);
    }

    function nextIdFromType(uint256 typeId_) public view returns (uint256) {
        return (typeId_ << 128) | typeIdTrackers[typeId_];
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        return string(abi.encodePacked(_baseTokenURIPtr.read(), tokenId));
    }

    function supportsInterface(bytes4 interfaceId_)
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

    function __BK_init(
        string calldata name_,
        string calldata symbol_,
        string calldata baseURI_,
        uint256 feeAmt_,
        IERC20Upgradeable feeToken_,
        IGovernanceV2 governance_,
        ITreasuryV2 treasury_,
        bytes32 version_
    ) internal onlyInitializing {
        __BK_init_unchained(
            name_,
            symbol_,
            baseURI_,
            feeAmt_,
            feeToken_,
            governance_,
            treasury_,
            version_
        );
    }

    function __BK_init_unchained(
        string calldata name_,
        string calldata symbol_,
        string calldata baseURI_,
        uint256 feeAmt_,
        IERC20Upgradeable feeToken_,
        IGovernanceV2 governance_,
        ITreasuryV2 treasury_,
        bytes32 version_
    ) internal onlyInitializing {
        __Base_init(governance_, 0);
        __FundForwarder_init(treasury_);
        __ERC721_init(name_, symbol_);
        __EIP712_init(type(BK721Upgradeable).name, "2");

        version = version_;
        _setfee(feeToken_, feeAmt_);

        _baseTokenURIPtr = bytes(baseURI_).write();
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
        __checkLock(tokenId_);
        super._beforeTokenTransfer(from_, to_, tokenId_);

        address sender = _msgSender();
        _checkBlacklist(sender);
        _checkBlacklist(from_);
        _checkBlacklist(to_);

        if (
            from_ != address(0) &&
            to_ != address(0) &&
            !governance().hasRole(Roles.MINTER_ROLE, sender)
        ) {
            (IERC20Upgradeable feeToken, uint256 feeAmt) = feeInfo();
            _safeTransferFrom(feeToken, sender, address(treasury()), feeAmt);
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

    function __decreasePoint(address user_, uint256 amount_) private {
        (bool ok, ) = _pointPool.fromFirst20Bytes().call(
            abi.encodeWithSelector(
                IIngameSwap.decrease.selector,
                user_,
                amount_
            )
        );
        if (!ok) revert();
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return string(_baseTokenURIPtr.read());
    }

    function __checkSignature(bytes32 structHash_, bytes calldata signature_)
        private
        view
    {
        if (
            !_hasRole(
                Roles.SIGNER_ROLE,
                _recoverSigner(_hashTypedDataV4(structHash_), signature_)
            )
        ) revert();
    }

    function __checkLock(uint256 tokenId_) private view {
        if (isLocked(tokenId_)) revert();
    }

    uint256[45] private __gap;
}

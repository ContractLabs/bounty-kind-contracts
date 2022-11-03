// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "oz-custom/contracts/oz-upgradeable/utils/structs/BitMapsUpgradeable.sol";

import "oz-custom/contracts/internal-upgradeable/SignableUpgradeable.sol";
import "oz-custom/contracts/internal-upgradeable/ProxyCheckerUpgradeable.sol";

import "./internal-upgradeable/BaseUpgradeable.sol";
import "./internal-upgradeable/FundForwarderUpgradeable.sol";

import "./interfaces/IMarketplace.sol";

import "oz-custom/contracts/libraries/FixedPointMathLib.sol";

contract Marketplace is
    IMarketplace,
    BaseUpgradeable,
    SignableUpgradeable,
    ProxyCheckerUpgradeable,
    FundForwarderUpgradeable
{
    using Bytes32Address for *;
    using FixedPointMathLib for uint256;
    using BitMapsUpgradeable for BitMapsUpgradeable.BitMap;

    uint256 public constant PERCENTAGE_FRACTION = 10_000;

    /// @dev value is equal to keccak256("Permit(address buyer,address nft,address payment,uint256 price,uint256 tokenId,uint256 nonce,uint256 deadline)")
    bytes32 private constant __PERMIT_TYPE_HASH =
        0xc396b6309f782cacc3389f4dd579db291ad1b771b8b4966f3695dab14150633e;

    uint256 public protocolFee;
    BitMapsUpgradeable.BitMap private __whitelistedContracts;

    function init(
        uint256 feeFraction_,
        address[] calldata supportedContracts_,
        IAuthority authority_,
        ITreasury treasury_
    ) external initializer {
        __setProtocolFee(feeFraction_);
        __whiteListContracts(supportedContracts_);

        __FundForwarder_init_unchained(treasury_);
        __Signable_init(type(Marketplace).name, "1");
        __Base_init_unchained(authority_, Roles.TREASURER_ROLE);
    }

    function setProtocolFee(
        uint256 feeFraction_
    ) external onlyRole(Roles.OPERATOR_ROLE) {
        __setProtocolFee(feeFraction_);
        emit ProtocolFeeUpdated(feeFraction_);
    }

    function updateTreasury(ITreasury treasury_) external override {
        emit TreasuryUpdated(treasury(), treasury_);
        _updateTreasury(treasury_);
    }

    function redeem(
        uint256 deadline_,
        Buyer calldata buyer_,
        Seller calldata seller_,
        bytes calldata signature_
    ) external payable whenNotPaused {
        address buyer = _msgSender();
        __checkUser(buyer);
        __checkSignature(buyer, seller_, deadline_, signature_);

        address seller = seller_.nft.ownerOf(seller_.tokenId);
        __processPayment(buyer, seller, buyer_, seller_);
        __transferItem(buyer, seller, seller_);

        emit Redeemed(
            buyer,
            seller,
            seller_.tokenId,
            seller_.nft,
            seller_.payment,
            seller_.unitPrice
        );
    }

    function __setProtocolFee(uint256 feeFraction_) private {
        protocolFee = feeFraction_;
    }

    function __transferItem(
        address buyerAddr_,
        address sellerAddr_,
        Seller calldata seller_
    ) private {
        if (!__whitelistedContracts.get(address(seller_.nft).fillLast96Bits()))
            revert Marketplace__UnsupportedNFT();
        if (seller_.nft.getApproved(seller_.tokenId) != address(this))
            seller_.nft.permit(
                seller_.tokenId,
                seller_.deadline,
                address(this),
                seller_.v,
                seller_.r,
                seller_.s
            );

        seller_.nft.safeTransferFrom(
            sellerAddr_,
            buyerAddr_,
            seller_.tokenId,
            ""
        );
    }

    function __processPayment(
        address buyerAddr_,
        address sellerAddr_,
        Buyer calldata buyer_,
        Seller calldata seller_
    ) private {
        uint256 _protocolFee = protocolFee;
        uint256 percentageFraction = PERCENTAGE_FRACTION;
        uint256 receiveFraction = percentageFraction - _protocolFee;
        if (treasury().supportedPayment(address(seller_.payment)))
            revert Marketplace__UnsupportedPayment();
        if (address(seller_.payment) != address(0)) {
            if (
                seller_.payment.allowance(buyerAddr_, address(this)) <
                seller_.unitPrice
            )
                IERC20PermitUpgradeable(address(seller_.payment)).permit(
                    buyerAddr_,
                    address(this),
                    seller_.unitPrice,
                    buyer_.deadline,
                    buyer_.v,
                    buyer_.r,
                    buyer_.s
                );

            _safeERC20TransferFrom(
                seller_.payment,
                buyerAddr_,
                sellerAddr_,
                seller_.unitPrice.mulDivDown(
                    receiveFraction,
                    percentageFraction
                )
            );
            if (_protocolFee != 0)
                _safeERC20TransferFrom(
                    seller_.payment,
                    buyerAddr_,
                    address(treasury()),
                    seller_.unitPrice.mulDivDown(
                        _protocolFee,
                        percentageFraction
                    )
                );

            if (msg.value == 0) return;
            _safeNativeTransfer(buyerAddr_, msg.value);
        } else {
            _safeNativeTransfer(
                sellerAddr_,
                seller_.unitPrice.mulDivDown(
                    receiveFraction,
                    percentageFraction
                )
            );
            if (_protocolFee != 0)
                _safeNativeTransfer(
                    address(treasury()),
                    seller_.unitPrice.mulDivDown(
                        _protocolFee,
                        percentageFraction
                    )
                );
            if (msg.value == seller_.unitPrice) return;
            _safeNativeTransfer(buyerAddr_, msg.value - seller_.unitPrice);
        }
    }

    function __whiteListContracts(
        address[] calldata supportedContracts_
    ) private {
        uint256 length = supportedContracts_.length;
        uint256[] memory uintContracts = new uint256[](length);
        address[] memory supportedContracts = supportedContracts_;
        assembly {
            uintContracts := supportedContracts
        }

        for (uint256 i; i < length; ) {
            __whitelistedContracts.set(uintContracts[i]);
            unchecked {
                ++i;
            }
        }
    }

    function __checkSignature(
        address buyer,
        Seller calldata seller_,
        uint256 deadline_,
        bytes calldata signature_
    ) private {
        if (block.timestamp > deadline_) revert Marketplace__Expired();
        if (
            !_hasRole(
                Roles.SIGNER_ROLE,
                _recoverSigner(
                    keccak256(
                        abi.encode(
                            __PERMIT_TYPE_HASH,
                            buyer,
                            seller_.nft,
                            seller_.payment,
                            seller_.unitPrice,
                            seller_.tokenId,
                            _useNonce(buyer),
                            deadline_
                        )
                    ),
                    signature_
                )
            )
        ) revert Marketplace__InvalidSignature();
    }

    function __checkUser(address account_) private view {
        _checkBlacklist(account_);
        _onlyEOA(account_);
    }

    uint256[48] private __gap;
}

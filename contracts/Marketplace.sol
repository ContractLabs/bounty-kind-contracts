// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "oz-custom/contracts/oz-upgradeable/utils/structs/BitMapsUpgradeable.sol";

import "oz-custom/contracts/internal-upgradeable/SignableUpgradeable.sol";
import "oz-custom/contracts/internal-upgradeable/ProxyCheckerUpgradeable.sol";

import "oz-custom/contracts/presets-upgradeable/base/ManagerUpgradeable.sol";

import "./internal-upgradeable/BKFundForwarderUpgradeable.sol";

import "./interfaces/IBKTreasury.sol";
import "./interfaces/IMarketplace.sol";
import "oz-custom/contracts/internal-upgradeable/interfaces/IWithdrawableUpgradeable.sol";

import "oz-custom/contracts/libraries/FixedPointMathLib.sol";

contract Marketplace is
    IMarketplace,
    ManagerUpgradeable,
    SignableUpgradeable,
    ProxyCheckerUpgradeable,
    BKFundForwarderUpgradeable
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

    function initialize(
        uint256 feeFraction_,
        address[] calldata supportedContracts_,
        IAuthority authority_
    ) external initializer {
        __setProtocolFee(feeFraction_);
        __whiteListContracts(supportedContracts_);

        __Signable_init_unchained(type(Marketplace).name, "1");
        __Manager_init_unchained(authority_, Roles.TREASURER_ROLE);
        __FundForwarder_init_unchained(
            IFundForwarderUpgradeable(address(authority_)).vault()
        );
    }

    function changeVault(
        address vault_
    ) external override onlyRole(Roles.TREASURER_ROLE) {
        _changeVault(vault_);
    }

    function whiteListContracts(
        address[] calldata addrs_
    ) external onlyRole(Roles.OPERATOR_ROLE) {
        __whiteListContracts(addrs_);
    }

    function setProtocolFee(
        uint256 feeFraction_
    ) external onlyRole(Roles.OPERATOR_ROLE) {
        __setProtocolFee(feeFraction_);
        emit ProtocolFeeUpdated(feeFraction_);
    }

    function redeem(
        uint256 deadline_,
        Buyer calldata buyer_,
        Seller calldata seller_,
        bytes calldata signature_
    ) external payable whenNotPaused {
        address buyer = _msgSender();
        _checkBlacklist(buyer);
        _onlyEOA(buyer);

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

    function nonces(address account_) external view returns (uint256) {
        return _nonces[account_.fillLast12Bytes()];
    }

    function isWhitelisted(address addr_) external view returns (bool) {
        return __whitelistedContracts.get(addr_.fillLast96Bits());
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
                address(this),
                seller_.tokenId,
                seller_.deadline,
                seller_.signature
            );

        seller_.nft.safeTransferFrom(
            sellerAddr_,
            buyerAddr_,
            seller_.tokenId,
            safeTransferHeader()
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

        if (!IBKTreasury(vault()).supportedPayment(address(seller_.payment)))
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
            if (_protocolFee != 0) {
                address _vault = vault();
                uint256 received;
                _safeERC20TransferFrom(
                    seller_.payment,
                    buyerAddr_,
                    _vault,
                    received = seller_.unitPrice.mulDivDown(
                        _protocolFee,
                        percentageFraction
                    )
                );
                if (
                    IWithdrawableUpgradeable(_vault).notifyERC20Transfer(
                        address(seller_.payment),
                        received,
                        safeTransferHeader()
                    ) != IWithdrawableUpgradeable.notifyERC20Transfer.selector
                ) revert Marketplace__ExecutionFailed();
            }

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
                    vault(),
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
        uint256[] memory uintContracts;
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
                            _useNonce(buyer.fillLast12Bytes()),
                            deadline_
                        )
                    ),
                    signature_
                )
            )
        ) revert Marketplace__InvalidSignature();
    }

    uint256[48] private __gap;
}

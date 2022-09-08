// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./internal/BusinessRole.sol";
import "./internal/Transferable.sol";

import "./utils/NoProxy.sol";
import "./utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

import "./interfaces/IFiat.sol";
import "./interfaces/ICompanyPackage.sol";
import "./interfaces/IERC721Mintable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-IERC20Permit.sol";

contract CompanyPackage is
    NoProxy,
    BusinessRole,
    Transferable,
    ICompanyPackage,
    ReentrancyGuard
{
    using Math for uint256;
    using AddressLib for address;
    using AddressLib for bytes32;

    mapping(bytes32 => uint256) private _idCounter;
    mapping(bytes32 => mapping(uint256 => uint256)) private _idToPrice;

    bytes32 private immutable _fiat;

    constructor(address admin_, address fiat_) payable Base(admin_, false) {
        _fiat = fiat_.fillLast12Bytes();
    }

    function fiat() public view returns (IFiat) {
        return IFiat(_fiat.fromFirst20Bytes());
    }

    function priceOf(address nft_, uint256 id_)
        external
        view
        returns (uint256)
    {
        return _idToPrice[nft_.fillLast12Bytes()][id_];
    }

    function setPackage(
        address nft_,
        uint256 id_,
        uint256 price_
    ) external onlyManager {
        bytes32 addressBytes = nft_.fillLast12Bytes();
        unchecked {
            _idToPrice[addressBytes][
                id_ < _idCounter[addressBytes]
                    ? id_
                    : _idCounter[addressBytes]++
            ] = price_;
        }
    }

    function buyNFT(
        address nft_,
        uint256 id_,
        uint256 amount_,
        uint256 deadline_,
        address paymentToken_,
        bytes calldata signature_
    ) external payable nonReentrant {
        address sender = _msgSender();
        _onlyEOA(sender);
        if (
            !(paymentToken_ == address(0) ||
                admin().acceptedPayment(paymentToken_))
        ) revert CompanyPackage__UnsupportedPayment(paymentToken_);

        uint256 total;
        if (
            (total = fiat().priceOf(paymentToken_).mulDiv(
                _idToPrice[nft_.fillLast12Bytes()][id_] * amount_,
                1 ether
            )) == 0
        ) revert CompanyPackage__InvalidTokenId(id_);

        if (signature_.length == 65) {
            if (block.timestamp > deadline_)
                revert CompanyPackage__SignatureExpired();
                
            bytes32 r;
            bytes32 s;
            uint8 v;

            assembly {
                let offset := signature_.offset
                r := calldataload(add(offset, 0x20))
                s := calldataload(add(offset, 0x40))
                v := byte(0, calldataload(add(offset, 0x60)))
            }

            IERC20Permit(paymentToken_).permit(
                sender,
                address(this),
                total,
                deadline_,
                v,
                r,
                s
            );
        }

        _safeTransferFrom(paymentToken_, sender, admin().treasury(), total);

        uint256[] memory tokenIds = new uint256[](amount_);
        for (uint256 i; i < amount_; ) {
            tokenIds[i] = IERC721Mintable(nft_).mint(sender);
            unchecked {
                ++i;
            }
        }

        emit Registered(sender, nft_, tokenIds, total);
    }
}

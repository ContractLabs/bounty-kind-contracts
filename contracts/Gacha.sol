// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

// import "oz-custom/contracts/internal-upgradeable/SignableUpgradeable.sol";

// import "./internal-upgradeable/BaseUpgradeable.sol";
// import "./internal-upgradeable/TransferableUpgradeable.sol";
// import "./internal-upgradeable/ProxyCheckerUpgradeable.sol";
// import "./internal-upgradeable/FundForwarderUpgradeable.sol";

// import "./interfaces/IGacha.sol";
// import "./interfaces/IERC721Permit.sol";
// import "./interfaces/IERC721Mintable.sol";
// import "./interfaces/IERC721Burnable.sol";
// import "./interfaces/IPaymentProvider.sol";
// import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
// import "@openzeppelin/contracts/token/ERC20/extensions/draft-IERC20Permit.sol";

// import "oz-custom/contracts/libraries/Bytes32Address.sol";

// contract Gacha is
//     IGacha,
//     SignableUpgradeable,
//     ProxyCheckerUpgradeable,
//     TransferableUpgradeable
// {
//     using Bytes32Address for address;
//     using Bytes32Address for uint256;

//     mapping(bytes32 => uint256) private _tickets;

//     modifier onlyValidBuyTicket(uint256 id_) {
//         if (!isValidBuyTicket(id_)) revert Gacha__PurchasedTicket();
//         _;
//     }

//     function buyTicketByToken(
//         uint256 id_,
//         address erc20,
//         uint256 typeTicket_,
//         uint256 deadline_,
//         bytes calldata signature_
//     ) external onlyValidBuyTicket(id_) {
//         if (!paymentProvider.supportedToken(erc20))
//             revert Gacha__InvalidPayment();

//         address sender = _msgSender();
//         _onlyEOA(sender);
//         uint256 total = paymentProvider.priceOf(erc20)[typeTicket_];

//         if (signature_.length == 65) {
//             if (block.timestamp > deadline_) revert Gacha__Expired();
//             (bytes32 r, bytes32 s, uint8 v) = _splitSignature(signature_);
//             IERC20Permit(erc20).permit(
//                 sender,
//                 address(this),
//                 total,
//                 deadline_,
//                 v,
//                 r,
//                 s
//             );
//         }

//         _safeTransferFrom(erc20, sender, address(this), total);

//         unchecked {
//             _tickets[id_] = sender.fillLast96Bits() << 1;
//         }

//         emit BuyTicket(sender, id_, erc20, total);
//     }

//     function buyTicketByNFT(
//         uint256 _ticket,
//         address erc721,
//         uint256 tokenId,
//         uint256 deadline_,
//         bytes calldata signature_
//     ) external onlyValidBuyTicket(_ticket) {
//         if (!paymentProvider.supportedNFT(erc721))
//             revert Gacha__InvalidPayment();

//         address sender = _msgSender();
//         _onlyEOA(sender);

//         if (signature_.length == 65) {
//             if (block.timestamp > deadline_) revert Gacha__Expired();
//             (bytes32 r, bytes32 s, uint8 v) = _splitSignature(signature_);
//             IERC721Permit(erc721).permit(
//                 address(this),
//                 tokenId,
//                 deadline_,
//                 v,
//                 r,
//                 s
//             );
//         }

//         IERC721Burnable(erc721).burn(tokenId);

//         unchecked {
//             _tickets[_ticket] = sender.fillLast96Bits() << 1;
//         }

//         emit BuyTicketNFT(sender, _ticket, erc721, tokenId);
//     }

//     function rewardMainCoin(
//         uint256 id_,
//         address user_,
//         uint256 amount_
//     ) external payable onlyManager {
//         (address user, bool isUsed) = __ticket(id_);
//         if (user == address(0) || isUsed) revert Gacha__InvalidTicket();

//         _safeNativeTransfer(user_, amount_);
//         unchecked {
//             _tickets[id_] = (user.fillLast96Bits() << 1) | 1;
//         }

//         emit RewardMainCoin(id_, user_, amount_);
//     }

//     function rewardERC20(
//         uint256 id_,
//         address user_,
//         address erc20_,
//         uint256 amount_
//     ) external onlyManager {
//         (address user, bool isUsed) = __ticket(id_);
//         if (user == address(0) || isUsed) revert Gacha__InvalidTicket();
//         _safeTransferFrom(erc20_, _msgSender(), user_, amount_);
//         unchecked {
//             _tickets[id_] = (user.fillLast96Bits() << 1) | 1;
//         }
//         emit RewardERC20(id_, user_, erc20_, amount_);
//     }

//     function rewardERC721(
//         uint256 id_,
//         address user_,
//         address erc721_
//     ) public onlyManager {
//         (address user, bool isUsed) = __ticket(id_);
//         if (user == address(0) || isUsed) revert Gacha__InvalidTicket();
//         uint256 tokenId = IERC721Mintable(erc721_).mint(user_);
//         unchecked {
//             _tickets[id_] = (user.fillLast96Bits() << 1) | 1;
//         }
//         emit RewardERC721(id_, user_, erc721_, tokenId);
//     }

//     function isValidTicket(uint256 id_) public view returns (bool) {
//         (address user, bool isUsed) = __ticket(id_);
//         return user != address(0) && !isUsed;
//     }

//     function isValidBuyTicket(uint256 id_) public view returns (bool) {
//         return (_tickets[id_] >> 1).fromFirst160Bits() == address(0);
//     }

//     function ticket(uint256 id_) external view returns (address, bool) {
//         return __ticket(id_);
//     }

//     function __ticket(uint256 id_)
//         private
//         view
//         returns (address user, bool isUsed)
//     {
//         uint256 ticket_ = _tickets[id_];
//         unchecked {
//             user = (ticket_ >> 1).fromFirst160Bits();
//         }
//         isUsed = ticket_ & 1 != 0;
//     }
// }

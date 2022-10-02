// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

// interface IMarketplace {
//     error Marketplace__OutOfBounds();
//     error Marketplace__Unauthorized();
//     error Marketplace__LengthMismatch();
//     error Marketplace__UnsupportedPayment();
//     struct Price {
//         uint256[] tokenIds; // package tokenId
//         address maker; // address post
//         uint256 price; // price of the package (unit is USD/JPY/VND/...) * 1 ether
//         address[] fiat; // payable fiat
//         address buyByFiat;
//         bool isBuy; // order status
//     }
//     struct GameFee {
//         string fee; // bao nhieu phan `Percen` cua weiPrice
//         address taker; //
//         uint256 percent;
//         bool existed;
//     }

//     struct Game {
//         uint256 fee;
//         uint256 limitFee;
//         uint256 creatorFee;
//         mapping(uint256 => Price) tokenPrice;
//         GameFee[] arrFees;
//         mapping(string => GameFee) fees;
//     }

//     event _setPrice(
//         address _game,
//         uint256[] _tokenIds,
//         uint256 _price,
//         uint8 _type
//     );
//     event _resetPrice(address _game, uint256 _orderId);
// }

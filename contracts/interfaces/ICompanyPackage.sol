// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

interface ICompanyPackage {
    error CompanyPackage__SignatureExpired();
    error CompanyPackage__InvalidTokenId(uint256);
    error CompanyPackage__UnsupportedPayment(address);
    event Registered(
        address indexed user,
        address indexed erc721,
        uint256[] tokenIds,
        uint256 price
    );
}

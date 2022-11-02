const hre = require("hardhat");
const { writeNetworkEnv, readNetworkEnv } = require("../network/env");
const { addressPage, isTomoChain } = require("../utils");

readNetworkEnv(hre.network);

function writeEnv(address) {
  writeNetworkEnv("NFT_CHARACTER", address, hre.network);
  readNetworkEnv(hre.network);
}

async function argsInit() {
  const tokenAddress = process.env.YU || hre.ethers.constants.AddressZero;
  const taker = await hre.ethers.getSigner();
  return [
    "Bountykind Character", // name
    "NFTCharacter", // symbol
    tokenAddress, // token
    taker.address, // taker address
    taker.address, // creator
    taker.address, // signer
  ];
}

// npx hardhat run ./scripts/deployNFTCharacter.js
async function main() {
  const nft = await (
    await hre.ethers.getContractFactory("contracts/MyNFT4907.sol:MyNFT")
  ).deploy(...(await argsInit()));

  writeEnv(nft.address);
  console.log(`Address: ${addressPage(hre.network, nft.address)}`);
}

main().catch(error => {
  console.error(error);
  process.exit(1);
});

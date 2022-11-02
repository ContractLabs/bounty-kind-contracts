const hre = require("hardhat");
const { writeNetworkEnv, readNetworkEnv } = require("../network/env");
const { addressPage, isTomoChain } = require("../utils");

readNetworkEnv(hre.network);

function writeEnv(address) {
  writeNetworkEnv("GACHA", address, hre.network);
  readNetworkEnv(hre.network);
}

async function argsInit() {
  return [];
}

// npx hardhat run ./scripts/deployGacha.js
async function main() {
  const draw = await (await hre.ethers.getContractFactory("contracts/Gacha.sol:Gacha")).deploy(...(await argsInit()));

  writeEnv(nft.address);
  console.log(`Address: ${addressPage(hre.network, draw.address)}`);
}

main().catch(error => {
  console.error(error);
  process.exit(1);
});

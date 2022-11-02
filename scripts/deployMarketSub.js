const hre = require("hardhat");
const { writeNetworkEnv, readNetworkEnv } = require("../network/env");
const { addressPage, isTomoChain } = require("../utils");

readNetworkEnv(hre.network);

function writeEnv(address) {
  writeNetworkEnv("MARKET_SUB", address, hre.network);
  readNetworkEnv(hre.network);
}

async function argsInit() {
  const marketAddress = process.env.MARKET || hre.ethers.constants.AddressZero;
  return [marketAddress];
}

// npx hardhat run ./scripts/deployMarketSub.js
async function main() {
  const marketSub = await (
    await hre.ethers.getContractFactory("contracts/MarketSub.sol:MarketSub")
  ).deploy(...(await argsInit()));

  writeEnv(marketSub.address);
  console.log(`Address: ${addressPage(hre.network, marketSub.address)}`);
}

main().catch(error => {
  console.error(error);
  process.exit(1);
});

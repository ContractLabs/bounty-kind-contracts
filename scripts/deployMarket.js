const hre = require("hardhat");
const { writeNetworkEnv, readNetworkEnv } = require("../network/env");
const { addressPage, isTomoChain } = require("../utils");
const { RPCs } = require("../utils/constants");

readNetworkEnv(hre.network);

function writeEnv(address) {
  writeNetworkEnv("MARKET", address, hre.network);
  readNetworkEnv(hre.network);
}

async function argsInit() {
  const marketSubAddress = process.env.MARKET_SUB || hre.ethers.constants.AddressZero;
  const fiatAddress = process.env.FIAT || hre.ethers.constants.AddressZero;
  const tokenAddress = process.env.YU || hre.ethers.constants.AddressZero;
  const ceo = await hre.ethers.getSigner();
  const chainId = hre.network.config.chainId;

  return [
    marketSubAddress, // market address
    fiatAddress, // fiat contract
    [RPCs[chainId].nativeCurrency.symbol, "YU"], // symbols coin/token
    [hre.ethers.constants.AddressZero, tokenAddress], // set address(0) to use network coin
    ceo.address, // ceo address
  ];
}

// npx hardhat run ./scripts/deployMarket.js
async function main() {
  const market = await (
    await hre.ethers.getContractFactory("contracts/Market.sol:Market")
  ).deploy(...(await argsInit()));

  writeEnv(market.address);
  console.log(`Address: ${addressPage(hre.network, market.address)}`);
}

main().catch(error => {
  console.error(error);
  process.exit(1);
});

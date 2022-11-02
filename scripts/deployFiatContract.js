const hre = require("hardhat");
const { writeNetworkEnv, readNetworkEnv } = require("../network/env");
const { addressPage, isTomoChain } = require("../utils");

readNetworkEnv(hre.network);

function writeEnv(address) {
  writeNetworkEnv("FIAT", address, hre.network);
  readNetworkEnv(hre.network);
}

async function argsInit() {
  return [];
}

// npx hardhat run ./scripts/deployFiatContract.js
async function main() {
  const fiat = await (
    await hre.ethers.getContractFactory("contracts/FiatContract.sol:FiatContract")
  ).deploy(...(await argsInit()));

  writeEnv(fiat.address);
  console.log(`Address: ${addressPage(hre.network, fiat.address)}`);
}

main().catch(error => {
  console.error(error);
  process.exit(1);
});

// Khi set giá bao nhiêu token trên một đơn vị tiền tệ (USD/JPY/VND/...)

// function setupFiat() {
//   fiat.setPrice(
//     ['TVH21'], // symbol
//     [200000], // wei token / price
//     5, // code to approve
//   )
// }

// lưu ý khi set giá trên market. Nếu set giá USD, JPY, lấy giá đó x 1 ether. Để giải quyết vấn đề để giá lẻ như 1.99 USD

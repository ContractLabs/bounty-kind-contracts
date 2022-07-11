const hre = require('hardhat')
const { writeNetworkEnv, readNetworkEnv } = require('../../network/env')
const { addressPage, isTomoChain } = require('../../utils')

readNetworkEnv(hre.network)

function writeEnv(address) {
  writeNetworkEnv('EXCHANGE_POINT', address, hre.network)
  readNetworkEnv(hre.network)
}

async function argsInit() {
  return [
  ]
}

// npx hardhat run ./scripts/utils/deployExchangePoint.js
async function main() {
  const nft = await (await hre.ethers.getContractFactory(
    isTomoChain(hre.network)
      ? 'contracts/0.4.26/ExchangePoint.sol:ExchangePoint'
      : 'contracts/0.8/ExchangePoint.sol:ExchangePoint'
  )).deploy(...(await argsInit()))


  writeEnv(nft.address)
  console.log(`Address: ${addressPage(hre.network, nft.address)}`)
}

main().catch((error) => {
  console.error(error)
  process.exit(1)
})
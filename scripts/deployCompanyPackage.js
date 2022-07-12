const hre = require('hardhat')
const { writeNetworkEnv, readNetworkEnv } = require('../network/env')
const { addressPage, isTomoChain } = require('../utils')

readNetworkEnv(hre.network)

function writeEnv(address) {
  writeNetworkEnv('BOUNTYKIND_PACKAGE', address, hre.network)
  readNetworkEnv(hre.network)
}

async function argsInit() {
  const taker = await hre.ethers.getSigner()
  return [
    taker.address,
  ]
}

// npx hardhat run ./scripts/utils/deployMarketSub.js
async function main() {
  const companyPackage = await (await hre.ethers.getContractFactory(
     'contracts/CompanyPackage.sol:CompanyPackage'
  )).deploy(...(await argsInit()))

  writeEnv(marketSub.address)
  console.log(`Address: ${addressPage(hre.network, companyPackage.address)}`)
}

main().catch((error) => {
  console.error(error)
  process.exit(1)
})
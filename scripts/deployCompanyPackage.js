const hre = require('hardhat')
const { writeNetworkEnv, readNetworkEnv } = require('../network/env')
const { addressPage, isTomoChain } = require('../utils')

readNetworkEnv(hre.network)

function writeEnv(address) {
  writeNetworkEnv('BOUNTYKIND_PACKAGE', address, hre.network)
  readNetworkEnv(hre.network)
}

async function argsInit() {
  const owner = await hre.ethers.getSigner()
  const YU = process.env.YU || hre.ethers.constants.AddressZero
  const FiatContract = process.env.FIAT || hre.ethers.constants.AddressZero
  return [
    owner.address,
    YU,
    owner.address,
    '0',
    FiatContract
  ]
}

// npx hardhat run ./scripts/deployCompanyPackage.js
async function main() {
  const companyPackage = await (await hre.ethers.getContractFactory(
     'contracts/CompanyPackage.sol:CompanyPackage'
  )).deploy(...(await argsInit()))

  writeEnv(companyPackage.address)
  console.log(`Address: ${addressPage(hre.network, companyPackage.address)}`)
}

main().catch((error) => {
  console.error(error)
  process.exit(1)
})
const hre = require('hardhat')
const { writeNetworkEnv, readNetworkEnv } = require('../network/env')
const { addressPage, isTomoChain } = require('../utils')

readNetworkEnv(hre.network)

function writeEnv(address) {
  writeNetworkEnv('NFT_SAPPHIRE', address, hre.network)
  readNetworkEnv(hre.network)
}

async function argsInit() {
  const tokenAddress = process.env.TOKEN || hre.ethers.constants.AddressZero
  const taker = await hre.ethers.getSigner()
  const minFee = hre.ethers.utils.parseUnits('40').toString(10)
  return [
    'Bountykind Sapphire', // name
    'NFTSapphire', // symbol
    tokenAddress, // token
    taker.address, // taker address
    minFee, // min fee
    taker.address // creator
  ]
}

// npx hardhat run ./scripts/utils/deployNFT.js
async function main() {
  const nft = await (await hre.ethers.getContractFactory(
    'contracts/MyNFT.sol:MyNFT'
  )).deploy(...(await argsInit()))


  writeEnv(nft.address)
  console.log(`Address: ${addressPage(hre.network, nft.address)}`)
}

main().catch((error) => {
  console.error(error)
  process.exit(1)
})
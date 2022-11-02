const { types } = require("hardhat/config");
const { constants } = require("ethers/lib/ethers");
const { readNetworkEnv } = require("../../network/env");
const { isTomoChain, transactionPage } = require("../../utils");
const { address } = require("../../utils/types");

const MaxNFTPerTx = 100;

function getNFTAddress() {
  return process.env.NFT;
}

/**
 * Mint NFT to account
 *
 * npx hardhat mint-nft --number 1000 --address
 */
task("mint-nft", "Mint NFT to account")
  .addParam("nft", "Nft contract. Default NFT in env", constants.AddressZero, address)
  .addParam("address", "Address mint to. Default is owner", constants.AddressZero, address)
  .addParam("number", "Mint number NFT to account", undefined, types.int)
  .setAction(async function (taskArgs, hre) {
    readNetworkEnv(hre.network);

    const contractFactoryName = isTomoChain(hre.network)
      ? "contracts/0.4.26/MyNFT.sol:MyNFT"
      : "contracts/0.8/MyNFT.sol:MyNFT";

    const [owner] = await hre.ethers.getSigners();
    var toAddress = taskArgs.address === constants.AddressZero ? owner.address : taskArgs.address;

    const nftAddress = taskArgs.nft === constants.AddressZero ? taskArgs.nft : getNFTAddress();

    if (nftAddress) {
      console.error("[Error] Address nft is empty. You can set NFT in .env file or set params --nft");
      return;
    }

    const nft = await (await hre.ethers.getContractFactory(contractFactoryName)).attach(nftAddress);

    const total = +taskArgs.number;

    for (var number = total; number > 0; ) {
      const numItem = number > MaxNFTPerTx ? MaxNFTPerTx : number;
      const tx = await nft.connect(owner).register(toAddress, numItem, owner.address);
      const receipt = await tx.wait();

      number -= numItem;
      console.log(`[Success] Mint ${total - number}/${total} NFT to ${toAddress}`);
      console.log(`TxID: ${transactionPage(hre.network, receipt)}`);
    }
  });

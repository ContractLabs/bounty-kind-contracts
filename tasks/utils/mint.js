const { types } = require("hardhat/config");
const { constants } = require("ethers/lib/ethers");
const { readNetworkEnv } = require("../../network/env");
const { isTomoChain, transactionPage } = require("../../utils");
const { address } = require("../../utils/types");

function getTokenAddress() {
  return process.env.TOKEN;
}

/**
 * Mint token to account
 *
 * npx hardhat mint --amount 1000000 --address 0x65C2f3acceC21fA5bd5869572273dA7b7296AdEA
 */
task("mint", "Mint token to account")
  .addParam("token", "Token contract. Default TOKEN in env", constants.AddressZero, address)
  .addParam("address", "Address mint to. Default is owner", constants.AddressZero, address)
  .addParam("amount", "Mint amount (uint ether) to account", undefined, types.int)
  .setAction(async function (taskArgs, hre) {
    readNetworkEnv(hre.network);

    const contractFactoryName = isTomoChain(hre.network)
      ? "contracts/0.4.26/MyERC21.sol:MyERC21"
      : "contracts/0.8/MyERC21.sol:MyERC21";

    const [owner] = await hre.ethers.getSigners();
    var toAddress = taskArgs.address === constants.AddressZero ? owner.address : taskArgs.address;

    const tokenAddress = taskArgs.token === constants.AddressZero ? taskArgs.token : getTokenAddress();

    if (tokenAddress) {
      console.error("[Error] Address token is empty. You can set NFT in .env file or set params --token");
      return;
    }

    const token = await (await hre.ethers.getContractFactory(contractFactoryName)).attach(tokenAddress);

    const amount = hre.ethers.utils.parseEther(taskArgs.amount).toString();

    const tx = await token.connect(owner).mint(toAddress, amount);
    const receipt = await tx.wait();

    console.log(`[Success] Mint ${taskArgs.amount} (ether) to ${toAddress}`);
    console.log(`TxID: ${transactionPage(hre.network, receipt)}`);
  });

const { types } = require("hardhat/config");
const { constants } = require("ethers/lib/ethers");
const path = require("path");
const { transactionPage } = require("../../utils");
const { address } = require("../../utils/types");
const abiERC20 = require("../../abi/ERC20.json");

/**
 * Transfer coin or token to accounts
 *
 * npx hardhat transfer --path ./accounts/accounts.json --amount 0.01
 * npx hardhat transfer --path ./accounts/accounts.json --amount 100 --token 0x013345B20fe7Cf68184005464FBF204D9aB88227
 */
task("transfer", "Transfer coin or token to accounts")
  .addParam("path", "Path JSON file", undefined, types.inputFile)
  .addParam("token", "Address token transfer. Address zero is native coin. ", constants.AddressZero, address)
  .addParam("amount", "Amount per address", 0, types.float)
  .setAction(async function (taskArgs, hre) {
    const accounts = require(path.join(__dirname, "../", taskArgs.path));
    const [from] = await hre.ethers.getSigners();
    const ERC20 =
      taskArgs.token !== constants.AddressZero
        ? new hre.ethers.Contract(taskArgs.token, abiERC20, await hre.ethers.getSigner())
        : null;
    var amount = hre.ethers.utils.parseEther(`${taskArgs.amount}`); //.toString()

    // Check balance
    const balance = await (taskArgs.token === constants.AddressZero
      ? hre.ethers.provider.getBalance(from.address)
      : ERC20.balanceOf(from.address));

    const total = hre.ethers.utils.parseEther(`${accounts.length * taskArgs.amount}`);
    if (total.gt(balance)) {
      // total > balance
      console.error(`[Error] transfer amount exceeds balance`);
      return;
    }

    // 1. Use code call transfer to address
    if (ERC20) {
      var i = 0;
      amount = amount.toString();
      try {
        while (i < accounts.length) {
          const tx = await (await ERC20.transfer(accounts[i].address, amount)).wait();
          i++;
          console.log(`[Info] ${i}/${accounts.length} accounts, ${transactionPage(hre.network, tx)}`);
        }
        console.log(`[Success] transfer success`);
      } catch (e) {
        console.error(`[Error] transfer ${i}/${accounts.length} accounts, ${e.message}`);
      }
    } else {
      var i = 0;
      amount = amount.toHexString();
      try {
        while (i < accounts.length) {
          const tx = await (
            await from.sendTransaction({
              to: accounts[i].address,
              value: amount,
            })
          ).wait();
          i++;
          console.log(`[Success] ${i}/${accounts.length} accounts, ${transactionPage(hre.network, tx)}`);
        }
      } catch (e) {
        console.error(`[Error] transfer ${i}/${accounts.length} accounts, ${e.message}`);
      }
    }

    // 2. Call contract MultiTransfer
    if (ERC20) {
    } else {
    }
  });

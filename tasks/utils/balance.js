const { types } = require("hardhat/config");
const { constants } = require("ethers/lib/ethers");
const path = require("path");
const { address } = require("../../utils/types");
const abiERC20 = require("../../abi/ERC20.json");

/**
 * Prints an account's balance
 *
 * npx hardhat balance --account
 * npx hardhat balance --path ./accounts/accounts.json
 */
task("balance", "Prints an account's balance")
  .addParam("path", "Path JSON file", undefined, types.inputFile, true)
  .addParam("account", "The account's address", constants.AddressZero, address)
  .addParam("token", "The token's address", constants.AddressZero, address)
  .addParam("block", "Block number. Default is lastest", undefined, types.int, true)
  .setAction(async function (taskArgs, hre) {
    const accountAddresses = [];
    if (taskArgs.account !== constants.AddressZero) {
      accountAddresses.push(taskArgs.account);
    }
    if (taskArgs.path) {
      const accounts = require(path.join(__dirname, "../../", taskArgs.path));
      accounts.forEach(acc => accountAddresses.push(acc.address));
    }
    const ERC20 =
      taskArgs.token !== constants.AddressZero
        ? new hre.ethers.Contract(taskArgs.token, abiERC20, await hre.ethers.getSigner())
        : null;

    await Promise.all(
      accountAddresses.map(addr => {
        return new Promise((resolve, rejects) => {
          (taskArgs.token === constants.AddressZero
            ? hre.ethers.provider.getBalance(addr, taskArgs.block)
            : ERC20.balanceOf(addr, { blockTag: taskArgs.block })
          )
            .then(wei => {
              console.log(`${addr} ${wei.toString()} (wei) = ${hre.ethers.utils.formatEther(wei)} (ether)`);
              resolve();
            })
            .catch(rejects);
        });
      }),
    );
  });

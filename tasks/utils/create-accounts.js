const { types } = require("hardhat/config");
const fs = require("fs");
const crypto = require("crypto");

/**
 * Create account test to file
 *
 * npx hardhat create-accounts --number 1000
 */
task("create-accounts", "Create account test to file")
  .addParam("number", "Number of address. Default 10", 10, types.int)
  .setAction(async function (taskArgs, hre) {
    var number = +taskArgs.number;
    var accountsList = [];
    for (var i = 0; i < number; i++) {
      var id = crypto.randomBytes(32).toString("hex");
      var privateKey = "0x" + id;

      var wallet = new hre.ethers.Wallet(privateKey);
      accountsList.push({
        address: wallet.address,
        privateKey,
      });
    }

    fs.writeFileSync("./accounts/accounts.json", JSON.stringify(accountsList, null, 2));
    console.log(`[Success] Created success ${taskArgs.number} accounts`);
  });

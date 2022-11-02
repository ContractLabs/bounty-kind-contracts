/**
 * Prints the list of accounts
 *
 * npx hardhat accounts
 */
task("accounts", "Prints the list of accounts", async function (_, hre) {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

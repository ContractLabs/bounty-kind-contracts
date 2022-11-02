/**
 * Get block number
 *
 * npx hardhat block
 */
task("block", "Get block number").setAction(async function (_, hre) {
  const number = await hre.ethers.provider.getBlockNumber();

  console.log("Blocks: ", number.toString());
});

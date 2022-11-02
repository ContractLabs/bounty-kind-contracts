const { types } = require("hardhat/config");
const { isTomoChain, transactionPage } = require("../../utils");
const { address } = require("../../utils/types");
const { ADDRESS_ERC21_ISSUER, RPCs } = require("../../utils/constants");
const abiERC21Issuer = require("../../abi/ERC21Issuer.json");
const abiIssuerTomoZ = require("../../abi/IssuerTomoZ.json");

/**
 * Apply tomoz token trc21
 *
 * npx hardhat apply-tomoz --amount 10 --address
 */
task("apply-tomoz", "Apply tomoz token trc21.")
  .addParam("address", "Contract address apply tomoz", undefined, address)
  .addParam("amount", "Amount tomo apply tomoz. Default 10", 10, types.int)
  .setAction(async function (taskArgs, hre) {
    // Check tomochain network
    if (!isTomoChain(hre.network)) {
      console.error("[Error] This is not the tomochain network");
      return;
    }

    // check config contract address apply tomoz
    if (!ADDRESS_ERC21_ISSUER[hre.network.config.chainId]) {
      console.error(`[Error] Config Contract address apply tomoz`);
      return;
    }

    const tokenERC21 = taskArgs.address;

    const issuerTomoZ = new hre.ethers.Contract(
      ADDRESS_ERC21_ISSUER[hre.network.config.chainId],
      abiIssuerTomoZ,
      await hre.ethers.getSigner(),
    );

    const filter = issuerTomoZ.filters.Apply(null, tokenERC21);
    const eventApplys = await issuerTomoZ.queryFilter(filter);
    const amount = hre.ethers.utils.parseEther(`${taskArgs.amount}`);

    if (!eventApplys.length) {
      const minCap = await issuerTomoZ.minCap();
      if (minCap.gt(amount)) {
        // minCap > amount
        console.error(
          `[Error] Apply TomoZ min cap is ${hre.ethers.utils.formatEther(minCap)} ${
            RPCs[hre.network.config.chainId].nativeCurrency.symbol
          }`,
        );
        return;
      }
      // get issuer in contract
      const erc21Issuer = new hre.ethers.Contract(taskArgs.address, abiERC21Issuer, await hre.ethers.getSigner());
      const issuerAddress = await erc21Issuer.issuer();
      const accounts = await hre.ethers.getSigners();
      const issuerSigner = accounts.find(acc => acc.address === issuerAddress);

      if (!issuerSigner) {
        console.error(`[Error] Login issuer to apply tomoZ`);
        return;
      }

      const tx = await issuerTomoZ.connect(issuerSigner).apply(tokenERC21, { value: amount.toString() });
      const receipt = await tx.wait();
      console.log(`TxID: ${transactionPage(hre.network, receipt)}`);
    } else {
      const tx = await issuerTomoZ.charge(tokenERC21, { value: amount.toString() });
      const receipt = await tx.wait();
      console.log(`TxID: ${transactionPage(hre.network, receipt)}`);
    }
  });

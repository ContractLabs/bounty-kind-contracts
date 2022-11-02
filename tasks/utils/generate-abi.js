const fs = require("fs");
const fse = require("fs-extra");
const path = require("path");

const pathAbiTo = [];
const ArtifactsAbi = [
  "./artifacts/contracts/0.8/FiatContract.sol/FiatContract.json",
  "./artifacts/contracts/0.8/Market.sol/Market.json",
  "./artifacts/contracts/0.8/MarketSub.sol/MarketSub.json",
  "./artifacts/contracts/0.8/NFTConvert.sol/NFTConvert.json",
  "./artifacts/contracts/0.8/NFTPackage.sol/NFTPackage.json",
  // './artifacts/contracts/0.8/MyNFT.sol/MyNFT.json',
  // './artifacts/contracts/0.8/MyERC20.sol/MyERC20.json',
  // './artifacts/contracts/0.4.26/MyERC21.sol/MyERC21.json',
];

const pathAbiFrom = "./abi";

/**
 * Generate abi json
 *
 * npx hardhat generate-abi
 */
task("generate-abi", "Generate abi json").setAction(async function () {
  await Promise.all(
    pathAbiTo.map(
      async pTo =>
        new Promise((resolve, reject) => {
          try {
            // remove abi
            fs.rmdirSync(pTo, { recursive: true });

            // copy abi root
            if (fs.existsSync(pathAbiFrom)) {
              fse.copySync(pathAbiFrom, pTo, { overwrite: true });
            } else {
              fs.mkdirSync(pTo, { recursive: true });
            }

            resolve(true);
          } catch (err) {
            reject(err);
          }
        }),
    ),
  );

  await Promise.all(
    ArtifactsAbi.map(artiPath => {
      const artifact = JSON.parse(fs.readFileSync(artiPath));
      const fileName = path.basename(artiPath);

      return Promise.all(
        pathAbiTo.map(pTo => {
          return fs.promises.writeFile(`${pTo}/${fileName}`, JSON.stringify(artifact.abi)).then(() => true);
        }),
      );
    }),
  );
});

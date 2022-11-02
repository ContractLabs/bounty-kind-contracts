const hre = require("hardhat");
const { expect } = require("chai");

const args = [
  "NFT 4907",
  "NFTT",
  hre.ethers.constants.AddressZero,
  "0x64470E5F5DD38e497194BbcAF8Daa7CA578926F6",
  "0",
  "0x64470E5F5DD38e497194BbcAF8Daa7CA578926F6",
];

describe("Test NFT4907", function () {
  let nft4907;
  before(async function () {
    const [owner] = await ethers.getSigners();
    const NFT4907 = await ethers.getContractFactory("contracts/MyNFT.sol:MyNFT");
    nft4907 = await NFT4907.deploy(
      "NFT 4907",
      "NFTT",
      hre.ethers.constants.AddressZero,
      owner.address,
      "0",
      owner.address,
    );
    console.log(nft4907.address, await nft4907.owner());
  });

  it("Deployment should assign the total supply of tokens to the owner", async function () {});
});

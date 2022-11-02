const hre = require("hardhat");
const { expect } = require("chai");

describe("Test NFT4907", function () {
  let contract;
  before(async function () {
    const [owner] = await ethers.getSigners();
    const Contract = await ethers.getContractFactory("contracts/CompanyPackage.sol:CompanyPackage");
    contract = await Contract.deploy(owner.address, ethers.constants.AddressZero);
    console.log(contract.address);
  });

  it("Test unset", async function () {
    await (
      await contract.setTokensFiat(
        ["Yu", "BNB"],
        ["0x6f2f89bd53f622619479e7805b2f54716f545d19", "0x0000000000000000000000000000000000000000"],
      )
    ).wait();

    const a = await contract.getTokensList();

    await (await contract.resetTokensFiat()).wait();

    const b = await contract.getTokensList();

    console.log(a, b);
  });
});

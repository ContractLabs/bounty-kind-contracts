import * as dotenv from "dotenv";
import { Contract, ContractFactory } from "ethers";
import { ethers, upgrades } from "hardhat";

async function main(): Promise<void> {
  const Authority: ContractFactory = await ethers.getContractFactory("Authority");
  const authority: Contract = await upgrades.deployProxy(Authority, [], { kind: "uups", initializer: "init" });
  await authority.deployed();
  console.log("Authority deployed to: ", authority.address);

  const Treasury: ContractFactory = await ethers.getContractFactory("Treasury");
  const treasury: Contract = await upgrades.deployProxy(Treasury, [authority.address], {
    kind: "uups",
    initializer: "init",
  });
  await treasury.deployed();
  console.log("Authority deployed to: ", treasury.address);

  const BK20: ContractFactory = await ethers.getContractFactory("BK20v2");
  const ffe: Contract = await upgrades.deployProxy(
    BK20,
    [authority.address, treasury.address, "Forbidden Fruit Energy", "FFE", 18],
    {
      kind: "uups",
      initializer: "init",
    },
  );
  await ffe.deployed();
  console.log("FFE deployed to: ", ffe.address);

  const yu: Contract = await upgrades.deployProxy(BK20, [authority.address, treasury.address, "YU", "YU", 18], {
    kind: "uups",
    initializer: "init",
  });
  await yu.deployed();
  console.log("YU deployed to: ", ffe.address);

  // const Governance: ContractFactory = await ethers.getContractFactory("GovernanceUpgradeable");
  // const goverance: Contract = await upgrades.deployProxy(
  //     Governance,
  //     [],
  //     { kind: "uups", initializer: "init" },
  // );
  // await goverance.deployed();
  // console.log("Governance deployed to : ", goverance.address);

  // const Treasury: ContractFactory = await ethers.getContractFactory("TreasuryUpgradeable");
  // const treasury: Contract = await upgrades.deployProxy(
  //     Treasury,
  //     [goverance.address],
  //     { kind: "uups", initializer: "init" },
  // );
  // await treasury.deployed();
  // console.log("Treasury deployed to : ", treasury.address);

  // const RentableBK721: ContractFactory = await ethers.getContractFactory("RentableBK721Upgradeable");
  // const rentableBK721: Contract = await upgrades.deployProxy(
  //     RentableBK721,
  //     ["RentableNFC", "RNFC", "https://example/token/", 10000, "0xDc9ec7717E7e6F13fcf02cE1b40b7AFf5fb8Eb1d", goverance.address, treasury.address],
  //     { kind: "uups", initializer: "init" },
  // );
  // await rentableBK721.deployed();
  // console.log("RentableNFC deployed to : ", rentableBK721.address);

  // const Business: ContractFactory = await ethers.getContractFactory(
  //     "BusinessUpgradeable",
  // );
  // const business: Contract = await upgrades.deployProxy(Business, [], {
  //     kind: "uups",
  //     initializer: "init",
  // });
  // await business.deployed();
  // console.log("Business deployed to : ", business.address);

  // const Treasury: ContractFactory = await ethers.getContractFactory(
  //     "TreasuryUpgradeable",
  // );
  // const treasury: Contract = await upgrades.deployProxy(Treasury, [], {
  //     kind: "uups",
  //     initializer: "init",
  // });
  // await treasury.deployed();
  // console.log("Treasury deployed to : ", treasury.address);

  // const ERC20Test: ContractFactory = await ethers.getContractFactory("ERC20Test");
  // const erc20Test: Contract = await ERC20Test.deploy(
  //   "PaymentToken", "PMT"
  // );
  // await erc20Test.deployed();
  // console.log("ERC20Test deployed to : ", erc20Test.address);
}

main()
  .then(() => process.exit(0))
  .catch((error: Error) => {
    console.error(error);
    process.exit(1);
  });

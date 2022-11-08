import { Contract, ContractFactory } from "ethers";
import { ethers, upgrades } from "hardhat";

async function main(): Promise<void> {
  // const Treasury: ContractFactory = await ethers.getContractFactory("TreasuryUpgradeable");
  // const treasury: Contract = await upgrades.upgradeProxy(
  //     "0x345F31cda6738AbBe0a8a8EFe2397C2E9C60dcf2",
  //     Treasury,
  // );
  // await treasury.deployed();
  // console.log("Treasury upgraded to : ", treasury.address);

  // const Business: ContractFactory = await ethers.getContractFactory("BusinessUpgradeable");
  // const business: Contract = await upgrades.upgradeProxy(
  //     "0xf6D3B4Fbd90715976587b2058ABeA5F2D0cB517f",
  //     Business
  // );
  // await business.deployed();
  // console.log("Business upgraded to : ", await upgrades.erc1967.getImplementationAddress(business.address));

  //   const ERC20Test: ContractFactory = await ethers.getContractFactory("ERC20Test");
  //   const erc20Test: Contract = await ERC20Test.deploy(
  //     "PaymentToken", "PMT"
  //   );
  //   await erc20Test.deployed();
  //   console.log("ERC20Test deployed to : ", erc20Test.address);

  const RentableNFC: ContractFactory = await ethers.getContractFactory("RentableBK721Upgradeable");
  const rentableNFC: Contract = await upgrades.upgradeProxy("0xB4bfff4B5F44de9ea89721E9931f486687F8e1f5", RentableNFC);
  await rentableNFC.deployed();
  console.log("RentableNFC upgraded to : ", await upgrades.erc1967.getImplementationAddress(rentableNFC.address));
}

main()
  .then(() => process.exit(0))
  .catch((error: Error) => {
    console.error(error);
    process.exit(1);
  });

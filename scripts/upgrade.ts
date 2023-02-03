import {Contract, ContractFactory} from "ethers";
import {ethers, upgrades} from "hardhat";
import * as dotenv from "dotenv";

dotenv.config();

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
    // const RentableNFC: ContractFactory = await ethers.getContractFactory("RentableBK721Upgradeable");
    // const rentableNFC: Contract = await upgrades.upgradeProxy("0xB4bfff4B5F44de9ea89721E9931f486687F8e1f5", RentableNFC);
    // await rentableNFC.deployed();
    // console.log("RentableNFC upgraded to : ", await upgrades.erc1967.getImplementationAddress(rentableNFC.address));

    // const Treasury: ContractFactory = await ethers.getContractFactory("Treasury");
    // const treasury: Contract = await upgrades.upgradeProxy(process.env.TREASURY || "", Treasury);
    // await treasury.deployed();
    // console.log("Treasury upgraded to : ", await upgrades.erc1967.getImplementationAddress(treasury.address));

    // const Authority: ContractFactory = await ethers.getContractFactory("BKAuthority")
    // // const authority: Contract = await

    // const BK20: ContractFactory = await ethers.getContractFactory("BK20");
    // const FFE: Contract = await upgrades.upgradeProxy(process.env.FFE || "", BK20);
    // await FFE.deployed();
    // console.log("FFE upgraded to : ", await upgrades.erc1967.getImplementationAddress(FFE.address));

    // const YU: Contract = await upgrades.upgradeProxy(process.env.YU || "", BK20);
    // await YU.deployed();
    // console.log("YU upgraded to : ", await upgrades.erc1967.getImplementationAddress(YU.address));

    const Gacha: ContractFactory = await ethers.getContractFactory("Gacha");
    const gacha: Contract = await upgrades.upgradeProxy(
        process.env.GACHA || "",
        Gacha,
        {unsafeAllow: ["delegatecall"]},
    );
    await gacha.deployed();
    console.log(
        "Gacha upgraded to : ",
        await upgrades.erc1967.getImplementationAddress(gacha.address),
    );

    // const NFT: ContractFactory = await ethers.getContractFactory("BKNFT");
    // const nft: Contract = await upgrades.upgradeProxy(
    //     process.env.EQUIPMENT || "",
    //     NFT,
    // );
    // await nft.deployed();
    // console.log(
    //     "NFT upgraded to : ",
    //     await upgrades.erc1967.getImplementationAddress(nft.address),
    // );

    // const Marketplace: ContractFactory = await ethers.getContractFactory("Marketplace");
    // const marketplace: Contract = await upgrades.upgradeProxy(process.env.MARKETPLACE || "", Marketplace);
    // await marketplace.deployed();
    // console.log("Marketplace upgraded to : ", await upgrades.erc1967.getImplementationAddress(marketplace.address));

    // const RBK721: ContractFactory = await ethers.getContractFactory("RBK721");
    // const character: Contract = await upgrades.upgradeProxy(process.env.CHARACTER || "", RBK721);
    // await character.deployed();
    // console.log("RBK721 upgraded to : ", await upgrades.erc1967.getImplementationAddress(character.address));

    // const INO: ContractFactory = await ethers.getContractFactory("INO");
    // const ino: Contract = await upgrades.upgradeProxy(
    //     process.env.INO || "",
    //     INO,
    //     {unsafeAllow: ["delegatecall"]},
    // );
    // await ino.deployed();
    // console.log(
    //     "INO upgraded to: ",
    //     await upgrades.erc1967.getImplementationAddress(ino.address),
    // );
}

main()
    .then(() => process.exit(0))
    .catch((error: Error) => {
        console.error(error);
        process.exit(1);
    });

import * as dotenv from "dotenv";
import { Contract, ContractFactory } from "ethers";
import { ethers, upgrades } from "hardhat";

dotenv.config()

async function main(): Promise<void> {
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
    //     ["0x7aa44259f7c767503CBEad1D506E9d8782078f27"],
    //     { kind: "uups", initializer: "init" },
    // );
    // await treasury.deployed();
    // console.log("Treasury deployed to : ", treasury.address);

    // const RentableBK721: ContractFactory = await ethers.getContractFactory("RentableBK721Upgradeable");
    // const rentableBK721: Contract = await upgrades.deployProxy(
    //   RentableBK721,
    //   [
    //     "RentableNFC",
    //     "RNFC",
    //     "https://example/token/",
    //     10000,
    //     "0xDc9ec7717E7e6F13fcf02cE1b40b7AFf5fb8Eb1d",
    //     "0x7aa44259f7c767503CBEad1D506E9d8782078f27",
    //     "0xB255A005b65e986729e70De4d0cAa692914A8350",
    //   ],
    //   { kind: "uups", initializer: "init" },
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

    // const Authority: ContractFactory = await ethers.getContractFactory(
    //     "Authority",
    // );
    // const authority: Contract = await upgrades.deployProxy(Authority, [], {
    //     kind: "uups",
    //     initializer: "init",
    // });
    // await authority.deployed();
    // console.log("Authority deployed to: ", authority.address);

    // const Treasury: ContractFactory = await ethers.getContractFactory(
    //     "Treasury",
    // );
    // const treasury: Contract = await upgrades.deployProxy(
    //     Treasury,
    //     [authority.address],
    //     {
    //         kind: "uups",
    //         initializer: "init",
    //     },
    // );
    // await treasury.deployed();
    // console.log("Treasury deployed to: ", treasury.address);

    // const BK20: ContractFactory = await ethers.getContractFactory("BK20");
    // const ffe: Contract = await upgrades.deployProxy(
    //     BK20,
    //     [
    //         authority.address,
    //         treasury.address,
    //         "Forbidden Fruit Energy",
    //         "FFE",
    //         18,
    //     ],
    //     {
    //         kind: "uups",
    //         initializer: "init",
    //     },
    // );
    // await ffe.deployed();
    // console.log("FFE deployed to: ", ffe.address);

    // const yu: Contract = await upgrades.deployProxy(
    //     BK20,
    //     [authority.address, treasury.address, "YU", "YU", 18],
    //     {
    //         kind: "uups",
    //         initializer: "init",
    //     },
    // );
    // await yu.deployed();
    // console.log("YU deployed to: ", yu.address);

    // const BKNFT: ContractFactory = await ethers.getContractFactory("BKNFT");
    // const sphere: Contract = await upgrades.deployProxy(
    //     BKNFT,
    //     [
    //         "Bountykind Sphere",
    //         "NFTSphere",
    //         "https://dev-game-api.w3w.app/api/nfts/metadata/",
    //         0,
    //         process.env.YU || "",
    //         process.env.AUTHORITY || "",
    //         process.env.TREASURY || "",
    //     ],
    //     {
    //         kind: "uups",
    //         initializer: "init",
    //     },
    // );
    // await sphere.deployed();
    // console.log("sphere deployed to: ", sphere.address);

    // const item: Contract = await upgrades.deployProxy(
    //     BKNFT,
    //     [
    //         "Bountykind Item",
    //         "NFTItem",
    //         "https://dev-game-api.w3w.app/api/nfts/metadata/",
    //         0,
    //         process.env.YU || "",
    //         process.env.AUTHORITY || "",
    //         process.env.TREASURY || "",
    //     ],
    //     {
    //         kind: "uups",
    //         initializer: "init",
    //     },
    // );
    // await item.deployed();
    // console.log("item deployed to: ", item.address);

    // const RBK721: ContractFactory = await ethers.getContractFactory("RBK721")
    // const character: Contract = await upgrades.deployProxy(
    //     RBK721,
    //     [
    //         "Bountykind Character",
    //         "NFTCharacter",
    //         "https://dev-game-api.w3w.app/api/nfts/metadata/",
    //         0,
    //         process.env.YU || "",
    //         process.env.AUTHORITY || "",
    //         process.env.TREASURY || "",
    //     ],
    //     {
    //         kind: "uups",
    //         initializer: "init",
    //     },
    // )
    // await character.deployed();
    // console.log("character deployed to: ", character.address);

    // const yu: Contract = await upgrades.deployProxy(
    //     BK20,
    //     [authority.address, treasury.address, "YU", "YU", 18],
    //     {
    //         kind: "uups",
    //         initializer: "init",
    //     },
    // );
    // await yu.deployed();
    // console.log("YU deployed to: ", yu.address);

    // const Marketplace: ContractFactory = await ethers.getContractFactory("Marketplace");
    // const marketplace: Contract = await upgrades.deployProxy(
    //     Marketplace,
    //     [
    //         0,
    //         [sphere.address, item.address, character.address],
    //         process.env.AUTHORITY || "",
    //         process.env.TREASURY || ""
    //     ],
    //     {
    //         kind: "uups",
    //         initializer: "init",
    //     },
    // );
    // await marketplace.deployed();
    // console.log("Marketplace deployed to: ", marketplace.address);

    const Gacha : ContractFactory = await ethers.getContractFactory("Gacha");
    const gacha: Contract = await upgrades.deployProxy(
        Gacha,
        [
            process.env.AUTHORITY || "",
            process.env.TREASURY || ""
        ],
        {
            kind: "uups",
            initializer: "init",
        },
    );
    await gacha.deployed();
    console.log("Gacha deployed to: ", gacha.address);
}

main()
    .then(() => process.exit(0))
    .catch((error: Error) => {
        console.error(error);
        process.exit(1);
    });

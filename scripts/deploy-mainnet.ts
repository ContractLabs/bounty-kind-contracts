import * as dotenv from "dotenv";
import {ethers, run, upgrades} from "hardhat";
import {Contract, ContractFactory} from "ethers";

dotenv.config();

async function main(): Promise<void> {
    // const Authority: ContractFactory = await ethers.getContractFactory(
    //     "BKAuthority",
    // );
    // const authority: Contract = await upgrades.deployProxy(
    //     Authority,
    //     [
    //         "0xc065ee0cab9ecbd0b80f3a3cc219acce441573c6",
    //         [
    //             // MINTER_ROLE
    //             "0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6",
    //             "0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6",
    //             "0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6",
    //             "0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6",
    //             "0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6",

    //             // OPERATOR_ROLE
    //             "0x97667070c54ef182b0f5858b034beac1b6f3089aa2d3188bb1e8929f4fa9b929",

    //             // PAUSER_ROLE
    //             "0x65d7a28e3265b37a6474929f336521b332c1681b933f6cb9f3376673440d862a",

    //             // SIGNER_ROLE
    //             "0xe2f4eaae4a9751e85a3e4a7b9587827a877f29914755229b07a7b2da98285f70",

    //             // TREASURER_ROLE
    //             "0x3496e2e73c4d42b75d702e60d9e48102720b8691234415963a5a857b86425d07",

    //             // UPGRADER_ROLE
    //             "0x189ab7a9244df0848122154315af71fe140f3db0fe014031783b0946b8c9d2e3",
    //         ],
    //         [
    //             // MINTER_ROLE
    //             "0xa71002059e5a330d2adfcad8879ef0e36a241398",
    //             "0x30f51950bfa636edeaa6639f0359852889777f4f",
    //             "0xba16a39747dbcf4cc7f9eb9146af433e0e1b669b",
    //             "0x0eee4c91c19e2aeec604665031e7cc21489ac743",
    //             "0x267839d63f9d651569b5a3e4656f40eba778a59b",

    //             // OPERATOR_ROLE
    //             "0xcFa0D80130aE8Aa5532CE3c57bC42d66669Cf150",

    //             // PAUSER_ROLE
    //             "0xcFa0D80130aE8Aa5532CE3c57bC42d66669Cf150",

    //             // SIGNER_ROLE
    //             "0x8076cac201f11867f7490d6def88621b0439ee11",

    //             // TREASURER_ROLE
    //             "0x7caf7b77e2cb50fe152575a448362bb229975d45",

    //             // UPGRADER_ROLE
    //             "0xcFa0D80130aE8Aa5532CE3c57bC42d66669Cf150",
    //         ],
    //     ],
    //     {
    //         kind: "uups",
    //         initializer: "initialize",
    //     },
    // );
    // await authority.deployed();

    // console.log("Authority deployed to: ", authority.address);
    // await run(`verify:verify`, {
    //     address: authority.address,
    //     constructorArguments: [],
    // });

    // const Treasury: ContractFactory = await ethers.getContractFactory(
    //     "BKTreasury",
    // );
    // const treasury: Contract = await upgrades.deployProxy(
    //     Treasury,
    //     [
    //         "BountyKindsTreasury",
    //         authority.address,
    //         "0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE",
    //     ],
    //     {
    //         kind: "uups",
    //         initializer: "initialize",
    //     },
    // );
    // await treasury.deployed();

    // await run(`verify:verify`, {
    //     address: treasury.address,
    //     constructorArguments: [],
    // });

    // console.log("Treasury deployed to: ", treasury.address);

    const BKNFT: ContractFactory = await ethers.getContractFactory("BKNFT");
    const sphere: Contract = await upgrades.deployProxy(
        BKNFT,
        [
            "Bountykinds:Spheres",
            "BKS",
            "https://bountykinds.com/api/nfts/metadata/",
            "0",
            "0x3e098C23DCFBbE0A3f468A6bEd1cf1a59DC1770D",
            "0x38E586659c83c7Ea2cBC7b796b08B8179EddEbC5",
        ],
        {
            kind: "uups",
            initializer: "initialize",
        },
    );
    await sphere.deployed();

    await run(`verify:verify`, {
        address: sphere.address,
        constructorArguments: [],
    });

    // console.log("Authority deployed to: ", authority.address);
    // console.log("Treasury deployed to: ", treasury.address);
    // console.log("sphere deployed to: ", sphere.address);

    // const BK20: ContractFactory = await ethers.getContractFactory(
    //     "BountyKindsERC20",
    // );
    // const ffe: Contract = await BK20.deploy(
    //     "FORBIDDEN FRUIT ENERGY",
    //     "FFE",
    //     "0xc065ee0cab9ecbd0b80f3a3cc219acce441573c6",
    //     "0xee0f91b31c883f98c6bf73d3db27eca2be807e43",
    //     10_000_000,
    //     "0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c",
    //     "0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE",
    // );
    // await ffe.deployed();

    // await run(`verify:verify`, {
    //     address: "0x9E0335fb61958Fe19Bb120F3F8408B4297921820",
    //     constructorArguments: [
    //         "FORBIDDEN FRUIT ENERGY",
    //         "FFE",
    //         "0xc065ee0cab9ecbd0b80f3a3cc219acce441573c6",
    //         "0xee0f91b31c883f98c6bf73d3db27eca2be807e43",
    //         10_000_000,
    //         "0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c",
    //         "0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE",
    //     ],
    // });

    // const yu: Contract = await BK20.deploy(
    //     "BOUNTYKINDS YU",
    //     "YU",
    //     "0xc065ee0cab9ecbd0b80f3a3cc219acce441573c6",
    //     "0xee0f91b31c883f98c6bf73d3db27eca2be807e43",
    //     250_000,
    //     "0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c",
    //     "0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE",
    // );
    // await yu.deployed();

    // await run(`verify:verify`, {
    //     address: "yu.address",
    //     constructorArguments: [
    //         "BOUNTYKINDS YU",
    //         "YU",
    //         "0xc065ee0cab9ecbd0b80f3a3cc219acce441573c6",
    //         "0xee0f91b31c883f98c6bf73d3db27eca2be807e43",
    //         250_000,
    //         "0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c",
    //         "0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE",
    //     ],
    // });

    //console.log("YU deployed to: ", yu.address);
    //console.log("FFE deployed to: ", ffe.address);
}

main()
    .then(() => process.exit(0))
    .catch((error: Error) => {
        console.error(error);
        process.exit(1);
    });

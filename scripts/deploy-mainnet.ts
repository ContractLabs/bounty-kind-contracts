import * as dotenv from "dotenv";
import {ethers, run, upgrades} from "hardhat";
import {Contract, ContractFactory} from "ethers";
import {DeployProxyOptions} from "@openzeppelin/hardhat-upgrades/dist/utils";

dotenv.config();

const deployAndVerify = async (
    name: string,
    params: any[],
    canVerify: boolean = true,
    proxyOptions?: DeployProxyOptions | undefined,
): Promise<Contract> => {
    const Factory: ContractFactory = await ethers.getContractFactory(name);
    const instance: Contract = proxyOptions
        ? await upgrades.deployProxy(Factory, params, proxyOptions)
        : await Factory.deploy(...params);
    await instance.deployed();

    if (canVerify)
        await run(`verify:verify`, {
            address: instance.address,
            constructorArguments: proxyOptions ? [] : params,
        });

    console.log(`${name} deployed at: ${instance.address}`);

    return instance;
};

async function main(): Promise<void> {
    const proxyOption: DeployProxyOptions = {
        kind: "uups",
        initializer: "initialize",
    };
    // const authority = await deployAndVerify(
    //     "BKAuthority",
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
    //             "0x97667070c54ef182b0f5858b034beac1b6f3089aa2d3188bb1e8929f4fa9b929",

    //             // PAUSER_ROLE
    //             "0x65d7a28e3265b37a6474929f336521b332c1681b933f6cb9f3376673440d862a",

    //             // SIGNER_ROLE
    //             "0xe2f4eaae4a9751e85a3e4a7b9587827a877f29914755229b07a7b2da98285f70",

    //             // TREASURER_ROLE
    //             "0x3496e2e73c4d42b75d702e60d9e48102720b8691234415963a5a857b86425d07",
    //             "0x3496e2e73c4d42b75d702e60d9e48102720b8691234415963a5a857b86425d07",

    //             // UPGRADER_ROLE
    //             "0x189ab7a9244df0848122154315af71fe140f3db0fe014031783b0946b8c9d2e3",
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
    //             "0x3F579e98e794B870aF2E53115DC8F9C4B2A1bDA6", // test
    //             "0xcFa0D80130aE8Aa5532CE3c57bC42d66669Cf150",

    //             // PAUSER_ROLE
    //             "0xcFa0D80130aE8Aa5532CE3c57bC42d66669Cf150",

    //             // SIGNER_ROLE
    //             "0x8076cac201f11867f7490d6def88621b0439ee11",

    //             // TREASURER_ROLE
    //             "0x7caf7b77e2cb50fe152575a448362bb229975d45",
    //             "0x3F579e98e794B870aF2E53115DC8F9C4B2A1bDA6", // test

    //             // UPGRADER_ROLE
    //             "0xcFa0D80130aE8Aa5532CE3c57bC42d66669Cf150",
    //             "0x3F579e98e794B870aF2E53115DC8F9C4B2A1bDA6", // test
    //         ],
    //     ],
    //     true,
    //     proxyOption
    // );

    // const treasury = await deployAndVerify(
    //     "BKTreasury",
    //     [
    //         "BountyKindsTreasury",
    //         authority.address,
    //         "0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE",
    //     ],
    //     true,
    //     proxyOption
    // );

    const verify = true;
    const yuAddress = "0x3e098C23DCFBbE0A3f468A6bEd1cf1a59DC1770D";

    const authAddress = "0x38e586659c83c7ea2cbc7b796b08b8179eddebc5";
    //const authAddress = "0x5c11011a70177D20765114FfD6cAc4D181820959";
    const sphereAddress = "0x4b9c0a7F383335c824DFEa21B9F91ebFdF7168Ff";

    const notifyGate = await deployAndVerify(
        "NotifyGate",
        [authAddress],
        verify,
    );

    const gacha = await deployAndVerify(
        "Gacha",
        [authAddress],
        verify,
        proxyOption,
    );

    const ino = await deployAndVerify(
        "INO",
        [authAddress],
        verify,
        proxyOption,
    );

    const equipment = await deployAndVerify(
        "BKNFT",
        [
            "Bountykinds:Equipments",
            "BKE",
            "https://bountykinds.com/api/nfts/metadata/",
            "0",
            yuAddress,
            authAddress,
        ],
        verify,
        proxyOption,
    );

    const item2 = await deployAndVerify(
        "BKNFT",
        [
            "Bountykinds:Items2",
            "BKIT2",
            "https://bountykinds.com/api/nfts/metadata/",
            "0",
            yuAddress,
            authAddress,
        ],
        verify,
        proxyOption,
    );

    const metablocks = await deployAndVerify(
        "RBK721",
        [
            "Bountykinds:Metablocks",
            "BTK",
            "https://bountykinds.com/api/nfts/metadata/",
            "0",
            yuAddress,
            authAddress,
        ],
        verify,
        proxyOption,
    );

    const emperors = await deployAndVerify(
        "BKNFT",
        [
            "Bountykinds:Emperors",
            "BNFT",
            "https://bountykinds.com/api/nfts/metadata/",
            "0",
            yuAddress,
            authAddress,
        ],
        verify,
        proxyOption,
    );

    const character = await deployAndVerify(
        "RBK721",
        [
            "Bountykinds:Characters",
            "BKC",
            "https://bountykinds.com/api/nfts/metadata/",
            "0",
            yuAddress,
            authAddress,
        ],
        verify,
        proxyOption,
    );

    const marketplace = await deployAndVerify(
        "Marketplace",
        [
            800,
            authAddress,
            [
                item2.address,
                sphereAddress,
                emperors.address,
                equipment.address,
                character.address,
                metablocks.address,
                "0x87d20921BB5639c3eA6b66e4567396877a009595", // item
            ],
        ],
        verify,
        proxyOption,
    );

    const commandGate = await deployAndVerify(
        "PaymentGateway",
        [authAddress, [gacha.address, ino.address, marketplace.address]],
        verify,
    );

    console.log({
        ino: ino.address,
        item2: item2.address,
        gacha: gacha.address,
        emperors: emperors.address,
        character: character.address,
        equipment: equipment.address,
        metablocks: metablocks.address,
        notifyGate: notifyGate.address,
        commandGate: commandGate.address,
        marketplace: marketplace.address,
    });

    // const BKNFT: ContractFactory = await ethers.getContractFactory("BKNFT");
    // const sphere: Contract = await upgrades.deployProxy(
    //     BKNFT,
    //     [
    //         "Bountykinds:Spheres",
    //         "BKS",
    //         "https://bountykinds.com/api/nfts/metadata/",
    //         "0",
    //         "0x3e098C23DCFBbE0A3f468A6bEd1cf1a59DC1770D",
    //         "0x38E586659c83c7Ea2cBC7b796b08B8179EddEbC5",
    //     ],
    //     {
    //         kind: "uups",
    //         initializer: "initialize",
    //     },
    // );
    // await sphere.deployed();

    // await run(`verify:verify`, {
    //     address: sphere.address,
    //     constructorArguments: [],
    // });

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

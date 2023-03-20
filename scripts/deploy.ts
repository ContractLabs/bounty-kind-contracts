import * as dotenv from "dotenv";
import {Contract, ContractFactory} from "ethers";
import {defaultAbiCoder} from "ethers/lib/utils";
import {ethers, upgrades, run} from "hardhat";

dotenv.config();

async function main(): Promise<void> {
    const Authority: ContractFactory = await ethers.getContractFactory(
        "BKAuthority",
    );
    const authority: Contract = await upgrades.deployProxy(
        Authority,
        [
            "0x3F579e98e794B870aF2E53115DC8F9C4B2A1bDA6",
            defaultAbiCoder.encode(
                ["address"],
                ["0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526"],
            ),
            [
                "0x64470E5F5DD38e497194BbcAF8Daa7CA578926F6",
                "0x64470E5F5DD38e497194BbcAF8Daa7CA578926F6",
                "0x64470E5F5DD38e497194BbcAF8Daa7CA578926F6",
                "0x64470E5F5DD38e497194BbcAF8Daa7CA578926F6",
            ],
            [
                "0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6",
                "0x97667070c54ef182b0f5858b034beac1b6f3089aa2d3188bb1e8929f4fa9b929",
                "0x3496e2e73c4d42b75d702e60d9e48102720b8691234415963a5a857b86425d07",
                "0x65d7a28e3265b37a6474929f336521b332c1681b933f6cb9f3376673440d862a",
            ],
        ],
        {
            kind: "uups",
            initializer: "initialize",
        },
    );
    await authority.deployed();
    console.log("Authority deployed to : ", authority.address);

    const Treasury: ContractFactory = await ethers.getContractFactory(
        "TreasuryUpgradeable",
    );
    const treasury: Contract = await upgrades.deployProxy(
        Treasury,
        ["0x7aa44259f7c767503CBEad1D506E9d8782078f27"],
        {kind: "uups", initializer: "init"},
    );
    await treasury.deployed();
    console.log("Treasury deployed to : ", process.env.TREASURY);

    const RentableBK721: ContractFactory = await ethers.getContractFactory(
        "RentableBK721Upgradeable",
    );
    const rentableBK721: Contract = await upgrades.deployProxy(
        RentableBK721,
        [
            "RentableNFC",
            "RNFC",
            "https://example/token/",
            10000,
            "0xDc9ec7717E7e6F13fcf02cE1b40b7AFf5fb8Eb1d",
            "0x7aa44259f7c767503CBEad1D506E9d8782078f27",
            "0xB255A005b65e986729e70De4d0cAa692914A8350",
        ],
        {kind: "uups", initializer: "init"},
    );
    await rentableBK721.deployed();
    console.log("RentableNFC deployed to : ", rentableBK721.address);

    const Business: ContractFactory = await ethers.getContractFactory(
        "BusinessUpgradeable",
    );
    const business: Contract = await upgrades.deployProxy(Business, [], {
        kind: "uups",
        initializer: "init",
    });
    await business.deployed();
    console.log("Business deployed to : ", business.address);

    const Treasury: ContractFactory = await ethers.getContractFactory(
        "TreasuryUpgradeable",
    );
    const treasury: Contract = await upgrades.deployProxy(Treasury, [], {
        kind: "uups",
        initializer: "init",
    });
    await treasury.deployed();
    console.log("Treasury deployed to : ", process.env.TREASURY);

    const ERC20Test: ContractFactory = await ethers.getContractFactory(
        "ERC20Test",
    );
    const erc20Test: Contract = await ERC20Test.deploy("PaymentToken", "PMT");
    await erc20Test.deployed();
    console.log("ERC20Test deployed to : ", erc20Test.address);

    const Authority: ContractFactory = await ethers.getContractFactory(
        "Authority",
    );
    const authority: Contract = await upgrades.deployProxy(Authority, [], {
        kind: "uups",
        initializer: "init",
    });
    await authority.deployed();
    console.log("Authority deployed to: ", process.env.AUTHORITY);

    const Treasury: ContractFactory = await ethers.getContractFactory(
        "Treasury",
    );
    const treasury: Contract = await upgrades.deployProxy(
        Treasury,
        [process.env.AUTHORITY],
        {
            kind: "uups",
            initializer: "init",
        },
    );
    await treasury.deployed();
    console.log("Treasury deployed to: ", process.env.TREASURY);

    const BK20: ContractFactory = await ethers.getContractFactory("BK20");
    const ffe: Contract = await upgrades.deployProxy(
        BK20,
        [authority.address, "Forbidden Fruit Energy", "FFE"],
        {
            kind: "uups",
            initializer: "initialize",
        },
    );
    await ffe.deployed();
    console.log("FFE deployed to: ", ffe.address);

    const yu: Contract = await upgrades.deployProxy(
        BK20,
        [authority.address, "YU", "YU"],
        {
            kind: "uups",
            initializer: "initialize",
        },
    );
    await yu.deployed();
    console.log("YU deployed to: ", yu.address);

    const BKNFT: ContractFactory = await ethers.getContractFactory("BKNFT");
    const sphere: Contract = await upgrades.deployProxy(
        BKNFT,
        [
            "Bountykind Sphere",
            "NFTSphere",
            "https://dev-game-api.w3w.app/api/nfts/metadata/",
            0,
            yu.address || "",
            authority.address || "",
        ],
        {
            kind: "uups",
            initializer: "initialize",
        },
    );
    await sphere.deployed();
    console.log("sphere deployed to: ", sphere.address);

    const item: Contract = await upgrades.deployProxy(
        BKNFT,
        [
            "Bountykind Item",
            "NFTItem",
            "https://dev-game-api.w3w.app/api/nfts/metadata/",
            0,
            yu.address || "",
            authority.address || "",
        ],
        {
            kind: "uups",
            initializer: "initialize",
        },
    );
    await item.deployed();
    console.log("item deployed to: ", item.address);

    const equipment: Contract = await upgrades.deployProxy(
        BKNFT,
        [
            "Bountykind Equipment",
            "NFTEquip",
            "https://dev-game-api.w3w.app/api/nfts/metadata/",
            0,
            yu.address || "",
            authority.address || "",
        ],
        {
            kind: "uups",
            initializer: "initialize",
        },
    );
    await equipment.deployed();
    console.log("equipment deployed to: ", equipment.address);

    const RBK721: ContractFactory = await ethers.getContractFactory("RBK721");
    const character: Contract = await upgrades.deployProxy(
        RBK721,
        [
            "Bountykind Character",
            "NFTCharacter",
            "https://dev-game-api.w3w.app/api/nfts/metadata/",
            0,
            yu.address || "",
            authority.address || "",
        ],
        {
            kind: "uups",
            initializer: "initialize",
        },
    );
    await character.deployed();
    console.log("character deployed to: ", character.address);

    const Marketplace: ContractFactory = await ethers.getContractFactory(
        "Marketplace",
    );
    const marketplace: Contract = await upgrades.deployProxy(
        Marketplace,
        [
            0,
            [
                sphere.address,
                item.address,
                character.address,
                process.env.SPHERE_NEW,
            ],
            authority.address || "",
        ],
        {
            kind: "uups",
            initializer: "initialize",
        },
    );
    await marketplace.deployed();
    console.log("Marketplace deployed to: ", marketplace.address);

    const Gacha: ContractFactory = await ethers.getContractFactory("Gacha");
    const gacha: Contract = await upgrades.deployProxy(
        Gacha,
        [authority.address || ""],
        {
            kind: "uups",
            initializer: "initialize",
            unsafeAllow: ["delegatecall"],
        },
    );
    await gacha.deployed();
    console.log("Gacha deployed to: ", gacha.address);

    const INO: ContractFactory = await ethers.getContractFactory("INO");
    const ino: Contract = await upgrades.deployProxy(
        INO,
        [authority.address || ""],
        {
            kind: "uups",
            initializer: "initialize",
            unsafeAllow: ["delegatecall"],
        },
    );
    await ino.deployed();
    console.log("INO deployed to: ", ino.address);

    const CommandGate: ContractFactory = await ethers.getContractFactory(
        "CommandGate",
    );
    const commandGate: Contract = await CommandGate.deploy(
        "0x3005775740fA97131036b6aBfe86fc2acd70f7F0",
        "0x80ff7A61C582A6371cA32Da8d8634992b3910765",
        [],
    );
    await commandGate.deployed();
    console.log("CommandGate deployed to: ", commandGate.address);

    await run(`verify:verify`, {
        address: commandGate.address,
        constructorArguments: [
            "0x3005775740fA97131036b6aBfe86fc2acd70f7F0",
            "0x80ff7A61C582A6371cA32Da8d8634992b3910765",
            [],
        ],
    });

    const Factory: ContractFactory = await ethers.getContractFactory(
        "NFTFactory",
    );
    const factory: Contract = await Factory.deploy(
        ethers.constants.AddressZero,
        authority.address || "",
    );
    await factory.deployed();
    console.log("Factory deployed to: ", factory.address);

    const NotifyGate: ContractFactory = await ethers.getContractFactory(
        "NotifyGate",
    );
    const notifyGate: Contract = await NotifyGate.deploy(
        "0x3005775740fA97131036b6aBfe86fc2acd70f7F0",
        "0x2AD70C0cF809CC2810e239F74f9e2d119e6AdAb5",
    );
    await notifyGate.deployed();
    console.log("NotifyGate deployed to: ", notifyGate.address);

    await run(`verify:verify`, {
        address: notifyGate.address,
        constructorArguments: [
            "0x3005775740fA97131036b6aBfe86fc2acd70f7F0",
            "0x2AD70C0cF809CC2810e239F74f9e2d119e6AdAb5",
        ],
    });

    const data = defaultAbiCoder.encode(
        ["address", "address[]"],
        [
            "0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526",
            [
                "0x5c0e6505a748f6aeaad1a474cb2866c22dd4a5b8",
                "0x4a8d59baf30638fa00af210dac3b78c3f1ebce54",
                "0x41d546e8cac3f583a5075d6444e14d46cff278bb",
                "0x61661f30e9559492fa28f0ae78425d050080d5ca",
                "0x52f5c2737b5df48a0f3ae38d6f4d125596562734",
                "0x00d397a4694dec764858ab4babad076f540eda07",
                "0x2117479b2414850b1182afc8de7a628face84a34",
                "0x1f67c7a859dd3b399e4a5a7bb0d3e1a9d369b4f9",
                "0x085de31179e75bc85bbf6fd9f033508a9ee0ded2",
                "0x94DB90de01ecFbC2fA8f82443D1Ea0F4f09ccD18",
                "0x5445018B3A8Ae30cd25c1D1aAFbe7455a45abDaB",
            ],
        ],
    );
    console.log({data});

    const Multicall: ContractFactory = await ethers.getContractFactory(
        "Multicall",
    );
    const multicall: Contract = await Multicall.deploy();
    await multicall.deployed();
    console.log("Multicall deployed to: ", multicall.address);

    await run(`verify:verify`, {
        address: multicall.address,
        constructorArguments: [],
    });
}

main()
    .then(() => process.exit(0))
    .catch((error: Error) => {
        console.error(error);
        process.exit(1);
    });

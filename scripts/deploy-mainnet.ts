import * as dotenv from "dotenv";
import {ethers, run} from "hardhat";
import {Contract, ContractFactory} from "ethers";

dotenv.config();

async function main(): Promise<void> {
    const BK20: ContractFactory = await ethers.getContractFactory(
        "BountyKindsERC20",
    );
    const ffe: Contract = await BK20.deploy(
        "FORBIDDEN FRUIT ENERGY",
        "FFE",
        "0xc065ee0cab9ecbd0b80f3a3cc219acce441573c6",
        "0x72f615888beC96b9AD244fe774fF789657126fe1",
        10_000_000,
        "0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c",
        "0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE",
    );
    await ffe.deployed();

    await run(`verify:verify`, {
        address: ffe.address,
        constructorArguments: [
            "FORBIDDEN FRUIT ENERGY",
            "FFE",
            "0xc065ee0cab9ecbd0b80f3a3cc219acce441573c6",
            "0x72f615888beC96b9AD244fe774fF789657126fe1",
            10_000_000,
            "0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c",
            "0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE",
        ],
    });

    const yu: Contract = await BK20.deploy(
        "BOUNTYKINDS YU",
        "YU",
        "0xc065ee0cab9ecbd0b80f3a3cc219acce441573c6",
        "0x72f615888beC96b9AD244fe774fF789657126fe1",
        250_000,
        "0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c",
        "0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE",
    );
    await yu.deployed();

    await run(`verify:verify`, {
        address: yu.address,
        constructorArguments: [
            "BOUNTYKINDS YU",
            "YU",
            "0xc065ee0cab9ecbd0b80f3a3cc219acce441573c6",
            "0x72f615888beC96b9AD244fe774fF789657126fe1",
            250_000,
            "0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c",
            "0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE",
        ],
    });

    console.log("YU deployed to: ", yu.address);
    console.log("FFE deployed to: ", ffe.address);
}

main()
    .then(() => process.exit(0))
    .catch((error: Error) => {
        console.error(error);
        process.exit(1);
    });

import * as dotenv from "dotenv";
import {ethers, upgrades, run} from "hardhat";
import {Contract, ContractFactory} from "ethers";
import {defaultAbiCoder} from "ethers/lib/utils";

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
        "0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd",
        "0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526",
    );
    await ffe.deployed();
    console.log("FFE deployed to: ", ffe.address);

    await run(`verify:verify`, {
        address: ffe.address,
        constructorArguments: [
            "FORBIDDEN FRUIT ENERGY",
            "FFE",
            "0xc065ee0cab9ecbd0b80f3a3cc219acce441573c6",
            "0x72f615888beC96b9AD244fe774fF789657126fe1",
            "0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd",
            "0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526",
        ],
    });

    // const yu: Contract = await BK20.deploy(
    //     "BOUNTYKINDS YU",
    //     "YU",
    //     "0xc065ee0cab9ecbd0b80f3a3cc219acce441573c6",
    //     "0x72f615888beC96b9AD244fe774fF789657126fe1",
    //     250_000,
    //     "0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd",
    //     "0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526",
    // );
    // await yu.deployed();
    // console.log("YU deployed to: ", yu.address);
}

main()
    .then(() => process.exit(0))
    .catch((error: Error) => {
        console.error(error);
        process.exit(1);
    });

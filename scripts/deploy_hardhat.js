const { ethers } = require("hardhat");

async function main() {
    const [deployer] = await ethers.getSigners();

    console.log("-- Deploy Mocks, Token, Mint y Claim --");

    const BASENFT = await ethers.getContractFactory('BaseNFT');

    const iotabots = await BASENFT.deploy("IotaBots","IOTABOTS");
    await iotabots.waitForDeployment();
    const iotabots_addr = await iotabots.getAddress();

    const lilape = await BASENFT.deploy("LILApe", "LILAPE");
    await lilape.waitForDeployment();
    const lilape_addr = await lilape.getAddress();

    const lumi = await BASENFT.deploy("Lumi", "LUMI");
    await lumi.waitForDeployment();
    const lumi_addr = await lumi.getAddress();

    const ogape = await BASENFT.deploy("OGApe","OGAPE");
    await ogape.waitForDeployment();
    const ogape_addr = await ogape.getAddress();

    const ShimmerInu = await ethers.getContractFactory('ShimmerInuMemeToken');
    const shimmerinu = await ShimmerInu.deploy(iotabots_addr, lilape_addr, lumi_addr, ogape_addr);
    await shimmerinu.waitForDeployment();

    tx = await iotabots.safeMint(deployer.address, "bee");
    await tx.wait();
   
    console.log("Total claimed: ", await shimmerinu.balanceOf(deployer.address));
    console.log("Shimmer INU: ", await shimmerinu.getAddress());
    console.log("IOTABots: ", iotabots_addr);
    console.log("LILApe: ", lilape_addr);
    console.log("Lumi: ", lumi_addr);
    console.log("OGApe: ", ogape_addr);
}

main()
    .then(() => process.exit())
    .catch(error => {
        console.error(error);
        process.exit(1);
    })
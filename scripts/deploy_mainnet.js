const { ethers } = require("hardhat");

async function main() {
    const [deployer] = await ethers.getSigners();

    console.log("-- Deploy --");

    const ShimmerInu = await ethers.getContractFactory('ShimmerInuMemeToken');
    const shimmerinu = await ShimmerInu.deploy();
    await shimmerinu.waitForDeployment();

    console.log("Shimmer Inu: ", await shimmerinu.getAddress());
}

main()
    .then(() => process.exit())
    .catch(error => {
        console.error(error);
        process.exit(1);
    })
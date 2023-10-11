require("@nomicfoundation/hardhat-toolbox");
require("@nomicfoundation/hardhat-verify");
require("dotenv").config();

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async(taskArgs, hre) => {
    const accounts = await hre.ethers.getSigners();

    for (const account of accounts) {
        console.log(account.address);
    }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
    defaultNetwork: "localhost",
    networks: {
        hardhat: {
            blockGasLimit: 90000000
        },
        shimmer: {
            url: "https://json-rpc.evm.shimmer.network",
            chainId: 148,
            timeout: 60000,
            accounts: [process.env.PRIVATEKEY]
        }
    },
    solidity: {
        compilers: [{
                version: "0.8.21",
                settings: {
                    optimizer: {
                        enabled: true,
                        runs: 200,
                    },
                },
            },
        ]
    },
    etherscan: {
        apiKey:
          {
            shimmer: "xxx"
          },
        customChains: [
          {
            apikey: "xxx",
            network: "shimmer",
            chainId: 148,
            urls: {
              apiURL: "https://explorer.evm.shimmer.network/api",
              browserURL: "https://explorer.evm.shimmer.network/"
            }
          }
        ]
      },
};
require("@nomiclabs/hardhat-waffle");
require("dotenv").config();

const pk = process.env.PK;
const mainnetEndpoint = process.env.MAINNET_ENDPOINT;
const rinkebyEndpoint = process.env.RINKEBY_ENDPOINT;

module.exports = {
  solidity: "0.8.7",
  networks: {
    rinkeby: {
      url:rinkebyEndpoint,
      accounts: [`0x${pk}`]
    }
  }
  //TESTING
  // mocha: {
  //   timeout:100000
  // },
  // networks: {
  //   hardhat: {
  //     forking: {
  //       url: mainnetEndpoint
  //     }
  //   }
  // },
};



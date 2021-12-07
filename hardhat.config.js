require("@nomiclabs/hardhat-waffle");

const pk = "";
const mainnetEndpoint = "";
const rinkebyEndpoint = "";
const kovanEndpoint = "";

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





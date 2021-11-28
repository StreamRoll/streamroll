require("@nomiclabs/hardhat-waffle");

const pk = "";
const mainnetEndpoint = "https://mainnet.infura.io/v3/2598d2302edb4d26914e38c5759fbbcb";
const rinkebyEndpoint = "https://rinkeby.infura.io/v3/2598d2302edb4d26914e38c5759fbbcb";

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




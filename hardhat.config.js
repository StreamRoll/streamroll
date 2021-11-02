require("@nomiclabs/hardhat-waffle");

const pk = ""; //NEVER PUT IT HERE IN PRODUCTION NEITHER A PK WITH REAL ETH
const endpoint = "";

module.exports = {
  solidity: "0.8.7",
  networks: {
    rinkeby: {
      url:endpoint,
      accounts: [`0x${pk}`]
    }
  }
  //THIS IS FOR TESTING PURPOSES --> FORKING MAINNET
  // mocha: {
  //   timeout:100000
  // },
  // networks: {
  //   hardhat: {
  //     forking: {
  //       url: "MAINNET URL"
  //     }
  //   }
  // },
};

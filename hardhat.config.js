require("@nomiclabs/hardhat-waffle");

const pk = "YOUR PUBLIC KEY"; //NEVER PUT IT HERE IN PRODUCTION NEITHER A PK WITH REAL ETH
const endpoint = "YOUR ENDPOINT";

module.exports = {
  solidity: "0.8.7",
  networks: {
    rinkeby: {
      url:endpoint,
      accounts:[`0x${pk}`]
    }
  }
};

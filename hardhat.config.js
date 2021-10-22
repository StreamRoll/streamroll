require("@nomiclabs/hardhat-waffle");

const pk = "9559de0d3b989be78cd20ea3da4151b7f5c72be085ec04add6ce6ef47b6691c4";
const endpoint = "https://rinkeby.infura.io/v3/faf17ca58524494b98040c2047b5465a";

module.exports = {
  solidity: "0.8.7",
  networks: {
    rinkeby: {
      url:endpoint,
      accounts:[`0x${pk}`]
    }
  }
};

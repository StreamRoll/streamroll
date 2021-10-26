require("@nomiclabs/hardhat-waffle");

const pk = "d045412d2baf4fa34b32d25e96da433c5e68d35b5fbe0d6dde338096bd3d0fea"; //NEVER PUT IT HERE IN PRODUCTION NEITHER A PK WITH REAL ETH
const endpoint =
  "https://eth-rinkeby.alchemyapi.io/v2/rYfYDKefrMURVBWyaF7i83qympWlYDXO";

module.exports = {
  solidity: "0.8.7",
  networks: {
    rinkeby: {
      url: endpoint,
      accounts: [`0x${pk}`],
    },
  },
};

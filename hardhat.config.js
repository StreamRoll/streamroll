require("@nomiclabs/hardhat-waffle");
require("dotenv").config({path: '.env'});

const { INFURA_PROJECT_ID, PRIVATE_KEY } = process.env;

module.exports = {
  solidity: "0.8.7",
  networks: {
    localhost: {
      url: "http://localhost:8545",
    },
    rinkeby: {
      url: `https://rinkeby.infura.io/v3/${INFURA_PROJECT_ID}`,
      accounts:[`0x${PRIVATE_KEY}`]
    },
    ropsten: {
      url: `https://ropsten.infura.io/v3/${INFURA_PROJECT_ID}`,
      accounts:[`0x${PRIVATE_KEY}`]
    },
    kovan: {
      url: `https://kovan.infura.io/v3/${INFURA_PROJECT_ID}`,
      accounts:[`0x${PRIVATE_KEY}`]
    },
    goerli: {
      url: `https://goerli.infura.io/v3/${INFURA_PROJECT_ID}`,
      accounts:[`0x${PRIVATE_KEY}`]
    },
    mainnet: {
      url: `https://mainnet.infura.io/v3/${INFURA_PROJECT_ID}`,
      accounts:[`0x${PRIVATE_KEY}`]
    }
  }
};





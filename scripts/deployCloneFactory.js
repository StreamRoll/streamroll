async function main() {

    // Deploying CloneFactory.sol
    const [deployer] = await ethers.getSigners();
    console.log("Deploying contracts with the account:", deployer.address);

    console.log("Account balance:", (await deployer.getBalance()).toString());
  
    const CLONE_FACTORY = await ethers.getContractFactory("CloneFactory");
    const CloneFactory = await CLONE_FACTORY.deploy("0x8dB00cD456f772f2d5782D09Df31278bA4d69F39");
    
    console.log("CloneFactory.sol address -->", CloneFactory.address);

  }
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });
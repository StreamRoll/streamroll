async function main() {

    // Deploying CloneFactory.sol
    const [deployer] = await ethers.getSigners();
    console.log("Deploying contracts with the account:", deployer.address);

    console.log("Account balance:", (await deployer.getBalance()).toString());
  
    const CLONE_FACTORY = await ethers.getContractFactory("CloneFactory");
    const CloneFactory = await CLONE_FACTORY.deploy("0x40F39E578455b96b4f1e9A3C212724AA2bf4BB29");
    
    console.log("CloneFactory.sol address -->", CloneFactory.address);

  }
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });
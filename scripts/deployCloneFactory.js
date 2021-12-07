async function main() {

    // Deploying CloneFactory.sol
    const [deployer] = await ethers.getSigners();
    console.log("Deploying contracts with the account:", deployer.address);

    console.log("Account balance:", (await deployer.getBalance()).toString());
  
    const CLONE_FACTORY = await ethers.getContractFactory("CloneFactory");
    const CloneFactory = await CLONE_FACTORY.deploy("0xa799F7150768992be3a4BE489E6cFEd3D17D83cA");
    console.log("CloneFactory.sol address -->", CloneFactory.address);

  }
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });
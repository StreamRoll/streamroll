async function main() {
    const [deployer] = await ethers.getSigners();
  
    console.log("Deploying contracts with the account:", deployer.address);
  
    console.log("Account balance:", (await deployer.getBalance()).toString());
  
    const CloneFactory = await ethers.getContractFactory("CloneFactory");
    const cloneFactory = await CloneFactory.deploy("0xB1F2471536A8646BA0Bce9F494e8bc1a85804198");
  
    console.log("CloneFactory address -->", cloneFactory.address);
  }
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });
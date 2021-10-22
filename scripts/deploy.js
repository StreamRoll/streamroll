async function main() {
    const [deployer] = await ethers.getSigners();
  
    console.log("Deploying contracts with the account:", deployer.address);
  
    console.log("Account balance:", (await deployer.getBalance()).toString());
  
    const StreamRollSupply = await ethers.getContractFactory("StreamRollSupply");
    const streamrollsupply = await StreamRollSupply.deploy();
  
    console.log("StreamRollSupply address -->", streamrollsupply.address);
  }
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });
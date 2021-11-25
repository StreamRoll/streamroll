async function main() {
    // Deploying StreamRollV1.sol
    // const [deployer] = await ethers.getSigners();
    // console.log("Deploying contracts with the account:", deployer.address);

    // console.log("Account balance:", (await deployer.getBalance()).toString());
  
    // const STREAM_ROLLV1 = await ethers.getContractFactory("StreamRollV1");
    // const StreamRollV1 = await STREAM_ROLLV1.deploy();
  
    // console.log("StreamRollV1.sol address -->", StreamRollV1.address);

    // Deploying CloneFactory.sol
    const [deployer] = await ethers.getSigners();
    console.log("Deploying contracts with the account:", deployer.address);

    console.log("Account balance:", (await deployer.getBalance()).toString());
  
    const CLONE_FACTORY = await ethers.getContractFactory("CloneFactory");
    const CloneFactory = await CLONE_FACTORY.deploy("0x6FA2eF89ab4601B34313BF93E0E039cCCE213c4E");
  
    console.log("CloneFactory.sol address -->", CloneFactory.address);

  }
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });
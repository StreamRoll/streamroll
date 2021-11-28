const { expect, assert, should} = require("chai");

const provider = waffle.provider;

// npx hardhat test to run the tests
describe("StreamRolV1.sol", () => {
    
    let StreamRollV1Mock;
    let contract;
    let alice;
    let bob;
    let attacker;
    let aliceContract; //alice is the signer
    let bobContract;
    let attackerContract;
    let SuperF;
    let _SuperF;

    beforeEach(async () => {

        StreamRollV1 = await ethers.getContractFactory("StreamRollV1Mock");
        [alice, bob, attacker] = await ethers.getSigners();
        contract = await StreamRollV1.deploy();
        aliceContract = await contract.connect(alice);
        bobContract = await contract.connect(bob);
        attackerContract = await contract.connect(attacker);
    

    });

    it ("correct deployment", async () => {
        const address0 = "0x0000000000000000000000000000000000000000";
        await expect(await aliceContract.owner()).to.equal(address0);
        await aliceContract.initialize(alice.address);
        await expect(await aliceContract.owner()).to.equal(alice.address);
        await expect(
            aliceContract.initialize(alice.address)
            ).to.be.revertedWith("Initializable: contract is already initialized");
        await expect(
            bobContract.initialize(bob.address)
            ).to.be.revertedWith("Initializable: contract is already initialized");
    });
    it ("math", async () => {
        // const sContract = await SuperF.connect(alice);
        await aliceContract._createFlow();
    });

});




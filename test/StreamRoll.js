const { expect } = require("chai");

// npx hardhat test to run the tests
describe("StreamRoll contract", () => {
    it("should deploy correctly", async function() {

        const [owner] = await ethers.getSigners();

        const StreamRoll = await ethers.getContractFactory("StreamRoll");

        const streamroll = await StreamRoll.deploy();

        await streamroll.setNum(10);

        expect(await streamroll.getNum()).to.equal(10);
    });
});
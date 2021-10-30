const { Signer } = require("@ethersproject/abstract-signer");
const { expect} = require("chai");

const provider = waffle.provider;

// npx hardhat test to run the tests
describe("StreamRollV1.sol", () => {

    let StreamRollSupply;
    let contract;
    let user;
    let signerContract;

    beforeEach(async () => {

        [user, user2] = await ethers.getSigners();
        StreamRollSupply = await ethers.getContractFactory("StreamRollV1");
        contract = await StreamRollSupply.deploy();
        signerContract = await contract.connect(user);

    });

    describe("Successfully deployed", () => {
        it("all the variables should match", async () => {
            const cEth = await contract._cEth();
            const eRate = await contract.exchangeRate();
            
            expect(cEth).to.equal("0xd6801a1DfFCd0a410336Ef88DeF4320D6DF1883e");
            expect(eRate).to.equal("32");
        });
        it("should have a payable function to recieve eth and update accordingly", async () => {
            const balance = await provider.getBalance(contract.address);
            expect(balance.toString()).to.equal("0");
            await user.sendTransaction({
                to: contract.address,
                value: ethers.utils.parseEther("10")
            });
            const newBalance = await provider.getBalance(contract.address);
            expect(ethers.utils.formatEther(newBalance)).to.equal("10.0");
        });
    });


});

// SPDX-License-Identifier: GPL-3.0
pragma solidity >= 0.8.0 < 0.9.0;

///@author StreamRoll team:)
///@title StreamRollSupply
///@notice it accepts eth as collateral and exchanges it for
///cEth.. Everything happens inside the contract, behaving like a pool.
interface CEth {
    function mint() external payable;
    function redeemUnderlying(uint redeemAmount) external returns (uint);
}

interface Comptroller {
    function markets(address) external returns (bool, uint256);
    function enterMarkets(address[] calldata cTokens)
        external
        returns (uint256[] memory);
    function getAccountLiquidity(address)
        external
        view
        returns (uint256, uint256, uint256);
    function getAssetsIn(address acount) 
        external
        view
        returns (address[] memory);
}

interface CErc20 {
    function mint(uint256) external returns (uint256);
    function borrow(uint256) external returns (uint256);
    function borrowRatePerBlock() external view returns (uint256);
    function borrowBalanceCurrent(address) external returns (uint256);
    function repayBorrow(uint256) external returns (uint256);
}

interface PriceFeed {
    function getUnderlyingPrice(address cToken) external view returns (uint);
}


contract StreamRollSupply {
    
    CEth cEth;
    CErc20 cDai;
    Comptroller comptroller;


    event Log(string, address, uint);


    ///@dev To keep track of balances and authorize
    ///transactions. balances = wei. wei = 1 eth * 10 ^18
    ///checkout = wei. This is the redeemed amount ready to checkout
    ///borrowedBalances = amount borrowed in the underlying asset 
    mapping(address => uint) public balances;
    mapping(address => uint) public checkout;
    mapping(address => uint) public borrowedBalances;


    ///@dev cEth --> the contract's address for cEther on rinkeby
    ///cDai--> the contract's address for cDai on rinkeby
    constructor() {
        cEth = CEth(0xd6801a1DfFCd0a410336Ef88DeF4320D6DF1883e); 
        cDai = CErc20(0x6D7F0754FFeb405d23C51CE938289d4835bE3b14);
        comptroller = Comptroller(0x2EAa9D77AE4D8f9cdD9FAAcd44016E746485bddb);
    }

    receive() external payable {}

    ///@dev supplyEthToCompund --> accepts ether and mints cEth.
    ///Everything stays inside our contract, behaving like a pool.
    function supplyEthToCompound() external payable returns (bool) {
        cEth.mint{value: msg.value}();
        balances[msg.sender] += msg.value;
        emit Log("New balance", msg.sender, msg.value);
        return true;
    }

    ///@dev Converts cEth to Eth. The _amount is in wei
    ///Eth goes back to this contract.
    function getEtherBack(uint _amount) external returns (bool) {
        require(balances[msg.sender] > 0);
        require(balances[msg.sender] >= _amount, "Not enough funds");
        require(cEth.redeemUnderlying(_amount) == 0, "ERROR");
        balances[msg.sender] -= _amount;
        checkout[msg.sender] += _amount;
        emit Log("New CHECKOUT REQUESTED", msg.sender, _amount);
        return true;
    }

    ///The amount in cEth wei of the corresponding account.
    /// balance = eth * exchangeRate * 10^18
    function getBalance(address _requested) external view returns (uint) {
        return balances[_requested];
    }

    ///The amount ready to re-send to the msg.sender.
    ///Amount in wei
    function getCheckout(address _requested) external view returns (uint) {
        return checkout[_requested];
    }

    ///@dev transfers the converted amount back to the sender. 
    ///this transfer is in wei.
    ///_amount = wei
    function transferBack(uint _amount, address payable _to) external returns (bool) {
        require(checkout[msg.sender] > 0, "zero balance not supported");
        require(checkout[msg.sender] >= _amount, "Not enough funds");
        require(msg.sender == _to, "INCORRECT ADDRESS");
        (bool sent, bytes memory data) = _to.call{value:_amount}("");
        require(sent, "Transaction Failed");
        checkout[msg.sender] -= _amount;
        emit Log("Transfer succesfull", msg.sender, _amount);
        return true;
    } 

    ///@dev borrowFromCompund transfers the collateral asset to the protocol 
    ///and creates a borrow balance that begins accumulating interests based
    ///on the borrow rate. The amount borrowed must be less than the 
    ///user's collateral balance multiplied by the collateral factor * exchange rate
    function borrowFromCompound(uint _amount) public payable returns (bool) {
        address[] memory cTokens = new address[](2);
        cTokens[0] = 0xd6801a1DfFCd0a410336Ef88DeF4320D6DF1883e;
        cTokens[1] = 0x6D7F0754FFeb405d23C51CE938289d4835bE3b14;
        uint[] memory errors = comptroller.enterMarkets(cTokens);
        if (errors[0] != 0) {
           revert("Comptroller.enterMarkets failed");
       }
       require(cDai.borrow(_amount) == 0, "Not Working");
       borrowedBalances[msg.sender] += _amount;
       return true;
    }

    ///@dev returns the total borrowed amount for the EOA accounts.
    function returnBorrowedBalances() external view returns (uint) {
        return borrowedBalances[msg.sender];
    }

    ///@dev returns the total borrowed amount of this smart contract
    function streamRollTotalBorrowed() external returns (uint) {
        return cDai.borrowBalanceCurrent(address(this));
    }

    ///@dev repays the borrowed amount
    function repayDebt() external payable returns (bool) {
        require(borrowedBalances[msg.sender] <= msg.value, "You are Over Paying");
        require(cDai.repayBorrow(msg.value) == 0, "Error");
        borrowedBalances[msg.sender] -= msg.value;
        return true;
    }


}








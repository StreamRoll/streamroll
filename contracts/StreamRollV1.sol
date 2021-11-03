// SPDX-License-Identifier: GPL-3.0
pragma solidity >= 0.8.0 < 0.9.0;

import './interfaces/ICERC20.sol';
import './interfaces/IERC20.sol';
import './interfaces/ICETH.sol';
import './interfaces/IComptroller.sol';

///@author StreamRoll team:)
///@title StreamRollV1
///@notice it accepts eth as collateral and exchanges it for
///cEth.. Everything happens inside the contract, behaving like a pool.
/// It then streams chunks to the desired accounts.
contract StreamRollV1 {
    
    ICETH cEth;
    ICERC20 cDai;
    IComptroller comptroller;


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
        cEth = ICETH(0xd6801a1DfFCd0a410336Ef88DeF4320D6DF1883e); 
        cDai = ICERC20(0x6D7F0754FFeb405d23C51CE938289d4835bE3b14);
        comptroller = IComptroller(0x2EAa9D77AE4D8f9cdD9FAAcd44016E746485bddb);
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

    ///@dev borrowFromCompund transfers the collateral asset to the protocol 
    ///and creates a borrow balance that begins accumulating interests based
    ///on the borrow rate. The amount borrowed must be less than the 
    ///user's collateral balance multiplied by the collateral factor * exchange rate
    function borrowFromCompound(uint _amount) external payable returns (bool) {
        //approx --> this is due to exchange rate issues in testnets
        //THIS IS ONLY FOR RINKEBY
        uint8 ethToDai = 210;
        require(balances[msg.sender] * ethToDai >= _amount, "You need more collateral");
        uint aggregateBorrowed = balances[msg.sender] - borrowedBalances[msg.sender];
        require(aggregateBorrowed * ethToDai >= _amount, "You need more collateral");
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

    ///@dev transfers the converted amount back to the sender. 
    ///this transfer is in wei.
    ///_amount = wei
    function transferBack(uint _amount, address payable _to) external returns (bool) {
        require(checkout[msg.sender] >= _amount, "Not enough checkout funds");
        require(msg.sender == _to, "INCORRECT ADDRESS");
        (bool sent, bytes memory data) = _to.call{value:_amount}("");
        require(sent, "Transaction Failed");
        checkout[msg.sender] -= _amount;
        emit Log("Transfer succesfull", msg.sender, _amount);
        return true;
    } 

    ///@dev Converts cEth to Eth. The _amount is in wei
    ///Eth goes back to this contract.
    function getEtherBack(uint _amount) external returns (bool) {
        //approx --> this is due to exchange rate issues in testnets
        //THIS IS ONLY FOR RINKEBY
        uint8 ethToDai = 210;
        require(balances[msg.sender] - (borrowedBalances[msg.sender] / ethToDai) >= _amount, "Not enough funds to retrieve" );
        require(cEth.redeemUnderlying(_amount) == 0, "ERROR");
        balances[msg.sender] -= _amount;
        checkout[msg.sender] += _amount;
        emit Log("New CHECKOUT REQUESTED", msg.sender, _amount);
        return true;
    }

    ///@dev repays the borrowed amount in dai
    ///@param _repayAmount = dai * 10 ^18
    function repayDebt(uint _repayAmount) external returns (bool) {
        IERC20 underlying = IERC20(0x5592EC0cfb4dbc12D3aB100b257153436a1f0FEa);
        underlying.approve(0x6D7F0754FFeb405d23C51CE938289d4835bE3b14, _repayAmount);
        require(cDai.repayBorrow(_repayAmount) == 0, "Error in repayBorrow()");
        borrowedBalances[msg.sender] -= _repayAmount;
        return true;
    }

    ///@dev returns the total borrowed amount of this smart contract
    // function streamRollTotalBorrowed() external returns (uint) {
    //     return cDai.borrowBalanceCurrent(address(this));
    // }

    ///The amount in cEth wei of the corresponding account.
    /// balance = eth * exchangeRate * 10^18
    function getSuppliedBalances(address _requested) external view returns (uint) {
        return balances[_requested];
    }

    ///The amount ready to re-send to the msg.sender.
    ///Amount in wei
    function getCheckout(address _requested) external view returns (uint) {
        return checkout[_requested];
    }

    ///@dev returns the total borrowed amount for the EOA accounts.
    function returnBorrowedBalances() external view returns (uint) {
        return borrowedBalances[msg.sender];
    }
}









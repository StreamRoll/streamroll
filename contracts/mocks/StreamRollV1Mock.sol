// SPDX-License-Identifier: GPL-3.0
pragma solidity >= 0.8.0 < 0.9.0;

import '../interfaces/ICERC20.sol';
import '../interfaces/IERC20.sol';
import '../interfaces/ICETH.sol';
import '../interfaces/IComptroller.sol';

///@author StreamRoll team:)
///@title StreamRollV1
///@notice it accepts eth as collateral and exchanges it for
///cEth.. Everything happens inside the contract, behaving like a pool.
/// It then streams chunks to the desired accounts.
contract StreamRollV1Mock {
    
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
        cEth = ICETH(0x4Ddc2D193948926D02f9B1fE9e1daa0718270ED5); 
        cDai = ICERC20(0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643);
        comptroller = IComptroller(0x3d9819210A31b4961b30EF54bE2aeD79B9c9Cd3B);
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

    ///@dev Converts cEth to Eth.
    ///@param _amount = in wei
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
    ///balance = wei
    function getSuppliedBalances(address _requested) external view returns (uint) {
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
    function borrowFromCompound(uint _amount) external payable returns (bool) {
        require(balances[msg.sender] > 0);
        require(balances[msg.sender] >= _amount, "You need more funds");
        ///missing a require statement require()
        address[] memory cTokens = new address[](2);
        cTokens[0] = 0x4Ddc2D193948926D02f9B1fE9e1daa0718270ED5;
        cTokens[1] = 0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643;
        uint[] memory errors = comptroller.enterMarkets(cTokens);
        if (errors[0] != 0) {
           revert("Comptroller.enterMarkets failed");
       }
       require(cDai.borrow(_amount) == 0, "Borrow part not working");
       borrowedBalances[msg.sender] += _amount;
       return true;
    }

    ///@dev returns the total borrowed amount for the EOA accounts.
    function returnBorrowedBalances() external view returns (uint) {
        return borrowedBalances[msg.sender];
    }

    ///@dev returns the total borrowed amount of this smart contract
    // function streamRollTotalBorrowed() external returns (uint) {
    //     uint borrowedAmount = cDai.borrowBalanceCurrent(address(this));
    //     return borrowedAmount;
    //     //return cDai.borrowBalanceCurrent(address(this));
    // }

    ///@dev repays the borrowed amount in dai
    ///@param _repayAmount = dai * 10 ^18
    function repayDebt(uint _repayAmount) external returns (bool) {
        //missing require statemetns
        IERC20 underlying = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
        underlying.approve(0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643, _repayAmount);
        require(cDai.repayBorrow(_repayAmount) == 0, "Error in repayBorrow()");
        borrowedBalances[msg.sender] -= _repayAmount;
        return true;
    }
}









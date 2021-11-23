// SPDX-License-Identifier: GPL-3.0
pragma solidity >= 0.8.0 < 0.9.0;

import './interfaces/ICERC20.sol';
import './interfaces/IERC20.sol';
import './interfaces/ICETH.sol';
import './interfaces/IComptroller.sol';

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

///@title StreamRollV1
///@notice StreamRollV1 is the base contract. Here, all the logic is kept.
///This contract is intended to be 1 contract -> 1 account. In order to do this, 
///we implemented the (EIP-1167) standard or "Minimal Proxy". There is a CloneFactory contract
///which deploys a "cheap version of this" making it an identical child. When the contract is called
///from the Factory, the msg.sender is sent as an argument for the initialize() function. This makes the
///creator of the identical child the unique owner of this contract.
///@author StreamRoll
contract StreamRollV1 is ReentrancyGuard, Initializable {

    address private owner;

    ///@dev Interfaces to interact with Compound and ERC20.
    ICETH cEth;
    ICERC20 cDai;
    IComptroller comptroller;

    event Log(string, address, uint);

    event Creation(string _message, address _owner);

    modifier onlyOwner() {
        require(owner == msg.sender, "You are not authorized, only owner");
        
        _;
    }

    ///@notice This function is called only once at deployment. 
    ///We ensure that the function cannot be called again by the initializer modifier
    ///provided by OpenZeppelin. 
    ///@param _owner the msg.sender of the CloneFactory.
    function initialize(address _owner) external initializer {
        owner = _owner;
        cEth = ICETH(0xd6801a1DfFCd0a410336Ef88DeF4320D6DF1883e); 
        cDai = ICERC20(0x6D7F0754FFeb405d23C51CE938289d4835bE3b14);
        comptroller = IComptroller(0x2EAa9D77AE4D8f9cdD9FAAcd44016E746485bddb);
        // Here we take a last security approach. If the owner was already set, then revert.
        require(owner == address(0), "Owner already constructed");
        owner = _owner;
        emit Creation("New Creation", owner);
    }


    receive() external payable { }

    ///@notice supplyEthToCompund --> accepts ether and mints cEth.
    function supplyEthToCompound() external payable nonReentrant onlyOwner {
        cEth.mint{value: msg.value}();
        emit Log("New balance", msg.sender, msg.value);
    }

    ///@dev borrowFromCompund transfers the collateral asset to the protocol 
    ///and creates a borrow balance that begins accumulating interests based
    ///on the borrow rate. The amount borrowed must be less than the 
    ///user's collateral balance multiplied by the collateral factor * exchange rate
    function borrowFromCompound(uint _amount) external payable nonReentrant onlyOwner {
        //approx --> this is due to exchange rate issues in testnets
        //THIS IS ONLY FOR RINKEBY
        address[] memory cTokens = new address[](2);
        cTokens[0] = 0xd6801a1DfFCd0a410336Ef88DeF4320D6DF1883e;
        cTokens[1] = 0x6D7F0754FFeb405d23C51CE938289d4835bE3b14;
        uint[] memory errors = comptroller.enterMarkets(cTokens);
        if (errors[0] != 0) {
           revert("Comptroller.enterMarkets failed");
       }
       require(cDai.borrow(_amount) == 0, "Borrow Not Working");
    }

    ///@dev transfers the converted amount back to the sender. 
    // this transfer is in wei.
    // _amount = wei.
    function transferBack(uint _amount) private onlyOwner {
        (bool sent, ) = payable(owner).call{value:_amount}("");
        require(sent, "Transaction Failed");
        emit Log("Transfer succesfull", msg.sender, _amount);
    } 

    ///@dev Converts cEth to Eth. The _amount is in wei
    ///Eth goes back to this contract.
    function getEtherBack(uint _amount) external nonReentrant onlyOwner {
        require(cEth.redeemUnderlying(_amount) == 0, "ERROR");
        transferBack(_amount);
        emit Log("New CHECKOUT REQUESTED", msg.sender, _amount);
    }

    ///@dev repays the borrowed amount in dai
    ///@param _repayAmount = dai * 10 ^18
    function repayDebt(uint _repayAmount) external nonReentrant onlyOwner {
        IERC20 underlying = IERC20(0x5592EC0cfb4dbc12D3aB100b257153436a1f0FEa);
        underlying.approve(0x6D7F0754FFeb405d23C51CE938289d4835bE3b14, _repayAmount);
        require(cDai.repayBorrow(_repayAmount) == 0, "Error in repayBorrow()");
    }

   /////////////////////////////////////////////////////////////////////////////////////////////
   // SIMPLE UTIL FUNCTIONS THAT RETURN BASIC INFORMATION ABOUT THE HOLDINGS OF THIS CONTRACT 
   /////////////////////////////////////////////////////////////////////////////////////////////

   function returnEtherBalance() external view returns (uint) {
       return address(this).balance;
   }
   
   ///@notice returns the user's current borrow balance(with interest) in units 
   /// of the underlying asset (in this case: dai)
   function returnBorrowedBalance() external onlyOwner returns (uint) {
       return cDai.borrowBalanceCurrent(address(this));
   }
   
   ///@notice returns the user's underlying balance, representing the assets in the protocol, is equal to
   ///the uers's cToken balance multiplied by the Exchange Rate.
   function returnUnderlyingBalance() external onlyOwner returns (uint) {
       return cDai.balanceOfUnderlying(address(this));
   }
}









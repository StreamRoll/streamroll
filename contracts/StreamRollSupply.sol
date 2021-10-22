// SPDX-License-Identifier: GPL-3.0
pragma solidity >= 0.8.0 < 0.9.0;

/**
@author StreamRoll team:)
 */
interface CEth {
    function mint() external payable;
    function redeem(uint) external returns (uint);
    function totalBorrowsCurrent() external returns (uint);
    function totalReserve() external returns (uint);
    function totalSupply() external returns (uint);
}

/**
* @title StreamRollSupply
* @notice it accepts eth as collateral 
* and recieves cEth.. Everything happens inside the contract
 */
contract StreamRollSupply {
    /**
    * @dev cEth --> the contract's address for cEther on rinkeby
    * @dev exchangeRate --> NOT EXACT, the exchange rate function of 
    * compound does not work in rinkeby, that is why it is an approximation
    */
    address public _cEth = 0xd6801a1DfFCd0a410336Ef88DeF4320D6DF1883e;
    uint public exchangeRate;
    CEth cEth;

    event Log(string, uint);
    
    /**
    * @dev both mapping are to keep track of balances and authorize
    * transactions
     */
    mapping(address => uint) public balances;
    mapping(address => bool) public authorizations;

    /** 
    * @dev 32 is an approximation of the exchange rate in rinkeby
    * currently is 32.27... this is just for the example.
     */

    constructor() {
        cEth = CEth(_cEth); 
        exchangeRate = 32;
    }

    receive() external payable {}

    /**
    * @dev supplyEthToCompund --> accepts ether and mints cEth.
    * Everything stays inside our contract, behaving like a pool.
     */
    function supplyEthToCompound() public payable returns (bool) {
        cEth.mint{value: msg.value}();
        balances[msg.sender] += msg.value * exchangeRate;
        emit Log("New balance", msg.value * exchangeRate);
        return true;
    }

    /**
    * @dev Converts cEth to Eth.
     */
    function getEtherBack(uint _amount) public returns (bool) {
        require(balances[msg.sender] >= _amount, "Not enough funds");
        cEth.redeem(_amount);
        authorizations[msg.sender] = true;
        balances[msg.sender] -= _amount;
        return true;
    }

    function getBalance(address _requested) public view returns (uint) {
        return balances[_requested];
    }

    /**
    * @dev transfers the converted amount back to the sender. 
     */
    function transfer(uint amount, address payable _to) internal returns (bool) {
        require(authorizations[msg.sender] == true);
        _to.transfer(amount);
        authorizations[msg.sender] = false;
        return true;
    }
}








// SPDX-License-Identifier: GPL-3.0
pragma solidity >= 0.8.0 < 0.9.0;

/**
@author StreamRoll team:)
 */
interface CEth {
    function mint() external payable;
    function redeemUnderlying(uint redeemAmount) external returns (uint);
}

/**
* @title StreamRollSupply
* @notice it accepts eth as collateral and exchanges it for
* cEth.. Everything happens inside the contract, behaving like a pool.
 */
contract StreamRollSupply {
    /**
    * @dev cEth --> the contract's address for cEther on rinkeby
    */
    address public _cEth = 0xd6801a1DfFCd0a410336Ef88DeF4320D6DF1883e;
    CEth cEth;

    event Log(string, address, uint);
    
    /**
    * @dev To keep track of balances and authorize
    * transactions. balances = wei. wei = 1 eth * 10 ^18
    * checkout = wei. This is the redeemed amount ready to checkout
     */
    mapping(address => uint) public balances;
    mapping(address => uint) public checkout;

    constructor() {
        cEth = CEth(_cEth); 
    }

    receive() external payable {}

    /**
    * @dev supplyEthToCompund --> accepts ether and mints cEth.
    * Everything stays inside our contract, behaving like a pool.
     */
    function supplyEthToCompound() external payable returns (bool) {
        cEth.mint{value: msg.value}();
        balances[msg.sender] += msg.value;
        emit Log("New balance", msg.sender, msg.value);
        return true;
    }

    /**
    * @dev Converts cEth to Eth. The _amount is in wei
    * Eth goes back to this contract.
     */
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

    /**
    * @dev transfers the converted amount back to the sender. 
    * this transfer is in wei.
    * _amount = wei
     */
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
}











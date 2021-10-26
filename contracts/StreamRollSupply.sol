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

interface Comptroller {
    function markets(address) external returns (bool, uint256);

    function enterMarkets(address[] calldata)
        external
        returns (uint256[] memory);

    function getAccountLiquidity(address)
        external
        view
        returns (uint256, uint256, uint256);
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
    /**
    * @dev cEth --> the contract's address for cEther on rinkeby
    */
    address public _cEth = 0xd6801a1DfFCd0a410336Ef88DeF4320D6DF1883e;
    CEth cEth;

    event Log(string, address, uint);
    event MyLog(string, uint256);
    
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



    function borrowErc20Example(
        address payable _cEtherAddress,
        address _comptrollerAddress,
        address _priceFeedAddress,
        address _cTokenAddress,
        uint _underlyingDecimals
    ) public payable returns (uint256) {
        CEth cEth = CEth(_cEtherAddress);
        Comptroller comptroller = Comptroller(_comptrollerAddress);
        PriceFeed priceFeed = PriceFeed(_priceFeedAddress);
        CErc20 cToken = CErc20(_cTokenAddress);

        // Supply ETH as collateral, get cETH in return
        cEth.mint{value:msg.value}();

        // Enter the ETH market so you can borrow another type of asset
        address[] memory cTokens = new address[](1);
        cTokens[0] = _cEtherAddress;
        uint256[] memory errors = comptroller.enterMarkets(cTokens);
        if (errors[0] != 0) {
            revert("Comptroller.enterMarkets failed.");
        }

        // Get my account's total liquidity value in Compound
        (uint256 error, uint256 liquidity, uint256 shortfall) = comptroller
            .getAccountLiquidity(address(this));
        if (error != 0) {
            revert("Comptroller.getAccountLiquidity failed.");
        }
        require(shortfall == 0, "account underwater");
        require(liquidity > 0, "account has excess collateral");

        // Get the collateral factor for our collateral
        // (
        //   bool isListed,
        //   uint collateralFactorMantissa
        // ) = comptroller.markets(_cEthAddress);
        // emit MyLog('ETH Collateral Factor', collateralFactorMantissa);

        // Get the amount of underlying added to your borrow each block
        // uint borrowRateMantissa = cToken.borrowRatePerBlock();
        // emit MyLog('Current Borrow Rate', borrowRateMantissa);

        // Get the underlying price in USD from the Price Feed,
        // so we can find out the maximum amount of underlying we can borrow.
        uint256 underlyingPrice = priceFeed.getUnderlyingPrice(_cTokenAddress);
        uint256 maxBorrowUnderlying = liquidity / underlyingPrice;

        // Borrowing near the max amount will result
        // in your account being liquidated instantly
        emit MyLog("Maximum underlying Borrow (borrow far less!)", maxBorrowUnderlying);

        // Borrow underlying
        uint256 numUnderlyingToBorrow = 10;

        // Borrow, check the underlying balance for this contract's address
        cToken.borrow(numUnderlyingToBorrow * 10**_underlyingDecimals);

        // Get the borrow balance
        uint256 borrows = cToken.borrowBalanceCurrent(address(this));
        emit MyLog("Current underlying borrow amount", borrows);

        return borrows;
    }
}











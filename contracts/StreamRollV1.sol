// SPDX-License-Identifier: GPL-3.0
pragma solidity >= 0.8.0 < 0.9.0;

import './interfaces/ICERC20.sol';
import './interfaces/IERC20.sol';
import './interfaces/ICETH.sol';
import './interfaces/IComptroller.sol';

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

import {
    ISuperfluid,
    ISuperToken, //Superfluid token interface extension of ERC20
    ISuperApp, // Superfluid app interface
    ISuperAgreement, // Superfluid agreement interface
    ContextDefinitions,
    SuperAppDefinitions
} from "@superfluid-finance/ethereum-contracts/contracts/interfaces/superfluid/ISuperfluid.sol";
import { IConstantFlowAgreementV1 } from "@superfluid-finance/ethereum-contracts/contracts/interfaces/agreements/IConstantFlowAgreementV1.sol";

///@title StreamRollV1
///@notice StreamRollV1 is the base contract. Here, all the logic is kept.
///This contract is intended to be 1 contract -> 1 account. In order to do this, 
///we implemented the (EIP-1167) standard or "Minimal Proxy". There is a CloneFactory contract
///which deploys a "cheap version of this" making it an identical child. When the contract is called
///from the Factory, the msg.sender is sent as an argument for the initialize() function. This makes the
///creator of the identical child the unique owner of this contract.
///@author StreamRoll
contract StreamRollV1 is ReentrancyGuard, Initializable {
    
    // isBase ensures that this contract cannot be used, only if deployed from the CloneFactory.
    bool private isBase;
    address private owner;

    ///@dev Interfaces to interact with Compound and ERC20.
    ICETH cEth;
    ICERC20 cDai;
    IComptroller comptroller;
    ///@dev Superfluid contracts instances used for a distribution flow.
    ISuperfluid private _host;
    IConstantFlowAgreementV1 private _cfa;
    ISuperToken private _acceptedToken;

    event Log(string, address, uint);
    event Creation(string _message, address _owner);
    event NewFlow(address _sender, address _to, uint _amount, uint _days, uint _hours);
    event FlowUpdated(address _sender, address _to, uint _amount, uint _days, uint _hours);
    event FlowDeleted(address _sender, address _to, uint _amount, uint _days, uint _hours);

    modifier onlyOwner() {
        require(owner == msg.sender, "You are not authorized, only owner");
        
        _;
    }
    
    // This constructor ensures that this contract can only be used as a master copy for
    // proxy contracts. isBase = true, makes it impossible to use.
    constructor() {
        isBase = true;
    }

    receive() external payable { }

    ///@notice This function is called only once at deployment. It is initialized immediately once 
    ///it is deployed. 
    ///@dev We ensure that the function cannot be called again by the initializer modifier
    ///provided by OpenZeppelin plus additional security like require(owner == address(0)). 
    ///@param _owner the msg.sender of the CloneFactory.
    function initialize(address _owner) external initializer {
        require(isBase == false, "ERROR: Base contract cannot be callable, it is already initialized");
        require(owner == address(0), "ERROR: Owner not address (0), Contract already initialized");
        owner = _owner;
        isBase = true;
        cEth = ICETH(0xd6801a1DfFCd0a410336Ef88DeF4320D6DF1883e); 
        cDai = ICERC20(0x6D7F0754FFeb405d23C51CE938289d4835bE3b14);
        comptroller = IComptroller(0x2EAa9D77AE4D8f9cdD9FAAcd44016E746485bddb);
        _host = ISuperfluid(0xeD5B5b32110c3Ded02a07c8b8e97513FAfb883B6);
        _cfa = IConstantFlowAgreementV1(0xF4C5310E51F6079F601a5fb7120bC72a70b96e2A);
        _acceptedToken = ISuperToken(0x745861AeD1EEe363b4AaA5F1994Be40b1e05Ff90);
        IERC20(0x15F0Ca26781C3852f8166eD2ebce5D18265cceb7).approve(address(0x745861AeD1EEe363b4AaA5F1994Be40b1e05Ff90), 2**256 - 1);
        emit Creation("New creation: initialized", owner);
    }


    ///@notice Supplies Eth to compound and gets cEth (compound Eth) in return. cEth starts accumulating 
    ///interests immediately, and it is also useful and necessary to borrow dai or any other ERC20 token.
    function supplyEthToCompound() external payable nonReentrant onlyOwner {
        cEth.mint{value: msg.value}();
        emit Log("Supplied Balance", msg.sender, msg.value);
    }

    ///@notice borrowFromCompund transfers the collateral asset to the protocol 
    ///and creates a borrow balance that begins accumulating interests based
    ///on the borrow rate. The amount borrowed must be less than the 
    ///user's collateral balance multiplied by the collateral factor * exchange rate.
    ///@param _amount the amount to borrow (amount * 1e18)
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
       emit Log("Borrowed Balance", msg.sender, _amount);
    }

    ///@notice transfers the converted amount back to the sender (owner of this contract).
    ///@param _amount the amount to transfer back (_amount * 1e18)
    function transferBack(uint _amount) private onlyOwner {
        (bool sent, ) = payable(owner).call{value:_amount}("");
        require(sent, "Transaction Failed");
        emit Log("Transfered Back", msg.sender, _amount);
    } 

    ///@notice  Converts cEth back to eth.
    ///@param _amount the amount to convert.
    function getEtherBack(uint _amount) external nonReentrant onlyOwner {
        require(cEth.redeemUnderlying(_amount) == 0, "ERROR: redeemUnderlying failed");
        transferBack(_amount);
        emit Log("Get Ether Back", msg.sender, _amount);
    }

    ///@notice repays the borrowed amount in dai.
    ///@param _repayAmount dai * 1e18.
    function repayDebt(uint _repayAmount) external nonReentrant onlyOwner {
        IERC20 underlying = IERC20(0x5592EC0cfb4dbc12D3aB100b257153436a1f0FEa);
        underlying.approve(0x6D7F0754FFeb405d23C51CE938289d4835bE3b14, _repayAmount);
        require(cDai.repayBorrow(_repayAmount) == 0, "Error in repayBorrow()");
        emit Log("Repayed Debt", msg.sender, _repayAmount);
    }

    //////////////////////////////////////////////////////////////////////////////////////////
                    // SuperFluid Integration //
    ///@notice starts a new flow (or streaming).
    ///@param _to the receiver of the stream.
    ///@param _amount amount to transfer per x amount of _days.
    ///@param _days the days that the stream should last.
    ///@param _hours the hours that the stream should last.
    function _createFlow(address _to, uint _amount, uint _days, uint _hours) external onlyOwner {
        //if only days wanted, set _hours = 0
        //if only hours wanted, set _days = 0
        require(_days > 0 || _hours > 0);
        uint secondsPerDay = 86400;
        uint secondsPerHour = 3600;
        uint _flowRate;
        if (_days == 0) {
            uint totalSeconds = secondsPerHour * _hours;
            _flowRate = (_amount * 1e18) / totalSeconds;
        } else if (_hours == 0) {
            uint totalSeconds = secondsPerDay * _days;
            _flowRate = (_amount * 1e18) / totalSeconds;
        } else if (_days > 0 && _hours > 0){
            uint totalSeconds = (secondsPerDay * _days) + (secondsPerHour * _hours);
            _flowRate = (_amount * 1e18) / totalSeconds;
        }
        ISuperToken(0x745861AeD1EEe363b4AaA5F1994Be40b1e05Ff90).upgrade(uint(_amount * 1e18));
        _host.callAgreement(
            _cfa,
            abi.encodeWithSelector(
                _cfa.createFlow.selector, 
                _acceptedToken,
                _to,
                _flowRate,
                new bytes(0) // placeholder
            ),
            "0x"
        );
        emit NewFlow(msg.sender, _to, _amount, _days, _hours);
    }

    ///@notice updates a flow.
    ///@param _to the receiver of the stream.
    ///@param _amount amount to transfer per x amount of _days.
    ///@param _days the days that the stream should last.
    ///@param _hours the hours that the stream should last.
    function _updateFlow(address _to, uint _amount, uint _days, uint _hours) external onlyOwner {
        //if only days wanted, set _hours = 0
        //if only hours wanted, set _days = 0
        require(_days > 0 || _hours > 0);
        uint secondsPerDay = 86400;
        uint secondsPerHour = 3600;
        uint _flowRate;
        if (_days == 0) {
            uint totalSeconds = secondsPerHour * _hours;
            _flowRate = (_amount * 1e18) / totalSeconds;
        } else if (_hours == 0) {
            uint totalSeconds = secondsPerDay * _days;
            _flowRate = (_amount * 1e18) / totalSeconds;
        } else if (_days > 0 && _hours > 0){
            uint totalSeconds = (secondsPerDay * _days) + (secondsPerHour * _hours);
            _flowRate = (_amount * 1e18) / totalSeconds;
        }
        ISuperToken(0x745861AeD1EEe363b4AaA5F1994Be40b1e05Ff90).upgrade(uint(_amount * 1e18));
        _host.callAgreement(
            _cfa,
            abi.encodeWithSelector(
                _cfa.updateFlow.selector, 
                _acceptedToken,
                _to,
                _flowRate,
                new bytes(0) // placeholder
            ),
            "0x"
        );
        emit FlowUpdated(msg.sender, _to, _amount, _days, _hours);
    }

    ///@notice deletes a flow.
    ///@param _to the receiver of the stream.
    ///@param _amount amount to transfer per x amount of _days.
    ///@param _days the days that the stream should last.
    ///@param _hours the hours that the stream should last.
    function _deleteFlow(address _to, uint _amount, uint _days, uint _hours) external onlyOwner {
        //if only days wanted, set _hours = 0
        //if only hours wanted, set _days = 0
        require(_days > 0 || _hours > 0);
        uint secondsPerDay = 86400;
        uint secondsPerHour = 3600;
        uint _flowRate;
        if (_days == 0) {
            uint totalSeconds = secondsPerHour * _hours;
            _flowRate = (_amount * 1e18) / totalSeconds;
        }  else if (_hours == 0) {
            uint totalSeconds = secondsPerDay * _days;
            _flowRate = (_amount * 1e18) / totalSeconds;
        }  else if (_days > 0 && _hours > 0){
            uint totalSeconds = (secondsPerDay * _days) + (secondsPerHour * _hours);
            _flowRate = (_amount * 1e18) / totalSeconds;
        }
        ISuperToken(0x745861AeD1EEe363b4AaA5F1994Be40b1e05Ff90).upgrade(uint(_amount * 1e18));
        _host.callAgreement(
            _cfa,
            abi.encodeWithSelector(
                _cfa.deleteFlow.selector, 
                _acceptedToken,
                _to,
                _flowRate,
                new bytes(0) // placeholder
            ),
            "0x"
        );
        emit FlowDeleted(msg.sender, _to, _amount, _days, _hours);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >= 0.8.0 < 0.9.0;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "./StreamRollV1.sol";

///@title CloneFactory
///@notice The CloneFactory uses the minimal proxy standard (EIP-1167)
///to create copies of the base contract. The main advantages of using this standard
///are: 1. Cheaper deployment 2. Higher security on the base contract.
///@author Stream Roll 
contract CloneFactory {
    // the base contract (StreamRollV1.sol).
    address immutable base;
    
    // mapping to keep track of all the deployments.
    mapping(address => address[]) public allClones;

    // emits an event every time there is a new clone.
    event NewClone(address _clone, address _creator);

    // sets the base address. Once set, it is completely irreversible. 
    constructor(address _base) {
        base = _base;
    }

    ///@notice _clone() creates a new clone of the base address. 
    ///It also triggers the "initialize" function with the msg.sender as the argument.
    ///Initialize() can only be called once, this is the perfect time to call it. 
    ///The msg.sender is set as the owner in the base contract through the initialize call
    function _clone() external returns (address) {
        address payable identicalChild = payable(Clones.clone(base));
        allClones[msg.sender].push(identicalChild);
        emit NewClone(identicalChild, msg.sender);
        StreamRollV1(identicalChild).initialize(msg.sender);
        return identicalChild;
    }

    ///@notice function to return the clones that a given address has created.
    ///@param _requested the address on request.
    ///@return returns an array of the clone or clones that _requested has created.
    function returnClones(address _requested)
            external
            view
            returns (address[] memory)
    {
        return allClones[_requested];
    }
}


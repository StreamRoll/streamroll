// SPDX-License-Identifier: MIT
pragma solidity >= 0.8.0 < 0.9.0;


///@title Ownable.
///@dev Module to restrict access for the base contract.
contract Ownable {

    address private _owner;

    modifier onlyOwner() {
        require(owner() == msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function msgSender() internal view returns (address) {
        return msg.sender;
    }

    function msgData() internal pure returns (bytes calldata) {
        return msg.data;
    }

    function owner() public view returns (address) {
        return _owner;
    }
}





// SPDX-License-Identifier: MIT
pragma solidity >= 0.8.0 < 0.9.0;

contract StreamRoll {

    uint public num;

    function setNum(uint _num) public {
        num = _num;
    }

    function getNum() public view returns (uint) {
        return num;
    }

}
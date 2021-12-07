// SPDX-License-Identifier: GPL-3.0
pragma solidity >= 0.8.0 < 0.9.0;

/// @title IERC20 interface for StreamRoll
/// @notice Basic uses specifically for our cases.
interface IERC20 {
    
    function approve(address spender, uint amount) external returns (bool);

    function balanceOf(address tokenOwner) external returns (uint balance);

    function mint(address account, uint amount) external returns (bool);
}



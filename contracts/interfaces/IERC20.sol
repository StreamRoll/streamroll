// SPDX-License-Identifier: GPL-3.0
pragma solidity >= 0.8.0 < 0.9.0;

/// @title IERC20 interface for StreamRoll
/// @notice Basic uses specifically for our cases.
interface IERC20 {
    /// @notice Sets the allowance of a spender from the "msg.sender" to the value `amount`
    /// @param spender The account which will be allowed to spend a given amount of the owners tokens
    /// @param amount The amount of tokens allowed to be used by spender
    /// @return Returns true for a successful approval, false for unsuccessful
    function approve(address spender, uint amount) external returns (bool);
}



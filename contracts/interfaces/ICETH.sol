// SPDX-License-Identifier: GPL-3.0
pragma solidity >= 0.8.0 < 0.9.0;

/// @title ICETH interface for StreamRoll
/// @notice Basic uses specifically for our cases.
interface ICETH {
    function mint() external payable;
    function redeemUnderlying(uint redeemAmount) external returns (uint);
}


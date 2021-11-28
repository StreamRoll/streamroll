// SPDX-License-Identifier: GPL-3.0
pragma solidity >= 0.8.0 < 0.9.0;

/// @title ICERC20 interface for StreamRoll
/// @notice Basic uses specifically for our cases.
interface ICERC20 {
    
    function mint(uint256) external returns (uint256);

    function borrow(uint256) external returns (uint256);

    function borrowRatePerBlock() external view returns (uint256);

    function borrowBalanceCurrent(address) external returns (uint256);
    
    function repayBorrow(uint256) external returns (uint256);

    function balanceOfUnderlying(address account) external returns (uint);
}


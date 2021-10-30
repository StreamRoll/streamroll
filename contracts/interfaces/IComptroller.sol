// SPDX-License-Identifier: GPL-3.0
pragma solidity >= 0.8.0 < 0.9.0;

/// @title IComptroller interface for StreamRoll
/// @notice Basic uses specifically for our cases.
interface IComptroller {
    function markets(address) external returns (bool, uint256);

    function enterMarkets(address[] calldata cTokens)
        external
        returns (uint256[] memory);

    function getAccountLiquidity(address)
        external
        view
        returns (uint256, uint256, uint256);

    function getAssetsIn(address account) 
        external
        view
        returns (address[] memory);
}



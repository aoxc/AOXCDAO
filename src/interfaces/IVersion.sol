// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

/**
 * @title IVersion
 * @dev Tüm AOXC kontratları için standart versiyon arayüzü.
 */
interface IVersion {
    function getVersion() external view returns (string memory);
    function getMajorVersion() external view returns (uint256);
}

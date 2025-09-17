// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Multicall {
    function multicall(
        address[] calldata targets,
        bytes[] calldata data
    ) external returns (bytes[] memory results) {
        require(targets.length == data.length, "Array length mismatch");

        results = new bytes[](targets.length);

        for (uint256 i = 0; i < targets.length; i++) {
            (bool success, bytes memory returnData) = targets[i].call(data[i]);
            require(success, "Call failed");
            results[i] = returnData;
        }
    }
}

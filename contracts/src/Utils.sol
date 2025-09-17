// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Utils {
    function isSender(address addr) public view {
        require(msg.sender == addr, "Not authorized");
    }
}

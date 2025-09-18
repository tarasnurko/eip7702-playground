// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Utils {
    function isSender(address addr) public view {
        require(msg.sender == addr, "Not msg.sender");
    }

    function isTxOrigin(address addr) public view {
        require(tx.origin == addr, "Not tx.origin");
    }

    function isThis(address addr) public view {
        require(address(this) == addr, "Not address(this)");
    }
}

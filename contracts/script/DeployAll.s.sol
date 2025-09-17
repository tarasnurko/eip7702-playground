// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Counter} from "../src/Counter.sol";
import {MockERC20} from "../src/MockERC20.sol";
import {Multicall} from "../src/Multicall.sol";
import {Utils} from "../src/Utils.sol";

// forge script script/DeployAll.s.sol:DeployAllScript --rpc-url http://127.0.0.1:8545 --broadcast --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
contract DeployAllScript is Script {
    function run() public {
        vm.startBroadcast();

        Counter counter = new Counter();
        console.log("Counter deployed at:", address(counter));

        MockERC20 mockToken = new MockERC20();
        console.log("MockERC20 deployed at:", address(mockToken));

        Multicall multicall = new Multicall();
        console.log("Multicall deployed at:", address(multicall));

        Utils utils = new Utils();
        console.log("Utils deployed at:", address(utils));

        vm.stopBroadcast();
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Counter} from "../src/Counter.sol";
import {EIP7702Utils} from "@openzeppelin/contracts/account/utils/EIP7702Utils.sol";

/*
1) does delegation change state of contract, or of EoA?
2) when other user call delegated contract - does it change state of contract or of EoA?
3) when user call EoA which is delegated - does it execute contract with state of EoA or state of contract?
*/

/*
Delegator - actor (EoA) which gives authority
Delegatee - delegated contract, i.e. the contract whose code the EOA borrows 
*/
contract EIP7702CounterTest is Test {
    Counter public counter;

    uint256 constant ALICE_PK =
        0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
    uint256 constant BOB_PK =
        0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d;

    address public alice = vm.addr(ALICE_PK);
    address public bob = vm.addr(BOB_PK);

    function _assertCounterDelegatedToEOA(address eoa) private view {
        address delegate = EIP7702Utils.fetchDelegate(eoa);
        assertEq(delegate, address(counter));
    }

    /**
     * @notice assert that function code address is address(0) and codehash is empty
     */
    function _assertIsEOA(address eoa) private view {
        assertEq(eoa.codehash, bytes32(0));
        assertEq(eoa.code.length, 0);
    }

    function _assertIsNotEOA(address eoa) private view {
        assertNotEq(eoa.codehash, bytes32(0));
        assertNotEq(eoa.code.length, 0);
    }

    function setUp() public {
        counter = new Counter();
        counter.setNumber(0);
    }

    function test_Increment() public {
        counter.increment();
        assertEq(counter.number(), 1);
    }

    function test_eip7702DelegationIncrementEOA() public {
        _assertIsEOA(alice);

        vm.signAndAttachDelegation(address(counter), ALICE_PK);
        vm.prank(alice);
        Counter(address(alice)).increment();

        assertEq(counter.number(), 0);
        assertEq(Counter(address(alice)).number(), 1);

        _assertIsNotEOA(alice);

        _assertCounterDelegatedToEOA(alice);
    }
}

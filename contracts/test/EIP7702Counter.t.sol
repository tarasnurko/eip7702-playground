// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Counter} from "../src/Counter.sol";
import {EIP7702TestSetup} from "./EIP7702TestSetup.t.sol";
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
contract EIP7702CounterTest is EIP7702TestSetup {
    Counter public counter;

    function _assertCounterDelegatedToEOA(address eoa) private view {
        _assertDelegatedTo(eoa, address(counter));
    }

    function setUp() public {
        counter = new Counter();
        counter.setNumber(0);
    }

    function test_Increment() public {
        counter.increment();
        assertEq(counter.number(), 1);
    }

    function test_setDelegation() public {
        // EoA is just a regular EoA
        _assertIsEOA(alice);

        // Now EoA have pointer to Counter contract, and when iteracting with it it will execute code of Counter but with state of EoA - so storage of Counter doesnt change
        vm.signAndAttachDelegation(address(counter), ALICE_PK);
        vm.prank(alice);
        Counter(address(alice)).increment();

        assertEq(counter.number(), 0);
        assertEq(Counter(address(alice)).number(), 1);

        _assertIsNotEOA(alice);
        _assertCounterDelegatedToEOA(alice);
    }

    function test_removeDelegation() public {
        // set delegation
        vm.signAndAttachDelegation(address(counter), ALICE_PK);

        _assertIsNotEOA(alice);
        _assertCounterDelegatedToEOA(alice);

        // remove delegation
        vm.signAndAttachDelegation(address(0), ALICE_PK);

        // after removing delegation, EoA is just a regular EoA
        _assertIsEOA(alice);

        // trying to call increment on alice should succeed but not change any state
        (bool success, ) = address(alice).call(
            abi.encodeWithSignature("increment()")
        );
        assertTrue(success, "Call should succeed but do nothing");

        // verify that no state changed - counter should still be 0
        assertEq(counter.number(), 0);
    }

    function test_anyoneCanCallDelegatedEOA() public {
        vm.signAndAttachDelegation(address(counter), ALICE_PK);

        // any user can interact with delegated EoA as if it was a contract and it changes state of delegated EoA
        vm.prank(bob);
        Counter(address(alice)).increment();

        assertEq(counter.number(), 0);
        assertEq(Counter(address(alice)).number(), 1);
    }
}

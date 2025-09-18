// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Utils} from "../src/Utils.sol";
import {EIP7702TestSetup} from "./EIP7702TestSetup.t.sol";
import {EIP7702Utils} from "@openzeppelin/contracts/account/utils/EIP7702Utils.sol";

contract EIP7702UtilsTest is EIP7702TestSetup {
    Utils public utils;

    function _assertUtilsDelegatedToEOA(address eoa) private view {
        _assertDelegatedTo(eoa, address(utils));
    }

    function setUp() public {
        utils = new Utils();
    }

    function test_eip7702_msgSenderIsDelegatorWhenDelegatorCallsOwnDelegatedEoA()
        public
    {
        vm.signAndAttachDelegation(address(utils), ALICE_PK);
        _assertUtilsDelegatedToEOA(alice);

        vm.prank(alice);
        Utils(address(alice)).isSender(alice);
    }

    function test_eip7702_msgSenderIsCallerWhenThirdPartyCallsDelegatedEoA()
        public
    {
        vm.signAndAttachDelegation(address(utils), ALICE_PK);
        _assertUtilsDelegatedToEOA(alice);

        vm.prank(bob);
        Utils(address(alice)).isSender(bob);
    }

    function test_eip7702_txOriginIsDelegatorWhenDelegatorCallsOwnDelegatedEoA()
        public
    {
        vm.signAndAttachDelegation(address(utils), ALICE_PK);
        _assertUtilsDelegatedToEOA(alice);

        vm.prank(alice, alice);
        Utils(address(alice)).isTxOrigin(alice);
    }

    function test_eip7702_txOriginIsCallerWhenThirdPartyCallsDelegatedEoA()
        public
    {
        vm.signAndAttachDelegation(address(utils), ALICE_PK);
        _assertUtilsDelegatedToEOA(alice);

        vm.prank(bob, bob);
        Utils(address(alice)).isTxOrigin(bob);
    }

    function test_eip7702_executionContextPreservationInDelegatedCall() public {
        vm.signAndAttachDelegation(address(utils), ALICE_PK);

        vm.startPrank(bob, bob);

        Utils(address(alice)).isSender(bob);
        Utils(address(alice)).isTxOrigin(bob);

        vm.stopPrank();
    }

    function test_eip7702_addressThisIsDelegatedEoAWhenCalledDirectly() public {
        vm.signAndAttachDelegation(address(utils), ALICE_PK);
        _assertUtilsDelegatedToEOA(alice);

        vm.prank(alice, alice);
        Utils(address(alice)).isThis(alice);
    }

    function test_eip7702_addressThisIsDelegatedEoAWhenCalledByThirdParty() public {
        vm.signAndAttachDelegation(address(utils), ALICE_PK);
        _assertUtilsDelegatedToEOA(alice);

        vm.prank(bob, bob);
        Utils(address(alice)).isThis(alice);
    }
}

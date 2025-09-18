// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {console} from "forge-std/console.sol";
import {Utils} from "../src/Utils.sol";
import {Multicall} from "../src/Multicall.sol";
import {MockERC20} from "../src/MockERC20.sol";
import {EIP7702TestSetup} from "./EIP7702TestSetup.t.sol";
import {EIP7702Utils} from "@openzeppelin/contracts/account/utils/EIP7702Utils.sol";

contract EIP7702MulticallTest is EIP7702TestSetup {
    Utils public utils;
    Multicall public multicall;
    MockERC20 public tokenA;
    MockERC20 public tokenB;

    uint256 constant INITIAL_BALANCE = 1000e18;

    function _assertMulticallDelegatedToEOA(address eoa) private view {
        _assertDelegatedTo(eoa, address(multicall));
    }

    function setUp() public {
        utils = new Utils();
        multicall = new Multicall();
        tokenA = new MockERC20();
        tokenB = new MockERC20();

        tokenA.mint(alice, INITIAL_BALANCE);
        tokenB.mint(alice, INITIAL_BALANCE);
    }

    function test_eip7702_msgSenderIsDelegatedEoAWhenMulticallCallsUtils()
        public
    {
        // when delegatee (contract) calls other contract, msg.sender would be delegator (EoA)

        vm.signAndAttachDelegation(address(multicall), ALICE_PK);
        _assertMulticallDelegatedToEOA(alice);

        address[] memory targets = new address[](1);
        bytes[] memory data = new bytes[](1);
        targets[0] = address(utils);
        data[0] = abi.encodeWithSignature("isSender(address)", alice);

        vm.prank(alice, alice);
        Multicall(address(alice)).multicall(targets, data);
    }

    function test_eip7702_txOriginIsCallerWhenMulticallCallsUtils() public {
        // tx.origin is always EoA

        vm.signAndAttachDelegation(address(multicall), ALICE_PK);
        _assertMulticallDelegatedToEOA(alice);

        address[] memory targets = new address[](1);
        bytes[] memory data = new bytes[](1);
        targets[0] = address(utils);
        data[0] = abi.encodeWithSignature("isTxOrigin(address)", alice);

        vm.prank(alice, alice);
        Multicall(address(alice)).multicall(targets, data);
    }

    function test_eip7702_thirdPartyCallsDelegatedEoAMulticall() public {
        // when other actor (Bob) (EoA) calls delegator (Alice) (EoA) that have delegated Contract, msg.sender when delegated Contract calls other contract would be the Delegator (Alice) (EoA)

        vm.signAndAttachDelegation(address(multicall), ALICE_PK);

        address[] memory targets = new address[](1);
        bytes[] memory data = new bytes[](1);
        targets[0] = address(utils);
        data[0] = abi.encodeWithSignature("isSender(address)", alice);

        vm.prank(bob, bob);
        Multicall(address(alice)).multicall(targets, data);
    }

    function test_eip7702_multicallBatchUtilsCalls() public {
        vm.signAndAttachDelegation(address(multicall), ALICE_PK);

        address[] memory targets = new address[](2);
        bytes[] memory data = new bytes[](2);
        targets[0] = address(utils);
        targets[1] = address(utils);
        data[0] = abi.encodeWithSignature("isSender(address)", alice);
        data[1] = abi.encodeWithSignature("isTxOrigin(address)", alice);

        vm.prank(alice, alice);
        Multicall(address(alice)).multicall(targets, data);
    }

    function test_eip7702_multicallUtilsFailsWithWrongSender() public {
        vm.signAndAttachDelegation(address(multicall), ALICE_PK);

        address[] memory targets = new address[](1);
        bytes[] memory data = new bytes[](1);
        targets[0] = address(utils);
        data[0] = abi.encodeWithSignature("isSender(address)", bob);

        vm.prank(alice, alice);
        vm.expectRevert("Not msg.sender");
        Multicall(address(alice)).multicall(targets, data);
    }

    function test_eip7702_thirdPartyTxOriginThroughMulticall() public {
        // tx.origin is always EoA that initialized transaction

        vm.signAndAttachDelegation(address(multicall), ALICE_PK);

        address[] memory targets = new address[](1);
        bytes[] memory data = new bytes[](1);
        targets[0] = address(utils);
        data[0] = abi.encodeWithSignature("isTxOrigin(address)", bob);

        vm.prank(bob, bob);
        Multicall(address(alice)).multicall(targets, data);
    }

    function test_eip7702_aliceBatchApprovesMultipleTokensViaMulticall()
        public
    {
        vm.signAndAttachDelegation(address(multicall), ALICE_PK);

        address[] memory targets = new address[](2);
        bytes[] memory data = new bytes[](2);
        targets[0] = address(tokenA);
        targets[1] = address(tokenB);
        data[0] = abi.encodeWithSignature(
            "approve(address,uint256)",
            bob,
            100e18
        );
        data[1] = abi.encodeWithSignature(
            "approve(address,uint256)",
            bob,
            200e18
        );

        vm.prank(alice, alice);
        Multicall(address(alice)).multicall(targets, data);

        assertEq(tokenA.allowance(alice, bob), 100e18);
        assertEq(tokenB.allowance(alice, bob), 200e18);
    }

    function test_eip7702_aliceBatchTransfersMultipleTokensViaMulticall()
        public
    {
        vm.signAndAttachDelegation(address(multicall), ALICE_PK);

        address[] memory targets = new address[](2);
        bytes[] memory data = new bytes[](2);
        targets[0] = address(tokenA);
        targets[1] = address(tokenB);
        data[0] = abi.encodeWithSignature(
            "transfer(address,uint256)",
            bob,
            50e18
        );
        data[1] = abi.encodeWithSignature(
            "transfer(address,uint256)",
            charlie,
            75e18
        );

        vm.prank(alice, alice);
        Multicall(address(alice)).multicall(targets, data);

        assertEq(tokenA.balanceOf(bob), 50e18);
        assertEq(tokenB.balanceOf(charlie), 75e18);
        assertEq(tokenA.balanceOf(alice), INITIAL_BALANCE - 50e18);
        assertEq(tokenB.balanceOf(alice), INITIAL_BALANCE - 75e18);
    }

    function test_eip7702_bobApprovesAliceTokensWithoutPermission() public {
        vm.signAndAttachDelegation(address(multicall), ALICE_PK);

        address[] memory targets = new address[](2);
        bytes[] memory data = new bytes[](2);
        targets[0] = address(tokenA);
        targets[1] = address(tokenB);
        data[0] = abi.encodeWithSignature(
            "approve(address,uint256)",
            bob,
            500e18
        );
        data[1] = abi.encodeWithSignature(
            "approve(address,uint256)",
            charlie,
            300e18
        );

        vm.prank(bob, bob);
        Multicall(address(alice)).multicall(targets, data);

        assertEq(tokenA.allowance(alice, bob), 500e18);
        assertEq(tokenB.allowance(alice, charlie), 300e18);
    }

    function test_eip7702_bobTransfersAliceTokensWithoutPermission() public {
        vm.signAndAttachDelegation(address(multicall), ALICE_PK);

        address[] memory targets = new address[](2);
        bytes[] memory data = new bytes[](2);
        targets[0] = address(tokenA);
        targets[1] = address(tokenB);
        data[0] = abi.encodeWithSignature(
            "transfer(address,uint256)",
            bob,
            200e18
        );
        data[1] = abi.encodeWithSignature(
            "transfer(address,uint256)",
            bob,
            150e18
        );

        vm.prank(bob, bob);
        Multicall(address(alice)).multicall(targets, data);

        assertEq(tokenA.balanceOf(bob), 200e18);
        assertEq(tokenB.balanceOf(bob), 150e18);
        assertEq(tokenA.balanceOf(alice), INITIAL_BALANCE - 200e18);
        assertEq(tokenB.balanceOf(alice), INITIAL_BALANCE - 150e18);
    }

    function test_eip7702_aliceRemovesDelegationToStopUnauthorizedUse() public {
        vm.signAndAttachDelegation(address(multicall), ALICE_PK);

        vm.signAndAttachDelegation(address(0), ALICE_PK);
        _assertDelegationRemoved(alice);

        address[] memory targets = new address[](1);
        bytes[] memory data = new bytes[](1);
        targets[0] = address(tokenA);
        data[0] = abi.encodeWithSignature(
            "transfer(address,uint256)",
            bob,
            100e18
        );

        vm.prank(bob, bob);
        (bool success, ) = address(alice).call(
            abi.encodeWithSignature(
                "multicall(address[],bytes[])",
                targets,
                data
            )
        );
        assertTrue(success);

        assertEq(tokenA.balanceOf(bob), 0);
        assertEq(tokenA.balanceOf(alice), INITIAL_BALANCE);
    }

    function test_eip7702_partialFailureInTokenBatch() public {
        vm.signAndAttachDelegation(address(multicall), ALICE_PK);

        address[] memory targets = new address[](2);
        bytes[] memory data = new bytes[](2);
        targets[0] = address(tokenA);
        targets[1] = address(tokenB);
        data[0] = abi.encodeWithSignature(
            "transfer(address,uint256)",
            bob,
            100e18
        );
        data[1] = abi.encodeWithSignature(
            "transfer(address,uint256)",
            bob,
            INITIAL_BALANCE + 1
        );

        vm.prank(alice, alice);
        vm.expectRevert();
        Multicall(address(alice)).multicall(targets, data);

        assertEq(tokenA.balanceOf(bob), 0);
        assertEq(tokenB.balanceOf(bob), 0);
    }

    function test_eip7702_delegatedEoACanExecuteEtherTransfer() public {
        vm.deal(alice, 10 ether);
        vm.signAndAttachDelegation(address(multicall), ALICE_PK);

        uint256 bobBalanceBefore = bob.balance;
        uint256 aliceBalanceBefore = alice.balance;

        vm.prank(alice, alice);
        (bool success, ) = address(bob).call{value: 1 ether}("");
        assertTrue(success);

        assertEq(bob.balance, bobBalanceBefore + 1 ether);
        assertEq(alice.balance, aliceBalanceBefore - 1 ether);
    }

    function test_eip7702_delegatedEoACanExecuteTokenTransfer() public {
        MockERC20 token = new MockERC20();
        token.mint(alice, 1000e18);

        vm.signAndAttachDelegation(address(multicall), ALICE_PK);

        vm.prank(alice, alice);
        (bool success, ) = address(token).call(
            abi.encodeWithSignature("transfer(address,uint256)", bob, 200e18)
        );
        assertTrue(success);

        assertEq(token.balanceOf(bob), 200e18);
        assertEq(token.balanceOf(alice), 800e18);
    }
}

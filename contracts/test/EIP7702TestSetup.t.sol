// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {EIP7702Utils} from "@openzeppelin/contracts/account/utils/EIP7702Utils.sol";

contract EIP7702TestSetup is Test {
    uint256 constant ALICE_PK =
        0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
    uint256 constant BOB_PK =
        0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d;
    uint256 constant CHARLIE_PK =
        0x5de4111afa1a4b94908f83103eb1f1706367c2e68ca870fc3fb9a804cdab365a;

    address public alice = vm.addr(ALICE_PK);
    address public bob = vm.addr(BOB_PK);
    address public charlie = vm.addr(CHARLIE_PK);

    function _assertDelegatedTo(
        address eoa,
        address delegatedContract
    ) internal view {
        address delegate = EIP7702Utils.fetchDelegate(eoa);
        assertEq(delegate, delegatedContract);
    }

    function _assertIsEOA(address eoa) internal view {
        assertEq(eoa.codehash, bytes32(0));
        assertEq(eoa.code.length, 0);
    }

    function _assertIsNotEOA(address eoa) internal view {
        assertNotEq(eoa.codehash, bytes32(0));
        assertNotEq(eoa.code.length, 0);
    }

    function _assertDelegationRemoved(address eoa) internal view {
        address delegate = EIP7702Utils.fetchDelegate(eoa);
        assertEq(delegate, address(0));
    }

    function _expectSuccessfulCall(
        address target,
        bytes memory data
    ) internal returns (bytes memory) {
        (bool success, bytes memory returnData) = target.call(data);
        assertTrue(success);
        return returnData;
    }

    function _expectFailedCall(
        address target,
        bytes memory data,
        string memory expectedRevertReason
    ) internal {
        (bool success, bytes memory returnData) = target.call(data);
        assertFalse(success);

        if (bytes(expectedRevertReason).length > 0) {
            string memory actualReason = abi.decode(returnData, (string));
            assertEq(actualReason, expectedRevertReason);
        }
    }
}

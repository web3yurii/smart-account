// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {SmartAccountFactory, SmartAccount} from "../src/SmartAccount.sol";
import {EntryPoint} from "account-abstraction/core/EntryPoint.sol";
import {PackedUserOperation} from "account-abstraction/interfaces/PackedUserOperation.sol";
import {CommonBase} from "forge-std/Base.sol";
import {Script} from "forge-std/Script.sol";
import {StdChains} from "forge-std/StdChains.sol";
import {StdCheatsSafe} from "forge-std/StdCheats.sol";
import {StdUtils} from "forge-std/StdUtils.sol";
import {console} from "forge-std/console.sol";

contract ExecuteScript is Script {
    address private constant EP_ADDRESS = 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512;
    address private constant FACTORY_ADDRESS = 0x5FbDB2315678afecb367f032d93F642f64180aa3;
    address private constant SIGNER = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;

    function setUp() public {}

    function run() public {
        EntryPoint entrypoint = EntryPoint(payable(EP_ADDRESS));

        bytes memory data = abi.encodeWithSelector(SmartAccountFactory.createAccount.selector, payable(SIGNER));
        bytes memory initCode = abi.encodePacked(FACTORY_ADDRESS, data);
        (bool success, bytes memory revertData) =
            EP_ADDRESS.call(abi.encodeWithSelector(EntryPoint.getSenderAddress.selector, initCode));
        require(!success, "Expected revert");

        // Check selector
        bytes4 expectedSelector = bytes4(keccak256("SenderAddressResult(address)"));
        bytes4 actualSelector;
        assembly {
            actualSelector := mload(add(revertData, 32))
        }
        require(actualSelector == expectedSelector, "Unexpected error selector");

        // Decode address using inline assembly
        address sender;
        assembly {
            sender := mload(add(revertData, 36)) // Skip 4 bytes selector
        }

        PackedUserOperation memory userOp = PackedUserOperation({
            sender: sender,
            nonce: entrypoint.getNonce(sender, 0),
            initCode: initCode,
            callData: abi.encodeWithSelector(SmartAccount.execute.selector),
            accountGasLimits: bytes32(abi.encodePacked(uint128(200_000), uint128(100_000))),
            preVerificationGas: 0,
            gasFees: bytes32(abi.encodePacked(uint128(1 gwei), uint128(2 gwei))),
            paymasterAndData: "",
            signature: ""
        });

        PackedUserOperation[] memory userOps = new PackedUserOperation[](1);
        userOps[0] = userOp;

        vm.startBroadcast();

        // Prefund the entrypoint
        entrypoint.depositTo{value: 100 ether}(sender);

        //        // Handle the user operation
        entrypoint.handleOps(userOps, payable(SIGNER));

        vm.stopBroadcast();
    }
}

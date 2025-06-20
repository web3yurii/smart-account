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
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

contract ExecuteScript is Script {
    using MessageHashUtils for bytes32;

    address private constant FACTORY_ADDRESS = 0x5FbDB2315678afecb367f032d93F642f64180aa3;
    address private constant ENTRYPOINT_ADDRESS = 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512;
    address private constant PAYMASTER_ADDRESS = 0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0;

    uint256 private constant PRIVATE_KEY = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
    address private constant SIGNER = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;

    EntryPoint private entrypoint = EntryPoint(payable(ENTRYPOINT_ADDRESS));

    function setUp() public {}

    function run() public {
        bytes memory data = abi.encodeWithSelector(SmartAccountFactory.createAccount.selector, payable(SIGNER));
        bytes memory initCode = abi.encodePacked(FACTORY_ADDRESS, data);
        address sender = getSenderAddress(initCode);

        PackedUserOperation memory userOp = PackedUserOperation({
            sender: sender,
            nonce: entrypoint.getNonce(sender, 0),
            initCode: initCode,
            callData: abi.encodeWithSelector(SmartAccount.execute.selector),
            accountGasLimits: bytes32(abi.encodePacked(uint128(1_200_000), uint128(50_000))),
            preVerificationGas: 0,
            gasFees: bytes32(abi.encodePacked(uint128(1 gwei), uint128(2 gwei))),
            paymasterAndData: abi.encodePacked(PAYMASTER_ADDRESS, uint128(200_000), uint128(50_000), bytes32(0)), // data is omitted for simplicity
            signature: new bytes(0)
        });

        userOp.signature = getSignature(userOp);

        PackedUserOperation[] memory userOps = new PackedUserOperation[](1);
        userOps[0] = userOp;

        vm.startBroadcast();

        // Prefund the entrypoint
        entrypoint.depositTo{value: 100 ether}(PAYMASTER_ADDRESS);

        // Handle the user operation
        entrypoint.handleOps(userOps, payable(SIGNER));

        vm.stopBroadcast();
    }

    function getSenderAddress(bytes memory initCode) private returns (address sender) {
        (bool success, bytes memory revertData) =
            ENTRYPOINT_ADDRESS.call(abi.encodeWithSelector(EntryPoint.getSenderAddress.selector, initCode));
        require(!success, "Expected revert");

        // Check selector
        bytes4 expectedSelector = bytes4(keccak256("SenderAddressResult(address)"));
        bytes4 actualSelector;
        assembly {
            actualSelector := mload(add(revertData, 32))
        }
        require(actualSelector == expectedSelector, "Unexpected error selector");

        // Decode address using inline assembly
        assembly {
            sender := mload(add(revertData, 36)) // Skip 4 bytes selector
        }
    }

    function getSignature(PackedUserOperation memory userOp) private view returns (bytes memory signature) {
        bytes32 userOpHash = entrypoint.getUserOpHash(userOp);
        bytes32 signedHash = userOpHash.toEthSignedMessageHash();
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(PRIVATE_KEY, signedHash);
        return abi.encodePacked(r, s, v);
    }
}

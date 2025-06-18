// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {EntryPoint, AccountFactory, SmartAccount} from "../src/Account.sol";
import {PackedUserOperation} from "account-abstraction/interfaces/PackedUserOperation.sol";

contract ExecuteScript is Script {
    address payable private constant EP_ADDRESS = payable(0x9A676e781A523b5d0C0e43731313A708CB607508);
    address private constant FACTORY_ADDRESS = 0x0DCd1Bf9A1b36cE34237eEaFef220932846BCD82;
    uint256 private constant FACTORY_NONCE = 1;

    function setUp() public {}

    function run() public {
        address payable signer0 = payable(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);

        EntryPoint entrypoint = EntryPoint(EP_ADDRESS);

        // CREATE: hash(deployer + nonce) - use now for simplicity

        // cast compute-address 0x0DCd1Bf9A1b36cE34237eEaFef220932846BCD82 --nonce 1
        address senderAddress = 0x32467b43BFa67273FC7dDda0999Ee9A12F2AaA08;

        // CREATE2: hash(deployer + nonce + initCode + salt)

        bytes memory data = abi.encodeWithSelector(AccountFactory.createAccount.selector, signer0);

        PackedUserOperation memory userOp = PackedUserOperation({
            sender: senderAddress,
            nonce: entrypoint.getNonce(senderAddress, 0),
            initCode: abi.encodePacked(FACTORY_ADDRESS, data),
            callData: abi.encodeWithSelector(SmartAccount.execute.selector),
            accountGasLimits: bytes32(abi.encodePacked(uint128(5_200_000), uint128(5_200_000))),
            preVerificationGas: 500_000,
            gasFees: bytes32(abi.encodePacked(uint128(20 gwei), uint128(10 gwei))),
            paymasterAndData: "",
            signature: ""
        });

        PackedUserOperation[] memory userOps = new PackedUserOperation[](1);
        userOps[0] = userOp;

        vm.startBroadcast();

        // Prefund the entrypoint
        //        entrypoint.depositTo{value: 10 ether}(senderAddress);

        // Handle the user operation
        entrypoint.handleOps(userOps, payable(address(0x326794fBB97ed389B2b1F6eF39006CB08ED89046)));

        vm.stopBroadcast();
    }

    receive() external payable {
        console.log("Received %s wei", msg.value);
    }
}

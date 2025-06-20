// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {EntryPoint, SmartAccountFactory} from "../src/SmartAccount.sol";
import {Paymaster} from "../src/Paymaster.sol";

contract DeployScript is Script {
    EntryPoint public entrypoint;
    SmartAccountFactory public factory;
    Paymaster public paymaster;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        factory = new SmartAccountFactory();
        console.log("SmartAccountFactory deployed at:", address(factory));

        entrypoint = new EntryPoint();
        console.log("EntryPoint deployed at:", address(entrypoint));

        paymaster = new Paymaster();
        console.log("Paymaster deployed at:", address(paymaster));

        vm.stopBroadcast();
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {SmartAccountFactory} from "../src/SmartAccount.sol";

contract SmartAccountFactoryScript is Script {
    SmartAccountFactory public smartAccountFactory;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        smartAccountFactory = new SmartAccountFactory();

        vm.stopBroadcast();
    }
}

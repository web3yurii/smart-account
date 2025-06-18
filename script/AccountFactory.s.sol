// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {EntryPoint} from "../src/Account.sol";

contract AccountScript is Script {
    EntryPoint public entrypoint;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        entrypoint = new EntryPoint();

        vm.stopBroadcast();
    }
}

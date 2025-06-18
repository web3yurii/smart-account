// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {AccountFactory} from "../src/Account.sol";

contract AccountFactoryScript is Script {
    AccountFactory public accountFactory;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        accountFactory = new AccountFactory();

        vm.stopBroadcast();
    }
}

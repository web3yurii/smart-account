// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {SmartAccount} from "../../src/SmartAccount.sol";
import {Paymaster} from "../../src/Paymaster.sol";
import {EntryPoint} from "account-abstraction/core/EntryPoint.sol";

contract SmartAccountTest is Test {
    SmartAccount private smartAccount;
    Paymaster private paymaster;
    EntryPoint private entrypoint;

    function setUp() public {
        smartAccount = SmartAccount(0xa16E02E87b7454126E5E10d957A927A7F5B5d2be);
        paymaster = Paymaster(0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0);
        entrypoint = EntryPoint(payable(0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512));
    }

    function testSmartAccountCounter() public view {
        uint256 count = smartAccount.count();
        console.log("SmartAccount count:", count);
        assertEq(count, 1, "Initial count should be 1");
    }

    function testBalances() public view {
        uint256 accountBalance = address(smartAccount).balance;
        console.log("SmartAccount balance:", accountBalance);
        assertEq(accountBalance, 0, "SmartAccount should have zer, gas is payed by the Paymaster");

        uint256 accountBalanceEP = entrypoint.balanceOf(address(smartAccount));
        console.log("SmartAccount balance in EntryPoint:", accountBalanceEP);
        assertEq(accountBalanceEP, 0, "SmartAccount should have zero balance, gas is payed by the Paymaster");

        uint256 paymasterBalance = address(paymaster).balance;
        console.log("Paymaster balance:", paymasterBalance);
        assertEq(paymasterBalance, 0, "Paymaster should not have balance itself, it should be funded by the EntryPoint");

        uint256 paymasterBalanceEP = entrypoint.balanceOf(address(paymaster));
        console.log("Paymaster balance in EntryPoint:", paymasterBalanceEP);
        assertGt(paymasterBalanceEP, 0, "Paymaster should have a positive balance to pay for gas");
    }
}

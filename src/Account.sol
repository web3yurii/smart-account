// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {EntryPoint} from "account-abstraction/core/EntryPoint.sol";
import {IAccount} from "account-abstraction/interfaces/IAccount.sol";

contract Account is IAccount {
    EntryPoint public entryPoint;

    uint public count;

    constructor(address _entryPoint) {
        entryPoint = EntryPoint(_entryPoint);
    }

    function validateUserOp(PackedUserOperation calldata userOp, bytes32 userOpHash, uint256 missingAccountFunds)
        external
        override
        returns (uint256 validationData)
    {
        // Implement your validation logic here
        // For now, we return a dummy value
        return 0; // Replace with actual validation logic
    }

    function execute() external {
        count++;
    }
}

contract AccountFactory {
    function createAccount(address owner) external returns (address) {
        Account account = new Account(owner);
        return account;
    }
}

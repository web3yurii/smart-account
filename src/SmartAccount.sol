// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {EntryPoint} from "account-abstraction/core/EntryPoint.sol";
import {IAccount} from "account-abstraction/interfaces/IAccount.sol";
import {PackedUserOperation} from "account-abstraction/interfaces/PackedUserOperation.sol";

contract SmartAccount is IAccount {
    address private owner;

    uint256 public count;

    constructor(address _owner) {
        owner = _owner;
    }

    function validateUserOp(PackedUserOperation calldata, bytes32, uint256)
        external
        pure
        override
        returns (uint256 validationData)
    {
        return 0; // Replace with actual validation logic
    }

    function execute() external {
        count++;
    }
}

contract SmartAccountFactory {
    function createAccount(address owner) external returns (address) {
        SmartAccount account = new SmartAccount(owner);
        return address(account);
    }
}

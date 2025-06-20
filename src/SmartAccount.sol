// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.13;

import {EntryPoint} from "account-abstraction/core/EntryPoint.sol";
import {IAccount} from "account-abstraction/interfaces/IAccount.sol";
import {PackedUserOperation} from "account-abstraction/interfaces/PackedUserOperation.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

contract SmartAccount is IAccount {
    address private owner;

    uint256 public count;

    constructor(address _owner) {
        owner = _owner;
    }

    function validateUserOp(PackedUserOperation calldata userOp, bytes32 userOpHash, uint256)
        external
        view
        override
        returns (uint256 validationData)
    {
        bytes32 signedHash = MessageHashUtils.toEthSignedMessageHash(userOpHash);
        address recovered = ECDSA.recover(signedHash, userOp.signature);

        return owner == recovered ? 0 : 1; // Replace with actual validation logic
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

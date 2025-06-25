// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.13;

import {EntryPoint} from "account-abstraction/core/EntryPoint.sol";
import {IAccount} from "account-abstraction/interfaces/IAccount.sol";
import {PackedUserOperation} from "account-abstraction/interfaces/PackedUserOperation.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import {Create2} from "@openzeppelin/contracts/utils/Create2.sol";

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
        // CREATE
//        SmartAccount account = new SmartAccount(owner);
//        return address(account);

        // CREATE 2
        // amount, salt, bytecode
        bytes32 salt = bytes32(uint256(uint160(owner))); // Use the owner's address as salt
        bytes memory bytecode = abi.encodePacked(type(SmartAccount).creationCode, abi.encode(owner));

        address addr = Create2.computeAddress(salt, keccak256(bytecode));
        if (addr.code.length > 0) {
            return addr; // Account already exists
        }

        return Create2.deploy(0, salt, bytecode);

    }
}

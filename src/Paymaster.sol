// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.13;

import {EntryPoint} from "account-abstraction/core/EntryPoint.sol";
import {IPaymaster} from "account-abstraction/interfaces/IPaymaster.sol";
import {PackedUserOperation} from "account-abstraction/interfaces/PackedUserOperation.sol";

contract Paymaster is IPaymaster {
    function validatePaymasterUserOp(PackedUserOperation calldata, bytes32, uint256)
        external
        pure
        override
        returns (bytes memory context, uint256 validationData)
    {
        return ("", 0); // Replace with actual validation logic
    }

    function postOp(PostOpMode, bytes calldata, uint256, uint256) external override {}
}

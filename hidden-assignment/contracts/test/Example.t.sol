// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import { Transaction, Operation, PublicInput } from "@gribi/evm-rootsystem/Structs.sol";
import {Example} from "../src/Example.sol";

contract ExampleTest is Test {
    Example public example;

    function setUp() public {
        example = new Example();
    }

    function test_CreateCommitment() public {
        uint256 salt = 1;
        uint256 secret = 2;
        uint256 commitment = uint256(keccak256(abi.encodePacked([salt, secret])));
        Operation[] memory ops = new Operation[](1);
        ops[0] = Operation(0, commitment, 0);
        PublicInput[] memory inputs = new PublicInput[](0);
        Transaction memory transaction = Transaction(inputs, ops);

        example.createCommitment(transaction);
    }

    function test_UpdateCommitment() public {
        uint256 salt = 1;
        uint256 secret = 2;
        uint256 commitment = uint256(keccak256(abi.encodePacked([salt, secret])));

        uint256 salt2 = 2;
        uint256 secret2 = 2;
        uint256 commitment2 = uint256(keccak256(abi.encodePacked([salt2, secret2])));
        Operation[] memory ops = new Operation[](1);
        ops[0] = Operation(0, commitment2, commitment);
        PublicInput[] memory inputs = new PublicInput[](0);
        Transaction memory transaction = Transaction(inputs, ops);

        example.updateCommitment(transaction);
    }

    function test_UpdateCommitmentFails() public {
        uint256 salt = 1;
        uint256 secret = 2;
        uint256 commitment = uint256(keccak256(abi.encodePacked([salt, secret])));

        uint256 salt2 = 2;
        uint256 secret2 = 2;
        uint256 commitment2 = uint256(keccak256(abi.encodePacked([salt2, secret2])));
        Operation[] memory ops = new Operation[](1);
        ops[0] = Operation(0, commitment2, commitment);
        PublicInput[] memory inputs = new PublicInput[](0);
        Transaction memory transaction = Transaction(inputs, ops);

        example.updateCommitment(transaction);
        vm.expectRevert();
    }

    function test_RevealCommitment() public {
        uint256 salt = 2;
        uint256 secret = 2;
        uint256 commitment = uint256(keccak256(abi.encodePacked([salt, secret])));
        Operation[] memory ops = new Operation[](0);
        PublicInput[] memory inputs = new PublicInput[](3);
        inputs[0] = PublicInput(commitment, 0);
        inputs[1] = PublicInput(salt, 0);
        inputs[2] = PublicInput(secret, 0);
        Transaction memory transaction = Transaction(inputs, ops);

        example.revealCommitment(transaction);
        uint256 revealed = example.parse(example.peekUpdates());
        vm.assertEq(revealed, secret);
    }
}

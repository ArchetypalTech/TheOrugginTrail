// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { BaseThread, UpdateRegister } from "@gribi/evm-rootsystem/BaseThread.sol";
import { Transaction, Operation, PublicInput } from "@gribi/evm-rootsystem/Structs.sol";
import { Forest } from "@gribi/evm-rootsystem/Forest.sol";

/**
 * This module jointly creates randomness in such a way that a client can
 * prove ownership over an item to other players without revealing the item
 * publicly.
 * 
 * It can also be used for simple procedural generation of client-side state, which may
 * be later revealed (Paranoia Devices).
 * 
 * 
 * In order to use this module, a GribiSystem should listen for the Codes.NEW_RANDOMNESS and Codes.REVEALED_STATE
 * and use the information:
 * generate -> (commitmentKey, randomness)
 * reveal -> (commitmentKey, index)
 * 
 */
contract HiddenAssignment is BaseThread {
    enum Codes { UNSET, NEW_RANDOMNESS, REVEALED_STATE }
    constructor() {
        codes = new uint[](3);
        codes[uint(Codes.UNSET)] = 0;
        codes[uint(Codes.NEW_RANDOMNESS)] = 0;
        codes[uint(Codes.REVEALED_STATE)] = 0;
        register = UpdateRegister(uint(Codes.UNSET), bytes(""));
    }

    function getModuleID() public virtual pure override returns (uint256) {
        return uint256(keccak256(abi.encodePacked("hidden-assignment")));
    }

    function parse(UpdateRegister memory ur) public pure returns (uint256) {
        if (ur.code == uint(Codes.REVEALED_STATE)) {
            return abi.decode(ur.value, (uint256));
        }
    }

    //hash(random_seed) = commitment 
    function generate(Transaction memory transaction) external {
        uint256 commitment = transaction.operations[0].value;
        require(!forest.nullifierExists(commitment), "This commitment has been nullified");
        forest.addCommitment(commitment);
        uint256 commitmentKey = uint256(keccak256(abi.encodePacked(msg.sender, commitment, "(uint256, uint256)")));
        uint256 randomness = generateRandomNumber(commitment);
        PublicInput input = PublicInput(commitmentKey, randomness)
        forest.setPublicState(input);

        // should be used to receive randomness from chain
        register = UpdateRegister(
            uint(Codes.NEW_RANDOMNESS),
            abi.encode(input, "(uint256, uint256)")
        );
    }

    // hash(random_seed, randomness) = index, used to get item (can be done client-side)
    // checks a proof that commitment = hash(random_seed) and index = hash(random_seed, randomness)
    function reveal(Transaction memory transaction) external {
        uint256 commitment = transaction.operations[0].nullifier;
        uint256 index = transaction.operations[0].value;
        require(forest.commitmentExists(commitment));
        require(!forest.nullifierExists(commitment));
        forest.addNullifier(commitment);
        uint256 commitmentKey = uint256(keccak256(abi.encodePacked(msg.sender, commitment, "(uint256, uint256)")));

        register = UpdateRegister(
            uint(Codes.REVEALED_STATE),
            abi.encode(commitmentKey, index, "(uint256, uint256)")
        );
    }

    function generateRandomNumber(uint256 seed) internal view returns (uint256) {
        uint256 blockNumber = block.number - 1; // Use the previous block's hash
        bytes32 blockHash = blockhash(blockNumber);
        return uint256(blockHash) % seed;
    }
    
}

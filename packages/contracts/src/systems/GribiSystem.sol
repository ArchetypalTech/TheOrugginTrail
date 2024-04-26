// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import { System } from "@latticexyz/world/src/System.sol";
import { GribiConfig } from "../codegen/index.sol";
import { EVMRootSystem } from "@gribi/evm-rootsystem/EVMRootSystem.sol";
import { Operation, PublicInput, Proof, Transaction } from "@gribi/evm-rootsystem/Structs.sol";
import { BaseThread, UpdateRegister } from "@gribi/evm-rootsystem/BaseThread.sol";
import { Forest } from "@gribi/evm-rootsystem/Forest.sol";

contract GribiSystem is System {
    event Log(string message);
    event LogBytes(bytes data);

    //register the other systems that implement the interface here in this contract
    constructor() {
    }

    function setRootSystemAddress(address rootSystemAddress) public {
        GribiConfig.set(rootSystemAddress);
    }

    function registerModules() public {
        EVMRootSystem rs = EVMRootSystem(GribiConfig.get());
        BaseThread[] memory threads = new BaseThread[](1);

        //TODO: Register your module here
//        threads[0] = new CommitUpdateReveal();
//        rs.registerThreads(threads);
    }

    function handleReturnValues(BaseThread thread) private {
        // ReturnStack st = thread.getReturnValue(0);
        UpdateRegister memory reg = thread.peekUpdates();
//        bytes32 player = addressToEntityKey(address(_msgSender()));



        // this is revealCommitment
//        if (reg.code == uint(CommitUpdateReveal.Codes.REVEAL_COMMITMENT)) {
//            //set the MUD table here for player key
//            uint256 secret = abi.decode(reg.value, (uint256));
//
//            //do something with that secret
//        }

        // If I need to use some return value I can add it here
    }

    function execute(uint256 id, bytes memory data) public {
        EVMRootSystem rs = EVMRootSystem(address(GribiConfig.get()));
        BaseThread thread = rs.execute(id, data);
        handleReturnValues(thread);
    }

    function execute(uint256 id, bytes memory data, Proof memory proof) public {
        EVMRootSystem rs = EVMRootSystem(address(GribiConfig.get()));
        BaseThread thread = rs.execute(id, data);
        handleReturnValues(thread);
    }

}
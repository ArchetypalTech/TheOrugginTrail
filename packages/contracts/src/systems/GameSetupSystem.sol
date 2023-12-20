// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

// get some debug OUT going
import { console } from "forge-std/console.sol";

import {System} from "@latticexyz/world/src/System.sol";
import {Output, CurrentRoomId, RoomStore, RoomStoreData, ActionStore,  TextDef} from "../codegen/index.sol";
import {ActionType, RoomType, ObjectType, CommandError} from "../codegen/common.sol";


// NOTE of interest in the return types of the functions, these
// are later used in the logs of the game provided by the MUD 
// dev tooling
contract GameSetupSystem is System {

    function init() public returns (uint32) {

       // we are right now initing the data in the 
        Output.set('init called...');

        return 0;
    }

}


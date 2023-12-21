// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

// get some debug OUT going
import { console } from "forge-std/console.sol";

import {System} from "@latticexyz/world/src/System.sol";
import {Output, CurrentRoomId, RoomStore, RoomStoreData, ActionStore,  TextDef} from "../codegen/index.sol";
import {ActionType, RoomType, ObjectType, CommandError, DirectionType} from "../codegen/common.sol";
import { CommandLookups } from "./CommandLookup.sol";
import { GameConstants } from "../constants/defines.sol";

contract MeatPuppetSystem is System, GameConstants, CommandLookups  {
    
    // we call this from the post deploy contract 
    function initGES() public returns (uint32) {
        Output.set('initGES called...');
        initCES();
        return 0;
    }

    function enterRoom(uint32 rId) public returns (uint32 err) {
        // TODO:  on entering describe the room
        uint32 id = CurrentRoomId.get();
        uint32 newValue = id + 1;
        CurrentRoomId.set(newValue);

        string memory roomDesc = "Minging room, bedsit carpet, smells of fags and soap bar";
        Output.set(roomDesc);

        return 0;
    }

    // we really should return a id to a hash table of compressed data, we shouldnt
    // be storing this shite here
    function _beWitty(CommandError ce, string memory badCmd) private pure returns (string memory) {
        string memory eMsg;
        if (ce == CommandError.LEN) {
        eMsg = "WTF, slow down cowboy, your gonna hurt yourself";
        } else if (ce == CommandError.NOP) {
            eMsg = "Nope, gibberish\n"
            "Stop breathing with your mouth.";
        } else if (ce == CommandError.GONOWHERE) {
            eMsg = "Go where pilgrim?";
        } else if (ce == CommandError.GOWHERE) {
            eMsg = string(abi.encodePacked("Go ", badCmd, " is nowhere I know of bellend"));    
        }
        return eMsg;
    }


    // should probably not return a uint8 but a CommandError
    function processCommand(string[] calldata tokens) public returns (uint8 err) {

        if (tokens.length > MAX_TOK ) {
            string memory response = _beWitty(CommandError.LEN, "");
            Output.set(response);
            return uint8(CommandError.LEN);
        }

        for (uint8 i = 0; i < tokens.length; i++) {
            // we want to compare against our mapped sting => enum
            // data structure which takes strings we have tokenised
            string memory vrb = tokens[i];
            if (cmdLookup[vrb] != ActionType.None) {
                ActionType VERB = cmdLookup[vrb];
                if (VERB == ActionType.Go && tokens.length >= 2) {
                    // hand off here to the engine it should take the current room id
                    // this is just a start... GO is easy
                    DirectionType DIR = dirLookup[tokens[1]];
                    if (DIR != DirectionType.None) {
                        enterRoom(CurrentRoomId.get());
                        return uint8(CommandError.NONE);
                    }else {
                        Output.set(_beWitty(CommandError.GOWHERE, tokens[1]));
                        return uint8(CommandError.NOP); 
                    }
                } else {
                    // didnt give use enough tokens for verb
                    Output.set(_beWitty(CommandError.GONOWHERE, ""));
                    return 12; //uint8(CommandError.NOP);
                }
            }else {
                Output.set(_beWitty(CommandError.NOP, ""));
                return 3;}
        }
       return 0;
    }
}


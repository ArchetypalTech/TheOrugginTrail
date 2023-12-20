// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

// get some debug OUT going
import { console } from "forge-std/console.sol";

import {System} from "@latticexyz/world/src/System.sol";
import {Output, CurrentRoomId, RoomStore, RoomStoreData, ActionStore,  TextDef} from "../codegen/index.sol";
import {ActionType, RoomType, ObjectType, CommandError} from "../codegen/common.sol";
import { GameConstants } from "../constants/defines.sol";


// NOTE of interest in the return types of the functions, these
// are later used in the logs of the game provided by the MUD 
// dev tooling
contract GameEngineSystem is System, GameConstants {
   
    
    mapping (string => ActionType) private commandLookup;

    function initData() public returns (uint32) {

       // we are right now initing the data in the 
       // contracts/script/PostDeploy.s.sol
       // so the previous Room sets etc have been chopped
       // they should in fct be moved here I think but right
       // now there it sits. This gets called from im not sure
       // tbh and it does always seem to be called, no idea where
       // from as I am sure we dont call it directly
        Output.set('initData called...');

        return 0;
    }

    // horribly faked really this should use the GameMap and
    // take coordinate
    function enterRoom(uint32 rId) public returns (uint32 err) {

        uint32 id = CurrentRoomId.get();
        uint32 newValue = id + 1;
        CurrentRoomId.set(newValue);

        string memory roomDesc = "Minging room, bedsit carpet, smells of fags and soap bar";
        Output.set(roomDesc);

        return 0;
    }

    // we really should return a id to a hash table of compressed data, we shouldnt
    // be storing this shite here
    function _beWitty(CommandError ce) private pure returns (string memory) {
        string memory eMsg;
        if (ce == CommandError.LEN) {
        eMsg = "WTF, slow down cowboy, your gonna hurt yourself\n"
        "Now take a deep breath...\n"
        "Smell that?\n"
        "Yep its you, you done shit your pants again, that dysentry sure is a bitch\n"
        "Go on now, have a another crack there dude";
        } else if (ce == CommandError.NOP) {
            eMsg = "Nope, gibberish\n"
            "Have another try, emote...";
        } 
        return eMsg;
    }

    function processCommand(string[] calldata tokens) public returns (uint8 err) {

        if (tokens.length > MAX_TOK ) {
            string memory response = _beWitty(CommandError.LEN); 
            Output.set(response);
            return 10;
        }
        
        // this is a very crude first step, as we are actually 
        // using strings here and really we should tokenise to 
        // ZORKish types VERB, DOBJ, IDOBJ
        // pre running a behaviour engine then again whats really 
        // the size of our vocab right now, like 256 * (16 ** 2)
        // its really not a huge amount
        for (uint8 i = 0; i < tokens.length; i++) {
            // we want to compare against our mapped sting => enum
            // data structure which takes strings and we have tokenised

            string calldata cmd = tokens[i];

            // check that its not a `None` which will be the default return
            // if there is no matching key in the map. When the lookup fails
            // the the default type is returned, our type is ENUM and as such
            // the first value is 0 so we set that to `None` amd handle for 
            // the failing case this way
            if (commandLookup[cmd] != ActionType.None) {
                ActionType VERB = commandLookup[cmd];
                if (VERB != ActionType.None) {
                    enterRoom(1);
                    return 1;
                } else {
                    return 2;
                }
            }else {return 3;}
        }
       return 0; 
    }
}


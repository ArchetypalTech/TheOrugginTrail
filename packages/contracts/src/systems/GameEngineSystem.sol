// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

// get some debug OUT going
import { console } from "forge-std/console.sol";

import {System} from "@latticexyz/world/src/System.sol";
import {Output, CurrentRoomId, RoomStore, RoomStoreData, ActionStore,  TextDef} from "../codegen/index.sol";
import {ActionType, RoomType, ObjectType, CommandError} from "../codegen/common.sol";

contract GameEngineSystem is System {
   
    uint8 constant MAX_TOK = 16;
    
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


        // so anyway as we are calling this friom somewhere
        // we may as well actually init som more data this
        // very should be done via tooling which we will hack
        // together, should take a {file, [str]} of VERBS and then
        // a SYSTEM to map them into. This is actually not a bad
        // PR for MUD lattice.
        // for now however hack at it....
        commandLookup["North"] = ActionType.North;
        commandLookup["Go"] = ActionType.Go;
        commandLookup["Move"] = ActionType.Move;
        commandLookup["Loot"] = ActionType.Loot;
        commandLookup["Describe"] = ActionType.Describe;
        commandLookup["Take"] = ActionType.Take;
        commandLookup["Kick"] = ActionType.Kick;
        commandLookup["Lock"] = ActionType.Lock;
        commandLookup["Unlock"] = ActionType.Unlock;
        commandLookup["Open"] = ActionType.Open;

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
    // this is really again somthing we should use tooling for and again mioght be
    // a reasonble PR or even maintained fork
    function _beWitty(CommandError ce) private pure returns (string memory msg) {
        string memory msg = "WTF, slow down cowboy, your gonna hurt yourself\n"
        "Now take a deep breath...\n"
        "Smell that?\n"
        "Yep its you, you done shit your pants again, that dysentry sure is a bitch\n"
        "Go on now, have a another crack there dude";
        return msg;
    }

    function processCommand(uint8[][] calldata tokens) public returns (uint8 err) {

        if (tokens.length > MAX_TOK) {
            string memory response = _beWitty(CommandError.Boring); 
            Output.set(response);
            string memory rFoo = 'Foo Response';
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
            // to uint8[] array's because that's good right?
            // we did that in the tokeniser in the TS `createClientComponents`
            // maybe we shouldn't
            // so now we go back to string'y data for the enum
            uint8[] calldata input = tokens[i];
            bytes memory stringBytes = new bytes(input.length);
            for (uint8 j = 0; j < input.length; j++) {
                stringBytes[i] = bytes1(input[i]);
            }
            // check that its not a `None` which will be the default return
            // if there is no matching key in the map. When the lookup fails
            // the the default type is returned, our type is ENUM and as such
            // the first value is 0 so we set that to `None` amd handle for 
            // the failing case this way
            if (commandLookup[string(stringBytes)] != ActionType.None) {
                ActionType VERB = commandLookup[string(stringBytes)];
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


// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

// get some debug OUT going
import { console } from "forge-std/console.sol";

import {System} from "@latticexyz/world/src/System.sol";
import {Output, CurrentRoomId, RoomStore, RoomStoreData, ActionStore, DirObjStore, DirObjStoreData, TextDef} from "../codegen/index.sol";
import {ActionType, RoomType, ObjectType, CommandError, DirectionType} from "../codegen/common.sol";
import { CommandLookups } from "./CommandLookup.sol";
import { GameConstants } from "../constants/defines.sol";

// an attempt at calling another system
// we nneed the below
import { SystemSwitch } from "@latticexyz/world-modules/src/utils/SystemSwitch.sol";
// then the system interface
import { IGameSetupSystem } from "../codegen/world/IGameSetupSystem.sol";

import { console } from "forge-std/console.sol";

contract MeatPuppetSystem is System, GameConstants, CommandLookups  {
    
    // TODO: 
    // * common parser should be the same for actions as for
    //   directions:
    //   dircmd = "go", ["to"], target | dir;
    //   dir = north | south | east | west;
    //   target = object;
    //   object = ...

    event debugLog(string msg, uint8 val);

    // we call this from the post deploy contract 
    function initGES() public returns (uint32) {
        Output.set('initGES called...');

        // i dont like this there must be a cleaner way
        // perhaps we should init() all systems via postdeploy ??
        initCLS();

        // our empty test function from the GSS that just returns a uint32
        // for ref of how to call another systen, I think the system has to 
        // be in the root namespace but it would be handy to figure out 
        // how to actually use namespaces properly, its in the docs but not
        // exactly clear
        uint32 returnValue = abi.decode(
            SystemSwitch.call(
                abi.encodeCall(IGameSetupSystem.setupCmds, (22))
        ),
        (uint32)
        );

        spawn(0);
        return 0;
    }

    function spawn(uint32 startId) public {
        console.log("spawn");
        // start on the mountain
       _enterRoom(0); 
    }

    function _describeActions(uint32 rId) private returns (string memory) {
        RoomStoreData memory currRm = RoomStore.get(rId);
        string[8] memory dirStrings;
        string memory msgStr;
        for(uint8 i = 0; i < currRm.dirObjIds.length; i++) {
            DirObjStoreData memory dir = DirObjStore.get(currRm.dirObjIds[i]);

            if (dir.dirType == DirectionType.North) {
                dirStrings[i] = " North";
            }else if (dir.dirType == DirectionType.East) {
                dirStrings[i] = " East";
            }else if (dir.dirType == DirectionType.South) {
                dirStrings[i] = " South";
            }else if (dir.dirType == DirectionType.West) {
                dirStrings[i] = " West";
            }else {dirStrings[i] = " to hell";}
        }

        for(uint16 i = 0; i < dirStrings.length; i++) {
            msgStr = string(abi.encodePacked(msgStr, dirStrings[i]));
        }

        return msgStr;
    }

    function _enterRoom(uint32 rId) private returns (uint8 err) {
        CurrentRoomId.set(rId);
        RoomStoreData memory currRoom = RoomStore.get(CurrentRoomId.get());
        string memory actions = _describeActions(rId);
        string memory pack = string(abi.encodePacked(currRoom.description, "\n", 
                                     "You can go", _describeActions(rId))
                                   );
        Output.set(pack);
        return 0;
    }

    // MOVE TO ITS OWN SYTEM -- MEATMOVER
    // handle logic for testing direction are available and thus moving the player 
    //or not as the case may be
    function _movePlayer(string[] memory tokens, uint32 currRmId) private returns (uint8 err) {
       // first check we have a decent token 
       string memory  tok;
       if (tokens.length > 2) {
           /* dir valid? */
           if ( dirLookup[tokens[3]] != DirectionType.None ) {
               /* dir found */
           }else if (dirLookup[tokens[2]] != DirectionType.None ) {
               /* dir found */
           }else {
               /* no dir found in tokens */
               return ER_DR_ND;
           }
       }
    }

    // intended soley to process tokens and then hand off to other systems
    // checks for first TOKEN which can be either a GO or another VERB.
    // Assuming these look good then in an ideal world drops token[0] and 
    // passes the tail to either the movement system or the actions system
    // Actually we dont because actually doing that is an expensive op in Sol
    // and therefore the EVM (don't know) so we pass the whole thing around
    function processCommandTokens(string[] calldata tokens) public returns (uint8 err) {

        if (tokens.length > ER_PR_MXT ) {
            string memory response = _insultMeat(ER_PR_MXT, "");
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
                    // this is a GO
                    _movePlayer(tokens, CurrentRoomId.get());
                }
                else if (tokens.length >= 2) {
                    // some other VERB 
                }   
            }
        }
    }

    //MOVE TO ITS OWN SYTEM - MEATINSULTOR
    // we really should return a id to a hash table of compressed data, we shouldnt
    // be storing this shite here
    function _insultMeat(uint8 ce, string memory badCmd) private pure returns (string memory) {
        string memory eMsg;
        if (ce == ER_PR_MXT) {
            eMsg = "WTF, slow down cowboy, your gonna hurt yourself";
        } else if (ce == ER_PR_NOP) {
            eMsg = "Nope, gibberish\n"
            "Stop breathing with your mouth.";
        } else if (ce == ER_PR_ND) {
            eMsg = "Go where pilgrim?";
        } else if (ce == ER_DR_NOP) {
            eMsg = string(abi.encodePacked("Go ", badCmd, " is nowhere I know of bellend"));    
        }
        
        return eMsg;
    }
}


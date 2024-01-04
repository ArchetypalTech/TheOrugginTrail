// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import {console} from "forge-std/console.sol";
import { IWorld } from '../codegen/world/IWorld.sol'; 

import { ActionType, GrammarType, DirectionType, ObjectType, DirObjectType } from '../codegen/common.sol';

import { RoomStore, RoomStoreData } from '../codegen/index.sol';

library LookAt {
    /* l_cmd = (look, at, [ the ] , obj) | (look, around, [( [the], place )]) */

    function stuff(address wrld, string[] memory tokens, uint32 curRmId) internal view returns (uint8 e) {
        // Composes the descriptions for stuff Players can see
        // right now that's from string's stored in object meta data
        console.log("---->SEE T:%s, R:%d", tokens[0], curRmId);

        ActionType vrb = IWorld(wrld).meat_TokeniserSystem_getActionType(tokens[0]);
        DirectionType dir;
        ObjectType obj;
        DirObjectType dirObj;
        GrammarType gObj;

        // we know it is an action because the commandProcessors has pre-parsed for us
        // so we dont need to test for a garbage vrb token
        if ( vrb == ActionType.Look ) {
            console.log("---->LOOK");
            string memory tok = tokens[tokens.length -1];
            if (tokens.length > 1) {
               gObj = IWorld(wrld).meat_TokeniserSystem_getGrammarType(tokens[tokens.length -1]);
               if (gObj != GrammarType.Adverb) {
                   
               }
                
            }
        } else if ( vrb == ActionType.Describe ) {
            console.log("---->DESC");
        }
    }

    function _lookAround(uint32 rId) internal view returns (string memory) {
        uint32[] memory objects = RoomStore.get(rId).objectIds;
        uint32[] memory dObjects = RoomStore.get(rId).dirObjIds;
    }
}


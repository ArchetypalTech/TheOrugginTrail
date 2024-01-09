// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import {console} from "forge-std/console.sol";
import { IWorld } from '../codegen/world/IWorld.sol'; 


import { ActionType, GrammarType, DirectionType, ObjectType, DirObjectType, TxtDefType, RoomType } from '../codegen/common.sol';

import { RoomStore, RoomStoreData, ObjectStore, DirObjectStore, Description, Output, TxtDefStore } from '../codegen/index.sol';


library LookAt {
    /* l_cmd = (look, at, [ the ] , obj) | (look, around, [( [the], place )]) */


    function stuff(address wrld, string[] memory tokens, uint32 curRmId) internal returns (uint8 err) {
        // Composes the descriptions for stuff Players can see
        // right now that's from string's stored in object meta data
        console.log("---->SEE T:%s, R:%d", tokens[0], curRmId);
        uint8 err;
        ActionType vrb = IWorld(wrld).meat_TokeniserSystem_getActionType(tokens[0]);
        GrammarType gObj;


        // we know it is an action because the commandProcessors has pre-parsed for us
        // so we dont need to test for a garbage vrb token
        if ( vrb == ActionType.Look ) {
            console.log("---->LK RM:%s", curRmId);
            string memory tok = tokens[tokens.length -1];
            if (tokens.length > 1) {
               gObj = IWorld(wrld).meat_TokeniserSystem_getGrammarType(tokens[tokens.length -1]);
               if (gObj != GrammarType.Adverb) {
                  err = _lookAround(curRmId); 
                  console.log("->_LA:%s", err);
               }
            }
        } else if ( vrb == ActionType.Describe ) {
            console.log("---->DESC");
        }
        return err;
    }

    function _genDescText(uint32 id) internal returns (string memory) {
        bytes32[] memory ids = Description.getTxtIds();
        string memory desc = "You are standing ";

        for (uint8 i =0; i < ids.length; i++) {
            TxtDefType t = TxtDefStore.getTxtDefType(ids[i]);
            if ( t == TxtDefType.Place ) {
                if ( RoomStore.getRoomType(id) == RoomType.Plain ) {
                    desc = string(abi.encodePacked(desc, "on ", RoomStore.getDescription(id)));
                } else {
                    desc = string(abi.encodePacked(desc, "in ", RoomStore.getDescription(id)));
                }
            }
        }
        Output.set(desc);
    }

    function _fetchObjects(uint32[] memory objs) internal returns (uint8 er) {
        //Objects:
        for(uint8 i =0; i < objs.length; i++) {
            console.log("--->LK_AR: %d OBJ_ID:%d", i, objs[i]);
            bytes32 tId =  ObjectStore.getTxtDefId(objs[i]); 
            Description.pushTxtIds(tId);
        }
        return 0;
    }

    function _fetchDObjects(uint32[] memory objs) internal returns (uint8 er) {
        //DirObjects:
        for(uint8 i =0; i < objs.length; i++) {
            console.log("--->LK_AR: %d OBJ_ID:%d", i, objs[i]);
            bytes32 tId = DirObjectStore.getTxtDefId(objs[i]); 
            Description.pushTxtIds(tId);
        }
        return 0;
    }

    function _fetchRoomDesc(uint32 rmId) internal returns (uint8 er) {
        bytes32 tId = RoomStore.getTxtDefId(rmId);
        Description.pushTxtIds(tId);
        return 0;
    }

    function _lookAround(uint32 rId) internal returns (uint8 er) {
        uint32[] memory objIds = RoomStore.get(rId).objectIds;
        uint32[] memory dObjects = RoomStore.get(rId).dirObjIds;

       _fetchObjects(objIds); 
       _fetchDObjects(dObjects);
       _fetchRoomDesc(rId);
       _genDescText(rId);

       return 0 ;
    }
}


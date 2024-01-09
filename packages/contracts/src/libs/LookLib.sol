// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import {console} from "forge-std/console.sol";
import { IWorld } from '../codegen/world/IWorld.sol'; 


import { ActionType, MaterialType, GrammarType, DirectionType, ObjectType, DirObjectType, TxtDefType, RoomType } from '../codegen/common.sol';

import { RoomStore, RoomStoreData, ObjectStore, DirObjectStore, DirObjectStoreData, Description, Output, TxtDefStore } from '../codegen/index.sol';


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
                  err = _lookAround(curRmId, wrld); 
                  console.log("->_LA:%s", err);
               }
            }
        } else if ( vrb == ActionType.Describe ) {
            console.log("---->DESC");
        }
        return err;
    }

    function _genDescText(uint32 id, address wrld) internal returns (string memory) {
        string memory desc = "Looking around you see that\nyou are standing ";
        string memory storedDesc = TxtDefStore.getValue(RoomStore.getTxtDefId(id));

        if ( RoomStore.getRoomType(id) == RoomType.Plain ) {
            desc = string(abi.encodePacked(desc, "on ", RoomStore.getDescription(id), "\n"));
        } else {
            desc = string(abi.encodePacked(desc, "in ", RoomStore.getDescription(id), "\n"));
        }
        // concat the general description
        desc = string(abi.encodePacked(desc, storedDesc, "\n"));

        // handle the rooms objects
        desc = string(abi.encodePacked(desc, _genObjDesc(RoomStore.getObjectIds(id))));

        // handle the rooms exits
        desc = string(abi.encodePacked(desc, _genExitDesc(RoomStore.getDirObjIds(id), wrld)));
        return desc;
    }

    function _genObjDesc(uint32[] memory objs) internal returns (string memory) {
        if (objs[0] != 0) {// if the first item is 0 then there are no objects
            string memory objsDesc = "You can alse see ";
            for(uint8 i = 0; i < objs.length; i++) {
                if (objs[i] != 0) { // again, an id of 0 means no value
                    objsDesc = string(abi.encodePacked(objsDesc, ObjectStore.getDescription(objs[i]), "\n")); 
                    bytes32 tId =  ObjectStore.getTxtDefId(objs[i]); 
                    objsDesc = string(abi.encodePacked(objsDesc, TxtDefStore.getValue(tId), "\n"));
                }
            }
            return objsDesc;
        }
    }

    function _genMaterial(MaterialType t, DirObjectType dt) internal returns (string memory) {
        string memory dsc; 
        if (dt == DirObjectType.Path || dt == DirObjectType.Trail) {
            
        } else {

        }
    }

    function _genExitDesc(uint32[] memory objs, address wrld) internal returns (string memory) {
        if (objs[0] != 0) {// if the first item is 0 then there are no objects
            string memory exitsDesc = "There is ";
            for(uint8 i = 0; i < objs.length; i++) {
                if (objs[i] != 0) { // again, an id of 0 means no value
                    DirObjectStoreData memory objData = DirObjectStore.get(objs[i]);
                    exitsDesc = string(abi.encodePacked(exitsDesc, TxtDefStore.getValue(objData.txtDefId), "to the ",
                                                        IWorld(wrld).meat_TokeniserSystem_reverseDirType(objData.dirType), ".\n" ));
                }
            }
            return exitsDesc;
        }
    }

    function _fetchRoomDesc(uint32 rmId) internal returns (uint8 er) {
        bytes32 tId = RoomStore.getTxtDefId(rmId);
        Description.pushTxtIds(tId);
        return 0;
    }

    function _lookAround(uint32 rId, address w) internal returns (uint8 er) {

       Output.set(_genDescText(rId, w));

       return 0 ;
    }
}


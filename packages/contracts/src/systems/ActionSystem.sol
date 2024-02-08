// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { console } from "forge-std/console.sol";

import { System } from "@latticexyz/world/src/System.sol";

import { IWorld } from '../codegen/world/IWorld.sol';

import { ObjectType, ActionType, DirObjectType } from '../codegen/common.sol';

import { Player, RoomStore, ObjectStore, DirObjectStore, Output, ActionStore} from '../codegen/index.sol';

import { ErrCodes, VerbData } from '../constants/defines.sol';

import { Constants } from '../constants/Constants.sol';

import { SizedArray } from '../libs/SizedArrayLib.sol';

/**
*   @dev handle actions other than LOOK and MOVE. These are generic
    we need to check that tha VRB can find a matching response ACTION
*/
contract ActionSystem is System, Constants {

    uint32[MAX_OBJ] private itemsToUse;

    function act(VerbData memory cmd, uint32 rm) public returns (uint8 er) {
        uint8 err;

        uint32[MAX_OBJ] memory ids = _fetchObjsForType(cmd.directNoun, cmd.verb, rm);
        uint32[MAX_OBJ] memory dids = _fetchDObjsForType(cmd.indirectDirNoun, cmd.verb, rm);

//        console.log("--->vrb:%s, dids:%d, dids[0]:%d", uint32(cmd.verb), dids.length, dids[0]);

        if (ids.length > 0 && ids[0] != 0) {
            console.log("---> Got objects:%d", uint8(ids.length));
        }

        if (dids.length > 0 && dids[0] != 0) {
            console.log("---> Got d_objects:%d", uint8(dids.length));
        }
        return err;
    }

    /**
        @dev Fetch the DirectionObjects we might need to act on
        VERB `t` needs to be mapped to it's corresponding RESPONSE i.e
        KICK/THROW/HIT -> DAMAGE
        If DAMAGE is ENABLED then its DAMAGE state can be flipped
        i.e DAMAGE -> DAMAGED
    */
    function _fetchDObjsForType(DirObjectType dObjType, ActionType t, uint32 rm) private returns (uint32[MAX_OBJ] memory ids) {
        console.log("-->FETCH_DOBJS");
        uint32[MAX_OBJ] memory matchedObjects;
        uint32[MAX_OBJ] memory objs =  RoomStore.getDirObjIds(rm);
        for (uint256 i = 0; i < objs.length; i++ ) {
            uint32[MAX_OBJ] memory actionIds =  DirObjectStore.getObjectActionIds(objs[i]);
            if (actionIds[0] == 0) {break;}
//            console.log("-------------->AID:%d", actionIds[i]);
            for (uint256 j = 0; j < actionIds.length; j++) {
                ActionType vrb = ActionStore.getActionType(actionIds[j]);
                if (vrb == ActionType.None) { break; }
//                console.log("------->want R-vrb:%d A-vrb:%d R:%d", uint8(vrb), uint8(t), rm);
                ActionType[] memory responses = IWorld(_world()).meat_TokeniserSystem_getResponseForVerb(t);
                if (responses.length > 0) {
                    for (uint256 k = 0; k < responses.length; k++) {
                        if (responses[k] == vrb) {
//                            console.log("----> matched on:%d obj:%d", uint8(t), objs[i]);
                            SizedArray.add(matchedObjects, objs[i]);
                        }
                    }
                }
            }
        }
        return matchedObjects;
    }

    /**
        @dev Fetch the Objects we might need to act on
        VERB `t` needs to be mapped to it's corresponding RESPONSE i.e
        KICK/THROW/HIT -> DAMAGE | BREAK | SMASH ...
        If DAMAGE is ENABLED then its DAMAGE state can be flipped
        i.e DAMAGE -> DAMAGED
    */
    function _fetchObjsForType(ObjectType objType, ActionType t, uint32 rm) private returns (uint32[MAX_OBJ] memory ids) {
        console.log("-->FETCH_OBJS");
        uint32[MAX_OBJ] memory matchedObjects;
        uint32[MAX_OBJ] memory objs =  RoomStore.getObjectIds(rm);
        for(uint256 i = 0; i < objs.length; i++) {
//            console.log("------>rm:%d objects[%d]:%d",uint8(rm), uint8(i), uint8(objs[i]));
            uint32[MAX_OBJ] memory actionIds = ObjectStore.getObjectActionIds(objs[i]);
            if (actionIds[0] == 0) {break;}
            for(uint256 j = 0; j < actionIds.length; j++) {
                ActionType vrb = ActionStore.getActionType(actionIds[j]);
                if (vrb == ActionType.None) { break; }
                ActionType[] memory responses = IWorld(_world()).meat_TokeniserSystem_getResponseForVerb(vrb);
                if (responses.length > 0) {
                    for (uint256 k = 0; k < responses.length; k++) {
    //                    console.log("--->response:%d", uint8(responses[k]));
                        if (responses[k] == t) {
    //                        console.log("---> Got match on:%d with t:%d", uint8(responses[k]), uint8(t));
                            SizedArray.add(matchedObjects, objs[i]);
                        }
                    }
                }
            }
        }
        return matchedObjects;
    }
}

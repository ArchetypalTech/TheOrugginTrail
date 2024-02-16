// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { console } from "forge-std/console.sol";

import { System } from "@latticexyz/world/src/System.sol";

import { IWorld } from '../codegen/world/IWorld.sol';

import { ObjectType, ActionType, DirObjectType } from '../codegen/common.sol';

import { Player, RoomStore, ObjectStore, DirObjectStore, Output, ActionStore, ActionOutputs, ActionStoreData, DirObjectStoreData } from '../codegen/index.sol';

import { ErrCodes, VerbData } from '../constants/defines.sol';

import { Constants } from '../constants/Constants.sol';

import { SizedArray } from '../libs/SizedArrayLib.sol';

/**
*   @dev handle actions other than LOOK and MOVE. These are generic
    we need to check that tha VRB can find a matching response ACTION
*/
contract ActionSystem is System, Constants {

    function act(VerbData memory cmd, uint32 rm) public returns (uint8 er, string memory response) {
        uint8 err;
        string memory responseStr;
        uint32[MAX_OBJ] memory ids = _fetchObjsForType(cmd.directNoun, cmd.verb, rm);
        uint32[MAX_OBJ] memory sizedDids = _fetchDObjsForType(cmd.indirectDirNoun, cmd.verb, rm);

        if (ids.length > 0 && ids[0] != 0) {
            console.log("---> Got objects:%d", uint8(ids.length));
        }

        if (sizedDids.length > 0 && sizedDids[0] != 0) {
            console.log("---> Got d_obj:%d", SizedArray.count(sizedDids));
            console.log("----> Got d_obj[0]:%d", sizedDids[0]);
            _setActionBits(cmd, sizedDids, true);
//            _getResponseStr(cmd, sizedDids, true);
        }
        return (err, responseStr);
    }

    function _handleBaseAction(uint32 actId) private returns (uint8 er, string memory response) {
//        DirObjectStoreData memory objData = DirObjectStore.get(objID);
//        for (uint256 j = 0; j < objData.objectActionIds.length; j++) {
//            ActionStoreData memory actionData = ActionStore.get(objData.objectActionIds[j]);
//            if (actionData.enabled) {
//            }
//        }
    }

    function _getResponseStr() private {
        console.log("--------> getResponseStr");
    }

    function _followLinkedActions(uint32 top, uint32[MAX_OBJ] memory ids, uint32 cnt) private returns (uint32 ct) {
        uint32 id = ActionStore.getAffectsActionId(top);
        if (id == 0) {return cnt;} else {
            ++cnt;
            SizedArray.add(ids, ActionStore.getAffectsActionId(top));
            _followLinkedActions(id, ids, cnt);
        }
    }

    /// @notice flip the action bit i.e make it a past participle, broken/smashed/opened
    // the logic is that we check for an enabled bit and then change the state
    // and then follow any linked actions which allows us to then build puzzle chains
    function _setActionBits(VerbData memory cmd, uint32[MAX_OBJ] memory objIDs, bool isD) private returns(uint8 er) {
        /**
            todo:
            if (action.next.affectedByActionId == action.this.id) then { do stuff }
            so a locked door that needs a `rusty key` would only get opened by a
            `rusty key` that has an lock action set on it, the important part being
            the id of the lock action and setting that on the correct item (`rusty key`)
        */
        uint32 ct = SizedArray.count(objIDs);
        console.log("->sz:%d", ct);
        for (uint32 i = 0; i < ct; i++) {
            // set the action bit on the object for the verb
            if (isD) {
                // get the object data
                DirObjectStoreData memory objData = DirObjectStore.get(objIDs[i]);
                // are we dealing with a specific action or a general action i.e de we
                // have an indirectObject in the command. If we don't have an indirectObj
                // then use the base case
                if (cmd.indirectDirNoun != DirObjectType.None) {
                    for (uint256 j = 0; j < objData.objectActionIds.length; j++) {
                        ActionStoreData memory actionData = ActionStore.get(objData.objectActionIds[j]);
                        if (actionData.enabled) {
                            // flip the bit
                            actionData.dBit = !actionData.dBit;
                            ActionStore.set(objData.objectActionIds[j], actionData);
                            // get the state change text and store
                            ActionOutputs.pushTxtIds(objData.objectActionIds[j], ActionStore.getDBitTxt(objData.objectActionIds[j]));
                            // follow any linked actions
                            uint32 linkedActionId = ActionStore.getAffectsActionId(objData.objectActionIds[j]);
                            if (linkedActionId != 0) {
                                uint32[MAX_OBJ] memory linkedActions;
                                uint32 count;
                                _followLinkedActions(linkedActionId, linkedActions, count);
                                console.log("------>followLinks count:%d", count);
                                for (uint32 k = 0; k < SizedArray.count(linkedActions); k++) {
                                    ActionStoreData memory lnkActionData = ActionStore.get(linkedActions[k]);
                                    // flip the bit, and the enable bit if needed
                                    lnkActionData.enabled = !lnkActionData.enabled;
                                    lnkActionData.dBit = !lnkActionData.dBit;
                                    // store the new state
                                    ActionStore.set(linkedActions[k], lnkActionData);
                                    // get the state change text and store
                                    ActionOutputs.pushTxtIds(objData.objectActionIds[j], ActionStore.getDBitTxt(linkedActions[k]));
                                }
                            }
                        }
                    }
                } else {
                    // handle base case for verb by looping though objects and flipping the state bits
                    // if this is indeed the desired behaviour which it probably isn't so there is no implementation
                    // here but we may want to, the current behaviour is take the txtDef from the action and use that
                    //handleBaseAction();
                }

            } else {
                // handle for objects
            }
        }
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
        uint32[MAX_OBJ] memory matchedObIDs;
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
                            SizedArray.add(matchedObIDs, objs[i]);
                        }
                    }
                }
            }
        }
        return matchedObIDs;
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

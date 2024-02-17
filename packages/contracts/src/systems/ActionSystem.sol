// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { console } from "forge-std/console.sol";

import { System } from "@latticexyz/world/src/System.sol";

import { IWorld } from '../codegen/world/IWorld.sol';

import { ObjectType, ActionType, DirObjectType } from '../codegen/common.sol';

import { Player, RoomStore, ObjectStore, DirObjectStore, Output, ActionStore, ActionOutputs, TxtDefStore, ActionStoreData, DirObjectStoreData } from '../codegen/index.sol';

import { ErrCodes, ResCodes, VerbData } from '../constants/defines.sol';

import { Constants } from '../constants/Constants.sol';

import { SizedArray } from '../libs/SizedArrayLib.sol';

/**
*   @dev handle actions other than LOOK and MOVE. These are generic
    we need to check that tha VRB can find a matching response ACTION
*/
contract ActionSystem is System, Constants {

    address private world;

    function act(VerbData memory cmd, uint32 rm, uint32 playerId) public returns (uint8 er, string memory response) {
        world = _world();
        uint8 err;
        uint8 bitCnt;
        string memory responseStr;
        uint32[MAX_OBJ] memory ids = _fetchObjsForType(cmd.directNoun, cmd.verb, rm);
        uint32[MAX_OBJ] memory sizedDids = _fetchDObjsForType(cmd.indirectDirNoun, cmd.verb, rm);

        if (ids.length > 0 && ids[0] != 0) {
            console.log("---> Got objects:%d", uint8(ids.length));
        }

        if (sizedDids.length > 0 && sizedDids[0] != 0) {
            console.log("---> Got d_obj:%d", SizedArray.count(sizedDids));
            console.log("----> Got d_obj[0]:%d", sizedDids[0]);
            if (cmd.indirectDirNoun == DirObjectType.None && cmd.indirectObjNoun == ObjectType.None) {
                (err, responseStr) = _handleBaseAction(cmd);
            } else {
                (err, bitCnt) = _setActionBits(cmd, sizedDids, playerId, true);
            }
        }

        if (err == 0 && bitCnt > 0) {
            // we flipped some bits so generate responseStr
            responseStr = _getResponseStr(cmd, playerId);
        }
        return (err, responseStr);
    }

    function _handleBaseAction(VerbData memory cmd) private returns (uint8 er, string memory response) {
       console.log("---->base action");
    }

    /// @notice Generate a description string for the state changes on the objects tree
    /// @param cmd, VerbData
    /// @param playerId, the player acting on the items/objects
    /// @return ResponseString, a composed response string built from the txtDef's on the linked actions
    ///
    /// The code previous to this runs through the actions tree and fishes out the default text
    /// definitions when it flips a bit.
    function _getResponseStr(VerbData memory cmd, uint32 playerId) private returns(string memory){
        console.log("--------> getResponseStr");
        string memory res = "you ";
        res = string.concat(res, IWorld(world).mp_TokeniserSystem_revVrbType(cmd.verb), " the ",
            IWorld(world).mp_TokeniserSystem_revObjType(cmd.directNoun));
        res = string.concat(res, " at the ", IWorld(world).mp_TokeniserSystem_revDObjType(cmd.indirectDirNoun));

        bytes32[] memory txtIds = ActionOutputs.getTxtIds(playerId);
        uint256 ct = txtIds.length;
        for (uint256 i = 0; i < ct; i++) {
            if (txtIds[i] == 0){break;}
            string memory t = TxtDefStore.getValue(txtIds[i]);
            res = string.concat(res, "\n", t, "\n");
        }
        return res;
    }

    function _followLinkedActions(uint32 top, uint32[MAX_OBJ] memory ids) private returns(uint8 er)  {
        uint32 id = ActionStore.getAffectsActionId(top);
        if (id == 0) {return 0;} else {
            console.log("-->following links");
            SizedArray.add(ids, ActionStore.getAffectsActionId(top));
            _followLinkedActions(id, ids);
        }
    }

    /// @notice flip the action bit i.e make it a past participle, broken/smashed/opened
    /// @return er, error code. 0 for success or an error code
    /// @return bitCount, records the number of bite flipped
    ///
    /// the logic is that we check for an enabled bit and then change the state
    /// and then follow any linked actions which allows us to then build puzzle chains
    function _setActionBits(VerbData memory cmd, uint32[MAX_OBJ] memory objIDs, uint32 playerId, bool isD) private returns(uint8, uint8) {
        /**
            :TODO
            if (action.next.affectedByActionId == action.this.id) then { do stuff }
            so a locked door that needs a `rusty key` would only get opened by a
            `rusty key` that has an lock action set on it, the important part being
            the id of the lock action and setting that on the correct item (`rusty key`)
        */
        uint32 ct = SizedArray.count(objIDs);
        uint8 bc = 0;

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
                            ++bc;
                            // flip the bit
                            actionData.dBit = !actionData.dBit;
                            ActionStore.set(objData.objectActionIds[j], actionData);
                            // get the state change text and store
                            ActionOutputs.pushTxtIds(playerId, ActionStore.getDBitTxt(objData.objectActionIds[j]));
                            // follow any linked actions
                            uint32 linkedActionId = ActionStore.getAffectsActionId(objData.objectActionIds[j]);
                            console.log("--->link:%s", linkedActionId);
                            if (linkedActionId != 0) {
                                uint32[MAX_OBJ] memory linkedActions;
                                SizedArray.add(linkedActions, linkedActionId);
                                _followLinkedActions(linkedActionId, linkedActions);
                                console.log("------>followLinks");
                                for (uint32 k = 0; k < SizedArray.count(linkedActions); k++) {
                                    ++bc;
                                    ActionStoreData memory lnkActionData = ActionStore.get(linkedActions[k]);
                                    // flip the bit, and the enable bit if needed
                                    lnkActionData.enabled = !lnkActionData.enabled;
                                    lnkActionData.dBit = !lnkActionData.dBit;
                                    // store the new state
                                    ActionStore.set(linkedActions[k], lnkActionData);
                                    // get the state change text and store
                                    ActionOutputs.pushTxtIds(playerId, ActionStore.getDBitTxt(linkedActions[k]));
                                }
                            }
                        }
                    }
                } else {
                    // handle base case for verb by looping though objects and flipping the state bits
                    // if this is indeed the desired behaviour which it probably isn't so there is no implementation
                    // here but we may want to, the current behaviour is take the txtDef from the action and use that
                }
            } else {
                // handle for objects
                // :TODO
            }
        }
        if (bc > 0) {
            return (0, bc);
        } else {
            return (ResCodes.AH_BC_0, bc);
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
                ActionType[] memory responses = IWorld(_world()).mp_TokeniserSystem_getResponseForVerb(t);
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
                ActionType[] memory responses = IWorld(_world()).mp_TokeniserSystem_getResponseForVerb(vrb);
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

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import {  console } from "forge-std/console.sol";

import { System } from "@latticexyz/world/src/System.sol";

import { IWorld } from '../codegen/world/IWorld.sol';

import { ObjectType, ActionType } from '../codegen/common.sol';

import { Player, CurrentPlayerId, RoomStore, ObjectStore, Output, ActionStore } from '../codegen/index.sol';

import { ErrCodes, VerbData } from '../constants/defines.sol';

import { Constants } from '../constants/Constants.sol';

contract ActionSystem is System, Constants {

    uint32[MAX_OBJ] private itemsToUse;

    function act(VerbData memory cmd, uint32 rm) public returns (uint32 er) {
        uint32[] memory ids = _fetchObjsForType(cmd.directNoun, cmd.verb, rm);
        if (ids.length > 0) {
            console.log("---> Got objects:%d", ids.length);
        }
    }

    function _fetchObjsForType(ObjectType objType, ActionType t, uint32 rm) private view returns (uint32[MAX_OBJ] memory ids) {
        uint32[MAX_OBJ] memory objs =  RoomStore.getObjectIds(rm);
        for(uint256 i = 0; i < objs.length; i++) {
            uint32[MAX_OBJ] memory actionIds = ObjectStore.getObjectActionIds(objs[i]);
            for(uint256 j = 0; j < actionIds.length; j++) {
                if(ActionStore.getActionType(actionIds[j]) == t) {
                    ids[j] = actionIds[j];
                }
            }
        }
        return ids;
    }

}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import {console} from "forge-std/console.sol";
import {IWorld} from '../codegen/world/IWorld.sol';
import {ObjectType, ActionType} from '../codegen/common.sol';
import {SizedArray} from '../libs/SizedArrayLib.sol';
import {DirObjectStore, DirObjectStoreData, ActionStoreData, ActionStore, RoomStore, ObjectStore, Output} from '../codegen/index.sol';

library Kick {
    /* k_cmd = kick, [the], obj, [ ( at, [the], obj ) ]; */
    function kick(address wrld, string[] memory tokens, uint32 curRmId, uint32 playerId) internal returns (uint8 err) {

        uint8 tok_err;
        string memory tok = tokens[1];
        ObjectType objType = IWorld(wrld).meat_TokeniserSystem_getObjectType(tok);
        if (objType != ObjectType.None) {
            uint32[32] memory objIds = RoomStore.getObjectIds(curRmId);
            uint32 objIdCount = SizedArray.count(objIds);
            // find the object
            for (uint8 objectIndex = 0; objectIndex < objIdCount; objectIndex++) {
                ObjectType testType = ObjectStore.getObjectType(objIds[objectIndex]);

                // have we found the ball in the room?
                if (testType == objType) {

                    // we need a check to see if the object is actually kickable
                    // the exits for this room
                    uint32[32] memory dirObjIds = RoomStore.getDirObjIds(curRmId);
                    uint32 dirIdCount = SizedArray.count(dirObjIds);

                    // iterate through direction objects
                    for (uint8 dirObjectIndex = 0; dirObjectIndex < dirIdCount; dirObjectIndex++) {
                        DirObjectStoreData memory dir = DirObjectStore.get(dirObjectIndex);

                        // iterate through the actions of the direction object
                        for (uint8 actionIndex = 0; actionIndex < dir.objectActionIds.length; actionIndex++) {
                            ActionStoreData memory action = ActionStore.get(actionIndex);
                            // we found a breakable object
                            if (action.actionType == ActionType.Break) {
                                Output.set(playerId,"you broke something");

                                // remove kicked object from the room
                                objIds[objectIndex] = 0;
                        //ddt stack size issue        RoomStore.setObjectIds(curRmId, objIds);
                                return 0;
                            }
                        }
                    }


                        Output.set(playerId, "You kick the ball");

                    return 0;
                }
            }
        }
        Output.set(playerId,"Kick what?");
        return 0;
    }

}


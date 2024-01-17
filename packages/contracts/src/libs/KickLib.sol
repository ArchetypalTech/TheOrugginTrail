// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import {console} from "forge-std/console.sol";
import {IWorld} from '../codegen/world/IWorld.sol';

import {ObjectType, ActionType} from '../codegen/common.sol';
import {DirObjectStore, DirObjectStoreData, ActionStoreData, ActionStore, RoomStore, ObjectStore, Output} from '../codegen/index.sol';

library Kick {

    function kick(address wrld, string[] memory tokens, uint32 curRmId) internal returns (uint8 err) {

        console.log("---->KICK T:%s, R:%d", tokens[0], curRmId);

        uint8 tok_err;
        string memory tok = tokens[1];
        ObjectType objType = IWorld(wrld).meat_TokeniserSystem_getObjectType(tok);
        if (objType != ObjectType.None) {
            uint32[] memory objIds = RoomStore.getObjectIds(curRmId);
            // find the object
            for (uint8 objectIndex = 0; objectIndex < objIds.length; objectIndex++) {
                ObjectType testType = ObjectStore.getObjectType(objIds[objectIndex]);

                // have we found the ball in the room?
                if (testType == objType) {
                    console.log("------>we found the ball");
                    // we need a check to see if the object is actually kickable

                    // the exits for this room
                    uint32[] memory dirObjIds = RoomStore.getDirObjIds(curRmId);
                    console.log('-------->dirObjIds.length = %d', dirObjIds.length);
                    // iterate through direction objects
                    for (uint8 dirObjectIndex = 0; dirObjectIndex < dirObjIds.length; dirObjectIndex++) {
                        DirObjectStoreData memory dir = DirObjectStore.get(dirObjectIndex);
                        console.log('---------->dir.objectActionIds.length = %d', dir.objectActionIds.length);
                        // iterate through the actions of the direction object
                        for (uint8 actionIndex = 0; actionIndex < dir.objectActionIds.length; actionIndex++) {
                            ActionStoreData memory action = ActionStore.get(actionIndex);
                            // we found a breakable object
                            if (action.actionType == ActionType.Break) {
                                Output.set("you broke something");

                                // remove kicked object from the room
                                objIds[objectIndex] = 0;
                                RoomStore.setObjectIds(curRmId, objIds);
                                return 0;
                            }
                        }
                    }


                        Output.set("You kick the ball");

                    return 0;
                }
            }
        }
        Output.set("Kick what?");
        return 0;
    }

}


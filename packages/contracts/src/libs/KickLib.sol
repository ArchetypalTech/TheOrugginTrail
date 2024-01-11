
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import {console} from "forge-std/console.sol";
import { IWorld } from '../codegen/world/IWorld.sol';

import {ObjectType } from '../codegen/common.sol';
import { RoomStore, ObjectStore, Output } from '../codegen/index.sol';

library Kick {

    function kick(address wrld, string[] memory tokens, uint32 curRmId) internal returns (uint8 err) {
        console.log("----->KICK :", tokens[1]);
        uint8 tok_err;
        string memory tok = tokens[1];
        ObjectType objType = IWorld(wrld).meat_TokeniserSystem_getObjectType(tok);
        if (objType != ObjectType.None) {
            uint32[] memory objIds = RoomStore.getObjectIds(curRmId);
            for (uint8 objectIndex = 0; objectIndex < objIds.length; objectIndex++) {
                ObjectType testType = ObjectStore.getObjectType(objIds[objectIndex]);

                // have we found the ball in the room?
                if (testType == objType) {
                    uint32[] memory dirObjIds = RoomStore.getDirObjIds(curRmId);
                    for (uint8 dirObjectIndex = 0; dirObjectIndex < objIds.length; dirObjectIndex++) {

                    }



                    // iterate through direction objects

                        // iterate therough the actions of the direction object
                            // find a breakable

                                // check the flag
                                    // set the flag
                                        //show its (true) text

                                        // for the direction object



                    Output.set("You kick the ball and experience moderate fun");
                    //    Player.pushObjectIds(CurrentPlayerId.get(), objIds[i]);
                    //    objIds[i] = 0;
                    //    RoomStore.setObjectIds(rId, objIds);
                    return 0;
                }
            }
        }

        Output.set("Kick what?");

        return 0;
    }

}


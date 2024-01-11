
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
            for (uint8 i = 0; i < objIds.length; i++) {
                ObjectType testType = ObjectStore.getObjectType(objIds[i]);
                if (testType == objType) {
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


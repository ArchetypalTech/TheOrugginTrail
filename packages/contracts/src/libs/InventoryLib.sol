// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import {console} from "forge-std/console.sol";
import {IWorld} from '../codegen/world/IWorld.sol';

import {ActionType, MaterialType, GrammarType, DirectionType, ObjectType, DirObjectType, TxtDefType, RoomType} from '../codegen/common.sol';
import {Player, CurrentPlayerId,RoomStore, RoomStoreData, ObjectStore, DirObjectStore, DirObjectStoreData, Description, Output, TxtDefStore} from '../codegen/index.sol';

library Inventory {
    function take(address world, string[] memory tokens, uint32 rId) internal returns (uint8 err) {
        console.log("----->TAKE :", tokens[1]);
        uint8 tok_err;
        string memory tok = tokens[1];
        ObjectType objType = IWorld(world).meat_TokeniserSystem_getObjectType(tok);
        if (objType != ObjectType.None) {
            uint32[] memory objIds = RoomStore.getObjectIds(rId);
            for (uint8 i = 0; i < objIds.length; i++) {
                ObjectType testType = ObjectStore.getObjectType(objIds[i]);
                if (testType == objType) {
                    Output.set("You picked it up");
                    Player.pushObjectIds(CurrentPlayerId.get(), objIds[i]);
                    objIds[i] = 0;
                    RoomStore.setObjectIds(rId, objIds);
                    break;
                }
            }
        }

        return 0;

    }

    function drop(address world, string[] memory tokens, uint32 rId) internal returns (uint8 err) {
        console.log("----->DROP :", tokens[1]);
        uint8 tok_err;
        string memory tok = tokens[1];
        ObjectType objType = IWorld(world).meat_TokeniserSystem_getObjectType(tok);
        if (objType != ObjectType.None) {
            console.log("1");
            uint32[] memory objIds = Player.getObjectIds(CurrentPlayerId.get());
            for (uint8 i = 0; i < objIds.length; i++) {
                console.log("2");
                ObjectType testType = ObjectStore.getObjectType(objIds[i]);
                if (testType == objType) {
                    Output.set("You took the item from your faded Aldi bag and placed it on the floor");
                    console.log("3");
                    RoomStore.pushObjectIds(rId, objIds[i]);
                    objIds[i] = 0;
                    Player.setObjectIds(CurrentPlayerId.get(), objIds);
                    return 0;
                }
            }
            Output.set("That item is not in the Aldi carrer bag");
        }
        Output.set("I'm not sure what one of those is");

        return 0;
    }
}
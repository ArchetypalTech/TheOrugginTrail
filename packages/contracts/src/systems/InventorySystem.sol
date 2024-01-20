// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import {console} from "forge-std/console.sol";
import {System} from "@latticexyz/world/src/System.sol";
import {IWorld} from '../codegen/world/IWorld.sol';
import {ITokeniserSystem} from '../codegen/world/ITokeniserSystem.sol';

import {SizedArray} from '../libs/SizedArrayLib.sol';

import {ObjectType} from '../codegen/common.sol';
import {Player, CurrentPlayerId, RoomStore, ObjectStore, Output} from '../codegen/index.sol';

contract InventorySystem is System {
    function take(address world, string[] memory tokens, uint32 rId) public returns (uint8 err) {
        console.log("----->TAKE :", tokens[1]);
        uint8 tok_err;
        bool itemPickedUp = false;
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
                    itemPickedUp = true;
                    break;
                }
            }
        }

        if(itemPickedUp == false) {
        Output.set("That isn't here");
        }

        return 0;
    }


    function inventory(address world) public returns (uint8 err) {

        uint32[] memory objIds = Player.getObjectIds(CurrentPlayerId.get());

        bool isEmpty = true;
        string memory itemTxt = "";

        for (uint8 i = 0; i < objIds.length; i++) {
            uint32 objectId = objIds[i];
            if (objectId != 0) {
                itemTxt = string(abi.encodePacked(itemTxt, IWorld(world).meat_TokeniserSystem_getObjectNameOfObjectType(ObjectStore.getObjectType(objectId))));
                isEmpty = false;
            }
        }

        if (objIds.length == 0) {
            Output.set("Your carrier bag is empty");
            return 0;
        } else {
            Output.set(string(abi.encodePacked("You have ", itemTxt)));
        }

        return 0;

    }

    function drop(address world, string[] memory tokens, uint32 rId) public returns (uint8 err) {
        console.log("----->DROP :", tokens[1]);
        uint8 tok_err;
        string memory tok = tokens[1];
        ObjectType objType = IWorld(world).meat_TokeniserSystem_getObjectType(tok);
        if (objType != ObjectType.None) {
            uint32[] memory objIds = Player.getObjectIds(CurrentPlayerId.get());
            for (uint8 i = 0; i < objIds.length; i++) {
                ObjectType testType = ObjectStore.getObjectType(objIds[i]);
                if (testType == objType) {
                    Output.set("You took the item from your faded Aldi bag and placed it on the floor");
                    RoomStore.pushObjectIds(rId, objIds[i]);
                    objIds[i] = 0;
                    Player.setObjectIds(CurrentPlayerId.get(), objIds);
                    return 0;
                }
            }
            Output.set("That item is not in the Aldi carrer bag");
            return 0;
        }
        Output.set("I'm not sure what one of those is");

        return 0;
    }


}
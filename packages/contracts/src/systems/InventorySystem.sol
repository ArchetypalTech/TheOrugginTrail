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


    function inventory(address world) public returns (uint8 err) {

        console.log("----->INVENTORY:");

        uint32[32] memory objIds = Player.getObjectIds(CurrentPlayerId.get());

        if (SizedArray.count(objIds) == 0) {
            Output.set("Your carrier bag is empty");
            return 0;
        }

        string memory itemTxt = "You have a ";

        console.log("----->INVENTORY COUNT:%d", SizedArray.count(objIds));

        for (uint8 i = 0; i < SizedArray.count(objIds); i++) {
            uint32 objectId = objIds[i];
                if(i > 0) {
                    itemTxt = string.concat(itemTxt, " and a ");
                }
                itemTxt = string(abi.encodePacked(itemTxt, IWorld(world).meat_TokeniserSystem_getObjectNameOfObjectType(ObjectStore.getObjectType(objectId))));
        }

        Output.set(itemTxt);

        return 0;

    }


    function take(address world, string[] memory tokens, uint32 rId) public returns (uint8 err) {
        console.log("----->TAKE :%s", tokens[1]);
        uint8 tok_err;
        bool itemPickedUp = false;
        string memory tok = tokens[1];
        ObjectType objType = IWorld(world).meat_TokeniserSystem_getObjectType(tok);
        if (objType != ObjectType.None) {

            console.log("----->TAKE 1");


            uint32[32] memory roomObjIds = RoomStore.getObjectIds(rId);

            console.log("----->TAKE room object item count:%d", SizedArray.count(roomObjIds));


            console.log("----->TAKE 2");
            for (uint8 i = 0; i < SizedArray.count(roomObjIds); i++) {
                console.log("----->TAKE 3");
                ObjectType testType = ObjectStore.getObjectType(roomObjIds[i]);
                if (testType == objType) {
                    Output.set("You picked it up");

                    console.log("----->TAKE add item to the inventory");
                    // add the item to the inventory
                    uint32[32] memory playerObjIds = Player.getObjectIds(CurrentPlayerId.get());
                    SizedArray.add(playerObjIds, roomObjIds[i]);
                    Player.setObjectIds(CurrentPlayerId.get(), playerObjIds);

                    console.log("----->TAKE remove from the room");
                    // delete from the room
                    SizedArray.remove(roomObjIds, i);

                    console.log("----->TAKE set object ids count:%d", SizedArray.count(roomObjIds));

                    RoomStore.setObjectIds(rId, roomObjIds);

                    itemPickedUp = true;
                    break;
                }
            }
        }

        if (itemPickedUp == false) {
            Output.set("That isn't here");
        }

        return 0;
    }


    function drop(address world, string[] memory tokens, uint32 rId) public returns (uint8 err) {
        console.log("----->DROP :%s", tokens[1]);
        uint8 tok_err;
        string memory tok = tokens[1];
        ObjectType objType = IWorld(world).meat_TokeniserSystem_getObjectType(tok);
        if (objType != ObjectType.None) {
            uint32[32] memory playerObjIds = Player.getObjectIds(CurrentPlayerId.get());
            for (uint8 i = 0; i < SizedArray.count(playerObjIds); i++) {
                ObjectType testType = ObjectStore.getObjectType(playerObjIds[i]);
                if (testType == objType) {
                    Output.set("You took the item from your faded Aldi bag and placed it on the floor");

                    // add the item to the room
                    uint32[32] memory roomObjIds = RoomStore.getObjectIds(rId);
                    SizedArray.add(roomObjIds, playerObjIds[i]);
                    RoomStore.setObjectIds(rId, roomObjIds);

                    // delete from the inventory
                    SizedArray.remove(playerObjIds, i);
                    Player.setObjectIds(CurrentPlayerId.get(), playerObjIds);

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


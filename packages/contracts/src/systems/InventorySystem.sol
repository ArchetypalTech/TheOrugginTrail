// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import {console} from "forge-std/console.sol";
import {System} from "@latticexyz/world/src/System.sol";
import {IWorld} from '../codegen/world/IWorld.sol';
import {ITokeniserSystem} from '../codegen/world/ITokeniserSystem.sol';
import {SizedArray} from '../libs/SizedArrayLib.sol';
import {ObjectType} from '../codegen/common.sol';
import {Player, RoomStore, ObjectStore, Output} from '../codegen/index.sol';

contract InventorySystem is System {
    uint constant MAX_OBJ = 32;

    function inventory(address world, uint32 playerId) public returns (uint8 err) {
        uint32[32] memory objIds = Player.getObjectIds(playerId);
        uint32 objCount = countNonZero(objIds);

        if (objCount == 0) {
            Output.set(playerId,"Your carrier bag is empty");
            return 0;
        }

        string memory itemTxt = "You have a ";
        for (uint8 i = 0; i < objCount; i++) {
            uint32 objectId = objIds[i];
                if(i > 0) {
                    itemTxt = string.concat(itemTxt, " and a ");
                }
                itemTxt = string(abi.encodePacked(itemTxt, IWorld(world).mp_TokeniserSystem_getObjectNameOfObjectType(ObjectStore.getObjectType(objectId))));
        }
        Output.set(playerId,itemTxt);
        return 0;
    }

    function take(address world, string[] memory tokens, uint32 rId, uint32 playerId) public returns (uint8 err) {
        uint8 tok_err;
        bool itemPickedUp = false;
        string memory tok = tokens[1];
        ObjectType objType = IWorld(world).mp_TokeniserSystem_getObjectType(tok);
        if (objType != ObjectType.None) {

            uint32[MAX_OBJ] memory roomObjIds = RoomStore.getObjectIds(rId);

            uint32 roomObjCount = countNonZero(roomObjIds);
            console.log("----->TAKE room object item count:%d", roomObjCount);

            for (uint8 i = 0; i < roomObjCount; i++) {
                ObjectType testType = ObjectStore.getObjectType(roomObjIds[i]);
                if (testType == objType) {
                    Output.set(playerId,"You picked it up");

                    // add the item to the inventory
                    uint32[32] memory playerObjIds = Player.getObjectIds(playerId);
                    addElement(playerObjIds, roomObjIds[i]);
                    Player.setObjectIds(playerId, playerObjIds);

                    // delete from the room
                   removeElement(roomObjIds, i);
                   RoomStore.setObjectIds(rId, roomObjIds);

                    itemPickedUp = true;
                    break;
                }
            }
        }

        if (itemPickedUp == false) {
            Output.set(playerId,"That isn't here");
        }

        return 0;
    }


    function drop(address world, string[] memory tokens, uint32 rId, uint32 playerId) public returns (uint8 err) {
        uint8 tok_err;
        string memory tok = tokens[1];
        ObjectType objType = IWorld(world).mp_TokeniserSystem_getObjectType(tok);
        if (objType != ObjectType.None) {
            uint32[MAX_OBJ] memory playerObjIds = Player.getObjectIds(playerId);

            for (uint8 i = 0; i < playerObjIds.length; i++) {

                ObjectType testType = ObjectStore.getObjectType(playerObjIds[i]);
                if (testType == objType) {
                    Output.set(playerId,"You took the item from your faded Aldi bag and placed it on the floor");

                    // add the item to the room
                    uint32[32] memory roomObjIds = RoomStore.getObjectIds(rId);
                    addElement(roomObjIds, playerObjIds[i]);
                    RoomStore.setObjectIds(rId, roomObjIds);

                    // delete from the inventory
                    removeElement(playerObjIds, i);
                    Player.setObjectIds(playerId, playerObjIds);

                    return 0;
                }
            }
            Output.set(playerId,"That item is not in the Aldi carrer bag");
            return 0;
        }
        Output.set(playerId,"I'm not sure what one of those is");

        return 0;
    }

       function countNonZero(uint32[MAX_OBJ] memory arr) private pure returns (uint32) {
        uint32 count = 0;
        for (uint8 i = 0; i < arr.length; i++) {
            if (arr[i] != 0) {
                count++;
            }
        }
        return count;
    }

    function addElement(uint32[MAX_OBJ] memory arr, uint32 element) private pure returns (bool) {
        for (uint8 i = 0; i < arr.length; i++) {
            if (arr[i] == 0) {
                arr[i] = element;
                return true;
            }
        }
        return false; // Array is full
    }

    function removeElement(uint32[MAX_OBJ] memory arr, uint8 index) private pure returns (bool) {
        if (index >= arr.length || arr[index] == 0) {
            return false;
        }
        for (uint8 i = index; i < arr.length - 1; i++) {
            arr[i] = arr[i + 1];
        }
        arr[arr.length - 1] = 0;
        return true;
    }

}


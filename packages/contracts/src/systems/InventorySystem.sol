// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import {console} from "forge-std/console.sol";
import {System} from "@latticexyz/world/src/System.sol";
import {IWorld} from '../codegen/world/IWorld.sol';
import {ITokeniserSystem} from '../codegen/world/ITokeniserSystem.sol';
import {ObjectType} from '../codegen/common.sol';
import {Player, RoomStore, ObjectStore, Output} from '../codegen/index.sol';
import { Constants } from '../constants/Constants.sol';

contract InventorySystem is System, Constants {
    
    function inventory(address world, uint32 playerId) public returns (uint8 err) {
        uint32[32] memory objIds = Player.getObjectIds(playerId);
        uint256 objCount = objIds.length;

        if (objCount == 0) {
            Output.set(playerId, "Your carrier bag is empty");
            return 0;
        }

        string memory itemTxt = "You have a ";
        bool firstItem = true;

        for (uint8 i = 0; i < objCount; i++) {
            uint32 objectId = objIds[i];
            if (objectId == 0) {
                continue;
            }
            if (!firstItem) {
                itemTxt = string.concat(itemTxt, " and a ");
            }
            itemTxt = string(abi.encodePacked(itemTxt, IWorld(world).mp_TokeniserSystem_getObjectNameOfObjectType(ObjectStore.getObjectType(objectId))));
            firstItem = false;
        }

        if (firstItem) {
            // If firstItem is still true, it means all items were 0
            Output.set(playerId, "Your carrier bag is empty");
        } else {
            Output.set(playerId, itemTxt);
        }
        return 0;
    }

    function take(address world, string[] memory tokens, uint32 rId, uint32 playerId) public returns (uint8 err) {
        uint8 tok_err;
        bool itemPickedUp = false;
        string memory tok = tokens[1];
        ObjectType objType = IWorld(world).mp_TokeniserSystem_getObjectType(tok);
        if (objType != ObjectType.None) {

            uint32[MAX_OBJ] memory roomObjIds = RoomStore.getObjectIds(rId);

            uint256 roomObjCount = roomObjIds.length;
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


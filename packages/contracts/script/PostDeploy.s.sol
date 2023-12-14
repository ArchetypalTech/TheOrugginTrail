// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";

import { IWorld } from "../src/codegen/world/IWorld.sol";


// import the Room Map types
import { RoomType } from "../src/codegen/common.sol";
import { ActionType } from "../src/codegen/common.sol";
import { ObjectType } from "../src/codegen/common.sol";


import { RoomStore } from "../src/codegen/index.sol";
import { ObjectStore } from "../src/codegen/index.sol";
import { ActionStore } from "../src/codegen/index.sol";
import { GameMap } from "../src/codegen/index.sol";

contract PostDeploy is Script {
  function run(address worldAddress) external {
    // Specify a store so that you can use tables directly in PostDeploy
    StoreSwitch.setStoreAddress(worldAddress);

    // Load the private key from the `PRIVATE_KEY` environment variable (in .env)
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

    // Start broadcasting transactions from the deployer account
    vm.startBroadcast(deployerPrivateKey);

    uint32 newValue = IWorld(worldAddress).initData();
    console.log("World initialised", newValue);

    // Generate MapData, we are just gonna cheat
    // right now
    console.log("Running map creation");
    RoomType O = RoomType.Void;
    RoomType X = RoomType.Place;

    RoomType[4][4] memory map = [
        [O,O,O,X],
        [O,O,O,X],
        [O,O,O,O],
        [O,O,O,O]
    ];

    // OBJECTS: The DOOR
    // as this needs an Open action we are gonna store a
    // new row on that table we can use this on other 
    // Objects now that its initialised
    uint32 openDoorActionId = 3;
    ActionStore.set(openDoorActionId, ActionType.Open);
    
    // ACTIONS: we need an array of actionId's to pass to the Door Object 
    uint32[] memory actionIds = new uint32[](3);
    actionIds[0] = openDoorActionId;
    uint32 doorObjectId = 1;
    ObjectStore.set(doorObjectId, ObjectType.Door, 7, actionIds);
    
    // We now have stored a Door type object 
    // (with an objectId of 1 in the ObjectStore) that has in turn 
    // had the Open action set on it (stored at actionId 3 in the ActionsStore)
    // It also has a textDefId of 7 set on it but we haven't actually made one of
    // those rows yet.
    uint32[] memory objectIds = new uint32[](3);
    objectIds[0] = doorObjectId;


    // Now parse the map and build the rooms
    // first we need to allocate the memory
    // we will store the roomId's in this map
    // and then we will some thing clever like
    // set a start poition to the console?
    uint8 h = uint8(map.length);
    uint8 w = uint8(map[0].length);
    uint32[] memory worldMap = new uint32[](h * w);

    console.log("Running room creation");
    for(uint32 y = 0; y < h; y++ ) {
        for( uint32 x = 0; x < w; x++) {
            RoomType room = map[x][y];
            if (room == RoomType.Void) continue;
            // Now we will make a room and based on
            // right now pure bullshit give it some 
            // Door objects we are sharing the door object
            // becasue we are cheating.
            uint32 newRoomId = x * y;
            RoomStore.set(newRoomId, RoomType.Place, 9, objectIds);
            worldMap[(y * w) + x] = newRoomId;
        }
    }

    // now add these roomId's to the GameMap singleton
    GameMap.set(w, h, worldMap);

    // I guess we need to alert the console now...

    vm.stopBroadcast();
  }
}

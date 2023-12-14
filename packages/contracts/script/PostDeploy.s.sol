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

    // parse the map and build the rooms
    // first we need to allocate the memory
    // we will store the roomId's in this map
    // and then we will some thing clever like
    // set a start poition to the console?
    uint8 h = uint8(map.length);
    uint8 w = uint8(map[0].length);
    bytes memory worldMap = new bytes(h * w);
    
    console.log("Running room creation");
    for(uint32 y = 0; y < h; y++ ) {
        for( uint32 x = 0; x < w; x++) {
            RoomType room = map[x][y];
            if (room == RoomType.Void) continue;
            // Now we will make a room and based on
            // right now pure bullshit give it some 
            // Door objects and give those Door O's
            // some Actions, well the Open action anyway
            // The DOOR
            // as this needs an Open action we are gonna store a
            // new row on that table
            ActionStore.set(1, ActionType.Open);
            //Object.set

        }
    }

    vm.stopBroadcast();
  }
}

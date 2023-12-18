// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";

import { IWorld } from "../src/codegen/world/IWorld.sol";


// import the Room Map types
import { BiomeType } from "../src/codegen/common.sol";
import { TerrainType } from "../src/codegen/common.sol";
import { RoomType } from "../src/codegen/common.sol";
import { ActionType } from "../src/codegen/common.sol";
import { ObjectType } from "../src/codegen/common.sol";
import { TexDefType } from "../src/codegen/common.sol";
import { MaterialType } from "../src/codegen/common.sol";


import { RoomStore } from "../src/codegen/index.sol";
import { ObjectStore } from "../src/codegen/index.sol";
import { ActionStore } from "../src/codegen/index.sol";
import { GameMap } from "../src/codegen/index.sol";

import { Constants } from "../src/constants/defines.sol";

contract PostDeploy is Script, Constants {

    // make the basic data for initial work on dev around
    // maps and actions etc this is only for an intial stab 
    // at general object linkage and useage 
    function setupData() internal {
        // OBJECTS: The DOOR
        // it's a wooden door and it opens
        uint8 dir = NORTH_DIR | SOUTH_DIR;
        ActionStore.set(
            OPEN_ACTION_ID, ActionType.Open, 
            OPEN_ACTION_DESC_ID, true, 5
        );
        uint32[] memory actionIds = new uint32[](3);
        actionIds[0] = OPEN_ACTION_ID;

        ObjectStore.set(
            WOOD_DOOR_OBJECT_ID, ObjectType.Door, 
            MaterialType.Wood, WOOD_DOOR_DESC_ID,
            actionIds
        );

    }

    function setupMapData() internal {
        console.log("Running map creation");
        // Pack a bunch of bits into the uint32 using 4 blocks
        // | TERRAIN | ROOM | OBJECT | ACTION |
        uint32 O = uint32(TerrainType.None);
        uint32 X = uint32(uint32(TerrainType.DirtPath) << TERRAIN_BITS);
        uint32 P = uint32(uint32(TerrainType.Portal) << TERRAIN_BITS);
        uint32 C = uint32(uint32(RoomType.WoodCabin) << ROOM_BITS);

        // a DIRT PATH heads EAST then a DOOR
        // to a CABIN appears to the SOUTH
        uint32[4][4] memory map = [
            [X,X,X,O],
            [O,O,P,O],
            [X,P,C,O],
            [O,O,O,O]
        ];

        uint8 h = uint8(map.length);
        uint8 w = uint8(map[0].length);
        uint32[] memory worldMap = new uint32[](h * w);

        // build up the rooms from the map
        console.log("Running room creation");
        for(uint32 y = 0; y < h; y++ ) {
            for( uint32 x = 0; x < w; x++) {
                uint32 room = map[x][y];
                if (room & uint32(RoomType.None) == 0) continue;
                // parse the map data to "rooms" 
                if ( room & X == 0x1000000 ) {
                    // dirt path
                }else if ( room & P == 0x6000000 ) {
                    // portal
                }else if ( room & C == 0x10000 ) {
                    // log cabin
                }
            }
        }
        // now add these roomId's to the GameMap singleton
        GameMap.set(w, h, worldMap);
    }


    function run(address worldAddress) external {
        // Specify a store so that you can use tables directly in PostDeploy
        StoreSwitch.setStoreAddress(worldAddress);

        // Load the private key from the `PRIVATE_KEY` environment variable (in .env)
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        // Start broadcasting transactions from the deployer account
        vm.startBroadcast(deployerPrivateKey);

        uint32 newValue = IWorld(worldAddress).initData();
        console.log("World initialised", newValue);

        setupData();
        setupMapData();

        vm.stopBroadcast();
    }
}

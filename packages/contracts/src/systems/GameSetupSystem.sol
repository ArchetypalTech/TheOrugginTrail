// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

// get some debug OUT going
import {console} from "forge-std/console.sol";
import {System} from "@latticexyz/world/src/System.sol";
import {Output, CurrentRoomId, RoomStore, RoomStoreData, ActionStore, TextDef, DirObjStore} from "../codegen/index.sol";
import {ActionType, RoomType, ObjectType, CommandError, DirectionType} from "../codegen/common.sol";

// NOTE of interest in the return types of the functions, these
// are later used in the logs of the game provided by the MUD
// dev tooling
contract GameSetupSystem is System {

    uint32 dirId = 0;

    function init() public returns (uint32) {

        setupWorld();
        // we are right now initing the data in the
        Output.set('init called...');
        return 0;
    }

    function setupWorld() private {
        // really wanted the code to look like this
        // createRoom(KPlain, 'You are on a plain with the wind blowing', [createDir(DirectionType.North,KBarn),createDir(DirectionType.East, KMountainPath)]);
        // but the dynamic arrays we use must be setup and passed as they are below

        uint32 KPlain = 0;
        uint32 KBarn = 1;
        uint32 KMountainPath = 2;

        // plain has two exits, the mountain path and the barn
        uint32[] memory plainDirs = new uint32[](2);
        plainDirs[0] = createDir(DirectionType.North, KBarn);
        plainDirs[1] = createDir(DirectionType.East, KMountainPath);
        createRoom(KPlain, 'You are on a plain with the wind blowing', plainDirs);

        // barn has one exit, back to the plain
        uint32[] memory barnDirs = new uint32[](1);
        barnDirs[0] = createDir(DirectionType.South, KPlain);
        createRoom(KBarn, 'You are in the barn', barnDirs);

        // mountain path has only one exit now, back to the plain
        uint32[] memory mountainDirs = new uint32[](1);
        mountainDirs[0] = createDir(DirectionType.West, KPlain);
        createRoom(KMountainPath, 'You are on the mountain path, you cant go any further though', mountainDirs);
    }

    function createDir(DirectionType directionType, uint32 roomId) private returns (uint32){
        DirObjStore.setDirType(dirId, uint8(directionType));
        DirObjStore.setRoomId(dirId, roomId);
        return ++dirId;
    }

    function createRoom(uint32 roomId, string memory description, uint32[] memory dirs) private {
        RoomStore.setDescription(roomId, description);
        for (uint8 i = 0; i < dirs.length; i++) {
            RoomStore.pushDirObjIds(roomId, dirs[i]);
        }
    }
}


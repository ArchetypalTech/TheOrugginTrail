// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

// get some debug OUT going
import { console } from "forge-std/console.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { Description, ObjectStore, DirObjectStore, Player, Output, CurrentPlayerId, RoomStore, RoomStoreData, ActionStore, TextDefStore } from "../codegen/index.sol";
import { ActionType, RoomType, ObjectType, CommandError, DirectionType, DirObjectType, TxtDefType, MaterialType } from "../codegen/common.sol";

// NOTE of interest in the return types of the functions, these
// are later used in the logs of the game provided by the MUD
// dev tooling
contract GameSetupSystem is System {

    uint32 dirId = 1;
    uint32 objId = 1;

    function init() public returns (uint32) {

        setupWorld();

        // we are right now initing the data in the
        Output.set('init called...');
        return 0;
    }

    // left in here as an example for how to call systems via the world
    // see MeatPuppetSystem for call
    function setupCmds(uint32 cmds) public returns (uint32) {
       // maybe populate the unused VERB tables etc? for now we just use
       // the mapping thats in the GE.
       return 23;
    }

    function setupWorld() private {
        setupRooms();
        setupPlayer();
    }

    function setupPlayer() private {
        // tim, whats the method to create a random int32????
        CurrentPlayerId.set(1);
    }

    function setupRooms() private {
        uint32 KPlain = 2;
        uint32 KBarn = 1;
        uint32 KMountainPath = 0;

        // plain has two exits, the mountain path and the barn
        // PATH, MUD, NORTH
        RoomStore.pushDirObjIds(KPlain,  createDirObj(DirectionType.North, KBarn, 
                                                      DirObjectType.Path, MaterialType.Dirt,
                                                        "a path heading north to a barn"));
        // PATH, MOUNTAIN, EAST
        RoomStore.pushDirObjIds(KPlain,  createDirObj(DirectionType.East, KMountainPath, 
                                                      DirObjectType.Path, MaterialType.Mud,
                                                        "a path east heading into the mountains"));
        
        RoomStore.setDescription(KPlain,  'You are on a plain with the wind blowing');


        bytes32 tid_plain = keccak256(abi.encodePacked('You are on a plain with the wind blowing'));
        TextDefStore.set(tid_plain, TxtDefType.Place, KPlain, 'You are on a plain with the wind blowing'); 

        // this is probably correct, adding the description at build time 
        RoomStore.pushObjectIds(KPlain, createObject(ObjectType.Football, 
                                                     MaterialType.Flesh,
                                                     "A slightly deflated knock off uefa football,"
                                                     "not quite speherical, it's "
                                                     "kickable though"
                                                    ));


        // barn has one exit, back to the plain
        // Im adding a description to the dirObj but this is probably wrong
        // we should add a type, i.e. a DOOR, of WOOD, SOUTH then compose the description
        RoomStore.pushDirObjIds(KBarn,  createDirObj(DirectionType.South, KPlain, 
                                                     DirObjectType.Door, MaterialType.Wood,  
                                                     "a door to the south"));

        // get the hash use as identifier
        bytes32 tid_barn = keccak256(abi.encodePacked("The place is dusty and full of spiderwebs, " 
                                                        "something died in here"));  

    
        TextDefStore.set(tid_barn, TxtDefType.Place, KBarn,
                                                    "The place is dusty and full of spiderwebs,"
                                                    "something died in here");

        RoomStore.setDescription(KBarn, 'You are in the barn');// this should be auto gen
        RoomStore.setTxtDefId(KBarn, tid_barn);

        // mountain path has only one exit now, back to the plain
        // as above but a PATH, of MUD, WEST
        RoomStore.pushDirObjIds(KMountainPath,  createDirObj(DirectionType.West, KPlain,
                                                             DirObjectType.Path, MaterialType.Dirt,
                                                             "a path leads to the west heading down "
                                                             "to the plains below"));
        
        // TODO: move this into a textDef
        RoomStore.setDescription(KMountainPath,  "You are on the mountain path, "
                                                    "you cant go any further though");

    }

    function createDirObj(DirectionType directionType, uint32 destId, DirObjectType dType,
                                                    MaterialType mType,string memory desc) 
                                                                    private returns (uint32) {
        DirObjectStore.setDirType(dirId, directionType);
        DirObjectStore.setDestId(dirId, destId);
        DirObjectStore.setMatType(dirId, MaterialType.IKEA);
        DirObjectStore.setObjType(dirId, dType);
        TextDefStore.set(keccak256(abi.encodePacked(desc)), TxtDefType.DirObject, dirId, desc);
        DirObjectStore.setTxtDefId(dirId, keccak256(abi.encodePacked(desc)));
        return dirId++;
    }

    function createObject(ObjectType objectType, MaterialType mType, string memory desc) private returns (uint32){
        ObjectStore.setObjectType(objId, objectType);
        ObjectStore.setMaterialType(objId, mType);
        TextDefStore.set( keccak256(abi.encodePacked(desc)), TxtDefType.Object, objId, desc); 
        ObjectStore.setTexDefId(objId, keccak256(abi.encodePacked(desc)));
        return objId++;
    }

    //function createPlace(uint32 id, RoomType rType, ) private returns (uint32) {
    //}
}


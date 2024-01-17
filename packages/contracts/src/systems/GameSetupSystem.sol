// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

// get some debug OUT going
import { console } from "forge-std/console.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { ErrCodes } from '../constants/defines.sol';
import { Description, ObjectStore, ObjectStoreData , DirObjectStore, DirObjectStoreData, Player, Output, CurrentPlayerId, RoomStore, RoomStoreData, ActionStore, ActionStoreData,TxtDefStore } from "../codegen/index.sol";
import { ActionType, RoomType, ObjectType, CommandError, DirectionType, DirObjectType, TxtDefType, MaterialType } from "../codegen/common.sol";

// NOTE of interest in the return types of the functions, these
// are later used in the logs of the game provided by the MUD
// dev tooling
contract GameSetupSystem is System {

    uint32 dirObjId = 1;
    uint32 objId = 1;
    uint32 actionId = 1;

    uint32[256] private map;

    function init() public returns (uint32) {

        setupWorld();

        // we are right now initing the data in the
        Output.set('init called...');
        return 0;
    }

    function getArrayValue(uint8 index) public view returns (uint32, uint8 er) {
        if (index > 255) {
            return (0, ErrCodes.ER_AR_BNDS);
        }
        return (map[index], 0);
    }

    function setupWorld() private {
        setupRooms();
        setupPlayer();
    }

    function guid() private view returns (uint32) {
        bytes32 hash = keccak256(
            abi.encodePacked(
                block.timestamp,
                block.prevrandao,
                blockhash(block.number - 1),
                msg.sender
            )
        );
        return uint32(uint256(hash));
    }

    function setupPlayer() private {
        // tim, whats the method to create a random int32????
        // Daren, there is no pseudo random number gen but there
        // is some semi entropic stuff we can hash see guid()
        CurrentPlayerId.set(guid());
    }

    function clearArr(uint32[] memory arr) private pure {
        for (uint8 i = 0; i < 32; i++) {
            arr[i] = 0;
        }
    }

    function createPlace(uint32 id, uint32[] memory dirObjects, uint32[] memory objects, bytes32 txtId) public {
        for (uint8 i = 0; i < dirObjects.length; i++) {
                RoomStore.pushDirObjIds(id, dirObjects[i]);
        }
        for (uint8 i = 0; i < objects.length ; i++) {
                RoomStore.pushObjectIds(id, objects[i]);
        }
        RoomStore.setTxtDefId(id,txtId);
    }

    function setupRooms() private {
        uint32 KPlain = 2;
        uint32 KBarn = 1;
        uint32 KMountainPath = 0;

        // much bigger than this and it seems to blow up the stack?
        // panic capicty error hence I assume blown stack
        uint32[] memory dids = new uint32[](32);
        uint32[] memory oids = new uint32[](32);
        uint32[] memory directionActionIds = new uint32[](32);

        // KPLAIN
        dids[0] = createDirObj(DirectionType.North, KBarn,
                              DirObjectType.Path, MaterialType.Dirt,
                              "path",directionActionIds);

        dids[1] = createDirObj(DirectionType.East, KMountainPath,
                              DirObjectType.Path, MaterialType.Mud,
                              "path",directionActionIds);

        directionActionIds[0] = createAction(ActionType.Break, "Broken Window", false );

        dids[2] = createDirObj(DirectionType.South, KMountainPath,
            DirObjectType.Path, MaterialType.Glass,
            "Window", directionActionIds);
        clearArr(directionActionIds);

        // TODO creat a kick action and add to the football
        oids[0] = createObject(ObjectType.Football, MaterialType.Flesh,
                                "A slightly deflated knock off uefa football,\n"
                                "not quite spherical, it's "
                                "kickable though", "football");


        RoomStore.setDescription(KPlain,  'a windswept plain');
        RoomStore.setRoomType(KPlain,  RoomType.Plain);

        bytes32 tid_plain = keccak256(abi.encodePacked('a windsept plain'));
        TxtDefStore.set(tid_plain, KPlain, TxtDefType.Place, "the wind blowing is cold and\n"
                                                                "bison skulls in piles taller than houses\n"
                                                                "cover the plains as far as your eye can see\n"
                                                                "the air tastes of burnt grease and bensons.");

        createPlace(KPlain, dids, oids, tid_plain);


        // KBARN
        // TODO add a smash action to the window
        clearArr(dids);
        clearArr(oids);


        dids[0] = createDirObj(DirectionType.South, KPlain,
                                DirObjectType.Door, MaterialType.Wood,
                                "door",directionActionIds

                               );

        bytes32 tid_barn = keccak256(abi.encodePacked("a barn"));
        TxtDefStore.set(tid_barn, KBarn, TxtDefType.Place,
                                                    "The place is dusty and full of spiderwebs,\n"
                                                    "something died in here, possibly your own self\n"
                                                    "plenty of corners and dark shadows");


        RoomStore.setDescription(KBarn, 'a barn');// this should be auto gen
        RoomStore.setRoomType(KBarn, RoomType.Room);

        createPlace(KBarn, dids, oids, tid_barn);

        // KPATH
        clearArr(dids);
        clearArr(oids);

        dids[0] = createDirObj(DirectionType.West, KPlain,
                               DirObjectType.Path, MaterialType.Stone,
                               "path",directionActionIds);


        bytes32 tid_mpath = keccak256(abi.encodePacked("a high mountain pass"));
        TxtDefStore.set(tid_mpath, KMountainPath, TxtDefType.Place,
                         "it winds through the mountains, the path is treacherous\n"
                         "toilet papered trees cover the steep \nvalley sides below you.\n"
                         "On closer inspection the TP might \nbe the remains of a cricket team\n"
                         "or pehaps a lost and very dead KKK picnic group.\n"
                         "It's brass monkeys.");

        RoomStore.setDescription(KMountainPath,  "a high mountain pass");
        RoomStore.setRoomType(KMountainPath,  RoomType.Plain);
        createPlace(KMountainPath, dids, oids, tid_mpath);
    }



    function createDirObj(DirectionType dirType, uint32 dstId, DirObjectType dOType,
                                                    MaterialType mType,string memory desc, uint32[] memory actionObjects)
                                                                    private returns (uint32) {
        bytes32 txtId = keccak256(abi.encodePacked(desc));
        TxtDefStore.set(txtId, dirObjId, TxtDefType.DirObject, desc);
        DirObjectStoreData memory dirObjData = DirObjectStoreData(dOType, dirType, mType, dstId, txtId, actionObjects);
        DirObjectStore.set(dirObjId, dirObjData);
        return dirObjId++;
    }

    function createObject(ObjectType objType, MaterialType mType, string memory desc, string memory name) private returns (uint32){
        bytes32 txtId = keccak256(abi.encodePacked(desc));
        TxtDefStore.set(txtId, objId, TxtDefType.Object, desc);
        uint32[] memory actions = new uint32[](0);
        ObjectStoreData memory objData = ObjectStoreData(objType, mType, txtId, actions, name);
        ObjectStore.set(objId, objData);
        return objId++;
    }

    function createAction(ActionType actionType, string memory desc, bool pBit) private returns (uint32){
        bytes32 txtId = keccak256(abi.encodePacked(desc));
        TxtDefStore.set(txtId, actionId, TxtDefType.Action, desc);
        ActionStoreData memory actionData = ActionStoreData(actionType,txtId,pBit);
        ActionStore.set(actionId, actionData);
        return actionId++;
    }

}

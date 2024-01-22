// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

// get some debug OUT going
import { console } from "forge-std/console.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { ErrCodes } from '../constants/defines.sol';
import { Constants } from '../constants/Constants.sol';
import {SizedArray} from '../libs/SizedArrayLib.sol';
import { Description, ObjectStore, ObjectStoreData , DirObjectStore, DirObjectStoreData, Player, Output, CurrentPlayerId, RoomStore, RoomStoreData, ActionStore, ActionStoreData,TxtDefStore } from "../codegen/index.sol";
import { ActionType, RoomType, ObjectType, CommandError, DirectionType, DirObjectType, TxtDefType, MaterialType } from "../codegen/common.sol";

contract GameSetupSystem is System, Constants {
    
    uint32 dirObjId = 1;
    uint32 objId = 1;
    uint32 actionId = 1;
    uint32 KForest = 3;
    uint32 KPlain = 2;
    uint32 KBarn = 1;
    uint32 KMountainPath = 0;
    
    function init() public returns (uint32) {
        setupWorld();
        return 0;
    }

    function setupWorld() private {
        setupRooms();
        setupPlayer();
    }

    function textGuid(string memory str) private returns (uint32) {
        bytes4 trunc = bytes4(keccak256(abi.encodePacked(str)));
        return uint32(trunc);
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
        uint32 g = uint32(uint256(hash));
        return g++;
    }

    function setupPlayer() private {
        CurrentPlayerId.set(guid());
    }

    function clearArr(uint32[MAX_OBJ] memory arr) private view {
        console.log("---> clear");
        for (uint8 i = 0; i < MAX_OBJ; i++) {
            arr[i] = 0;
        }
    }

    function createPlace(uint32 id, uint32[32] memory dirObjects, uint32[32] memory objects, bytes32 txtId) public {
        for (uint8 i = 0; i < dirObjects.length; i++) {
                RoomStore.pushDirObjIds(id, dirObjects[i]);
        }
        for (uint8 i = 0; i < objects.length ; i++) {
                RoomStore.pushObjectIds(id, objects[i]);
        }
        RoomStore.setTxtDefId(id,txtId);
    }
    
    function _setupPlain() private {
        // KPLAIN -> N, E
        uint32 open_2_barn = createAction(ActionType.Open, "the door opens with a farty noise\n"
                                "oddly you can actually smell fart",
                                true, true);  
        
        uint32[MAX_OBJ] memory plain_barn;
        uint32[MAX_OBJ] memory dObjs;
        uint32[MAX_OBJ] memory objs;
        
        plain_barn[0] = open_2_barn;

        dObjs[0] = createDirObj(DirectionType.North, KBarn, 
                              DirObjectType.Path, MaterialType.Dirt, 
                              "path", plain_barn);

        uint32 open_2_path = createAction(ActionType.Open, "the door opens and a small hinge demon curses you\n"
                                "your nose is really itchy",
                                true, true);  

        uint32[MAX_OBJ] memory plain_path;
        plain_barn[0] = open_2_path;
        dObjs[1] = createDirObj(DirectionType.East, KMountainPath, 
                              DirObjectType.Path, MaterialType.Mud,
                              "path", plain_path);

        uint32 kick = createAction(ActionType.Kick, "the ball (such as it is)"
                                "bounces feebly\n then rolls into some fresh dog eggs\n"
                                "none the less you briefly feel a little better",
                                true, false);  
        
        uint32[MAX_OBJ] memory ball_actions;
        ball_actions[0] = kick;

        objs[0] = createObject(ObjectType.Football, MaterialType.Flesh,
                                "A slightly deflated knock off uefa football,\n"
                                "not quite spherical, it's "
                                "kickable though", "football", ball_actions);

        RoomStore.setDescription(KPlain,  'a windswept plain');
        RoomStore.setRoomType(KPlain,  RoomType.Plain);

        bytes32 tid_plain = keccak256(abi.encodePacked('a windsept plain'));
        TxtDefStore.set(tid_plain, KPlain, TxtDefType.Place, "the wind blowing is cold and\n"
                                                                "bison skulls in piles taller than houses\n"
                                                                "cover the plains as far as your eye can see\n"
                                                                "the air tastes of burnt grease and bensons.");

        createPlace(KPlain, dObjs, objs, tid_plain);
    }

    function _setupBarn() private {
        // KBARN -> S
        // TODO add a smash action to the window
        uint32 open_2_south = createAction(ActionType.Open, "the door opens\n", true, true);
        uint32[MAX_OBJ] memory barn_plain;
        barn_plain[0] = open_2_south;
        uint32[MAX_OBJ] memory dObjs;
        uint32[MAX_OBJ] memory objs;
        dObjs[0] = createDirObj(DirectionType.South, KPlain,
                                DirObjectType.Door, MaterialType.Wood,
                                "door", barn_plain); 

        uint32 open_2_forest = createAction(ActionType.Open, "the window, glass and frame smashed"
                                "falls open\n", true, false);
        
        uint32 smash_window = createAction(ActionType.Break, "I love the sound of breaking glass\n"
                                "especially when I'm lonely, the panes and the frame shatter\n"
                                "satisfyingly spreading broken joy on the floor"
                                , true, false);

        uint32[MAX_OBJ] memory window_actions;
        window_actions[0] = open_2_forest;
        window_actions[1] = smash_window;

        dObjs[1] = createDirObj(DirectionType.East, KForest,
                                DirObjectType.Window, MaterialType.Wood,
                                "window", window_actions); 

        bytes32 tid_barn = keccak256(abi.encodePacked("a barn"));
        TxtDefStore.set(tid_barn, KBarn, TxtDefType.Place,
                                                    "The place is dusty and full of spiderwebs,\n"
                                                    "something died in here, possibly your own self\n"
                                                    "plenty of corners and dark shadows");


        RoomStore.setDescription(KBarn, 'a barn'); // this should be auto gen
        RoomStore.setRoomType(KBarn, RoomType.Room);
        createPlace(KBarn, dObjs, objs, tid_barn);
    }

    function _createMountainPath() private {
        // KPATH -> W
        uint32 open_2_west = createAction(ActionType.Open, "the path is passable", true, true); 
        uint32[MAX_OBJ] memory path_actions;
        path_actions[0] = open_2_west;

        uint32[MAX_OBJ] memory dirObjs;
        uint32[MAX_OBJ] memory objs;
        // this is a path we might want to say BLOCK it which would mean adding a BLOCK
        // and an OPEN which we would set to false but as can be seen above right
        // now its just open and there is no state change to describe it
        dirObjs[0] = createDirObj(DirectionType.West, KPlain,
                               DirObjectType.Path, MaterialType.Stone,
                               "path", path_actions);



        bytes32 tid_mpath = keccak256(abi.encodePacked("a high mountain pass"));
        TxtDefStore.set(tid_mpath, KMountainPath, TxtDefType.Place,
                         "it winds through the mountains, the path is treacherous\n"
                         "toilet papered trees cover the steep \nvalley sides below you.\n"
                         "On closer inspection the TP might \nbe the remains of a cricket team\n"
                         "or pehaps a lost and very dead KKK picnic group.\n"
                         "It's brass monkeys.");

        RoomStore.setDescription(KMountainPath,  "a high mountain pass");
        RoomStore.setRoomType(KMountainPath,  RoomType.Plain);
        createPlace(KMountainPath, dirObjs, objs, tid_mpath);

    }

    function setupRooms() private {
        _setupPlain();
        _setupBarn();
        _createMountainPath();
    }

    function createDirObj(DirectionType dirType, uint32 dstId, DirObjectType dOType,
                                                    MaterialType mType,string memory desc, uint32[MAX_OBJ] memory actionObjects)
                                                                    private returns (uint32) {
        bytes32 txtId = keccak256(abi.encodePacked(desc));
        TxtDefStore.set(txtId, dirObjId, TxtDefType.DirObject, desc);
        DirObjectStoreData memory dirObjData = DirObjectStoreData(dOType, dirType, mType, dstId, txtId, actionObjects);
        DirObjectStore.set(dirObjId, dirObjData);
        return dirObjId++;
    }

    function createObject(ObjectType objType, MaterialType mType, string memory desc, string memory name, uint32[MAX_OBJ] memory actions) private returns (uint32) {
        bytes32 txtId = keccak256(abi.encodePacked(desc));
        TxtDefStore.set(txtId, objId, TxtDefType.Object, desc);
        ObjectStoreData memory objData = ObjectStoreData(objType, mType, txtId, actions, name);
        ObjectStore.set(objId, objData);
        return objId++;
    }

    function createAction(ActionType actionType, string memory desc, bool enabled, bool dBit) private returns (uint32) {
        bytes32 txtId = keccak256(abi.encodePacked(desc));
        uint32 aId = textGuid(desc);
        TxtDefStore.set(txtId, aId, TxtDefType.Action, desc);
        ActionStoreData memory actionData = ActionStoreData(actionType, txtId, enabled, dBit);
        ActionStore.set(aId, actionData);
        return aId;
    }

}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

// get some debug OUT going
import { console } from "forge-std/console.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { IWorld } from "../codegen/world/IWorld.sol";
import { ErrCodes } from '../constants/defines.sol';
import { Constants } from '../constants/Constants.sol';
import {SizedArray} from '../libs/SizedArrayLib.sol';
import { Description, ObjectStore, ObjectStoreData , DirObjectStore, DirObjectStoreData, Player, Output, RoomStore, RoomStoreData, ActionStore, ActionStoreData,TxtDefStore } from "../codegen/index.sol";
import { ActionType, RoomType, ObjectType, CommandError, DirectionType, DirObjectType, TxtDefType, MaterialType } from "../codegen/common.sol";

/**
 * @dev We use this to setup the word for dev and we could use this to setup
 * the world for reals. But right now we arent this is pure test mode.
 */
contract GameSetupSystem is System, Constants {

    uint32 dirObjId = 1;
    uint32 objId = 1;
    uint32 actionId = 1;
    uint32 KCellar = 4;
    uint32 KForge = 3;
    uint32 KPlain = 2;
    uint32 KBarn = 1;
    uint32 KMountainPath = 0;

    function init() public returns (uint32) {
        _setupWorld();
        return 0;
    }

    function _setupWorld() private {
        _setupRooms();
        _setupPlayers();
        IWorld(_world()).mp_TokeniserSystem_initLUTS();
        IWorld(_world()).mp_MeatPuppetSystem_spawnPlayer(1,1);
    }

    function _textGuid(string memory str) private returns (uint32) {
        bytes4 trunc = bytes4(keccak256(abi.encodePacked(str)));
        return uint32(trunc);
    }

    function _guid() private view returns (uint32) {
        bytes32 hash = keccak256(
            abi.encodePacked(
                block.timestamp,
                block.prevrandao,
                blockhash(block.number - 1),
                msg.sender
            )
        );
        uint32 g = uint32(uint256(hash));
    }
    // we start the main loop such as it is
    // with the call to `_spawn_player`
    // even though we are actually adding the players
    // to the game...
    function _setupPlayers() private {
        Player.setRoomId(1, 1);
        Player.setRoomId(2, 1);
        Player.setRoomId(3, 1);


        Player.setName(1,"Bob");
        Player.setName(2,"Steve");
        Player.setName(3,"Nigel");

    }

    function _clearArr(uint32[MAX_OBJ] memory arr) private view {
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
                                "you can actually smell fart",
                                true, true, true, 0, 0);

        uint32[MAX_OBJ] memory plain_barn;
        uint32[MAX_OBJ] memory dObjs;
        uint32[MAX_OBJ] memory objs;

        plain_barn[0] = open_2_barn;

        uint32 dirObj1 = createDirObj(DirectionType.North, KBarn,
                              DirObjectType.Path, MaterialType.Dirt,
                              "path", plain_barn);
        dObjs[0] = dirObj1;

        uint32 open_2_path = createAction(ActionType.Open, "the door opens and a small hinge demon curses you\n"
                                "your nose is really itchy",
                                true, true, true, 0, 0);

        uint32[MAX_OBJ] memory plain_path;
        plain_path[0] = open_2_path;
        
        uint32 dirObj2 = createDirObj(DirectionType.East, KMountainPath,
                              DirObjectType.Path, MaterialType.Mud,
                              "path", plain_path);
        dObjs[1] = dirObj2;

        uint32 kick = createAction(ActionType.Kick, "the ball (such as it is)"
                                "bounces feebly\n then rolls into some fresh dog eggs\n"
                                "none the less you briefly feel a little better",
                                true, false, true, 0, 0);

        uint32[MAX_OBJ] memory ball_actions;
        ball_actions[0] = kick;

         uint32 obj1 = createObject(ObjectType.Football, MaterialType.Flesh,
                                "A slightly deflated knock off uefa football,\n"
                                "not quite spherical, it's "
                                "kickable though", "football", ball_actions);
        objs[0] = obj1;

        RoomStore.setDescription(KPlain,  'a windswept plain');
        RoomStore.setRoomType(KPlain,  RoomType.Plain);

        bytes32 tid_plain = keccak256(abi.encodePacked('a windsept plain'));
        TxtDefStore.set(tid_plain, KPlain, TxtDefType.Place, "the wind blowing is cold and\n"
                                                                "bison skulls in piles taller than houses\n"
                                                                "cover the plains as far as your eye can see\n"
                                                                "the air tastes of burnt grease and bensons.");

        createPlace(KPlain, dObjs, objs, tid_plain);
    }

    function _setupForge() private {
        // KForge -> W
        uint32 open_2_barn = createAction(ActionType.Open, "The broken window is still there\n"
		" just don't cut yourself\n", true, true, true, 0, 0);

        uint32[MAX_OBJ] memory forge_barn;        
        uint32[MAX_OBJ] memory dObjs;
        uint32[MAX_OBJ] memory objs;

        forge_barn[0] = open_2_barn;

        uint32 dirObj1 = createDirObj(DirectionType.West, KBarn,
                                DirObjectType.Window, MaterialType.Wood,
                                "window", forge_barn);
        dObjs[0] = dirObj1;

         // Petrol Object
        uint32 burn = createAction(ActionType.Burn, "the petrol (with its unique funny smell)"
		                    "burns fiercely with a scent that makes you feel dizzy", 
                            true, false, true, 0, 0);

        uint32[MAX_OBJ] memory petrol_actions;
        petrol_actions[0] = burn;

        uint32 obj1 = createObject(ObjectType.Petrol, MaterialType.IKEA,
                                "a strange liquid that seems to be petrol,\n"
                                "probably there are about 3 litres of it, "
                                "its highly flammable", "petrol", petrol_actions);
        objs[0] = obj1;


        // Matches Object
        uint32 light = createAction(ActionType.Light, "the matches (despite their small size)"
		                    " lights enough to see a small distance\n"
                            "you have to use them quickly"
                            " or your fingers will get burnt", 
                            true, false, true, 0, 0);

        
        uint32[MAX_OBJ] memory matches_actions;
        matches_actions[0] = light;

        uint32 obj2 = createObject(ObjectType.Matches, MaterialType.Wood,
                                "a box of matches that have survived the passing of the ages,\n"
                                "you can probably light them up, as they seem to be in a good condition\n",
                                "matches", matches_actions);
        objs[1] = obj2;


        RoomStore.setDescription(KForge, 'a dusty forge');
        RoomStore.setRoomType(KForge,  RoomType.Forge);

        bytes32 tid_plain = keccak256(abi.encodePacked('a dusty forge'));
        TxtDefStore.set(tid_plain, KForge, TxtDefType.Place, "you can see that it has not been used in ages.\n"
                                                                "There are many blood spots accross the forge and even the anvil is broken.\n"
                                                                "You don't know what happened here.\n");

        createPlace(KForge, dObjs, objs, tid_plain);
    }

    function _setupBarn() private {
        // KBARN -> S
        uint32 open_2_south = createAction(ActionType.Open, "the door opens\n", true, true, true, 0, 0);
        uint32[MAX_OBJ] memory barn_plain;
        barn_plain[0] = open_2_south;
        uint32[MAX_OBJ] memory dObjs;
        uint32[MAX_OBJ] memory objs;

        uint32 dirObj1 = createDirObj(DirectionType.South, KPlain,
                                DirObjectType.Door, MaterialType.Wood,
                                "door", barn_plain);
        dObjs[0] = dirObj1;

        // KBARN -> E
        // this is NOT enabled NOR OPEN
        uint32 open_2_forge = createAction(ActionType.Open, "the window, glass and frame smashed"
                                " falls open", false, false, false, 0, 0);

        uint32 smash_window = createAction(ActionType.Break, "I love the sound of breaking glass\n"
                                "especially when I'm lonely, the panes and the frame shatter\n"
                                "satisfyingly spreading broken joy on the floor"
                                , true, false, false, open_2_forge, 0);

        uint32[MAX_OBJ] memory window_actions;
        window_actions[0] = open_2_forge;
        window_actions[1] = smash_window;

        uint32 dirObj2 = createDirObj(DirectionType.East, KForge,
                                DirObjectType.Window, MaterialType.Wood,
                                "window", window_actions);
        dObjs[1] = dirObj2;


        // KBARN -> DOWN
        uint32 open_2_cellar = createAction(ActionType.Open, "The hay having burnt fast reveals a set of stairs.", false, false, false, 0, 0);
        uint32 burn_hay = createAction(ActionType.Burn, "You hear the cracking noise of the hay burning quickly as it is consumed by the dark fires\n"
                                "sadly, this enjoyable moment is short lived."
                                , true, false, false, open_2_cellar, 0);
        
        uint32[MAX_OBJ] memory hay_actions;
        hay_actions[0] = open_2_cellar;
        hay_actions[1] = burn_hay;

        uint32 dirObj3 = createDirObj(DirectionType.Down, KCellar,
                                DirObjectType.Stairs, MaterialType.Stone,
                                "stairs filled by a stack of hay", hay_actions);
        dObjs[2] = dirObj3;

        bytes32 tid_barn = keccak256(abi.encodePacked("a barn"));
        TxtDefStore.set(tid_barn, KBarn, TxtDefType.Place,
                                                    "The place is dusty and full of spiderwebs,\n"
                                                    "something died in here, possibly your own self\n"
                                                    "plenty of corners and dark shadows");


        RoomStore.setDescription(KBarn, 'a barn');
        RoomStore.setRoomType(KBarn, RoomType.Room);
        createPlace(KBarn, dObjs, objs, tid_barn);
    }

      function _setupCellar() private {
        // KCELLAR -> UP
        uint32 open_2_barn = createAction(ActionType.Open, "the way is opened\n"
                                "just don't fall when going up",
                                true, true, true, 0, 0);

        uint32[MAX_OBJ] memory cellar_barn;
        uint32[MAX_OBJ] memory dObjs;
        uint32[MAX_OBJ] memory objs;

        cellar_barn[0] = open_2_barn;

        uint32 dirObj1 = createDirObj(DirectionType.Up, KBarn,
                              DirObjectType.Stairs, MaterialType.Stone,
                              "stairs", cellar_barn);
        dObjs[0] = dirObj1;

        // Dynamite Object
        uint32 lightDynamite = createAction(ActionType.Light, "Seeing the fuse sparkling makes you remember the fireworks you loved as a child.\n"
                                "Suddenly, you return back and see that there is almost no time.\n"
                                "You have to do something or you will be turned to meat puree",
                                true, false, true, 0, 0);

         uint32 throwDynamite = createAction(ActionType.Throw, "You throw quickly the dynamite\n"
                                "and start running for the hills as your life depends on it",
                                true, false, true, 0, 0);

        uint32[MAX_OBJ] memory dynamite_actions;
        dynamite_actions[0] = lightDynamite;
        dynamite_actions[1] = throwDynamite;

        uint32 obj1 = createObject(ObjectType.Dynamite, MaterialType.IKEA,
                                "a high quality (if old) dynamite with a quick fuse.\n"
                                "It needs to be lit first", "dynamite", dynamite_actions);
        objs[0] = obj1;

        // Glue Object
        uint32 sniffGlue = createAction(ActionType.Sniff, "The smell of it is really relaxing,\n"
                                "but for now thats all",
                                true, false, true, 0, 0);

        uint32[MAX_OBJ] memory glue_actions;
        dynamite_actions[0] = sniffGlue; 

        uint32 obj2 = createObject(ObjectType.Glue, MaterialType.Shit,
                                "some oddly named glue.\n"
                                "Not knowing if its your imagination it seems to be calling you", "glue", glue_actions);
        objs[1] = obj2;

        RoomStore.setDescription(KCellar,  'a small cellar');
        RoomStore.setRoomType(KCellar,  RoomType.Cellar);

        bytes32 tid_plain = keccak256(abi.encodePacked('a small cellar'));
        TxtDefStore.set(tid_plain, KPlain, TxtDefType.Place, "big enough to hide probably fifty people.\n"
                                                                "It seems that it was constructed with great care as you can't find any cracks or holes in the walls.\n"
                                                                "This place might be important.");

        createPlace(KCellar, dObjs, objs, tid_plain);
    }

    function _createMountainPath() private {
        // KPATH -> W
        uint32 open_2_west = createAction(ActionType.Open, "the path is passable", true, true, false, 0, 0);
        uint32[MAX_OBJ] memory path_actions;
        path_actions[0] = open_2_west;

        uint32[MAX_OBJ] memory dObjs;
        uint32[MAX_OBJ] memory objs;
        // this is a path we might want to say BLOCK it which would mean adding a BLOCK
        // and an OPEN which we would set to false but as can be seen above right
        // now its just open and there is no state change to describe it
         uint32 dirObj1 = createDirObj(DirectionType.West, KPlain,
                               DirObjectType.Path, MaterialType.Stone,
                               "path", path_actions);
        dObjs[0] = dirObj1;

        // KPATH -> E
        uint32 open_2_actII = createAction(ActionType.Open, "The boulder, blasted to pieces reveals a path to a new adventure.\n"
                                                            "This is the end of ACT I, if you go East you will return to the plain.", false, false, false, 0, 0);

        uint32 destroy_boulder = createAction(ActionType.Throw, "The dynamite lands at the boulder while you keep running\n"
                                "and in just a second KBOOOM!", 
                                true, false, false, open_2_actII, 0);
        
        uint32[MAX_OBJ] memory boulder_actions;
        boulder_actions[0] = open_2_actII;
        boulder_actions[1] = destroy_boulder;

        uint32 dirObj2 = createDirObj(DirectionType.East, KPlain,
                                DirObjectType.Boulder, MaterialType.Stone,
                                "boulder", boulder_actions);

        dObjs[1] = dirObj2;

        bytes32 tid_mpath = keccak256(abi.encodePacked("a high mountain pass"));
        TxtDefStore.set(tid_mpath, KMountainPath, TxtDefType.Place,
                         "it winds through the mountains, the path is treacherous\n"
                         "toilet papered trees cover the steep \nvalley sides below you.\n"
                         "On closer inspection the TP might \nbe the remains of a cricket team\n"
                         "or perhaps a lost and very dead KKK picnic group.\n"
                         "It's brass monkeys.");

        RoomStore.setDescription(KMountainPath,  "a high mountain pass");
        RoomStore.setRoomType(KMountainPath,  RoomType.Plain);
        createPlace(KMountainPath, dObjs, objs, tid_mpath);

    }

    function _setupRooms() private {
        _setupPlain();
        _setupBarn();
        _createMountainPath();
        _setupForge();
        _setupCellar();
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

    function createAction(ActionType actionType, string memory desc, bool enabled, bool dBit, bool revert, uint32 affectsId, uint32 affectedById) private returns (uint32) {
        bytes32 txtId = keccak256(abi.encodePacked(desc));
        uint32 aId = _textGuid(desc);
        TxtDefStore.set(txtId, aId, TxtDefType.Action, desc);
        ActionStoreData memory actionData = ActionStoreData(actionType, txtId, enabled, revert, dBit, affectsId, affectedById);
        ActionStore.set(aId, actionData);
        return aId;
    }

}

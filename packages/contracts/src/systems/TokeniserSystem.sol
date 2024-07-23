// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import { console } from "forge-std/console.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { ObjectType, MaterialType, ActionType, DirectionType, GrammarType, DirObjectType } from "../codegen/common.sol";
import { Dirs } from "../codegen/tables/Dirs.sol";
import { ErrCodes, VerbData } from '../constants/defines.sol';


contract TokeniserSystem is System {

    // we can handle token streams of VRB, OBJ, IOBJ, the IOBJ might be an ObjectType or a DirObjectType
    // eg: "Throw the bottle at the cop", "Kick ball at window" etc
    function fishTokens(string[] memory tokens) public view returns (VerbData memory vrbData) {
        uint8 err = 0;
        VerbData memory data;
        uint32 len = uint32(tokens.length - 1);
        //ObjectType iobj; // not used right now
        ActionType vrb = cmdLookup[tokens[0]];
        ObjectType obj = objLookup[tokens[len]];
        DirObjectType dobj = dirObjLookup[tokens[len]];

        data.verb = vrb;
        if (obj == ObjectType.None && dobj == DirObjectType.None) {
            data.errCode = ErrCodes.ER_TKPR_NO ;
           } else {
               // ? VRB, OBJ ? //
               if ( obj != ObjectType.None && tokens.length <= 3) {
                   data.directNoun = obj;
               } else if (obj == ObjectType.None) {
                    err = ErrCodes.ER_TKPR_NO;   
               }
               if (tokens.length > 3) {
                   // ? VRB, [DA], OBJ, IOBJ ? // 
                   // dirObj ?
                   if (dobj != DirObjectType.None) {
                       // we have IOBJ find DOBJ
                       obj = objLookup[tokens[1]];
                       if (obj == ObjectType.None) {
                           obj = objLookup[tokens[2]];
                           if (obj == ObjectType.None) {
                               err = ErrCodes.ER_TKPR_NO;
                           }
                       }
                   } else if (obj != ObjectType.None) {
                       // we arent dealing with this type structure right now
                       // but we have a "throw thing1 at thing2" form where thing2
                       // is not a direction object. Probably combat as it goes
                       // so for now return
                       return data;
                   }
               }
           }
           console.log("--->d.dobj:%s iobj:%s vrb:%s", uint8(obj), uint8(dobj), uint8(vrb));
           //console.log("---->d.dobj:%s d.vrb:%s d.iobj:%s", data.directNoun, data.indirectDirNoun, data.verb);
           data.directNoun = obj;
           data.indirectDirNoun = dobj;
           data.errCode = err;
           return data;
    }

    /*
     * We use the maps below but it might be better to use tables
     * be useful to make some kind of a test
     *
     */
    mapping (string => ActionType) public cmdLookup;
    mapping (string => DirectionType) public dirLookup;
    mapping (string => DirObjectType) public dirObjLookup;
    mapping (string => GrammarType) public grammarLookup;
    mapping (string => ObjectType) public objLookup;
    mapping (ObjectType => string) public reverseObjLookup;
    mapping (DirObjectType => string) public reverseDObjLookup;
    mapping (ActionType => string) public reverseVrbLookup;
    mapping (DirectionType => string) public revDirLookup;
    mapping (MaterialType => string) public revMat;

    /**
    @dev The idea here is to get the corresponding actions for an action
    or VRB
    e.e. KICK -> [HIT]
    */
    mapping(ActionType => ActionType[]) public responseLookup;

    function initLUTS() public {
        setupCmds();
        setupObjects();
        setupDirs();
        setupDirObjs();
        setupGrammar();
        setupVrbAct();
        setupRevVrb();
    }

    function getResponseForVerb(ActionType key) public view returns (ActionType[] memory) {
        return responseLookup[key];
    }

    function reverseDirType(DirectionType key) public view returns (string memory) {
        return revDirLookup[key];
    }

    function revMatType(MaterialType key) public view returns (string memory) {
        return revMat[key];
    }

    function revVrbType(ActionType key) public view returns (string memory) {
        return reverseVrbLookup[key];
    }

    function revObjType(ObjectType key) public view returns (string memory) {
        return reverseObjLookup[key];
    }

    function revDObjType(DirObjectType key) public view returns (string memory) {
        return reverseDObjLookup[key];
    }

    function getObjectType(string memory key) public view returns (ObjectType) {
        return objLookup[key];
    }

    function getObjectNameOfObjectType(ObjectType key) public view returns (string memory) {
        return reverseObjLookup[key];
    }

    function getActionType(string memory key) public view returns (ActionType) {
        return cmdLookup[key];
    }

    function getGrammarType(string memory key) public view returns (GrammarType) {
        return grammarLookup[key];
    }

    function getDirectionType(string memory key) public view returns (DirectionType) {
        return dirLookup[key];
    }

    function setupVrbAct() private {
        responseLookup[ActionType.Kick] = [ActionType.Break, ActionType.Hit, ActionType.Damage, ActionType.Kick];
        responseLookup[ActionType.Burn] = [ActionType.Burn, ActionType.Light, ActionType.Damage];
        responseLookup[ActionType.Light] = [ActionType.Burn, ActionType.Light, ActionType.Damage];
        responseLookup[ActionType.Open] = [ActionType.Open];
        responseLookup[ActionType.Break] = [ActionType.Break];
        responseLookup[ActionType.Throw] = [ActionType.Throw];
         responseLookup[ActionType.Sniff] = [ActionType.Sniff];
    }

    function setupRevVrb() private {
        reverseVrbLookup[ActionType.Go]         = "go";
        reverseVrbLookup[ActionType.Move]       = "move";
        reverseVrbLookup[ActionType.Loot]       = "loot";
        reverseVrbLookup[ActionType.Describe]   = "describe";
        reverseVrbLookup[ActionType.Take]       = "take";
        reverseVrbLookup[ActionType.Kick]       = "kick";
        reverseVrbLookup[ActionType.Lock]       = "lock";
        reverseVrbLookup[ActionType.Unlock]     = "unlock";
        reverseVrbLookup[ActionType.Open]       = "open";
        reverseVrbLookup[ActionType.Look]       = "look";
        reverseVrbLookup[ActionType.Close]      = "close";
        reverseVrbLookup[ActionType.Break]      = "break";
        reverseVrbLookup[ActionType.Throw]      = "throw";
        reverseVrbLookup[ActionType.Drop]       = "drop";
        reverseVrbLookup[ActionType.Inventory]  = "inventory";
        reverseVrbLookup[ActionType.Burn]       = "burn";
        reverseVrbLookup[ActionType.Aquire]      = "aquire";
    }

    // we need to somewhere somehow read in the possible verbs if we
    // want users to have their own VERBS
    // how do we dynamically populate this ??
    function setupCmds() private {
        cmdLookup["GO"]         = ActionType.Go;
        cmdLookup["MOVE"]       = ActionType.Move;
        cmdLookup["LOOT"]       = ActionType.Loot;
        cmdLookup["DESCRIBE"]   = ActionType.Describe;
        cmdLookup["TAKE"]       = ActionType.Take;
        cmdLookup["GET"]       = ActionType.Take;
        cmdLookup["KICK"]       = ActionType.Kick;
        cmdLookup["LOCK"]       = ActionType.Lock;
        cmdLookup["UNLOCK"]     = ActionType.Unlock;
        cmdLookup["OPEN"]       = ActionType.Open;
        cmdLookup["LOOK"]       = ActionType.Look;
        cmdLookup["CLOSE"]      = ActionType.Close;
        cmdLookup["BREAK"]      = ActionType.Break;
        cmdLookup["THROW"]      = ActionType.Throw;
        cmdLookup["DROP"]       = ActionType.Drop;
        cmdLookup["INVENTORY"]  = ActionType.Inventory;
        cmdLookup["BURN"]       = ActionType.Burn;
        cmdLookup["LIGHT"]      = ActionType.Light;
        cmdLookup["AQUIRE"]      = ActionType.Take;
    }

    // this could autogen because we just take set of "str"
    // iterate and gen a line for each str.
    // fooLookup["FOO"] = FoosType.foo;
    function setupDirs () private {
        //Dirs.setDir(keccak256(abi.encodePacked("NORTH")), DirectionType.North);
        dirLookup["NORTH"]      = DirectionType.North;
        dirLookup["SOUTH"]      = DirectionType.South;
        dirLookup["EAST"]       = DirectionType.East;
        dirLookup["WEST"]       = DirectionType.West;
        dirLookup["UP"]         = DirectionType.Up;
        dirLookup["DOWN"]       = DirectionType.Down;
        dirLookup["FORWARD"]    = DirectionType.Forward;
        dirLookup["BACKWARD"]   = DirectionType.Backward;

        revDirLookup[DirectionType.North]   = "north";
        revDirLookup[DirectionType.South]   = "south";
        revDirLookup[DirectionType.East]    = "east";
        revDirLookup[DirectionType.West]    = "west";
        revDirLookup[DirectionType.Up]      = "up";
        revDirLookup[DirectionType.Down]    = "down";
        revDirLookup[DirectionType.Forward]  = "forward";
        revDirLookup[DirectionType.Backward] = "backward";
    }

    function setupDirObjs () private {
        dirObjLookup["DOOR"]        = DirObjectType.Door;
        dirObjLookup["WINDOW"]      = DirObjectType.Window;
        dirObjLookup["STAIRS"]      = DirObjectType.Stairs;
        dirObjLookup["LADDER"]      = DirObjectType.Ladder;
        dirObjLookup["PATH"]        = DirObjectType.Path;
        dirObjLookup["TRAIL"]       = DirObjectType.Trail;
        dirObjLookup["BOULDER"]       = DirObjectType.Boulder;

        reverseDObjLookup[DirObjectType.Door]        = "door";
        reverseDObjLookup[DirObjectType.Window]      = "window";
        reverseDObjLookup[DirObjectType.Stairs]      = "stairs";
        reverseDObjLookup[DirObjectType.Ladder]      = "ladder";
        reverseDObjLookup[DirObjectType.Path]        = "path";
        reverseDObjLookup[DirObjectType.Trail]       = "trail";
        reverseDObjLookup[DirObjectType.Boulder]        = "boulder";
    }

    // TODO: we probably no longer need this
    function setupGrammar () private {
       grammarLookup["The"]     = GrammarType.DefiniteArticle;
       grammarLookup["To"]      = GrammarType.Preposition;
       grammarLookup["at"]      = GrammarType.Preposition;
       grammarLookup["Around"]  = GrammarType.Adverb;
    }

    function setupObjects() private returns (uint32) {
        objLookup["FOOTBALL"]   = ObjectType.Football;
        objLookup["BALL"]       = ObjectType.Football;
        objLookup["KEY"]        = ObjectType.Key;
        objLookup["KNIFE"]      = ObjectType.Knife;
        objLookup["BOTTLE"]     = ObjectType.Bottle;
        objLookup["PETROL"]     = ObjectType.Petrol;
        objLookup["MATCHES"]     = ObjectType.Matches;
        objLookup["DYNAMITE"]     = ObjectType.Dynamite;
        objLookup["GLUE"]     = ObjectType.Glue;

        reverseObjLookup[ObjectType.Football]   = "Football";
        reverseObjLookup[ObjectType.Football]   = "Ball";
        reverseObjLookup[ObjectType.Key]        = "Key";
        reverseObjLookup[ObjectType.Knife]      = "Knife";
        reverseObjLookup[ObjectType.Bottle]     = "Bottle";
        reverseObjLookup[ObjectType.Petrol]     = "Petrol";
        reverseObjLookup[ObjectType.Matches]     = "Matches";
        reverseObjLookup[ObjectType.Dynamite]     = "Dynamite";
        reverseObjLookup[ObjectType.Glue]     = "Glue";

        revMat[MaterialType.Mud]    = "mud";
        revMat[MaterialType.Dirt]   = "dirt";
        revMat[MaterialType.Stone]  = "stone";
        revMat[MaterialType.Flesh]  = "flesh";
        revMat[MaterialType.Wood]   = "wood";
    }

}

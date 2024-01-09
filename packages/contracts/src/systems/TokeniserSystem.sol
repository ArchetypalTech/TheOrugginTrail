// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { console } from "forge-std/console.sol";
import {System} from "@latticexyz/world/src/System.sol";
import {ObjectType, ActionType, DirectionType, GrammarType} from "../codegen/common.sol";
import {Dirs} from "../codegen/tables/Dirs.sol";


contract TokeniserSystem is System {

    /*
     * We use the maps below but it might be better to use tables
     * be useful to make some kind of a test
     *
     */
    mapping (string => ActionType) public cmdLookup;
    mapping (string => DirectionType) public dirLookup;
    mapping (string => GrammarType) public grammarLookup;
    mapping(string => ObjectType) public objLookup;
    mapping(ObjectType => string) public reverseObjLookup;
    mapping(DirectionType => string) public revDirLookup;

    function initTS() public returns (address) {
        console.log("--->initTS");
        setupCmds();
        setupObjects();
        setupDirs();
        setupGrammar();
        return address(this);
    }

    function reverseDirType(DirectionType key) public view returns (string memory) {
        return revDirLookup[key];
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

    // we need to somewhere somehow read in the possible verbs if we
    // want users to have their own VERBS
    // how do we dynamically populate this ??
    function setupCmds() private {
        cmdLookup["GO"]         = ActionType.Go;
        cmdLookup["MOVE"]       = ActionType.Move;
        cmdLookup["LOOT"]       = ActionType.Loot;
        cmdLookup["DESCRIBE"]   = ActionType.Describe;
        cmdLookup["TAKE"]       = ActionType.Take;
        cmdLookup["KICK"]       = ActionType.Kick;
        cmdLookup["LOCK"]       = ActionType.Lock;
        cmdLookup["UNLOCK"]     = ActionType.Unlock;
        cmdLookup["OPEN"]       = ActionType.Open;
        cmdLookup["LOOK"]       = ActionType.Look;
        cmdLookup["DROP"]       = ActionType.Drop;
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

    function setupGrammar () private {
       grammarLookup["The"]     = GrammarType.DefiniteArticle;
       grammarLookup["To"]      = GrammarType.Preposition;
       grammarLookup["Around"]  = GrammarType.Adverb;
    }

    function setupObjects() private returns (uint32) {
        objLookup["FOOTBALL"]   = ObjectType.Football;
        objLookup["KEY"]        = ObjectType.Key;
        objLookup["KNIFE"]      = ObjectType.Knife;
        objLookup["BOTTLE"]     = ObjectType.Bottle;

        reverseObjLookup[ObjectType.Football]   = "Football";
        reverseObjLookup[ObjectType.Key]        = "Key";
        reverseObjLookup[ObjectType.Knife]      = "Knife";
        reverseObjLookup[ObjectType.Bottle]     = "Bottle";
    }

}

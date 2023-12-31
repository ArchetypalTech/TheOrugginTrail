// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import {System} from "@latticexyz/world/src/System.sol";
import {Output} from "../codegen/index.sol";
import {ActionType, DirectionType, GrammarType} from "../codegen/common.sol";


contract CommandLookupSystem is System {

    // some maps for lookups
    mapping (string => ActionType) public cmdLookup;
    mapping (string => DirectionType) public dirLookup;
    mapping (string => GrammarType) public grammarLookup;

    function initCLS() public returns (address) {
        Output.set('initCES called...');
        setupCmds();
        setupDirs();
        setupGrammar();
        return address(this);
    }

    function getActionType(string calldata key) external view returns (ActionType) {
        return cmdLookup[key];
    }

    function getGrammarType(string calldata key) external view returns (GrammarType) {
        return grammarLookup[key];
    }

    function getDirectionType(string calldata key) external view returns (DirectionType) {
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
    }

    // this could autogen because we just take set of "str"
    // iterate and gen a line for each str.
    // fooLookup["FOO"] = FoosType.foo;
    function setupDirs () private {
        dirLookup["NORTH"]  = DirectionType.North;
        dirLookup["SOUTH"]  = DirectionType.South;
        dirLookup["EAST"]   = DirectionType.East;
        dirLookup["WEST"]   = DirectionType.West;
        dirLookup["UP"]     = DirectionType.Up;
        dirLookup["DOWN"]   = DirectionType.Down;
    }

    function setupGrammar () private {
       grammarLookup["The"] = GrammarType.DefiniteArticle; 
       grammarLookup["To"]  = GrammarType.Preposition;
    }
    
}

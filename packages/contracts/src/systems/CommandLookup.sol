// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;


//import {System} from "@latticexyz/world/src/System.sol";
import {Output} from "../codegen/index.sol";
import {ActionType, DirectionType} from "../codegen/common.sol";

contract CommandLookups {

    // some maps for lookups
    mapping (string => ActionType) public cmdLookup;
    mapping (string => DirectionType) public dirLookup;
    
    function initCLS() public returns (uint32) {
        Output.set('initCES called...');
        setupCmds();
        setupDirs();
        return 0;
    }

    // we need to somewhere somehow read in the possible verbs if we
    // want users to have their own VERBS
    // how do we dynamically populate this ??
    function setupCmds() private returns (uint32) {
        cmdLookup["GO"]         = ActionType.Go;
        cmdLookup["MOVE"]       = ActionType.Move;
        cmdLookup["LOOT"]       = ActionType.Loot;
        cmdLookup["DESCRIBE"]   = ActionType.Describe;
        cmdLookup["TAKE"]       = ActionType.Take;
        cmdLookup["KICK"]       = ActionType.Kick;
        cmdLookup["LOCK"]       = ActionType.Lock;
        cmdLookup["UNLOCK"]     = ActionType.Unlock;
        cmdLookup["OPEN"]       = ActionType.Open;
    }

    // this could autogen because we just take set of "str"
    // iterate and gen a line for each str.
    // fooLookup["FOO"] = FoosType.foo;
    function setupDirs () private returns (uint32) {
        dirLookup["NORTH"]  = DirectionType.North;
        dirLookup["SOUTH"]  = DirectionType.South;
        dirLookup["EAST"]   = DirectionType.East;
        dirLookup["WEST"]   = DirectionType.West;
        dirLookup["UP"]     = DirectionType.Up;
        dirLookup["DOWN"]   = DirectionType.Down;
    }
    
}

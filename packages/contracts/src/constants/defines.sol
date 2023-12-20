// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import {ActionType, DirectionType} from "../codegen/common.sol";

// this should be auto generated ? but it isnt
// but it can then be used in Obj creation
// by the PreyEngine or perhaps we just use 
// this set of constants to define the entire// digetic set of poassible things
contract GameConstants {
    // some general purpose object ID's
    // these really shoulf be uefull bit masks
    // but for now we will just throw some shitty
    // numbers in there
    uint32 public constant OPEN_ACTION_ID = 122;
    uint32 public constant OPEN_ACTION_DESC_ID = 123;
    uint32 public constant WOOD_DOOR_OBJECT_ID = 124;
    uint32 public constant WOOD_DOOR_DESC_ID = 125;
    uint32 public constant WOOD_MATERIAL_ID = 126;
    uint32 public constant PORTAL_ID = 127;

    // some MAX_SIZES for functions 
    uint8 public constant MAX_TOK = 16;

    // some maps for verb lookups
    mapping (string => ActionType) private commandLookup;
    mapping (string => DirectionType) private directionLookup;

    // some DATA_BITS for packing
    uint8 public constant TERRAIN_BITS = 24;    // << 24
    uint8 public constant ROOM_BITS = 16;       // << 16
    uint8 public constant OBJECT_BITS = 8;      // << 8

    // some Direction bits
    uint8 public constant NORTH_DIR = 1;        // 0x0001
    uint8 public constant EAST_DIR = 2;         // 0x0010
    uint8 public constant SOUTH_DIR = 4;        // 0x0100
    uint8 public constant WEST_DIR = 8;         // 0x1000

    constructor() {
        commandLookup["GO"] = ActionType.Go;
        commandLookup["MOVE"] = ActionType.Move;
        commandLookup["LOOT"] = ActionType.Loot;
        commandLookup["DESCRIBE"] = ActionType.Describe;
        commandLookup["TAKE"] = ActionType.Take;
        commandLookup["KICK"] = ActionType.Kick;
        commandLookup["LOCK"] = ActionType.Lock;
        commandLookup["UNLOCK"] = ActionType.Unlock;
        commandLookup["OPEN"] = ActionType.Open;

        directionLookup["NORTH"] = DirectionType.North;
    }

    function getActionType(string memory cmd) public view returns (ActionType) {
        return commandLookup[cmd];
    }
    
    function getDirType(string memory cmd) public view returns (DirectionType) {
        return directionLookup[cmd];
    }
}

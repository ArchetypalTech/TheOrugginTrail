// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import { ObjectType, MaterialType, ActionType, DirectionType, GrammarType, DirObjectType } from "../codegen/common.sol";
// this should be auto generated ? but it isnt
// but it can then be used in Obj creation
// by the PreyEngine or perhaps we just use
// this set of constants to define the entire// digetic set of poassible things
library GameConstants {

    // some MAX_SIZES for functions
    uint8 public constant MAX_TOK = 16;
    uint8 public constant MIN_TOK = 2;

    // some DATA_BITS for packing
    uint8 public constant TERRAIN_BITS = 24;    // << 24
    uint8 public constant ROOM_BITS = 16;       // << 16
    uint8 public constant OBJECT_BITS = 8;      // << 8

    // some Direction bits
    uint8 public constant NORTH_DIR = 1;        // 0x0001
    uint8 public constant EAST_DIR = 2;         // 0x0010
    uint8 public constant SOUTH_DIR = 4;        // 0x0100
    uint8 public constant WEST_DIR = 8;         // 0x1000

    uint32 public constant SIZED_AR_SIZE = 32;   // the max size of a Sized Array, 31 items + 1 for count
}


struct VerbData {
    ActionType verb;
    ObjectType directNoun;
    DirObjectType indirectDirNoun;
    ObjectType indirectObjNoun;
    uint8 errCode;
}


// some result codes (from game commands)
library ResCodes {
    uint8 public constant GO_NO_EXIT = 8; // Error DirectionRoutine DR
    // We use a custom return type for LOOK's
    // because we cant return a 0 for no err unlike the rest of our commands
    uint8 public constant LK_RT = 9;
    uint8 public constant AH_BC_0 = 10;
}

library ErrCodes {

    uint8 public constant ER_DR_ND = 122; // Error DirectionRoutine DR
    uint8 public constant ER_DR_NOP = 123;
    uint8 public constant ER_PR_ND = 124; // Error ParserRoutine DR
    uint8 public constant ER_PR_NT = 125;
    uint8 public constant ER_PR_TK_CX = 126; // > MAX TOKS
    uint8 public constant ER_PR_NOP = 127;
    uint8 public constant ER_PR_TK_C1 = 128; // < MIN TOKS
    uint8 public constant ER_PR_NO = 129; // Error No DirectObject
    uint8 public constant ER_LK_NOP = 130; // Error Bad Look Command
    uint8 public constant ER_AR_BNDS = 131; // Error No DirectObject
    uint8 public constant ER_TKPR_NO = 132; // Error No DirectObject

    uint8 public constant ER_SIZED_AR_OUT_OF_SPACE = 133; // when we try and add an item to a size array using the add function, but its full
    uint8 public constant ER_SIZED_AR_NOT_ITEMS_TO_REMOVE = 134; // when we try and remove an item to a sized array using the remove function, but noone is home!
    uint8 public constant ER_ACTION_HDL_NO = 135; // Error No Objects to handle
}

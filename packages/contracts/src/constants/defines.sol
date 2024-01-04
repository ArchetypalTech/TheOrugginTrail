// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

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
}

// some result codes (from game commands)
library ResCodes {
    uint8 public constant GO_NO_EXIT = 8; // Error DirectionRoutine DR
    uint8 public constant LK_OK = 8; // Error DirectionRoutine DR
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
    uint8 public constant ER_LK_NOP = 130; // Error No DirectObject

}

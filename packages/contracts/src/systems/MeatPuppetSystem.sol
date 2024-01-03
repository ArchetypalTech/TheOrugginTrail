// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

// get some debug OUT going
import {console} from "forge-std/console.sol";

import {System} from "@latticexyz/world/src/System.sol";
import {ObjectStoreData, ObjectStore,Player, Output, CurrentPlayerId, RoomStore, RoomStoreData, ActionStore, DirObjStore, DirObjStoreData, TextDef} from "../codegen/index.sol";
import {ActionType, RoomType, ObjectType, CommandError, DirectionType} from "../codegen/common.sol";
import { GameConstants, ErrCodes, ResCodes } from "../constants/defines.sol";

import { IWorld } from "../codegen/world/IWorld.sol";

import { Look } from './actions/Look.sol';

import { console } from "forge-std/console.sol";

contract MeatPuppetSystem is System  {

    event debugLog(string msg, uint8 val);

    address world;

    // we call this from the post deploy contract
    function initGES(address wrld) public returns (address) {
        console.log('--->initGES() wr:%s', wrld);

        world = wrld;

        spawn(0);
        return address(this);
    }

    function spawn(uint32 startId) public {
        console.log("--->spawn");
        // start on the mountain
        _enterRoom(0);
    }

    function _describeRoom(uint32 rId) private returns (string memory) {
        console.log("--------->DescribeRoom:");
        RoomStoreData memory currRoom = RoomStore.get(rId);
        return string(abi.encodePacked(currRoom.description, "\n",
            "You can go", _describeActions(rId), _describeObjectsInRoom(rId), _describeObjectsInInventory())
        );
    }

    function _describeObjectsInRoom(uint32 rId) private returns (string memory) {
        console.log("--------->DescribeObjectsInRoom:");
        return _describeObjects(RoomStore.get(rId).objectIds, "\nThis room contains ");
    }

    function _describeObjectsInInventory() private returns (string memory) {
        console.log("--------->DescribeObjectsInInventory:");
        return _describeObjects(Player.getObjectIds(CurrentPlayerId.get()), "\nYour Aldi carrier bag contains ");
    }

    function _describeObjects(uint32[] memory objectIds, string memory preText) private returns (string memory) {
        console.log("--------->DescribeObjects:");

        bool foundValidObject = false;
        for(uint8 i = 0 ; i < objectIds.length ; i++) {
            if(objectIds[i] != 0 ) {
                foundValidObject = true;
                break;
            }
        }

        if (foundValidObject == false) return "";
        string memory msgStr = preText;
        for (uint8 i = 0; i < objectIds.length; i++) {
            msgStr = string(abi.encodePacked(msgStr, IWorld(world).meat_TokeniserSystem_getObjectNameOfObjectType(ObjectStore.get(objectIds[i]).objectType)));
        }
        return msgStr;
    }


    function _take(string[] memory tokens, uint32 rId) private returns (uint8 err) {
        console.log("----->TAKE :", tokens[1]);
        uint8 tok_err;
        string memory tok = tokens[1];
        ObjectType objType = IWorld(world).meat_TokeniserSystem_getObjectType(tok);
        if (objType != ObjectType.None) {
            uint32[] memory objIds = RoomStore.getObjectIds(rId);
            for(uint8 i = 0 ; i < objIds.length ; i++) {
                ObjectType testType = ObjectStore.getObjectType(objIds[i]);
                if(testType == objType) {
                    Output.set("You picked it up");
                    Player.pushObjectIds(CurrentPlayerId.get(), objIds[i]);
                    objIds[i] = 0;
                    RoomStore.setObjectIds(rId, objIds);
                    break;
                }
            }
        }

        return 0;
    }

    function _drop(string[] memory tokens, uint32 rId) private returns (uint8 err) {
        console.log("----->DROP :", tokens[1]);
        uint8 tok_err;
        string memory tok = tokens[1];
        ObjectType objType = IWorld(world).meat_TokeniserSystem_getObjectType(tok);
        if (objType != ObjectType.None) {
            console.log("1");
            uint32[] memory objIds = Player.getObjectIds(CurrentPlayerId.get());
            for(uint8 i = 0 ; i < objIds.length ; i++) {
                console.log("2");
                ObjectType testType = ObjectStore.getObjectType(objIds[i]);
                if(testType == objType) {
                    Output.set("You took the item from your faded Aldi bag and placed it on the floor");
                    console.log("3");
                    RoomStore.pushObjectIds(rId, objIds[i]);
                    objIds[i] = 0;
                    Player.setObjectIds(CurrentPlayerId.get(), objIds);
                    return 0;
                }
            }
            Output.set("That item is not in the Aldi carrer bag");


        }

        Output.set("I'm not sure what one of those is");

        return 0;
    }

    // MOVE TO OWN SYSTEM -- MEATCOMMANDER
    /* handle NON MOVEMENT VERBS */
    function _handleAction(string[] memory tokens, uint32 rId) private returns (uint8 err) {
        console.log("---->HDL_ACT", tokens[1]);

        string memory tok = tokens[0];

        ActionType actionType = IWorld(world).meat_TokeniserSystem_getActionType(tok);

        if (actionType == ActionType.Take) {
            return _take(tokens, rId);
        } else if (actionType == ActionType.Drop) {
            return _drop(tokens, rId);

        }

        return 0;
    }


    // MOVE TO OWN SYSTEM -- MEATWHISPERER
    /* build up the text description strings for general output */
    function _describeActions(uint32 rId) private returns (string memory) {
        RoomStoreData memory currRm = RoomStore.get(rId);
        string[8] memory dirStrings;
        string memory msgStr;
        for (uint8 i = 0; i < currRm.dirObjIds.length; i++) {
            DirObjStoreData memory dir = DirObjStore.get(currRm.dirObjIds[i]);

            if (dir.dirType == DirectionType.North) {
                dirStrings[i] = " North";
            } else if (dir.dirType == DirectionType.East) {
                dirStrings[i] = " East";
            } else if (dir.dirType == DirectionType.South) {
                dirStrings[i] = " South";
            } else if (dir.dirType == DirectionType.West) {
                dirStrings[i] = " West";
            } else {dirStrings[i] = " to hell";}
        }
        for (uint16 i = 0; i < dirStrings.length; i++) {
            msgStr = string(abi.encodePacked(msgStr, dirStrings[i]));
        }
        return msgStr;
    }

    function _enterRoom(uint32 rId) private returns (uint8 err) {
        console.log("--------->CURR_RM:", rId);
        Player.setRoomId(CurrentPlayerId.get(), rId);
        Output.set(_describeRoom(rId));
        return 0;
    }


    // intended soley to process tokens and then hand off to other systems
    // checks for first TOKEN which can be either a GO or another VERB.
    function processCommandTokens(string[] calldata tokens) public returns (uint8 err) {
        /* see action diagram in VP (tokenise) for logic */
        uint8 err;
        bool move;
        uint32 nxt;

        uint32 rId = Player.getRoomId(CurrentPlayerId.get());

        if (tokens.length > GameConstants.MAX_TOK ) {
            err = ErrCodes.ER_PR_TK_CX;
        }
        string memory tok1 = tokens[0];
        console.log("---->CMD: %s", tok1);
        DirectionType tokD = IWorld(world).meat_TokeniserSystem_getDirectionType(tok1);

        if (tokD != DirectionType.None) {
            /* DIR: form */
            move = true;
            (err, nxt) = IWorld(world).meat_DirectionSystem_getNextRoom(tokens,
                rId);
        } else if (IWorld(world).meat_TokeniserSystem_getActionType(tok1) != ActionType.None ) {
            if (tokens.length >= 2) {
                console.log("-->tok.len %d", tokens.length);
                if ( IWorld(world).meat_TokeniserSystem_getActionType(tok1) == ActionType.Go ) {
                    /* GO: form */
                    move = true;
                    (err, nxt) = IWorld(world).meat_DirectionSystem_getNextRoom(tokens,
                        rId);
                } else {
                    /* VERB: form */
                    // TODO: handle actions
                        err = _handleAction(tokens, rId);
                    move = false;
                }
            } else {
                err = ErrCodes.ER_PR_NO;
            }
        } else {
            err = ErrCodes.ER_PR_NOP;
        }

        /* we have gone through the TOKENS, give err feedback if needed */
        if (err != 0) {
            console.log("----->PCR_ERR: err:", err);
            string memory errMsg;
            errMsg = _insultMeat(err, "");
            Output.set(errMsg);
            return err;
        } else {
            // either a do something or move rooms command
            if ( move ) {
                _enterRoom(nxt);
            }
        }
    }

    //MOVE TO ITS OWN SYTEM - MEATINSULTOR
    /* process errors and build up err output */
    function _insultMeat(uint8 ce, string memory badCmd) private pure returns (string memory) {
        string memory eMsg;
        if (ce == ErrCodes.ER_PR_TK_CX) {
            eMsg = "WTF, slow down cowboy, your gonna hurt yourself";
        } else if (ce == ErrCodes.ER_PR_NOP || ce == ErrCodes.ER_PR_TK_C1) {
            eMsg = "Nope, gibberish\n"
            "Stop breathing with your mouth.";
        } else if (ce == ErrCodes.ER_PR_ND || ce == ErrCodes.ER_DR_ND) {
            eMsg = "Go where pilgrim?";
        } else if (ce == ErrCodes.ER_DR_NOP) {
            eMsg = string(abi.encodePacked("Go ", badCmd, " is nowhere I know of bellend"));
        } else if (ce == ResCodes.GO_NO_EXIT) {
            eMsg = string(abi.encodePacked("Can't go that away", badCmd));
        }
        return eMsg;
    }
}


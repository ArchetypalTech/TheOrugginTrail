// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

// get some debug OUT going
import { console } from "forge-std/console.sol";

import { System } from "@latticexyz/world/src/System.sol";

import { ObjectStoreData, ObjectStore,Player, Output, CurrentPlayerId, RoomStore, RoomStoreData, ActionStore, DirObjectStore,
    DirObjectStoreData, TxtDefStore } from "../codegen/index.sol";

import { ActionType, RoomType, ObjectType, CommandError, DirectionType } from "../codegen/common.sol";

import { GameConstants, ErrCodes, ResCodes } from "../constants/defines.sol";

import { IInventorySystem } from '../codegen/world/IInventorySystem.sol';

import { IWorld } from "../codegen/world/IWorld.sol";

import { LookAt } from '../libs/LookLib.sol';

import { Kick } from '../libs/KickLib.sol';

import { Constants } from '../constants/Constants.sol';


contract MeatPuppetSystem is System, Constants {

    using LookAt for *;

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

    function _handleAlias(string[] memory tokens, uint32 curRm) private returns (uint8 err) {
        // we are not handling go aliases right now
        ActionType vrb = IWorld(world).meat_TokeniserSystem_getActionType(tokens[0]);
        uint8 e;
        console.log("---->HDL_ALIAS");
        if( vrb == ActionType.Inventory) {
            e = IWorld(world).meat_InventorySystem_inventory(world);
        } else {
       //     return ErrCodes.ER_PR_NO;
        }
        return e;
    }


    function _handleVerb(string[] memory tokens, uint32 curRm) private returns (uint8 err) {
        ActionType vrb = IWorld(world).meat_TokeniserSystem_getActionType(tokens[0]);
        uint8 e;
        console.log("---->HDL_VRB");
        if (vrb == ActionType.Look || vrb == ActionType.Describe) {
            e = LookAt.stuff(world, tokens, curRm);
        } else if (vrb == ActionType.Take ) {
            e = IWorld(world).meat_InventorySystem_take(world,tokens, curRm);
        } else if (vrb == ActionType.Drop) {
            e = IWorld(world).meat_InventorySystem_drop(world,tokens, curRm);
        } else if (vrb == ActionType.Kick) {
            e = Kick.kick(world, tokens, curRm);
        }
            /*else if (vrb == ActionType.Unlock) {
            e = Open.unlock
            } else if (vrb == ActionType.Use) {
            e = Open.unlock
            }
            */
        return e;
    }

    function _describeObjectsInRoom(uint32 rId) private returns (string memory) {
        console.log("--------->DescribeObjectsInRoom:");
        return _describeObjects(RoomStore.get(rId).objectIds, "\nThis room contains ");
    }

    function _describeObjectsInInventory() private returns (string memory) {
        console.log("--------->DescribeObjectsInInventory:");
        return _describeObjects(Player.getObjectIds(CurrentPlayerId.get()), "\nYour Aldi carrier bag contains ");
    }

    function _describeObjects(uint32[MAX_OBJ] memory objectIds, string memory preText) private returns (string memory) {
        console.log("--------->DescribeObjects:");

        uint32 objectCount = SizedArray.count(objectIds);

        if(objectCount == 0) {
            return "";
        }

        string memory msgStr = preText;
        for (uint8 i = 0; i < objectCount; i++) {
            msgStr = string(abi.encodePacked(msgStr,
                IWorld(world).meat_TokeniserSystem_getObjectNameOfObjectType(
                    ObjectStore.get(objectIds[i]).objectType)));
        }
        return msgStr;
    }

    // this is about to be redundant so dont do anymore work omn it
    // MOVE TO OWN SYSTEM -- MEATWHISPERER
    /* build up the text description strings for general output */
    function _describeActions(uint32 rId) private view returns (string memory) {
        RoomStoreData memory currRm = RoomStore.get(rId);
        string[8] memory dirStrings;
        string memory msgStr;
        for (uint8 i = 0; i < currRm.dirObjIds.length; i++) {
            DirObjectStoreData memory dir = DirObjectStore.get(currRm.dirObjIds[i]);

            if (dir.dirType == DirectionType.North) {
                dirStrings[i] = " North";
            } else if (dir.dirType == DirectionType.East) {
                dirStrings[i] = " East";
            } else if (dir.dirType == DirectionType.South) {
                dirStrings[i] = " South";
            } else if (dir.dirType == DirectionType.West) {
                dirStrings[i] = " West";
            }
        }
        for (uint16 i = 0; i < dirStrings.length; i++) {
            msgStr = string(abi.encodePacked(msgStr, dirStrings[i]));
        }
        return msgStr;
    }

    function _enterRoom(uint32 rId) private returns (uint8 err) {
        console.log("--------->ENTR_RM:", rId);
        Player.setRoomId(CurrentPlayerId.get(), rId);
        Output.set(LookAt.getRoomDesc(rId));
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

        if (tokens.length > GameConstants.MAX_TOK) {
            err = ErrCodes.ER_PR_TK_CX;
        }
        string memory tok1 = tokens[0];
        console.log("---->CMD: %s", tok1);
        DirectionType tokD = IWorld(world).meat_TokeniserSystem_getDirectionType(tok1);

        if (tokD != DirectionType.None) {
            //console.log("---->DIR:");
            /* DIR: form */
            move = true;
            (err, nxt) = IWorld(world).meat_DirectionSystem_getNextRoom(tokens, rId);
        } else if (IWorld(world).meat_TokeniserSystem_getActionType(tok1) != ActionType.None ) {
            //console.log("---->VRB:");
            if (tokens.length >= 2) {
                //console.log("-->tok.len %d", tokens.length);
                if (IWorld(world).meat_TokeniserSystem_getActionType(tok1) == ActionType.Go) {
                    /* GO: form */
                    move = true;
                    (err, nxt) = IWorld(world).meat_DirectionSystem_getNextRoom(tokens, rId);
                } else {
                    /* VERB: form */
                    err = _handleVerb(tokens, Player.getRoomId(CurrentPlayerId.get()));
                    console.log("->ERR: %s", err);
                    move = false;
                }
            } else {
                err = _handleAlias(tokens, Player.getRoomId(CurrentPlayerId.get()));
                move = false;
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
            if (move) {
                _enterRoom(nxt);
            } else {
                // hit look libs_ perhaps?
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


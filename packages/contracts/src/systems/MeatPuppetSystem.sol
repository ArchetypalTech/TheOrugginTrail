// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

// get some debug OUT going
import { console } from "forge-std/console.sol";

import { System } from "@latticexyz/world/src/System.sol";

import { ObjectStoreData, ObjectStore,Player, Output, RoomStore, RoomStoreData, ActionStore, DirObjectStore,
    DirObjectStoreData, TxtDefStore } from "../codegen/index.sol";

import { ActionType, RoomType, ObjectType, CommandError, DirectionType } from "../codegen/common.sol";

import { GameConstants, ErrCodes, ResCodes } from "../constants/defines.sol";

import { IInventorySystem } from '../codegen/world/IInventorySystem.sol';

import { IWorld } from "../codegen/world/IWorld.sol";

import { LookAt } from '../libs/LookLib.sol';

import { Kick } from '../libs/KickLib.sol';

import { Constants } from '../constants/Constants.sol';

import { SizedArray } from '../libs/SizedArrayLib.sol';


contract MeatPuppetSystem is System, Constants {

    using LookAt for *;

    address world;

    // we call this from the post deploy contract
    function initGES(address wrld) public returns (address) {
        console.log('--->initGES() wr:%s', wrld);

        world = wrld;

        return address(this);
    }

    function _handleAlias(string[] memory tokens, uint32 playerId) private returns (uint8 err) {
        // we are not handling go aliases right now
        uint32 curRm = Player.getRoomId(playerId);

        ActionType vrb = IWorld(world).meat_TokeniserSystem_getActionType(tokens[0]);
        uint8 e;
        console.log("---->HDL_ALIAS");
        if( vrb == ActionType.Inventory) {
            e = IWorld(world).meat_InventorySystem_inventory(world, playerId);
        } else if (vrb == ActionType.Look) {
            e = LookAt.stuff(world, tokens, curRm, playerId);
        }
        return e;
    }


    function _handleVerb(string[] memory tokens,  uint32 playerId) private returns (uint8 err) {

        uint32 curRm = Player.getRoomId(playerId);
        ActionType vrb = IWorld(world).meat_TokeniserSystem_getActionType(tokens[0]);
        uint8 e;
        console.log("---->HDL_VRB");
        IWorld(world).meat_TokeniserSystem_fishTokens(tokens);
        if (vrb == ActionType.Look || vrb == ActionType.Describe) {
            e = LookAt.stuff(world, tokens, curRm, playerId);
        } else if (vrb == ActionType.Take ) {
            e = IWorld(world).meat_InventorySystem_take(world,tokens, curRm, playerId);
        } else if (vrb == ActionType.Drop) {
            e = IWorld(world).meat_InventorySystem_drop(world,tokens, curRm, playerId);
        } else if (vrb == ActionType.Kick) {
            e = Kick.kick(world, tokens, curRm, playerId);
        }
            /*else if (vrb == ActionType.Unlock) {
            e = Open.unlock
            } else if (vrb == ActionType.Use) {
            e = Open.unlock
            }
            */
        return e;
    }

    function _enterRoom(uint32 rId, uint32 playerId) private returns (uint8 err) {
        console.log("--------->ENTR_RM:", rId);
        Player.setRoomId(playerId, rId);
        Output.set(playerId,LookAt.getRoomDesc(rId));
        return 0;
    }


    // intended soley to process tokens and then hand off to other systems
    // checks for first TOKEN which can be either a GO or another VERB.
    function processCommandTokens(string[] calldata tokens, uint32 playerId) public returns (uint8 err) {
        /* see action diagram in VP (tokenise) for logic */
        uint8 err;
        bool move;
        uint32 nxt;

        uint32 rId = Player.getRoomId(playerId);

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
                    err = _handleVerb(tokens, playerId);
                    console.log("->ERR: %s", err);
                    move = false;
                }
            } else {
                err = _handleAlias(tokens, playerId);
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
            Output.set(playerId,errMsg);
            return err;
        } else {
            // either a do something or move rooms command
            if (move) {
                _enterRoom(nxt, playerId);
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


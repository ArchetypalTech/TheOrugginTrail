// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

// get some debug OUT going
import { console } from "forge-std/console.sol";

import { System } from "@latticexyz/world/src/System.sol";

import { ObjectStoreData, ObjectStore,Player, Output, RoomStore, RoomStoreData, ActionStore, DirObjectStore,
    DirObjectStoreData, TxtDefStore } from "../codegen/index.sol";

import { ActionType, RoomType, ObjectType, CommandError, DirectionType } from "../codegen/common.sol";

import { GameConstants, ErrCodes, ResCodes } from "../constants/defines.sol";

import { IWorld } from "../codegen/world/IWorld.sol";

import { VerbData } from "../constants/defines.sol";

import { Kick } from '../libs/KickLib.sol';

import { Constants } from '../constants/Constants.sol';

import { SizedArray } from '../libs/SizedArrayLib.sol';


contract MeatPuppetSystem is System, Constants {

    address private world;
    /**
     * @param pId a player id and a room id
     * @param rId a room id
     * @dev the initialisation routine of right now the whole game takes a player id and
     *  a room ID and then spawns the player there.
     */
    function spawnPlayer(uint32 pId, uint32 rId) public {
        console.log("--->spawn player:%d, room:%d", pId, rId);
        world = _world();
        _enterRoom(rId, pId);
    }

    function _handleAlias(string[] memory tokens, uint32 playerId) private returns (uint8 err) {
        uint32 curRm = Player.getRoomId(playerId);

        ActionType vrb = IWorld(world).mp_TokeniserSystem_getActionType(tokens[0]);
        uint8 e;
//        console.log("---->HDL_ALIAS");
        if( vrb == ActionType.Inventory) {
            e = IWorld(world).mp_InventorySystem_inventory(world, playerId);
        } else if (vrb == ActionType.Look) {
            e = IWorld(world).mp_LookSystem_stuff(tokens, curRm, playerId);
        }
        return e;
    }

    /**
        At this point we should have a valid `VRB` as the initial parser takes care of this
        for us. We have already handled MOVE's and `ALIASES` (i.e short forms) so all that
        remains is to handle `LOOK` commands, `INVENTORY` cmds and everything else.
    */
    function _handleVerb(string[] memory tokens,  uint32 playerId) private returns (uint8 err) {
        uint32 curRm = Player.getRoomId(playerId);
        string memory resultStr;
        ActionType vrb = IWorld(world).mp_TokeniserSystem_getActionType(tokens[0]);
        uint8 e;
        console.log("---->HDL_VRB");
        VerbData memory cmdData = IWorld(world).mp_TokeniserSystem_fishTokens(tokens);
        if (vrb == ActionType.Look || vrb == ActionType.Describe) {
            e = IWorld(world).mp_LookSystem_stuff(tokens, curRm, playerId);
        } else if (vrb == ActionType.Take ) {
            e = IWorld(world).mp_InventorySystem_take(world,tokens, curRm, playerId);
        } else if (vrb == ActionType.Drop) {
            e = IWorld(world).mp_InventorySystem_drop(world,tokens, curRm, playerId);
        }  else {
            (e, resultStr) = IWorld(world).mp_ActionSystem_act(cmdData, curRm, playerId);
            // this is probably not the place for this
            Output.set(playerId, resultStr);
        }
        return e;
    }

    function _enterRoom(uint32 rId, uint32 playerId) private returns (uint8 err) {
        console.log("--------->ENTR_RM:", rId);
        Player.setRoomId(playerId, rId);
        Output.set(playerId,IWorld(world).mp_LookSystem_getRoomDesc(rId));
        return 0;
    }


    // intended soley to process tokens and then hand off to other systems
    // checks for first TOKEN which can be either a GO or another VERB.
    function processCommandTokens(string[] calldata tokens, uint32 playerId) public returns (uint8 err) {
        /* see action diagram in VP (tokenise) for logic */
        uint8 er;
        bool move;
        uint32 nxt;

        uint32 rId = Player.getRoomId(playerId);

        if (tokens.length > GameConstants.MAX_TOK) {
            er = ErrCodes.ER_PR_TK_CX;
        }
        string memory tok1 = tokens[0];
        console.log("---->CMD: %s", tok1);
        DirectionType tokD = IWorld(world).mp_TokeniserSystem_getDirectionType(tok1);

        if (tokD != DirectionType.None) {
            //console.log("---->DIR:");
            /* DIR: form */
            move = true;
            (er, nxt) = IWorld(world).mp_DirectionSystem_getNextRoom(tokens, rId);
        } else if (IWorld(world).mp_TokeniserSystem_getActionType(tok1) != ActionType.None ) {
            //console.log("---->VRB:");
            if (tokens.length >= 2) {
                //console.log("-->tok.len %d", tokens.length);
                if (IWorld(world).mp_TokeniserSystem_getActionType(tok1) == ActionType.Go) {
                    /* GO: form */
                    move = true;
                    (er, nxt) = IWorld(world).mp_DirectionSystem_getNextRoom(tokens, rId);
                } else {
                    /* VERB: form */
                    er = _handleVerb(tokens, playerId);
                    console.log("->ERR: %s", err);
                    move = false;
                }
            } else {
                er = _handleAlias(tokens, playerId);
                move = false;
            }
        } else {
            er = ErrCodes.ER_PR_NOP;
        }

        /* we have gone through the TOKENS, give err feedback if needed */
        if (er != 0) {
            console.log("----->PCR_ERR: err:", er);
            string memory errMsg;
            errMsg = _insultMeat(er, "");
            Output.set(playerId, errMsg);
            return er;
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
            eMsg = string.concat("Can't go that away ", badCmd);
        }
        return eMsg;
    }
}


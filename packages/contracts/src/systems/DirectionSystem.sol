// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import { console } from "forge-std/console.sol";

import { System } from "@latticexyz/world/src/System.sol";

import { IWorld } from "../codegen/world/IWorld.sol";

import { Constants } from "../constants/Constants.sol";

import { GameConstants, ErrCodes, ResCodes } from "../constants/defines.sol";

import { ITokeniserSystem } from '../codegen/world/ITokeniserSystem.sol';

import { ActionType, RoomType, ObjectType, CommandError, DirectionType } from "../codegen/common.sol";

import { RoomStore, RoomStoreData, ActionStore,ActionStoreData, DirObjectStore } from "../codegen/index.sol";

contract DirectionSystem is System, Constants {

    address world;

    function getNextRoom(string[] memory tokens, uint32 currRm) public returns (uint8 e, uint32 nxt) {
        //console.log("----->DF_NXT_RM tok: ", tokens[0]);
        world = _world();

        (string memory tok, uint8 tok_err) = _fishDirectionTok(tokens);

        if ( tok_err != 0 ) {
            return (tok_err, 0x10000);
        }

        /* Test DIRECTION */
        DirectionType DIR = IWorld(world).mp_TokeniserSystem_getDirectionType(tok);

        (bool mv, uint32 dObjId) = _directionCheck(currRm, DIR);
        if (mv) {
            //console.log("->DF--->DOBJ:", dObjId);
            uint32 nxtRm = DirObjectStore.getDestId(dObjId);
            //console.log("->DF --------->NXTRM:", nxtRm);
            return (0, nxtRm);
        }else { 
            console.log("--->DF:XXX");
            // check reason we didnt move this can currently only 
            // be cannot actually move that way because no exit
            //string memory errMsg;
            //errMsg = _insultMeat(GO_NO_EXT, tok);
            //Output.set(errMsg);
            return (ResCodes.GO_NO_EXIT, dObjId);
        }
    }

    function _canMove(uint32 exitId) private view returns (bool success) {
       // check LOCK/UNLOCK, OPEN/CLOSED 
       uint32[MAX_OBJ] memory actions = DirObjectStore.getObjectActionIds(exitId);
       bool canMove = false; // inits to 0 by default but lets be explicit
       for (uint8 i =0; i < actions.length; i++) {
           ActionStoreData memory action = ActionStore.get(actions[i]);
           if (action.actionType == ActionType.Open) {
               console.log("--->canMove_open: e:%s d:%s", action.enabled, action.dBit);
               canMove = action.enabled && action.dBit; 
           }        
           if (action.actionType == ActionType.Lock) {
               console.log("--->canMove_lock: e:%s d:%s", action.enabled, action.dBit);
               canMove = action.enabled && !action.dBit;
           }
       }
       // for now just allow it as we dont have any actions
       return canMove;
    }

    function _directionCheck (uint32 rId, DirectionType d) private view returns (bool success, uint32 next) {
        //console.log("---->DC room:", rId, "---> DR:", uint8(d));
        uint32[MAX_OBJ] memory exitIds = RoomStore.getDirObjIds(rId);  
        //console.log("---->DC room:", rId, "---> EXITIDS.LEN:", uint8(exitIds.length));
        for (uint8 i = 0; i < exitIds.length; i++) {
            //console.log( "-->i:", i, "-->[]", uint32(exitIds[i]) );
            // just for debug output
            //DirectionType dt = DirObjectStore.getDirType(exitIds[i]);
            //console.log( "-->i:", i, "-->", uint8(dt) );
            if ( DirObjectStore.getDirType(exitIds[i]) == d) {
                if (_canMove(exitIds[i]) == true){
                    return (true, exitIds[i]); 
                } else {
                    // TODO: the exit is there but we cant go that way
                    // TODO: why? So bubble up the reason
                }
            }
        }
        // bad idea but we use 0 as a roomId
        // need to fix, we should stick with Solidity idiom
        // which is 0 is always false/None/Null
        return (false, 0x10000);
    }

    function _fishDirectionTok(string[] memory tokens) private returns (string memory tok, uint8 err)  {

        if (IWorld(world).mp_TokeniserSystem_getDirectionType(tokens[0]) != DirectionType.None) {
            //console.log("--->DIR %s", tokens[0]);
            /* Direction form
            *
            * dir = n | e | s | w
            *
            */
            tok = tokens[0];
        } else if (IWorld(world).mp_TokeniserSystem_getActionType(tokens[0]) != ActionType.None ) {
            //console.log("--->GO %s", tok);
            /* GO form
            *
            * go_cmd = go, [(pp da)], dir | obj
            * pp = "to";
            * da = "the";
            * dir = n | e | s | w
            */
            if ( tokens.length >= 4 ) {
                //console.log("--->GO_LNG %s", tokens[3]);
                /* long form */
                /* go_cmd = go, ("to" "the"), dir|obj */
                tok = tokens[3]; // dir | obj
            } else if (tokens.length == 2) {
                //console.log("--->GO_SHRT %s", tokens[1]);
                /* short form */
                /* go_cmd = go, dir|obj */
                tok = tokens[1]; // dir | obj
                //TODO: handle for obj we probably dont even need it tbh
                // but anyway its here because I get carried away...
            }

            if (IWorld(world).mp_TokeniserSystem_getDirectionType(tok) != DirectionType.None ) {
                return (tok, 0);
            } else {
                return (tok, ErrCodes.ER_DR_ND);
            }
        }
    }

}

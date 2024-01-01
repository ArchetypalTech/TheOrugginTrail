// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { console } from "forge-std/console.sol";

import {System} from "@latticexyz/world/src/System.sol";

import { GameConstants, ErrCodes, ResCodes } from "../constants/defines.sol";

import { ITokeniserSystem } from '../codegen/world/ITokeniserSystem.sol';

import {ActionType, RoomType, ObjectType, CommandError, DirectionType} from "../codegen/common.sol";

contract DirectionFinderSystem is System {

    ITokeniserSystem luts;

    function initDFS(address tokeniser) public returns (address) {
        console.log("--->initDFS");
        luts = ITokeniserSystem(tokeniser);
        return address(this);
    }

    function getNextRoom(string[] calldata tokens, uint32 currRm) external view returns (uint8 e, uint32 nxtRm) {
        console.log("----->MV_PL to: ", tokens[0]);
        (string memory tok, uint8 tok_err) = _fishDirectionTok(tokens);
    }

    function _fishDirectionTok(string[] calldata tokens) private view returns (string memory tok, uint8 err)  {
        
        if (luts.getDirectionType(tokens[0]) != DirectionType.None) {
            /* Direction form
            *
            * dir = n | e | s | w
            *
            */
            tok = tokens[0];
        } else if ( luts.getActionType(tokens[0]) != ActionType.None ) {
            /* GO form
            * 
            * go_cmd = go, [(pp da)], dir | obj 
            * pp = "to";
            * da = "the";
            * dir = n | e | s | w
            */
            if ( tokens.length >= 4 ) {
                //[> long form <]
                //[> go_cmd = go, ("to" "the"), dir|obj <]
                tok = tokens[3]; // dir | obj
            } else if (tokens.length == 2) {
                //[> short form <]
                //[> go_cmd = go, dir|obj <]
                tok = tokens[1]; // dir | obj
                ////TODO: handle for obj we probably dont even need it tbh
                //// but anyway its here because I get carried away...
            }

            if ( luts.getDirectionType(tok) != DirectionType.None ) {
                return (tok, 0); 
            } else {
                return (tok, ErrCodes.ER_DR_ND);
            }
        }
    }

}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { ErrCodes, ResCodes } from '../../constants/defines.sol';
import { CommandLookups } from '../CommandLookup.sol';

import {ActionType, RoomType, ObjectType, CommandError, DirectionType} from "../../codegen/common.sol";

library Look {
    
    function fishDirectionTok(string[] memory tokens, CommandLookups lut) private view returns (string memory, uint8)  {
        string memory tok;
        uint8 err_code;
        if (lut.cmdLookup(tokens[0]) != ActionType.None) {
            /* Look form
            *
            * look_cmd = look 
            *
            */
            
        } else  {
            err_code = 127; 
        }
            /* GO form
            * 
                * go_cmd = go, [(pp da)], dir | obj 
            * pp = "to";
            * da = "the";
            * dir = n | e | s | w
            */
            //if ( tokens.length >= 4 ) {
                //[> long form <]
                    //[> go_cmd = go, ("to" "the"), dir|obj <]
                    //tok = tokens[3]; // dir | obj
            //} else if (tokens.length == 2) {
                //[> short form <]
                    //[> go_cmd = go, dir|obj <]
                    //tok = tokens[1]; // dir | obj
                ////TODO: handle for obj we probably dont even need it tbh
                //// but anyway its here because I get carried away...
            //}

            //if ( bc.dirLookup[tok] != bc.DirectionType.None ) {
                //return (tok, 0); 
            //} else {
                //return ("", bc.ER_DR_ND);
            //}
        //}
    }


    function look(string[] calldata tokens, CommandLookups caller) public returns (string memory, uint8) {
        return  fishDirectionTok(tokens, caller);
    }
}



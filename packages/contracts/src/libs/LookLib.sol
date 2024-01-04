// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import {console} from "forge-std/console.sol";
import { IWorld } from '../codegen/world/IWorld.sol'; 

import { ActionType, DirectionType } from '../codegen/common.sol';

library LookAt {
    /* l_cmd = (look, at, [ the ] , obj) | (look, around, [( [the], place )]) */

    function stuff(address wrld, string[] memory tokens, uint32 curRmId) internal returns (uint8 e) {
        // Composes the descriptions for stuff Players can see
        // right now that's from string's stored in object meta data
        console.log("---->SEE T:%s, R:%d", tokens[0], curRmId);

        ActionType vrb = IWorld(wrld).meat_TokeniserSystem_getActionType(tokens[0]);
        DirectionType dir;

        // we know it is an action because the commandProcessors has pre-parsed for us
        // so we dont need to test for a garbage vrb token
        if ( vrb == ActionType.Look ) {
            console.log("---->LOOK");
            string memory tok = tokens[tokens.length -1];
            if (tokens.length > 1) {

                
            }
        } else if ( vrb == ActionType.Describe ) {
            console.log("---->DESC");
        }
    }
}


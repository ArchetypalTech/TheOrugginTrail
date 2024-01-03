// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import {console} from "forge-std/console.sol";
import { IWorld } from '../codegen/world/IWorld.sol'; 

import { ActionType } from '../codegen/common.sol';

library LookAt {

    // Composes the descriptions for stuff Players can see
    // right now that's from string's stored in object meta data
    function stuff(address wrld, string[] memory tokens, uint32 curRmId) internal returns (uint8) {
        console.log("---->SEE T:%s, R:%d", tokens[0], curRmId);
        ActionType vrb = IWorld(wrld).meat_TokeniserSystem_getActionType(tokens[0]);

        // we know it is an action because the commandProcessors has pre-parsed for us
        // so we dont need to test for a garbage vrb token
        if ( vrb == ActionType.Look ) {
            console.log("---->LOOK");
        } else if ( vrb == ActionType.Describe ) {
            console.log("---->DESC");
        }
    }
}


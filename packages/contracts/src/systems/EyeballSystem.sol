// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { console } from "forge-std/console.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { ActionType, DirectionType, GrammarType } from "../codegen/common.sol";
import { Dirs } from "../codegen/tables/Dirs.sol";


contract EyeballSystem is System {

    address world;

    function initEYES(address wrld) public returns (address) {
        console.log("--->intEYES");
        world = wrld;
        return address(this);
    }
}


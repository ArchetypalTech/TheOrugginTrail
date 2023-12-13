// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import {System} from "@latticexyz/world/src/System.sol";
import {CurrentRoomId, Room, RoomData, Action, TextDef} from "../codegen/index.sol";

contract IncrementSystem is System {
    function initData() public returns (uint32) {




    }

    function processCommand(string memory command) public returns (string memory) {
        uint32 id = CurrentRoomId.get();
        uint32 newValue = id + 1;
        CurrentRoomId.set(newValue);
        return 'fuck off';
    }
}

contract DescribeRoom is System {
    function desribe() public returns (string memory) {
        return "FOO-RETURN";
    }
}


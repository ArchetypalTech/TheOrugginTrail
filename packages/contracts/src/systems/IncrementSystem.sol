// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import {System} from "@latticexyz/world/src/System.sol";
import {Counter} from "../codegen/index.sol";
import {Room, RoomData, Action, TextDef, History, HistoryData} from "../codegen/index.sol";

contract IncrementSystem is System {
    function increment() public returns (uint32) {
        uint32 counter = Counter.get();
        uint32 newValue = counter + 1;
        Counter.set(newValue);
        return newValue;
    }



    function processCommand(string memory command) public returns (uint32) {

        uint32 counter = Counter.get();
        uint32 newValue = counter + 1;
        Counter.set(newValue);
        return newValue;
    }
}

contract DescribeRoom is System {
    function desribe() public returns (string memory) {
        return "FOO-RETURN";
    }
}


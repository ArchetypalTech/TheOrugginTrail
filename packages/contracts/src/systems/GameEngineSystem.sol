// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import {System} from "@latticexyz/world/src/System.sol";
import {Output, CurrentRoomId, Room, RoomData, Action, TextDef} from "../codegen/index.sol";

contract GameEngineSystem is System {
    function initData() public returns (uint32) {

        Room.setTextDefId(0,0);
        Room.pushActions(0,1);


//        Room.setTextDefId(0, [0,1,2,3,4,5,6,7]);

     //   uint32[8] memory x = [0,1,2,3,4,5,6,7];

       // Room.setActions(0,x);

        Output.set('data initialised');

        return 0;
    }

    function processCommand(string memory command) public returns (string memory) {
        command;

        uint32 id = CurrentRoomId.get();
        uint32 newValue = id + 1;
        CurrentRoomId.set(newValue);

        // we need to change
        Output.set(command);

        return '';
    }
}

/*
contract DescribeRoom is System {
    function desribe() public returns (string memory) {
        return "FOO-RETURN";
    }
}
*/


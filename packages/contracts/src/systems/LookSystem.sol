// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import { console } from "forge-std/console.sol";

import { System } from "@latticexyz/world/src/System.sol";
import {IWorld} from '../codegen/world/IWorld.sol';
import {SizedArray} from '../libs/SizedArrayLib.sol';

import {ActionType, MaterialType, GrammarType, DirectionType, ObjectType, DirObjectType, TxtDefType, RoomType} from '../codegen/common.sol';
import {Player, PlayerTableId, RoomStore, ObjectStore, DirObjectStore, DirObjectStoreData, Description, Output, TxtDefStore} from '../codegen/index.sol';

contract LookSystem is System {

    

}

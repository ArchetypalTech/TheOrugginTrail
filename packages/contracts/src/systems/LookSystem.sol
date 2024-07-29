// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import { console } from "forge-std/console.sol";

import { System } from "@latticexyz/world/src/System.sol";
import {IWorld} from '../codegen/world/IWorld.sol';
import {ActionType, MaterialType, GrammarType, DirectionType, ObjectType, DirObjectType, TxtDefType, RoomType} from '../codegen/common.sol';
import {Player, PlayerTableId, RoomStore, ObjectStore, DirObjectStore, DirObjectStoreData, Description, Output, TxtDefStore} from '../codegen/index.sol';
import { Constants } from '../constants/Constants.sol';

contract LookSystem is System, Constants {

    address private wrld;   

    function stuff(string[] memory tokens, uint32 curRmId, uint32 playerId) public returns (uint8 e) {
        // Composes the descriptions for stuff Players can see
        // right now that's from string's stored in object meta data
        wrld = _world();
        console.log("---->SEE T:%s, R:%d", tokens[0], curRmId);
        uint8 err;
        ActionType vrb = IWorld(wrld).mp_TokeniserSystem_getActionType(tokens[0]);
        GrammarType gObj;

        // we know it is an action because the commandProcessors has pre-parsed for us
        // so we dont need to test for a garbage vrb token
        if (vrb == ActionType.Look) {
            console.log("---->LK RM:%s", curRmId);
            //string memory tok = tokens[tokens.length -1]; // use to determine the direct object
            if (tokens.length > 1) {
                gObj = IWorld(wrld).mp_TokeniserSystem_getGrammarType(tokens[tokens.length -1]);
                if (gObj != GrammarType.Adverb) {
                    err = _lookAround(curRmId, playerId);
                    console.log("->_LA:%s", err);
                }
            } else {
                // alias form LOOK
                err = _lookAround(curRmId, playerId);
                console.log("->_LOOK:%s", err);
            }
        } else if (vrb == ActionType.Describe || vrb == ActionType.Look) {
            console.log("---->DESC");
        }
        return err;
    }

    function getRoomDesc(uint32 id) public view returns (string memory d) {
        // return the room description but dont bother with the exits or the objects
        string memory desc = "You are ";
        if (RoomStore.getRoomType(id) == RoomType.Plain) {
            desc = string(abi.encodePacked(desc, "on ", RoomStore.getDescription(id), "\n"));
        } else {
            desc = string(abi.encodePacked(desc, "in ", RoomStore.getDescription(id), "\n"));
        }
        desc = string(abi.encodePacked(desc, "\n"));
        return desc;
    }

    function _genDescText(uint32 playerId, uint32 id) private view returns (string memory) {
        string memory desc = "You are standing ";
        string memory storedDesc = TxtDefStore.getValue(RoomStore.getTxtDefId(id));

        if (RoomStore.getRoomType(id) == RoomType.Plain) {
            desc = string.concat(desc, "on ", RoomStore.getDescription(id), "\n");
        } else {
            desc = string.concat(desc, "in ", RoomStore.getDescription(id), "\n");
        }
        // concat the general description
        desc = string.concat(desc, storedDesc, "\n");

        // handle the rooms objects
        desc = string.concat(desc, _genObjDesc(RoomStore.getObjectIds(id)));

        // handle the rooms exits
        desc = string.concat(desc, _genExitDesc(RoomStore.getDirObjIds(id), wrld));

        // handle player
        desc = string.concat(desc, _genPlayerPresenceDesc(playerId, id, wrld));

        return desc;
    }

    function _genObjDesc(uint32[32] memory objs) private view returns (string memory) {

        uint32 count = 0;

        // Count non-zero elements in the objs array
        for (uint8 i = 0; i < objs.length; i++) {
            if (objs[i] != 0) {
                count++;
            }
        }

        if (count != 0) {// if the first item is 0 then there are no objects
            string memory objsDesc = "\nYou can also see a ";
            for (uint8 i = 0; i < count; i++) {
                objsDesc = string(abi.encodePacked(objsDesc, ObjectStore.getDescription(objs[i]), "\n"));
                bytes32 tId = ObjectStore.getTxtDefId(objs[i]);

                objsDesc = string(abi.encodePacked(objsDesc, TxtDefStore.getValue(tId), "\n"));
            }
            return objsDesc;
        } else {
            return '';
        }
    }

    function _genMaterial(MaterialType mt, DirObjectType dt, string memory value, address wrld) private view returns (string memory) {
        string memory dsc;
        if (dt == DirObjectType.Path || dt == DirObjectType.Trail) {
            dsc = string(abi.encodePacked(value, " made mainly from ", IWorld(wrld).mp_TokeniserSystem_revMatType(mt), " "));
        } else {
            dsc = string(abi.encodePacked(IWorld(wrld).mp_TokeniserSystem_revMatType(mt), " ", value, " "));

        }
        return dsc;
    }

    // there is a PATH made os mud to the DIR | there is a wood door to the
    function _genExitDesc(uint32[32] memory objs, address wrld) private view returns (string memory) {

        uint32 count = 0;

        // Count non-zero elements in the objs array
        for (uint8 i = 0; i < objs.length; i++) {
            if (objs[i] != 0) {
                count++;
            }
        }

        if (count != 0) {// if the first item is 0 then there are no objects
            string memory exitsDesc = "\nThere is a ";
            for(uint8 i = 0; i < count; i++) {
                if (objs[i] != 0) { // again, an id of 0 means no value
                    DirObjectStoreData memory objData = DirObjectStore.get(objs[i]);// there is a fleshy path to the | there
                    if (i == 0) {
                        exitsDesc = string(abi.encodePacked(exitsDesc, _genMaterial(objData.matType,
                            objData.objType, TxtDefStore.getValue(objData.txtDefId), wrld),
                            "to the ",
                            IWorld(wrld).mp_TokeniserSystem_reverseDirType(objData.dirType), ".\n" ));
                    } else { // we got more exits
                        exitsDesc = string(abi.encodePacked(exitsDesc, "and there is a ", _genMaterial(objData.matType,
                            objData.objType, TxtDefStore.getValue(objData.txtDefId), wrld),
                            "to the ",IWorld(wrld).mp_TokeniserSystem_reverseDirType(objData.dirType),
                            "\n"));
                    }
                }
            }
            return exitsDesc;
        } else {
            return '';
        }
    }

    // there is a PATH made os mud to the DIR | there is a wood door to the
    function _genPlayerPresenceDesc(uint32 playerId, uint32 roomId, address wrld) private view returns (string memory) {
        uint32[32] memory playerIdsInRoom;

        // logic
        for (uint32 i = 1; i <= 3; i++) {
            if (playerId != i) {
                uint32 otherPlayerRoomId = Player.getRoomId(i);
                if (otherPlayerRoomId == roomId) {
                    _addElement(playerIdsInRoom, i);
                }
            }
        }

        uint32 count = 0;
        for (uint32 i = 0; i < playerIdsInRoom.length; i++) {
            if (playerIdsInRoom[i] != 0) {
                count++;
            }
        }

        if (count == 1) {
            return string(abi.encodePacked("\nIn this room is ", Player.getName(playerIdsInRoom[0])));
        } else if (count > 1) {
            string memory desc = "";
            for (uint32 i = 0 ; i < count; i ++) {
                desc = string(abi.encodePacked(desc, Player.getName(playerIdsInRoom[i])));
                if(i != count - 1)   desc = string(abi.encodePacked(desc, i != count - 2 ? ", " : " and "));
            }

            desc = string(abi.encodePacked(desc, " are here."));

            return desc;
        }

        return 'No other players at this location';

    }

    function _lookAround(uint32 rId, uint32 playerId) private returns (uint8 er) {
        Output.set(playerId, _genDescText(playerId, rId));
        return 0;
    }

    function _addElement(uint32[MAX_OBJ] memory arr, uint32 element) private pure returns (bool) {
        for (uint8 i = 0; i < arr.length; i++) {
            if (arr[i] == 0) {
                arr[i] = element;
                return true;
            }
        }
        return false; // Array is full
    }
}


    

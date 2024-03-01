// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import { ErrCodes ,GameConstants } from "../constants/defines.sol";
import {console} from "forge-std/console.sol";

library SizedArray {

    function add(uint32[32] memory array, uint32 item) internal view returns (uint8 err)  {
        console.log("------------->SizedArray.add item:%d", item);
        if (count(array) == GameConstants.SIZED_AR_SIZE-1) {
            return ErrCodes.ER_SIZED_AR_OUT_OF_SPACE;
        }

        array[count(array)] = item;
        incCount(array);

        logArray(array);

        return 0;
    }

    function remove(uint32[32] memory array, uint32 index) internal returns (uint8 err)  {
        console.log("------------->SizedArray.remove index:%d", index);
        console.log("------------->SizedArray.remove count:%d", count(array));

        if( index >= count(array)) {
            return ErrCodes.ER_SIZED_AR_NOT_ITEMS_TO_REMOVE;
        }

        array[index] = array[count(array)-1];
        decCount(array);

        logArray(array);

        return 0;
    }

    function count(uint32[32] memory array) internal view returns (uint32){
        // sadly no error handling, but add handles oversize
        return array[GameConstants.SIZED_AR_SIZE-1];
    }

    function decCount(uint32[32] memory array) private {
        array[GameConstants.SIZED_AR_SIZE-1]--;
    }

    function incCount(uint32[32] memory array) private view {
        array[GameConstants.SIZED_AR_SIZE-1]++;
    }

    function logArray(uint32[32] memory array) private view {
        console.log("------------->SizedArray.logArray :");
        for(uint32 i = 0 ;  i < count(array) ; i++) {
            console.log("--------------->%d", array[i]);
        }
        console.log("----------------->count:%d", array[GameConstants.SIZED_AR_SIZE-1]);
    }
}

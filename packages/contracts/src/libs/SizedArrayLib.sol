// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { ErrCodes ,GameConstants } from "../constants/defines.sol";

library SizedArray {

    function add(uint32[32] memory array, uint32 item) internal returns (uint8 err)  {
        if (count(array) == GameConstants.SIZED_AR_SIZE-1) {
            return ErrCodes.ER_SIZED_AR_OUT_OF_SPACE;
        }

        array[array[GameConstants.SIZED_AR_SIZE-1]] = item;
        incCount(array);

        return 0;
    }

    function remove(uint32[32] memory array, uint32 index) internal returns (uint8 err)  {
        if(index > GameConstants.SIZED_AR_SIZE-1) {
            return ErrCodes.ER_SIZED_AR_NOT_ITEMS_TO_REMOVE;
        }

        array[count(array)] = array[index];
        decCount(array);

        return 0;
    }

    function count(uint32[32] memory array) internal view returns (uint32){
        // sadly no error handling, but add handles oversize
        return array[GameConstants.SIZED_AR_SIZE-1];
    }

    function decCount(uint32[32] memory array) private {
        array[GameConstants.SIZED_AR_SIZE-1]--;
    }

    function incCount(uint32[32] memory array) private {
        array[GameConstants.SIZED_AR_SIZE-1]++;
    }




}

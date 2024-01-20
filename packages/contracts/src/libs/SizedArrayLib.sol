// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

library SizedArray {

    // defrags then counts the items and puts the count in the last element
    function initArray(uint32[] memory array) internal  {
        defragArray(array);
    }

    // removes 0 items from the dataset and updates the count
    function defragArray(uint32[] memory array) internal  {

    }

    function addItemToArray(uint32[] memory array, uint32 item) internal {

    }

    function removeItemFromArray(uint32[] memory array, uint32 index) internal {

    }


}

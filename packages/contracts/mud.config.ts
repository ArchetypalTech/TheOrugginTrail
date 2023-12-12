import { mudConfig } from "@latticexyz/world/register";

export default mudConfig({
    enums: {
        RoomType: ["Transport", "Actionable",],
        ActionType: ["Move", "Loot", "Describe",],
    },
    tables: {
        // all rooms take a description and a set of actions that themselves
        // have descriptions. Strings such as Decriptions get passed back as 
        // uint32's that then get mapped to a client side hash map of heavily
        // compressed strings. Ergo the key is the hash of that description.
        // This actual encoding has to be done by the adventure loader which 
        // actually should set up the game "map" and as such the contracts.
        //Room: {
            //keySchema: {
                //roomId: "uint32",
            //},
            //// Rooms have for now 8 arbitrary descriptions attached because ?
            //// also an arbitrary 8 Actions
            //valueSchema: {
                //textDefId: "uint32[8]",
                ////actions: "uint32[8]",
                ////roomType: "RoomType",
            //},
       //},
        //Action: {
            //keySchema: {
                //actionId: "uint32",
            //},
            //valueSchema: {
                //actionType: "ActionType",
            //},
        //},
        TextDef: {
            keySchema: {},
            valueSchema: "uint32",
        },
        Counter: {
            keySchema: {},
            valueSchema: "uint32",
        },
        History: {
            keySchema: {
                counterValue: "uint32",
            },
            valueSchema: {
                blockNumber: "uint256",
                time: "uint256",
            },
        },
    },
});

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
        Room: {
            keySchema: {
                roomId: "uint32",
            },
            // Rooms have for now 8 arbitrary descriptions attached because ?
            // also an arbitrary 8 Actions
            valueSchema: {
                roomType: "RoomType",
                textDefId: "uint32[8]",
                actions: "uint32[8]",
            },
       },
        Action: {
            keySchema: {
                actionId: "uint32",
            },
            valueSchema: {
                actionType: "ActionType",
            },
        },
        TextDef: {
            keySchema: {},
            valueSchema: "uint32",
        },
        CurrentRoomId: {
            keySchema: {},
            valueSchema: "uint32",
        },
        Output: {
            keySchema: {},
            valueSchema: "string",
        },
    },
});

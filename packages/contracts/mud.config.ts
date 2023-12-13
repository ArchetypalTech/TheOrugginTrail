import { mudConfig } from "@latticexyz/world/register";

export default mudConfig({
    enums: {
        // all places on the 2d map grid are either Void or Place:
        // 0x00 | 0x01
        // Voids have no Objects 
        // Places have Objects, of which Door is one.
        // Objects have actions, eg Doors can Open or not.
        //
        RoomType: ["Void", "Place"],
        ActionType: ["Move", "Loot", "Describe", "Take", "Kick", "Lock", "Unlock"],
        ObjectType: ["Door", "Ball", "Key", "Window"],
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
                textDefId: "uint32",
                actions: "uint32[]",
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

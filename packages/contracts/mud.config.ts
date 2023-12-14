import { mudConfig } from "@latticexyz/world/register";

export default mudConfig({
    enums: {
        // all places on the 2d map grid are either Void or Place:
        // 0x00 | 0x01
        // Voids have no Objects 
        // Places have Objects, of which Door is one.
        // Objects have Actions, eg Doors can Open or not.
        // Actions generate NESS or Bool 
        // ie. "Lock Door":
        // the Room/Place with Door with Lock -> Lock-NESS -> Place(Door(Lock(NESS(1))))
        // NB This doesn't equate to Open-NESS, a door could be LockY AND OpenY
        //
        // For now fuck it...
        //
        RoomType: ["Void", "Place"],
        ActionType: ["Move", "Loot", "Describe", "Take", "Kick", "Lock", "Unlock", "Open"],
        ObjectType: ["Door", "Ball", "Key", "Window"],
    },
    tables: {
        // all rooms take a description and a set of Objects that themselves
        // have descriptions and Actions.
        // We handle descriptions like everything else, its a ref to a 
        // row in a Table.
        GameMap: {
            keySchema: {},
            valueSchema: {
                width: "uint32",
                height: "uint32",
                bigOlePlace: "uint32[]",
            },
        },       
        RoomStore: {
            keySchema: {
                roomId: "uint32",
            },
            valueSchema: {
                roomType: "RoomType",
                textDefId: "uint32",
                objectIds: "uint32[]",
            },
        },
        ActionStore: {
            keySchema: {
                actionId: "uint32",
            },
            valueSchema: {
                actionType: "ActionType",
            },
        },
        ObjectStore: {
            keySchema: {
                objectId: "uint32",
            },
            valueSchema: {
                objectType: "ObjectType",
                texDefId: "uint32",
                objectActions: "uint32[]",
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

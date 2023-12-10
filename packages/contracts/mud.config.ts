import { mudConfig } from "@latticexyz/world/register";

export default mudConfig({
    enums: {
        RoomType: ["Transport", "Actionable"],
        ActionType: ["Move", "Mutate", "Describe"],
    },
    tables: {
        Room: {
            keySchema: {
                roomId: "uint32",
            },
            valueSchema: {
                textDefId: "uint32",
                roomType: "RoomType",
                actions: "bytes",
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
            keyScheme: {
                textId: "uint32",
            },
            valueSchema: {
                description: "string",
            },
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

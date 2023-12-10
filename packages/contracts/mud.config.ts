import { mudConfig } from "@latticexyz/world/register";

export default mudConfig({
  enums: {
      RoomType: ["transport", "actionable"],
      ActionType: ["move", "mutate", "describe"]
  },
  tables: {
     Room: {
         keySchema: {
             roomId: "uint32",
         },
         valueSchema: {
             textDefId: "uint32",
             actions: "uint32",
             roomType: "Roomtype"
         },
      },
    Action: {
        keySchema: {
            actionId: "uint32",
        },
        valueSchema: {
            responseType: "ResponseType",
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

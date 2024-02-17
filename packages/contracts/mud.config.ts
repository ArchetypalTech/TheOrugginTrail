import { mudConfig } from "@latticexyz/world/register";

export default mudConfig({
    namespace: "meat",
    enums: {
        // all places on the 2d map grid are either Void or Place:
        // 0x00 | 0x01
        // Voids/None have no Objects cant be travelled through etc.
        //
        // Places have Objects
        // Objects have Actions, eg Chests can Open or not.
        // Actions generate NESS or Bool
        // ie. "Lock Door":
        // the Room/Place with Door with Lock -> Lock-NESS -> Place(Door(Lock(NESS(1))))
        // NB This doesn't equate to Open-NESS, a door could be LockY AND OpenY
        //
        // NB Something else abour Doors
        // They are DirectionObjects.
        // DirectionObjects also have a Direction
        // an ObjectType, when they are in a map they are a Portal. It allows us to
        // map a map, and it allows us to link a Places Door to the portal that it
        // links to. Portals connect non void places on the map.
        //
        // For now fuck it...
        //
        // we will use the keys for left shifting values
        // in a 32 bit var so we have maskable state from the
        // map data
        TypeKeys: [
            "None", "BiomeTypes", "TerrainTypes",
            "RoomType", "ActionType",
        ],
        // use in describe things as a construciton type
        BiomeType: [
            "None","Tundra", "Arctic", "Temporate",
            "Alpine", "Jungle", "Faery"
        ],
        // Terrain has paths
        TerrainType: [
            "None", "Path", "Forest", "Plains",
            "Mud", "DirtPath", "Portal"
        ],
        // Rooms have doors/exits
        RoomType: [
            "None", "WoodCabin", "Store",
            "Cavern", "StoneCabin", "Fort", "Room",
            "Plain"
        ],
        /** @dev use these to set direction bits on a DirectionObject
         * such as a door
         */
        DirectionType: [
            "None", "North", "South", "East", "West",
            "Up", "Down", "Forward", "Backward"
        ],
        /**
         * @dev add these to ROOMS to allow for movement
         * between them
         */
        DirObjectType: [
            "None", "Door", "Window", "Stairs", "Ladder",
            "Path", "Trail"
        ],
        /**
         * @dev use these in the parser, they are VERBS
         * we also use them to look for VERB response mapping
         * e.g. KICK actions can affect HIT, DAMAGE, BREAK actions
        */
        ActionType: [
            "None", "Go", "Move", "Loot", "Describe",
            "Take", "Kick", "Lock", "Unlock", "Open",
            "Look", "Close", "Break", "Throw", "Drop",
            "Inventory", "Burn", "Light", "Damage", "Hit"
        ],
        // add these to rooms for stuff to do
        ObjectType: [
            "None", "Football", "Key", "Knife", "Bottle", "Straw", "Petrol"
        ],
        GrammarType: ["None", "DefiniteArticle", "Preposition", "Adverb", "DemPronoun"],
        MaterialType: ["None", "Wood", "Stone", "Iron", "Shit", "IKEA", "Flesh",
                        "Dirt", "Mud", "Glass"],
        TxtDefType: ["None", "DirObject", "Dir", "Place", "Object", "Action"],
        CommandError: ["NONE", "LEN", "NOP", "GONOWHERE", "GOWHERE"],
    },
    tables: {
        // all rooms take a description and a set of Objects that themselves
        // have descriptions and Actions.
        Dirs: {
            keySchema: {
                key: "bytes32",
            },
            valueSchema: {
                dir: "DirectionType",
                tok: "string",
            },
        },
        Vrbs: {
            keySchema: {
                val: "ActionType",
            },
            valueSchema: {
                dirType: "string",
            },
        },
        RoomStore: { // add
            keySchema: {
                roomId: "uint32",
            },
            valueSchema: {
                roomType: "RoomType",
                txtDefId: "bytes32",
                description: "string", //temp
                objectIds: "uint32[32]",
                dirObjIds: "uint32[32]",
                players: "uint32[32]"
            },
        },
        // NOTE the use of the `affects` and `affectedBy` actionIds
        // we use these to create chains so if an action is `affectedBy`
        // an object then that object must have the correct thing
        // say a `rusty key` if they do then the `affects` would
        // link to an `open` action and the thing would open.
        ActionStore: {
            keySchema: {
                actionId: "uint32",
            },
            valueSchema: {
                actionType: "ActionType",
                dBitTxt: "bytes32", // txt when the state is flipped
                enabled: "bool", // can it be used? so we can chain disabled actions that are triggered
                dBit: "bool", // is it done, LOCK->lockED, CLOSE -> closeED etc
                affectsActionId: "uint32", // follow this action chain and flip bits
                affectedByActionId: "uint32" // does this id match the calling action
            },
        },
        // attach to rooms/paths to set the exits
        // give it a DirObjType like DOOR
        // then give it a directionType like NORTH
        // then give it an Action like OPEN or LOCKED
        // or BOTH!
        DirObjectStore: {
            keySchema: {
                dirObjId: "uint32",
            },
            valueSchema: {
                objType: "DirObjectType", // Door/Window/CaveMouth etc
                dirType: "DirectionType", // North, South, Up etc
                matType: "MaterialType",
                destId: "uint32",
                txtDefId: "bytes32",
                objectActionIds: "uint32[32]" // Open/Lock/Break etc
            },
        },
        ObjectStore: {
            keySchema: {
                objectId: "uint32",
            },
            valueSchema: {
                objectType: "ObjectType",
                materialType: "MaterialType",
                txtDefId: "bytes32",
                objectActionIds: "uint32[32]",
                description: "string"
            },
        },
        // we are going to store a hash over the actual description
        // string/s here (keccak256) that will then be used as the key for the compressed
        // data on the client which de-compresses it from some form of hash map or what have you
        // it should be generated by build tools. It isn't.
        // we keep a link to the owning thing so that we can
        // fetch a material type. Probably a bad idea. The bool
        // is to control a processing flag.
        TxtDefStore: {
            keySchema: {
                txtDefId: "bytes32",
            },
            valueSchema: {
                owner: "uint32", // get material type
                txtDefType: "TxtDefType",
                value: "string",
            },
        },
        ActionOutputs: {
            keySchema: {
                actionId: "uint32",
            },
            valueSchema: {
                txtIds: "bytes32[]"
            },
        },
        Output: {
            keySchema: {
            },
            valueSchema: {
                playerId: "uint32",
                text: "string",
           },
        },
        Description: { // might need a player id for multiplayer
            keySchema: {},
            valueSchema: {
                txtIds: "bytes32[]"
            },
        },
        Player: {
            keySchema: {
                playerId: "uint32",
            },
            valueSchema: {
                roomId: "uint32",
                objectIds: "uint32[32]",
                name: "string",
            },
        },
    },
});

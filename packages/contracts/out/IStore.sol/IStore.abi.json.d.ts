declare const abi: [
  {
    "type": "function",
    "name": "deleteRecord",
    "inputs": [
      {
        "name": "tableId",
        "type": "bytes32",
        "internalType": "ResourceId"
      },
      {
        "name": "keyTuple",
        "type": "bytes32[]",
        "internalType": "bytes32[]"
      }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "getDynamicField",
    "inputs": [
      {
        "name": "tableId",
        "type": "bytes32",
        "internalType": "ResourceId"
      },
      {
        "name": "keyTuple",
        "type": "bytes32[]",
        "internalType": "bytes32[]"
      },
      {
        "name": "dynamicFieldIndex",
        "type": "uint8",
        "internalType": "uint8"
      }
    ],
    "outputs": [
      {
        "name": "",
        "type": "bytes",
        "internalType": "bytes"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "getDynamicFieldLength",
    "inputs": [
      {
        "name": "tableId",
        "type": "bytes32",
        "internalType": "ResourceId"
      },
      {
        "name": "keyTuple",
        "type": "bytes32[]",
        "internalType": "bytes32[]"
      },
      {
        "name": "dynamicFieldIndex",
        "type": "uint8",
        "internalType": "uint8"
      }
    ],
    "outputs": [
      {
        "name": "",
        "type": "uint256",
        "internalType": "uint256"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "getDynamicFieldSlice",
    "inputs": [
      {
        "name": "tableId",
        "type": "bytes32",
        "internalType": "ResourceId"
      },
      {
        "name": "keyTuple",
        "type": "bytes32[]",
        "internalType": "bytes32[]"
      },
      {
        "name": "dynamicFieldIndex",
        "type": "uint8",
        "internalType": "uint8"
      },
      {
        "name": "start",
        "type": "uint256",
        "internalType": "uint256"
      },
      {
        "name": "end",
        "type": "uint256",
        "internalType": "uint256"
      }
    ],
    "outputs": [
      {
        "name": "data",
        "type": "bytes",
        "internalType": "bytes"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "getField",
    "inputs": [
      {
        "name": "tableId",
        "type": "bytes32",
        "internalType": "ResourceId"
      },
      {
        "name": "keyTuple",
        "type": "bytes32[]",
        "internalType": "bytes32[]"
      },
      {
        "name": "fieldIndex",
        "type": "uint8",
        "internalType": "uint8"
      },
      {
        "name": "fieldLayout",
        "type": "bytes32",
        "internalType": "FieldLayout"
      }
    ],
    "outputs": [
      {
        "name": "data",
        "type": "bytes",
        "internalType": "bytes"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "getField",
    "inputs": [
      {
        "name": "tableId",
        "type": "bytes32",
        "internalType": "ResourceId"
      },
      {
        "name": "keyTuple",
        "type": "bytes32[]",
        "internalType": "bytes32[]"
      },
      {
        "name": "fieldIndex",
        "type": "uint8",
        "internalType": "uint8"
      }
    ],
    "outputs": [
      {
        "name": "data",
        "type": "bytes",
        "internalType": "bytes"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "getFieldLayout",
    "inputs": [
      {
        "name": "tableId",
        "type": "bytes32",
        "internalType": "ResourceId"
      }
    ],
    "outputs": [
      {
        "name": "fieldLayout",
        "type": "bytes32",
        "internalType": "FieldLayout"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "getFieldLength",
    "inputs": [
      {
        "name": "tableId",
        "type": "bytes32",
        "internalType": "ResourceId"
      },
      {
        "name": "keyTuple",
        "type": "bytes32[]",
        "internalType": "bytes32[]"
      },
      {
        "name": "fieldIndex",
        "type": "uint8",
        "internalType": "uint8"
      },
      {
        "name": "fieldLayout",
        "type": "bytes32",
        "internalType": "FieldLayout"
      }
    ],
    "outputs": [
      {
        "name": "",
        "type": "uint256",
        "internalType": "uint256"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "getFieldLength",
    "inputs": [
      {
        "name": "tableId",
        "type": "bytes32",
        "internalType": "ResourceId"
      },
      {
        "name": "keyTuple",
        "type": "bytes32[]",
        "internalType": "bytes32[]"
      },
      {
        "name": "fieldIndex",
        "type": "uint8",
        "internalType": "uint8"
      }
    ],
    "outputs": [
      {
        "name": "",
        "type": "uint256",
        "internalType": "uint256"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "getKeySchema",
    "inputs": [
      {
        "name": "tableId",
        "type": "bytes32",
        "internalType": "ResourceId"
      }
    ],
    "outputs": [
      {
        "name": "keySchema",
        "type": "bytes32",
        "internalType": "Schema"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "getRecord",
    "inputs": [
      {
        "name": "tableId",
        "type": "bytes32",
        "internalType": "ResourceId"
      },
      {
        "name": "keyTuple",
        "type": "bytes32[]",
        "internalType": "bytes32[]"
      },
      {
        "name": "fieldLayout",
        "type": "bytes32",
        "internalType": "FieldLayout"
      }
    ],
    "outputs": [
      {
        "name": "staticData",
        "type": "bytes",
        "internalType": "bytes"
      },
      {
        "name": "encodedLengths",
        "type": "bytes32",
        "internalType": "PackedCounter"
      },
      {
        "name": "dynamicData",
        "type": "bytes",
        "internalType": "bytes"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "getRecord",
    "inputs": [
      {
        "name": "tableId",
        "type": "bytes32",
        "internalType": "ResourceId"
      },
      {
        "name": "keyTuple",
        "type": "bytes32[]",
        "internalType": "bytes32[]"
      }
    ],
    "outputs": [
      {
        "name": "staticData",
        "type": "bytes",
        "internalType": "bytes"
      },
      {
        "name": "encodedLengths",
        "type": "bytes32",
        "internalType": "PackedCounter"
      },
      {
        "name": "dynamicData",
        "type": "bytes",
        "internalType": "bytes"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "getStaticField",
    "inputs": [
      {
        "name": "tableId",
        "type": "bytes32",
        "internalType": "ResourceId"
      },
      {
        "name": "keyTuple",
        "type": "bytes32[]",
        "internalType": "bytes32[]"
      },
      {
        "name": "fieldIndex",
        "type": "uint8",
        "internalType": "uint8"
      },
      {
        "name": "fieldLayout",
        "type": "bytes32",
        "internalType": "FieldLayout"
      }
    ],
    "outputs": [
      {
        "name": "",
        "type": "bytes32",
        "internalType": "bytes32"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "getValueSchema",
    "inputs": [
      {
        "name": "tableId",
        "type": "bytes32",
        "internalType": "ResourceId"
      }
    ],
    "outputs": [
      {
        "name": "valueSchema",
        "type": "bytes32",
        "internalType": "Schema"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "popFromDynamicField",
    "inputs": [
      {
        "name": "tableId",
        "type": "bytes32",
        "internalType": "ResourceId"
      },
      {
        "name": "keyTuple",
        "type": "bytes32[]",
        "internalType": "bytes32[]"
      },
      {
        "name": "dynamicFieldIndex",
        "type": "uint8",
        "internalType": "uint8"
      },
      {
        "name": "byteLengthToPop",
        "type": "uint256",
        "internalType": "uint256"
      }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "pushToDynamicField",
    "inputs": [
      {
        "name": "tableId",
        "type": "bytes32",
        "internalType": "ResourceId"
      },
      {
        "name": "keyTuple",
        "type": "bytes32[]",
        "internalType": "bytes32[]"
      },
      {
        "name": "dynamicFieldIndex",
        "type": "uint8",
        "internalType": "uint8"
      },
      {
        "name": "dataToPush",
        "type": "bytes",
        "internalType": "bytes"
      }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "registerStoreHook",
    "inputs": [
      {
        "name": "tableId",
        "type": "bytes32",
        "internalType": "ResourceId"
      },
      {
        "name": "hookAddress",
        "type": "address",
        "internalType": "contract IStoreHook"
      },
      {
        "name": "enabledHooksBitmap",
        "type": "uint8",
        "internalType": "uint8"
      }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "registerTable",
    "inputs": [
      {
        "name": "tableId",
        "type": "bytes32",
        "internalType": "ResourceId"
      },
      {
        "name": "fieldLayout",
        "type": "bytes32",
        "internalType": "FieldLayout"
      },
      {
        "name": "keySchema",
        "type": "bytes32",
        "internalType": "Schema"
      },
      {
        "name": "valueSchema",
        "type": "bytes32",
        "internalType": "Schema"
      },
      {
        "name": "keyNames",
        "type": "string[]",
        "internalType": "string[]"
      },
      {
        "name": "fieldNames",
        "type": "string[]",
        "internalType": "string[]"
      }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "setDynamicField",
    "inputs": [
      {
        "name": "tableId",
        "type": "bytes32",
        "internalType": "ResourceId"
      },
      {
        "name": "keyTuple",
        "type": "bytes32[]",
        "internalType": "bytes32[]"
      },
      {
        "name": "dynamicFieldIndex",
        "type": "uint8",
        "internalType": "uint8"
      },
      {
        "name": "data",
        "type": "bytes",
        "internalType": "bytes"
      }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "setField",
    "inputs": [
      {
        "name": "tableId",
        "type": "bytes32",
        "internalType": "ResourceId"
      },
      {
        "name": "keyTuple",
        "type": "bytes32[]",
        "internalType": "bytes32[]"
      },
      {
        "name": "fieldIndex",
        "type": "uint8",
        "internalType": "uint8"
      },
      {
        "name": "data",
        "type": "bytes",
        "internalType": "bytes"
      }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "setField",
    "inputs": [
      {
        "name": "tableId",
        "type": "bytes32",
        "internalType": "ResourceId"
      },
      {
        "name": "keyTuple",
        "type": "bytes32[]",
        "internalType": "bytes32[]"
      },
      {
        "name": "fieldIndex",
        "type": "uint8",
        "internalType": "uint8"
      },
      {
        "name": "data",
        "type": "bytes",
        "internalType": "bytes"
      },
      {
        "name": "fieldLayout",
        "type": "bytes32",
        "internalType": "FieldLayout"
      }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "setRecord",
    "inputs": [
      {
        "name": "tableId",
        "type": "bytes32",
        "internalType": "ResourceId"
      },
      {
        "name": "keyTuple",
        "type": "bytes32[]",
        "internalType": "bytes32[]"
      },
      {
        "name": "staticData",
        "type": "bytes",
        "internalType": "bytes"
      },
      {
        "name": "encodedLengths",
        "type": "bytes32",
        "internalType": "PackedCounter"
      },
      {
        "name": "dynamicData",
        "type": "bytes",
        "internalType": "bytes"
      }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "setStaticField",
    "inputs": [
      {
        "name": "tableId",
        "type": "bytes32",
        "internalType": "ResourceId"
      },
      {
        "name": "keyTuple",
        "type": "bytes32[]",
        "internalType": "bytes32[]"
      },
      {
        "name": "fieldIndex",
        "type": "uint8",
        "internalType": "uint8"
      },
      {
        "name": "data",
        "type": "bytes",
        "internalType": "bytes"
      },
      {
        "name": "fieldLayout",
        "type": "bytes32",
        "internalType": "FieldLayout"
      }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "spliceDynamicData",
    "inputs": [
      {
        "name": "tableId",
        "type": "bytes32",
        "internalType": "ResourceId"
      },
      {
        "name": "keyTuple",
        "type": "bytes32[]",
        "internalType": "bytes32[]"
      },
      {
        "name": "dynamicFieldIndex",
        "type": "uint8",
        "internalType": "uint8"
      },
      {
        "name": "startWithinField",
        "type": "uint40",
        "internalType": "uint40"
      },
      {
        "name": "deleteCount",
        "type": "uint40",
        "internalType": "uint40"
      },
      {
        "name": "data",
        "type": "bytes",
        "internalType": "bytes"
      }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "spliceStaticData",
    "inputs": [
      {
        "name": "tableId",
        "type": "bytes32",
        "internalType": "ResourceId"
      },
      {
        "name": "keyTuple",
        "type": "bytes32[]",
        "internalType": "bytes32[]"
      },
      {
        "name": "start",
        "type": "uint48",
        "internalType": "uint48"
      },
      {
        "name": "data",
        "type": "bytes",
        "internalType": "bytes"
      }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "storeVersion",
    "inputs": [],
    "outputs": [
      {
        "name": "version",
        "type": "bytes32",
        "internalType": "bytes32"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "unregisterStoreHook",
    "inputs": [
      {
        "name": "tableId",
        "type": "bytes32",
        "internalType": "ResourceId"
      },
      {
        "name": "hookAddress",
        "type": "address",
        "internalType": "contract IStoreHook"
      }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "event",
    "name": "HelloStore",
    "inputs": [
      {
        "name": "storeVersion",
        "type": "bytes32",
        "indexed": true,
        "internalType": "bytes32"
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "Store_DeleteRecord",
    "inputs": [
      {
        "name": "tableId",
        "type": "bytes32",
        "indexed": true,
        "internalType": "ResourceId"
      },
      {
        "name": "keyTuple",
        "type": "bytes32[]",
        "indexed": false,
        "internalType": "bytes32[]"
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "Store_SetRecord",
    "inputs": [
      {
        "name": "tableId",
        "type": "bytes32",
        "indexed": true,
        "internalType": "ResourceId"
      },
      {
        "name": "keyTuple",
        "type": "bytes32[]",
        "indexed": false,
        "internalType": "bytes32[]"
      },
      {
        "name": "staticData",
        "type": "bytes",
        "indexed": false,
        "internalType": "bytes"
      },
      {
        "name": "encodedLengths",
        "type": "bytes32",
        "indexed": false,
        "internalType": "PackedCounter"
      },
      {
        "name": "dynamicData",
        "type": "bytes",
        "indexed": false,
        "internalType": "bytes"
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "Store_SpliceDynamicData",
    "inputs": [
      {
        "name": "tableId",
        "type": "bytes32",
        "indexed": true,
        "internalType": "ResourceId"
      },
      {
        "name": "keyTuple",
        "type": "bytes32[]",
        "indexed": false,
        "internalType": "bytes32[]"
      },
      {
        "name": "start",
        "type": "uint48",
        "indexed": false,
        "internalType": "uint48"
      },
      {
        "name": "deleteCount",
        "type": "uint40",
        "indexed": false,
        "internalType": "uint40"
      },
      {
        "name": "encodedLengths",
        "type": "bytes32",
        "indexed": false,
        "internalType": "PackedCounter"
      },
      {
        "name": "data",
        "type": "bytes",
        "indexed": false,
        "internalType": "bytes"
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "Store_SpliceStaticData",
    "inputs": [
      {
        "name": "tableId",
        "type": "bytes32",
        "indexed": true,
        "internalType": "ResourceId"
      },
      {
        "name": "keyTuple",
        "type": "bytes32[]",
        "indexed": false,
        "internalType": "bytes32[]"
      },
      {
        "name": "start",
        "type": "uint48",
        "indexed": false,
        "internalType": "uint48"
      },
      {
        "name": "data",
        "type": "bytes",
        "indexed": false,
        "internalType": "bytes"
      }
    ],
    "anonymous": false
  },
  {
    "type": "error",
    "name": "Store_IndexOutOfBounds",
    "inputs": [
      {
        "name": "length",
        "type": "uint256",
        "internalType": "uint256"
      },
      {
        "name": "accessedIndex",
        "type": "uint256",
        "internalType": "uint256"
      }
    ]
  },
  {
    "type": "error",
    "name": "Store_InvalidDynamicDataLength",
    "inputs": [
      {
        "name": "expected",
        "type": "uint256",
        "internalType": "uint256"
      },
      {
        "name": "received",
        "type": "uint256",
        "internalType": "uint256"
      }
    ]
  },
  {
    "type": "error",
    "name": "Store_InvalidFieldNamesLength",
    "inputs": [
      {
        "name": "expected",
        "type": "uint256",
        "internalType": "uint256"
      },
      {
        "name": "received",
        "type": "uint256",
        "internalType": "uint256"
      }
    ]
  },
  {
    "type": "error",
    "name": "Store_InvalidKeyNamesLength",
    "inputs": [
      {
        "name": "expected",
        "type": "uint256",
        "internalType": "uint256"
      },
      {
        "name": "received",
        "type": "uint256",
        "internalType": "uint256"
      }
    ]
  },
  {
    "type": "error",
    "name": "Store_InvalidResourceType",
    "inputs": [
      {
        "name": "expected",
        "type": "bytes2",
        "internalType": "bytes2"
      },
      {
        "name": "resourceId",
        "type": "bytes32",
        "internalType": "ResourceId"
      },
      {
        "name": "resourceIdString",
        "type": "string",
        "internalType": "string"
      }
    ]
  },
  {
    "type": "error",
    "name": "Store_InvalidSplice",
    "inputs": [
      {
        "name": "startWithinField",
        "type": "uint40",
        "internalType": "uint40"
      },
      {
        "name": "deleteCount",
        "type": "uint40",
        "internalType": "uint40"
      },
      {
        "name": "fieldLength",
        "type": "uint40",
        "internalType": "uint40"
      }
    ]
  },
  {
    "type": "error",
    "name": "Store_InvalidValueSchemaLength",
    "inputs": [
      {
        "name": "expected",
        "type": "uint256",
        "internalType": "uint256"
      },
      {
        "name": "received",
        "type": "uint256",
        "internalType": "uint256"
      }
    ]
  },
  {
    "type": "error",
    "name": "Store_TableAlreadyExists",
    "inputs": [
      {
        "name": "tableId",
        "type": "bytes32",
        "internalType": "ResourceId"
      },
      {
        "name": "tableIdString",
        "type": "string",
        "internalType": "string"
      }
    ]
  },
  {
    "type": "error",
    "name": "Store_TableNotFound",
    "inputs": [
      {
        "name": "tableId",
        "type": "bytes32",
        "internalType": "ResourceId"
      },
      {
        "name": "tableIdString",
        "type": "string",
        "internalType": "string"
      }
    ]
  }
]; export default abi;

declare const abi: [
  {
    "type": "error",
    "name": "World_AccessDenied",
    "inputs": [
      {
        "name": "resource",
        "type": "string",
        "internalType": "string"
      },
      {
        "name": "caller",
        "type": "address",
        "internalType": "address"
      }
    ]
  },
  {
    "type": "error",
    "name": "World_AlreadyInitialized",
    "inputs": []
  },
  {
    "type": "error",
    "name": "World_CallbackNotAllowed",
    "inputs": [
      {
        "name": "functionSelector",
        "type": "bytes4",
        "internalType": "bytes4"
      }
    ]
  },
  {
    "type": "error",
    "name": "World_DelegationNotFound",
    "inputs": [
      {
        "name": "delegator",
        "type": "address",
        "internalType": "address"
      },
      {
        "name": "delegatee",
        "type": "address",
        "internalType": "address"
      }
    ]
  },
  {
    "type": "error",
    "name": "World_FunctionSelectorAlreadyExists",
    "inputs": [
      {
        "name": "functionSelector",
        "type": "bytes4",
        "internalType": "bytes4"
      }
    ]
  },
  {
    "type": "error",
    "name": "World_FunctionSelectorNotFound",
    "inputs": [
      {
        "name": "functionSelector",
        "type": "bytes4",
        "internalType": "bytes4"
      }
    ]
  },
  {
    "type": "error",
    "name": "World_InsufficientBalance",
    "inputs": [
      {
        "name": "balance",
        "type": "uint256",
        "internalType": "uint256"
      },
      {
        "name": "amount",
        "type": "uint256",
        "internalType": "uint256"
      }
    ]
  },
  {
    "type": "error",
    "name": "World_InterfaceNotSupported",
    "inputs": [
      {
        "name": "contractAddress",
        "type": "address",
        "internalType": "address"
      },
      {
        "name": "interfaceId",
        "type": "bytes4",
        "internalType": "bytes4"
      }
    ]
  },
  {
    "type": "error",
    "name": "World_InvalidResourceId",
    "inputs": [
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
    "name": "World_InvalidResourceType",
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
    "name": "World_ResourceAlreadyExists",
    "inputs": [
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
    "name": "World_ResourceNotFound",
    "inputs": [
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
    "name": "World_SystemAlreadyExists",
    "inputs": [
      {
        "name": "system",
        "type": "address",
        "internalType": "address"
      }
    ]
  },
  {
    "type": "error",
    "name": "World_UnlimitedDelegationNotAllowed",
    "inputs": []
  }
]; export default abi;

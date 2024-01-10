// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

/* Autogenerated file. Do not edit manually. */

// Import schema type
import { SchemaType } from "@latticexyz/schema-type/src/solidity/SchemaType.sol";

// Import store internals
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";
import { StoreCore } from "@latticexyz/store/src/StoreCore.sol";
import { Bytes } from "@latticexyz/store/src/Bytes.sol";
import { Memory } from "@latticexyz/store/src/Memory.sol";
import { SliceLib } from "@latticexyz/store/src/Slice.sol";
import { EncodeArray } from "@latticexyz/store/src/tightcoder/EncodeArray.sol";
import { FieldLayout, FieldLayoutLib } from "@latticexyz/store/src/FieldLayout.sol";
import { Schema, SchemaLib } from "@latticexyz/store/src/Schema.sol";
import { PackedCounter, PackedCounterLib } from "@latticexyz/store/src/PackedCounter.sol";
import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";
import { RESOURCE_TABLE, RESOURCE_OFFCHAIN_TABLE } from "@latticexyz/store/src/storeResourceTypes.sol";

// Import user types
import { DirObjectType, DirectionType, MaterialType } from "./../common.sol";

ResourceId constant _tableId = ResourceId.wrap(
  bytes32(abi.encodePacked(RESOURCE_TABLE, bytes14("meat"), bytes16("DirObjectStore")))
);
ResourceId constant DirObjectStoreTableId = _tableId;

FieldLayout constant _fieldLayout = FieldLayout.wrap(
  0x0027050101010104200000000000000000000000000000000000000000000000
);

struct DirObjectStoreData {
  DirObjectType objType;
  DirectionType dirType;
  MaterialType matType;
  uint32 destId;
  bytes32 txtDefId;
  uint32[] objectActionIds;
}

library DirObjectStore {
  /**
   * @notice Get the table values' field layout.
   * @return _fieldLayout The field layout for the table.
   */
  function getFieldLayout() internal pure returns (FieldLayout) {
    return _fieldLayout;
  }

  /**
   * @notice Get the table's key schema.
   * @return _keySchema The key schema for the table.
   */
  function getKeySchema() internal pure returns (Schema) {
    SchemaType[] memory _keySchema = new SchemaType[](1);
    _keySchema[0] = SchemaType.UINT32;

    return SchemaLib.encode(_keySchema);
  }

  /**
   * @notice Get the table's value schema.
   * @return _valueSchema The value schema for the table.
   */
  function getValueSchema() internal pure returns (Schema) {
    SchemaType[] memory _valueSchema = new SchemaType[](6);
    _valueSchema[0] = SchemaType.UINT8;
    _valueSchema[1] = SchemaType.UINT8;
    _valueSchema[2] = SchemaType.UINT8;
    _valueSchema[3] = SchemaType.UINT32;
    _valueSchema[4] = SchemaType.BYTES32;
    _valueSchema[5] = SchemaType.UINT32_ARRAY;

    return SchemaLib.encode(_valueSchema);
  }

  /**
   * @notice Get the table's key field names.
   * @return keyNames An array of strings with the names of key fields.
   */
  function getKeyNames() internal pure returns (string[] memory keyNames) {
    keyNames = new string[](1);
    keyNames[0] = "dirObjId";
  }

  /**
   * @notice Get the table's value field names.
   * @return fieldNames An array of strings with the names of value fields.
   */
  function getFieldNames() internal pure returns (string[] memory fieldNames) {
    fieldNames = new string[](6);
    fieldNames[0] = "objType";
    fieldNames[1] = "dirType";
    fieldNames[2] = "matType";
    fieldNames[3] = "destId";
    fieldNames[4] = "txtDefId";
    fieldNames[5] = "objectActionIds";
  }

  /**
   * @notice Register the table with its config.
   */
  function register() internal {
    StoreSwitch.registerTable(_tableId, _fieldLayout, getKeySchema(), getValueSchema(), getKeyNames(), getFieldNames());
  }

  /**
   * @notice Register the table with its config.
   */
  function _register() internal {
    StoreCore.registerTable(_tableId, _fieldLayout, getKeySchema(), getValueSchema(), getKeyNames(), getFieldNames());
  }

  /**
   * @notice Get objType.
   */
  function getObjType(uint32 dirObjId) internal view returns (DirObjectType objType) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(dirObjId));

    bytes32 _blob = StoreSwitch.getStaticField(_tableId, _keyTuple, 0, _fieldLayout);
    return DirObjectType(uint8(bytes1(_blob)));
  }

  /**
   * @notice Get objType.
   */
  function _getObjType(uint32 dirObjId) internal view returns (DirObjectType objType) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(dirObjId));

    bytes32 _blob = StoreCore.getStaticField(_tableId, _keyTuple, 0, _fieldLayout);
    return DirObjectType(uint8(bytes1(_blob)));
  }

  /**
   * @notice Set objType.
   */
  function setObjType(uint32 dirObjId, DirObjectType objType) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(dirObjId));

    StoreSwitch.setStaticField(_tableId, _keyTuple, 0, abi.encodePacked(uint8(objType)), _fieldLayout);
  }

  /**
   * @notice Set objType.
   */
  function _setObjType(uint32 dirObjId, DirObjectType objType) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(dirObjId));

    StoreCore.setStaticField(_tableId, _keyTuple, 0, abi.encodePacked(uint8(objType)), _fieldLayout);
  }

  /**
   * @notice Get dirType.
   */
  function getDirType(uint32 dirObjId) internal view returns (DirectionType dirType) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(dirObjId));

    bytes32 _blob = StoreSwitch.getStaticField(_tableId, _keyTuple, 1, _fieldLayout);
    return DirectionType(uint8(bytes1(_blob)));
  }

  /**
   * @notice Get dirType.
   */
  function _getDirType(uint32 dirObjId) internal view returns (DirectionType dirType) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(dirObjId));

    bytes32 _blob = StoreCore.getStaticField(_tableId, _keyTuple, 1, _fieldLayout);
    return DirectionType(uint8(bytes1(_blob)));
  }

  /**
   * @notice Set dirType.
   */
  function setDirType(uint32 dirObjId, DirectionType dirType) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(dirObjId));

    StoreSwitch.setStaticField(_tableId, _keyTuple, 1, abi.encodePacked(uint8(dirType)), _fieldLayout);
  }

  /**
   * @notice Set dirType.
   */
  function _setDirType(uint32 dirObjId, DirectionType dirType) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(dirObjId));

    StoreCore.setStaticField(_tableId, _keyTuple, 1, abi.encodePacked(uint8(dirType)), _fieldLayout);
  }

  /**
   * @notice Get matType.
   */
  function getMatType(uint32 dirObjId) internal view returns (MaterialType matType) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(dirObjId));

    bytes32 _blob = StoreSwitch.getStaticField(_tableId, _keyTuple, 2, _fieldLayout);
    return MaterialType(uint8(bytes1(_blob)));
  }

  /**
   * @notice Get matType.
   */
  function _getMatType(uint32 dirObjId) internal view returns (MaterialType matType) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(dirObjId));

    bytes32 _blob = StoreCore.getStaticField(_tableId, _keyTuple, 2, _fieldLayout);
    return MaterialType(uint8(bytes1(_blob)));
  }

  /**
   * @notice Set matType.
   */
  function setMatType(uint32 dirObjId, MaterialType matType) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(dirObjId));

    StoreSwitch.setStaticField(_tableId, _keyTuple, 2, abi.encodePacked(uint8(matType)), _fieldLayout);
  }

  /**
   * @notice Set matType.
   */
  function _setMatType(uint32 dirObjId, MaterialType matType) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(dirObjId));

    StoreCore.setStaticField(_tableId, _keyTuple, 2, abi.encodePacked(uint8(matType)), _fieldLayout);
  }

  /**
   * @notice Get destId.
   */
  function getDestId(uint32 dirObjId) internal view returns (uint32 destId) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(dirObjId));

    bytes32 _blob = StoreSwitch.getStaticField(_tableId, _keyTuple, 3, _fieldLayout);
    return (uint32(bytes4(_blob)));
  }

  /**
   * @notice Get destId.
   */
  function _getDestId(uint32 dirObjId) internal view returns (uint32 destId) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(dirObjId));

    bytes32 _blob = StoreCore.getStaticField(_tableId, _keyTuple, 3, _fieldLayout);
    return (uint32(bytes4(_blob)));
  }

  /**
   * @notice Set destId.
   */
  function setDestId(uint32 dirObjId, uint32 destId) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(dirObjId));

    StoreSwitch.setStaticField(_tableId, _keyTuple, 3, abi.encodePacked((destId)), _fieldLayout);
  }

  /**
   * @notice Set destId.
   */
  function _setDestId(uint32 dirObjId, uint32 destId) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(dirObjId));

    StoreCore.setStaticField(_tableId, _keyTuple, 3, abi.encodePacked((destId)), _fieldLayout);
  }

  /**
   * @notice Get txtDefId.
   */
  function getTxtDefId(uint32 dirObjId) internal view returns (bytes32 txtDefId) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(dirObjId));

    bytes32 _blob = StoreSwitch.getStaticField(_tableId, _keyTuple, 4, _fieldLayout);
    return (bytes32(_blob));
  }

  /**
   * @notice Get txtDefId.
   */
  function _getTxtDefId(uint32 dirObjId) internal view returns (bytes32 txtDefId) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(dirObjId));

    bytes32 _blob = StoreCore.getStaticField(_tableId, _keyTuple, 4, _fieldLayout);
    return (bytes32(_blob));
  }

  /**
   * @notice Set txtDefId.
   */
  function setTxtDefId(uint32 dirObjId, bytes32 txtDefId) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(dirObjId));

    StoreSwitch.setStaticField(_tableId, _keyTuple, 4, abi.encodePacked((txtDefId)), _fieldLayout);
  }

  /**
   * @notice Set txtDefId.
   */
  function _setTxtDefId(uint32 dirObjId, bytes32 txtDefId) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(dirObjId));

    StoreCore.setStaticField(_tableId, _keyTuple, 4, abi.encodePacked((txtDefId)), _fieldLayout);
  }

  /**
   * @notice Get objectActionIds.
   */
  function getObjectActionIds(uint32 dirObjId) internal view returns (uint32[] memory objectActionIds) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(dirObjId));

    bytes memory _blob = StoreSwitch.getDynamicField(_tableId, _keyTuple, 0);
    return (SliceLib.getSubslice(_blob, 0, _blob.length).decodeArray_uint32());
  }

  /**
   * @notice Get objectActionIds.
   */
  function _getObjectActionIds(uint32 dirObjId) internal view returns (uint32[] memory objectActionIds) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(dirObjId));

    bytes memory _blob = StoreCore.getDynamicField(_tableId, _keyTuple, 0);
    return (SliceLib.getSubslice(_blob, 0, _blob.length).decodeArray_uint32());
  }

  /**
   * @notice Set objectActionIds.
   */
  function setObjectActionIds(uint32 dirObjId, uint32[] memory objectActionIds) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(dirObjId));

    StoreSwitch.setDynamicField(_tableId, _keyTuple, 0, EncodeArray.encode((objectActionIds)));
  }

  /**
   * @notice Set objectActionIds.
   */
  function _setObjectActionIds(uint32 dirObjId, uint32[] memory objectActionIds) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(dirObjId));

    StoreCore.setDynamicField(_tableId, _keyTuple, 0, EncodeArray.encode((objectActionIds)));
  }

  /**
   * @notice Get the length of objectActionIds.
   */
  function lengthObjectActionIds(uint32 dirObjId) internal view returns (uint256) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(dirObjId));

    uint256 _byteLength = StoreSwitch.getDynamicFieldLength(_tableId, _keyTuple, 0);
    unchecked {
      return _byteLength / 4;
    }
  }

  /**
   * @notice Get the length of objectActionIds.
   */
  function _lengthObjectActionIds(uint32 dirObjId) internal view returns (uint256) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(dirObjId));

    uint256 _byteLength = StoreCore.getDynamicFieldLength(_tableId, _keyTuple, 0);
    unchecked {
      return _byteLength / 4;
    }
  }

  /**
   * @notice Get an item of objectActionIds.
   * @dev Reverts with Store_IndexOutOfBounds if `_index` is out of bounds for the array.
   */
  function getItemObjectActionIds(uint32 dirObjId, uint256 _index) internal view returns (uint32) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(dirObjId));

    unchecked {
      bytes memory _blob = StoreSwitch.getDynamicFieldSlice(_tableId, _keyTuple, 0, _index * 4, (_index + 1) * 4);
      return (uint32(bytes4(_blob)));
    }
  }

  /**
   * @notice Get an item of objectActionIds.
   * @dev Reverts with Store_IndexOutOfBounds if `_index` is out of bounds for the array.
   */
  function _getItemObjectActionIds(uint32 dirObjId, uint256 _index) internal view returns (uint32) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(dirObjId));

    unchecked {
      bytes memory _blob = StoreCore.getDynamicFieldSlice(_tableId, _keyTuple, 0, _index * 4, (_index + 1) * 4);
      return (uint32(bytes4(_blob)));
    }
  }

  /**
   * @notice Push an element to objectActionIds.
   */
  function pushObjectActionIds(uint32 dirObjId, uint32 _element) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(dirObjId));

    StoreSwitch.pushToDynamicField(_tableId, _keyTuple, 0, abi.encodePacked((_element)));
  }

  /**
   * @notice Push an element to objectActionIds.
   */
  function _pushObjectActionIds(uint32 dirObjId, uint32 _element) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(dirObjId));

    StoreCore.pushToDynamicField(_tableId, _keyTuple, 0, abi.encodePacked((_element)));
  }

  /**
   * @notice Pop an element from objectActionIds.
   */
  function popObjectActionIds(uint32 dirObjId) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(dirObjId));

    StoreSwitch.popFromDynamicField(_tableId, _keyTuple, 0, 4);
  }

  /**
   * @notice Pop an element from objectActionIds.
   */
  function _popObjectActionIds(uint32 dirObjId) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(dirObjId));

    StoreCore.popFromDynamicField(_tableId, _keyTuple, 0, 4);
  }

  /**
   * @notice Update an element of objectActionIds at `_index`.
   */
  function updateObjectActionIds(uint32 dirObjId, uint256 _index, uint32 _element) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(dirObjId));

    unchecked {
      bytes memory _encoded = abi.encodePacked((_element));
      StoreSwitch.spliceDynamicData(_tableId, _keyTuple, 0, uint40(_index * 4), uint40(_encoded.length), _encoded);
    }
  }

  /**
   * @notice Update an element of objectActionIds at `_index`.
   */
  function _updateObjectActionIds(uint32 dirObjId, uint256 _index, uint32 _element) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(dirObjId));

    unchecked {
      bytes memory _encoded = abi.encodePacked((_element));
      StoreCore.spliceDynamicData(_tableId, _keyTuple, 0, uint40(_index * 4), uint40(_encoded.length), _encoded);
    }
  }

  /**
   * @notice Get the full data.
   */
  function get(uint32 dirObjId) internal view returns (DirObjectStoreData memory _table) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(dirObjId));

    (bytes memory _staticData, PackedCounter _encodedLengths, bytes memory _dynamicData) = StoreSwitch.getRecord(
      _tableId,
      _keyTuple,
      _fieldLayout
    );
    return decode(_staticData, _encodedLengths, _dynamicData);
  }

  /**
   * @notice Get the full data.
   */
  function _get(uint32 dirObjId) internal view returns (DirObjectStoreData memory _table) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(dirObjId));

    (bytes memory _staticData, PackedCounter _encodedLengths, bytes memory _dynamicData) = StoreCore.getRecord(
      _tableId,
      _keyTuple,
      _fieldLayout
    );
    return decode(_staticData, _encodedLengths, _dynamicData);
  }

  /**
   * @notice Set the full data using individual values.
   */
  function set(
    uint32 dirObjId,
    DirObjectType objType,
    DirectionType dirType,
    MaterialType matType,
    uint32 destId,
    bytes32 txtDefId,
    uint32[] memory objectActionIds
  ) internal {
    bytes memory _staticData = encodeStatic(objType, dirType, matType, destId, txtDefId);

    PackedCounter _encodedLengths = encodeLengths(objectActionIds);
    bytes memory _dynamicData = encodeDynamic(objectActionIds);

    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(dirObjId));

    StoreSwitch.setRecord(_tableId, _keyTuple, _staticData, _encodedLengths, _dynamicData);
  }

  /**
   * @notice Set the full data using individual values.
   */
  function _set(
    uint32 dirObjId,
    DirObjectType objType,
    DirectionType dirType,
    MaterialType matType,
    uint32 destId,
    bytes32 txtDefId,
    uint32[] memory objectActionIds
  ) internal {
    bytes memory _staticData = encodeStatic(objType, dirType, matType, destId, txtDefId);

    PackedCounter _encodedLengths = encodeLengths(objectActionIds);
    bytes memory _dynamicData = encodeDynamic(objectActionIds);

    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(dirObjId));

    StoreCore.setRecord(_tableId, _keyTuple, _staticData, _encodedLengths, _dynamicData, _fieldLayout);
  }

  /**
   * @notice Set the full data using the data struct.
   */
  function set(uint32 dirObjId, DirObjectStoreData memory _table) internal {
    bytes memory _staticData = encodeStatic(
      _table.objType,
      _table.dirType,
      _table.matType,
      _table.destId,
      _table.txtDefId
    );

    PackedCounter _encodedLengths = encodeLengths(_table.objectActionIds);
    bytes memory _dynamicData = encodeDynamic(_table.objectActionIds);

    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(dirObjId));

    StoreSwitch.setRecord(_tableId, _keyTuple, _staticData, _encodedLengths, _dynamicData);
  }

  /**
   * @notice Set the full data using the data struct.
   */
  function _set(uint32 dirObjId, DirObjectStoreData memory _table) internal {
    bytes memory _staticData = encodeStatic(
      _table.objType,
      _table.dirType,
      _table.matType,
      _table.destId,
      _table.txtDefId
    );

    PackedCounter _encodedLengths = encodeLengths(_table.objectActionIds);
    bytes memory _dynamicData = encodeDynamic(_table.objectActionIds);

    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(dirObjId));

    StoreCore.setRecord(_tableId, _keyTuple, _staticData, _encodedLengths, _dynamicData, _fieldLayout);
  }

  /**
   * @notice Decode the tightly packed blob of static data using this table's field layout.
   */
  function decodeStatic(
    bytes memory _blob
  )
    internal
    pure
    returns (DirObjectType objType, DirectionType dirType, MaterialType matType, uint32 destId, bytes32 txtDefId)
  {
    objType = DirObjectType(uint8(Bytes.slice1(_blob, 0)));

    dirType = DirectionType(uint8(Bytes.slice1(_blob, 1)));

    matType = MaterialType(uint8(Bytes.slice1(_blob, 2)));

    destId = (uint32(Bytes.slice4(_blob, 3)));

    txtDefId = (Bytes.slice32(_blob, 7));
  }

  /**
   * @notice Decode the tightly packed blob of dynamic data using the encoded lengths.
   */
  function decodeDynamic(
    PackedCounter _encodedLengths,
    bytes memory _blob
  ) internal pure returns (uint32[] memory objectActionIds) {
    uint256 _start;
    uint256 _end;
    unchecked {
      _end = _encodedLengths.atIndex(0);
    }
    objectActionIds = (SliceLib.getSubslice(_blob, _start, _end).decodeArray_uint32());
  }

  /**
   * @notice Decode the tightly packed blobs using this table's field layout.
   * @param _staticData Tightly packed static fields.
   * @param _encodedLengths Encoded lengths of dynamic fields.
   * @param _dynamicData Tightly packed dynamic fields.
   */
  function decode(
    bytes memory _staticData,
    PackedCounter _encodedLengths,
    bytes memory _dynamicData
  ) internal pure returns (DirObjectStoreData memory _table) {
    (_table.objType, _table.dirType, _table.matType, _table.destId, _table.txtDefId) = decodeStatic(_staticData);

    (_table.objectActionIds) = decodeDynamic(_encodedLengths, _dynamicData);
  }

  /**
   * @notice Delete all data for given keys.
   */
  function deleteRecord(uint32 dirObjId) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(dirObjId));

    StoreSwitch.deleteRecord(_tableId, _keyTuple);
  }

  /**
   * @notice Delete all data for given keys.
   */
  function _deleteRecord(uint32 dirObjId) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(dirObjId));

    StoreCore.deleteRecord(_tableId, _keyTuple, _fieldLayout);
  }

  /**
   * @notice Tightly pack static (fixed length) data using this table's schema.
   * @return The static data, encoded into a sequence of bytes.
   */
  function encodeStatic(
    DirObjectType objType,
    DirectionType dirType,
    MaterialType matType,
    uint32 destId,
    bytes32 txtDefId
  ) internal pure returns (bytes memory) {
    return abi.encodePacked(objType, dirType, matType, destId, txtDefId);
  }

  /**
   * @notice Tightly pack dynamic data lengths using this table's schema.
   * @return _encodedLengths The lengths of the dynamic fields (packed into a single bytes32 value).
   */
  function encodeLengths(uint32[] memory objectActionIds) internal pure returns (PackedCounter _encodedLengths) {
    // Lengths are effectively checked during copy by 2**40 bytes exceeding gas limits
    unchecked {
      _encodedLengths = PackedCounterLib.pack(objectActionIds.length * 4);
    }
  }

  /**
   * @notice Tightly pack dynamic (variable length) data using this table's schema.
   * @return The dynamic data, encoded into a sequence of bytes.
   */
  function encodeDynamic(uint32[] memory objectActionIds) internal pure returns (bytes memory) {
    return abi.encodePacked(EncodeArray.encode((objectActionIds)));
  }

  /**
   * @notice Encode all of a record's fields.
   * @return The static (fixed length) data, encoded into a sequence of bytes.
   * @return The lengths of the dynamic fields (packed into a single bytes32 value).
   * @return The dyanmic (variable length) data, encoded into a sequence of bytes.
   */
  function encode(
    DirObjectType objType,
    DirectionType dirType,
    MaterialType matType,
    uint32 destId,
    bytes32 txtDefId,
    uint32[] memory objectActionIds
  ) internal pure returns (bytes memory, PackedCounter, bytes memory) {
    bytes memory _staticData = encodeStatic(objType, dirType, matType, destId, txtDefId);

    PackedCounter _encodedLengths = encodeLengths(objectActionIds);
    bytes memory _dynamicData = encodeDynamic(objectActionIds);

    return (_staticData, _encodedLengths, _dynamicData);
  }

  /**
   * @notice Encode keys as a bytes32 array using this table's field layout.
   */
  function encodeKeyTuple(uint32 dirObjId) internal pure returns (bytes32[] memory) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(dirObjId));

    return _keyTuple;
  }
}

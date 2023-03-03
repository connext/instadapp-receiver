// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

struct CastData {
  string[] _targetNames;
  bytes[] _datas;
  address _origin;
}

struct EIP712Domain {
  string name;
  string version;
  uint256 chainId;
  address verifyingContract;
}

interface IDSA {
  function cast(
    string[] calldata _targetNames,
    bytes[] calldata _datas,
    address _origin
  ) external payable returns (bytes32);
}

interface IMetaTxAuthority {
  function verify(
    CastData memory castData,
    address sender,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external view returns (bool);

  function cast(
    CastData memory castData, 
    address sender,
    address dsa,
    uint8 v, 
    bytes32 r, 
    bytes32 s
  ) external payable;
}

contract MetaTxAuthority {
  bytes32 public DOMAIN_SEPARATOR;

  constructor() {
    DOMAIN_SEPARATOR = hashEIP712Domain(EIP712Domain({
      name: "MetaTxAuthority",
      version: "1",
      chainId: block.chainid,
      verifyingContract: address(this)
    }));
  }

  function hashEIP712Domain(EIP712Domain memory eip712Domain) internal pure returns (bytes32) {
    return keccak256(abi.encode(
      keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
      keccak256(bytes(eip712Domain.name)),
      keccak256(bytes(eip712Domain.version)),
      eip712Domain.chainId,
      eip712Domain.verifyingContract
    ));
  }

  function hashCastData(CastData memory castData) private pure returns (bytes32) {
    return keccak256(abi.encode(
        keccak256("Cast(string[] _targetNames,bytes[] _datas,address _origin)"),
        castData._targetNames,
        castData._datas,
        castData._origin
    ));
  }

  function verify(
    CastData memory castData,
    address sender,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) public view returns (bool) {
    bytes32 digest = keccak256(abi.encodePacked(
      "\x19\x01",
      DOMAIN_SEPARATOR,
      hashCastData(castData)
    ));
    return ecrecover(digest, v, r, s) == sender;
  }

  function cast(
    CastData memory castData, 
    address sender,
    address dsa,
    uint8 v, 
    bytes32 r, 
    bytes32 s
  ) public payable {
    require(verify(castData, sender, v, r, s), "Invalid signature");

    // send funds to DSA

    IDSA(dsa).cast{value: msg.value}(castData._targetNames, castData._datas, castData._origin);
  }
}

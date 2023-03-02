// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface IMetaTxAuthority {
  function verifyAndCast(
    bytes32 _transferId,
    uint256 _amount,
    address _asset,
    address _originSender,
    uint32 _origin,
    bytes memory _callData
  ) external returns (bytes memory);
}

contract MetaTxAuthority {
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
}

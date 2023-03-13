//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IConnext } from "@connext/interfaces/core/IConnext.sol";
import { IXReceiver } from "@connext/interfaces/core/IXReceiver.sol";

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

interface IInstadappTargetAuth {
  function verify(
    CastData memory castData,
    address sender,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external view returns (bool);

  function authCast(
    CastData memory castData,
    address sender,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external payable;
}

contract InstadappXReceiver is IXReceiver {
  // Whitelist addresses allowed to call xReceive
  // function whitelistAddress()

  // The Connext contract on this domain
  IConnext public connext;

  // The MetaTxAuthority contract on this domain
  IInstadappTargetAuth public targetAuth;

  bytes32 public DOMAIN_SEPARATOR;
  // The Connext contract on this domain
  IDSA public dsa;

  modifier onlyConnext() {
    require(msg.sender == address(connext), "Caller must be Connext");
    _;
  }

  constructor(
    address _connext //   address _dsa
  ) {
    connext = IConnext(_connext);
    // dsa = IDSA(_dsa);

    DOMAIN_SEPARATOR = hashEIP712Domain(
      EIP712Domain({
        name: "InstadappTargetAuth",
        version: "1",
        chainId: block.chainid,
        verifyingContract: address(this)
      })
    );
  }

  function hashEIP712Domain(EIP712Domain memory eip712Domain) internal pure returns (bytes32) {
    return
      keccak256(
        abi.encode(
          keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
          keccak256(bytes(eip712Domain.name)),
          keccak256(bytes(eip712Domain.version)),
          eip712Domain.chainId,
          eip712Domain.verifyingContract
        )
      );
  }

  function hashCastData(CastData memory castData) private pure returns (bytes32) {
    return
      keccak256(
        abi.encode(
          keccak256("Cast(string[] _targetNames,bytes[] _datas,address _origin)"),
          castData._targetNames,
          castData._datas,
          castData._origin
        )
      );
  }

  function verify(
    CastData memory castData,
    address sender,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) public view returns (bool) {
    bytes32 digest = keccak256(abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, hashCastData(castData)));
    return ecrecover(digest, v, r, s) == sender;
  }

  function authCast(
    CastData memory castData,
    address sender,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) public payable {
    require(verify(castData, sender, v, r, s), "Invalid signature");

    // send funds to DSA
    dsa.cast{ value: msg.value }(castData._targetNames, castData._datas, castData._origin);
  }

  function xReceive(
    bytes32 _transferId,
    uint256 _amount, // must be amount in bridge asset less fees
    address _asset,
    address _originSender,
    uint32 _origin,
    bytes memory _callData
  ) external onlyConnext returns (bytes memory) {
    // Decode signed calldata
    (CastData memory _castData, address sender, uint8 v, bytes32 r, bytes32 s) = abi.decode(
      _callData,
      (CastData, address, uint8, bytes32, bytes32)
    );

    authCast(_castData, sender, v, r, s);
  }
}

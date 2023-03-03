//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IConnext } from "@connext/interfaces/core/IConnext.sol";
import { IXReceiver } from "@connext/interfaces/core/IXReceiver.sol";
import { IMetaTxAuthority } from "./MetaTxAuthority.sol";

struct CastData {
    string[] _targetNames;
    bytes[] _datas;
    address _origin;
}

contract InstadappTargetV1 is IXReceiver {
  // Whitelist addresses allowed to call xReceive
  // function whitelistAddress()

  // The Connext contract on this domain
  IConnext public connext;

  // The MetaTxAuthority contract on this domain
  IMetaTxAuthority public metaTxAuth;

  modifier onlyConnext() {
    require(
      msg.sender == address(connext),
      "Caller must be Connext"
    );
    _;
  }

  constructor(address _connext, address _metaTxAuth) {
    connext = IConnext(_connext);
    metaTxAuth = IMetaTxAuthority(_metaTxAuth);
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
    (
      CastData[] memory _castData
    ) = abi.decode(_callData, (CastData[]));

    // metaTxAuth.cast(...);
  }
}

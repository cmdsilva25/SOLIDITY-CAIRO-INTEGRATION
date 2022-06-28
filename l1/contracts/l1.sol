//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.10;
import {IStarknetMessaging} from "./interfaces/IStarknetMessaging.sol";
import {Errors} from "./libraries/helpers/Errors.sol";
import {IStarknetMessaging} from "./interfaces/IStarknetMessaging.sol";
import "./libraries/helpers/Cairo.sol";


contract l1 {
  uint256 private value;
  IStarknetMessaging public messagingContract = IStarknetMessaging(0xde29d060D45901Fb19ED6C6e959EB22d8626708e);
  uint256 public bridge;
  uint256 constant DEPOSIT_HANDLER = 1285101517810983806491589552491143496277809242732141897358598292095611420389; // The selector of the "handle_deposit" l1_handler on L2.
  constructor() {
      value=10;
  }
  function get() external view returns (uint256) {
      return value;
  }
  function set(uint256 _value) external {
      value = _value;
      _sendL2( _value );      
  }
  function _sendL2(uint256 _value ) internal {
      uint256[] memory payload = new uint256[](2);
      (payload[0], payload[1]) = Cairo.toSplitUint( _value );
      messagingContract.sendMessageToL2( bridge, DEPOSIT_HANDLER, payload );
  }
  function setBridge(uint256 _bridge) external {
      bridge = _bridge;
  }
}

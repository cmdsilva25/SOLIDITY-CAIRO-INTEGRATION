//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.10;
import {IStarknetMessaging} from "./interfaces/IStarknetMessaging.sol";
import {Errors} from "./libraries/helpers/Errors.sol";
import {IStarknetMessaging} from "./interfaces/IStarknetMessaging.sol";
import "./libraries/helpers/Cairo.sol";


contract l1 {
  IStarknetMessaging public messagingContract = IStarknetMessaging(0xde29d060D45901Fb19ED6C6e959EB22d8626708e);
  uint256 private value;
  uint256 private bridge = 0;
  uint256 private l1Handler = 854786134140017148399561816726568892307207570892433063785923233729965809848;
  
  constructor() {
      value=10;
  }

  function get_var() external view returns (uint256) {
      return value;
  }

  function set_var(uint256 _value) external {
      value = _value;
  }
  
  function _consumeMessageFromL2() external {
        uint256[] memory payload = new uint256[](2);
        (payload[0], payload[1]) = Cairo.toSplitUint( value );
        messagingContract.consumeMessageFromL2( bridge, payload );
        value = payload[0] + payload[1]<<128;
    }

  function _sendMessageToL2() external {
      uint256[] memory payload = new uint256[](2);
      (payload[0], payload[1]) = Cairo.toSplitUint( value );
      messagingContract.sendMessageToL2( bridge, l1Handler, payload );
      value = payload[0] + payload[1]<<128;
  }

  function setL1Handler( uint256 _l1Handler ) external {
      l1Handler = _l1Handler;
  }
  
  function getL1Handler( ) external view returns ( uint256 ) {
      return l1Handler;
  }

  function setBridge(uint256 _bridge) external {
      bridge = _bridge;
  }

  function getBridge() external view returns (uint256) {
    return bridge;
  }
}

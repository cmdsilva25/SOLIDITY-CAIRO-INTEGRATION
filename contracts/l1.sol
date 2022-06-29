//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.10;
import {IStarknetMessaging} from "./interfaces/IStarknetMessaging.sol";
import {Errors} from "./libraries/helpers/Errors.sol";
import {IStarknetMessaging} from "./interfaces/IStarknetMessaging.sol";
import "./libraries/helpers/Cairo.sol";


contract l1 {
  uint256 private value;
  IStarknetMessaging public messagingContract = IStarknetMessaging(0xde29d060D45901Fb19ED6C6e959EB22d8626708e);
  uint256 public bridge = 0;
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
  

/*
  function _consumeMessage() internal {
        uint256[] memory payload = new uint256[](8);
        (payload[0], payload[1]) = Cairo.toSplitUint(amount);
        // Consume the message from the StarkNet core contract.
        // This will revert the (Ethereum) transaction if the message does not exist.
        _messagingContract.consumeMessageFromL2( bridge, payload );
    }
*/

  function _sendL2( uint256 _value ) internal {
      uint256[] memory payload = new uint256[](2);
      (payload[0], payload[1]) = Cairo.toSplitUint( _value );
      messagingContract.sendMessageToL2( bridge, DEPOSIT_HANDLER, payload );
  }

  function setBridge(uint256 _bridge) external {
      bridge = _bridge;
  }

  function getBridge() external view returns (uint256) {
    return bridge;
  }

}



// SPDX-License-Identifier: Apache-2.0.
pragma solidity ^0.6.12;

interface IStarknetCore {
    /**
      Sends a message to an L2 contract.

      Returns the hash of the message.
    */
    function sendMessageToL2(
        uint256 toAddress,
        uint256 selector,
        uint256[] calldata payload
    ) external returns (bytes32);

    /**
      Consumes a message that was sent from an L2 contract.

      Returns the hash of the message.
    */
    function consumeMessageFromL2(uint256 fromAddress, uint256[] calldata payload)
        external
        returns (bytes32);
}

/**
  Demo contract for L1 <-> L2 interaction between an L2 StarkNet contract and this L1 solidity
  contract.
*/
contract L1L2Example {
    // The StarkNet core contract.
    IStarknetCore starknetCore;

    mapping(uint256 => uint256) public userBalances;

    uint256 constant MESSAGE_WITHDRAW = 0;

    // The selector of the "deposit" l1_handler.
    uint256 constant DEPOSIT_SELECTOR =
        352040181584456735608515580760888541466059565068553383579463728554843487745;

    /**
      Initializes the contract state.
    */
    constructor(IStarknetCore starknetCore_) public {
        starknetCore = starknetCore_;
    }

    function withdraw(
        uint256 l2ContractAddress,
        uint256 user,
        uint256 amount
    ) external {
        // Construct the withdrawal message's payload.
        uint256[] memory payload = new uint256[](3);
        payload[0] = MESSAGE_WITHDRAW;
        payload[1] = user;
        payload[2] = amount;

        // Consume the message from the StarkNet core contract.
        // This will revert the (Ethereum) transaction if the message does not exist.
        starknetCore.consumeMessageFromL2(l2ContractAddress, payload);

        // Update the L1 balance.
        userBalances[user] += amount;
    }

    function deposit(
        uint256 l2ContractAddress,
        uint256 user,
        uint256 amount
    ) external {
        require(amount < 2**64, "Invalid amount.");
        require(amount <= userBalances[user], "The user's balance is not large enough.");

        // Update the L1 balance.
        userBalances[user] -= amount;

        // Construct the deposit message's payload.
        uint256[] memory payload = new uint256[](2);
        payload[0] = user;
        payload[1] = amount;

        // Send the message to the StarkNet core contract.
        starknetCore.sendMessageToL2(l2ContractAddress, DEPOSIT_SELECTOR, payload);
    }
}

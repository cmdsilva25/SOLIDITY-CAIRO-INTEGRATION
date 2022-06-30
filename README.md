# Cairo Solidity Integration Example

## Install Dependencies
```shell=
npm i
```

## Set `.env` file
```shell=
mv .env.sample .env
```
In `.env` file:

```shell=
API_URL = "https://eth-goerli.alchemyapi.io/v2/your-api-key"
PRIVATE_KEY = "your-metamask-private-key"
CONTRACT_ADDRESS = "put here the address where your contract was deployed... only known after deployment"
```

## L1 Setup

### Compile L1 contracts
```shell=
npx hardhat compile
```

### Deploy your contract on Goerli test net
```shell=
npx hardhat run scripts/deploy.js --network goerli
```

### Update `.env` file with the contract address
```shell=
Contract deployed to address: 0xCAFBf889bef0617d9209Cf96f18c850e901A6D61
```

### Interact with your L1 smart contract
```shell=
npx hardhat run scripts/interact.js
```

If you need more help, plese refer to [https://www.web3.university/tracks/create-a-smart-contract](https://www.web3.university/tracks/create-a-smart-contract).

## L2 Setup

### Compile L2
```shell
cd cairo-contracts
export STARKNET_NETWORK=alpha-goerli
starknet-compile l2.cairo --output l2_compiled.json --abi l2_abi.json
```

### Creating and Deploying Account
```shell=
export STARKNET_WALLET=starkware.starknet.wallets.open_zeppelin.OpenZeppelinAccount
starknet deploy_account
```

### Deploy L2 Contract on testnet alpha-goerli

```shell
starknet deploy --contract l2_compiled.json
export CONTRACT_ADDRESS= <contract address>
```

### Interacting with L2 contract
```shell
starknet invoke --address ${CONTRACT_ADDRESS} --abi l2_abi.json --function <setter function> --inputs <input separated by space>
starknet call   --address ${CONTRACT_ADDRESS} --abi l2_abi.json --function <getter function> --inputs <input separated by space>
starknet tx_status --hash <hash of the transaction>
```


### Help

```javascript
pragma solidity ^0.6.12;

interface IStarknetCore {
    function sendMessageToL2(
        uint256 toAddress,
        uint256 selector,
        uint256[] calldata payload
    ) external returns (bytes32);

    function consumeMessageFromL2(uint256 fromAddress, uint256[] calldata payload)
        external
        returns (bytes32);
}

contract L1L2Example {
    // The StarkNet core contract.
    IStarknetCore starknetCore;

    mapping(uint256 => uint256) public userBalances;

    uint256 constant MESSAGE_WITHDRAW = 0;

    // The selector of the "deposit" l1_handler.
    uint256 constant DEPOSIT_SELECTOR =
        352040181584456735608515580760888541466059565068553383579463728554843487745;

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
```

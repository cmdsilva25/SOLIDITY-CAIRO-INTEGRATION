const API_KEY = process.env.API_KEY;
const PRIVATE_KEY = process.env.PRIVATE_KEY;
const CONTRACT_ADDRESS = process.env.CONTRACT_ADDRESS;

const contract = require("../artifacts/contracts/l1.sol/l1.json");

// Provider
const alchemyProvider = new ethers.providers.AlchemyProvider(network="goerli", API_KEY);

// Signer
const signer = new ethers.Wallet(PRIVATE_KEY, alchemyProvider);

// Contract
const l1 = new ethers.Contract(CONTRACT_ADDRESS, contract.abi, signer);

async function main() {
    const tx = await l1.set(11);
    await tx.wait();

    const message = await l1.get();
    console.log("get is: " + message);

    //const tx = await l1.setBridge("0x05bebe2c625f3906db9ef96f72ee88fd9162256d6a61950af2138cf403715dc9");
    //await tx.wait();
    
    //let m = await l1.getBridge();
    //console.log("Bridge Address is: " + m);
  }
  main();


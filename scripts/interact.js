const API_KEY = process.env.API_KEY;
const PRIVATE_KEY = process.env.PRIVATE_KEY;
const L1_CONTRACT_ADDRESS = process.env.L1_CONTRACT_ADDRESS;

const contract = require("../artifacts/contracts/l1.sol/l1.json");

// Provider
const alchemyProvider = new ethers.providers.AlchemyProvider(network="goerli", API_KEY);

// Signer
const signer = new ethers.Wallet(PRIVATE_KEY, alchemyProvider);

// Contract
const l1 = new ethers.Contract(L1_CONTRACT_ADDRESS, contract.abi, signer);

async function main() {
  /*
  console.log('API_KEY: ' + API_KEY);
  console.log('PRIVATE_KEY: ' + PRIVATE_KEY);
  console.log('L1_CONTRACT_ADDRESS: ' + L1_CONTRACT_ADDRESS);
  */

  /*
  console.log("setting var");
  const tx = await l1.set_var(10);
  await tx.wait();
 
  console.log("getting var");
  const message = await l1.get_var();
  console.log("get_var: " + message);
 */
 
 
  /*
  const tx = await l1.setBridge("0x0465a97e426f269fab708677a8f59e80d3096e48d7a6ff4d6ffaa115cbe28a77");
  await tx.wait();
    
  let m = await l1.getBridge();
  console.log("Bridge Address is: " + m);
  */

  const tx = await l1._consumeMessageFromL2()
  await tx.wait();

  console.log("getting var");
  const message = await l1.get_var();
  console.log("get_var: " + message);
 
  /*
  const tx = await l1._sendMessageToL2();
  await tx.wait();
  */

  }
  main();


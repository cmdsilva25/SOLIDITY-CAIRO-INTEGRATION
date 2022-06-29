async function main() {
    const l1_factory = await ethers.getContractFactory("l1");
 
    // Start deployment, returning a promise that resolves to a contract object
    const l1 = await l1_factory.deploy();
    console.log("Contract deployed to address:", l1.address);
 }
 
 main()
   .then(() => process.exit(0))
   .catch(error => {
     console.error(error);
     process.exit(1);
   });
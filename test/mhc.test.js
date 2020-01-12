const MinimalHybridContract = artifacts.require("MinimalHybridContract")

contract("KryptoSedler", (accounts) => { 

    let mhc;
    let contract_id;

    it("Get contract", async () => { 
        mhc = await MinimalHybridContract.deployed()
    })


    it("Create binding contract", async () => { 
        let contract_tx = await mhc.create_contract(accounts[0], accounts[1], "HASHDASDASDSSAD", "SHA256");
        //console.log(contract_tx)
        contract_id = contract_tx.logs[0]["args"].contract_id;
        //console.log("Contract id:", contract_id)
    })

    it("Send money and make reference to contract", async () => { 
        let transfer_tx = await web3.eth.sendTransaction({from: accounts[1], to: accounts[0], gas: 210000, value: 10000})

        // Make for loop for each transaction
        console.log(transfer_tx["transactionHash"])
        let contract_transfer_tx = await mhc.contract_transfer(contract_id, transfer_tx["transactionHash"])
        console.log(contract_transfer_tx)
    })


})
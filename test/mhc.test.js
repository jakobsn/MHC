const MinimalHybridContract = artifacts.require("MinimalHybridContract")

contract("MinimalHybridContract", (accounts) => { 

    let mhc;
    let contract_id;
    let transfer_tx;

    it("Get the deployed smart contract", async () => { 
        mhc = await MinimalHybridContract.deployed()
    })

    it("Store legal contract representation", async () => { 
        let contract_tx = await mhc.create_contract(accounts[0], accounts[1], 
            "Contract Title", "d04b98f48e8f8bcc15c6ae5ac050801cd6dcfd428fb5f9e65c4e16e7807340fa", "SHA256");
        contract_id = contract_tx.logs[0]["args"].contract_id;
        console.log("Legal contract id:", contract_id.toString())
        expect(contract_id.toString()).to.equal('0')
    })

    it("Send transaction to be referenced to the contract", async () => { 
        transfer_tx = await web3.eth.sendTransaction({from: accounts[1], to: accounts[0], gas: 210000, value: 10000})
        console.log("Perform transaction:", transfer_tx["transactionHash"])
    })

    it("Reference the transaction to the contract", async () => { 
        let contract_transfer_tx = await mhc.contract_transfer(contract_id, transfer_tx["transactionHash"])
        let event_contract_id = contract_transfer_tx.logs[0]["args"].contract_id;
        console.log("Contract id linked to transaction hash")
        expect(event_contract_id.toString()).to.equal('0')        
    })

    it("Read contract ids", async () => { 
        let ids = await mhc.read_contract_ids(accounts[1])
        console.log("Contracts related to user:", ids.toString())
        expect(ids.toString()).to.equal('0')
    })

    it("Read contract transactions", async () => { 
        let transactions = await mhc.read_contract_transactions(contract_id)
        console.log("Transactions related to contract id:", contract_id.toString(), "-", transactions)
        expect(transactions[0]).to.equal(transfer_tx["transactionHash"])
    })

})
const MinimalHybridContract = artifacts.require("MinimumHybridContract")

contract("MinimumHybridContract", (accounts) => { 

	console.log(accounts[0])
    let mhc;
    let contract_id;
    let legal_contract_hash = "0x30755ed65396facf86c53e6217c52b4daebe72aa4941d89635409de4c9c7f9466d4e9aaec7977f05e923889b33c0d0dd27d7226b6e6f56ce737465c5cfd04be400"

    it("Get the deployed smart contract", async () => { 
        mhc = await MinimalHybridContract.deployed()
    })

    it("Store and sign legal contract representation", async () => {
        let contract_tx = await mhc.create_contract(accounts[1], accounts[0], 
            "Contract Title", legal_contract_hash, "SHA256", {from: accounts[0]});
        contract_id = contract_tx.logs[0]["args"].contract_id.toString();
        //console.log("New legal contract id:", contract_id)
        expect(contract_id.toString()).to.equal('0')
    })

    it("Read newly created legal contract representationm", async () => { 
        let contract_struct = await mhc.read_contract(contract_id)
        //console.log("Principal:", contract_struct.principal)
        //console.log("Agent:", contract_struct.agent)
        //console.log("Contract Hash:", contract_struct.contract_hash)
        //console.log("Contract Signed:", contract_struct.signed)
        expect(contract_struct.contract_hash).to.equal(legal_contract_hash)
        expect(!contract_struct.signed)
    })

    it("Should sign a contract", async () => {
        await mhc.create_contract_signature(contract_id, {from: accounts[1]})
        let contract_struct = await mhc.read_contract(contract_id)
        expect(contract_struct.signed)
    })

    it("Send transaction through the contract", async () => { 
        const transfer_value = 1
        // Gwei multiplier
        const multiplier = 1
        let contract_transfer_tx = await mhc.create_contract_transfer(contract_id, "0x30755ed65396facf86c53e6217c52b4daebe72aa4941d89635409de4c9c7f9466d4e9aaec7977f05e923889b33c0d0dd27d7226b6e6f56ce737465c5cfd04be400",
        transfer_value, multiplier, accounts[1], {from: accounts[0], value:transfer_value*multiplier})
        let contract_transfer_event = contract_transfer_tx.logs[0]["args"];
        //console.log("Transfered:", contract_transfer_event.value.toString(), "wei")
        //console.log("From:", contract_transfer_event.sender.toString())
        //console.log("To:", contract_transfer_event.receiver.toString())
        //console.log("On contract:", contract_id.toString())
        expect(contract_transfer_event.contract_id.toString()).to.equal(contract_id)
        expect(contract_transfer_event.sender.toString()).to.equal(accounts[0])
        expect(contract_transfer_event.receiver.toString()).to.equal(accounts[1])
        expect(contract_transfer_event.value.toString()).to.equal(String(transfer_value*multiplier))
    })

    it("Read contract ids", async () => { 
        let ids = await mhc.read_contract_ids(accounts[0])
        //console.log("Contract ids related to user:", ids.toString())
        expect(ids.toString()).to.equal('0')
    })

    it("Check if an address is actor in a contract", async () => { 
        let is_actor = await mhc.read_is_actor(contract_id, accounts[1])
        expect(is_actor).to.equal(true)
    })

    it("Should be able to unsign from a contract, and deactivate it upon agreement", async () => {
        await mhc.update_contract_unsign(contract_id, {from: accounts[0]})
        let contract_struct = await mhc.read_contract(contract_id)
        expect(!contract_struct.signed)
        await mhc.update_contract_unsign(contract_id, {from: accounts[1]})
        contract_struct = await mhc.read_contract(contract_id)
        expect(!contract_struct.signed)
    })

    it("Should be able to show contract events", async () => {
        let events = await mhc.getPastEvents("allEvents", 
        {
            fromBlock:0,
            toBlock: "latest"
        })
        console.log("Events:")
        console.log("")
        let transaction
        for(var i = 0; i < events.length; i++){
            console.log("Event: ", events[i].event)
            transaction = await web3.eth.getTransaction(events[i].transactionHash)
            console.log("Sender: ", transaction.from)
            console.log("")
        }
    })
}) 


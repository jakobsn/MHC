const MinimalHybridContract = artifacts.require("MinimalHybridContract")

contract("MinimalHybridContract", (accounts) => { 

    let mhc;
    let contract_id;
    let legal_contract_hash = "d04b98f48e8f8bcc15c6ae5ac050801cd6dcfd428fb5f9e65c4e16e7807340fa"

    it("Get the deployed smart contract", async () => { 
        mhc = await MinimalHybridContract.deployed()
    })

    it("Store legal contract representation", async () => { 
        let contract_tx = await mhc.create_contract(accounts[6], accounts[0], 
            "Contract Title", legal_contract_hash, "SHA256");
        contract_id = contract_tx.logs[0]["args"].contract_id.toString();
        //console.log("New legal contract id:", contract_id)
        expect(contract_id.toString()).to.equal('0')
    })

    it("Read newly created legal contract representationm", async () => { 
        let contract_struct = await mhc.read_contract(contract_id)
        //console.log("Principal:", contract_struct.principal)
        //console.log("Agent:", contract_struct.agent)
        //console.log("Contract Hash:", contract_struct.contract_hash)
        expect(contract_struct.contract_hash).to.equal(legal_contract_hash)
    })

    it("Send transaction through the contract", async () => { 
        const transfer_value = 1000000000000000
        const multiplier = 100
        let contract_transfer_tx = await mhc.create_contract_transfer(contract_id, transfer_value, 
            multiplier, accounts[4], {from: accounts[6], value:transfer_value*multiplier})
        let contract_transfer_event = contract_transfer_tx.logs[0]["args"];
        //console.log("Transfered:", contract_transfer_event.value.toString(), "wei")
        //console.log("From:", contract_transfer_event.sender.toString())
        //console.log("To:", contract_transfer_event.receiver.toString())
        //console.log("On contract:", contract_id.toString())
        expect(contract_transfer_event.contract_id.toString()).to.equal(contract_id)
        expect(contract_transfer_event.sender.toString()).to.equal(accounts[6])
        expect(contract_transfer_event.receiver.toString()).to.equal(accounts[4])
        expect(contract_transfer_event.value.toString()).to.equal(String(transfer_value*multiplier))
    })

    it("Read contract ids", async () => { 
        let ids = await mhc.read_contract_ids(accounts[6])
        //console.log("Contract ids related to user:", ids.toString())
        expect(ids.toString()).to.equal('0')
    })

    it("Check if an address is actor in a contract", async () => { 
        let is_actor = await mhc.read_is_actor(contract_id, accounts[6])
        expect(is_actor).to.equal(true)
    })
})

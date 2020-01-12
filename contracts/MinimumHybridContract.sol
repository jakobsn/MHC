pragma solidity ^0.5.0;


contract MinimalHybridContract {

    struct ContractStruct {
        address principal;
        address agent;
        string contract_hash;
        string contract_method;
    }

    event CreateContract (
        address principal,
        address agent,
        uint contract_id
    );

    // Keep all contracts in a list
    ContractStruct[] contracts;

    // Map actors to contracts
    mapping (address => uint[]) private contract_actor;
    // Map contract to transactions
    mapping (uint => string[]) private contract_transaction;

    constructor () public {
        return;
    }

    function create_contract(address principal, address agent, string calldata contract_hash, string calldata contract_method) external
        returns (uint contract_id) {
        // Create a contract struct and store it on chain
        ContractStruct memory contract_struct;
        contract_struct.principal = principal;
        contract_struct.agent = agent;
        contract_struct.contract_hash = contract_hash;
        contract_struct.contract_method = contract_method;

        // Push the contract to the contracts list
        contract_id = contracts.push(contract_struct);

        // Map the actors to the contract
        contract_actor[principal].push(contract_id);
        contract_actor[agent].push(contract_id);

        // Record metadata to the blockchain event log
        emit CreateContract(principal, agent, contract_id);
        return contract_id;
    }

    function contract_transfer(uint contract_id, string calldata transaction_hash) external {
        // TODO: Check if sender is actor in contract and transaction exists
        contract_transaction[contract_id].push(transaction_hash);
        return;
    }

    function read_contracts(address actor) external {
        // TODO
        return;
    }

    function read_contract_transactions(uint contract_id) external {
        // TODO
        return;
    }

}
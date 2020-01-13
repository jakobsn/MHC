pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

/**
 * @title Minimal Hybrid Contract
 * @dev Proof of concept implementation of the proposed MHC
 * @author Jakob Svennevik Notland
 */

contract MinimalHybridContract {

    // Smart contract representation of a legal contract
    struct ContractStruct {
        address principal;
        address agent;
        string title;
        string contract_hash;
        string contract_method;
    }

    // Log event for contract creation
    event CreateContract (
        address creator,
        uint contract_id
    );

    // Log event for contract transaction
    event ContractTransaction (
        uint contract_id,
        string transaction_hash
    );

    // Keep all contract representations in a list
    ContractStruct[] contracts;
    // Map actors to contracts
    mapping (address => uint[]) private contract_actor;
    // Map contract to transactions
    mapping (uint => string[]) private contract_transaction;

    /**
    * @dev Create a contract struct and store it on chain. Anyone can create a contract,
    * #TODO: further implementation should use multisignatures to ensure better security.
    * This would be done by making it possible to make a contract struct only when both
    * the principal and the agent signs for it.
    * @param principal address of the participating principal
    * @param agent address of the participating agent
    * @param title overhead title of the legal contract
    * @param contract_hash a hash generated from the legal contract
    * @param contract_method the hashing algorithm used to generate the contract_hash
    * @return {
    *   "contract_id": "The id of the published contract_strct"
    * }
    */
    function create_contract(address principal, address agent, string calldata title,
            string calldata contract_hash, string calldata contract_method) external
        returns (uint contract_id) {
        // Make a ContractStruct instance contract_struct
        ContractStruct memory contract_struct;
        contract_struct.principal = principal;
        contract_struct.agent = agent;
        contract_struct.title = title;
        contract_struct.contract_hash = contract_hash;
        contract_struct.contract_method = contract_method;
        // Push the contract_struct to the contracts list
        contract_id = contracts.push(contract_struct) - 1;
        // Map the actors to the contract_struct
        contract_actor[principal].push(contract_id);
        contract_actor[agent].push(contract_id);
        // Record the contract creator and the contract id to the blockchain event log
        emit CreateContract(msg.sender, contract_id);
        return contract_id;
    }

    /**
    * @dev Record a reference between transactions to their corresponding contract
    * #TODO: Further implementations should allow only the sender to record their transaction.
    * It should possible to record a transaction to no more than one contract id
    * @param contract_id the id of the relevant contract struct
    * @param transaction_hash the hash of a transaction related to the contract id
    */
    function contract_transfer(uint contract_id, string calldata transaction_hash) external {
        // Store the contract id and transaction reference
        contract_transaction[contract_id].push(transaction_hash);
        // Record the event of a contract transaction
        emit ContractTransaction(contract_id, transaction_hash);
    }

    /**
    * @dev Get the ids of the contracts related to an actor
    * @param actor address of the actor
    * @return {
    *   "uint[]": "contract_ids"
    * }
    */
    function read_contract_ids(address actor) external view
        returns(uint[] memory contract_ids) {
        return contract_actor[actor];
    }

    /**
    * @dev Get the transactions related to a contract
    * @param contract_id id of the contract
    * @return {
    *   "string[]": "transactions"
    * }
    */
    function read_contract_transactions(uint contract_id) external view
        returns(string[] memory transactions) {
        return contract_transaction[contract_id];
    }

}
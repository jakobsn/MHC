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
        address sender,
        address receiver,
        uint value
    );

    // Keep all contract representations in a list
    ContractStruct[] contracts;
    // Map actors to contracts
    mapping (address => uint[]) private contract_actor;

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
        require(msg.sender == principal || msg.sender == agent,
            "Revert, can not create contract for someone else");
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
    * @param contract_id the id of the relevant contract struct
    * @param value the value to send in wei
    * @param multiplier a number to multiply the value, used as a Workaround
    * @param receiver address of the receiving user
    */
    function create_contract_transfer(uint contract_id, uint value, uint multiplier,
        address payable receiver) external payable {
        // Store the contract id and transaction reference
        require(read_is_actor(contract_id, msg.sender) || read_is_actor(contract_id, receiver),
            "Revert, both sender and receiver are not actors in contract");
        // Send funds through the MHC smart contract
        address(receiver).transfer(value*multiplier);
        // Record the event of a contract transaction
        emit ContractTransaction(contract_id, msg.sender, receiver, value*multiplier);
    }

    /**
    * @dev Get attributes of a specific legal contract representation
    * @param contract_id the id of the relevant contract struct
    * @return {
    *   "address": "principal",
    *   "address": "agent",
    *   "string": "title" overhead title of the legal contract,
    *   "string": "contract_hash" hash generated from the legal contract,
    *   "string": "contract_method" the hashing algorithm used to generate the contract_hash
    * }
    */
    function read_contract(uint contract_id) public view
        returns (address principal, address agent, string memory title,
            string memory contract_hash, string memory contract_method) {
        ContractStruct memory contract_struct = contracts[contract_id];
        principal = contract_struct.principal;
        agent = contract_struct.agent;
        title = contract_struct.title;
        contract_hash = contract_struct.contract_hash;
        contract_method = contract_struct.contract_method;
    }

    /**
    * @dev Get the ids of the contracts related to an actor
    * @param actor address of the actor
    * @return {
    *   "uint[]": "contract_ids"
    * }
    */
    function read_contract_ids(address actor) public view
        returns(uint[] memory contract_ids) {
        return contract_actor[actor];
    }

    /**
    * @dev Get the ids of the contracts related to an actor
    * @param contract_id the id of the relevant contract struct
    * @param actor address of the actor
    * @return {
    *   "bool": "is_actor" true if actor is pricipal or agent in contract
    * }
    */
    function read_is_actor(uint contract_id, address actor) public view
        returns(bool is_actor){
        is_actor = false;
        uint[] memory contract_ids = read_contract_ids(actor);
        for(uint i = 0; i < contract_ids.length; i++){
            if(contract_ids[i] == contract_id){
                is_actor = true;
            }
        }
    }
}
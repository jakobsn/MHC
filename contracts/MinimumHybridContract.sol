pragma solidity ^0.5.0;

/**
 * @title Minimum Hybrid Contract
 * @dev Proof of concept implementation of the proposed MHC. Available at github: https://github.com/jakobsn/MHC
 * @author Jakob Svennevik Notland
 */


contract MinimumHybridContract {

    // Smart contract representation of a legal contract
    struct ContractStruct {
        address principal;
        address agent;
        string title;
        bytes contract_hash;
        string contract_method;
        bool signed;
    }

    // Log event for contract creation
    event CreateContract (
        uint contract_id
    );

    // Log event for signing a contract
    event SignContract (
        uint contract_id
    );

    // Log event when both parties have signed a contract
    event ActivateContract (
        uint contract_id
    );

    // Log event for unsigning a contract
    event UnSignContract (
        uint contract_id
    );

    // Log event when both parties have unsigned a contract
    event DeActivateContract (
        uint contract_id
    );

    // Log event for contract transaction
    event ContractTransaction (
        uint contract_id,
        address sender,
        address receiver,
        uint value,
        bytes invoice_hash
    );

    // Keep all contract representations in a list
    ContractStruct[] private contracts;
    // Map actors to contracts
    mapping (address => uint[]) private contract_actor;
    // Map contract to participants and their signing status
    mapping (uint => mapping (address => bool)) contract_actor_signed;

    /**
    * @dev Create a contract struct and store it on chain.
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
        bytes calldata contract_hash, string calldata contract_method) external
        returns (uint contract_id) {
        require(msg.sender == principal || msg.sender == agent,
            "Revert, only contract participants can create a contract");
        // Make a ContractStruct instance contract_struct
        ContractStruct memory contract_struct;
        contract_struct.principal = principal;
        contract_struct.agent = agent;
        contract_struct.title = title;
        contract_struct.contract_hash = contract_hash;
        contract_struct.contract_method = contract_method;
        contract_struct.signed = false;
        // Push the contract_struct to the contracts list
        contract_id = contracts.push(contract_struct) - 1;
        // Map the actors to the contract_struct
        contract_actor[principal].push(contract_id);
        contract_actor[agent].push(contract_id);
        // Record the the contract id to the blockchain event log
        emit CreateContract(contract_id);
        // Sign the contract
        contract_actor_signed[contract_id][msg.sender] = true;
        emit SignContract(contract_id);
        return contract_id;
    }

    /**
    * @dev Sign a contract. If both parties have signed, the contract activates
    * @param contract_id the id of the relevant contract struct
     */
    function create_contract_signature(uint contract_id) external {
        require(msg.sender == contracts[contract_id].agent || msg.sender == contracts[contract_id].principal,
            "Revert, only contract actors can sign a contract");
        // Record the actors signature
        contract_actor_signed[contract_id][msg.sender] = true;
        emit SignContract(contract_id);
        if (contract_actor_signed[contract_id][contracts[contract_id].principal] &&
            contract_actor_signed[contract_id][contracts[contract_id].agent]){
            // Record activation of the contract if both parties have signed
            contracts[contract_id].signed = true;
            emit ActivateContract(contract_id);
        }
    }

    /**
    * @dev Record a reference between transactions to their corresponding contract
    * @param contract_id the id of the relevant contract struct
    * @param value the value to send in wei
    * @param multiplier a number to multiply the value, used as a Workaround
    * @param receiver address of the receiving user
     */
    function create_contract_transfer(uint contract_id, bytes calldata invoice_hash, uint value, uint multiplier,
        address payable receiver) external payable {
        // Store the contract id and transaction reference
        require(read_is_actor(contract_id, msg.sender) || read_is_actor(contract_id, receiver),
            "Revert, both sender and receiver are not actors in contract");
        // Send funds through the MHC smart contract
        address(receiver).transfer(value*multiplier);
        // Record the event of a contract transaction
        emit ContractTransaction(contract_id, msg.sender, receiver, value*multiplier, invoice_hash);
    }

    /**
    * @dev Unsign a contract. If both parties have unsigned, the contract deactivates
    * @param contract_id the id of the relevant contract struct
     */
    function update_contract_unsign(uint contract_id) external {
        require(msg.sender == contracts[contract_id].principal || msg.sender == contracts[contract_id].agent,
            "Revert, only contract participants can unsign");
        // Record the actors act of unsigning from the contract
        contract_actor_signed[contract_id][msg.sender] = false;
        emit UnSignContract(contract_id);
        if (!contract_actor_signed[contract_id][contracts[contract_id].principal] &&
            !contract_actor_signed[contract_id][contracts[contract_id].agent]){
            // Record deactivation of the contract if both parties have unsigned
            contracts[contract_id].signed = false;
            emit DeActivateContract(contract_id);
        }
    }

    /**
    * @dev Get attributes of a specific legal contract representation
    * @param contract_id the id of the relevant contract struct
    * @return {
    *   "principal": Address
    *   "agent": Address
    *   "title": Overhead title of the legal contract
    *   "contract_hash": Hash generated from the legal contract
    *   "contract_method": The hashing algorithm used to generate the contract_hash
    * }
     */
    function read_contract(uint contract_id) public view
        returns (address principal, address agent, string memory title,
            bytes memory contract_hash, string memory contract_method, bool signed) {
        // Fetch the stored contract struct from the contracts list
        ContractStruct memory contract_struct = contracts[contract_id];
        principal = contract_struct.principal;
        agent = contract_struct.agent;
        title = contract_struct.title;
        contract_hash = contract_struct.contract_hash;
        contract_method = contract_struct.contract_method;
        signed = contract_struct.signed;
    }

    /**
    * @dev Get the ids of the contracts related to an actor
    * @param actor address of the actor
    * @return {
    *   "contract_ids": A list of contract_ids involving the actor
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
    *   "is_actor": True if actor is pricipal or agent in contract
    * }
     */
    function read_is_actor(uint contract_id, address actor) public view
        returns(bool is_actor) {
        is_actor = false;
        uint[] memory contract_ids = read_contract_ids(actor);
        for(uint i = 0; i < contract_ids.length; i++){
            if(contract_ids[i] == contract_id){
                is_actor = true;
            }
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import {AbstractModule} from "@verax/interface/AbstractModule.sol";
import {AttestationPayload} from "@verax/types/Structs.sol";

/**
 * @title ECDSA Module
 * @author Consensys x DappSheriff
 * @notice This contract illustrates a valid Module that is used to verify ECDSA signatures of payload
 */
contract ECDSAModule is AbstractModule, Ownable {
    using ECDSA for bytes32;
    using MessageHashUtils for bytes;

    address public signer;
    mapping(string => bool) public usedNonces; // tokenUri => used

    constructor(address initialOwner, address _signer) Ownable(initialOwner) {
        signer = _signer;
    }

    /// @dev This empty method prevents Foundry from counting this contract in code coverage
    function test() public {}

    /**
     * @notice This method is used to run the module's validation logic
     * @param attestationPayload - AttestationPayload containing the user address as `subject` and tokenUri as `attestationData`
     * @param validationPayload - Payload encoded with abi.encode(userAddress, tokenUri).toEthSignedMessageHash().sign(signer)
     */
    function run(
        AttestationPayload memory attestationPayload,
        bytes memory validationPayload,
        address, /*txSender*/
        uint256 /*value*/
    ) public override {
        address signee = abi.decode(attestationPayload.subject, (address));
        string memory tokenUri = abi.decode(attestationPayload.attestationData, (string));
        if (usedNonces[tokenUri]) {
            revert("Token URI already used");
        }

        address payloadSigner = abi.encodePacked(signee, tokenUri).toEthSignedMessageHash().recover(validationPayload);
        require(payloadSigner == signer, "Wrong signature");

        usedNonces[tokenUri] = true;
    }

    function setSigner(address _signer) external onlyOwner {
        signer = _signer;
    }
}

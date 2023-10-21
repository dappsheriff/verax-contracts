// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

import {ECDSAModule} from "../src/ECDSAModule.sol";
import {AttestationPayload} from "@verax/types/Structs.sol";

contract ECDSAModuleTest is Test {
    ECDSAModule ecdsaModule;
    address signer;
    uint256 signerPk;
    AttestationPayload attestationPayload;

    using ECDSA for bytes32;
    using MessageHashUtils for bytes;

    function setUp() public {
        (signer, signerPk) = makeAddrAndKey("dappSheriff");
        ecdsaModule = new ECDSAModule(signer, signer);

        attestationPayload = AttestationPayload(bytes32(uint256(1234)), 0, abi.encode(signer), abi.encode("tokenUri"));
        vm.deal(signer, 1 ether);
    }

    function testValidationRun() public {
        bytes32 hash = abi.encodePacked(signer, "tokenUri").toEthSignedMessageHash();

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(signerPk, hash);
        bytes memory signature = abi.encodePacked(r, s, v);

        ecdsaModule.run(attestationPayload, signature, signer, 0);
    }
}

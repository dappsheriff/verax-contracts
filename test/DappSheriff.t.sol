// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import {AttestationRegistry} from "@verax/AttestationRegistry.sol";
import {PortalRegistry} from "@verax/PortalRegistry.sol";
import {SchemaRegistry} from "@verax/SchemaRegistry.sol";
import {ModuleRegistry} from "@verax/ModuleRegistry.sol";
import {DefaultPortal} from "@verax/DefaultPortal.sol";
import {Attestation, AttestationPayload} from "@verax/types/Structs.sol";
import {Router} from "@verax/Router.sol";

import {DappSheriff} from "../src/DappSheriff.sol";
import {ECDSAModule} from "../src/ECDSAModule.sol";

contract DappSheriffTest is Test {
    DappSheriff dappSheriff;
    address signer;
    uint256 signerPk;

    address public portalOwner = makeAddr("portalOwner");
    Router public router;
    AttestationRegistry public attestationRegistry;
    PortalRegistry public portalRegistry;
    SchemaRegistry public schemaRegistry;
    ModuleRegistry public moduleRegistry;
    bytes32 public schemaId;
    AttestationPayload[] public payloadsToAttest;
    bytes[][] public validationPayloads;
    DefaultPortal public defaultPortal;
    ECDSAModule ecdsaModule;

    event Initialized(uint8 version);
    event AttestationRegistered(bytes32 indexed attestationId);
    event BulkAttestationsRegistered(Attestation[] attestations);
    event AttestationRevoked(bytes32 attestationId, bytes32 replacedBy);
    event BulkAttestationsRevoked(bytes32[] attestationId, bytes32[] replacedBy);
    event VersionUpdated(uint16 version);

    using ECDSA for bytes32;
    using MessageHashUtils for bytes;

    function setUp() public {
        router = new Router();
        router.initialize();

        attestationRegistry = new AttestationRegistry();
        router.updateAttestationRegistry(address(attestationRegistry));
        vm.prank(address(0));
        attestationRegistry.updateRouter(address(router));

        portalRegistry = new PortalRegistry();
        router.updatePortalRegistry(address(portalRegistry));
        vm.prank(address(0));
        portalRegistry.updateRouter(address(router));
        vm.prank(address(0));
        portalRegistry.setIssuer(address(0));

        schemaRegistry = new SchemaRegistry();
        router.updateSchemaRegistry(address(schemaRegistry));
        vm.prank(address(0));
        schemaRegistry.updateRouter(address(router));

        moduleRegistry = new ModuleRegistry();
        router.updateModuleRegistry(address(moduleRegistry));
        vm.prank(address(0));
        moduleRegistry.updateRouter(address(router));

        (signer, signerPk) = makeAddrAndKey("dappSheriff");
        ecdsaModule = new ECDSAModule(signer, signer);
        address ecdsaAddress = address(ecdsaModule);

        vm.prank(address(0));
        moduleRegistry.register("name", "description", ecdsaAddress);

        address[] memory modules = new address[](1);
        modules[0] = ecdsaAddress;
        defaultPortal = new DefaultPortal(modules, address(router));

        vm.prank(address(0));
        portalRegistry.register(address(defaultPortal), "defaultPortal", "defaultPortal", false, "defaultPortal");

        dappSheriff = new DappSheriff(signer);
        vm.prank(signer);
        dappSheriff.initVerax(address(defaultPortal), address(router));
        vm.prank(address(0));
        schemaRegistry.createSchema("name", "description", "context", "string dappSheriffTokenUri");
        vm.prank(signer);
        dappSheriff.setSchemaId("string dappSheriffTokenUri");
    }

    function testMint() public {
        bytes32 hash = abi.encodePacked(signer, "tokenUri").toEthSignedMessageHash();

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(signerPk, hash);
        bytes memory signature = abi.encodePacked(r, s, v);

        vm.deal(signer, 1 ether);
        vm.prank(signer);
        dappSheriff.mint{value: 0.001 ether}(signer, "tokenUri", signature);
    }
}

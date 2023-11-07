// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import {DefaultPortal} from "@verax/DefaultPortal.sol";
import {AttestationPayload} from "@verax/types/Structs.sol";
import {SchemaRegistry} from "@verax/SchemaRegistry.sol";
import {Router} from "@verax/Router.sol";

/**
 * @title DappSheriff
 * @notice This contract illustrates a valid ERC721 contract that creates attestation on Verax
 */
contract DappSheriff is ERC721, ERC721URIStorage, Ownable {
    uint256 private _nextTokenId;
    uint256 public price = 0.001 ether;

    DefaultPortal private dappSheriffPortal;
    SchemaRegistry private schemaRegistry;
    Router private veraxRouter;
    bytes32 public schemaId;

    event PriceChanged(uint256 newPrice);
    event SchemaRegistryUpdated(address newSchemaRegistry);
    event VeraxPortalUpdated(address newVeraxPortal);
    event SchemaUpdated(bytes32 newSchemaId);
    event VeraxInited(address dappSheriffPortal, address veraxRouter, address schemaRegistry);

    constructor(address initialOwner) ERC721("DappSheriff", "DPS") Ownable(initialOwner) {}

    /**
     * @notice This method is used to initialize the Verax integration
     * @param _dappSheriffPortal The address of the DappSheriff's Portal registered on Verax
     * @param _veraxRouter The address of the Verax's Router
     */
    function initVerax(address _dappSheriffPortal, address _veraxRouter) external onlyOwner {
        dappSheriffPortal = DefaultPortal(_dappSheriffPortal);
        veraxRouter = Router(_veraxRouter);
        schemaRegistry = SchemaRegistry(veraxRouter.getSchemaRegistry());

        emit VeraxInited(_dappSheriffPortal, _veraxRouter, address(schemaRegistry));
    }

    /**
     * @notice This method is used to update the Verax's SchemaRegistry, if it has been updated on Verax
     */
    function updateSchemaRegistry() external onlyOwner {
        schemaRegistry = SchemaRegistry(veraxRouter.getSchemaRegistry());

        emit SchemaRegistryUpdated(address(schemaRegistry));
    }

    /**
     * @notice This method is used to update the Verax's SchemaId, if it has been updated on our schema.
     *            Initially, it's empty and must be provided by the owner.
     * @param createSchema The string of the schema to update
     */
    function setSchemaId(string memory createSchema) external onlyOwner {
        schemaId = schemaRegistry.getIdFromSchemaString(createSchema);

        emit SchemaUpdated(schemaId);
    }

    /**
     * @notice This method is used to mint a new token and create an attestation on Verax
     * @param to The address of the token's owner
     * @param uri The URI of the token
     * @param sig Signed message of the token metadata. Only signed tokens can be attestated on Verax.
     */
    function mint(address to, string memory uri, bytes calldata sig) external payable {
        require(msg.value == price, "Wrong ETH value");

        uint256 tokenId = _nextTokenId++;
        _mint(to, tokenId);
        _setTokenURI(tokenId, uri);

        if (schemaId != 0) {
            // if verax integration is deployed
            bytes[] memory validationPayloads = new bytes[](1);
            validationPayloads[0] = sig;

            dappSheriffPortal.attest(
                AttestationPayload(schemaId, 0, abi.encode(to), abi.encode(uri)), validationPayloads
            );
        }
    }

    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721URIStorage) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function setPrice(uint256 _price) external onlyOwner {
        price = _price;

        emit PriceChanged(_price);
    }

    function withdraw() external onlyOwner {
        (bool success,) = msg.sender.call{value: address(this).balance}("");
        require(success, "Withdrawal failed");
    }

    /**
     * @notice This method is used to update the DappSheriff's Portal on Verax, if it has been updated
     * @param _dappSheriffPortal The address of the DappSheriff's Portal registered on Verax
     */
    function updatePortal(address _dappSheriffPortal) external onlyOwner {
        dappSheriffPortal = DefaultPortal(_dappSheriffPortal);

        emit VeraxPortalUpdated(_dappSheriffPortal);
    }
}

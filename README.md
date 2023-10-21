## DappSheriff x Verax

DappSheriff issues NFT attestations on Verax. Once user mints their ERC721 review, DappSheriff attestates the user on Verax.

Contracts:
- Goerli Testnet
  - DAPPSHERIFF NFT: 0xcc8C45bD9b1E1569c139D5511d8f66031f788D30
  - ECDSA_MODULE: 0x96d6750e92028f514D44a63A77A2f09E6Aba1398
  - PORTAL: 0xe2bb4e0f8d3f57dc02485d85e6be529b5c69541f


### ECDSA Module 
DappSheriff allows all users to mint their reviews, but they need to be attested by DappSheriff. 
DappSheriff uses ECDSA module to attest the users permit. 

To get the signature for the permit, users simply need to get calldata from DappSheriff's client, 
whill will already contain data for the NFT mint and Verax attestation.

### Attestation Schema
Verax's SchemaRegistry accepts this parameters:

```solidity
function createSchema(
    string memory name,
    string memory description,
    string memory context,
    string memory schemaString
)
```

DappSheriff sends this parameters:
- name - "DappSheriff Review Attestation"
- description - "Proof of user's review on DappSheriff"
- context - "review"
- schemaString - "string dappSheriffTokenId"

### Portal
DappSheriff has decided to use the default portal created by Portal Registry
```solidity
function deployDefaultPortal(
  address[] calldata modules,
  string memory name,
  string memory description,
  bool isRevocable,
  string memory ownerName
)
```

DappSheriff sends this parameters:
- modules - []
- name - "DappSheriff Portal"
- description - "Portal to issue review attestations"
- isRevocable - false
- ownerName - "dappsheriff.com"


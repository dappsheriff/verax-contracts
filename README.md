## DappSheriff x Verax

DappSheriff issues NFT attestations on Verax. Once user mints their ERC721 review, DappSheriff attestates the user on Verax.

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

### ECDSA Module 
DappSheriff allows all users to mint their reviews, but they need to be attested by DappSheriff. 
DappSheriff uses ECDSA module to attest the users permit. 

To get the signature for the permit, users simply need to get calldata from DappSheriff's client, 
whill will already contain data for the NFT mint and Verax attestation.


### Portal
```solidity
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


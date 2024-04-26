# How to Write a Module

Modules are the building blocks of complex behavior in Gribi. If you want to do something in Gribi, you will either be writing a module or using one. Here we will go through the process of writing a new Gribi module by following the 
example module available in this folder.

## Table of Contents
- [What kind of module are you writing?]()
- [Vault]()
- [RootSystem]()
- [Getting Started]()
    - [EVMRootSystem]()
    - [BaseThread.sol]()
    - [contract/Example.sol]()
    - [circuits/commit/src/main.nr]()
    - [client/src/index.ts]()

## What kind of module are you writing?

Not all modules in Gribi are created equal. The gribi interfaces as defined [here]() work at different levels of the stack. 


![diagram of gribi arch](../../gribi-arch.png)

Modules may exist as
1. a set of Transforms
2. a Transmitter, Receptor and Transform
3. Receptors and RootSystem functionality
4. etc.

## Vault

Vaults are where you store secrets for client-side use. A user may want to retain ownership over a PCD making some claim over their identity for later use. A user creating commitments to client-side data in the RootSystem will want to display and update it in the clear client-side. All secrets have their hidden truths and these hidden truths go into the Vault. A module who wants a user to see or manipulate their hidden truths to create more PCDs or Signals will need to retrieve them from the Vault.

## RootSystem

PCDs are self-evident, static objects. In other words, they are capable of attesting only to the data contained within. This is the source of their strength as composable and federated objects, but in order to augment their power we do occasionally want to transform them into a more stateful, ordered and dynamic form. This is why we have RootSystems. They "root" the data into some larger stateful system. Our example module uses the EVMRootSystem, a simplified private state framework which complements public state frameworks like MUD or Dojo. For now, our EVMRootSystem only supports MUD and EVM-based chains.

RootSystems expose a simple interface and may have wide ranging implementations. In the EVMRootSystem, module client-code must interact with module specific behavior on the contract side. Our example module includes both code for the client (Transmitters and Receptors) and code for the contract (which are called Threads in EVMRootSystem)

## Getting Started

The rest of this document will follow an example module built for the EVMRootSystem. This module exposes the functionality to create, update, and reveal commitments. A module like this sets the foundation for more complex hidden information modules, like hidden movement.

### EVMRootSystem

[PLACEHOLDER EVMROOTSYSTEM GRAPHIC]

An EVMRootSystem module consists of three things:
1. Client code to handle the logic of creating Transactions, generating proofs and submitting them to the chain.  (Using Gribi interfaces)
2. Circuit code to be used for proofs (built in Noir)
3. Contract code to update onchain data structures and move state around (EVMRootSystem Threads).

We will cover these in reverse order.

### BaseThread.sol

When you want to build a module for the EVMRootSystem, then you must either refer to an existing Thread or create your own. Let's take a look at what exactly a Thread is by examining the abstract BaseThread interface.

We will see how these are used in the Example.sol immediately after.

```
struct UpdateRegister {
    uint code;
    bytes value;
}

abstract contract BaseThread {
    uint[] codes;
    UpdateRegister internal register;
    Forest internal forest;

    constructor() {
        forest = new Forest();
    }

    function getModuleID() public virtual pure returns (uint256); 
    function peekUpdates() public view returns (UpdateRegister memory) {
        return register;
    }
}
```
We will go through it one by one
<br/>
<br/>

```
uint[] codes
UpdateRegister internal register
function peekUpdates() public view returns (UpdateRegister memory) {
    return register;
}
```
Threads hold their own state, but are only meant to hold state for client-side cryptographic operations. Sometimes you need to move that state back into a framework optimized for viewing and manipulating state (for this example, MUD). It is expected that a module will set a unique code and fill the register following some operation to flag public state has become available for external frameworks.

<br/>
<br/>

```
Forest internal forest;
```
A forest is a set of three merkle trees. A commitment tree, a nullifier tree and a public state tree. These three trees serve distinct cryptographic purposes.
1. Commitment trees may be used to hold a commitment to some state (e.g. a hash of some private data). Storing commitments in a tree allows us to prove facts over this commitment without sharing which commitment specifically this fact is about.
2. Nullifier trees are used to hold nullifiers and are optimized to create proofs that something does not exist in the tree. You can think of nullifiers as a way to prevent double-spends over private state.
3. A public state tree is used similarly to the commitment tree except its leaves hold public state which is visible to all. This allows us to use public state in our circuits by proving the state we used in the circuit exists in this tree.

<br/>
<br/>
<br/>

```
function getModuleID() public virtual pure returns (uint256); 
```

Every module in EVMRootSystem is given a unique ID. Client code when using a module through the EVMRootSystem will use this ID to route appropriately to Thread.

<br/>
<br/>


### contract/Example.sol

Now take a look at the Example.sol file in our module/contracts folder. We will highlight specific units of code to describe how it's implemented.

<br/>
<br/>

```
function getModuleID() public virtual pure override returns (uint256) {
        return uint256(keccak256(abi.encodePacked("example-module")));
    }
```

Keccak of a string provides for a simple way to define the module ID which can be easily recreated on the client.
<br/>
<br/>

```
enum Codes { UNSET, REVEAL_COMMITMENT }
```

We have two codes:
- UNSET which tells any listener to simply ignore
- REVEAL_COMMITMENT which announces that a commitment has been revealed.

<br/>
<br/>

Now, let's take a look at one of the functions on our module.

```
 function revealCommitment(Transaction memory transaction) external {
        require(transaction.inputs.length > 2, "malformed transaction");
        uint256 commitment = transaction.inputs[0].value;
        uint256 salt = transaction.inputs[1].value;
        uint256 secret = transaction.inputs[2].value;

        require(forest.commitmentExists(commitment), "This value was not properly committed to earlier!");
        uint256 hash = uint256(keccak256(abi.encodePacked([salt, secret])));
        require(hash == commitment, "The revealed commitment is incorrect");

        register = UpdateRegister(
            uint(Codes.REVEAL_COMMITMENT),
            abi.encode(secret)
        );
    }
```

<br/>
<br/>

First, what is a Transaction? We can see them defined in the Structs.sol file of EVMRootSystem contracts.

```
struct PublicInput {
    uint256 slot;
    uint256 value;
}

struct Operation {
    uint256 opid;
    uint256 value;
    uint256 nullifier;
}

struct Transaction {
    PublicInput[] inputs;
    Operation[] operations;
}
```

Transactions are simply arrays of PublicInputs and Operations. Circuits are required to take a Transaction as input. The EVMRootSystem expects no more than 8 of each of these arrays. So, we can have a maximum of 8 PublicInputs and 8 Operations in one Transaction.

**Operations**
The meaning of opid, value and nullifier will be specific to your module. In this module the opid is not used. Value is the commitment and nullifier is only present when making updates or revealing commitments.

**PublicInput**
these inputs are expected to come from the public tree. The EVMRootSystem will feed these inputs into the circuit verifier keying on slot. In our Example module we use slot 0, which tells the EVMRootSystem to not do a lookup into our tree. As such, PublicInputs at slot 0 allow for arbitrary inputs into our circuit.
<br/>
<br/>

Second we understand modules are responsible for managing their own forest. 
```
require(forest.commitmentExists(commitment), "This value was not properly committed to earlier!");
require(!forest.nullifierExists(transaction.operations[0].nullifier), "This value was not properly committed to earlier!");
        forest.addNullifier(transaction.operations[0].nullifier);
```

These lines use the commitment tree to make sure we aren't revealing a made-up commitment and the nullifier tree to make sure we haven't revealed this commitment before.

You can also see further down we check to make sure the commitment is well formed.

<br/>
<br/>

Finally we want to move this secret back into MUD so all players can see the reveal. Values in the register are encoded to allow for arbitrary return types. This means whoever will read the type needs to know the underlying structure of the encoded data. In order to make this easier, this module includes an add-on convenience function for parsing data.
```
register = UpdateRegister(
            uint(Codes.REVEAL_COMMITMENT),
            abi.encode(secret)
        );
```
This function is not included in the interface because solidity does not allow for generics. In the future we may discover a more convenient way to do pass along the structure of the register value data.
```
function parse(UpdateRegister memory ur) public pure returns (uint256) {
        if (ur.code == uint(Codes.REVEAL_COMMITMENT)) {
            return abi.decode(ur.value, (uint256));
        }
    }
```

### circuits/commit/src/main.nr

> NOTE: Circuit logic is currently incomplete and is not turned on in the alpha version EVMRootSystem. 

The EVMRootSystem expects our Circuits to be written in [Noir](), a rust-like circuit definition language.


The interface below describes the public and private inputs to our module circuit in Noir.
```
fn main(
	address: pub Field,
	inputs: pub [PublicInput; 8],
	operations: pub [Operation; 8],

	commitment_root: pub Field, 
	nullifier_root: pub Field,
	public_root: pub Field,

	//Arbitrary private variables would go below here
	commitment: Field,
	secrets: Field,
	salt: Field
) { ... }
```

In the future, the address, tree roots, inputs and operations will be handled through oracle calls. We may also need to add extra information into the context. As such, this format is highly likely to change.

The primary thing to note is how our circuit allows for arbitrary private variables. We can add as many private inputs as we want, however the public inputs are fixed. The PublicInputs and Operations fed into this circuit will be the same PublicInputs and Operations sent by the client and received by our contract. 

EVMRootSystem promises to verify the proof with the above inputs, which are again: msg.sender(), Transaction and the roots of the Thread's forest.

Given this construction we can began to see how a circuit might constrain behavior across client and contract.

The client could update a secret commitment to a new secret commitment and prove this update is valid and made according to the constraints of the circuit. Then, the contract only needs to verify a proof and perform the updates as specified by the Transaction.

Let's imagine our commitment is a player's hidden location (x,y) data hashed using Pedersen hash. A player then chooses to move to (x+1, y). This requires an update to the committed Pedersen hash. Our circuit would something like this:
1. Check the new commitment is well formed.
2. Check the new commitment pre-hash (x,y) is within distance 1 of previous commitment pre-hash (x,y)
3. Check the nullifier of the previous commitment is well formed.

### client/src/index.ts

This brings us finally to the module's client code. As above, we will go through the client code and highlight specific logic to cover all the requisite parts of writing client code in Gribi.
<br/>
<br/>

The first thing to note is that we are defining this thing called a Precursor.
```
export class CreateCommitment implements Precursor<CommitmentArgs, Commitment[], StoredCommitment> {
    async bond(args: CommitmentArgs): Promise<WitnessRelation<Commitment[], StoredCommitment>> {
        const commitment = (await Utils.keccak([args.salt as bigint, args.secret as bigint])).toString();
        return {
            claim: [commitment.toString()],
            witness: {
                secret: [args.secret],
                salt: [args.salt]
            }
        }
    }
}
```

A Precursor is a convenient structure for us to use client-side because it bundles the claim (the commitment) with its secret parts (the witness). Were we to use PCDs instead to formulate this relationship, the format would be much the same except instead of a field called witness, we would have a field called proof with the trivial proof (that is, the witness). In order to draw a distinction between this client-side utility form and regular PCDs which are meant to be federated, Gribi defines the Precursor interface.

Our CreateCommitment Precursor simply bundles together a commitment with its witness: a salt and secret (the two values hashed together to create the commitment).

<br/>
<br/>

```
export class CreateCommitmentReceptor implements Receptor<WitnessRelation<Commitment[], StoredCommitment>, StateUpdate> {
    async signal(args: WitnessRelation<Commitment[], StoredCommitment>): Promise<Signal<StateUpdate>> {
        let cc = CommitCheck as CompiledCircuit;
        const inputs =  [Utils.EmptyInput()];
        const operations = [{
            opid: 0,
            value: BigInt(args.claim.slice(-1)[0]),
        }];
        const proof = await prove(EVMRootSystem.walletAddress, cc, inputs, operations, {
            secret: args.witness.secret.toString(),
            salt: args.witness.salt.toString()
        });

        return {
            output: {
                id: MODULE_ID,
                method: 'createCommitment',
                inputs,
                operations,
                proof
            }
        }
    }
}
```

Now that we have gone through both the contract and the circuit code, we can see all of these things come together in the client code.

We form the PublicInputs and Operations. We create the proof using those inputs. Finally, we return a Signal\<StateUpdate\>. 

That's it!

But, where's our Transaction? How does this StateUpdate reach the contract? In order to understand that, we'll need to take a look at the [Using a Module in MUD]() tutorial.



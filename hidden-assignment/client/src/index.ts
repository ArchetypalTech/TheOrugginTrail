import { keccak256, toHex } from 'viem';
import { 
    Signal, 
    Field,
    Receptor,
} from '@gribi/types';
import { WitnessRelation, Precursor } from '@gribi/types';
import { Vault } from '@gribi/vault';
import { NetworkCall } from '@gribi/mud';
import { Utils } from "@gribi/vault";
import { EVMRootSystem, StateUpdate, prove } from "@gribi/evm-rootsystem";
import { CompiledCircuit } from '@noir-lang/backend_barretenberg';

// import RandomnessCheck from '../../circuits/generate/target/generate.json';
// import RevealCheck from '../../circuits/reveal/target/reveal.json';

export const MODULE_ID = BigInt(keccak256(toHex("hidden-assignment")));

export type Commitment = string;
export type JointRandomness = {
    myRandom: Field,
    chainRandom: Field
    commitmentKey: Field
}

export type StoredCommitment = {
    randomness: string,
}

export type UpdateCommitmentArgs = {
    relation: WitnessRelation<Commitment[], StoredCommitment>,
    circuit?: CompiledCircuit,
    secret: Field,
    salt: Field,
}

export class CreateRandomness implements Precursor<undefined, Commitment, StoredCommitment> {
    async bond(args: undefined): Promise<WitnessRelation<Commitment, StoredCommitment>> {
        const randomness = Utils.rng();
        const commitment = (await Utils.keccak([randomness as bigint])).toString();
        return {
            claim: commitment.toString(),
            witness: {
                randomness: randomness.toString(), 
            }
        }
    }
}

export class RandomnessReceptor implements Receptor<WitnessRelation<Commitment, StoredCommitment>, StateUpdate> {
    async signal(args: WitnessRelation<Commitment, StoredCommitment>): Promise<Signal<StateUpdate>> {
        // let cc = RandomnessCheck as CompiledCircuit;
        const inputs =  [Utils.EmptyInput()];
        const operations = [{
            opid: 0,
            value: BigInt(args.claim),
            nullifer: 0,
        }];

        // Disbaling because of build errors
        // const proof = await prove(EVMRootSystem.walletAddress, cc, inputs, operations, {
        //     randomness: args.witness.randomness.toString()
        // });

        return {
            output: {
                id: MODULE_ID,
                method: 'generate',
                inputs,
                operations,
                // proof
            }
        }
    }
}

export class RevealCommitment implements Receptor<WitnessRelation<Commitment, JointRandomness>, StateUpdate> {
    async signal(args: WitnessRelation<Commitment, JointRandomness>): Promise<Signal<StateUpdate>> {
        // let cc = RevealCheck as CompiledCircuit;
        const commitment = args.claim;
        const index = (await Utils.keccak([args.witness.myRandom as bigint, args.witness.chainRandom as bigint])).toString();

        const inputs = [{
            slot: args.witness.commitmentKey,
            value: args.witness.chainRandom
        }];
        const operations = [{
            opid: 0,
            value: index,
            nullifier: commitment
        }]

        // Disabling because of build errors

        //Generate proof for the reveal here
        // const proof = await prove(EVMRootSystem.walletAddress, cc, inputs, operations, {
        //     randomness: args.witness.myRandom.toString()
        // });

        return {
            output: {
                id: MODULE_ID,
                method: "reveal",
                inputs,
                operations,
                // proof
            }
        }
    }
}

export const createModuleCalls = (call: NetworkCall, vault: typeof Vault, rs: typeof EVMRootSystem) => {
    /**
     * Creates a commitment to randomness on-chain
     */
    const claim = async (commitmentKey: number) => {
        const randomness = await new CreateRandomness().bond(undefined);
        const signal = await new RandomnessReceptor().signal(randomness);
        const txs = await rs.createTxs([signal]);
        const entry = {
            slot: commitmentKey,
            value: randomness
        }
        await Promise.all(txs.map(async (tx: any) => await call(tx)));
        Vault.setEntry(rs.walletAddress, MODULE_ID.toString(), entry);
    }

    /**
     * 
     * @param chainRandom the random number generated on-chain and used to create joint randomness
     * @param commitmentKey the key that is used to determine the item slot both client-side and onchain
     */
    const reveal = async (chainRandom: number, commitmentKey: number) => {
        const entry = vault.getDataAtSlot(rs.walletAddress, MODULE_ID.toString(), commitmentKey);
        const relation = entry?.value as WitnessRelation<Commitment, StoredCommitment>;
        const jointRandomness = {
            chainRandom, 
            commitmentKey,
            myRandom: relation.witness.randomness,
        }
        const revealRelation = {
            claim: relation.claim,
            witness: jointRandomness
        }
        const signal = await new RevealCommitment().signal(revealRelation);
        const txs = await rs.createTxs([signal]);
        await Promise.all(txs.map(async (tx: any) => await call(tx)));
        Vault.removeEntry(rs.walletAddress, MODULE_ID.toString(), entry!);
    }

    return {
        claim,
        reveal
    }
}

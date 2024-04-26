import { Signal, Field, Receptor } from '@gribi/types';
import { WitnessRelation, Precursor } from '@gribi/types';
import { Vault } from '@gribi/vault';
import { NetworkCall } from '@gribi/mud';
import { EVMRootSystem, StateUpdate } from "@gribi/evm-rootsystem";
import { CompiledCircuit } from '@noir-lang/backend_barretenberg';
export declare const MODULE_ID: bigint;
export type Commitment = string;
export type JointRandomness = {
    myRandom: Field;
    chainRandom: Field;
    commitmentKey: Field;
};
export type StoredCommitment = {
    randomness: string;
};
export type UpdateCommitmentArgs = {
    relation: WitnessRelation<Commitment[], StoredCommitment>;
    circuit?: CompiledCircuit;
    secret: Field;
    salt: Field;
};
export declare class CreateRandomness implements Precursor<undefined, Commitment, StoredCommitment> {
    bond(args: undefined): Promise<WitnessRelation<Commitment, StoredCommitment>>;
}
export declare class RandomnessReceptor implements Receptor<WitnessRelation<Commitment, StoredCommitment>, StateUpdate> {
    signal(args: WitnessRelation<Commitment, StoredCommitment>): Promise<Signal<StateUpdate>>;
}
export declare class RevealCommitment implements Receptor<WitnessRelation<Commitment, JointRandomness>, StateUpdate> {
    signal(args: WitnessRelation<Commitment, JointRandomness>): Promise<Signal<StateUpdate>>;
}
export declare class HiddenState {
    private call;
    private vault;
    private rs;
    constructor(call: NetworkCall, vault: typeof Vault, rs: typeof EVMRootSystem);
    /**
     * Creates a commitment to randomness on-chain
     */
    claim(commitmentKey: number): Promise<void>;
    /**
     *
     * @param chainRandom the random number generated on-chain and used to create joint randomness
     * @param commitmentKey the key that is used to determine the item slot both client-side and onchain
     */
    reveal(chainRandom: number, commitmentKey: number): Promise<void>;
}

use dep::std;

struct Operation {
	opid: Option<Field>,
	value: Option<Field>,
	nullifier: Option<Field>,
}

struct Input {
    slot: Option<Field>,
    value: Option<Field>,
}

//Example signature of what a gribi module circuit looks like
// PROOFS NOT HOOKED UP RIGHT NOW
fn main(
	// TODO: IDEALLY WE GET THESE ALL THROUGH ORACLE
	address: pub Field,
	inputs: pub [Input; 8],
	operations: pub [Operation; 8], //given 8 maximum, which seems like more than anyone would need

	//I mean just in case for crazy shit we keep these???
	// commitment_root: pub Field, 
	// nullifier_root: pub Field,
	// public_root: pub Field,

	//Arbitrary private variables would go below here
	randomness: Field,
) {
	// this means, most logic is on JS side
	// the circuit logic just validates "correctness"
	let commitment = operations[0].value.unwrap();
	let commit = std::hash::pedersen_hash([commitment, randomness, 0, 0, 0, 0, 0]);
	assert(commitment == commit);
}
// SPDX-License-Identifier: Proprietary
pragma solidity ^0.8.20;

/**
 * @dev Interface for verifying Aleo zero-knowledge proofs.
 */
interface IAleoVerifier {
    /**
     * @dev Verifies an Aleo zero-knowledge proof.
     * @param proof The ZK proof generated off-chain.
     * @param publicInputs Public inputs used for verification.
     * @return valid Returns true if the proof is valid, false otherwise.
     */
    function verifyProof(bytes calldata proof, bytes calldata publicInputs) external view returns (bool valid);
}

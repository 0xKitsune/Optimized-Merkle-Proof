// SPDX-License-Identifier: MIT
pragma solidity >=0.8.10;

contract OptimizedMerkleProof {
 
    ///TODO: Update all the comments, only a temp placeholder for now


    ///@notice Verifies that a leaf is part of a merkle tree
    ///@param root - The merkle root of the tree
    ///@param leaf - The element that gets hashed with the hash at `index`
    ///@param proof - Array of bytes32 consisting of proof elements required to verify the merkle proof
    function verify(
        bytes32 root,
        bytes32 leaf,
        bytes32[] calldata proof
    ) public pure returns (bool) {
        uint256 proofLength = proof.length;

        assembly {

            ///@notice for each proofElement in proofs
            for {
                let i := 0
            } lt(i, proofLength) {
                i := add(i, 1)
            } {

                ////@notice The offset is 0x84, which is 132 bytes there is an extra 4 bytes to account for the method signature in the calldata
                 ///@notice Offset for the first proof element is 0x84 because the length of the array is at 0x64
                let proofElement := calldataload(add(0x84,mul(0x20,i)))

                //calculate the next proof
                {
                    switch lt(leaf, proofElement)
                    ///@notice if the leaf is > proofElement
                    case 0 {
                        ///@notice store the proof then hash element in scratch space
                        mstore(0x00, proofElement)
                        mstore(0x20, leaf)

                        ///@notice hash the proofElement and leaf to get the new proof
                        leaf := keccak256(0x00, 0x40)    
                    }
                    ///@notice if the leaf is < proofElement
                    default {
                        ///@notice store the hash then proof element in scratch space
                        mstore(0x00, leaf)
                        mstore(0x20, proofElement)

                        ///@notice keccak256 hash the leaf and proofElement to get the new proof
                        leaf := keccak256(0x00, 0x40)
                    }
                }
            }

            ///@notice Evaluates to if root != leaf after the leaf has been updated
            if iszero(eq(root, leaf)) {
                mstore(0x00, false)
                return(0x00, 0x20)
            }

            ///@notice Otherwise, return true
            mstore(0x00, true)
            return(0x00, 0x20)
        }
    }
    
}


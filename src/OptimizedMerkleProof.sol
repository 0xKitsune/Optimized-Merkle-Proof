// SPDX-License-Identifier: MIT
pragma solidity >=0.8.10;

contract OptimizedMerkleProof {
 
    ///@param leaf - The element that gets hashed with the hash at `index`
    function verify(
        bytes32 root,
        bytes32 leaf,
        bytes32[] calldata proof
    ) public pure returns (bool) {
        uint256 proofLength = proof.length;

        assembly {

            // for each proofElement in proofs
            for {
                let i := 0
            } lt(i, proofLength) {
                i := add(i, 1)
            } {

                //The offset is 0x84, which is 132 bytes there is an extra 4 bytes to account for the method signature in the calldata
                //Offset for the first proof element is 0x84 because the length of the array is at 0x64
                let proofElement := calldataload(add(0x84,mul(0x20,i)))

                //calculate the next proof
                {
                    switch lt(leaf, proofElement)
                    //if the leaf is < proofElement
                    case 0 {
                        //store the proof then hash element in scratch space
                        mstore(0x00, proofElement)
                        mstore(0x20, leaf)

                        //hash the proofElement and leaf to get the new proof
                        leaf := keccak256(0x00, 0x40)    
                    }
                    //else
                    default {
                        //store the hash then proof element in scratch space
                        mstore(0x00, leaf)
                        mstore(0x20, proofElement)

                        //keccak256 hash the leaf and proofElement to get the new proof
                        leaf := keccak256(0x00, 0x40)

                    }
                }
            }

            //Evaluates to if root != leaf after the leaf has been updated
            if iszero(eq(root, leaf)) {
                mstore(0x00, false)
                return(0x00, 0x20)
            }
            mstore(0x00, true)
            return(0x00, 0x20)
        }
    }
    
}



// NOTE: Offsets in calldata do not account for function sig, will update this later.
//Disregard anything below this comment for now


//TODO: Benchmark maybe adding everything in assembly, prob not but will check if any significant gas savings
// This still needs to be further optimized also

///--------------------------------------------------------------------------------------
    ///--------------------------------------------------------------------------------------
    // function verifyWithAssembly(bytes calldata indexRootLeafProofsizeProof)
    //     public
    //     pure
    //     returns (bool)
    // {
    //     assembly {
    //         //store the index, root, leaf, proof size and proof in memory

    //         //index is 2 bytes
    //         let index := mload(0x40)
    //         calldatacopy(index, 0x00, 0x02)

    //         //root is 32 bytes
    //         let root := mload(0x40)
    //         calldatacopy(root, 0x22, 0x20)

    //         //leaf is 32 bytes
    //         let leaf := mload(0x40)
    //         calldatacopy(leaf, 0x42, 0x20)

    //         //proofSize is 2 bytes
    //         let proofSize := mload(0x40)
    //         calldatacopy(proofSize, 0x62, 0x02)

    //         //proof is determined by 32 bytes * proofSize
    //         let proof := mload(0x40)
    //         calldatacopy(proof, 0x64, mul(0x20, mload(proofSize)))

    //         //for each proofElement in proofs
    //         for {
    //             let i := 0
    //         } lt(i, proofSize) {
    //             i := add(i, 1)
    //         } {
    //             let proofElement := mload(mul(proof, i))
    //             //calculate the next proof
    //             {
    //                 //if the current index is even
    //                 switch iszero(mod(index, 2))
    //                 case 1 {
    //                     //store the hash then proof element in scratch space
    //                     mstore(0x00, leaf)
    //                     mstore(0x20, proofElement)

    //                     //keccak256 hash the leaf and proofElement to get the new proof
    //                     leaf := keccak256(0x0, 0x40)
    //                 }
    //                 default {
    //                     //store the proof then hash element in scratch space
    //                     mstore(0x00, proofElement)
    //                     mstore(0x20, leaf)

    //                     //hash the proofElement and leaf to get the new proof
    //                     leaf := keccak256(0x0, 0x40)
    //                 }
    //             }

    //             // The parent index of the current proof is always `k` where the current proof index is equal to `2k` for even indexes or `2k + 1` for odds
    //             // In a more legible formula:
    //             // When the current index is even: currentIndex = 2 * parentIndex
    //             // When the current index is odd: currentIndex = 2 * parentIndex + 1
    //             // This finds `k` by taking the current proof index, dividing it by two and rounding down to the nearest int.
    //             // Rounding down accounts for when the index is odd.
    //             index := div(index, 2)
    //         }
    //     }
    // }

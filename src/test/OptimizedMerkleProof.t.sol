// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;

import "../../lib/ds-test/src/test.sol";
import "../../lib/openzeppelin-contracts/MerkleProof.sol";
import "../OptimizedMerkleProof.sol";
import "../../lib/utils/Console.sol";

///TODO: need to add more tests, also look for further optimizations

contract OptimizedMerkleProofTest is DSTest {
    MerkleProof _merkleProof;
    OptimizedMerkleProof _optimizedMerkleProof;

    function setUp() public {
        _merkleProof = new MerkleProof();
        _optimizedMerkleProof = new OptimizedMerkleProof();
    }

    function testOptimizedMerkleProofVerify() public view {
        bytes32[] memory proof = new bytes32[](2);

        bytes32 proof0 = 0x948f90037b4ea787c14540d9feb1034d4a5bc251b9b5f8e57d81e4b470027af8;
        bytes32 proof1 = 0x63ac1b92046d474f84be3aa0ee04ffe5600862228c81803cce07ac40484aee43;

        proof[0] = proof0;

        proof[1] = proof1;

        bool valid = _optimizedMerkleProof.verifyProof(
            //root
            0x074b43252ffb4a469154df5fb7fe4ecce30953ba8b7095fe1e006185f017ad10,
            //leaf
            0x1bbd78ae6188015c4a6772eb1526292b5985fc3272ead4c65002240fb9ae5d13,
            //proof
            proof
        );

        assert(valid);
    }

    function testMerkleProofVerify() public view {
        bytes32[] memory proof = new bytes32[](2);

        bytes32 proof0 = 0x948f90037b4ea787c14540d9feb1034d4a5bc251b9b5f8e57d81e4b470027af8;
        bytes32 proof1 = 0x63ac1b92046d474f84be3aa0ee04ffe5600862228c81803cce07ac40484aee43;

        proof[0] = proof0;

        proof[1] = proof1;

        bool valid = _merkleProof.verify(
            //proof
            proof,
            //root
            0x074b43252ffb4a469154df5fb7fe4ecce30953ba8b7095fe1e006185f017ad10,
            //leaf
            0x1bbd78ae6188015c4a6772eb1526292b5985fc3272ead4c65002240fb9ae5d13
        );

        assert(valid);
    }
}

/* Data for test case
    3rd leaf
    0x1bbd78ae6188015c4a6772eb1526292b5985fc3272ead4c65002240fb9ae5d13

    root
    0x074b43252ffb4a469154df5fb7fe4ecce30953ba8b7095fe1e006185f017ad10


    proof
    0x948f90037b4ea787c14540d9feb1034d4a5bc251b9b5f8e57d81e4b470027af8
    0x63ac1b92046d474f84be3aa0ee04ffe5600862228c81803cce07ac40484aee43
    */

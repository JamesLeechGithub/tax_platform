// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

interface IProposal {

    enum ProposalState {
        PROPOSED,
        UNSUCCESSFULL,
        SUCCESSFULL,
        PHASE_1,
        PHASE_2,
        PHASE_3,
        PHASE_4,
        CLOSED
    }

    struct Proposal {
        uint256 proposalID;
        uint256 tenderID;
        uint256 sectorID;
        uint256 companyID;
        uint256 quote;
        uint256 numberOfPublicVotes;
        bytes32 storageHash;
        ProposalState _proposalState;
    }

    function createProposal(uint256 _tenderID, uint256 _sectorID, uint256 _companyID, uint256 _quote, bytes32 _IPFSHash) external;

    function calculateWinningProposals(uint256 _tenderID) external;

    function addVoteForProposal(uint256 _proposalID, uint256 _totalVotingPower) external;

    //function viewAllProposals() external view returns (Proposal[] memory);

    //function getProposal(uint256 _proposalID) external view returns (Proposal memory);

}
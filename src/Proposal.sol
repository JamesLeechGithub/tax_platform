// SPDX-License-Identifier: MIT
pragma solidity =0.8.13;

import "./interfaces/ICitizen.sol";
import "./interfaces/ITender.sol";
import "./interfaces/ITaxPayerCompany.sol";
import "./TaxPayerCompany.sol";
import "./Citizen.sol";
import "./Sector.sol";
import "./Governance.sol";

contract Proposal is IProposal {

    address public sectorContractAddress;
    address public governanceContractAddress;
    address public companyContractAddress;
    address public tenderContractAddress;
    address public citizenContractAddress;
    uint256 public numberOfProposals;

    mapping(uint256 => Proposal) public proposals;

    event ProposalCreated(Proposal _proposal);
    event SetSupervisor(
        uint256 proposalID,
        address previousSupervisor,
        address newSupervisor,
        uint256 time
    );

    constructor(address _sectorContractAddress, address _citizenContractAddress, address _governanceContractAddress, address _companyContractAddress, address _tenderContractAddress) {
        sectorContractAddress = _sectorContractAddress;
        governanceContractAddress = _governanceContractAddress;
        companyContractAddress = _companyContractAddress;
        tenderContractAddress = _tenderContractAddress;
        citizenContractAddress = _citizenContractAddress;
    }

    //----------------------------------------------------------------------------------------------------------------------
    //-----------------------------------------         CREATE FUNCTIONS        --------------------------------------------
    //----------------------------------------------------------------------------------------------------------------------

    function createProposal(uint256 _tenderID, uint256 _sectorID, uint256 _companyID, uint256 _quote, bytes32 _IPFSHash)
        public onlySuperAdmin
    {
        
        ITender tender = ITender(tenderContractAddress);
        ITaxPayerCompany company = ITaxPayerCompany(companyContractAddress);

        proposals[numberOfProposals] = Proposal({
            proposalID: numberOfProposals,
            tenderID: _tenderID,
            sectorID: _sectorID,
            companyID: _companyID,
            quote: _quote,
            numberOfPublicVotes: 0,
            storageHash: _IPFSHash,
            _proposalState: ProposalState.PROPOSED
        });

        company.addProposal(numberOfProposals, _companyID);
        tender.addProposal(numberOfProposals, _tenderID);

        numberOfProposals++;

        emit ProposalCreated(proposals[numberOfProposals - 1]);
    }

    //----------------------------------------------------------------------------------------------------------------------
    //-----------------------------------------         GENERAL FUNCTIONALITY        ---------------------------------------
    //----------------------------------------------------------------------------------------------------------------------

    function addVoteForProposal(uint256 _proposalID, uint256 _totalVotingPower) external {
        
        require(msg.sender == citizenContractAddress, "NOT CONTRACT CALLER");
        proposals[_proposalID].numberOfPublicVotes += _totalVotingPower;

    }

    //Total public votes is scale of 10_000
    //Incase of ties, cheaper price quoted will be selected
    function calculateWinningProposals(uint256 _tenderID) public onlySuperAdmin {

        uint256 winningNumberOfVotes = 0;
        uint256 winningBudget = 0;
        
        Proposal memory winningProposal;

        for (uint256 x = 0; x <= numberOfProposals; x++) {
            if (proposals[x].tenderID == _tenderID) {
                if (proposals[x].numberOfPublicVotes == winningNumberOfVotes) {
                    if (proposals[x].quote < winningBudget) {
                        winningNumberOfVotes = proposals[x].numberOfPublicVotes;
                        winningProposal = proposals[x];
                    }
                } else if (
                    proposals[x].numberOfPublicVotes > winningNumberOfVotes
                ) {
                    winningNumberOfVotes = proposals[x].numberOfPublicVotes;
                    winningProposal = proposals[x];
                }
            }
        }

        winningProposal._proposalState = ProposalState.SUCCESSFULL;

        for (uint256 x = 0; x < numberOfProposals; x++) {
            if (proposals[x].tenderID == _tenderID) {
                if (proposals[x].proposalID != winningProposal.proposalID) {
                    proposals[x]._proposalState = ProposalState.UNSUCCESSFULL;
                }
            }
        }
    }

    modifier onlySuperAdmin() {
        Governance governance = Governance(governanceContractAddress);
        require(msg.sender == governance.superAdmin(), "NOT SUPER ADMIN");        
        _;
    }
}

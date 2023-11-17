// SPDX-License-Identifier: MIT
pragma solidity =0.8.13;

import "./interfaces/ICitizen.sol";
import "./interfaces/IProposal.sol";

import "./Sector.sol";

contract Citizen is ICitizen {

    uint256 public numberOfCitizens;
    address public sectorContractAddress;
    address public proposalContractAddress;

    mapping(uint256 => Citizen) public citizens;
    mapping(address => uint256) public userAddressesToIDs;
    mapping(address => mapping(uint256 => bool)) public userVotedPerProposal;

    event SectorsSelected(uint256 _citizenID, uint256 _primarySector, uint256 _secondarySector);
    event CitizenRegistered(uint256 _citizenID, uint256 _numberOfCitizens);

    constructor(address _sectorContractAddress, address _proposalContractAddress) {
        sectorContractAddress = _sectorContractAddress;
        proposalContractAddress = _proposalContractAddress;
    }

    function register(bytes32 _firstName, bytes32 _surname, uint256 _idNumber) public {

        citizens[numberOfCitizens] = Citizen({
            citizenID: _idNumber,
            salary: 0,
            taxPercentage: 0,
            primarySectorID: 0,
            secondarySectorID: 0,
            totalTaxPaid: 0,
            totalPriorityPoints: 0,
            walletAddress: msg.sender,
            firstName: _firstName,
            secondName: _surname
        });

        userAddressesToIDs[msg.sender] = _idNumber;
        numberOfCitizens++;

        emit CitizenRegistered(_idNumber, numberOfCitizens);

    }

    function selectSectors(uint256 _citizenID, uint256 _primarySectorID, uint256 _secondarySectorID) public {

        require(msg.sender == citizens[_citizenID].walletAddress, "INCORRECT PERMISSIONS");

        Sector sector = Sector(sectorContractAddress);

        require(_primarySectorID != _secondarySectorID, "SECTORS CANNOT BE THE SAME");
        require(_primarySectorID <= sector.numberOfSectors() && _secondarySectorID <= sector.numberOfSectors(), "INVALID SECTOR ID");
        
        citizens[_citizenID].primarySectorID = _primarySectorID;
        citizens[_citizenID].secondarySectorID = _secondarySectorID;

        emit SectorsSelected(_citizenID, citizens[_citizenID].primarySectorID, citizens[_citizenID].secondarySectorID);

    }

    function voteForProposal(uint256 _proposalID)
        public
    {

        uint256 citizenID = userAddressesToIDs[msg.sender];
        
        require(msg.sender == citizens[citizenID].walletAddress, "ONLY CITIZENS");
        require(userVotedPerProposal[msg.sender][_proposalID] == false, "CITIZEN ALREADY VOTED");

        require(
            proposals[_proposalID]._proposalState == ProposalState.PROPOSED,
            "PROPOSAL CLOSED"
        );

        require(
            citizens[citizenID].taxPercentage >= 0,
            "NOT A TAX PAYER"
        );

        uint256 citizenVotePower = citizens[citizenID].taxPercentage;
        userVotedPerProposal[msg.sender][_proposalID] = true;

        IProposal proposal = IProposal(proposalContractAddress);
        proposal.addVoteForProposal(_proposalID, citizenVotePower);

    }
    
}
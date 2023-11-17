// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

interface ICitizen {
    struct Citizen {
        uint256 citizenID;
        uint256 salary;
        //Stored out of 10_000 for scale
        uint256 taxPercentage;
        uint256 primarySectorID;
        uint256 secondarySectorID;
        uint256 totalTaxPaid;
        //Total taxPaid / 1000
        uint256 totalPriorityPoints;
        address walletAddress;
        bytes32 firstName;
        bytes32 secondName;
    }

    function selectSectors(
        uint256 _citizenID,
        uint256 _primarySectorID,
        uint256 _secondarySectorID
    ) external;

    function register(
        bytes32 _firstName,
        bytes32 _surnameName,
        uint256 _idNumber
    ) external;

    function voteForProposal(uint256 _proposalID) external;
}

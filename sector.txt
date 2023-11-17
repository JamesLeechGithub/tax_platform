// SPDX-License-Identifier: MIT
pragma solidity =0.8.13;

import "./interfaces/ISector.sol";
import "./Tender.sol";
import "./Governance.sol";

contract Sector is ISector {

    uint256 public numberOfSectors;
    address public governanceAddress;

    mapping(uint256 => Sector) public sectors;

    Governance public _governance;

    event SetSectorAdmin(uint256 sectorID, address newAdmin, uint256 time);
    event SectorBudgetUpdated(uint256 newBudget);


    constructor(address _governanceAddress) {
        governanceAddress = _governanceAddress;
    }

    function createSector(string memory _name) public {

        Governance governance = Governance(governanceAddress);

        require(msg.sender == governance.superAdmin(), "NOT SUPER ADMIN");

        Sector memory _sector = sectors[numberOfSectors];

       _sector.sectorID = numberOfSectors;
       _sector.numberOfTenders = 0;
       _sector.currentFunds = 0;
       _sector.budget = 0;
       _sector.budgetReached = false;
       _sector.sectorName = _name;

        numberOfSectors++;
    }

    function setSectorAdmin(uint256 _sectorID, address _newAdmin) public onlySectorAdmin(_sectorID)
    {
        require(_newAdmin != address(0), "CANNOT BE ZERO ADDRESS");
        require(msg.sender == sectors[_sectorID].sectorAdmin, "NOT SECTOR ADMIN");

        sectors[_sectorID].sectorAdmin = _newAdmin;

        emit SetSectorAdmin(_sectorID, _newAdmin, block.timestamp);
    }

    function updateSectorBudget(uint256 _sectorID, uint256 _newBudget) public onlySectorAdmin(_sectorID)
    {
        require(msg.sender == sectors[_sectorID].sectorAdmin, "NOT SECTOR ADMIN");

        sectors[_sectorID].budget = _newBudget;

        emit SectorBudgetUpdated(_newBudget);
    }

    //----------------------------------------------------------------------------------------------------------------------
    //-------------------------------------        MODIFIER       --------------------------------
    //----------------------------------------------------------------------------------------------------------------------

    modifier onlySectorAdmin(uint256 _sectorID) {
        require(msg.sender == sectors[_sectorID].sectorAdmin, "ONLY SECTOR ADMIN");
        _;
    }
}
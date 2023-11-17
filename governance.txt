// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "./interfaces/IGovernance.sol";
import "./Citizen.sol";
import "./Proposal.sol";
import "./Sector.sol";
import "./Tender.sol";
import "./TaxPayerCompany.sol";
import "./Treasury.sol";

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Governance is IGovernance, Ownable, ReentrancyGuard {
    address public superAdmin;
    address public USDAddress;
    address public treasuryAddress;

    IERC20 USDC;

    //----------------------------------------------------------------------------------------------------------------------
    //-----------------------------------------  EVENTS        ---------------------------------------
    //----------------------------------------------------------------------------------------------------------------------

    event SetSuperAdmin(
        address previousSuperAdmin,
        address newAdmin,
        uint256 time
    );
    
    event ChangeCompanyAdmin(
        uint256 companyID,
        address previousAdmin,
        address newAdmin,
        uint256 time
    );

    event TreasuryBalanceUpdated(uint256 newBalance);

    //----------------------------------------------------------------------------------------------------------------------
    //-----------------------------------------  CONSTRUCTOR        ---------------------------------------
    //----------------------------------------------------------------------------------------------------------------------

    constructor(address _USDC, address _treasuryAddress) {
        USDAddress = _USDC;
        USDC = IERC20(_USDC);
        superAdmin = msg.sender;
        treasuryAddress = _treasuryAddress;
    }

    //----------------------------------------------------------------------------------------------------------------------
    //-----------------------------------------  ACCESS FUNCTIONS       ---------------------------------------
    //----------------------------------------------------------------------------------------------------------------------

    function setSuperAdmin(address _newSuperAdmin) public onlySuperAdmin {
        require(_newSuperAdmin != address(0), "CANNOT BE ZERO ADDRESS");

        address previousSuperAdmin = superAdmin;

        superAdmin = _newSuperAdmin;

        emit SetSuperAdmin(previousSuperAdmin, superAdmin, block.timestamp);
    }

    //----------------------------------------------------------------------------------------------------------------------
    //-----------------------------------------  GENERAL FUNCTIONS       ---------------------------------------
    //----------------------------------------------------------------------------------------------------------------------

    function fundTreasury(uint256 _amount) public onlySuperAdmin nonReentrant {
        USDC.transfer(treasuryAddress, _amount);

        emit TreasuryBalanceUpdated(_amount);
    }

    //----------------------------------------------------------------------------------------------------------------------
    //-----------------------------------------  MODIFIERS        ---------------------------------------
    //----------------------------------------------------------------------------------------------------------------------

    modifier onlySuperAdmin() {
        require(msg.sender == superAdmin, "ONLY SUPER ADMIN");
        _;
    }
}

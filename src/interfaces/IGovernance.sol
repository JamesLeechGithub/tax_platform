// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

interface IGovernance {
  
  function setSuperAdmin(address _newSuperAdmin) external;

  //function changeCompanyAdmin(uint256 _companyID, address _newAdmin) external;

  function fundTreasury(uint256 _amount) external;

}
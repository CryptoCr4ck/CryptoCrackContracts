// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract crackFaucet is Ownable {
    IERC20 public CRK;
    mapping(address => bool) public claimed;

    function setCRK(address _crk) public onlyOwner {
        CRK = IERC20(_crk);
    }

    function claimYourFirstDose() public {
        require(claimed[msg.sender] == false, "already claimed");
        claimed[msg.sender] = true;
        CRK.transfer(msg.sender, 10000000000000000000);
    }
}
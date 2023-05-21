// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IcrackTool.sol";

contract cryptocrack is ERC20, Ownable {
    struct burnModifier {
        uint256 modifierPercentage;
        uint256 timeUntilOver;
    }

    mapping(address => uint256) public lastBuy;
    mapping(address => burnModifier) public burnerModifiers;
    IcrackTool public crackTool;
    address public pool;
    address public treasury;
    address public vesting;
    address public farming;
    address public nasCrack100;
    address public crackFaucet;

    event isLiquidated(address _liquidator, address _isBurned, uint amount);

    constructor(
        uint _initialsuply,
        address _crackToolAddress,
        address _treasury,
        address _vesting,
        address _nasCrack100,
        address _crackFaucet
    ) ERC20("CryptoCrack", "CRK") {
        _mint(msg.sender, _initialsuply);
        crackTool = IcrackTool(_crackToolAddress);
        treasury = _treasury;
        vesting = _vesting;
        nasCrack100 = _nasCrack100;
        crackFaucet = _crackFaucet;
    }

    function setFarm(address _farm) public onlyOwner {
        farming = _farm;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        if (lastBuy[to] == 0) {
            lastBuy[to] = block.timestamp;
        }
        if (from == pool && amount >= 1000000000000000000) {
            lastBuy[to] = block.timestamp;
        }
        if (to == pool) {
            uint toBurn = (amount * 5) / 100;
            uint toSend = amount - toBurn;
            _burn(from, toBurn);
            super._transfer(from, to, toSend);
        } else {
            super._transfer(from, to, amount);
        }
    }

    function setLpadress(address _lpaddress) public onlyOwner {
        pool = _lpaddress;
    }

    function burnTheOpps(address _addressToBurn) public {
        require(
            block.timestamp >= lastBuy[_addressToBurn] + 24 hours,
            "user not burnable"
        );
        require(
            _addressToBurn != pool &&
                _addressToBurn != treasury &&
                _addressToBurn != vesting &&
                _addressToBurn != farming &&
                _addressToBurn != crackFaucet &&
                _addressToBurn != nasCrack100,
            "protocol contract are not burnable"
        );
        uint256 balance = balanceOf(_addressToBurn);
        uint temp = balance / 2;
        if (burnerModifiers[msg.sender].timeUntilOver > block.timestamp) {
            uint256 toSend = (temp *
                (5 + burnerModifiers[msg.sender].modifierPercentage)) / 100;
            uint256 toBurn = temp - toSend;
            _burn(_addressToBurn, toBurn);
            _transfer(_addressToBurn, msg.sender, toSend);
            lastBuy[_addressToBurn] = block.timestamp;
            emit isLiquidated(msg.sender, _addressToBurn, temp);
        } else {
            uint256 toSend = (temp * 5) / 100;
            uint256 toBurn = temp - toSend;
            _burn(_addressToBurn, toBurn);
            _transfer(_addressToBurn, msg.sender, toSend);
            lastBuy[_addressToBurn] = block.timestamp;
            emit isLiquidated(msg.sender, _addressToBurn, temp);
        }
    }

    function smokeSomeCrack(uint256 _tokenId) public {
        require(
            crackTool.getApproved(_tokenId) == address(this),
            "You need to approve the contract before being allowed to smoke your crack"
        );
        require(
            crackTool.ownerOf(_tokenId) == msg.sender,
            "dont try to smoke the crack of other it's not very nice"
        );
        require(
            crackTool.toolsType(_tokenId) == 0,
            "you can only smoke crack with a crack pipe"
        );
        if (crackTool.rarity(_tokenId) == 0) {
            crackTool.burn(_tokenId);
            lastBuy[msg.sender] += 5 days;
        }
        if (crackTool.rarity(_tokenId) == 1) {
            crackTool.burn(_tokenId);
            lastBuy[msg.sender] += 3 days;
        }
        if (crackTool.rarity(_tokenId) == 2) {
            crackTool.burn(_tokenId);
            lastBuy[msg.sender] += 2 days;
        }
    }

    function loadUpYourGun(uint256 _tokenId) public {
        require(
            crackTool.getApproved(_tokenId) == address(this),
            "you need to approve the contract before being allowed to load your gun"
        );
        require(
            crackTool.ownerOf(_tokenId) == msg.sender,
            "dont try to steal the gun of other it's not very nice"
        );
        require(
            crackTool.toolsType(_tokenId) == 1,
            "you can only smoke ops with a gun"
        );
        if (crackTool.rarity(_tokenId) == 0) {
            crackTool.burn(_tokenId);
            burnerModifiers[msg.sender] = burnModifier(
                10,
                block.timestamp + 1 days
            );
        }
        if (crackTool.rarity(_tokenId) == 1) {
            crackTool.burn(_tokenId);
            burnerModifiers[msg.sender] = burnModifier(
                5,
                block.timestamp + 1 days
            );
        }
        if (crackTool.rarity(_tokenId) == 2) {
            crackTool.burn(_tokenId);
            burnerModifiers[msg.sender] = burnModifier(
                2,
                block.timestamp + 1 days
            );
        }
    }
}

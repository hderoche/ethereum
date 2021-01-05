pragma solidity ^0.7.6;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/math/SafeMath.sol";

// Setting up the allowance system
contract Allowance is Ownable {
    using SafeMath for uint;    
    mapping(address => uint) public allowance;
    
    event addAllowanceEvent(address indexed _from, address indexed _to, uint _oldAmount, uint _newAmout);
    
    modifier enoughFunds(uint _amount) {
        require(_amount <= address(this).balance, "Not enough funds in the contract");
        _;
    }
    
    modifier ownerOrAllowed(uint _amount) {
        require(isOwner() || allowance[msg.sender] >= _amount, "You are not allowed");
        _;
    }
    
    function isOwner() public view returns(bool) {
        if (msg.sender == owner()) {
            return true;
        } else {
            return false;
        }
    }
    
    function addAllowance(address _who, uint _amount) public onlyOwner {
        allowance[_who] = allowance[_who].add(_amount);
        emit addAllowanceEvent(msg.sender, _who, allowance[_who], allowance[_who].add(_amount));
    }
    
    function reduceAllowance(address _who, uint _amount) internal onlyOwner {
        allowance[_who] = allowance[_who].sub(_amount);
    }
}


// Wallet where the owner decides how much each participant can withdraw
contract SharedWallet is Allowance {
    
    event ReceiveMoney(address _from, uint _amount);
    
    receive() payable external {
        require(msg.value >= 0);
        emit ReceiveMoney(msg.sender, msg.value);
    }
    
    fallback() external {
        
    }
    
    event Withdraw(address _to, uint _amount);
    
    function withdrawMoney(address payable _to, uint _amount) public payable onlyOwner ownerOrAllowed(_amount) enoughFunds(_amount) {
        if(msg.sender != _to) {
            reduceAllowance(_to, _amount);
        }
        _to.transfer(_amount);
        emit Withdraw(_to, _amount);
    }
}
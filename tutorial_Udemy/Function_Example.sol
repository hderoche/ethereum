pragma solidity ^0.5.13;

contract FunctionExample {
    
    mapping(address => uint) public balanceReceived;
    
    address payable owner;
    
    constructor() public {
        owner = msg.sender;
    }
    
    function destroy() public {
        require(msg.sender == owner, "you are not the owner");
        selfdestruct(owner);
    }
    
    
    /*View function can access the reading state meaning it can access the stored variables */
    function getOwner() public view returns(address) {
        return owner;
    }
    
    /*Don't use the stored variables 
        Here : balanceReceived and owner
        
        Pure function can call another pure function but not a view function
    */
    function convertWeiToEther(uint _amountInWei) public pure returns(uint) {
        return _amountInWei / 1 ether;
    }
    
    function receiveMoney() public payable {
        assert(balanceReceived[msg.sender] + msg.value >= balanceReceived[msg.sender]);
        balanceReceived[msg.sender] += msg.value;
    }
    
    function withdrawMoney(address payable _to, uint _amount) public {
        require(_amount <= balanceReceived[msg.sender], "not enough funds");
        assert(balanceReceived[msg.sender] >= balanceReceived[msg.sender] - _amount);
        balanceReceived[msg.sender] -= _amount;
        _to.transfer(_amount);
    }
    
    function () external payable {
        receiveMoney();
    }
}
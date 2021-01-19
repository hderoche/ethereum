pragma solidity ^0.7.6;

import "./ItemManager.sol";

contract Item {
    uint public priceInWei;
    uint public PricePaid;
    uint public index;
    
    ItemManager parentContract;
    
    constructor(ItemManager _parentContract, uint _priceInWei, uint _index) {
        priceInWei = _priceInWei;
        index = _index;
        parentContract = _parentContract;
    }
    
    receive() external payable {
        require(PricePaid == 0, "Item is paid already");
        require(priceInWei == msg.value, "Only full payment allowed");
        PricePaid += msg.value;
        (bool success, ) = address(parentContract).call{value:msg.value}(abi.encodeWithSignature("triggerPayment(uint256)", index));
        require(success, "The transaction was not successfull, canceling");
    }
    fallback() external {}
}
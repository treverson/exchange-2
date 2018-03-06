pragma solidity ^0.4.19;

contract owned {
    address owner;

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function owned() {
        owner = msg.sender;
    }
}

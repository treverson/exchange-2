pragma solidity ^0.4.19;

contract Owned {
    address owner;

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function Owned() {
        owner = msg.sender;
    }
}

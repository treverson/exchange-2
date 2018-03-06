pragma solidity ^0.4.19;

import "./owned.sol";
import "./JotaliToken.sol";

contract JotaliExchange is owned{

    function JotaliExchange() {

    }

    // General Structure
    struct Offer {

    }

    struct OrderBook {

    }

    struct Token {

    }

    //Support a max of 255 tokens.
    mapping (uint8 => Token) tokens;
    uint symbolNameIndex;

    // Balances

    mapping (address => mapping (uint8 => uint)) tokenBalanceForAddress;

    mapping (address => uint) balanceEthForAddress;

    // Ether Deposit and Withdrawal

    function depositEther() payable {

    }

    function withdrawEther(uint amountInWei) {

    }

    function getEtherBalanceInWei() constant returns (uint) {

    }

    // Token Management

    function addToken(string symbolName, address erc20TokenAddress) onlyOwner {

    }

    function hasToken(string symbolName) constant returns (bool) {

    }

    function getSymbolIndex(string symbolName) internal returns (uint8) {

    }

    // Order Book - Bid Orders

    function getBuyOrderBook(string symbolName) constant returns (uint[], uint[]) {

    }

    // Order Book - Ask Orders

    function getSellOrderBook(string symbolName) constant returns (uint[], uint[]) {

    }

    // New Order - Bid Order

    function buyToken(string symbolName, uint priceInWei, uint amount) {

    }

    // New Order - Ask Order

    function sellToken(string symbolName, uint priceInWei, uint amount) {

    }

    // Cancel Limit Order Logic

    function cancelOrder(string symbolName, bool isSellOrder, uint priceInWei, uint offerKey) {

    }

}

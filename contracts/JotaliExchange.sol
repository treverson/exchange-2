pragma solidity ^0.4.19;

import "./JotaliToken.sol";

contract JotaliExchange {

    function JotaliExchange() {

    }

    // General Structure
    struct Offer {
      uint amount;
      address who;
    }

    struct OrderBook {
        uint higherPrice;
        uint lowerPrice;

        mapping (uint => Offer) offers;

        uint offers_key;
        uint offers_length;
    }

    struct Token {
      address tokenContract;
      string symbolName;

      mapping (uint => OrderBook) buyBook;

      uint currentBuyprice;
      uint lowestBuyPrice;
      uint amountBuyPrice;

      mapping (uint => OrderBook) sellBook;

      uint currentSellPrice;
      uint highestSellPrice;
      uint amountSellPrice;
    }

    //Support a max of 255 tokens.
    mapping (uint8 => Token) tokens;
    uint8 symbolNameIndex;

    // Balances
    mapping (address => mapping (uint8 => uint)) tokenBalanceForAddress;

    mapping (address => uint) balanceEthForAddress;

    // Events for Deposit/Withdrawal
    event DepositForTokenReceived(address indexed _from, uint indexed _symbolIndex, uint _amount, uint _timestamp);
    event WithdrawalToken(address indexed _to, uint indexed _symbolIndex, uint _amount, uint _timestamp );
    event DepositForEthReceived(address indexed _from, uint _amount, uint _timestamp);
    event WithdrawalEth(address indexed _to, uint _amount, uint _timestamp);

    // Events for Orders
    event LimitSellOrderCreated(uint indexed _symbolIndex, address indexed _who, uint _amountTokens, uint _priceInWei, uint _orderKey);
    event SellOrderFulfilled(uint indexed _symbolIndex, uint _amount, uing _priceInWei, uint _orderKey);
    event SellOrderCanceled(uint indexed _symbolIndex, uint _priceInWei, uint _orderkey);
    event LimitBuyOrderCreated(uint indexed _symbolIndex, address indexed _who, uint _amountTokens, uint _priceWei, uint _orderKey);
    event BuyOrderFulfilled(uint indexed _symbolindex, uint _amoutn, uint _priceInWei, uint _orderKey);
    event BuyOrderCanceled(uint indexed _symbolIndex, uint _priceInWei, uint _orderKey);

    // Events for Management
    event TokenAddedToSystem(uint _symbolIndex, string _token, uint _timestamp);

    // Ether Deposit and Withdrawal
    function depositEther() payable {
      require(balanceEthForAddress[msg.sender] + msg.value >= balanceEthForAddress[msg.sender]);
      balanceEthForAddress[msg.sender] += msg.value;
      DepositForEthReceived(msg.sender, msg.value, now);
    }

    function withdrawEther(uint amountInWei) {
      require(balanceEthForAddress[msg.sender] - amountInWei >= 0);
      require(balanceEthForAddress[msg.sender] - amountInWei <= balanceEthForAddress[msg.sender]);
      balanceEthForAddress[msg.sender] -= amountInWei;
      msg.sender.transfer(amountInWei);
      WithdrawalEth(msg.sender, amountInWei, now);
    }

    function getEtherBalanceInWei() constant returns (uint) {
      return balanceEthForAddress[msg.sender];
    }

    // Token Management
    function addToken(string symbolName, address erc20TokenAddress) {
      require(!hasToken(symbolName));
      symbolNameIndex++;
      tokens[symbolNameIndex].symbolName = symbolName;
      tokens[symbolNameIndex].tokenContract = erc20TokenAddress;
    }

    function hasToken(string symbolName) constant returns (bool) {
      uint8 index = getSymbolIndex(symbolName);
      if (index == 0) {
        return false;
      }
      return true;
    }

    function getSymbolIndex(string symbolName) internal returns (uint8) {
      for (uint8 i = 1; i <= symbolNameIndex; i++) {
        if (stringsEqual(tokens[i].symbolName, symbolName)) {
          return i;
        }
      }
      return 0;
    }

    // String Comparison Function
    function stringsEqual(string storage _a, string memory _b) internal returns (bool) {
      bytes storage a = bytes(_a);
      bytes memory b = bytes(_b);
      if (a.length != b.length)
        return false;
      // @todo unroll the loop
      for (uint i = 0; i < a.length; i ++)
        if (a[i] != b[i])
          return false;
        return true;
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

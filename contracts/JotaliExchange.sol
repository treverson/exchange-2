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
      uint amountBuyPrices;

      mapping (uint => OrderBook) sellBook;

      uint currentSellPrice;
      uint highestSellPrice;
      uint amountSellPrices;
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
    event SellOrderFulfilled(uint indexed _symbolIndex, uint _amount, uint _priceInWei, uint _orderKey);
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
      TokenAddedToSystem(symbolNameIndex, symbolName, now);

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

    function getSymbolIndexOrThrow(string symbolName) returns (uint8) {
      uint8 index = getSymbolIndex(symbolName);
      require(index > 0);
      return index;
    }

    // Deposit and Withdraw Token
    function depositToken(string symbolName, uint amount) {
      uint8 symbolNameIndex = getSymbolIndexOrThrow(symbolName);
      require(tokens[symbolNameIndex].tokenContract != address(0));

      ERC20Interface token = ERC20Interface(tokens[symbolNameIndex].tokenContract);

      require(token.transferFrom(msg.sender, address(this), amount) == true);
      require(tokenBalanceForAddress[msg.sender][symbolNameIndex] + amount >= tokenBalanceForAddress[msg.sender][symbolNameIndex]);
      tokenBalanceForAddress[msg.sender][symbolNameIndex] += amount;
      DepositForTokenReceived(msg.sender, symbolNameIndex, amount, now);
    }

    function withdrawToken(string symbolName, uint amount) {
      uint symbolNameIndex = getSymbolIndexOrThrow(symbolName);
      require(tokens[symbolNameIndex].tokenContract != address(0));

      ERC20Interface token = ERC20Interface(tokens[symbolNameIndex].tokenContract);

      require(tokenBalanceAddress[msg.sender][symbolNameIndex] - amount >= 0);
      require(tokenBalanceForAddress[msg.sender][symbolNameIndex] - amount <= tokenBalanceForAddress[msg.sender][symbolNameIndex]);

      tokenBalanceForAddress[msg.sender][symbolNameIndex] -= amount;
      require(token.transfer(msg.sender, amount) == true);
      WithdrawalToken(msg.sender, symbolNameIndex, amount, now);
    }

    function getBalance(string symbolName) constant returns (uint) {
      uint8 symbolNameIndex = getSymbolIndexOrThrow(symbolName);
      return tokenBalanceForAddress[msg.sender][symbolNameIndex];
    }

    // Order Book - Bid Orders
    function getBuyOrderBook(string symbolName) constant returns (uint[], uint[]) {

    }

    // Order Book - Ask Orders
    function getSellOrderBook(string symbolName) constant returns (uint[], uint[]) {

    }

    // New Order - Bid Order
    function buyToken(string symbolName, uint priceInWei, uint amount) {
      uint8 tokenNameindex = getSymbolIndexOrThrow(symbolName);
      uint total_amount_ether_necessary = 0;
      uint total_amount_ether_available = 0;

      total_amount_ether_necessary = amount * priceInWei;

      require(total_amount_ether_necessary >= amount);
      require(total_amount_ether_necessary >= priceInWei);
      require(balanceEthForAddress[msg.sender] >= total_amount_ether_necessary);
      require(balanceEthForAddress[msg.sender] - total_amount_ether_necessary >= 0);

      balanceEthForAddress[msg.sender] -= total_amount_ether_necessary;

      if (tokens[tokenNameindex].amountSellPrices  == 0 || tokens[tokensNameindex].currentSellprice > priceInWei) {
        addBuyOffer(tokenNameindex, priceInWei, amount, msg.sender);
        LimitBuyOrderCreated(tokenNameindex, msg.sender, amount, priceInWei, tokens[tokenNameindex].buyBook[priceInWei].offers_length);
      } else {
        revert();
      }
    }

    // Bid Limit order Logic
    function addBuyOffer(uint8 tokenIndex, uint priceInWei, uint amount, address who) internal {
      tokens[tokenIndex].buyBook[priceInWei].offers_length++;
      tokens[tokenIndex].buyBook[priceInWei].offers[tokensIndex].buyBook[priceInWei].offer_length = Offer(amount, who);

      if (tokens[tokenIndex].buyBook[priceInWei].offer_length == 1) {
        tokens[tokenIndex].buyBook[priceInWei].offers_key = 1;
        tokens[tokenIndex].amountBuyPrices++;

        uint currentBuyPrice = tokens[tokenIndex].currentBuyPrice ;

        uint lowestBuyPrice = tokens[tokenIndex].lowestBuyPrice;
        if (lowestBuyPrice == 0 || lowestBuyPrice > priceInWei) {
          if (currentBuyPrice == 0) {
            tokens[tokenIndex].currentBuyprice = priceInWei;
            tokens[tokenIndex].buyBook[priceInWei].higherPrice = priceInWei;
            tokens[tokenIndex].buyBook[priceInWei].lowerPrice = 0;
          } else {
            tokens[tokenIndex].buyBook[lowestBuyPrice].lowerPrice = priceInWei;
            tokens[tokenIndex].buyBook[priceInWei].higherPrice = lowestBuyPrice;
            tokens[tokenIndex].buyBook[priceInWei].lowerPrice = 0;
          }
          tokens[tokenindex].lowestBuyPrice = priceInWei;
        }
        else if (currentBuyPrice < priceInWei) {
          tokens[tokenIndex].buyBook[currentBuyPrice].higherPrice = priceInWei;
          tokens[tokenIndex].buyBook[priceInWei].higherPrice = priceInWei;
          tokens[tokenIndex].buyBook[priceInWei].lowerPrice = currentBuyPrice;
          tokens[tokenIndex].currentBuyprice = priceInWei;
        }
      }
      else {
        uint buyPrice = token[tokenIndex].currentBuyPrice;
        bool weFoundIt = false;
        while (buyPrice > 0 && !weFoundIt) {
          if (
          buyPrice< priceInWei &&
          tokens[tokenIndex].buyBook[buyPrice].higherPrice > priceInWei
          ) {
              tokens[tokenIndex].buyBook[priceInWei].lowerPrice = buyPrice;
              tokens[tokenIndex].buyBook[priceInWei].higherPrice = tokens[tokenIndex].buyBook[buyPrice].higherPrice;

              tokens[tokenIndex].buyBook[tokens[tokenIndex].buyBook[buyPrice].higherPrice].lowerPrice = priceInWei;
              tokens[tokenIndex].buyBook[buyPrice].higherPrice = priceInWei;

              weFoundIt = true;
          }
          buyPrice = tokens[tokenIndex].buyBook[buyPrice].lowerPrice;
        }
      }
    }

    // Ask Limit Order Logic



    // New Order - Ask Order
    function sellToken(string symbolName, uint priceInWei, uint amount) {
      uint8 tokenNameIndex = getSymbolIndexOrThrow(symbolName);
      uint total_amount_ether_necessary = 0;
      uint total_amount_ether_available = 0;

      total_amount_ether_necessary =amount * priceInWei;

      require(total_amount_ether_necessary >= amount);
      require(total_amount_ether_necessary >= priceInWei);
      require(tokenBalanceForAddress[msg.sender][tokenNameIndex] >= amount);
      require(tokenBalanceForAddress[msg.sender][tokenNameIndex] - amount >= 0);
      require(balanceEthForAddress[msg.sender] + total_amount_ether_necessary >= balanceEthForAddress[msg.sender]);

      tokenBalanceForAddress[msg.sender][tokenNameIndex] -= amount;

      if (tokens[tokenNameIndex].amountBuyPrices == 0 || tokens[tokenNameIndex].currentBuyprice < priceInWei) {

        addSellOffer(tokenNameIndex, priceInWei, amount, msg.sender);

        LimitSellOrderCreated(tokenNameIndex, msg.sender, amount, priceInWei, tokens[tokenNameIndex].sellBook[priceInWei].offers_length);
      } else {
        revert();
      }

    }

    // Ask Limit Order Logic
    function addSellOffer(uint tokenIndex, uint priceInWei, uint amount, address who) internal {
      tokens[tokenIndex].sellBook[priceInWei].offers_length++;
      tokens[tokenIndex].sellBook[priceInWei].offers[tokens[tokenIndex].sellBoook[priceInWei].offers_length] = Offer(amount, who);

      if (tokens[tokenIndex].sellBook[priceInWei].offers_length == 1) {
        tokens[tokenIndex].sellBook[priceInWei].offer_key = 1;

        tokens[tokenIndex].amountSellPrices++;

        uint highSellPrice = tokens[tokenIndex].highestSellPrice;
        if (highSellPrice == 0 || highSellPrice < priceInWei) {
          if (currentSellPrice == 0) {
            tokens[tokenIndex].currentSellPrice = priceInWei;
            tokens[tokenIndex].sellBook[priceInWei].higherPrice = 0;
            tokens[tokenIndex].sellBook[priceInWei].lowerPrice = 0;
          } else {
            tokens[tokenIndex].sellBook[highSellPrice].higherPrice = priceInWei;
            tokens[tokenIndex].sellBook[priceInWei].lowerPrice = highestSellPrice;
            tokens[tokenIndex].sellBook[priceInWei].higherPrice = 0;
          }
          tokens[tokenIndex].highestSellPrice = priceInWei;
        }
      }
      else if (currentSellPrice > priceInWei) {
        uint sellPrice = tokens[tokenIndex].currentSellPrice;
        bool weFoundIt = false;
        while (sellPrice > 0 && !weFoundIt) {
          if (
            sellPrice < priceInWei &&
            tokens[tokenIndex].sellBook[sellPrice].higherPrice > priceInWei
            ) {
              tokens[tokenIndex].sellBook[priceInWei].lowerPrice = sellPrice;
              tokens[tokenIndex].sellBook[priceInWei].higherPrice = tokens[tokenIndex].sellBook[sellPrice].higherPrice;
              tokens[tokenIndex].sellBook[tokens[tokenIndex].sellBook[sellPrice].higherPrice].lowerPrice = priceInWei;
              tokens[tokenIndex].sellBook[sellPrice].higherPrice = priceInWei;
              weFoundIt = true;
            }
            sellPrice = tokens[tokenIndex].sellBook[sellPrice].higherPrice = priceInWei;
        }
      }
    }

    // Cancel Limit Order Logic
    function cancelOrder(string symbolName, bool isSellOrder, uint priceInWei, uint offerKey) {
      uint symbolNameIndex = getSymbolIndexOrThrow(symbolName);

      if (isSellOrder) {
        require(tokens[symbolNameIndex].sellBook[priceInWei].offers[offerKey].who = msg.sender);

        uint tokensAmount = tokens[symbolNameIndex].sellBook[priceInWei].offers[offerKey].amount;
        require(tokenBalanceForAddress[msg.sender][symbolNameIndex] + tokensAmount >= tokenBalanceForAddress[msg.sender][symbolNameIndex]);

        tokenBalanceForAddress[msg.sender][symbolNameIndex] += tokensAmount;
        tokens[symbolNameIndex].sellBook[priceInWei].offers[offerKey].amount = 0;
        SellOrderCanceled(symbolNameIndex, priceInWei, offerKey);
      }
      else {
        require(tokens[symbolNameIndex].buyBook[priceInWei].offers[offerKey].who == msg.sender);
        uint etherToRefund = tokens[symbolNameIndex].buyBook[priceInWei].offers[offerKey].amount * priceInWei;

        balanceEthForAddress[msg.sender] += etherToRefund;
        tokens[symbolNameIndex].buyBook[priceInWei].offers[offerKey].amount = 0;
        BuyOrderCanceled(symbolNameIndex, priceInWei, offerKey);
      }

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

}

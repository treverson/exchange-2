pragma solidity ^0.4.21;

import './ERC20Interface.sol'

contract JotaliExchange is ERC20Interface {

  function constructor() public {
  }

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

    uint currentBuyPrice;
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

  mapping (address => mapping (uint8 => uint)) tokenBalanceForAddress;

  mapping (address => uint) balanceEthForAddress;

  event DepositForTokenReceived(address indexed _from, uint indexed _symbolIndex, uint _amount, uint _timestamp);
  event WithdrawalToken(address indexed _to, uint indexed _symbolIndex, uint _amount, uint _timestamp );
  event DepositForEthReceived(address indexed _from, uint _amount, uint _timestamp);
  event WithdrawalEth(address indexed _to, uint _amount, uint _timestamp);

  event LimitSellOrderCreated(uint indexed _symbolIndex, address indexed _who, uint _amountTokens, uint _priceInWei, uint _orderKey);
  event SellOrderFulfilled(uint indexed _symbolIndex, uint _amount, uint _priceInWei, uint _orderKey);
  event SellOrderCanceled(uint indexed _symbolIndex, uint _priceInWei, uint _orderkey);
  event LimitBuyOrderCreated(uint indexed _symbolIndex, address indexed _who, uint _amountTokens, uint _priceWei, uint _orderKey);
  event BuyOrderFulfilled(uint indexed _symbolindex, uint _amoutn, uint _priceInWei, uint _orderKey);
  event BuyOrderCanceled(uint indexed _symbolIndex, uint _priceInWei, uint _orderKey);

  event TokenAddedToSystem(uint _symbolIndex, string _token, uint _timestamp);

  function depositEther() public payable {
    require(balanceEthForAddress[msg.sender] + msg.value >= balanceEthForAddress[msg.sender]);

    balanceEthForAddress[msg.sender] += msg.value;
    emit DepositForEthReceived(msg.sender, msg.value, now);
  }

  function withdrawEther(uint amountInWei) public {
    require(balanceEthForAddress[msg.sender] - amountInWei >= 0);
    require(balanceEthForAddress[msg.sender] - amountInWei <= balanceEthForAddress[msg.sender]);

    balanceEthForAddress[msg.sender] -= amountInWei;
    msg.sender.transfer(amountInWei);
    emit WithdrawalEth(msg.sender, amountInWei, now);
  }

  function getEtherBalanceInWei() public constant returns (uint) {
    return balanceEthForAddress[msg.sender];
  }

  function addToken(string symbolName, address erc20TokenAddress) public {
    require(!hasToken(symbolName));

    symbolNameIndex++;
    tokens[symbolNameIndex].symbolName = symbolName;
    tokens[symbolNameIndex].tokenContract = erc20TokenAddress;
    emit TokenAddedToSystem(symbolNameIndex, symbolName, now);

  }

  function hasToken(string symbolName) public constant returns (bool) {
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

  function getSymbolIndexOrThrow(string symbolName) public returns (uint8) {
    uint8 index = getSymbolIndex(symbolName);
    require(index > 0);
    return index;
  }

  function depositToken(string symbolName, uint amount) public {
    symbolNameIndex = getSymbolIndexOrThrow(symbolName);
    require(tokens[symbolNameIndex].tokenContract != address(0));

    ERC20Interface token = ERC20Interface(tokens[symbolNameIndex].tokenContract);

    require(token.transferFrom(msg.sender, address(this), amount) == true);
    require(tokenBalanceForAddress[msg.sender][symbolNameIndex] + amount >= tokenBalanceForAddress[msg.sender][symbolNameIndex]);

    tokenBalanceForAddress[msg.sender][symbolNameIndex] += amount;
    emit DepositForTokenReceived(msg.sender, symbolNameIndex, amount, now);
  }

  function withdrawToken(string symbolName, uint amount) public {
    symbolNameIndex = getSymbolIndexOrThrow(symbolName);
    require(tokens[symbolNameIndex].tokenContract != address(0));

    ERC20Interface token = ERC20Interface(tokens[symbolNameIndex].tokenContract);

    require(tokenBalanceForAddress[msg.sender][symbolNameIndex] - amount >= 0);
    require(tokenBalanceForAddress[msg.sender][symbolNameIndex] - amount <= tokenBalanceForAddress[msg.sender][symbolNameIndex]);

    tokenBalanceForAddress[msg.sender][symbolNameIndex] -= amount;
    require(token.transfer(msg.sender, amount) == true);
    emit WithdrawalToken(msg.sender, symbolNameIndex, amount, now);
  }

  function getBalance(string symbolName) public returns (uint){
    symbolNameIndex = getSymbolIndexOrThrow(symbolName);
    return tokenBalanceForAddress[msg.sender][symbolNameIndex];
  }

//   function getBuyOrderBook(string symbolName) constant returns (uint[], uint[]) {

//   }

//   function getSellOrderBook(string symbolName) constant returns (uint[], uint[]) {

//   }

  function buyToken(string symbolName, uint priceInWei, uint amount) public {
    uint8 tokenNameIndex = getSymbolIndexOrThrow(symbolName);
    uint total_amount_ether_necessary = 0;

    total_amount_ether_necessary = amount * priceInWei;

    require(total_amount_ether_necessary >= amount);
    require(total_amount_ether_necessary >= priceInWei);
    require(balanceEthForAddress[msg.sender] >= total_amount_ether_necessary);
    require(balanceEthForAddress[msg.sender] - total_amount_ether_necessary >= 0);

    balanceEthForAddress[msg.sender] -= total_amount_ether_necessary;

    if (tokens[tokenNameIndex].amountSellPrices  == 0 || tokens[tokenNameIndex].currentSellPrice > priceInWei) {
      addBuyOffer(tokenNameIndex, priceInWei, amount, msg.sender);
      emit LimitBuyOrderCreated(tokenNameIndex, msg.sender, amount, priceInWei, tokens[tokenNameIndex].buyBook[priceInWei].offers_length);
    } else {
      revert();
    }
  }

  function addBuyOffer(uint8 tokenIndex, uint priceInWei, uint amount, address who) internal {
    tokens[tokenIndex].buyBook[priceInWei].offers_length++;
    tokens[tokenIndex].buyBook[priceInWei].offers[tokens[tokenIndex].buyBook[priceInWei].offers_length] = Offer(amount, who);

    if (tokens[tokenIndex].buyBook[priceInWei].offers_length == 1) {
      tokens[tokenIndex].buyBook[priceInWei].offers_key = 1;
      tokens[tokenIndex].amountBuyPrices++;

      uint currentBuyPrice = tokens[tokenIndex].currentBuyPrice;

      uint lowestBuyPrice = tokens[tokenIndex].lowestBuyPrice;
      if (lowestBuyPrice == 0 || lowestBuyPrice > priceInWei) {
        if (currentBuyPrice == 0) {
          tokens[tokenIndex].currentBuyPrice = priceInWei;
          tokens[tokenIndex].buyBook[priceInWei].higherPrice = priceInWei;
          tokens[tokenIndex].buyBook[priceInWei].lowerPrice = 0;
        } else {
          tokens[tokenIndex].buyBook[lowestBuyPrice].lowerPrice = priceInWei;
          tokens[tokenIndex].buyBook[priceInWei].higherPrice = lowestBuyPrice;
          tokens[tokenIndex].buyBook[priceInWei].lowerPrice = 0;
        }
        tokens[tokenIndex].lowestBuyPrice = priceInWei;
      }
      else if (currentBuyPrice < priceInWei) {
        tokens[tokenIndex].buyBook[currentBuyPrice].higherPrice = priceInWei;
        tokens[tokenIndex].buyBook[priceInWei].higherPrice = priceInWei;
        tokens[tokenIndex].buyBook[priceInWei].lowerPrice = currentBuyPrice;
        tokens[tokenIndex].currentBuyPrice = priceInWei;
      }
    }
    else {
      uint buyPrice = tokens[tokenIndex].currentBuyPrice;
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

  function sellToken(string symbolName, uint priceInWei, uint amount) public {
    uint8 tokenNameIndex = getSymbolIndexOrThrow(symbolName);
    uint total_amount_ether_necessary = 0;

    total_amount_ether_necessary = amount * priceInWei;

    require(total_amount_ether_necessary >= amount);
    require(total_amount_ether_necessary >= priceInWei);
    require(tokenBalanceForAddress[msg.sender][tokenNameIndex] >= amount);
    require(tokenBalanceForAddress[msg.sender][tokenNameIndex] - amount >= 0);
    require(balanceEthForAddress[msg.sender] + total_amount_ether_necessary >= balanceEthForAddress[msg.sender]);

    tokenBalanceForAddress[msg.sender][tokenNameIndex] -= amount;

    if (tokens[tokenNameIndex].amountBuyPrices == 0 || tokens[tokenNameIndex].currentBuyPrice < priceInWei) {

      addSellOffer(tokenNameIndex, priceInWei, amount, msg.sender);

      emit LimitSellOrderCreated(tokenNameIndex, msg.sender, amount, priceInWei, tokens[tokenNameIndex].sellBook[priceInWei].offers_length);
    } else {
      revert();
    }

  }

  function addSellOffer(uint8 tokenIndex, uint priceInWei, uint amount, address who) internal {
    tokens[tokenIndex].sellBook[priceInWei].offers_length++;
    tokens[tokenIndex].sellBook[priceInWei].offers[tokens[tokenIndex].sellBook[priceInWei].offers_length] = Offer(amount, who);

    if (tokens[tokenIndex].sellBook[priceInWei].offers_length == 1) {
      tokens[tokenIndex].sellBook[priceInWei].offers_key = 1;

      tokens[tokenIndex].amountSellPrices++;

      uint highSellPrice = tokens[tokenIndex].highestSellPrice;
      if (highSellPrice == 0 || highSellPrice < priceInWei) {
        if (tokens[tokenIndex].currentSellPrice == 0) {
          tokens[tokenIndex].currentSellPrice = priceInWei;
          tokens[tokenIndex].sellBook[priceInWei].higherPrice = 0;
          tokens[tokenIndex].sellBook[priceInWei].lowerPrice = 0;
        } else {
          tokens[tokenIndex].sellBook[highSellPrice].higherPrice = priceInWei;
          tokens[tokenIndex].sellBook[priceInWei].lowerPrice = tokens[tokenIndex].highestSellPrice;
          tokens[tokenIndex].sellBook[priceInWei].higherPrice = 0;
        }
        tokens[tokenIndex].highestSellPrice = priceInWei;
      }
    }
    else if (tokens[tokenIndex].currentSellPrice > priceInWei) {
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

  function cancelOrder(string symbolName, bool isSellOrder, uint priceInWei, uint offerKey) public {
    symbolNameIndex = getSymbolIndexOrThrow(symbolName);

    if (isSellOrder) {
      require(tokens[symbolNameIndex].sellBook[priceInWei].offers[offerKey].who == msg.sender);

      uint tokensAmount = tokens[symbolNameIndex].sellBook[priceInWei].offers[offerKey].amount;
      require(tokenBalanceForAddress[msg.sender][symbolNameIndex] + tokensAmount >= tokenBalanceForAddress[msg.sender][symbolNameIndex]);

      tokenBalanceForAddress[msg.sender][symbolNameIndex] += tokensAmount;
      tokens[symbolNameIndex].sellBook[priceInWei].offers[offerKey].amount = 0;
      emit SellOrderCanceled(symbolNameIndex, priceInWei, offerKey);
    }
    else {
      require(tokens[symbolNameIndex].buyBook[priceInWei].offers[offerKey].who == msg.sender);

      uint etherToRefund = tokens[symbolNameIndex].buyBook[priceInWei].offers[offerKey].amount * priceInWei;

      balanceEthForAddress[msg.sender] += etherToRefund;
      tokens[symbolNameIndex].buyBook[priceInWei].offers[offerKey].amount = 0;
      emit BuyOrderCanceled(symbolNameIndex, priceInWei, offerKey);
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

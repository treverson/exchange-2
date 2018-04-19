pragma solidity ^0.4.21;

// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/issues/20
contract ERC20Interface {
  // Get the total token supply
  function totalSupply() constant returns (uint256 totalSupply);

  // Get the account balance of another account with address _owner
  function balanceOf(address _owner) constant returns (uint256 balance);

  // Send _value amount of tokens to address _to
  function transfer(address _to, uint256 _value) returns (bool success);

  // Send _value amount of tokens from address _from to address _to
  function transferFrom(address _from, address _to, uint256 _value) returns (bool success);

  // Allow _spender to withdraw from your account, multiple times, up to the _value amount.
  // If this function is called again it overwrites the current allowance with _value.
  // this function is required for some DEX functionality
  function approve(address _spender, uint256 _value) returns (bool success);

  // Returns the amount which _spender is still allowed to withdraw from _owner
  function allowance(address _owner, address _spender) constant returns (uint256 remaining);

  // Triggered when tokens are transferred.
  event Transfer(address indexed _from, address indexed _to, uint256 _value);

  // Triggered whenever approve(address _spender, uint256 _value) is called.
  event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

import "zeppelin-solidity/contracts/math/SafeMath.sol";
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
import "zeppelin-solidity/contracts/token/ERC20/StandardToken.sol";

contract JotaliToken is Ownable, ERC20Interface, StandardToken {
  using SafeMath for uint256;

  string public constant name = "JTL Token";
  string public constant symbol = "JTL";
  uint8 public constant decimals = 8;

  mapping(address => uint256) balances;

  mapping(address => mapping (address => uint256)) allowed;

  uint internal totalSupply_;
  uint public INITIAL_SUPPLY;

  event Transfer(address indexed from, address indexed to, uint tokens);
  event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
  event OwnershipTransferred(address indexed from, address indexed to);

  function constructor() public {
    INITIAL_SUPPLY = 100000000000000000;
    balances[msg.sender] = INITIAL_SUPPLY;
    totalSupply_ = INITIAL_SUPPLY;

    emit Transfer(address(0), owner, totalSupply_);
  }

  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

  function balanceOf(address tokenOwner) public view returns (uint256 balance) {
    return balances[tokenOwner];
  }

  function allowance(address tokenOwner, address spender) public view returns (uint remaining) {
    return allowed[tokenOwner][spender];
  }

  function approve(address spender, uint tokens) public returns (bool success) {
    allowed[msg.sender][spender] = tokens;
    emit Approval(msg.sender, spender, tokens);
    success = true;
  }

  function transfer(address to, uint tokens) public returns (bool success) {
    require(to != address(0));
    require(tokens <= balances[msg.sender]);

    balances[msg.sender] = balances[msg.sender].sub(tokens);
    balances[to] = balances[to].add(tokens);
    emit Transfer(msg.sender, to, tokens);
    success = true;
  }

  function transferFrom(address from, address to, uint tokens) public returns (bool success) {
    require(to != address(0));
    require(tokens <= balances[from]);
    require(tokens <= allowed[from][msg.sender]);

    balances[from] = balances[from].sub(tokens);
    allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
    balances[to] = balances[to].add(tokens);
    emit Transfer(from, to, tokens);
    success = true;
  }

  function () public payable {
    revert();
  }

}

pragma solidity 0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";

contract Vendor is Ownable {

  uint256 public constant tokensPerEth = 100;


  YourToken yourToken;

  constructor(address tokenAddress) public {
    yourToken = YourToken(tokenAddress);
  }


  // ToDo: create a payable buyTokens() function:
  function buyTokens() public payable {
    uint result = msg.value * 100;
    yourToken.transfer(msg.sender, result);
    emit BuyTokens(msg.sender, msg.value, result);
  }

  // ToDo: create a withdraw() function that lets the owner withdraw ETH
  function withdraw() public payable {
    require(msg.sender == owner(), "You must be the owner to withdraw");
    payable(msg.sender).transfer(address(this).balance);
  }
  

  // ToDo: create a sellTokens() function:
  
  event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);
}

pragma solidity >=0.6.0 <0.7.0;

contract ExampleExternalContract {

  bool public completed;
  address payable testAccountAddress = 0xC061379C6b397c7Bbe8a31Ab62e6C1f45b3ace3B;

  function complete() public payable {
    completed = true;
  }

  function reset(address payable clearer) public {
    // clearer.transfer(address(this).balance);
    testAccountAddress.transfer(address(this).balance);
    completed = false;
  }

  function isComplete() public returns (bool) {
    return completed;
  }

}

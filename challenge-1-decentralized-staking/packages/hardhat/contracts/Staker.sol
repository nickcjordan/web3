pragma solidity >=0.6.0 <0.7.0;

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract Staker {
  string public debug = "";
  // uint256 public deadline = now + 600000 seconds;
  uint256 public deadline = now + 60 seconds;
  mapping ( address => uint256 ) public balances;
  uint256 public constant threshold = 0.001 ether;
  bool public openForWithdraw = false;

  bool public contractComplete = false;

  ExampleExternalContract public exampleExternalContract;

  constructor(address exampleExternalContractAddress) public {
      exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
  }

  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  //  ( make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )
  function stake() public payable {
    if (contractComplete) {
      debug = "Contract complete!";
      revert("Contract complete! No more stake is being accepted. Your eth and any remaining gas will be reverted.");
    } else if (timeLeft() == 0) {
      debug = "Deadline has passed!";
      contractComplete = true;
      revert("Deadline has passed! No more stake is being accepted. Your eth and any remaining gas will be reverted.");
    } else {
      debug = "";
      console.log("INSIDE STAKE: %s", msg.value);
      uint256 current = balances[msg.sender];
      balances[msg.sender] = current + msg.value;
      if (address(this).balance >= threshold) {
        exampleExternalContract.complete{value: address(this).balance}();
        contractComplete = true;
        debug = "Contract complete! No more stake is being accepted.";
      }
      emit Stake(msg.sender, msg.value);
    }
  }

  receive() external payable {
    console.log("START RECEIVE: ", msg.value);
    if (timeLeft() == 0 || address(this).balance >= threshold) {
      contractComplete = true;
    }
    if (contractComplete == true) {
      console.log("CONTRACT COMPLETE");
      debug = "Contract complete! No more stake is being accepted.";
      revert("Contract complete! No more stake is being accepted. Your eth and any remaining gas will be reverted.");
    } else if (contractComplete == false) {
      console.log("CALLING STAKE");
      stake();
    }
    console.log("END RECEIVE: ", msg.value);
  }

  event Stake(address who, uint amount);

  function resetContractDeadline() public {
    deadline = now + 60 seconds;
    contractComplete = false;
    openForWithdraw = false;
    debug = "";
  }

  function resetContractCompletion() public {
    deadline = now + 60 seconds;
    contractComplete = false;
    openForWithdraw = false;
    exampleExternalContract.reset(msg.sender);
    balances[msg.sender] = 0;
    debug = "";
  }

  function debugMessage() public view returns (string memory) {
    return debug;
  }

  function execute() public notCompleted {
    // if (!contractComplete) {
      if (address(this).balance >= threshold) {
        exampleExternalContract.complete{value: address(this).balance}();
        debug = "Contract complete!";
        contractComplete = true;
      } else if (timeLeft() == 0) {
        openForWithdraw = true;
        contractComplete = true;
        uint val = balances[msg.sender];
        if (val > 0) {
          debug = "The deadline has expired, the eth threshold was not met. Please withdraw your funds.";
        } else {
          debug = "The deadline has expired, the eth threshold was not met.";
        }
      } else {
        debug = "";
        // revert("Nothing to execute, please wait until the deadline has passed and try again");
      }
    // } else {
    //   revert("Contract has completed, nothing to execute");
    // }
  }

  function timeLeft() public view returns (uint256) {
    return now >= deadline ? 0 : deadline - now;
  }

  function withdraw(address payable toAddress) public notCompleted {
    if (openForWithdraw) {
      uint amountToWithdraw = balances[toAddress];
      balances[toAddress] = 0;
      if (amountToWithdraw > 0) {
        toAddress.transfer(amountToWithdraw);
      } else {
        debug = "There are no funds to withdraw for this address.";
        revert("There are no funds to withdraw for this address");
      }
    } else {
      if (timeLeft() > 0) {
        debug = "Please wait until the deadline before attempting to withdraw funds";
        revert("Please wait until the deadline before attempting to withdraw funds");
      } else {
        debug = "Threshold was met before deadline! You can not withdraw your funds.";
        revert("Threshold was met before deadline! You can not withdraw your funds.");
      }
    }
  }

  modifier notCompleted() {
    if (exampleExternalContract.isComplete()) {
      debug = "Contract has completed successfully. No more actions can be taken.";
      revert("Contract has completed successfully. No more actions can be taken.");
    } else {
      _;
    }
  }

}

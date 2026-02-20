// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract ETHReceiver{

     event Received(address indexed sender, uint256 amount, bytes data);
     event Deposit(address indexed user, uint256 amount);

     mapping(address => uint256) public balances;
    
    receive() external payable {
        emit Received(msg.sender, msg.value, "");
    }

    fallback() external payable {
        emit Received(msg.sender, msg.value, msg.data);
    }

    function sendViaTransfer(address payable to ) external payable {
        to.transfer(msg.value);
    }

    function sendViaSend(address payable to ) external payable returns (bool){
        return to.send(msg.value);
    }

    function sendViaCall(address payable to ) external payable returns (bool ok, bytes memory data){
        (ok,data) = to.call{value: msg.value}("");
    }

    function deposit() external payable {
        balances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

   
}   
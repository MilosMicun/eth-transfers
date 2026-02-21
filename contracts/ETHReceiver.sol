// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

error InsufficientBalance(uint256 requested, uint256 available);
error EthTransferFailed(address to, uint256 amount);

contract ETHReceiver{

     event Received(address indexed sender, uint256 amount, bytes data);
     event Deposit(address indexed user, uint256 amount);
     event Withdraw(address indexed user, uint256 amount);
     event InternalTransfer(address indexed from, address indexed to, uint256 amount);

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

    function withdraw(uint256 amount) external {
        uint256 bal = balances[msg.sender];
        if(bal < amount) revert InsufficientBalance(amount, bal);

        balances[msg.sender]= bal - amount;

        // interactions
        (bool ok,) = payable(msg.sender).call{value: amount}("");
        if(!ok) revert EthTransferFailed(msg.sender, amount);

        emit Withdraw(msg.sender, amount);

    }

    function withdrawAll() external {
        uint256 bal = balances[msg.sender];
        if(bal == 0) revert InsufficientBalance(0,0);

        balances[msg.sender] = 0;

        (bool ok,) = payable(msg.sender).call{value: bal}("");
        if(!ok) revert EthTransferFailed(msg.sender, bal);

        emit Withdraw(msg.sender, bal);
    }

    function balanceOF(address user) external view returns (uint256){
        return balances[user];
    }

   
}   
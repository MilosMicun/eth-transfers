# ETH Transfers — Solidity Native Value Flow

This project demonstrates how Ethereum smart contracts receive, route, account for, and safely send native ETH.

It covers the complete ETH entry and exit lifecycle using Solidity primitives and execution patterns that preserve accounting integrity.

Built with Hardhat and execution-focused tests.

---

## Overview

Ethereum transactions contain two independent components:

value → ETH being transferred  
data → instructions for contract execution  

The EVM routes execution based on calldata (`msg.data`) and transfers ETH based on value (`msg.value`).

This contract demonstrates how contracts correctly handle ETH entry, internal accounting, and protocol-safe exit.

---

## Execution Entry Points

### receive()

Executed when ETH is sent with empty calldata.

Condition:


msg.data.length == 0


Use case: plain ETH transfer.

Example:

```js
await signer.sendTransaction({
  to: contract,
  value: ethers.parseEther("1")
})

Effect:

contract receives ETH

Received event emitted

no internal accounting update

fallback()

Executed when calldata exists but does not match any function selector.

Condition:

msg.data.length > 0
AND
no matching function

Use case: low-level calls, unknown selectors, proxy routing.

Example:

await signer.sendTransaction({
  to: contract,
  value: ethers.parseEther("1"),
  data: "0x1234"
})

Effect:

contract receives ETH

Received event emitted

calldata captured

deposit()

Explicit accounting entry point.

balances[msg.sender] += msg.value;

Use case:

vault deposits

staking deposits

protocol accounting

Effect:

contract receives ETH

internal ownership tracked

Deposit event emitted

ETH Exit Patterns

The contract demonstrates three ETH sending mechanisms:

transfer (legacy)
to.transfer(amount);

fixed gas stipend (2300)

may fail under modern gas costs

discouraged in modern protocols

send (legacy)
to.send(amount);

returns boolean instead of reverting

same gas limitation

discouraged in modern protocols

call (modern standard)
(bool ok,) = to.call{value: amount}("");

forwards configurable gas

compatible with all contract receivers

current recommended approach

Used by modern protocols (Uniswap, OpenZeppelin, etc.).

Withdraw Pattern (Protocol-Safe Exit)

The contract implements a safe withdraw mechanism using the Checks-Effects-Interactions pattern.

Execution order:

Validate balance

Update internal accounting

Transfer ETH using call

Example:

function withdraw(uint256 amount) external {
    uint256 bal = balances[msg.sender];
    if (bal < amount) revert InsufficientBalance(amount, bal);

    balances[msg.sender] = bal - amount;

    (bool ok, ) = payable(msg.sender).call{value: amount}("");
    if (!ok) revert EthTransferFailed(msg.sender, amount);

    emit Withdraw(msg.sender, amount);
}

Security invariant:

Internal state is updated before external interaction.

This guarantees accounting correctness and prevents inconsistent state transitions.

Full Exit: withdrawAll()

Allows a user to exit completely in a single call.

balances[msg.sender] = 0;

(bool ok, ) = payable(msg.sender).call{value: bal}("");

This pattern is commonly used in:

vault exits

staking withdrawals

escrow refunds

It ensures deterministic state reset.

Storage Model

The contract demonstrates separation between protocol balance and internal accounting:

address(this).balance  → total ETH held by contract (protocol-level)
balances[user]         → internal ownership accounting (contract-level)

Ethereum tracks total value.

Contracts must track ownership explicitly.

Tests

Tests verify all execution paths:

receive() executes on plain ETH transfer

fallback() executes when calldata exists

deposit() updates internal balances

withdraw() transfers ETH safely

withdrawAll() resets balance correctly

events emitted correctly

accounting integrity preserved

Run tests:

npx hardhat test
Project Structure
contracts/
  ETHReceiver.sol

test/
  ETHReceiver.test.js

hardhat.config.js
package.json
Key Concepts Demonstrated

ETH value flow vs calldata routing

receive vs fallback execution model

payable function accounting

contract balance vs user balance

ETH transfer mechanisms (transfer, send, call)

secure withdraw using Checks-Effects-Interactions pattern

event-driven auditability

protocol-grade accounting integrity

Why This Matters

All Ethereum protocols rely on these primitives:

vaults

staking contracts

bridges

multisig wallets

treasuries

Correct ETH handling and safe withdrawal patterns are foundational to protocol security.
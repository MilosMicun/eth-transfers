# ETH Transfers — Solidity Native Value Flow

This project demonstrates how Ethereum smart contracts receive, route, account for, and send native ETH.

It covers the complete ETH entry and exit lifecycle using Solidity primitives and tests that prove execution behavior.

Built with Hardhat and execution-focused tests.

---

## Overview

Ethereum transactions contain two independent components:


value → ETH being transferred
data → instructions for contract execution


The EVM routes execution based on calldata (`msg.data`) and transfers ETH based on value (`msg.value`).

This contract demonstrates how contracts handle both correctly.

---

## Execution Entry Points

### receive()

Executed when ETH is sent with empty calldata.


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

balances[msg.sender] += msg.value

Use case: vault deposits, staking, protocol accounting.

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

event-driven auditability

protocol-grade testing

Why This Matters

All Ethereum protocols rely on these primitives:

vaults

staking contracts

bridges

multisig wallets

treasuries

Correct ETH handling is foundational to protocol safety.
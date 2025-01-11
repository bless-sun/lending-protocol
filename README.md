# Decentralized Lending Protocol

A secure and efficient lending protocol built on Stacks that enables sBTC-collateralized loans with robust liquidation mechanisms.

## Overview

This smart contract implements a decentralized lending protocol that allows users to:

- Deposit sBTC as collateral
- Borrow against their collateral
- Repay loans
- Participate in liquidations of under-collateralized positions

## Key Features

- **Secure Collateralization**: Maintains a minimum collateralization ratio of 150%
- **Flexible Interest Rates**: Configurable interest rates between 1% and 100%
- **Liquidation Mechanism**: Automated liquidation process with reward incentives
- **Safety Controls**: Emergency pause functionality and adjustable risk parameters

## Protocol Parameters

| Parameter                 | Value     | Description                       |
| ------------------------- | --------- | --------------------------------- |
| Minimum Collateral Ratio  | 150%      | Required collateral-to-loan ratio |
| Interest Rate Range       | 1% - 100% | Configurable borrowing rate       |
| Liquidation Threshold     | 70% - 95% | Trigger point for liquidations    |
| Maximum Reward Multiplier | 120%      | Liquidation reward ceiling        |

## Core Functions

### Depositing Collateral

```clarity
(deposit-collateral (token-contract <sip-010-trait>) (amount uint))
```

Allows users to deposit sBTC as collateral into the protocol.

### Borrowing

```clarity
(borrow (token-contract <sip-010-trait>) (amount uint))
```

Enables borrowing against deposited collateral, maintaining the minimum collateralization ratio.

### Loan Repayment

```clarity
(repay (token-contract <sip-010-trait>) (amount uint))
```

Allows borrowers to repay their outstanding loans.

### Liquidation

```clarity
(liquidate (token-contract <sip-010-trait>) (user principal) (amount uint))
```

Permits liquidators to close under-collateralized positions and earn rewards.

## Administrative Functions

### Interest Rate Management

```clarity
(set-interest-rate (new-rate uint))
```

Allows the contract owner to adjust the protocol's interest rate within defined bounds.

### Risk Parameters

```clarity
(set-liquidation-threshold (new-threshold uint))
```

Enables adjustment of the liquidation threshold to manage protocol risk.

### Emergency Controls

```clarity
(pause-protocol)
(unpause-protocol)
```

Emergency functions to pause and resume protocol operations.

## Error Codes

| Code | Description             |
| ---- | ----------------------- |
| u100 | Not authorized          |
| u101 | Insufficient balance    |
| u102 | Insufficient collateral |
| u103 | Invalid amount          |
| u104 | Already initialized     |
| u105 | Not initialized         |
| u106 | Liquidation failed      |

## Safety Mechanisms

1. **Overflow Protection**

   - Safe arithmetic operations for all numerical calculations
   - Strict validation of input amounts

2. **Access Control**

   - Owner-only administrative functions
   - Validated token contract interactions

3. **Risk Management**
   - Configurable liquidation thresholds
   - Maximum limits on rewards and interest rates
   - Emergency pause functionality

## Read-Only Functions

### User Information

```clarity
(get-user-deposits (user principal))
(get-user-borrows (user principal))
```

Query functions for user positions and balances.

### Protocol Statistics

```clarity
(get-protocol-stats)
```

Retrieves current protocol metrics including total deposits, borrows, and interest rate.

## Liquidation Mechanism

The protocol implements a fair liquidation system:

- Positions become eligible for liquidation when they fall below the liquidation threshold
- Liquidators receive a reward of up to 5% above the liquidated amount
- Maximum reward capped at 50% of the collateral value
- Rewards can be claimed through the `claim-rewards` function

## Security Considerations

1. **Collateral Safety**

   - All collateral operations require valid token contract verification
   - Strict collateralization requirements prevent under-collateralized borrowing

2. **Access Controls**

   - Administrative functions restricted to contract owner
   - Token contract validation on all operations

3. **Economic Security**
   - Bounded parameters prevent extreme protocol settings
   - Liquidation incentives aligned with protocol health

## Development and Testing

To interact with this contract:

1. Deploy the contract to the Stacks network
2. Initialize with a valid sBTC token contract
3. Users can begin depositing collateral and borrowing
4. Monitor positions to maintain healthy collateralization ratios

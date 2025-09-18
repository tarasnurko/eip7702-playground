# EIP-7702 Playground

This repository contains simple contracts, tests and scripts to test and understand EIP-7702.

## Result

Actors:

Alice - EoA that delegated authority to a contract
Bob - EoA
ContractA - delegate contract of Alice
ContractB - regular contract

After examining different scenarios, I can conclude that:

- tx.origin is always initiator of transaction
- address(this) in delegate contract is the address of delegator (EoA), independent of who called it (1\*)
- msg.sender of delegate contract is the one (EoA) who called it (2)
- msg.sender when delegate contract calls other contract is the address of delegator (EoA) (2\*)
- any 3rd party can call EoA as delegate contract (if they have one) and make transactions on their behalf (previous point)

## Diagrams

1\*)

```
Alice           ->            ContractA (Alice's delegate)
                |
        address(this) = Alice


Bob             ->            ContractA (Alice's delegate)
                |
        address(this) = Alice
```

2\*)

```
Alice      ->       ContractA (Alice's delegate)      ->       ContractB
           |                                          |
    msg.sender = Alice                       msg.sender = Alice

Bob        ->       ContractA (Alice's delegate)      ->       ContractB
           |                                          |
    msg.sender = Bob                           msg.sender = Alice
```

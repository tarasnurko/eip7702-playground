# EIP-7702 Playground

This repository contains simple contracts, tests and scripts to test and understand EIP-7702.

## Result

Actors:

Alice - EoA that delegated authority to a contract
Bob - EoA
ContractA - delegate contract of Alice
ContractB - regular contract

Conclusions:

- tx.origin is always initiator of transaction
- address(this) in delegate contract is the address of delegator (EoA), independent of who called it (1\*)
- msg.sender of delegate contract is the one (EoA) who called it (2)
- msg.sender when delegate contract calls other contract is the address of delegator (EoA) (2\*)
- any 3rd party can call EoA as delegate contract (if they have one) and make transactions on their behalf (previous point)
- EoA can not delegate authority to a single transaction
- when EoA delegates autority to a contract, this delegation exists until explicitly removed (set to address(0))
- delegated execution changes EoA storage, not contract's
- after EoA delegated authority, it can still send regular transactions (e.i send ETH or directly call other contracts)
- when EoA delegates authority to a contract, it's `codehash` is not empty and `code` points to delegate contract (0xef0100 || address)

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

// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

// Dry-run and dev-inspect must summarize created and unwrapped objects from simulated
// outputs rather than persistent storage. Both must leave the wrapped parent unchanged
// so that subsequent committed execution can still unwrap its child.

//# init --addresses test=0x0 --accounts A

//# publish --sender A
module test::m;
public struct First has key, store { id: UID, value: u64 }
public struct Second has key, store { id: UID, value: u64 }
public struct Parent has key, store { id: UID, child: First }
public fun create(ctx: &mut TxContext) {
    let second = Second { id: object::new(ctx), value: 2 };
    let first = First { id: object::new(ctx), value: 1 };
    transfer::public_transfer(second, ctx.sender());
    transfer::public_transfer(first, ctx.sender())
}
public fun make_wrapped(ctx: &mut TxContext) {
    let child = First { id: object::new(ctx), value: 7 };
    transfer::public_transfer(Parent { id: object::new(ctx), child }, ctx.sender())
}
public fun unwrap(parent: Parent, ctx: &mut TxContext) {
    let Parent { id, child } = parent;
    object::delete(id);
    transfer::public_transfer(child, ctx.sender())
}

//# run test::m::make_wrapped --sender A

//# programmable --sender A --dev-inspect
// Created objects must be summarized from simulated outputs, not persistent storage.
//> test::m::create();

//# programmable --sender A --dry-run
// Dry-run must use the same output-object path for multiple created objects.
//> test::m::create();

//# programmable --sender A --dev-inspect --inputs object(2,0)
// The unwrapped child also exists only in simulated output storage.
//> test::m::unwrap(Input(0));

//# view-object 2,0
// Dev-inspect did not delete the parent or unwrap its child in persistent storage.

//# programmable --sender A --dry-run --inputs object(2,0)
// The same parent is still available; use the simulated unwrapped object's output version.
//> test::m::unwrap(Input(0));

//# view-object 2,0
// Dry-run also left the parent and its wrapped child unchanged.

//# run test::m::unwrap --sender A --args object(2,0)
// Committed execution can still unwrap the object after both simulations.

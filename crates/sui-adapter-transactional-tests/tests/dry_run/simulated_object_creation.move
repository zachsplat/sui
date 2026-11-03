// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

// Dry-run and dev-inspect must assign stable fake IDs to simulated creations without
// reading them from persistent storage. Each PTB creates two coins so the sorting key
// is evaluated, exercising the regression that previously caused a missing-object panic.

//# init --accounts A

//# programmable --sender A --dry-run --inputs 1u64 @A
// Two created objects force fake-ID sorting to read the unpersisted simulation outputs.
//> 0: SplitCoins(Gas, [Input(0), Input(0)]);
//> TransferObjects([NestedResult(0,0), NestedResult(0,1)], Input(1));

//# programmable --sender A --dev-inspect --inputs 1u64 @A
// Dev-inspect must also use the returned objects instead of persistent storage.
//> 0: SplitCoins(Gas, [Input(0), Input(0)]);
//> TransferObjects([NestedResult(0,0), NestedResult(0,1)], Input(1));

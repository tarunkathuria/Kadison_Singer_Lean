# Kadison–Singer: full-cube walk and polynomial runtime

This is a standalone Lean repository. All local project proof dependencies are copied here; no sibling repository or original workspace is needed. Lean 4.24.0 and mathlib are restored from the pinned toolchain and dependency manifest.

## Current theorem and computational scope

For any original complex vectors `v_i` with `sum_i v_i v_i* = I` and `||v_i||² ≤ ε`, the convex-value-query implementation returns signs on every original label with Euclidean operator discrepancy at most

`9 (16 sqrt(2) + 5) sqrt(ε)`.

With `r` retries its actual output is present with probability at least `1 - (15/56)^r`, and every returned signing satisfies the bound. **Total arithmetic cost is polynomial in the original label count, dimension, and `r`**. The input-only bounds cover the actual derivative budgets, reciprocal query tolerances, step size, finite horizon, numerical preparation, updates, acceptance, and inspected retries. The final theorem has no supplied descent, success, Taylor-budget, or iteration-count assumption. Zero dimension and zero labels are included where compatible with the input assumptions.

The model is exact real-RAM arithmetic including square root, finite fair random draws, and the explicitly permitted `KSPolynomialConvexSolver.PolynomialSolver` contract for the directly constructed polynomial-size convex program. Program construction and requested accuracies are counted and bounded. Solver internals, bit complexity, random-bit generation, floating-point correctness, and extracted machine code are outside this model. All concrete numerical queries use real scalars; complex analytic extensions appear only in derivative proofs.

- Combined correctness, probability, and runtime theorem: [`KSFullPolynomialExplicit.algorithm`](MatrixSpencer/KSFullPolynomialExplicit.lean).
- Formal multivariate-polynomial cost certificate: [`KSFullRuntimePolynomialCertificate.totalCost_polynomial`](MatrixSpencer/KSFullRuntimePolynomialCertificate.lean).
- Exact model, polynomial formulas, and implementation changes: [POLYNOMIAL_RUNTIME.md](POLYNOMIAL_RUNTIME.md).
- The default `MatrixSpencer.lean` entry imports the runtime certificate and the earlier main walk and Weaver endpoints.

## Preserved proof variants and original Weaver statement

The earlier literal finite value implementation remains in `KSExplicitWalkAlgorithm`, with the same signing constant and retry success bound. Its projected-gradient value approximation and finite Jacobi Hessian calculations have correctness proofs; the total polynomial-runtime result above instead uses the proved convex-value implementation. [WALK_PROOF.md](WALK_PROOF.md) describes that earlier numerical variant and retains its historical runtime scope.

The separate manuscript algorithm and its original Weaver wrapper are also included: `KSFullManuscriptExplicit` and `KSFullManuscriptWeaver`. See [MANUSCRIPT_ALGORITHM.md](MANUSCRIPT_ALGORITHM.md) and [MANUSCRIPT_WEAVER.md](MANUSCRIPT_WEAVER.md) for their exact interfaces and verification.

Weaver's original KS2 existential-constants statement is formalized in `KSExplicitWeaver` with nonsharp constants `η = 1048576` and `θ = 262144`: vectors of norm at most one with constant unit-direction energy `η` admit a partition with energy at most `η - θ` in each part. The actual earlier walk and its output probability are stated in those original terms as well. The compact-minimum existence proof with smaller normalized signing constant `16 sqrt(2) + 2` remains unchanged as `kadison_singer_spin_mixed`; that smaller constant is not attributed to the numerical walk.

## Verify the complete current snapshot

```sh
python3 tools/verify_current_snapshot.py
```

This cumulative checker covers **every shipped local proof module**, including the default entry, retained algorithm variants, and optional shared SDP-size endpoints. It checks all current source hashes, repeats the endpoint and independent primitive statement probes, rejects admissions and custom axioms, and replays the entire local declaration graph into an environment containing external libraries only. The current inputs are fixed in `CURRENT_SNAPSHOT_MANIFEST_20260911.json`; successful runs write `CURRENT_SNAPSHOT_VERIFICATION_20260911.json` and preserve their logs under `provenance/current_snapshot_20260911/`.

The completed cumulative receipt covers **380 proof modules plus the entry wrapper**, **10,407 declaration records**, and **20 endpoint axiom probes**, together with the retained walk/manuscript route checks.

The earlier manifests were preserved under `provenance/pre_sdp_sync_20260911/` before their current copies received the updated default-entry hash. No earlier proof source or verification receipt was changed. Earlier runtime and walk receipts continue to describe their own snapshots; the cumulative receipt checks the current combined source distribution.

## Compile and verify

Install elan, put `lake` on PATH, and install Python 3. From this repository root:

```sh
./run_lake.sh exe cache get
./run_lake.sh build
./verify.sh
python3 tools/verify_polynomial_runtime.py
```

The first verifier checks the preserved existence and literal walk/Weaver endpoints. The second separately checks the complete polynomial-runtime extension, including its source manifest, endpoint statements, transitive axioms, and full local-closure kernel replay. Its September 11 receipt covers **370 modules and 10,211 declaration records** and is recorded in `POLYNOMIAL_RUNTIME_VERIFICATION_20260911.json`. The only permitted axioms are `propext`, `Classical.choice`, and `Quot.sound`; admissions are rejected.

Replay uses the installed Lean kernel, starting from external libraries for the runtime closure. It is not an independent kernel implementation or a reconstruction of all mathlib from primitives. Fresh logs and receipts go under `.verification/`. Earlier manifests and receipts retain their stated earlier scopes; current distribution verification is recorded separately.

Keep all **380 local proof modules**, the root entry, `tools/`, checkers, launchers, documentation, manifests, and pinned configuration. Shared foundations are deliberately duplicated. Do not ship `.lake/`, `.cache/`, `.verification/`, installed toolchains, or `__pycache__/`. Historical source and packaging records remain under `provenance/`.

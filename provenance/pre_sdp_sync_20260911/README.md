# Kadison–Singer: full-cube numerical walk

This is a standalone Lean repository. All project proof sources are copied here; no sibling repository or original workspace is needed. Mathlib is restored from the pinned dependency manifest.

For any complex vectors `v_i` with `sum_i v_i v_i* = I` and `||v_i||² ≤ ε`, the finite numerical walk returns signs on every original label with Euclidean operator discrepancy at most

`9 (16 sqrt(2) + 5) sqrt(ε)`.

One attempt succeeds with probability at least `41/56`. With `r` independent retries, the probability that the actual output is present is at least `1 - (15/56)^r`. Every returned output satisfies the stated signing and norm conditions. The proof includes numerical value and Hessian query accuracy, legal sticky updates, expected progress, finite cutoff, and the actual output probability. It has no supplied descent, termination, derivative-bound, or signing hypothesis.

The original Weaver KS2 formulation is formalized with the explicit constants `η = 1048576` and `θ = 262144`: unit-norm-bounded vectors with constant unit-direction energy `η` admit a partition whose energy in each part is at most `η - θ`. This is Weaver's existential-constants conjecture, with nonsharp constants. The algorithm and its output probability are also stated in these original unit-energy terms. The existence wrappers include zero-dimensional and zero-error cases.

- Actual walk: `MatrixSpencer.KSExplicitWalkAlgorithm`.
- Original Weaver statement and algorithm: `MatrixSpencer.KSExplicitWeaver`.
- Independent primitive statement checks: `tools/WalkIndependentStatements.lean`.
- Actual numerical proof-route checks: `tools/WalkRoutes.lean`.
- Detailed algorithm and manuscript comparison: `WALK_PROOF.md`.

The formalized finite numerical variant uses projected-gradient value approximation and finite Jacobi Hessian calculations. Its constants are conservative. Polynomial runtime and bit complexity are not formalized. The mathematical exact-real definitions are noncomputable in Lean; this repository does not supply extracted executable code or a floating-point implementation. All concrete numerical queries are real. Complex analytic extensions are used only in derivative-bound proofs.

The earlier compact-minimum existence proof, with the smaller constant `16 sqrt(2) + 2`, is retained as `MatrixSpencer.kadison_singer_spin_mixed`. Its source has not changed. The walk's success proof is checked separately and does not use that signing conclusion.

## Compile and verify

Install elan and put `lake` on PATH. Python 3 is needed for the verifier. `lean-toolchain` selects Lean 4.24.0; `lake-manifest.json` pins mathlib and its dependencies.

```sh
./run_lake.sh exe cache get
./run_lake.sh build
./verify.sh
```

`verify.sh` checks both the retained existence theorem and the actual walk/Weaver endpoint. It must finish with `VERIFIED` and exit zero. It checks independently written theorem types, transitive axioms, source admissions, numerical proof dependencies, and replays every local proof module through the installed Lean kernel against its imports. Only `propext`, `Classical.choice`, and `Quot.sound` are allowed. Replay does not use an independent kernel implementation or rebuild all of mathlib from primitives.

The verifier reads ordinary shipped files under `tools/` and the source manifest. It does not require historical hidden verification directories. Fresh receipts and logs go under `.verification/`. `VERIFICATION.json` records the completed packaging check, when available; historical receipts under `provenance/` have their original narrower scope.

Keep all shipped files, including the 208 local proof modules, Python checkers, `tools/`, launchers, and configuration. Caches, installed toolchains, and `.verification/` are excluded from the source distribution. `SOURCE_MANIFEST.json` records the proof and verification input hashes. The September 9 snapshot documentation and manifests remain under `provenance/`; they describe that earlier snapshot.

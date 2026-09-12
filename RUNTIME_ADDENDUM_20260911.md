# KS runtime addendum — 11 September 2026

This additive supplement preserves the existing algorithm, Weaver, and verification files.
It adds `MatrixSpencer/KSManuscriptScaleBounds.lean` and the source audit in
[provenance/runtime_addendum_20260911/KS_MANUSCRIPT_RUNTIME_AUDIT_20260911.md](provenance/runtime_addendum_20260911/KS_MANUSCRIPT_RUNTIME_AUDIT_20260911.md).

For the actual maximum atom size ε and positive physical dimension, the new module
proves from Parseval that `ε⁻¹ ≤ N`, `(sqrt ε)⁻¹ ≤ N`, and the fixed regularizer's
inverse is at most `2N`. It does not assume a minimum individual vector size or
source eigenvalue. Both existing KS manuscript algorithms already have their
actual finite success and full-signing correctness proofs.

The user permits polynomial-time solution of polynomial-size convex programs.
Remaining whole-runtime formalization consists of polynomial bounds for the
actual source/derivative budgets, inverse numerical tolerances and cutoffs,
then composition of the total sampled-path operation cost. This supplement
is not a whole-walk polynomial-runtime theorem or extracted executable.

The new module's six declarations were replayed through the installed Lean
kernel in the main project. Its 138 project dependencies match the already
verified KS bases and this standalone folder byte for byte. The standalone
new-module build and six standard-axiom checks are recorded in the accompanying
addendum manifest and provenance. No whole-base closure replay was repeated.

To rebuild just the supplement with an installed Lean 4.24 toolchain:

```sh
./run_lake.sh build MatrixSpencer.KSManuscriptScaleBounds
./run_lake.sh env lean provenance/runtime_addendum_20260911/ScaleAxioms.lean
```

`RUNTIME_ADDENDUM_MANIFEST_20260911.json` covers only these additive files and
records that pre-existing shipped files were preserved. Existing manifests,
checksums, README files and verification receipts retain their prior scope.

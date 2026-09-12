# KS input-budget supplement — 11 September 2026

This adds the verified `MatrixSpencer/KSManuscriptInputBudgetBounds.lean`
without changing prior sources, notes, checkers, manifests or receipts.
The detailed proof note and verification evidence are in
[provenance/input_budgets_20260911](provenance/input_budgets_20260911/KS_MANUSCRIPT_INPUT_BUDGET_BOUNDS_20260911.md).

From Parseval alone, the exact existing input budgets satisfy:

- physical atom budget ≤ `1+2N` and signed slope budget ≤ `1+3N`;
- Pauli budget ≤ `1+1152N`;
- full-cube source budget ≤ `1+23040dN`;
- eighth-cube source budget ≤ `1+20480dN`;
- eighth center/direction caps ≤ `3+9N` and `2+6N`.

At the actual positive-dimensional input scales, the full-cube center
radius is ≤ `4+4N` and its joint center cap is ≤ `6+10N`. No minimum
nonzero vector size or source eigenvalue is assumed.

This advances the center/source size obligations listed in the preceding
runtime audit. Bounds for the full fourth-derivative budget, inverse
tolerances, cutoffs and total operation cost remain to be assembled;
no whole-algorithm polynomial-runtime theorem is claimed.

All 30 new declarations passed a selected replay through the installed Lean
kernel in the main project, and nine public bounds passed standard-axiom
checks. The 225 project dependencies match the verified bases. The accompanying
`INPUT_BUDGETS_MANIFEST_20260911.json` records matching standalone sources,
a successful new-module build and axiom probe, and preservation of old files.
No whole-base replay is repeated by this supplement.

To rebuild only the new module with Lean 4.24 installed:

```sh
./run_lake.sh build MatrixSpencer.KSManuscriptInputBudgetBounds
./run_lake.sh env lean provenance/input_budgets_20260911/Axioms.lean
```

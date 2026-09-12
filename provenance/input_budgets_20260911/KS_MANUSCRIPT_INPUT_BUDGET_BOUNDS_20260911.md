# Exact KS input-budget bounds — 11 September 2026

This additive proof closes the entry/Frobenius-budget part of the runtime
audit. It does not change any frozen endpoint, audit note or package manifest.

`MatrixSpencer/KSManuscriptInputBudgetBounds.lean` proves the following
upper bounds for the **actual existing arithmetic budget definitions**, from
`sum_i v_i v_i* = I` alone. Here there are `N` original vectors in complex
dimension `d`; these statements also cover zero dimensions.

| Existing input budget | Proved upper bound | New theorem |
|---|---:|---|
| `KSDebitUniformFloor.atomBudget` | `1+2N` | `atomBudget_le` |
| `KSComplexPolynomialBounds.slopeBudget` | `1+3N` | `slopeBudget_le` |
| `KSDebitUniformFloor.spinBudget` | `1+1152N` | `spinBudget_le` |
| `KSComplexPolynomialBounds.sourceBudget` | `1+23040dN` | `sourceBudget_le` |
| `KSEighthInputTaylorBound.sourceCap` | `1+20480dN` | `eighth_sourceCap_le` |
| `KSEighthInputTaylorBound.centerCap` | `3+9N` | `eighth_centerCap_le` |
| `KSEighthInputTaylorBound.directionCap` | `2+6N` | `eighth_directionCap_le` |

For positive `d`, the actual scales `δ=sqrt(epsilon v)` and `η=δ/N`
further give `KSDebitUniformFloor.centerRadius ≤ 4+4N` and
`KSJointBoundParameters.centerCap ≤ 6+10N`
(`actual_centerRadius_le`, `actual_full_centerCap_le`). Their scalar
premises are discharged using Parseval and the actual maximum preprocessing.
The more general intermediate center bounds explicitly require `δ≤1`
and `Nη≤1`; those are not extra premises of the actual-input corollaries.

The proof uses the exact identity
`matrixEnergy(atom v) = norm(atom v)^2` (line 39), derived from the rank-one
square and trace identities. Parseval bounds each atom norm by one. The
signed, doubled and all four actual Pauli lifts have twice the Frobenius
energy; a single independent sign block has the original energy.
Consequently `matrixBound(atom)≤2`, all the former lifts have
`matrixBound≤3`, and the independent blocks have `matrixBound≤2`.
Counting their original labels yields the displayed constants. There is
no minimum-vector-size, source-conditioning or derivative-bound hypothesis.

This is a parameter bound, not a whole-walk runtime theorem. The remaining
size calculation can now substitute these inequalities and the previously
proved reciprocal scale bounds into the explicit density-floor, analytic
radius, joint derivative and fourth-derivative formulas, then bound inverse
meshes, cutoffs and total operation counts. No such subsequent theorem is
claimed here.

Verification evidence is in
`.verification/ks_manuscript_input_budgets_20260911/`: a targeted module
build, nine endpoint standard-axiom reports, and a selected replay of every
new declaration through the installed Lean kernel against verified imports.
The 225 existing project dependency sources are checked against the frozen
KS manuscript receipts and the preceding scale-bound incremental receipt.
This is not a fresh replay of mathlib or an independent kernel implementation.

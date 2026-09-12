# KS polynomial runtime extension — September 11, 2026

Both normalized Weaver signing walks now have end-to-end Lean theorems combining the actual output, its signing quality, its success probability, and total polynomial arithmetic cost. The new algorithms use the explicitly permitted polynomial convex solver for their value queries. The previous literal finite value implementations and their correctness proofs are preserved.

For an original complex-vector family with `sum_i v_i v_i* = I` and `||v_i v_i*|| ≤ ε`, every returned output assigns a sign to every original label. The formalized norm is the Euclidean operator norm.

| Route | Signing discrepancy | Success after r trials | All-dimensional endpoint |
|---|---|---|---|
| Full cube | `9 (16 sqrt 2 + 5) sqrt ε` | at least `1-(15/56)^r` | `KSFullPolynomialExplicit.algorithm` |
| Eighth cube | `512 sqrt ε` | at least `1-2^(-r)` | `KSEighthPolynomialExplicit.algorithm` |

All trajectories satisfy the corresponding cube/sticky constraints. Dimension zero returns the all-positive signing before scalar setup. Zero original labels are retained in the new variants. The random model is a fair coin for the full walk and a uniform live-coordinate/sign draw for the eighth walk. The number of these draws is bounded separately; random-bit generation and finite-precision arithmetic are outside this exact real-RAM model. Real arithmetic includes square root. The formalized execution relations evaluate a selected online path and do not construct the exponentially large probability tree. These are execution/cost proofs, not extracted machine code.

## Proved parameter bounds

Let `N` be the original number of labels, `d` the complex physical dimension, `S = 100000 (N+d+1)`, and `B = S^275`. For positive dimension, the actual maximum atom size is positive and the actual full and eighth fourth-derivative budgets are at most `B`. These are bounds on the defined input-dependent quantities, not supplied derivative hypotheses.

The actual full movement step `h` satisfies

`h^(-2) ≤ 16 N² + 100 N² B`,

and the actual full horizon is at most

`256 N³ + 100 N³ B + 1`.

For the actual eighth movement step and horizon the respective bounds are

`h^(-2) ≤ 40000 (N^5 + B N^4 + 1)`,

`T ≤ 4000000 N (N^5 + B N^4 + 1) + 1`.

The actual Hessian query spacings, value accuracies, retirement accuracies, covariance accuracies and final acceptance accuracies also have polynomial reciprocal bounds. Actual Hessian-entry bounds supply polynomial bounds for the matrix-dependent finite Jacobi iteration counts. No numerical spectral gap is assumed.

The exponents and constants are deliberately conservative; these results do not assert practical performance.

## What the total accounting includes

- Computing the input maximum and rank-one budgets, the actual scalar parameters, polynomial loop caps, and actual integer horizons. Powers are finite multiplication circuits; ceiling is a bounded comparison loop.
- Initial preparation, every tested retirement endpoint, live-coordinate bookkeeping, all finite-difference queries and their Taylor-accuracy bounds, covariance/direction formation, and the selected sticky update.
- Materializing every direct SDP coefficient using real/imaginary scalar arithmetic. At physical lift dimension `2d`, a query has `16d²-1` variables and pencil order `20d`. Construction itself is counted.
- Finite Jacobi rotations and the associated budget calculations; capped-simplex projection and guarded LDL sampling in the eighth route.
- The final full-label test and output copy. The full route includes forming the signed matrix and executing the actual finite realified Jacobi norm report. The eighth route includes its final value query and the multiplication of its endpoint by eight.
- Every inspected retry, including failed attempts. Computation stops at first acceptance. The displayed bound is polynomial in `N,d,r`, for a fixed solver with its fixed polynomial coefficient and degree.

The sole supplied computational contract is `KSPolynomialConvexSolver.PolynomialSolver`: an accurate solver for the explicitly constructed convex program, with polynomial work in program size and reciprocal requested accuracy. All program-size and accuracy bounds used in this contract are proved from the primitive Parseval input. Solver internals and bit complexity are excluded as authorized. There are no supplied walk-success, descent, Taylor-budget, iteration-count, or per-query-size hypotheses in the final algorithm theorem.

All concrete numerical evaluations in these new routines use real scalars. Complex matrix entries are stored as pairs of real registers; complex analytic extensions are used in the derivative proofs.

## Sources and verification

The new endpoint sources are `MatrixSpencer/KSFullPolynomialExplicit.lean` and `MatrixSpencer/KSEighthPolynomialExplicit.lean`. Their positive-dimensional runtime components are `KSFullPolynomialAlgorithmRuntime` and `KSEighthPolynomialRuntime`. The explicit polynomial cost formulas are the corresponding `totalCost`/`totalBudget` definitions. `KSFullRuntimePolynomialCertificate.totalCost_polynomial` and `KSEighthRuntimePolynomialCertificate.totalCost_polynomial` additionally prove that, for each fixed permitted solver, these all-dimensional bounds are exactly evaluations of natural-coefficient multivariate polynomials in `N,d,r`. Each package contains its own route’s certificate and complete imports.

Each standalone KS folder contains a full copied project-source closure and a separate `POLYNOMIAL_RUNTIME_MANIFEST.json`. The extension verifier is:

```sh
python3 tools/verify_polynomial_runtime.py
```

It verifies shipped source hashes, builds the new endpoint, probes its complete theorem and axiom dependencies, and replays all project declarations in the dependency closure into a base containing only external dependencies using the installed Lean kernel. No project theorem is assumed when another project theorem is replayed; Lean orders the declaration graph and checks it. Identical duplicated compiler-generated theorems are deduplicated only after structural equality checks. Only `propext`, `Classical.choice`, and `Quot.sound` are allowed; an admitted proof is rejected. This is not an independent implementation of the Lean kernel or a rebuild of mathlib from primitives. Fresh logs and receipts are written under `.verification/polynomial_runtime_20260911/`.

The earlier verifier, manifests, source files and provenance remain unchanged and continue to describe their earlier scope. New standalone verification receipts must be consulted for this extension. Matrix Spencer and spectrally thin trees are separate: these two KS endpoint theorems do not certify their polynomial runtime.

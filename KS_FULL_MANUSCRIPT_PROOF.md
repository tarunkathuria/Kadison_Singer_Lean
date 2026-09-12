# Full-cube KS manuscript controller: proof correspondence

This note concerns the new `KSFullManuscript*` modules. They preserve the
full-cube manuscript's ellipsoid-based value evaluation and its unweighted
Hessian stencils. The earlier projected-gradient implementation remains a
separate verified algorithm. No existing frozen proof source was changed.

## Actual value computation

`KSFullManuscriptValueOracle.report` first sets the source regularization
`λ = ν²/(16D)`, where `D` is the physical complex matrix dimension. It then
runs tolerant bisection, using finite central-cut ellipsoid feasibility and
an actual symmetric-elimination PSD separator. The report definition does
not evaluate an optimized potential or ask for an optimizer, matrix square
root, PSD decision, derivative, or optimization value as an oracle.

`report_accuracy` proves absolute error at most `ν` from `D > 0`, `ν > 0`,
`θ ≥ 0` and the supplied matrix entries. Its proof includes all of the
following pieces:

- exact fidelity and trace-square-root block SDP identities, including
  singular source matrices;
- the source-regularization error at most `ν/2`;
- an actual feasible center, an explicit positive inner radius, and an
  explicit outer radius;
- affine Hermitian coordinates covering the full trace-one density domain;
- actual separating cuts, central-cut containment and volume decrease,
  finite ellipsoid cutoff, and tolerant bisection error at most `ν/2`.

The manuscript's orthonormal Frobenius coordinates are replaced by explicit
matrix-entry coordinates. The dimension is unchanged, but the certified
inner and outer radii are conservative bounds for these actual coordinates;
the formalization does not silently reuse the manuscript's orthonormal
coordinate radius. The method is the same source-regularized affine SDP and
central-cut ellipsoid method in the manuscript's Section II.5.

`KSFullManuscriptDiagonalValue` forms each numerical Kraus matrix as
`√cᵢ Aᵢ`, using scalar square roots, and proves that this is exactly the
original diagonal covariance source. Zero weights are allowed. The doubled
Pauli source uses weights `cᵢ/2` on all four labels. `KSFullManuscriptDebitValue`
then uses `finSumFinEquiv` to relabel the doubled physical space and obtains
accuracy for the actual full-label debit potential at every cube state.
Its `controllerReport` uses tolerance `η/8`, exactly as in the manuscript's
endpoint preparation. The temporary-debit query is the new state's value
plus `η`; the existing exact query identity justifies using these reports
in the numerical retirement test.

## Actual update and drift

`KSFullManuscriptController.controller` uses the following concrete steps:

1. Scan the original labels and perform the exhaustive finite sticky
   endpoint preparation using the ellipsoid value reports.
2. Enumerate the remaining live labels and query the potential in
   **unweighted** live coordinates. Diagonal Hessian entries use the
   three-point stencil; off-diagonal entries use the four-point stencil.
3. Form `Dₓ^(1/2) Ahat Dₓ^(1/2)/2`, then run the finite real Jacobi
   approximate Rayleigh-minimization routine.
4. Zero-extend the resulting unit live vector and propose either sign of
   `h Dₓ^(1/2)v`. Apply the finite endpoint preparation again.

The parameter definitions reproduce the manuscript formulas

```
η = δ/N
κ = δ/(100N)
t = min(δ/(4√2), √(κ/(8NM)))
νquery = κ t²/(16N)
h = min(δ/4, √(24κ/M))
β = δ/(25N)
T = ceil(16N/h²).
```

`KSFullManuscriptTaylor.budget` supplies a concrete `M`: the input-derived
joint-objective Cauchy bound is passed through the proved stationary-envelope
fourth-derivative formula, then enlarged by `6144κ/δ²` and a positive unit
slack. This admissible conservative choice keeps the same `t` and `h`
formulas within `δ/16`, where the analytic bound was proved. No maximum over
unknown derivatives, source spectral gap, or supplied Taylor certificate
occurs in this budget.

`KSFullManuscriptQueries.query_accuracy` proves the accuracy of every
actual queried value. `KSFullManuscriptTaylor.lineBounds` proves smoothness
and the required fourth-derivative bounds on every actual stencil line.
`KSFullManuscriptRayleigh.liveDirection_hessian_le` applies the actual
negative-curvature theorem at exhausted endpoint tests and proves that the
returned direction has movement second derivative at most `6κ`. The factor
one half in the matrix is retained exactly: its Rayleigh value is at most
`3κ`, and the symmetric second-order contribution is `3κ h²`.

`KSFullManuscriptDrift.localPotentialDrift` consequently proves expected
potential increase at most `β h²` for the two actual proposals.
`step_potential_le` includes the subsequent numerical retirement.
These theorems require only positive scalar parameters and the original
matrix/vector data; report, optimizer, Taylor, negative-curvature and drift
certificates are not hypotheses. `KSFullManuscriptController.leaf_mem_cube`
proves that every trajectory remains in the cube, independently of the
final output filter.

`KSFullManuscriptAlgorithm.attempt_acceptance_ge` proves that an actual
finite trial is accepted with probability at least `41/56`, after the P38
cutoff. Its final numerical test has tolerance `δ/4` and threshold `8Kδ`,
where `K = 16√2+5`. Every accepted output is a full original-label signing
with discrepancy at most `9K√ε` (`output_sound`). The precise stronger
accepted-output bound before this rounding is `8K√ε+√ε/4`.

`output_event_probability_ge` proves the literal event that the first-
accepted output is `some`, with probability at least `1−(15/56)^r` after
`r` independent finite trials. Its measure is a finite weighted sum over
the actual draw histories, with separately proved nonnegative weights and
total weight one. A nonterminal cutoff or an output failing the numerical
norm test is an explicit failure. The theorem does not assert that every
trajectory terminates within the cutoff or that a fixed finite number of
trials succeeds with probability one.

These `KSFullManuscriptAlgorithm` endpoints take `N>0`, `d>0`, `ε>0`, the
Parseval identity and the primitive atom size bound. The companion original-
input wrapper `KSFullManuscriptExplicit` computes its epsilon by a finite
maximum of squared vector norms and adds the dimension-zero branch. Its
original-input endpoint builds and supplies actual output soundness and
probability in every dimension. The aggregate checker
`check_ks_full_manuscript.py` separately checks primitive statements, dependency
routes, standard axioms and a separate-process replay of every local module.

## Numerical and runtime scope

All concrete matrix evaluations used to make updates are real-arithmetic
operations on real and imaginary matrix entries, scalar square roots,
finite symmetric elimination and real Jacobi rotations. The analytic
Cauchy argument uses a complex extension only to prove derivative bounds;
it does not require the algorithm to query nonreal spectral parameters.

`KSFullManuscriptProgramSize` checks the actual SDP dimensions. In physical
complex dimension `D`, it has `4D²−1` real variables and one real PSD pencil
of order `10D`; its dense constant-plus-coefficient data contains exactly
`400D⁴` real entries. A feasibility level adds one scalar affine objective
constraint. For an original input of dimension `d`, the sign lift gives
`D=2d`: `16d²−1` variables, order `20d`, and `6400d⁴` pencil entries. The
Pauli source has exactly `4N` Kraus labels.

The user allows a polynomial-time solver for a convex program of polynomial
size. The checked program-size reduction supports that convention, without
adding a solver axiom to Lean. The retained finite ellipsoid construction
also proves value correctness directly. Primitive real-RAM code extraction
and operation counting for all solver internals, including the logarithm
and ceiling-based budgets and CLM matrix representation, are not claimed
here. Polynomial size alone is not a formal operation-count theorem for
the entire walk. Bit complexity is outside scope.

## Checks for the controller layer

The new controller chain through `KSFullManuscriptDrift` builds with Lean
4.24.0 and the project's pinned mathlib. Direct axiom probes of the value,
query, Taylor, curvature, trajectory-invariance and drift endpoints report
only `propext`, `Classical.choice`, and `Quot.sound`. No admission or custom
axiom was added. The parent task's final receipt audits the completed
output theorem and its complete dependency closure separately.

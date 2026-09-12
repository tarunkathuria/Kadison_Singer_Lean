# KS manuscript runtime audit — 11 September 2026

This is a read-only source audit of the frozen eighth-cube and full-cube
manuscript algorithms, with one new parameter-bound module. It does not
replace their existing verification receipts. The user's convention permits
a polynomial-time solver for a polynomial-size convex program; proving such
a solver's implementation is therefore not a remaining requirement under
that convention.

## Correctness is already supplied

The original-input endpoints are `KSEighthManuscriptExplicit.output_sound`
and `output_event_probability_ge` (lines 103 and 111), and
`KSFullManuscriptExplicit.output_sound` and `output_event_probability_ge`
(lines 118 and 127). They give full original-label signs, bounds respectively
`512 sqrt ε` and `9(16 sqrt 2+5) sqrt ε`, and literal success-event masses at
least `1−2^(−r)` and `1−(15/56)^r`. Both include the zero-dimensional branch.
There is no supplied accurate value oracle, Hessian, fourth-derivative cap,
local drift, or success certificate in these endpoints.

The distinction is substantive: `KSEighthInputTaylorBound.curve_fourth_bound`
(line 115), `KSInputJointBounds.jointBounds` (line 283),
`KSFullManuscriptTaylor.line_fourth_le` (line 96), and
`KSFullManuscriptDrift.localPotentialDrift` (line 109) discharge the actual
analytic estimates. The remaining work below concerns the **size and cost**
of already-correct finite computations, not Taylor remainder correctness.

## Input scales: one missing bound now formalized

Both explicit wrappers compute the maximum atom size from the original
input. For positive physical dimension, Parseval gives
`1 ≤ d ≤ N ε`, with `0 < ε ≤ 1`. The fixed regularizer is precisely
`θ = sqrt ε / sqrt(2d)` (`KSInitialBounds.lean:66`).
The new, built `KSManuscriptScaleBounds.lean` proves

- `ε⁻¹ ≤ N` (line 32);
- `(sqrt ε)⁻¹ ≤ N` (line 45);
- `θ⁻¹ ≤ 2N` (line 54).

These bounds need no lower bound on any individual nonzero vector. Removing
zero atoms in the eighth wrapper does not introduce such a requirement;
its retained count is at most the original count. Zero physical dimension
uses the existing deterministic branch. The new module has six
standard-axiom checks recorded in
`.verification/ks_manuscript_runtime_20260911/scale_axioms.log`.

## Parameters whose polynomial size remains to be assembled in Lean

| Actual definition | Existing fact | Remaining size statement |
|---|---|---|
| Eighth `fourthBudget` (`KSEighthInputTaylorBound.lean:21–29`) | Actual uniform fourth-derivative bound | A universal polynomial upper bound from Parseval and dimensions |
| Full `budget` (`KSFullManuscriptTaylor.lean:23`) | Actual uniform fourth-derivative bound plus radius enlargement | The corresponding universal polynomial upper bound |
| Eighth `rho`, `kappa`, `precision`, `beta`, `movementStep` (`KSEighthManuscriptParameters.lean:24–35`) | Positivity and all correctness tolerances | Polynomial upper bounds for their reciprocals |
| Full query, value, and movement tolerances (`KSFullManuscriptParameters.lean:19–29`) | Positivity and all correctness tolerances | Polynomial reciprocal bounds |
| Cutoffs `ceil(100N/h²)` and `ceil(16N/h²)` (`KSEighthManuscriptBudgets.lean:62`, `KSFullManuscriptParameters.lean:28`) | Actual cutoff success bounds | Polynomial upper bounds, including computation of integer budgets |

There is a direct mathematical route to these estimates. Parseval bounds
atom operator norms by one; finite-entry/Frobenius estimates consequently
bound all lifted-family `matrixBound`, source, and center budgets by
polynomials in `N,d`. The density floor is an explicit square of
`θ/(2R+2 sqrt κ+2θ sqrt D)`. The analytic radius is
`min(1,min(μ,ρ))/1000`, and the joint derivative cap is a value bound times
`(10/radius)^4`. The envelope fourth cap has fixed powers and divisions by
`θ/2`. See `KSEighthJointBoundPoint.lean:21–26`,
`KSDebitUniformFloor.lean:25–29`, and
`KSJointBoundParameters.lean:19–30`. Together with the new reciprocal
bounds, these fixed-degree formulas have polynomial growth. This audit has
not packaged that entire growth calculation as a Lean theorem. No source
least-positive-eigenvalue parameter occurs in these formulas.

## Solver convention and whole-path cost

`KSFullManuscriptProgramSize` already proves the exact SDP sizes: for
physical complex dimension `D`, `4D²−1` real variables, real PSD pencil
order `10D`, and `400D⁴` dense pencil entries. On the sign lift these become
`16d²−1`, `20d`, and `6400d⁴`; the Pauli family has `4N` labels (lines 24–60).
Thus the user's solver convention removes the need to prove the convex
solver's runtime. Required precision and the number of calls must still be
bounded as above.

For precision about the stored definitions, the full value routine retains
its verified finite ellipsoid construction
(`KSFullManuscriptValueOracle.lean:40–50,91`); the eighth value routine uses
the verified finite projected-gradient/Jacobi implementation
(`KSEighthNumericalValue.lean:37–42`, `KSNumericalDensityRun.lean:24–41`).
A runtime theorem for those *literal* implementations would additionally
compose their iteration and approximation budgets. Allowing a polynomial
convex solver avoids that internal proof obligation, but is not itself a
proof of the costs of these particular implementations.

Outside the solver, full Hessian sampling has polynomially many entries;
the eighth covariance uses a finite capped-simplex/Jacobi projection and
uniform signed LDL columns (`KSEighthManuscriptSampler.lean:20–39,64`).
The existing Jacobi count is the conservative
`ceil((d²+1)*offDiagonalEnergy/τ²)` (`KSJacobiIteration.lean:257`), so its
input energy and reciprocal accuracy require polynomial bounds too.
Useful primitive cost components already exist: safe LDL factor data cost
at most `60(d+1)^5` (`RealRAMLDL.lean:131,141`) and a safe Jacobi rotation
at most 300 (`RealRAMJacobiRotation.lean:124,127`). Generic retry cost is
at most `r` trial costs, and expected cost at most two trial costs for the
eighth half-success bound (`KSEighthManuscriptRetryCost`).

These components have not been composed into an execution/cost theorem
for either whole explicit KS endpoint. Such a theorem must represent one
sampled adaptive path, including preparation, report calls, matrix work,
integer-budget construction, acceptance, and retries. The complete finite
probability tree used in the proofs need not be enumerated by an online
implementation; conversely, its finiteness alone does not prove that
implementation's polynomial cost. The existing real-RAM language explicitly
charges loop control and says computing a supplied loop budget is separate
(`RealRAMProgram.lean:5–9`). Bit complexity and extracted executable code
are outside this audit's conclusion.

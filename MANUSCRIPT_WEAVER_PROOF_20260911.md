# Original Weaver statement from the two manuscript walks

`KSFullManuscriptWeaver` and `KSEighthManuscriptWeaver` now convert their
respective actual manuscript algorithms into the original finite Weaver KS₂
assertion. `KSManuscriptWeaverTools` reproduces the elementary conversion
lemmas; it imports no signing existence or algorithm theorem.

The universal constants are `eta=1048576` and `theta=262144`. Inputs are
arbitrary finite families of complex Euclidean vectors of norm at most one,
whose summed squared inner products with every unit vector equal eta.
The actual output is the positive-sign subset of the signing returned by the
corresponding manuscript algorithm. Both that subset and its complement
have unit-vector energy at most `eta-theta=786432`.

Scaling every vector by 1/1024 gives a Parseval family with atom norm at most
1/1048576. The new manuscript signing guarantees are at most 1/2 at this
scale. The fixed positive-sign partition then has both partial operator
norms at most 3/4. Scaling back gives the stated original energy bounds.
No sharp MSS constants are asserted here; these universal constants prove
Weaver's discrepancy conjecture.

The partition output is a map of the actual Option-valued signing output.
Therefore it has exactly the same returned-some event and normalized finite
weights. Its probability is at least `1-(15/56)^r` in the full-cube case and
`1-2^(-r)` in the eighth-cube case. Existence is derived from positive
probability at one trial. No favorable path is selected in the algorithm.
Dimension zero is included by the underlying original-input wrapper.

Both wrappers build. Three independently written primitive statements for
each walk check the original Weaver quantifiers, both returned partition
bounds with literal numerical constants, and the actual success event.
All six report only propext, Classical.choice and Quot.sound. The two new
wrapper modules and the reproduced elementary conversion module passed
separate-process replay against their imports. Dependency checks require
the new manuscript signing output and its probability proof, the fixed
positive partition and the elementary frame conversion, and exclude the
prior existential and alternative-algorithm conclusions.

The additive standalone checkers `check_ks_full_manuscript_weaver.py` and
`check_ks_eighth_manuscript_weaver.py` check both the original signing
statements and Weaver statements, both numerical/proof routes, and replay
the complete local closure of the respective new Weaver root. Their receipt
records whether that full standalone verification has actually completed.

A separate `KSFullManuscriptWalkBudget.cutoff_le` also proves the actual P38
movement horizon is at most
`256*N/delta^2 + 100*N^2*M/delta + 1`.
This is an explicit loop-count bound in the positive numerical parameters;
it does not by itself prove a polynomial bound in the original input size
or a total operation count. The user's allowed polynomial-time convex solver
assumption is retained, and bit complexity remains outside scope.

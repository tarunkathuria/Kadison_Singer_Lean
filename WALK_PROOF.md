# The explicit KS walk verified in Lean

This note records the finite randomized full-cube algorithm represented by the Lean sources, and distinguishes it from the implementation described in the separately distributed full-cube manuscript (`ks_rank_one_full_cube.tex`). It concerns the rank-one Kadison–Singer signing problem. It does not add a spectrally thin-tree algorithm, a deterministic signing algorithm, or a verified runtime theorem. The source review date is September 11, 2026.

For original labels \(i\in\mathrm{Fin}\,N\), the input is a family \(v_i\in\mathbb C^d\), with \(d>0\), a supplied real number \(\epsilon>0\), and

\[
A_i=v_iv_i^*,\qquad \sum_i A_i=I_d,\qquad
\|v_i\|_2^2\le\epsilon\quad\text{for every original label }i.
\]

The size assumption is the ordinary squared Euclidean vector norm. [KSJointInputAlgorithm.atom_bound_of_vector_size](MatrixSpencer/KSJointInputAlgorithm.lean#L40) proves the operator-norm hypothesis used downstream from that primitive assumption. The algorithm retains all original labels, including zero vectors; its output condition checks a sign on every label. It takes a size upper bound, rather than requiring that \(\epsilon\) be exactly the maximum. This input interface excludes \(d=0\) and \(\epsilon=0\). The separate [exists_full_signing theorem](MatrixSpencer/KSExplicitWalkAlgorithm.lean#L143) covers those cases by a constant signing, so the normalized existence corollary includes them; they are not additional branches of the positive-parameter walk's `output` definition.

The literal Weaver KS₂ statement asks for universal constants \(\eta_W\ge2\), \(\theta_W>0\) such that every finite complex vector family with \(\|w_i\|\le1\) and \(\sum_i|\langle u,w_i\rangle|^2=\eta_W\) for every unit \(u\) admits a partition whose two energy sums are each at most \(\eta_W-\theta_W\), for every unit \(u\). Thus sufficiently conservative universal constants satisfy the original quantifiers; matching the numerical constants \(18,2\) obtained by MSS is a stronger quantitative claim. See [MSS, Conjecture 1.2 and the discussion following Corollary 1.5](https://arxiv.org/pdf/1306.3969). This finite-dimensional partition statement must also be distinguished from formalizing the operator-algebraic equivalence to original pure-state extension uniqueness; that equivalence is outside the walk proof described here.

For the walk bound below, the conservative constants \(\eta_W=1048576=1024^2\) and \(\theta_W=262144=\eta_W/4\) suffice for that conversion. Normalize \(v_i=w_i/1024\), take \(\epsilon=1/\eta_W\), and partition by the returned signs. Since \(9(16\sqrt2+5)<512\), the normalized signed sum has norm at most \(1/2\). Both normalized part sums are bounded by \(3I/4\); rescaling gives the requested \(\eta_W-\theta_W\) energy bound. These constants concern the literal existential-constant KS₂ target, not the sharper quantitative MSS partition estimate.

**The actual state and transition.** The coefficients lie in the full cube \([-1,1]^N\). The source owners are exactly \(64(1-x_i^2)\). A label is frozen only at \(x_i=\pm1\). The physical debit is the following determined function of the frozen set:

\[
B(x)=\delta\sum_{i:\,|x_i|=1}A_i
       +\#\{i:|x_i|=1\}\,\eta I_d.
\]

Consequently each retirement adds exactly \(\delta A_i+\eta I_d\), and a movement preserving the open face leaves the debit unchanged. The optimized state potential uses the full \(2d\times2d\) density domain, the signed center minus the doubled debit, the actual spin covariance source, and the trace-square-root regularizer. These identities are proved in [KSDebitBudget](MatrixSpencer/KSDebitBudget.lean#L19), [KSDebitPreparation](MatrixSpencer/KSDebitPreparation.lean#L29), and [KSDebitMovement](MatrixSpencer/KSDebitMovement.lean#L101).

Preparation scans the finite list of original labels and their two endpoints. It accepts a live endpoint when its new-state report minus the old-state report is at most \(-\eta/2\). Each report has error at most \(\eta/8\). This is exactly the manuscript's temporary-debit test after accounting for the extra scalar debit \(\eta I\). The finite preparation loop exhausts the tests, preserves old endpoints, and does not increase the true potential. Its output has live margin \(\delta<1-|x_i|\). The designated initial state is preparation applied to zero, not an unspecified favorable starting state. See [KSDebitPreparation.test_equivalence](MatrixSpencer/KSDebitPreparation.lean#L91) and [KSDebitWalkRun.makeState](MatrixSpencer/KSDebitWalkRun.lean#L63).

At a nonterminal prepared state, a finite numerical Hessian computation returns a unit vector \(w\) on the enumerated live labels. It is extended by zero on frozen labels. One independent fair bit selects the proposal

\[
x_i' = x_i\pm h\sqrt{1-x_i^2}\,w_i,
\]

followed by preparation. Both proposals remain in the same open face; terminal states are absorbed. The numerical direction is obtained by explicit Jacobi rotations and finite comparisons, with no supplied exact eigenvector or eigenvalue-gap hypothesis. [KSDebitNumericalController.controller](MatrixSpencer/KSDebitNumericalController.lean#L47) supplies the actual report and direction implementations to the previously proved transition.

**Parameters and queried Hessian.** Write \(K=16\sqrt2+5\). The walk parameters are

\[
\delta=\sqrt\epsilon,\qquad
\theta=\frac{\sqrt\epsilon}{\sqrt{2d}},\qquad
\eta=\frac{\delta}{N+1},\qquad
\kappa=\frac{\delta}{100(N+1)},\qquad \beta=4\kappa.
\]

The derivative cap is an explicit input-entry expression. In source notation set

\[
\begin{aligned}
\mu&=\texttt{KSDebitUniformFloor.uniformFloor}(v,\delta,\eta,\theta),\\
r_0&=\min\{1,\mu,\delta/2\}/1000,\\
B_4&=\texttt{KSJointBoundParameters.objectiveCap}(v,\delta,\eta,\theta)
          (10/r_0)^4,\\
E&=(B_4+3B_4^2/(\theta/2))(1+B_4/(\theta/2))^4,\\
M&=\max\{E,256\kappa/\delta^2\}+1,\\
h&=\min\{\delta/4,\sqrt{\kappa/(M+1)}\},\\
T&=\max\{1,\lceil16N/h^2\rceil\}.
\end{aligned}
\]

Here \(B_4\) is a common cap for the joint second, third, and fourth derivatives, not merely the fourth derivative of the optimized outer function. The value cap and floor use finite entry sums, scalar arithmetic and square roots; the numerical constant does not ask for the source's least positive eigenvalue. The formulas are fixed in [KSJointBoundParameters](MatrixSpencer/KSJointBoundParameters.lean#L18), [KSTaylorBudget](MatrixSpencer/KSTaylorBudget.lean#L18), and [KSControllerParameters](MatrixSpencer/KSControllerParameters.lean#L16). Their positivity is proved. In particular, the enlarged budget ensures \(h\le\delta/16\), so movements fit inside the proved Taylor interval.

If the live count is \(k>0\), the actual Hessian query mesh and value tolerance are

\[
t_q=\min\{\delta/16,\sqrt{\kappa/[k(M+1)]}\},\qquad
\nu_q=\kappa t_q^2/(4k).
\]

Every matrix entry uses the four-query mixed stencil. This includes diagonal entries: their two line directions are \(2e_i\) and zero. The queried function is the true state potential composed with the weighted live-face map. Its Hessian is the full weighted Hessian, whereas the manuscript calls one half of this matrix \(K_B\). The Lean error and drift constants are proved for its own convention. [KSNumericalHessian](MatrixSpencer/KSNumericalHessian.lean#L28) and [KSDebitHessianQueries](MatrixSpencer/KSDebitHessianQueries.lean#L27) prove that the actual finite queries are legal and accurate. The actual Jacobi output has true Rayleigh value at most \(3\kappa\) at a prepared nonterminal state. The fourth-order remainder then gives the two-proposal mean potential increase at most \(\beta h^2\).

**Value computation differs from the manuscript.** Part II of the manuscript supplies an ellipsoid-based SDP value routine. The Lean walk instead calls a finite inexact projected-gradient ascent on the full physical density matrix. It starts at the maximally mixed density, uses a positive floor computed from the input entries, evaluates a finite-difference gradient, and projects back to the trace-one density floor using the actual Jacobi/simplex projection routine. The projection and gradient errors and the finite iteration count are instantiated inside the accuracy theorem. The canonical optimizer and coordinate charts are used as mathematical proof objects, not as values returned by the numerical routine.

[KSNumericalDensityRun.update](MatrixSpencer/KSNumericalDensityRun.lean#L31) is the physical update. [KSNumericalOwnerPotential.report_accuracy](MatrixSpencer/KSNumericalOwnerPotential.lean#L58) proves error at most the requested tolerance against the original supremum over all density matrices, from Hermitian/PSD input hypotheses and positive regularization and tolerance. It does not assume a value oracle. Jacobi trace-root and fidelity reports handle singular sources. Thus the verified value routine supports the same mathematical potential, while its numerical implementation is a different algorithm from the manuscript's ellipsoid construction.

**Progress and success refer to the finite run.** No condition \(x\cdot w=0\), or orthogonality to \(x\) after weighting, is imposed. Symmetric sampling cancels first-order terms in expectation. The stopping proof uses

\[
U(x)=\sum_i[2\log2-(1+x_i)\log(1+x_i)-(1-x_i)\log(1-x_i)]
\]

with the continuous endpoint convention. A nonterminal movement followed by preparation decreases its conditional mean by at least \(h^2\). For every finite horizon, the expected number of movements is at most \(2N\log2/h^2\), and the nonterminal cutoff probability at \(T\) is at most \(1/8\). These are the actual-run estimates in [KSDebitEntropyRun](MatrixSpencer/KSDebitEntropyRun.lean#L29). The earlier squared-coordinate-energy bound also exists, but it is not the stopping estimate used for the stated success constant. Neither logarithms nor entropy are evaluated by the controller.

The initial potential, the debit bound \(B(x)\preceq2\delta I\), and the total expected potential-drift allowance give expected discrepancy at the finite horizon at most \(K\delta\). Markov's inequality gives probability at most \(1/7\) for norm above \(7K\delta\). Combining this with the cutoff event gives a full-signing, good-norm probability at least

\[
1-\frac18-\frac17=\frac{41}{56}.
\]

This finite-tree proof does not need an uncut infinite walk or an almost-sure stopping theorem. In contrast, the manuscript proves almost-sure termination and then couples its cutoff run to that infinite-process formulation. See [KSDebitWalkQuality.successProbability_from_zero_ge](MatrixSpencer/KSDebitWalkQuality.lean#L266).

The acceptance test checks all original signs and a computed **upper** norm report. Lean uses report tolerance \(2K\delta\) and accepts at \(9K\delta\). The report lies between the true norm and the true norm plus that tolerance, so every \(7K\delta\)-good signing passes, and every accepted signing has true norm at most \(9K\delta\). The manuscript instead uses a \(\delta/4\)-accurate report and threshold \(8K\delta\); this is another intentional numerical difference. The proved final discrepancy constant is the same. See [KSComplexNorm.report_accuracy](MatrixSpencer/KSComplexNorm.lean#L131) and [KSDebitWalkAcceptance.accepts](MatrixSpencer/KSDebitWalkAcceptance.lean#L34).

The output is `Option (Fin N → ℝ)`: the first accepted signing, or `none` after the specified number \(r\) of independent attempts. Failure includes an unfinished cutoff or a completed trial rejected by the norm report. Every returned `some` is sound. The event in the probability theorem is literally `output.isSome`, summed with the proved finite independent draw weights. For \(r\) attempts the success lower bound is \(1-(15/56)^r\); \(r=0\) is allowed and gives the vacuous lower bound zero. Choosing an integer \(r\) with \((15/56)^r\le\zeta\) yields failure at most \(\zeta\). This note does not assert that a separate logarithmic retry-count implementation has been verified. The definitions and exact event identification are in [KSDebitInputAlgorithm](MatrixSpencer/KSDebitInputAlgorithm.lean#L39) and [KSDebitWalkRetry](MatrixSpencer/KSDebitWalkRetry.lean#L172).

**Real numerical queries and auxiliary complex analysis.** All walk coefficient, finite-difference, comparison and Jacobi parameters are real. Complex Hermitian inputs are represented by their real and imaginary entries and, where needed, explicit real block matrices. The numerical value and direction routines do not evaluate a resolvent at a nonreal spectral parameter. The proof of a uniform derivative cap does use a complex extension in coefficient time and matrix-density perturbations. [KSComplexOwnerObjective](MatrixSpencer/KSComplexOwnerObjective.lean#L30) proves smoothness of that actual extension and exact agreement with the real objective; [KSComplexSpinDomain](MatrixSpencer/KSComplexSpinDomain.lean#L188) proves its spectral domain without a source-gap premise. Cauchy estimates are proof tools, not numerical calls made by the walk. The compact-resolvent construction of the analytic trace root itself integrates over real \(a\in[0,1]\); for \(a<1\) its inverse corresponds to the real nonpositive spectral parameter \(-a^2/(1-a)^2\).

**Formal scope and runtime.** The sources define exact-real finite arithmetic procedures and prove their mathematical accuracy, feasibility, and finite-distribution guarantees. They are Lean `noncomputable` definitions over mathematical real numbers, not an extracted executable or floating-point implementation. Finite comparisons, scalar square roots, and natural-number ceilings in loop bounds are part of that mathematical description. The sampling model uses leaves of a finite run tree and their exact weights; a cost-aware online fair-bit sampler and path evaluator have not been verified. The tree describes the probability law, and no polynomial-time claim is made for materializing that whole tree. There is no formal cost semantics or theorem bounding the total number of real arithmetic operations by a polynomial in the original input size. There is also no bit-complexity, finite-precision stability, machine-code, or random-bit-generator verification.

The manuscript's polynomial real-arithmetic claim pertains to its stated ellipsoid/controller construction. The finite projected-gradient replacement is not identical to that construction, so a checked accuracy theorem for the replacement must not be described as a formal verification of the manuscript's complete runtime argument. Its explicit loop counts provide material for a separate operation-count analysis; finiteness alone is not such an analysis. Correctness and success of the instantiated finite walk, and polynomial-time implementation of that walk, are distinct claims.

**Completed input-only endpoint.** [KSInputJointBounds.jointBounds](MatrixSpencer/KSInputJointBounds.lean#L283) supplies the actual joint derivative certificate from the original input entries and positive scalar parameters. [KSExplicitWalkAlgorithm](MatrixSpencer/KSExplicitWalkAlgorithm.lean#L19) fixes that input cap and the Taylor budget, then composes the actual complex extension, value bound, Cauchy estimates, envelope theorem, Taylor estimates, numerical reports and finite-run theorem. The module has compiled, and its endpoint axiom checks contain only `propext`, `Classical.choice`, and `Quot.sound`. This is a module-level verification statement; fresh aggregate replay is recorded by the project's separate receipt.

Its [output_event_probability_ge](MatrixSpencer/KSExplicitWalkAlgorithm.lean#L110) takes only \(\epsilon>0\), \(d>0\), Parseval normalization and the original squared-vector-size bound, and proves the literal finite `isSome` probability at least \(1-(15/56)^r\). [one_attempt_success](MatrixSpencer/KSExplicitWalkAlgorithm.lean#L117) gives \(41/56\); [output_sound](MatrixSpencer/KSExplicitWalkAlgorithm.lean#L90) proves every returned original-label signing has discrepancy at most \(9K\sqrt\epsilon\). There is no supplied derivative cap, value oracle, eigenvector oracle, local-drift hypothesis or favorable execution assumption in the success endpoint.

Intermediate files deliberately retain hypotheses named `LocalPotentialDrift`, `RemainingTaylorBounds`, or `InputJointBounds`. Those are modular interfaces discharged by this final composition. Their isolated headers should be read in the scope of their own theorem statements, rather than as the current status of the complete algorithm proof. The remaining runtime qualifications above still apply to the completed input-only endpoint.

**Original Weaver theorem and final verification.** [KSExplicitWeaver.weaver_KS2](MatrixSpencer/KSExplicitWeaver.lean#L344) proves the literal original finite unit-energy statement with the universal pair (1048576,262144). The partition is the positive-sign set of an actual returned signing. Its [output-event theorem](MatrixSpencer/KSExplicitWeaver.lean#L300) has the same geometric retry guarantee and handles every dimension; the zero-dimensional branch returns the empty set deterministically.

The [original workspace verification receipt](provenance/20260911_full_cube_original_verification.json) has status `VERIFIED`. Ten independently written primitive statement checks passed, including both algorithms' actual outputs and nonnegative normalized weights. The proof-route audit confirms the actual finite optimizer, numerical controller, derived analytic bounds, local drift and entropy proof, and excludes the earlier signing-existence and maximal-frozen-minimizer vertex conclusions. Every one of the 205 project modules in that original walk/Weaver import closure was replayed against its imports using the installed Lean kernel, with only the three standard axioms and no project source admissions. All 431 prior frozen fingerprints remained unchanged.

This standalone repository contains the 208-module union of that walk/Weaver closure and the retained full-cube existence closure. From this repository directory, run `./verify.sh` to check both the retained existence theorem and the actual walk/Weaver endpoints using the shipped checkers and probes. Fresh receipts are written to `.verification/kadison_singer_spin_mixed/last_result.json` and `.verification/walk/verification.json`. The packaged `VERIFICATION.json` records the completed standalone checks, and copies of both fresh receipts are shipped under `provenance/`. No original workspace directory is needed.

import MatrixSpencer.KSExplicitWeaver
import Lean

/-!
Independent endpoint checks for the finite numerical KS walk.

The expected mathematical propositions below contain literal full signs,
physical rank-one entries, the Euclidean continuous-linear-map operator norm,
and the actual finite output-event sum. No IsSign, JointBounds, TaylorBounds,
or LocalPotentialDrift predicate occurs in these expected propositions.
Algorithm aliases refer to the final concrete walk; they are not existential
algorithm parameters. The separate Weaver check spells the original unit
energy formulation independently. These checks do not assert an operation-count bound.
-/

open scoped BigOperators Matrix InnerProductSpace
noncomputable section
namespace KSWalkFinalIndependent
open MatrixSpencer.KSExplicitWalkAlgorithm

def Expected_output_sound : Prop :=
  ∀ {N d : ℕ} (v : Fin N → Fin d → ℂ) {ε : ℝ}
    (hε : 0 < ε) (hd : 0 < d) (r : ℕ) (z : Draws v hε hd r) (σ : Fin N → ℝ),
    output v hε hd r z = some σ →
      (∀ i, σ i = 1 ∨ σ i = -1) ∧
      ‖Matrix.toEuclideanCLM (n := Fin d) (𝕜 := ℂ)
        (∑ i : Fin N, σ i • (fun a b : Fin d => v i a * star (v i b)))‖ ≤
          9 * (16 * Real.sqrt 2 + 5) * Real.sqrt ε

def Expected_output_event : Prop :=
  ∀ {N d : ℕ} (v : Fin N → Fin d → ℂ) {ε : ℝ}
    (hε : 0 < ε) (hd : 0 < d),
    (∑ i : Fin N, (fun a b : Fin d => v i a * star (v i b))) =
      (1 : Matrix (Fin d) (Fin d) ℂ) →
    (∀ i, ‖(WithLp.toLp 2 (v i) : EuclideanSpace ℂ (Fin d))‖ ^ 2 ≤ ε) →
    ∀ r : ℕ, 1 - ((15 : ℝ) / 56) ^ r ≤
      ∑ z : Draws v hε hd r,
        drawWeight v hε hd r z * (if (output v hε hd r z).isSome then 1 else 0)

def Expected_drawWeight_nonneg : Prop :=
  ∀ {N d : ℕ} (v : Fin N → Fin d → ℂ) {ε : ℝ}
    (hε : 0 < ε) (hd : 0 < d) (r : ℕ) (z : Draws v hε hd r),
      0 ≤ drawWeight v hε hd r z

def Expected_drawWeight_sum : Prop :=
  ∀ {N d : ℕ} (v : Fin N → Fin d → ℂ) {ε : ℝ}
    (hε : 0 < ε) (hd : 0 < d) (r : ℕ),
      (∑ z : Draws v hε hd r, drawWeight v hε hd r z) = 1

def Expected_exists_full_signing : Prop :=
  ∀ {N d : ℕ} (v : Fin N → Fin d → ℂ) {ε : ℝ}, 0 ≤ ε →
    (∑ i : Fin N, (fun a b : Fin d => v i a * star (v i b))) =
      (1 : Matrix (Fin d) (Fin d) ℂ) →
    (∀ i, ‖(WithLp.toLp 2 (v i) : EuclideanSpace ℂ (Fin d))‖ ^ 2 ≤ ε) →
    ∃ σ : Fin N → ℝ, (∀ i, σ i = 1 ∨ σ i = -1) ∧
      ‖Matrix.toEuclideanCLM (n := Fin d) (𝕜 := ℂ)
        (∑ i : Fin N, σ i • (fun a b : Fin d => v i a * star (v i b)))‖ ≤
          9 * (16 * Real.sqrt 2 + 5) * Real.sqrt ε

def Expected_weaver_output_sound : Prop :=
  ∀ {N d : ℕ} (w : Fin N → EuclideanSpace ℂ (Fin d)),
    (∀ u : EuclideanSpace ℂ (Fin d), ‖u‖ = 1 →
      (∑ i, ‖inner ℂ u (w i)‖ ^ 2) = 1048576) →
    ∀ (r : ℕ) (z : MatrixSpencer.KSExplicitWeaver.Draws w r) (S : Finset (Fin N)),
      MatrixSpencer.KSExplicitWeaver.output w r z = some S →
      ∀ u : EuclideanSpace ℂ (Fin d), ‖u‖ = 1 →
        (∑ i ∈ S, ‖inner ℂ u (w i)‖ ^ 2) ≤ 1048576 - 262144 ∧
        (∑ i ∈ Sᶜ, ‖inner ℂ u (w i)‖ ^ 2) ≤ 1048576 - 262144

def Expected_weaver_output_event : Prop :=
  ∀ {N d : ℕ} (w : Fin N → EuclideanSpace ℂ (Fin d)),
    (∀ i, ‖w i‖ ≤ 1) →
    (∀ u : EuclideanSpace ℂ (Fin d), ‖u‖ = 1 →
      (∑ i, ‖inner ℂ u (w i)‖ ^ 2) = 1048576) →
    ∀ r : ℕ, 1 - ((15 : ℝ) / 56) ^ r ≤
      ∑ z : MatrixSpencer.KSExplicitWeaver.Draws w r,
        MatrixSpencer.KSExplicitWeaver.drawWeight w r z *
          (if (MatrixSpencer.KSExplicitWeaver.output w r z).isSome then 1 else 0)

def Expected_weaver_drawWeight_nonneg : Prop :=
  ∀ {N d : ℕ} (w : Fin N → EuclideanSpace ℂ (Fin d)) (r : ℕ)
    (z : MatrixSpencer.KSExplicitWeaver.Draws w r),
      0 ≤ MatrixSpencer.KSExplicitWeaver.drawWeight w r z

def Expected_weaver_drawWeight_sum : Prop :=
  ∀ {N d : ℕ} (w : Fin N → EuclideanSpace ℂ (Fin d)) (r : ℕ),
    (∑ z : MatrixSpencer.KSExplicitWeaver.Draws w r,
      MatrixSpencer.KSExplicitWeaver.drawWeight w r z) = 1

def Expected_weaver_KS2 : Prop :=
  ∃ η θ : ℝ, 2 ≤ η ∧ 0 < θ ∧
    ∀ (N d : ℕ) (w : Fin N → EuclideanSpace ℂ (Fin d)),
      (∀ i, ‖w i‖ ≤ 1) →
      (∀ u : EuclideanSpace ℂ (Fin d), ‖u‖ = 1 →
        (∑ i, ‖inner ℂ u (w i)‖ ^ 2) = η) →
      ∃ S : Finset (Fin N), ∀ u : EuclideanSpace ℂ (Fin d), ‖u‖ = 1 →
        (∑ i ∈ S, ‖inner ℂ u (w i)‖ ^ 2) ≤ η - θ ∧
        (∑ i ∈ Sᶜ, ‖inner ℂ u (w i)‖ ^ 2) ≤ η - θ

/-- The final output alias is definitionally the actual finite numerical walk/retry output. -/
theorem output_is_actual_walk {N d : ℕ} (v : Fin N → Fin d → ℂ) {ε : ℝ}
    (hε : 0 < ε) (hd : 0 < d) (r : ℕ) (z : Draws v hε hd r) :
    output v hε hd r z =
      letI : Nonempty (Fin d) := ⟨⟨0,hd⟩⟩
      MatrixSpencer.KSDebitInputAlgorithm.output v hε (taylorBudget_pos v hε hd).le hd r z := rfl

/-- The weights are definitionally products of the actual finite walk's leaf weights. -/
theorem drawWeight_is_actual_walk {N d : ℕ} (v : Fin N → Fin d → ℂ) {ε : ℝ}
    (hε : 0 < ε) (hd : 0 < d) (r : ℕ) (z : Draws v hε hd r) :
    drawWeight v hε hd r z =
      letI : Nonempty (Fin d) := ⟨⟨0,hd⟩⟩
      let C := MatrixSpencer.KSDebitInputAlgorithm.controller v hε (taylorBudget_pos v hε hd).le hd
      MatrixSpencer.KSDebitWalkRetry.FiniteRetry.weight
        (MatrixSpencer.KSDebitWalkRun.run C
          (MatrixSpencer.KSDebitInputAlgorithm.cutoff N ε (taylorBudget v ε))
          (MatrixSpencer.KSDebitWalkRun.initialState C)).leafWeight r z := rfl

/-- Every Taylor budget is bound to the proved explicit input-entry expression. -/
theorem taylorBudget_is_input_expression {N d : ℕ} (v : Fin N → Fin d → ℂ) (ε : ℝ) :
    taylorBudget v ε = MatrixSpencer.KSTaylorBudget.budget N (Real.sqrt ε)
      (MatrixSpencer.ksRegularizerScale ε (Fin d))
      (MatrixSpencer.KSJointBoundParameters.jointCap v (Real.sqrt ε)
        (Real.sqrt ε / ((N : ℝ) + 1)) (MatrixSpencer.ksRegularizerScale ε (Fin d))) := rfl

end KSWalkFinalIndependent

run_cmd Lean.Elab.Command.liftTermElabM do
  for (endpoint, expected) in [
      (`MatrixSpencer.KSExplicitWalkAlgorithm.output_sound, `KSWalkFinalIndependent.Expected_output_sound),
      (`MatrixSpencer.KSExplicitWalkAlgorithm.output_event_probability_ge, `KSWalkFinalIndependent.Expected_output_event),
      (`MatrixSpencer.KSExplicitWalkAlgorithm.drawWeight_nonneg, `KSWalkFinalIndependent.Expected_drawWeight_nonneg),
      (`MatrixSpencer.KSExplicitWalkAlgorithm.drawWeight_sum, `KSWalkFinalIndependent.Expected_drawWeight_sum),
      (`MatrixSpencer.KSExplicitWalkAlgorithm.exists_full_signing, `KSWalkFinalIndependent.Expected_exists_full_signing),
      (`MatrixSpencer.KSExplicitWeaver.output_sound, `KSWalkFinalIndependent.Expected_weaver_output_sound),
      (`MatrixSpencer.KSExplicitWeaver.output_event_probability_ge, `KSWalkFinalIndependent.Expected_weaver_output_event),
      (`MatrixSpencer.KSExplicitWeaver.drawWeight_nonneg, `KSWalkFinalIndependent.Expected_weaver_drawWeight_nonneg),
      (`MatrixSpencer.KSExplicitWeaver.drawWeight_sum, `KSWalkFinalIndependent.Expected_weaver_drawWeight_sum),
      (`MatrixSpencer.KSExplicitWeaver.weaver_KS2, `KSWalkFinalIndependent.Expected_weaver_KS2)] do
    let info ← Lean.getConstInfo endpoint
    match info with
    | .thmInfo _ => pure ()
    | _ => throwError "{endpoint} must be a theorem declaration."
    unless (← Lean.Meta.isDefEq info.type (Lean.mkConst expected)) do
      throwError "{endpoint} differs from independently written primitive statement {expected}."
    Lean.logInfo m!"KS_WALK_FINAL_TYPE_CHECKED {endpoint}"

example : KSWalkFinalIndependent.Expected_output_sound := MatrixSpencer.KSExplicitWalkAlgorithm.output_sound
example : KSWalkFinalIndependent.Expected_output_event := MatrixSpencer.KSExplicitWalkAlgorithm.output_event_probability_ge
example : KSWalkFinalIndependent.Expected_drawWeight_nonneg := MatrixSpencer.KSExplicitWalkAlgorithm.drawWeight_nonneg
example : KSWalkFinalIndependent.Expected_drawWeight_sum := MatrixSpencer.KSExplicitWalkAlgorithm.drawWeight_sum
example : KSWalkFinalIndependent.Expected_exists_full_signing := MatrixSpencer.KSExplicitWalkAlgorithm.exists_full_signing
example : KSWalkFinalIndependent.Expected_weaver_output_sound := MatrixSpencer.KSExplicitWeaver.output_sound
example : KSWalkFinalIndependent.Expected_weaver_output_event := MatrixSpencer.KSExplicitWeaver.output_event_probability_ge
example : KSWalkFinalIndependent.Expected_weaver_drawWeight_nonneg := MatrixSpencer.KSExplicitWeaver.drawWeight_nonneg
example : KSWalkFinalIndependent.Expected_weaver_drawWeight_sum := MatrixSpencer.KSExplicitWeaver.drawWeight_sum
example : KSWalkFinalIndependent.Expected_weaver_KS2 := MatrixSpencer.KSExplicitWeaver.weaver_KS2

#eval IO.println "KS_WALK_FINAL_AXIOMS_BEGIN"
#print axioms MatrixSpencer.KSExplicitWalkAlgorithm.output_sound
#print axioms MatrixSpencer.KSExplicitWalkAlgorithm.output_event_probability_ge
#print axioms MatrixSpencer.KSExplicitWalkAlgorithm.drawWeight_nonneg
#print axioms MatrixSpencer.KSExplicitWalkAlgorithm.drawWeight_sum
#print axioms MatrixSpencer.KSExplicitWalkAlgorithm.exists_full_signing
#print axioms MatrixSpencer.KSExplicitWeaver.output_sound
#print axioms MatrixSpencer.KSExplicitWeaver.output_event_probability_ge
#print axioms MatrixSpencer.KSExplicitWeaver.drawWeight_nonneg
#print axioms MatrixSpencer.KSExplicitWeaver.drawWeight_sum
#print axioms MatrixSpencer.KSExplicitWeaver.weaver_KS2
#eval IO.println "KS_WALK_FINAL_AXIOMS_END"
#eval IO.println "KS_WALK_FINAL_INDEPENDENT_STATEMENTS_PASSED"
#eval IO.println "KS_WALK_PRIMITIVE_STATEMENTS_CHECKED"

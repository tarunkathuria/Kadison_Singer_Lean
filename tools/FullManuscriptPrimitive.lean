import MatrixSpencer.KSFullManuscriptExplicit

/- Independent checks against the original complex-vector Parseval input,
entrywise squared norm, literal full signs, original matrix sum and actual
returned-output event. All dimensions are quantified, including zero. -/
open Matrix MatrixSpencer
open scoped BigOperators Matrix.Norms.L2Operator
noncomputable section
namespace KSFullPrimitiveAudit
variable {N d : ℕ}

theorem returned_signing (v : Fin N → Fin d → ℂ)
    (hp : (∑ i, (fun a b : Fin d => v i a * star (v i b))) = (1 : Matrix (Fin d) (Fin d) ℂ))
    {ε : ℝ} (hε : 0 ≤ ε) (hsize : ∀ i, (∑ j, Complex.normSq (v i j)) ≤ ε)
    (r : ℕ) (z : KSFullManuscriptExplicit.Draws v hp r) (σ : Fin N → ℝ)
    (hout : KSFullManuscriptExplicit.output v hp r z = some σ) :
    (∀ i, σ i = 1 ∨ σ i = -1) ∧
      ‖Matrix.toEuclideanCLM (𝕜 := ℂ)
        (∑ i, σ i • (fun a b : Fin d => v i a * star (v i b)))‖ ≤ 9*(16*Real.sqrt 2+5)*Real.sqrt ε := by
  have hbound : ∀ i, ‖KSRankOne.atom (v i)‖ ≤ ε := by
    intro i
    rw [KSRankOne.atom_norm, KSRankOne.realTrace_atom]
    exact hsize i
  exact KSFullManuscriptExplicit.output_sound v hp hε hbound r z σ hout

theorem actual_success_event (v : Fin N → Fin d → ℂ)
    (hp : (∑ i, (fun a b : Fin d => v i a * star (v i b))) = (1 : Matrix (Fin d) (Fin d) ℂ))
    (r : ℕ) : 1-(15/56 : ℝ)^r ≤ ∑ z : KSFullManuscriptExplicit.Draws v hp r,
      KSFullManuscriptExplicit.drawWeight v hp r z *
        (if (KSFullManuscriptExplicit.output v hp r z).isSome then 1 else 0) :=
  KSFullManuscriptExplicit.output_event_probability_ge v hp r

theorem weights_are_probabilities (v : Fin N → Fin d → ℂ)
    (hp : (∑ i, (fun a b : Fin d => v i a * star (v i b))) = (1 : Matrix (Fin d) (Fin d) ℂ))
    (r : ℕ) :
    (∀ z : KSFullManuscriptExplicit.Draws v hp r, 0 ≤ KSFullManuscriptExplicit.drawWeight v hp r z) ∧
      (∑ z : KSFullManuscriptExplicit.Draws v hp r, KSFullManuscriptExplicit.drawWeight v hp r z) = 1 :=
  ⟨KSFullManuscriptExplicit.drawWeight_nonneg v hp r, KSFullManuscriptExplicit.drawWeight_sum v hp r⟩

#print axioms returned_signing
#print axioms actual_success_event
#print axioms weights_are_probabilities
end KSFullPrimitiveAudit

import MatrixSpencer.KSFullManuscriptWeaver
open MatrixSpencer
open scoped BigOperators InnerProductSpace
noncomputable section
namespace FullManuscriptWeaverPrimitive
variable {N d : ℕ}

theorem full_weaver :
    ∃η θ : ℝ, 2 ≤ η ∧ 0 < θ ∧
      ∀(N d : ℕ) (w : Fin N → EuclideanSpace ℂ (Fin d)),
        (∀i, ‖w i‖ ≤ 1) →
        (∀u : EuclideanSpace ℂ (Fin d), ‖u‖ = 1 → (∑i, ‖inner ℂ u (w i)‖^2) = η) →
        ∃S : Finset (Fin N), ∀u : EuclideanSpace ℂ (Fin d), ‖u‖ = 1 →
          (∑i ∈ S, ‖inner ℂ u (w i)‖^2) ≤ η-θ ∧
          (∑i ∈ Sᶜ, ‖inner ℂ u (w i)‖^2) ≤ η-θ :=
  KSFullManuscriptWeaver.weaver_KS2

theorem full_returned_partition (w : Fin N → EuclideanSpace ℂ (Fin d))
    (hw : ∀i, ‖w i‖ ≤ 1)
    (hp : ∀u : EuclideanSpace ℂ (Fin d), ‖u‖=1 → (∑i, ‖inner ℂ u (w i)‖^2)=1048576)
    (r : ℕ) (z : KSFullManuscriptWeaver.Draws w hp r) (S : Finset (Fin N))
    (ho : KSFullManuscriptWeaver.output w hp r z = some S) :
    ∀u : EuclideanSpace ℂ (Fin d), ‖u‖ = 1 →
      (∑i ∈ S, ‖inner ℂ u (w i)‖^2) ≤ 786432 ∧
      (∑i ∈ Sᶜ, ‖inner ℂ u (w i)‖^2) ≤ 786432 := by
  simpa only [KSManuscriptWeaverTools.eta,KSManuscriptWeaverTools.theta,show (1048576 : ℝ)-262144=786432 by norm_num]
    using KSFullManuscriptWeaver.output_sound w hp hw r z S ho

theorem full_event (w : Fin N → EuclideanSpace ℂ (Fin d))
    (hp : ∀u : EuclideanSpace ℂ (Fin d), ‖u‖=1 → (∑i, ‖inner ℂ u (w i)‖^2)=1048576)
    (r : ℕ) : 1-(15/56 : ℝ)^r ≤ ∑z : KSFullManuscriptWeaver.Draws w hp r,
      KSFullManuscriptWeaver.drawWeight w hp r z *
        (if (KSFullManuscriptWeaver.output w hp r z).isSome then 1 else 0) :=
  KSFullManuscriptWeaver.output_event_probability_ge w hp r

#print axioms full_weaver
#print axioms full_returned_partition
#print axioms full_event
end FullManuscriptWeaverPrimitive

import MatrixSpencer.KSExplicitWeaver
import Lean

/-! Verification tooling only: inspect actual transitive project dependencies.
The finite-walk theorem must use its numerical controller and entropy proof,
and the Weaver corollary must use this finite-walk success theorem. -/

open Lean Meta

partial def walkProjectDependencies (todo : List Name) (seen : NameSet := {}) : MetaM NameSet := do
  match todo with
  | [] => return seen
  | name :: todo =>
    let inProject := (`MatrixSpencer).isPrefixOf name ||
      (`KadisonSingerOriginal).isPrefixOf name ||
      name.toString.startsWith "_private.MatrixSpencer."
    if seen.contains name || !inProject then
      walkProjectDependencies todo seen
    else
      let info ← getConstInfo name
      let children := info.type.getUsedConstants.toList ++
        (info.value?.map (fun e => e.getUsedConstants.toList)).getD []
      walkProjectDependencies (children ++ todo) (seen.insert name)

run_cmd Lean.Elab.Command.liftTermElabM do
  let success ← walkProjectDependencies
    [`MatrixSpencer.KSExplicitWalkAlgorithm.output_event_probability_ge]
  let weaver ← walkProjectDependencies [`MatrixSpencer.KSExplicitWeaver.weaver_KS2]
  for name in [
      `MatrixSpencer.KSInputJointBounds.jointBounds,
      `MatrixSpencer.KSDebitNumericalController.controller,
      `MatrixSpencer.KSDebitNumericalValue.controller_accuracy,
      `MatrixSpencer.KSNumericalDensityRun.coordinateRun_accuracy,
      `MatrixSpencer.KSDebitNumericalDrift.localPotentialDrift,
      `MatrixSpencer.KSDebitEntropyRun.expectedMovements_le,
      `MatrixSpencer.KSDebitWalkRetry.successProbability_from_zero_ge] do
    unless success.contains name do
      throwError "Actual finite-walk proof is missing required dependency {name}."
  for name in [`MatrixSpencer.KSExplicitWeaver.exists_output,
      `MatrixSpencer.KSExplicitWalkAlgorithm.output_event_probability_ge,
      `MatrixSpencer.KSExplicitWalkAlgorithm.output_sound] do
    unless weaver.contains name do
      throwError "Weaver's final theorem must use the actual successful finite draw: {name}."
  for name in [
      `MatrixSpencer.kadison_singer_eighth,
      `MatrixSpencer.kadison_singer_spin_mixed,
      `MatrixSpencer.KSSpinVertex.maxFrozen_isVertex,
      `MatrixSpencer.KSFinalAssembly.spin_signing_of_maxFrozen_vertex,
      `KadisonSingerOriginal.weaver_matrix,
      `KadisonSingerOriginal.weaver_unit_energy,
      `KadisonSingerOriginal.weaver_KS2] do
    if success.contains name || weaver.contains name then
      throwError "The actual walk route uses an earlier signing existence conclusion: {name}."
  logInfo "KS_WALK_ROUTE_CHECKED"

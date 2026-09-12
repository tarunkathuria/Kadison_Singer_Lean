import MatrixSpencer.KSFullManuscriptExplicit
import Lean

open Lean
namespace KSFullManuscriptRoutes

def inProject (n : Name) : Bool :=
  (`MatrixSpencer).isPrefixOf n || n.toString.startsWith "_private.MatrixSpencer."

def inspectedData (n : Name) : Bool :=
  inProject n || (`Matrix.IsHermitian).isPrefixOf n || n == `CFC.sqrt

-- A syntactic operation-route guard. Theorem bodies are excluded from the
-- data scan; this is not an extraction or real-RAM execution theorem.
partial def dataClosure (todo : List Name) (seen : NameSet := {}) : CoreM NameSet := do
  match todo with
  | [] => return seen
  | n :: rest =>
    if seen.contains n then return ← dataClosure rest seen
    let info ← getConstInfo n
    let children := match info with
      | .thmInfo _ => []
      | _ => info.value?.toList.flatMap (fun e => e.getUsedConstants.toList.filter inspectedData)
    dataClosure (children ++ rest) (seen.insert n)

partial def proofClosure (todo : List Name) (seen : NameSet := {}) : CoreM NameSet := do
  match todo with
  | [] => return seen
  | n :: rest =>
    if seen.contains n || !inProject n then return ← proofClosure rest seen
    let info ← getConstInfo n
    let children := info.type.getUsedConstants.toList ++
      info.value?.toList.flatMap (fun e => e.getUsedConstants.toList)
    proofClosure (children ++ rest) (seen.insert n)

run_cmd Lean.Elab.Command.liftCoreM do
  let data ← dataClosure [`MatrixSpencer.KSFullManuscriptExplicit.output,
    `MatrixSpencer.KSFullManuscriptExplicit.drawWeight]
  for n in [
      `MatrixSpencer.KSEighthManuscriptPreprocess.epsilon,
      `MatrixSpencer.KSFullManuscriptAlgorithm.output,
      `MatrixSpencer.KSFullManuscriptController.numericalDirection,
      `MatrixSpencer.KSFullManuscriptHessian.matrixReport,
      `MatrixSpencer.KSFullManuscriptHessian.weighted,
      `MatrixSpencer.KSFullManuscriptDebitValue.stateReport,
      `MatrixSpencer.KSFullManuscriptValueOracle.report,
      `MatrixSpencer.KSFullManuscriptBisection.run,
      `MatrixSpencer.KSFullManuscriptEllipsoidRun.run,
      `MatrixSpencer.KSFullManuscriptPSDSeparation.report,
      `MatrixSpencer.KSJacobiIteration.run,
      `MatrixSpencer.KSJacobiRotation.cosine,
      `MatrixSpencer.KSDebitWalkRun.step,
      `MatrixSpencer.KSDebitMovement.proposal,
      `MatrixSpencer.KSFullManuscriptAcceptance.accepts,
      `MatrixSpencer.KSDebitWalkRetry.FiniteRetry.firstAccepted] do
    unless data.contains n do throwError "Missing actual numerical operation: {n}"
    logInfo m!"KS_FULL_MANUSCRIPT_DATA_REQUIRED {n}"
  for n in data.toList do
    if n == `CFC.sqrt || (`Matrix.IsHermitian).isPrefixOf n ||
      n == `MatrixSpencer.hermitianDensityOptimizer ||
      n == `MatrixSpencer.ownerPotential ||
      n == `MatrixSpencer.KSDebitNumericalController.numericalDirection ||
      n == `MatrixSpencer.KSEighthManuscriptPreprocess.restore ||
      n == `MatrixSpencer.KSEighthManuscriptPreprocess.family ||
      (n.toString.splitOn "maxFrozen").length > 1 then
      throwError "Analytic oracle, changed label set or replaced direction in numerical data: {n}"
  let proof ← proofClosure [`MatrixSpencer.KSFullManuscriptExplicit.output_sound,
    `MatrixSpencer.KSFullManuscriptExplicit.output_event_probability_ge]
  for n in [
      `MatrixSpencer.KSFullManuscriptValueOracle.report_accuracy,
      `MatrixSpencer.KSFullManuscriptPSDSeparation.report_correct,
      `MatrixSpencer.KSFullManuscriptDebitValue.stateReport_accuracy,
      `MatrixSpencer.KSFullManuscriptTaylor.line_fourth_le,
      `MatrixSpencer.KSFullManuscriptQueries.query_accuracy,
      `MatrixSpencer.KSFullManuscriptRayleigh.liveDirection_hessian_le,
      `MatrixSpencer.KSFullManuscriptDrift.localPotentialDrift,
      `MatrixSpencer.KSDebitEntropyRun.cutoffProbability_from_zero_le,
      `MatrixSpencer.KSFullManuscriptAcceptance.acceptanceProbability_from_zero_ge,
      `MatrixSpencer.KSFullManuscriptAlgorithm.attempt_acceptance_ge,
      `MatrixSpencer.KSDebitWalkRetry.FiniteRetry.failureProbability_eq_pow] do
    unless proof.contains n do throwError "Missing numerical correctness/probability proof: {n}"
    logInfo m!"KS_FULL_MANUSCRIPT_PROOF_REQUIRED {n}"
  for n in [
      `MatrixSpencer.kadison_singer_eighth,
      `MatrixSpencer.kadison_singer_spin_mixed,
      `MatrixSpencer.KSEighthVertex.maxFrozen_isVertex,
      `MatrixSpencer.KSSpinVertex.maxFrozen_isVertex,
      `MatrixSpencer.KSEighthExplicitAlgorithm.output_event_probability_ge,
      `MatrixSpencer.KSExplicitWalkAlgorithm.output_event_probability_ge] do
    if proof.contains n then throwError "Substituted prior signing/algorithm conclusion: {n}"
  logInfo m!"KS_FULL_MANUSCRIPT_ROUTE_CHECKED {data.toList.length} data declarations; {proof.toList.length} project proof declarations"
end KSFullManuscriptRoutes

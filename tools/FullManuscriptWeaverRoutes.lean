import MatrixSpencer.KSFullManuscriptWeaver
import Lean

open Lean
namespace KSFullManuscriptWeaverRoutes

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
  let data ← dataClosure [`MatrixSpencer.KSFullManuscriptWeaver.output,
    `MatrixSpencer.KSFullManuscriptWeaver.drawWeight]
  for n in [`MatrixSpencer.KSFullManuscriptExplicit.output,
      `MatrixSpencer.KSManuscriptWeaverTools.positiveSet,
      `MatrixSpencer.KSManuscriptWeaverTools.scaled] do
    unless data.contains n do throwError "Missing actual signing-to-partition operation: {n}"
  let proof ← proofClosure [`MatrixSpencer.KSFullManuscriptWeaver.weaver_KS2,
    `MatrixSpencer.KSFullManuscriptWeaver.output_event_probability_ge]
  for n in [`MatrixSpencer.KSFullManuscriptExplicit.output_sound,
      `MatrixSpencer.KSFullManuscriptExplicit.output_event_probability_ge,
      `MatrixSpencer.KSManuscriptWeaverTools.frame_identity_of_unit_energy,
      `MatrixSpencer.KSManuscriptWeaverTools.fixed_partition_bounds] do
    unless proof.contains n do throwError "Missing actual walk-to-Weaver proof: {n}"
  for n in [`MatrixSpencer.KSExplicitWeaver.weaver_KS2,
      `MatrixSpencer.KSEighthExplicitWeaver.weaver_KS2,
      `MatrixSpencer.KSExplicitWalkAlgorithm.output_event_probability_ge,
      `MatrixSpencer.KSEighthExplicitAlgorithm.output_event_probability_ge,
      `MatrixSpencer.kadison_singer_spin_mixed,
      `MatrixSpencer.kadison_singer_eighth] do
    if proof.contains n then throwError "Prior signing conclusion substituted: {n}"
  logInfo m!"KS_FULL_MANUSCRIPT_WEAVER_ROUTE_CHECKED {data.toList.length} data declarations; {proof.toList.length} project proof declarations"
end KSFullManuscriptWeaverRoutes

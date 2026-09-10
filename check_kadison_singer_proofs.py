#!/usr/bin/env python3
"""Verify both exact Kadison–Singer signing theorems and their project closure.

Compiling helper lemmas or checking a conditional theorem cannot yield VERIFIED.
The old verified checkers and Lean sources are read but never modified.
"""

from __future__ import annotations

import argparse
from datetime import datetime, timezone
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys

from check_rectangular_proof import (
    ALLOWED_AXIOMS, local_sources, parse_axioms, source_admissions,
    source_fingerprint,
)

ROOT = Path(__file__).resolve().parent
MODULE = "MatrixSpencer.KadisonSinger"
TARGETS = (
    ("eighth", "MatrixSpencer.kadison_singer_eighth", "MatrixSpencer.ksEighthStatement", "144"),
    ("spin_mixed", "MatrixSpencer.kadison_singer_spin_mixed", "MatrixSpencer.ksSpinMixedStatement", "(16 * Real.sqrt 2 + 2)"),
)


def fingerprint() -> dict[str, str]:
    result = source_fingerprint()
    result[Path(__file__).name] = hashlib.sha256(Path(__file__).read_bytes()).hexdigest()
    return dict(sorted(result.items()))


def primitive_probe(targets=TARGETS, module=MODULE) -> str:
    text = f"import {module}\nimport Lean\n\nopen scoped BigOperators Matrix\n\n"
    for key, target, statement, constant in targets:
        # Deliberately use primitive matrices, entries, signs, and CLM norm;
        # do not call any project-defined predicate in the expected statement.
        expected = f"KSIndependentVerification.Expected_{key}"
        text += f'''namespace KSIndependentVerification
def Expected_{key} : Prop :=
  ∀ (N d : ℕ) (ε : ℝ), 0 < ε →
    ∀ A : Fin N → Matrix (Fin d) (Fin d) ℂ,
      (∀ i, ∃ v : Fin d → ℂ, ∀ a b, A i a b = v a * star (v b)) →
      (∑ i, A i) = 1 →
      (∀ i, ‖Matrix.toEuclideanCLM (n := Fin d) (𝕜 := ℂ) (A i)‖ ≤ ε) →
      ∃ s : Fin N → ℝ,
        (∀ i, s i = 1 ∨ s i = -1) ∧
        ‖Matrix.toEuclideanCLM (n := Fin d) (𝕜 := ℂ)
          (∑ i : Fin N, (s i : ℂ) • A i)‖ ≤ {constant} * Real.sqrt ε
end KSIndependentVerification

run_cmd Lean.Elab.Command.liftTermElabM do
  let info ← Lean.getConstInfo `{target}
  match info with
  | .thmInfo _ => pure ()
  | _ => throwError "Final target must be a theorem declaration."
  unless (← Lean.Meta.isDefEq info.type (Lean.mkConst `{statement})) do
    throwError "Final theorem has extra hypotheses or the wrong target type."
  unless (← Lean.Meta.isDefEq info.type (Lean.mkConst `{expected})) do
    throwError "Final theorem differs from the independently frozen primitive statement."

example : {expected} := {target}
#print {expected}
#check ({target} : {statement})
#eval IO.println "KS_AXIOMS_BEGIN_{key}"
#print axioms {target}
#eval IO.println "KS_AXIOMS_END_{key}"

'''
    return text


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--timeout", type=int, default=3600,
                        help="Maximum seconds per build, statement check, or replay command")
    parser.add_argument("--route", choices=("both", "eighth", "spin-mixed"), default="both",
                        help="The exact proof route(s) to verify; defaults to both")
    args = parser.parse_args()
    if args.timeout <= 0:
        parser.error("--timeout must be positive")
    targets = TARGETS if args.route == "both" else tuple(
        t for t in TARGETS if t[0] == args.route.replace("-", "_"))
    module = {"both": MODULE, "eighth": "MatrixSpencer.KSEighthMain",
              "spin-mixed": "MatrixSpencer.KSSpinMain"}[args.route]
    audit = ROOT / ".verification" / ("kadison_singer_" + args.route.replace("-", "_"))
    audit.mkdir(parents=True, exist_ok=True)
    result = {
        "targets": [target for _, target, _, _ in targets],
        "module": module,
        "route": args.route,
        "allowed_axioms": sorted(ALLOWED_AXIOMS),
        "started_at": datetime.now(timezone.utc).isoformat(),
        "status": "INCOMPLETE", "commands": [],
    }

    def finish(status: str, reason: str, code: int) -> int:
        result.update(status=status, reason=reason, exit_code=code,
                      finished_at=datetime.now(timezone.utc).isoformat())
        (audit / "last_result.json").write_text(json.dumps(result, indent=2) + "\n")
        print(f"{status}: {reason}", flush=True)
        print(f"Audit record: {audit / 'last_result.json'}", flush=True)
        return code

    initial = fingerprint()
    result["source_sha256"] = initial
    sources = local_sources()
    result["source_files_scanned"] = [str(p.relative_to(ROOT)) for p in sources]
    admissions = [f"{p.relative_to(ROOT)}:{line}: {token}"
                  for p in sources for line, token in source_admissions(p.read_text())]
    result["source_admissions"] = admissions
    if admissions:
        return finish("FAILED", "Local source contains admission tokens: " + "; ".join(admissions), 1)
    wrapper = ROOT / "run_lake.sh"
    adapter = ROOT / "tools" / "Replay.lean"
    if not wrapper.is_file() or not adapter.is_file():
        return finish("INCOMPLETE", "Required Lake wrapper or project kernel replay adapter is missing", 2)
    env = os.environ.copy()
    local_elan = ROOT.parent / ".tools" / "elan"
    if local_elan.is_dir():
        env["ELAN_HOME"] = str(local_elan)
        env["PATH"] = str(local_elan / "bin") + os.pathsep + env.get("PATH", "")

    def run(label: str, command: list[str]) -> tuple[int, str]:
        print(f"Checking {label}...", flush=True)
        try:
            completed = subprocess.run(command, cwd=ROOT, env=env, text=True,
                                       stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                                       timeout=args.timeout, check=False)
            code, output = completed.returncode, completed.stdout
        except subprocess.TimeoutExpired as exc:
            captured = exc.stdout or b""
            output = captured.decode(errors="replace") if isinstance(captured, bytes) else captured
            output += f"\nCommand exceeded {args.timeout} seconds.\n"
            code = 124
        except OSError as exc:
            code, output = 127, str(exc) + "\n"
        (audit / f"{label}.log").write_text(output)
        result["commands"].append({"label": label, "argv": command, "exit_code": code})
        if output:
            print(output, end="" if output.endswith("\n") else "\n", flush=True)
        return code, output

    code, _ = run("build", [str(wrapper), "build", module])
    if code:
        return finish("INCOMPLETE", "The selected final proof routes have not built successfully", 2)
    probe = audit / "IndependentStatements.lean"
    probe.write_text(primitive_probe(targets, module))
    result["primitive_probe_sha256"] = hashlib.sha256(probe.read_bytes()).hexdigest()
    code, output = run("final_statements", [str(wrapper), "env", "lean", str(probe)])
    if code:
        return finish("INCOMPLETE", "A final theorem is absent or fails the primitive statement comparison", 2)
    actual = {}
    for key, target, _, _ in targets:
        try:
            axioms = parse_axioms(output, f"KS_AXIOMS_BEGIN_{key}", f"KS_AXIOMS_END_{key}")
        except ValueError as exc:
            return finish("FAILED", f"{target}: {exc}", 1)
        actual[target] = sorted(axioms)
        if axioms - ALLOWED_AXIOMS:
            return finish("FAILED", f"{target} depends on disallowed axioms: " +
                          ", ".join(sorted(axioms - ALLOWED_AXIOMS)), 1)
    result["actual_axioms"] = actual
    code, output = run("kernel_replay", [str(wrapper), "env", "lean", "--run", str(adapter), module])
    if code or "PROJECT_CLOSURE_REPLAYED:" not in output or "PANIC" in output:
        return finish("FAILED", "Mandatory replay of all project modules in the import closure failed", 1)
    result["kernel_replay"] = "all project modules in the target import closure, against imported environments"
    if fingerprint() != initial:
        return finish("INCOMPLETE", "Sources or verification code changed during verification; rerun required", 2)
    return finish("VERIFIED", f"Selected route {args.route}: exact primitive signing statement(s) proved with only standard axioms; project closure replay passed", 0)


if __name__ == "__main__":
    sys.exit(main())

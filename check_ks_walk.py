#!/usr/bin/env python3
"""Fail-closed verification of the explicit finite KS walk and Weaver KS2.

Requires independent primitive statement checks, actual proof-route checks,
standard axioms, and replay of every project module in the final import closure.
This verifies mathematical correctness and success probability, not cost bounds.
"""

from __future__ import annotations

import argparse
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import re
import subprocess
import sys

from check_proof import source_admissions

ROOT = Path(__file__).resolve().parent
AUDIT = ROOT / ".verification/walk"
MODULES = ('MatrixSpencer.KSExplicitWalkAlgorithm', 'MatrixSpencer.KSExplicitWeaver', 'MatrixSpencer.KSSpinMain')
ALLOWED = {"propext", "Classical.choice", "Quot.sound"}


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def project_closure() -> list[str]:
    seen: set[str] = set()

    def visit(module: str) -> None:
        if not module.startswith("MatrixSpencer") or module in seen:
            return
        path = ROOT / (module.replace(".", "/") + ".lean")
        if not path.is_file():
            raise ValueError(f"Missing project source: {module}")
        seen.add(module)
        for line in path.read_text().splitlines():
            if line.startswith("import "):
                for name in line.removeprefix("import ").split("--", 1)[0].split():
                    visit(name)

    for module in MODULES:
        visit(module)
    return sorted(seen)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--timeout", type=int, default=7200)
    args = parser.parse_args()
    if args.timeout <= 0:
        parser.error("timeout must be positive")
    AUDIT.mkdir(parents=True, exist_ok=True)
    result: dict = {
        "status": "INCOMPLETE", "modules": MODULES,
        "started_at": datetime.now(timezone.utc).isoformat(),
        "commands": [], "allowed_axioms": sorted(ALLOWED),
        "runtime_or_bit_complexity_verified": False,
    }

    def finish(status: str, reason: str, code: int) -> int:
        result.update(status=status, reason=reason, exit_code=code,
                      finished_at=datetime.now(timezone.utc).isoformat())
        (AUDIT / "verification.json").write_text(json.dumps(result, indent=2) + "\n")
        print(f"{status}: {reason}", flush=True)
        return code

    def run(label: str, command: list[str]) -> str:
        print(f"Checking {label}...", flush=True)
        with (AUDIT / (label + ".log")).open("w") as stream:
            proc = subprocess.run(command, cwd=ROOT, stdout=stream,
                                  stderr=subprocess.STDOUT, timeout=args.timeout)
        result["commands"].append({"label": label, "argv": command,
                                   "exit_code": proc.returncode})
        if proc.returncode:
            raise ValueError(f"{label} failed with exit {proc.returncode}")
        return (AUDIT / (label + ".log")).read_text()

    try:
        baseline = json.loads((ROOT / "SOURCE_MANIFEST.json").read_text())["copied_files_sha256"]
        changed = [p for p, h in baseline.items() if digest(ROOT / p) != h]
        if changed:
            raise ValueError("Distribution sources changed: " + ", ".join(changed))
        result["distribution_fingerprints_checked"] = len(baseline)
        closure = project_closure()
        result["project_import_closure"] = closure
        source_paths = [m.replace(".", "/") + ".lean" for m in closure]
        required = ["check_ks_walk.py", "check_proof.py", "tools/Replay.lean",
                    "tools/WalkIndependentStatements.lean",
                    "tools/WalkRoutes.lean",
                    "lean-toolchain", "lakefile.toml", "lake-manifest.json", "run_lake.sh", "SOURCE_MANIFEST.json"]
        initial = baseline | {p: digest(ROOT / p) for p in source_paths + required}
        result["source_sha256"] = initial
        admissions = {p: source_admissions((ROOT / p).read_text()) for p in source_paths}
        result["source_admissions"] = {p: a for p, a in admissions.items() if a}
        if result["source_admissions"]:
            raise ValueError("An admission token occurs in the final project closure")
        wrapper = str(ROOT / "run_lake.sh")
        run("build", [wrapper, "build", *MODULES])
        probe = run("independent_statements", [wrapper, "env", "lean",
                    str(ROOT / "tools/WalkIndependentStatements.lean")])
        if "KS_WALK_PRIMITIVE_STATEMENTS_CHECKED" not in probe:
            raise ValueError("The final primitive statement check did not finish")
        if "sorryAx" in probe:
            raise ValueError("An admitted axiom occurs in the final statements")
        reports = re.findall(r"depends on axioms:\s*\[([^\]]*)\]", probe)
        if len(reports) < 3:
            raise ValueError("Missing endpoint axiom reports")
        actual = {name.strip() for report in reports for name in report.split(",")}
        if actual - ALLOWED:
            raise ValueError("Disallowed final axiom dependencies: " + str(actual - ALLOWED))
        result["actual_axioms"] = sorted(actual)
        routes = run("routes", [wrapper, "env", "lean", str(ROOT / "tools/WalkRoutes.lean")])
        if "KS_WALK_ROUTE_CHECKED" not in routes:
            raise ValueError("The actual numerical-walk proof-route check did not finish")
        replay = run("kernel_replay", [wrapper, "env", "lean", "--run",
                     str(ROOT / "tools/Replay.lean"), *MODULES])
        checked = re.findall(r"^REPLAYED ([^:]+):", replay, re.M)
        audited = re.findall(r"^PROJECT_AXIOMS_CHECKED ([^:]+):", replay, re.M)
        if sorted(checked) != closure or sorted(audited) != closure or "PANIC" in replay:
            raise ValueError("Replay did not check every module in the actual final import closure")
        result["kernel_replay"] = {
            "mode": "Every project module replayed against imports in the installed Lean kernel",
            "module_count": len(checked), "independent_kernel_implementation": False,
        }
        changed = [p for p, h in initial.items() if digest(ROOT / p) != h]
        if changed:
            raise ValueError("Verification inputs changed during the check: " + ", ".join(changed))
        result["final_algorithm_theorem_verified"] = True
        return finish("VERIFIED", "Primitive input-only finite-output correctness and success "
                      "probability, literal Weaver KS2, actual numerical-walk proof route, and "
                      "the complete project import closure passed verification", 0)
    except (OSError, ValueError, KeyError, subprocess.TimeoutExpired) as exc:
        return finish("INCOMPLETE", str(exc), 2)


if __name__ == "__main__":
    sys.exit(main())

#!/usr/bin/env python3
"""Verify a self-contained polynomial-runtime extension from shipped sources."""
from pathlib import Path
import datetime
import hashlib
import json
import re
import subprocess
import sys

root = Path(__file__).resolve().parents[1]
manifest_path = root / "POLYNOMIAL_RUNTIME_MANIFEST.json"
manifest = json.loads(manifest_path.read_text())
out = root / ".verification" / "polynomial_runtime_20260911"
out.mkdir(parents=True, exist_ok=True)


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def run(args, filename):
    with (out / filename).open("w") as stream:
        result = subprocess.run(args, cwd=root, stdout=stream, stderr=subprocess.STDOUT)
    if result.returncode:
        raise RuntimeError(f"Command failed; inspect {out / filename}")


for filename, expected in manifest["source_sha256"].items():
    path = root / filename
    if not path.is_file() or digest(path) != expected:
        raise RuntimeError(f"Source hash mismatch: {filename}")

run([str(root / "run_lake.sh"), "build", *manifest["endpoints"]], "build.log")
run([str(root / "run_lake.sh"), "env", "lean", "tools/PolynomialRuntimeStatements.lean"], "statements.log")
run([str(root / "run_lake.sh"), "env", "lean", "--run", "tools/PolynomialRuntimeClosureReplay.lean",
     *manifest["modules"]], "replay.log")

statements = (out / "statements.log").read_text()
dependencies = re.findall(r"depends on axioms:\s*\[([^\]]*)\]", statements)
allowed = {"propext", "Classical.choice", "Quot.sound"}
if len(dependencies) != manifest["axiom_probes"]:
    raise RuntimeError("Missing endpoint axiom probes")
for declaration in dependencies:
    used = {x.strip() for x in declaration.split(",") if x.strip()}
    if not used <= allowed:
        raise RuntimeError(f"Unexpected axioms: {used - allowed}")
replay = (out / "replay.log").read_text()
counts = re.findall(r"REPLAYED .*?: (\d+) local declarations", replay)
if len(counts) != len(manifest["modules"]):
    raise RuntimeError("Kernel replay did not cover the shipped proof closure")
if "REPLAY_BASE_EXTERNAL_ONLY:" not in replay or "PROJECT_CLOSURE_REPLAYED:" not in replay:
    raise RuntimeError("Missing external-only-base closure replay certificate")
if "sorryAx" in statements or "sorryAx" in replay:
    raise RuntimeError("An admitted proof entered the checked theorem closure")

receipt = {
    "status": "VERIFIED",
    "checked_at_utc": datetime.datetime.now(datetime.timezone.utc).isoformat(),
    "scope": manifest["scope"],
    "model": "Exact real-RAM arithmetic with square root, finite uniform random draws, and the explicitly permitted polynomial convex solver contract.",
    "endpoints": manifest["endpoints"],
    "project_modules": len(counts),
    "replayed_project_declarations": sum(map(int, counts)),
    "axiom_probes": len(dependencies),
    "allowed_axioms": sorted(allowed),
    "manifest_sha256": digest(manifest_path),
    "source_sha256": manifest["source_sha256"],
    "evidence_sha256": {name: digest(out / name) for name in ["build.log", "statements.log", "replay.log"]},
}
(out / "verification.json").write_text(json.dumps(receipt, indent=2) + "\n")
print(f"VERIFIED: {len(counts)} project modules, {sum(map(int, counts))} replayed declarations")

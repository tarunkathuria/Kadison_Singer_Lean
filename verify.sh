#!/bin/sh
set -eu
matrix_repo_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
cd "$matrix_repo_dir"
exec python3 -B check_kadison_singer_proofs.py --route spin-mixed --timeout 3600 "$@"

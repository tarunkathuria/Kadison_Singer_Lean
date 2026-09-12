#!/bin/sh
set -eu
matrix_repo_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
cd "$matrix_repo_dir"
python3 -B check_kadison_singer_proofs.py --route spin-mixed --timeout 7200 "$@"
exec python3 -B check_ks_walk.py --timeout 7200 "$@"

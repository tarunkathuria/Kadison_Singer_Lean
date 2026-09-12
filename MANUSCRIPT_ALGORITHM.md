# Full-cube manuscript algorithm milestone

This additive extension verifies the actual ellipsoid value routine, unweighted finite Hessian stencils, weighted Jacobi direction, sticky preparation, fixed movement step, finite cutoff and numerical acceptance of the full-cube KS manuscript algorithm. Previous existence and projected-gradient algorithm sources, checkers and receipts remain intact.

The root is `MatrixSpencer.KSFullManuscriptExplicit`. Every original label is retained and signed in every successful output, with discrepancy at most9(16sqrt(2)+5)sqrt(epsilon). The actual signing-valued output succeeds with probability at least1-(15/56)^r after r independent trials. Dimension zero is handled directly. All matrix sizes and every derivative/accuracy/drift premise are supplied by primitive inputs.

Run `python3 check_ks_full_manuscript.py` for the269-module signing endpoint, or `python3 check_ks_full_manuscript_weaver.py` to additionally verify the original Weaver partition assertion with its271-module closure. Both check independent primitive statements, actual numerical/proof routes and all local kernel/axiom obligations. Every local source is included in this folder; Lean/mathlib dependencies are pinned by the Lake files.

See `KS_FULL_MANUSCRIPT_PROOF.md` for correspondence and the manifests/provenance for evidence. The actual SDP size is formalized and the user allows polynomial-time convex solution. A total polynomial real-RAM operation-count theorem and extracted executable are not claimed.

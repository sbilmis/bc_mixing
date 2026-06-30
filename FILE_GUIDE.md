# File guide for the \(B_c\) mixing project

This file explains what the main files in this folder are for.  The project
contains several related but distinct calculations:

1. the main momentum-space QCD sum-rule analysis;
2. coordinate-space cross-checks, including an Azizi-style implementation and
   a more direct/raw implementation;
3. perturbative \(O(\alpha_s)\) NLO diagnostic work;
4. dimension-six cross-line backup/output material;
5. plotting and publication artifacts.

Nothing in the cleanup pass was deleted.  Clearly generated or superseded
local files were moved into `archive/2026-06-30_redundant_generated/`.

## Main momentum-space calculation

These are the central files for the paper-level LO + condensate analysis in
momentum space.

| File | Role |
|---|---|
| `BcMixingMomentum.wl` | Main Wolfram package for the momentum-space calculation. Defines the \(A\) and \(B\) currents, perturbative spectral densities, Borel moments, condensate pieces, mixing-angle evaluation, scans, plotting helpers, and Monte Carlo utilities. |
| `BcMixingMomentum.nb` | Notebook interface for the momentum-space calculation. Useful for interactive checks and development. |
| `BcMixingMomentumPlots.nb` | Notebook used for plot exploration and production. |
| `RegenerateBcMixingArtifacts.wl` | Rebuilds standard numerical/plot artifacts from the momentum-space code. |
| `CalculationNotes.tex`, `CalculationNotes.pdf` | General calculation notes for the LO/OPE analysis. |
| `README.md` | Original project-level readme. |

## Coordinate-space cross-checks

These files are for coordinate-space versions/checks of the calculation. They
are not the main paper pipeline, but they were useful cross-checks.

| File | Role |
|---|---|
| `BcMixingCoordinate.wl`, `BcMixingCoordinate.nb` | Coordinate-space implementation/checks. |
| `BcMixingCoordinateAzizi.nb` | Coordinate-space notebook using the Azizi-style input/formulas. This is the “using Azizi” cross-check path. |
| `BcMixingCoordinateDirect.wl`, `BcMixingCoordinateDirect.nb` | Direct/raw coordinate-space method, independent of simply importing the Azizi-style expressions. |
| `BcMixingCoordinateOPE.wl`, `BcMixingCoordinateOPE.nb` | Coordinate-space OPE/convergence checks. |

Typical coordinate-space outputs:

| File pattern | Meaning |
|---|---|
| `BcMixingCoordinateThetaVsM2_WangWindow.*` | Coordinate-space \(\theta(M^2)\) scan in the Wang window. |
| `BcMixingCoordinateThetaVsS0_WangWindow.*` | Coordinate-space \(\theta(s_0)\) scan in the Wang window. |
| `BcMixingCoordinateDirectThetaVsM2_WangWindow.csv` | Direct/raw coordinate-space \(M^2\) scan. |
| `BcMixingCoordinateDirectThetaVsS0_WangWindow.csv` | Direct/raw coordinate-space \(s_0\) scan. |
| `BcMixingCoordinate*MonteCarlo*.csv` | Coordinate-space Monte Carlo sample/summary outputs. |
| `BcMixingCoordinateOPEConvergence_WangWindow.csv` | Coordinate-space OPE convergence data. |

## Perturbative \(O(\alpha_s)\) / NLO diagnostic work

These files are for the follow-up NLO study.  They are not part of the
original LO + condensate arXiv submission unless explicitly promoted later.

| File | Role |
|---|---|
| `BcMixingAlphaS.wl` | Main \(O(\alpha_s)\) workbench, especially the independently validated \(AA\) channel: virtual, real-minus-dipoles, integrated dipoles, UV/IR checks, threshold/Coulomb checks, and \(\overline{\rm MS}\) conversion. |
| `BcMixingAlphaSMixedAB.wl` | Mixed \(AB\) NLO diagnostic workbench: LO trace check, virtual Package-X layer, real subtraction, tensor-current pole bookkeeping, and Borel diagnostics. |
| `BcMixingAlphaSTensorBB.wl` | Imports/matches the two-mass tensor-current result for the \(BB\) channel from the external ancillary files. |
| `AlphaSCalculationNotes.tex`, `AlphaSCalculationNotes.pdf` | Lecture-style notes for the NLO calculation and diagnostics. This now includes the explanation of “earlier LO diagnostic,” “synchronized LO baseline,” and “synchronized NLO diagnostic.” |
| `AlphaSNextStudyNotes.md` | Running notes for the NLO follow-up project. |
| `AlphaSNLOContributionTable.md` | Earlier fixed-input diagnostic table for \(AA\), \(AB\), \(BB\) NLO channel effects. |
| `AlphaSAANLOConvergenceAudit.md` | Audit note for the large \(AA\) NLO correction, including parameter scans and threshold/Coulomb interpretation. |
| `AlphaSSynchronizedNLODiagnostic.md` | Final end-of-session synchronized diagnostic note for \(AA\), \(AB\), and \(BB\) in one common numerical scheme. |

NLO runner/output files:

| File | Role |
|---|---|
| `RunAANLOConvergenceAudit.wl` | Original all-in-one AA convergence scan runner. It was slow because it wrote only after whole scan blocks. |
| `RunAANLOConvergenceAuditIncremental.wl` | Improved incremental/cached AA convergence scan runner; writes rows as soon as they are available. |
| `AlphaS_AA_M2_scan_incremental.csv` | \(AA\) NLO/LO scan versus \(M^2\). |
| `AlphaS_AA_s0_scan_incremental.csv` | \(AA\) NLO/LO scan versus \(s_0\). |
| `AlphaS_AA_mu_scan_incremental.csv` | \(AA\) scale scan. |
| `RunSynchronizedNLODiagnostic.wl` | Runs the synchronized \(AA,AB,BB\) diagnostic in one common setup. |
| `AlphaS_synchronized_NLO_diagnostic.csv` | Main synchronized diagnostic output. |
| `AlphaS_synchronized_NLO_diagnostic_summary.mx` | Wolfram binary summary of the synchronized diagnostic. |
| `AlphaS_synchronized_AA_summary.mx` | Wolfram binary AA synchronized summary. |
| `AlphaS_synchronized_AB_summary.mx` | Wolfram binary AB synchronized summary. |
| `AlphaS_synchronized_BB_summary.mx` | Wolfram binary BB synchronized summary. |
| `AlphaS_AB_MSbar_conversion_split.csv` | Split of the \(AB\) \(\overline{\rm MS}\) mass-conversion term into “normalization fixed” and “normalization-only” pieces. |

Current synchronized NLO diagnostic headline:

\[
\theta_{\rm LO,sync}=44.88^\circ,\qquad
\theta_{\rm NLO,sync\,diag}=39.56^\circ,\qquad
\Delta\theta=-5.32^\circ.
\]

This is still labelled a synchronized diagnostic, not a publication-grade
final NLO prediction, because a fully independent closed-form \(AB\)
\(\overline{\rm MS}\) coefficient remains the final theoretical check.

## Dimension-six material

| File/folder | Role |
|---|---|
| `BcMixingDimension6Complete.wl` | Dimension-six cross-line/open-field calculation infrastructure. |
| `RunD6CrossLineSide.wl` | Runner for dimension-six cross-line side calculations. |
| `d6_chunks/` | Chunked Wolfram outputs for dimension-six cross-line calculations. These are kept because the expressions are long and expensive to regenerate. |
| `SupplementalD6CrossLineBackup.tex`, `SupplementalD6CrossLineBackup.pdf` | Supplemental/backup document for the lengthy D6 cross-line terms. |
| `SupplementalD6CrossLineBackup_README.md` | Notes explaining the D6 backup material. |
| `AppendixCondensateCoefficients.tex` | Appendix-style condensate coefficient expressions. |
| `CondensateCoefficientTeX.txt`, `CondensateCoefficientFunctionsTeX.txt` | Generated TeX/plaintext coefficient expressions used while preparing the appendix. |

Inside `d6_chunks/`, the naming convention is:

| Pattern | Meaning |
|---|---|
| `AA_*`, `AB_*`, `BB_*` | Channel. |
| `c1b2`, `c2b1` | Cross-line condensate topology/order label. |
| `*_001_020.wl`, etc. | Chunked symbolic expression pieces. |
| `*_assembled.wl` | Assembled expression from chunks. |
| `*_borel_integrand.wl` | Borel-integrand form. |
| `*_central_value.wl` | Central-value evaluation. |
| `*_retry*.wl`, `*_fp*.wl` | Retry/fixed-point/intermediate recovery pieces. Kept because they can save recomputation. |

## Publication plotting and numerical data

| File | Role |
|---|---|
| `MakeBcMixingPublicationFigure.py` | Python plotting script for the publication-style stability/contribution figure. |
| `MakeBcMixingMonteCarloPublicationFigure.py` | Python plotting script for the publication-style Monte Carlo histogram. |
| `RunMomentumMonteCarloPublication.wl` | Wolfram runner for publication Monte Carlo samples/summaries. |
| `BcMixingMomentumThetaOrdersCompleteD6VsM2_s0_53.pdf` | Publication-style momentum-space \(\theta(M^2)\) figure including complete D6 diagnostic. |
| `BcMixingMomentumThetaOrdersVsM2_s0_53.pdf` | Earlier momentum-space order-by-order \(\theta(M^2)\) figure. |
| `BcMixingMomentumOPERatiosVsM2_s0_53.pdf` | Older/superseded operations/contributions figure; retained for comparison. |
| `BcMixingMonteCarloHistogramPublication.pdf` | Publication-style Monte Carlo histogram. |
| `BcMixingMonteCarloSamplesPublication.csv` | Monte Carlo samples used for the publication histogram. |
| `BcMixingMonteCarloSummaryPublication.csv` | Summary of the publication Monte Carlo run. |
| `BcMixingMonteCarloHistogram.pdf` | Earlier Monte Carlo histogram. |
| `BcMixingMonteCarloSamples.csv`, `BcMixingMonteCarloSummary.csv` | Earlier Monte Carlo sample/summary outputs. |
| `BcMixingThetaVsM2_WangWindow.*`, `BcMixingThetaVsS0_WangWindow.*` | Momentum-space scan data/plots in the Wang window. |

## References

The `References/` folder contains papers used in the analysis and background
checks.  In particular:

- Azizi et al. for the coordinate-space/Azizi-style comparison;
- Huang and Liu for coordinate-space doubly-heavy spectral-density methods;
- Aliev et al. for axial-vector mixing-angle context;
- LHCb/Aaij references for observed \(B_c(1P)\) states.

## Archive

The local archive is:

```text
archive/2026-06-30_redundant_generated/
```

It contains ignored/generated/superseded files only:

- LaTeX auxiliary files (`*.aux`, `*.log`, `*.toc`, etc.);
- old duplicate scan/Monte Carlo outputs that were already in the ignored
  `old/` folder;
- local downloads such as `X-master.tar.gz`;
- `.DS_Store` files.

The archive contents are intentionally ignored by git, except for a README.
They are kept locally so nothing is deleted.

## Suggested “active” files for future work

For the paper/LO analysis:

- `BcMixingMomentum.wl`
- `MakeBcMixingPublicationFigure.py`
- `MakeBcMixingMonteCarloPublicationFigure.py`
- `AlphaSCalculationNotes.pdf` only if discussing the NLO follow-up.

For the NLO follow-up:

- `BcMixingAlphaS.wl`
- `BcMixingAlphaSMixedAB.wl`
- `BcMixingAlphaSTensorBB.wl`
- `RunSynchronizedNLODiagnostic.wl`
- `AlphaSSynchronizedNLODiagnostic.md`
- `AlphaSCalculationNotes.tex/pdf`

For D6 backup:

- `BcMixingDimension6Complete.wl`
- `RunD6CrossLineSide.wl`
- `d6_chunks/`
- `SupplementalD6CrossLineBackup.tex/pdf`

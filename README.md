# B_c Axial-Vector Mixing Angle Sum Rule

This workspace contains a Mathematica/FeynCalc setup for studying the
mixing angle between the axial-vector \(B_c(1P)\) states, following the
logic of Aliev et al. but using a momentum-space heavy-heavy correlator.

## Notebook Map

Use these three notebooks for production-style runs:

- `BcMixingMomentum.nb`: momentum-space calculation with perturbative,
  \(G^2\), standard single-line dimension-6 \(G^3\), publication stability
  plots, CSV/PDF export, and Monte Carlo uncertainty.  It also reads the cached
  central open-field cross-line \(G^3\) correction from
  `BcMixingDimension6Complete.wl` as an optional audit section.
- `BcMixingCoordinateAzizi.nb`: coordinate-space Azizi/Bessel-Schwinger OPE
  workflow using `BcMixingCoordinateOPE.wl`.  It produces the same style of
  \(M^2\)- and \(s_0\)-stability plots, OPE hierarchy tables, CSV/PDF export,
  and Monte Carlo uncertainty for `pert`, `pertG2full`, or `totalFull`.
- `BcMixingCoordinateDirect.nb`: direct non-Azizi coordinate-space
  perturbative cross-check.  It has the same publication stability and Monte
  Carlo blocks, but its scope is perturbative only.

`BcMixingCoordinateOPE.nb` remains the derivation/audit notebook for the
coordinate-space \(G^2\), \(G^3\), pole weights, and FeynCalc derivative checks.
`BcMixingCoordinate.nb` is the older coordinate-space exploratory notebook; for
paper-style coordinate plots and uncertainty use `BcMixingCoordinateAzizi.nb`.

`BcMixingDimension6Complete.wl` is the audit/workbench file for the
dimension-6 completion problem.  The standard single-line \(G^3\) contribution
is already part of the production momentum-space `"total"` order.  The slow
open-field cross-line pieces \(S_c^{GG}S_b^G+S_c^G S_b^{GG}\) have also been
reduced and cached at the central Wang-window point, so they can be inspected
with `D6CrossLineCentralSummary[]` and `D6CrossLineCentralAngleShift[]`.
They are not yet wired into the full `M^2`, `s0`, and Monte Carlo scans because
that requires either a full cache grid or an interpolation layer after the
final open-propagator convention audit.

## Current Status

Implemented files:

- `BcMixingMomentum.wl`: core Wolfram Language script.
- `BcMixingMomentum.nb`: thin notebook wrapper for interactive use.

The calculation currently supports:

- Momentum-space correlators for the currents
  \[
  J^A_\mu=\bar b\gamma_\mu\gamma_5 c,\qquad
  J^B_\mu=i\bar b\sigma_{\mu\alpha}
  \frac{p^\alpha}{m_b+m_c}\gamma_5 c .
  \]
  The denominator in \(J^B_\mu\) is essential: it makes \(J^A_\mu\) and
  \(J^B_\mu\) have the same mass dimension.
- Spin-1 projection with
  \[
  P_{\mu\nu}^{(1)}=\frac{1}{3}
  \left(g_{\mu\nu}-\frac{p_\mu p_\nu}{p^2}\right).
  \]
- FeynCalc algebra for the `AA`, `AB`, and `BB` correlators.
- Perturbative spectral densities \(\rho^{ij}_{\rm pert}(s)\).
- Numerical Borel moments and perturbative mixing angle.
- Direct Borel moments for the dimension-4 gluon condensate
  \(\langle g_s^2G^2\rangle\).
- Direct Borel moments for the standard vacuum-averaged single-line
  dimension-6 triple-gluon condensate \(\langle g_s^3G^3\rangle\).
- Scan/table/plot helpers for trial \(M^2\) and \(s_0\) windows.
- OPE-convergence scan helpers comparing \(G^2\) and \(G^3\) to the
  perturbative moment.
- OPE-decomposition plots for \(\theta(M^2)\) and channel-level ratio plots
  comparing \(G^2/\mathrm{pert}\) and \(G^3/\mathrm{pert}\).
- Mass-dimension checks for the current basis and perturbative spectral
  densities.
- A perturbative \(O(\alpha_s)\) sensitivity layer using channel-dependent
  trial \(K\)-factors. This is not a full NLO calculation.

The implemented \(G^3\) term is the standard single-line contribution
\[
  \Pi_{G^3,\mathrm{single}}^{ij}
  =
  \Pi^{ij}[S_c^{(G^3)}S_b^{(0)}]
  +
  \Pi^{ij}[S_c^{(0)}S_b^{(G^3)}].
\]
This statement applies to both the momentum-space notebook and the
coordinate-space OPE notebook.  The complete dimension-6 basis from multiplying
two background-field propagators would additionally contain
\[
  \Pi_{G^3,\mathrm{cross}}^{ij}
  =
  \Pi^{ij}[S_c^{(GG,\mathrm{open})}S_b^{(G,\mathrm{open})}]
  +
  \Pi^{ij}[S_c^{(G,\mathrm{open})}S_b^{(GG,\mathrm{open})}].
\]
These cross-line terms are not contained in the vacuum-averaged single-line
propagator.  The current workbench evaluates them numerically at the central
point; before they are used as paper-final input over the whole Borel window,
check the remaining convention audit with

```mathematica
Get["BcMixingDimension6Complete.wl"];
D6CompletenessReport[] // Dataset
D6CrossLineValidationStatus[] // Dataset
D6CrossLineCentralSummary[] // Dataset
D6CrossLineCentralAngleShift[] // Dataset
```

The notebook switch `showCachedCompleteD6CentralQuote` is therefore a
central-point quote/audit switch, not a replacement for the production
window scan.  The Monte Carlo switch `requestCompleteD6CrossLineMonteCarlo`
is intentionally `False`; turning it on prints a reminder that a full
cross-line grid/interpolation over the sampled variables is needed before that
correction can be sampled point by point.

For the momentum-space theta-decomposition plot with the complete dimension-6
cross-line term, use the `Complete-D6 M2 Grid` section of
`BcMixingMomentum.nb`.  The first run should be explicit because it is slow:

```mathematica
completeD6PlotS0 = 53.0;
completeD6GridNPoints = stabilityNPoints;  (* use 25 for the paper plot *)
generateCompleteD6CrossLineM2Grid = True;
overwriteCompleteD6CrossLineM2Grid = False;
```

Then evaluate the grid cells.  Each point is cached in `d6_chunks`, so an
interrupted run can be resumed.  After the cache is created, set

```mathematica
generateCompleteD6CrossLineM2Grid = False;
```

and the notebook will load the cached grid and plot four curves:

```mathematica
{"pert", "pertG2", "total", "totalCompleteD6"}
```

where `"total"` is
\(\Pi_{\rm pert}+\Pi_{G^2}+\Pi_{G^3,\mathrm{single}}\), while
`"totalCompleteD6"` additionally includes the cached
\(\Pi_{G^3,\mathrm{cross}}\) values on that \(M^2\) grid.

## Running The Code

In this environment, `wolframscript` may hang, but the Wolfram kernel runs
directly:

```bash
'/Applications/Wolfram.app/Contents/MacOS/WolframKernel' -noprompt -run 'SetDirectory["/Users/sbilmis/Bc_mixing"]; Get["BcMixingMomentum.wl"]; Print[InputForm[CheckEnvironment[]]]; Quit[]'
```

Inside Mathematica or the notebook:

```wl
SetDirectory["/Users/sbilmis/Bc_mixing"];
Get["BcMixingMomentum.wl"];
CheckEnvironment[]
```

The tested FeynCalc version is `10.2.0`.

## Perturbative Mixing Angle

The numerical function is

```wl
NumericMixingAngleDegrees[M2, s0, "pert"]
```

Example with the current default inputs \(m_b=4.18\), \(m_c=1.27\):

```wl
NumericMixingAngleDegrees[10, 55, "pert"]
```

Current result:

```wl
43.72611894294242
```

The raw quadrant-safe solution is also available:

```wl
NumericMixingAngleRawDegrees[10, 55, "pert"]
```

which gives

```wl
43.72611894294242
```

For this normalized-current convention the raw and principal-branch values
are the same at the displayed point. The function `NumericMixingAngleDegrees`
reports the conventional principal branch in \([-45^\circ,45^\circ]\).

The perturbative value is useful for debugging conventions. The
perturbative-plus-\(G^2\) result is available as:

```wl
NumericMixingAngleDegrees[10, 55, "pertG2"]
```

Current result:

```wl
43.74742666040357
```

The current `"total"` result includes perturbative, \(G^2\), and \(G^3\):

```wl
NumericMixingAngleDegrees[10, 55, "total"]
```

Current result:

```wl
43.74269352435188
```

At this point the condensate corrections are small, so the total angle is
close to the perturbative one. This should still be tested across the
accepted Borel window before quoting a paper-level result.

## Perturbative Alpha_s Sensitivity

> **NLO scope warning.** The independent AA coefficient now passes the LO,
> soft, UV, IR, scale-cancellation, equal-mass Catani form-factor, quadrature,
> and small-mass tests. The old \(+3\%\) AA result is superseded. However, an
> NLO mixing angle cannot be quoted until the independent `AB` and `BB`
> coefficients are also derived. The fixed-input on-shell diagnostic must
> also remain separate from the common-scale MSbar result.

The full perturbative \(O(\alpha_s)\) correction is now being developed in the
separate workbench `BcMixingAlphaS.wl`.  This is a genuine NLO spectral-density
calculation, not a small modification of the LO notebook.  The required form is

\[
\rho_{\rm pert}^{ij}(s)=
\rho_{0}^{ij}(s)+\frac{\alpha_s}{\pi}\rho_{1}^{ij}(s),
\qquad ij=AA,AB,BB .
\]

The workbench currently:

- loads the stable LO machinery from `BcMixingMomentum.wl`,
- keeps a registry for the derived \(\rho_1^{ij}(s)\) functions,
- contains an independent `AA` derivation workbench that does not use Wang's
  closed formula,
- combines its virtual, counterterm, real-emission and unequal-mass massive
  dipole pieces into a finite numerical \(\rho_1^{AA}(s)\),
- evaluates the corresponding Borel moment by Gauss-Legendre quadrature.

Use:

```wl
Get["BcMixingAlphaS.wl"];
AlphaSWorkbenchSelfTest[]
AlphaSNLOStatus[]
```

The independent `AA` path starts from the Feynman rules.  It now:

- reproduces the LO `AA` spectral density exactly via
  `IndependentAALODerivationCheck[s]`,
- builds the real-emission trace for \(J_A\to c\bar b g\),
- supplies the physical three-body phase-space bounds and a soft-cutoff
  diagnostic integral,
- extracts the real-emission soft endpoint coefficient by taking
  \(u=\delta y,\ v=\delta(1-y),\ \delta\to0\), and checks it against cutoff
  scans,
- verifies the real-emission soft kernel exactly against the universal
  massive eikonal factor,
- uses \(d\Phi_3=dt\,du/(128\pi^3s)\) and the optical-theorem factor
  \(1/(2\pi)\),
- reduces the virtual vertex to scalar `PaVe` integrals before calling
  Package-X, with no tensor-integral warning,
- eliminates the two nonsinglet gamma-five matrices before continuing the
  trace to \(D\) dimensions,
- uses the physical loop measure and the correct
  `1/PaXEpsilonBar` convention,
- normalizes the \(D\)-dimensional projected Born trace to the
  four-dimensional spectral-density convention before finite extraction,
- includes the on-shell field counterterm appropriate to the amplitude
  calculation,
- verifies exact UV cancellation and numerical real-virtual IR cancellation,
- subtracts the two local unequal-mass final-state dipoles from the real
  contribution,
- adds their analytically integrated finite terms,
- reproduces the exact equal-mass Catani axial \(f_1+f_2\) virtual
  coefficient and the inclusive \(\rho_1/\rho_0\to1\) limit.

The Wang unequal-mass axial-vector result is kept only as a later external
cross-check.  It is not used in the independent result.  The tensor-current
channels `AB` and `BB` must still be derived separately before the NLO
correction can be propagated consistently to the mixing angle.

Useful independent-AA checks:

```wl
IndependentAALODerivationCheck[s]["Difference"]
IndependentAARealEmissionSoftTheoremCheck[s, yAA]["Difference"]
IndependentAARealEmissionSoftFitCheck[40.0, {0.7, 0.5, 0.3}]
IndependentAARenormalizationSummary[s]
IndependentAAUVPoleCancellationCheck[
  s, l, FeynCalc`PaXC0Expand -> True
]
IndependentAAIRPoleCancellationCheck[40.0]
IndependentAAFinalRho1Numeric[
  40.0, $BcMixingDefaultParameters,
  AccuracyGoal -> 5, PrecisionGoal -> 5, MaxRecursion -> 10
]
IndependentAAFinalNLOBorelSummary[
  10.0, 55.0, $BcMixingDefaultParameters,
  "NPoints" -> 16, "Progress" -> True,
  AccuracyGoal -> 5, PrecisionGoal -> 5, MaxRecursion -> 10
]
```

At \(s=40\,\mathrm{GeV}^2\), the current audit gives

```text
virtual IR pole rho1 =  0.7839022052
field IR pole rho1   = -0.5197682507
real IR pole rho1    = -0.2641339545
sum                  =  0
```

The finite AA audit is now resolved. Two independent mistakes produced the
old small correction:

1. FeynHelpers uses `1/PaXEpsilonBar` for
   \(1/\epsilon-\gamma_E+\ln(4\pi)\), so the Laurent substitution is
   `PaXEpsilonBar -> z`, not `1/z`.
2. The D-dimensional projected Born trace differs from its four-dimensional
   value by an \(O(\epsilon)\) factor. The virtual loop must be normalized by
   \(B_4/B_D\) before its poles are expanded.

With these corrections, the equal-mass virtual coefficient agrees with the
Catani et al. axial \(f_1+f_2\) result to better than \(10^{-10}\), and the
inclusive small-mass ratios are

```text
m = 0.20 GeV: rho1/rho0 = 1.0831974
m = 0.10 GeV: rho1/rho0 = 1.0249053
m = 0.05 GeV: rho1/rho0 = 1.0072604
```

For the fixed numerical inputs \(m_b=4.18\) GeV, \(m_c=1.27\) GeV,
\(\alpha_s=0.26\), \(M^2=10\) GeV\(^2\), and \(s_0=55\) GeV\(^2\), treated
only as an on-shell-scheme diagnostic, the corrected 20-node result is

```text
LO perturbative AA moment             = 0.1441716826
bare NLO coefficient moment           = 1.3770512496
(alpha_s/Pi) NLO correction           = 0.1139655469
LO + NLO                              = 0.2581372295
relative NLO correction               = 0.790485
```

The 12-node bare coefficient is `1.3770552219`, confirming convergence.
These fixed mass numbers are not a consistent use of the usual MSbar inputs
\(m_b(m_b)=4.18\) GeV and \(m_c(m_c)=1.27\) GeV.

The following **superseded provisional benchmark** was obtained before the
epsilon-bar and D-dimensional Born-normalization errors were fixed. It is
retained only to reproduce the debugging history. For the default numerical
inputs, \(\alpha_s=0.26\),
\(M^2=10\,\mathrm{GeV}^2\), and \(s_0=55\,\mathrm{GeV}^2\), the 16-node
independent result is

```text
LO perturbative AA moment             = 0.1441716826
bare NLO coefficient moment           = 0.0539467666
(alpha_s/Pi) NLO correction           = 0.0044646652
LO + NLO                              = 0.1486363478
relative NLO correction               = 0.0309677
```

The 8-, 12-, and 16-node NLO corrections are respectively
`0.0044665742`, `0.0044651475`, and `0.0044646652`, showing stable numerical
convergence.

### Common-scale MSbar result

The workbench can convert an independently validated on-shell coefficient to a
consistent common-scale \(\overline{\mathrm{MS}}\) expression.  It uses

\[
 M_Q=\overline m_Q(\mu)\left[
 1+\frac{\alpha_s(\mu)}{\pi}
 \left(\frac43+\ln\frac{\mu^2}{\overline m_Q^2(\mu)}\right)
 \right]
\]

and therefore

\[
\rho_{1,\overline{\mathrm{MS}}}^{AA}(s,\mu)
=\rho_{1,\mathrm{OS}}^{AA}(s,\mu)
+\sum_{Q=b,c}\overline m_Q(\mu)
\left(\frac43+\ln\frac{\mu^2}{\overline m_Q^2(\mu)}\right)
\frac{\partial\rho_0^{AA}}{\partial m_Q}.
\]

The boundary inputs are

```text
mb(mb)       = 4.18 GeV
mc(mc)       = 1.27 GeV
alpha_s(MZ)  = 0.1180
MZ           = 91.1876 GeV
```

One-loop running is used, which is the RGE accuracy consistent with the
present \(O(\alpha_s)\) calculation.  The charm input is evolved in the
four-flavour theory to \(m_b\), matched continuously there, and both masses
are then evolved to the common scale in the five-flavour full theory because
the correlator contains an explicit bottom field.  Evaluate the result with:

```wl
IndependentAAMSbarRunningParameters[2.0]

IndependentAAFinalNLOBorelMSbarSummary[
  10.0, 55.0, 2.0,
  $BcAlphaSMSbarDefaults,
  $BcMixingDefaultParameters,
  "NPoints" -> 12,
  "Progress" -> True,
  AccuracyGoal -> 5,
  PrecisionGoal -> 5,
  MaxRecursion -> 10
]
```

Using the corrected, independently validated AA coefficient gives the
following 20-node result at \(\mu=2\,\mathrm{GeV}\):

```text
mb(mu)                                  = 4.6683009 GeV
mc(mu)                                  = 1.1659209 GeV
alpha_s(mu)                             = 0.2622100
LO perturbative AA moment               = 0.07234064
OS coefficient at running masses        = 0.76413932
pole-to-MSbar conversion coefficient    = -0.14310349
bare MSbar NLO coefficient moment       = 0.62103583
(alpha_s/Pi) NLO correction             = 0.05183416
LO + NLO                                = 0.12417480
relative NLO correction                 = 71.65 percent
```

Using 12 quadrature nodes at \(\mu=1.8\) and \(2.2\) GeV gives respectively

```text
mu = 1.8 GeV: LO + NLO = 0.11848220
mu = 2.2 GeV: LO + NLO = 0.12792949
```

The corresponding scale variation is

\[
\Pi_{\mathrm{pert,NLO}}^{AA}
=0.12417^{+0.00375}_{-0.00569}
\qquad (\mu=2.0^{+0.2}_{-0.2}\ {\rm GeV}),
\]

The wider scale and higher-order running dependence should still be included
in a final paper uncertainty.

The earlier value \(\Pi_{\mathrm{LO}}^{AA}=0.1441716826\) used the fixed
numbers \(m_b=4.18\) and \(m_c=1.27\) directly in the LO density.  It is not
the LO part of the common-scale \(\overline{\mathrm{MS}}\) result and must not
be combined directly with the common-scale correction above. Once both masses are
run to one common scale, the LO moment and threshold necessarily change.

The wider scale scan shows strong threshold sensitivity outside the
\(1.8\)--\(2.2\) GeV band.  In particular, choosing \(\mu=m_b\) makes the
fixed-order conversion poorly behaved.  This is a useful physics warning:
the common-scale \(\overline{\mathrm{MS}}\) result should be quoted with its
scale band, while the pole-scheme benchmark should remain a separate
cross-check.

The older K-factor layer in `BcMixingMomentum.wl` remains available as a
diagnostic only.  It rescales the perturbative part by channel-dependent trial
factors:

\[
\Pi_{\rm pert}^{ij}
\rightarrow
\left(1+\frac{\alpha_s}{\pi}K_{ij}\right)
\Pi_{\rm pert}^{ij}.
\]

The condensate terms are left unchanged. This is useful for estimating how
sensitive the angle is to unknown channel-dependent NLO corrections.

Example:

```wl
KFactorSensitivityRecord[
  10, 55,
  KFactorAssociation[1, 0, -1],
  0.26,
  "total"
]
```

Here `KFactorAssociation[1,0,-1]` means
\(K_{AA}=1\), \(K_{AB}=0\), \(K_{BB}=-1\). At \(M^2=10\), \(s_0=55\), this
gives

```wl
ThetaBaseDeg   = 43.74269352435188
ThetaAlphaSDeg = 40.6257216732301
DeltaThetaDeg  = -3.116971851121775
```

A small envelope scan can be run with:

```wl
KFactorSensitivityEnvelope[10, 55, {-2, 2, 2}, 0.26, "total"]
```

where `{-2,2,2}` scans \(K_{AA},K_{AB},K_{BB}\in\{-2,0,2\}\). For this
coarse scan the largest branch-corrected shift is about

```wl
MaxAbsDeltaThetaDeg = 7.52
```

This K-factor scan should be read only as an uncertainty stress test, not as an
NLO result.

## Borel-Window And Threshold Scans

Use `{min,max,step}` specifications for trial windows:

```wl
MixingAngleScan[{8, 12, 1}, {50, 60, 5}, "total"]
```

This returns a list of associations with:

- `M2`
- `s0`
- `PiAA`
- `PiAB`
- `PiBB`
- `ThetaRawDeg`
- `ThetaDeg`

For a notebook-friendly view:

```wl
MixingAngleDataset[{8, 12, 1}, {50, 60, 5}, "total"]
MixingAngleTable[{8, 12, 1}, {50, 60, 5}, "total"]
```

For plotting:

```wl
PlotMixingAngle[{8, 12}, 55, $BcMixingDefaultParameters, "total"]
PlotMixingAngleS0[10, {50, 60}, $BcMixingDefaultParameters, "total"]
MixingAngleContourPlot[{8, 12}, {50, 60}, $BcMixingDefaultParameters, "total"]
```

A quick total scan currently gives values near \(43^\circ\)-\(45^\circ\) across
the example window:

```wl
MixingAngleMatrix[{8, 12, 2}, {50, 60, 5}, "total"]
```

returns approximately

```wl
{{42.83, 43.45, 43.94},
 {43.00, 43.74, 44.37},
 {43.13, 43.95, 44.67}}
```

for \(M^2=\{8,10,12\}\) and \(s_0=\{50,55,60\}\).

## Wang-Window Stability Plots

Wang's \(B_c^*\) sum-rule analysis uses the auxiliary window

\[
M^2 = 7.0\text{--}9.0~{\rm GeV}^2,\qquad
s_0 = 54\pm1~{\rm GeV}^2.
\]

This is useful as a comparison/stability check for the mixing-angle analysis.
The package defines:

```wl
$BcMixingWangWindow
```

with

```wl
<|
  "M2Range" -> {7.0, 9.0},
  "M2Values" -> {7.0, 8.0, 9.0},
  "s0Central" -> 54.0,
  "s0Range" -> {53.0, 55.0},
  "s0Values" -> {53.0, 54.0, 55.0}
|>
```

Publication-quality stability plots can be generated directly with:

```wl
stabilityOrder = "total";

m2Stability = MixingAngleStabilityM2PublicationPlot[
  $BcMixingWangWindow["M2Range"],
  $BcMixingWangWindow["s0Values"],
  stabilityOrder,
  $BcMixingDefaultParameters,
  "NPoints" -> 25,
  "YHalfWidth" -> 1.0
];

s0Stability = MixingAngleStabilityS0PublicationPlot[
  $BcMixingWangWindow["s0Range"],
  $BcMixingWangWindow["M2Values"],
  stabilityOrder,
  $BcMixingDefaultParameters,
  "NPoints" -> 25,
  "YHalfWidth" -> 1.0
];

m2Stability["Plot"]
s0Stability["Plot"]
```

Here `"YHalfWidth" -> 1.0` forces at least a \(\pm1^\circ\) vertical window
around the plotted values, so the graph does not over-magnify small changes in
\(\theta\). Increase it to `1.5` or `2.0` if you want an even calmer y-axis.
The plot functions use MaTeX labels automatically when the MaTeX package is
available:

```wl
"UseMaTeX" -> Automatic
```

This gives publication-style labels such as \(M^2(\mathrm{GeV}^2)\),
\(s_0(\mathrm{GeV}^2)\), \(\theta^\circ\), and legend entries like
\(s_0=54\,\mathrm{GeV}^2\). If MaTeX is not installed, the same functions fall
back to ordinary Mathematica labels with the degree symbol. To force plain
labels, use `"UseMaTeX" -> False`; to request MaTeX explicitly, use
`"UseMaTeX" -> True`.

Export figures and data with:

```wl
Export["BcMixingThetaVsM2_WangWindow.pdf", m2Stability["Plot"]];
Export["BcMixingThetaVsS0_WangWindow.pdf", s0Stability["Plot"]];

ExportStabilityDataCSV[
  m2Stability["Data"],
  "BcMixingThetaVsM2_WangWindow.csv",
  "M2"
];

ExportStabilityDataCSV[
  s0Stability["Data"],
  "BcMixingThetaVsS0_WangWindow.csv",
  "s0"
];
```

For the most robust workflow, especially after the script-mode PDF export
hang we observed, use the dedicated notebook
`BcMixingMomentumPlots.nb`.  It computes the numerical tables first, writes
the corrected CSV files, and then builds the plots from those stored tables:

```wl
stabilityOrder = "total";
stabilityNPoints = 25;
stabilityYHalfWidth = 1.0;
stabilityUseMaTeX = False;
stabilityExportPDF = False;

m2StabilityData = MixingAngleM2StabilityData[
  $BcMixingWangWindow["M2Range"],
  $BcMixingWangWindow["s0Values"],
  stabilityOrder,
  $BcMixingDefaultParameters,
  stabilityNPoints
];

s0StabilityData = MixingAngleS0StabilityData[
  $BcMixingWangWindow["s0Range"],
  $BcMixingWangWindow["M2Values"],
  stabilityOrder,
  $BcMixingDefaultParameters,
  stabilityNPoints
];

m2Stability = MixingAngleStabilityM2PublicationPlotFromData[
  m2StabilityData,
  $BcMixingWangWindow["M2Range"],
  "UseMaTeX" -> stabilityUseMaTeX,
  "YHalfWidth" -> stabilityYHalfWidth
];

s0Stability = MixingAngleStabilityS0PublicationPlotFromData[
  s0StabilityData,
  $BcMixingWangWindow["s0Range"],
  "UseMaTeX" -> stabilityUseMaTeX,
  "YHalfWidth" -> stabilityYHalfWidth
];
```

This separates the physics numerics from the plot styling.  Once the CSV files
exist, labels, y-axis padding, MaTeX, and PDF export can be adjusted without
recalculating the stability curves.  The standalone
`RegenerateBcMixingArtifacts.wl` script now also skips PDF export by default;
set `regenerateExportPDF = True` inside that file only when a final export is
needed.

## Monte Carlo Uncertainty Analysis

The central values in the input table,

\[
m_b=4.18~{\rm GeV},\quad
m_c=1.27~{\rm GeV},\quad
\langle g_s^2G^2\rangle=4\pi^2(0.012)~{\rm GeV}^4,\quad
\langle g_s^3G^3\rangle=0.57~{\rm GeV}^6,
\]

are not enough for the final quoted uncertainty. Their allowed ranges should
be propagated together with the Borel-window and continuum-threshold
variation. The script now includes a Monte Carlo layer that samples
\(m_b\), \(m_c\), \(G^2\), \(G^3\), \(M^2\), and \(s_0\), rejects points that
violate \(s_0>(m_b+m_c)^2\), and computes \(\theta\) for every accepted point.

The current editable working ranges are:

```wl
$BcMixingDefaultUncertaintyRanges
```

which corresponds to

```wl
<|
  "mb" -> {4.16, 4.21},
  "mc" -> {1.25, 1.29},
  "G2" -> {4 Pi^2 0.006, 4 Pi^2 0.018},
  "G3" -> {0.28, 0.86},
  "M2" -> {8.0, 12.0},
  "s0" -> {50.0, 60.0}
|>
```

These are placeholders for the numerical scan and should be replaced by the
final input uncertainties used in the paper. A single number fixes a parameter
instead of sampling it; a pair `{min,max}` samples it uniformly.

In the call below, `50` is the number of random accepted Monte Carlo points.
For a paper-level run, use `500`, `1000`, or larger after the final parameter
ranges are fixed. The option `"Seed" -> 1234` fixes the random-number seed, so
the same notebook cell gives the same random sample again. Change the seed, or
set `"Seed" -> Automatic`, to generate a statistically independent sample.

Example with a small test sample. The result is named `uncertaintyRun` to
avoid confusion with the charm-quark mass key `"mc"`.

```wl
uncertaintyRun = MonteCarloMixingAngleUncertainty[
  50,
  <|
    "mb" -> {4.16, 4.21},
    "mc" -> {1.25, 1.29},
    "G2" -> {4 Pi^2 0.006, 4 Pi^2 0.018},
    "G3" -> {0.28, 0.86},
    "M2" -> {8.0, 12.0},
    "s0" -> {50.0, 60.0}
  |>,
  "total",
  "IncludeG3" -> False,
  "Seed" -> 1234,
  "Progress" -> True
];
```

For notebook work it is better to use one editable control block:

```wl
nSamples = 50;
histBins = 15;
m2Range = {8.0, 12.0};
s0Range = {50.0, 60.0};

uncertaintyRanges = Join[
  $BcMixingDefaultUncertaintyRanges,
  <|"M2" -> m2Range, "s0" -> s0Range|>
];

uncertaintyRun = MonteCarloMixingAngleUncertainty[
  nSamples,
  uncertaintyRanges,
  "total",
  "IncludeG3" -> False,
  "Seed" -> 1234,
  "Progress" -> True
];
```

Then the only controls you normally change are `nSamples`, `histBins`,
`m2Range`, and `s0Range`.

The package-level default Monte Carlo switch is

```wl
$BcMixingMonteCarloIncludeG3 = False;
```

This conservative package default prevents long exploratory scans from
accidentally evaluating the slower single-line \(G^3\) term.  The current
momentum notebook, however, is set to the paper-facing total-OPE workflow via

```wl
monteCarloIncludeG3 = True;
```

so its uncertainty cell evaluates

```wl
MonteCarloMixingAngleUncertainty[
  500,
  $BcMixingDefaultUncertaintyRanges,
  "total",
  "IncludeG3" -> True
]
```

as perturbative plus \(G^2\) plus the standard single-line \(G^3\)
contribution.  The result records both `"RequestedOrder"` and the actual
`"Order"` used for each point.  For a quick exploratory scan, either set

```wl
monteCarloIncludeG3 = False
```

in the notebook or call the Monte Carlo function with `"IncludeG3" -> False`;
then a requested `"total"` scan is evaluated as `"pertG2"`.

Then inspect the result:

```wl
uncertaintyRun["Summary"]
MonteCarloMixingAngleDataset[uncertaintyRun]
MonteCarloMixingAngleHistogram[uncertaintyRun, histBins]
MonteCarloMixingAnglePublicationHistogram[uncertaintyRun, histBins]
```

The summary reports the accepted sample count, mean angle, Gaussian-width
estimate, sample standard deviation, median, \(16\%\) and \(84\%\) quantiles,
and min/max values. For paper-level statistics, increase `50` to `500` or
larger after the final parameter ranges and Borel window are fixed.  The
paper-facing scan should keep `IncludeG3 -> True`; a faster diagnostic scan may
temporarily use `IncludeG3 -> False` to isolate the \(G^2\) result.

To vary only \(M^2\) and \(s_0\) while keeping the QCD inputs at their central
values:

```wl
myRanges = Join[
  $BcMixingDefaultUncertaintyRanges,
  <|
    "mb" -> 4.18,
    "mc" -> 1.27,
    "G2" -> 4 Pi^2 0.012,
    "G3" -> 0.57,
    "M2" -> {8.0, 12.0},
    "s0" -> {50.0, 60.0}
  |>
];

MonteCarloMixingAngleUncertainty[
  500,
  myRanges,
  "total",
  "IncludeG3" -> False
]
```

For example, to test a narrower window, change only the last two entries:

```wl
myRanges = Join[
  $BcMixingDefaultUncertaintyRanges,
  <|"M2" -> {9.0, 11.0}, "s0" -> {52.0, 58.0}|>
];
```

For publication plotting or external replotting:

```wl
pubPlot = MonteCarloMixingAnglePublicationHistogram[uncertaintyRun, 20];
Export["BcMixingMonteCarloHistogram.pdf", pubPlot];

ExportMonteCarloMixingAngleSamples[uncertaintyRun, "BcMixingMonteCarloSamples.csv"];
ExportMonteCarloMixingAngleSummary[uncertaintyRun, "BcMixingMonteCarloSummary.csv"];
```

The current Monte Carlo does not include a real \(O(\alpha_s)\) perturbative
uncertainty because the two-loop spectral densities have not been calculated
yet. The separate K-factor layer below is only a sensitivity test.

## Why Momentum Space

For \(B_c\), both quark lines are heavy. The OPE side is a two-mass
heavy-heavy loop. Momentum space is therefore natural:

\[
\int \frac{d^Dk}{(2\pi)^D}
\frac{{\rm Tr}[\Gamma_1(\slashed{k}+m_c)\Gamma_2(\slashed{k}-\slashed{p}+m_b)]}
{(k^2-m_c^2)[(k-p)^2-m_b^2]} .
\]

This is the type of expression FeynCalc handles well: Dirac traces, Lorentz
contractions, loop denominators, tensor reduction, and Feynman
parametrization.

The coordinate-space method used in heavy-light studies is convenient when a
light-quark propagator is expanded in \(x\)-space condensates. For \(B_c\),
coordinate space would lead to products of massive Bessel functions for the
\(b\) and \(c\) propagators and is less direct for FeynCalc.

## Independent Coordinate-Space Route

The file `BcMixingCoordinate.wl` is the independent coordinate-space route.
The notebook `BcMixingCoordinate.nb` now loads only this file in its main
workflow.  Momentum-space comparisons are left in an optional commented
section, so a coordinate-space calculation cannot accidentally quote a
momentum-space number.

The coordinate file defines the heavy-quark propagator in \(x\)-space,

\[
S_Q^{(0)}(x)=
\frac{m_Q^2}{(2\pi)^2}
\left[
i\slashed{x}\frac{K_2(m_Q\sqrt{-x^2})}{(-x^2)}
+\frac{K_1(m_Q\sqrt{-x^2})}{\sqrt{-x^2}}
\right],
\]

builds the coordinate-space trace kernels for \(AA\), \(AB\), \(BA\), and
\(BB\), and installs the perturbative spectral densities obtained after the
Bessel/Schwinger reduction described by Huang--Liu and Azizi et al.

Usage:

```wl
Get["BcMixingCoordinate.wl"];
CoordinateCheckEnvironment[]
CoordinateTraceKernel["AA", "pert"] // Short
CoordinateNumericMixingAngleDegrees[8, 54, "pert"]
CoordinateWangWindowGrid[]
```

The independent status can be inspected with

```wl
CoordinateIndependenceStatus[] // Dataset
```

At present, the independent coordinate-space result is the perturbative
spectral density and its Borel moments.  If `BcMixingMomentum.wl` is loaded
manually in the optional comparison section, one can compare the perturbative
angle directly:

```wl
Get["BcMixingMomentum.wl"];
Get["BcMixingCoordinate.wl"];
CoordinateCompareToMomentum[8, 54]
```

This currently returns equal perturbative values at \(M^2=8~{\rm GeV}^2\),
\(s_0=54~{\rm GeV}^2\):

```wl
<|"CoordinatePertDeg" -> 43.28944792785432,
  "MomentumPertDeg" -> 43.28944792785432,
  "DifferenceDeg" -> 0.|>
```

The coordinate-space perturbative result matches the momentum-space result
exactly at the Wang-window test point.  This agreement is a validation check,
not a dependency of the coordinate calculation.

The coordinate file also includes a local-condensate bridge for the
single-line \(G^2\) and \(G^3\) pieces:

```wl
CoordinateLocalCondensateSummary[8, 54]
CoordinateNumericMixingAngleDegrees[8, 54, "pertG2local"]
CoordinateNumericMixingAngleDegrees[8, 54, "totalLocal"]
CoordinateLocalCondensateComparisonToMomentum[8, 54]
CoordinateLocalCondensateComparisonToMomentum[8, 54,
  $BcCoordinateDefaultParameters, "IncludeG3" -> True]
```

At \(M^2=8~{\rm GeV}^2\), \(s_0=54~{\rm GeV}^2\), the local coordinate-space
checks give

```wl
theta[pert + G2local]           = 43.302779779 deg
theta[pert + G2local + G3local] = 43.295658148 deg
```

Here `local` means that the condensate is inserted on one heavy-quark line at
a time. These local pieces are diagnostic only. They are not the
coordinate-paper-final full OPE, because the current reduced numerical bridge
uses the Feynman/Schwinger helper machinery from `BcMixingMomentum.wl`.

For an independent coordinate-space paper, the implemented analytic target in
`BcMixingCoordinateOPE.wl` is

```wl
G2gg      (* open-field cross-line S_c^G(-x) S_b^G(x) *)
G2full    (* independent G2c + G2b + G2gg *)
G3full    (* independent single-line G3c + G3b truncation *)
totalFull (* independent perturbative + G2full + G3full *)
```

The full dimension-4 coordinate-space \(G^2\) calculation derives the
open-field cross-line contribution \(S_c^{(G)}(-x)S_b^{(G)}(x)\), contract the
two background fields in coordinate space, and reduce the resulting
Bessel/radial integrals without calling the momentum-space OPE engine.  The
\(G^3\) implementation is the standard single-line \(G3c+G3b\) truncation;
open-field dimension-6 cross-line terms are not included.

For perturbative-only independent coordinate-space uncertainty sampling use

```wl
CoordinateMonteCarloMixingAngleUncertainty[
  500, $BcCoordinateDefaultUncertaintyRanges, "pert"]
```

For the OPE-complete coordinate workbench use
`CoordinateOPENumericOPESummary[M2, s0]`, then run the corresponding OPE
mixing-angle scans after accepting the shared sign/normalization convention.

The independent condensate work now starts in a separate workbench:

```wl
Get["BcMixingCoordinateOPE.wl"];
CoordinateOPEStatus[] // Dataset
CoordinateOPEG2Status["AA"] // Dataset
CoordinateOPEG2KernelReport["AA"] // Short
CoordinateOPEG2CompletionReport[] // Short
CoordinateOPEReductionPlan["G2c"] // Dataset
CoordinateOPEKernelInventory["AA", "G2c"] // Dataset
CoordinateOPEKernel["AA", "G2c"] // Short
CoordinateOPEG2ggOpenFieldPropagatorNote[] // Dataset
CoordinateOPEG2ggContraction[]
CoordinateOPEKernelInventory["AA", "G2gg"] // Dataset
CoordinateOPEKernelInventory["AA", "G2full"] // Dataset
CoordinateOPEKernelReductionTable["AA", "G2full"] // Dataset
CoordinateOPEKernelBorelTemplate["AA", "G2full"] // Short
CoordinateOPEKernelWeightRecipe["AA", "G2full"] // Short
CoordinateOPEG2ReductionWorkbook[] // Short
CoordinateOPEKernelDerivationSheets["AA", "G2gg"] // Short
CoordinateOPEMissingWeightReport["AA", "G2full"] // Short
CoordinateOPEG2PoleWeights["AA", "G2c"] // Dataset
CoordinateOPEG2PoleWeights["AA", "G2b"] // Dataset
CoordinateOPEG2ggPoleWeights["AA"] // Dataset
CoordinateOPEG2PoleWeightCheck @@@
  Tuples[{{"AA", "AB", "BB"}, {"G2c", "G2b", "G2gg"}}]
CoordinateOPEExportG2KernelsTeX["AA"]
CoordinateOPEExportG2ReductionTeX["AA"]
CoordinateOPEExportAllG2KernelsTeX[]
CoordinateOPEExportAllG2ReductionTeX[]
CoordinateOPEBorelMoment["AA", "pert", 8.0, 54.0]
CoordinateOPEBorelMoment["AA", "G2gg", 8.0, 54.0]
CoordinateOPEMixingAngleWithG2gg[8.0, 54.0]
CoordinateOPEMixingAngle[8.0, 54.0, "pertG2full"]
CoordinateOPEG3PoleWeightCheck @@@
  Tuples[{{"AA", "AB", "BB"}, {"G3c", "G3b"}}]
CoordinateOPENumericOPESummary[8.0, 54.0] // Dataset
```

The companion notebook is `BcMixingCoordinateOPE.nb`.  It is intentionally a
derivation notebook.  At the kernel level it now contains the full
coordinate-space \(G^2\) structure:

```wl
G2full = G2c + G2b + G2gg
```

where `G2gg` is the open-field cross-line contraction.  The full dimension-4
coordinate-space \(G^2\) sector now has an independent pole-weight reduction in
this workbench.  The explicit weights can be inspected with
`CoordinateOPEG2PoleWeights[channel, order]`, where
`order` is `G2c`, `G2b`, or `G2gg`.  The exact reconstruction check is

```wl
CoordinateOPEG2PoleWeightCheck @@@
  Tuples[{{"AA", "AB", "BB"}, {"G2c", "G2b", "G2gg"}}]
```

and should return nine zeros.  This means the explicit pole weights reproduce
the direct Borel transform of the reduced coordinate-space kernels.

The workbench decomposes every \(G^2\) kernel into scalar terms and attaches a
Bessel/Schwinger delta-derivative template to each term.  It also reports the
canonical \(r\)-power required by the identities
\(K_\nu(mr)/r^\nu\), the residual \(r\)-power left in each term, and the
Gaussian/source-derivative recipe needed to generate the powers of
\((p\cdot x)\), \(x^2\), and \(r^2\).  The canonical dimension-4 kernels are
now reduced by the explicit pole-weight route.  Before paper use, the remaining
audit is not whether `G2full` exists numerically, but whether the global
coordinate-space sign and normalization convention is accepted by a hand check.

The Gaussian/source multipliers have a separate FeynCalc audit:

```wl
CoordinateOPEFeynCalcGaussianMultiplierReport[] // Dataset
```

This applies FeynCalc `FourDivergence` for the directional \((p\cdot x)\)
source derivatives and `FourLaplacian` for the \(x^2\) insertions, then compares
against the Mathematica `D` multipliers used by the numerical pole weights.  The
`Difference` entries should all be zero.  This does not replace the physics
normalization audit, but it checks the Lorentz derivative bookkeeping in four
dimensions.

At the central check point \(M^2=8.0~\mathrm{GeV}^2\),
\(s_0=54.0~\mathrm{GeV}^2\), the independent dimension-4 contribution is

```wl
<|{"AA", "G2c"} -> 0.001166802188340883,
  {"AA", "G2b"} -> 0.0002772620673178404,
  {"AA", "G2gg"} -> 0.000051580295482264745,
  {"AA", "G2full"} -> 0.0014956445511409883,
  {"AB", "G2c"} -> 0.00110755753920247,
  {"AB", "G2b"} -> -0.0003365067164562529,
  {"AB", "G2gg"} -> 4.261954847848125*^-6,
  {"AB", "G2full"} -> 0.0007753127775940651,
  {"BB", "G2c"} -> 0.001373644259578321,
  {"BB", "G2b"} -> 0.00031577979887816205,
  {"BB", "G2gg"} -> -0.00003222500249156523,
  {"BB", "G2full"} -> 0.0016571990559649176|>
```

The full \(G^2\) correction shifts the perturbative coordinate-space angle from
`43.289447927854305` degrees to `43.31873332754599` degrees at this central
point.  The open-field `G2gg` contribution alone would shift it to
`43.2543983466988` degrees.

The single-line dimension-6 contribution is also implemented as

```wl
G3full = G3c + G3b
```

with no open-field cross-line dimension-6 terms included.  At the same central
point,

```wl
<|{"AA", "G3c"} -> 0.0005329741949875566,
  {"AA", "G3b"} -> 0.000021831938764089127,
  {"AA", "G3full"} -> 0.0005548061337516456,
  {"AB", "G3c"} -> 0.0004803544176838252,
  {"AB", "G3b"} -> -0.000018955739304464525,
  {"AB", "G3full"} -> 0.0004613986783793607,
  {"BB", "G3c"} -> 0.0003873885999921353,
  {"BB", "G3b"} -> 0.000015568104596882016,
  {"BB", "G3full"} -> 0.00040295670458901733|>
```

The angle changes from `43.31873332754599` degrees at `pertG2full` to
`43.22988064994687` degrees at `totalFull`.

The OPE hierarchy across the Wang auxiliary-parameter window can be scanned
with:

```wl
coordinateOPEConvergence =
  CoordinateOPEConvergenceScan[{7.0, 9.0, 3}, {53.0, 55.0, 3}];

coordinateOPEConvergence // Dataset

CoordinateOPEExportConvergenceCSV[
  coordinateOPEConvergence,
  "BcMixingCoordinateOPEConvergence_WangWindow.csv"]
```

The exported file is `BcMixingCoordinateOPEConvergence_WangWindow.csv`.  On the
3-by-3 Wang-window grid, the largest observed condensate ratios are

```wl
max |G2full/pert| = 0.0856492483
max |G3full/pert| = 0.0294634786
```

Both ratios decrease as \(M^2\) increases.  At the central point
\(M^2=8.0~\mathrm{GeV}^2\), \(s_0=54.0~\mathrm{GeV}^2\),

```wl
max |G2full/pert| = 0.0384560963
max |G3full/pert| = 0.0134375395
theta[totalFull] = 43.2298806499 deg
```

For the mixing angle the required coordinate-space channels are `AA`, `AB`,
and `BB`.  The workbench therefore includes `CoordinateOPEG2CompletionReport[]`
and `CoordinateOPEG2ReductionWorkbook[]`, which summarize all three channels
at once.  These are the recommended first cells to inspect before attempting
any numerical coordinate-space condensate run.

The workbench now also has an explicit installation path for the missing
weights.  After deriving a weight \(W_{i,n}(x)\) by hand or in a separate
Mathematica cell, install it with

```wl
CoordinateOPEInstallWeight["AA", "G2c", i, n, weightExpression]
```

The required keys are reported by

```wl
CoordinateOPEMissingWeightReport["AA", "G2full"] // Short
```

The canonical \(G^2\) and single-line \(G^3\) weights are generated directly by
`CoordinateOPEG2PoleWeights` and `CoordinateOPEG3PoleWeights`; the manual
`CoordinateOPEInstallWeight` path remains available only for future
noncanonical kernels.  `CoordinateOPEBorelMoment[channel, order, M2, s0]`
now evaluates `pert`, `G2full`, `pertG2full`, `G3full`, and `totalFull`
directly over \(x_-(s_0)<x<x_+(s_0)\).

`CalculationNotes.tex` also contains a separate subsection describing the
direct coordinate-space route without using the Azizi et al. reduction. That
section is documentary only; it does not change the working Mathematica
calculation.

### Direct Non-Azizi Perturbative Check

`BcMixingCoordinateDirect.wl` is a separate direct-coordinate calculation of
the perturbative part without using the Azizi et al. Borel-continuum
machinery. It follows the Huang--Liu / Groote--Korner--Pivovarov viewpoint:
the discontinuity of the product of two massive coordinate-space propagators
is treated through the inverse-\(K\)-transform, equivalently the ordinary
two-body cut. The notebook `BcMixingCoordinateDirect.nb` now loads only
`BcMixingCoordinateDirect.wl` in its main workflow.

Usage:

```wl
Get["BcMixingCoordinateDirect.wl"];
DirectDeltaSupportNote[]
DirectDeltaDerivativeExamples[]
DirectPerturbativeSpectralDensity["AA", s] // Simplify
DirectPerturbativeCheck[8.0, 54.0]
```

The Wang-window test point gives

```wl
DirectNumericMixingAngleDegrees[8.0, 54.0]
(* 43.28944792785432 *)
```

The direct-coordinate file is independent for the perturbative part only.
Full \(G^2\) and \(G^3\) direct-coordinate OPE blocks are intentionally left
as pending publication tasks rather than filled with momentum-space values.

To compare with the existing coordinate-space file:

```wl
Get["BcMixingCoordinate.wl"];
DirectCompareToCoordinate[8.0, 54.0]
```

which returns

```wl
<|"DirectPertDeg" -> 43.28944792785432,
  "CoordinatePertDeg" -> 43.28944792785432,
  "DifferenceDeg" -> 0.|>
```

The file also has a diagnostic condensate layer. This is not yet a fresh
coordinate-space derivation of the \(G^2\) and \(G^3\) spectral densities.
Instead, it exposes the pole terms from the reduced Feynman-parameter
amplitudes as \(\delta^{(n)}(s-\bar s)\) Borel weights and verifies the
distribution algebra against the momentum direct-Borel moments.

The helper
`DirectBorelDeltaDerivativeIntegrand[weight, n, x, s, M2]` implements the
distribution identity

```wl
Integrate[Exp[-s/M2] weight[s, x] DerivativeDelta[n][s - sbar[x]], s]
```

in the convention
\(\delta^{(n)}(s-\bar s(x))\), namely
\((-1)^n \partial_s^n(e^{-s/M^2}W(s,x))|_{s=\bar s(x)}\).

After loading the momentum file first, the condensate checks are:

```wl
Get["BcMixingMomentum.wl"];
Get["BcMixingCoordinateDirect.wl"];
DirectCondensateWeightSummary["AA", "G2"]
DirectCondensateComparisonToMomentum[8.0, 54.0, "G2"]
DirectCondensateComparisonToMomentum[8.0, 54.0, "G3"]
```

At \(M^2=8~{\rm GeV}^2\), \(s_0=54~{\rm GeV}^2\), the \(G^2\) derivative
orders are `{0,1,2}` and the \(G^3\) derivative orders are `{1,2,3,4}`. The
direct derivative-delta reconstruction agrees with the corrected momentum
direct-Borel moments channel by channel.

Note: numerical condensate helpers now enforce that explicit function
arguments `M2` and `s0` override any `"M2"` or `"s0"` entries stored inside a
parameter association. This prevents a stale default Borel value from entering
auxiliary-parameter scans.

For OPE convergence checks:

```wl
NumericOPESummary[10, 55]
OPEConvergenceDataset[{8, 12, 1}, {50, 60, 5}]
```

At \(M^2=10\), \(s_0=55\), the current ratios are approximately:

```wl
AA: G2/pert = -0.00254
AB: G2/pert = -0.00220
BB: G2/pert = -0.00140
AA: G3/pert =  0.000486
AB: G3/pert =  0.000469
BB: G3/pert =  0.000230
```

For a paper figure, the most meaningful contribution plot is the physical
mixing angle itself, with separate curves for perturbative, perturbative plus
\(G^2\), and total OPE.  For example, at fixed \(s_0=53~\mathrm{GeV}^2\),

```wl
thetaOrderM2 = MixingAngleOrderM2PublicationPlot[
  $BcMixingWangWindow["M2Range"],
  53.0,
  {"pert", "pertG2", "total"},
  $BcMixingDefaultParameters,
  "NPoints" -> 25,
  "YHalfWidth" -> 1.0
];

thetaOrderM2["Plot"]
thetaOrderM2["Data"] // Dataset
```

The channel-level OPE hierarchy should be shown separately, because `AA`,
`AB`, and `BB` are not independent final angles; they are the ingredients of
the mixing-angle formula.  The diagnostic plot

```wl
momentumRatioM2 = OPEContributionRatioM2PublicationPlot[
  $BcMixingWangWindow["M2Range"],
  53.0,
  $BcMixingDefaultParameters,
  "NPoints" -> 25,
  "UseAbs" -> True
];

momentumRatioM2["Plot"]
momentumRatioM2["Data"] // Dataset
```

plots \(|\Pi_{G^2}^{ij}/\Pi_{\rm pert}^{ij}|\) and
\(|\Pi_{G^3}^{ij}/\Pi_{\rm pert}^{ij}|\) versus \(M^2\) for
\(ij=AA,AB,BB\).  Set `"UseAbs" -> False` to show signed ratios.

The coordinate-space Azizi/OPE analogues are

```wl
coordinateAziziThetaOrderM2 =
  CoordinateOPEMixingAngleOrderM2PublicationPlot[
    $BcCoordinateWangWindow["M2Range"],
    53.0,
    {"pert", "pertG2full", "totalFull"},
    $BcCoordinateDefaultParameters,
    "NPoints" -> 25,
    "YHalfWidth" -> 1.0
  ];

coordinateAziziRatioM2 =
  CoordinateOPEContributionRatioM2PublicationPlot[
    $BcCoordinateWangWindow["M2Range"],
    53.0,
    $BcCoordinateDefaultParameters,
    "NPoints" -> 25,
    "UseAbs" -> True
  ];
```

The production notebooks contain these cells in the `Theta Decomposition at
Fixed s0` and `OPE Ratio Diagnostics` sections.  The older grouped bar-chart
helpers remain available for quick checks, but they are not recommended for
paper presentation because the perturbative bars fixed at one visually hide the
small condensate effects.

## Mass-Dimension Checks

The tensor current must be normalized as

\[
J^B_\mu=
i\bar b\sigma_{\mu\alpha}
\frac{p^\alpha}{m_b+m_c}\gamma_5c .
\]

Without the factor \(1/(m_b+m_c)\), \(J^A_\mu\) has mass dimension 3 while
\(J^B_\mu\) has mass dimension 4. Then the three projected spectral densities
would have dimensions

\[
[\rho^{AA}],\ [\rho^{AB}],\ [\rho^{BB}]
=2,\ 3,\ 4,
\]

and the mixing-angle formula would combine dimensionally incompatible
quantities.

The script now has checks for this:

```wl
MixingMassDimensionReport[]
CheckMixingMassDimensions[]
PerturbativeSpectralDensityDimensionReport[]
```

The normalized convention returns `True` for `CheckMixingMassDimensions[]`.
For comparison,

```wl
MixingMassDimensionReport[False]
CheckMixingMassDimensions[False]
```

shows the deliberately unnormalized case and returns `False`.

## Gluon Condensate Status

The script builds the dimension-4 gluon-condensate algebra from

\[
S_c^{G^2}S_b^0,\qquad
S_c^0S_b^{G^2},\qquad
S_c^GS_b^G .
\]

It also builds the standard single-line dimension-6 triple-gluon term

\[
S_c^{G^3}S_b^0,\qquad
S_c^0S_b^{G^3}.
\]

These can be inspected with:

```wl
Correlator["AA", "G2"]
Correlator["AA", "G3"]
FeynmanParameterForm["AA", "G2"]
FeynmanParameterForm["AA", "G3"]
```

The \(\langle g_s^2G^2\rangle\) contribution is not treated as a smooth
ordinary spectral density \(\rho_{G^2}(s)\). The Feynman-parameter forms
contain powers of denominators that generate delta functions and derivatives
of delta functions in the spectral representation.

The code therefore uses a direct Borel moment:

\[
\Pi^{ij}_{G^2}(M^2,s_0)
=
\int_0^1 dx\,
\Theta(s_0-\bar s(x))\,
\mathcal{B}^{ij}_{G^2}(x,M^2),
\]

with

\[
\bar s(x)=
\frac{m_c^2 x+m_b^2(1-x)}
{x(1-x)} .
\]

The physical numerical angle in the current `"total"` convention is computed
from

\[
\Pi^{ij}=\Pi^{ij}_{\rm pert}+\Pi^{ij}_{G^2}+\Pi^{ij}_{G^3}.
\]

The code allows

```wl
NumericMixingAngleDegrees[M2, s0, "pertG2"]
NumericMixingAngleDegrees[M2, s0, "total"]
```

where `"pertG2"` means perturbative plus \(\langle g_s^2G^2\rangle\), and
`"total"` means perturbative plus \(\langle g_s^2G^2\rangle\) plus
\(\langle g_s^3G^3\rangle\).

Implementation caveats:

- The direct \(G^2\) and \(G^3\) Borel transforms use the phase convention
  `-I` to remove the loop-integration prefactor from the Feynman-parameter
  amplitudes. This is consistent with the current perturbative convention and
  gives small OPE corrections, but it should be cross-checked against an
  independent derivation before finalizing the paper.
- The \(G^3\) implementation currently uses the standard vacuum-averaged
  single-heavy-propagator term. Cross-line open-field \(G^3\) terms are not
  inserted into the production `"total"` result.

### Dimension-6 Cross-Line Workbench

`BcMixingDimension6Complete.wl` is a separate workbench for the missing
dimension-6 open-field products

\[
S_c^{(GG,\mathrm{open})}S_b^{(G,\mathrm{open})},\qquad
S_c^{(G,\mathrm{open})}S_b^{(GG,\mathrm{open})}.
\]

It now contains an experimental fixed-point-gauge derivative construction of
the open two-gluon propagator candidate, termwise projected FeynCalc traces,
Feynman-parameter reduction hooks, and direct-Borel numerical hooks.  The
validated central test so far is the AA \(S_c^{GG}S_b^G\) side:

```wl
Get["BcMixingMomentum.wl"];
Get["BcMixingDimension6Complete.wl"];

D6NumericBorelPiCrossLine[
  "AA", 8.0, 54.0, $BcMixingDefaultParameters, "c2b1",
  WorkingPrecision -> MachinePrecision,
  AccuracyGoal -> 6,
  PrecisionGoal -> 6
]
```

which gave

```wl
-1.6756975780964764*^-6
```

at \(M^2=8~\mathrm{GeV}^2\), \(s_0=54~\mathrm{GeV}^2\).  The mirror side
\(S_c^G S_b^{GG}\) is substantially slower, so it is evaluated with cached
trace and Feynman-parameter chunks.  For the same central point the cached AA
mirror result is

```wl
3.378713957299235*^-7
```

so the tested AA cross-line sum is approximately

```wl
-1.337826182366553*^-6
```

The AB and BB reductions have now also been completed at the same central
point.  The cached cross-line moments are

| channel | \(S_c^{GG}S_b^G\) | \(S_c^G S_b^{GG}\) | sum |
| --- | ---: | ---: | ---: |
| AA | \(-1.6756975780964764\times10^{-6}\) | \(3.378713957299235\times10^{-7}\) | \(-1.337826182366553\times10^{-6}\) |
| AB | \(6.907526226109287\times10^{-7}\) | \(1.1921369599555478\times10^{-7}\) | \(8.099663186064834\times10^{-7}\) |
| BB | \(-1.168414043165516\times10^{-6}\) | \(-7.557182424790687\times10^{-7}\) | \(-1.924132285644585\times10^{-6}\) |

At \(M^2=8~\mathrm{GeV}^2\), \(s_0=54~\mathrm{GeV}^2\), adding these cached
cross-line pieces changes the angle by only

```wl
DeltaThetaDeg = -0.00028427279801945815
```

The production momentum-space `"total"` still means

\[
\Pi_{\rm pert}+\Pi_{G^2}+\Pi_{G^3,\mathrm{single}},
\]

not \(\Pi_{G^3,\mathrm{complete}}\), until the open-propagator convention
audit is finalized.  Check the current status with

```wl
D6CrossLineValidationStatus[]
```

before using any cross-line number in the paper.

The product \(S_c^{(GG,\mathrm{open})}S_b^{(GG,\mathrm{open})}\) is not a
missing dimension-6 term.  It contains four background gluon fields and belongs
to the dimension-8 sector, schematically \(\langle G^4\rangle\) or a factorized
\(\langle G^2\rangle^2\) estimate.  It should be treated as a higher-order OPE
correction, not as part of \(G^3_{\mathrm{complete}}\).

## Paper Notes

The current perturbative scan is useful for debugging conventions and finding
a rough stability pattern, but it should not be quoted as the final result.
For a paper-level prediction we still need:

- Final sign/normalization audit of the independent coordinate-space
  \(\langle g_s^2G^2\rangle\) and single-line \(\langle g_s^3G^3\rangle\)
  Borel formulae.
- Decision on the single-line \(G^3\) approximation/completeness.
- OPE convergence checks are implemented in `CoordinateOPEConvergenceScan`;
  repeat them across the final accepted window.
- A dedicated perturbative \(O(\alpha_s)\) calculation, beyond the current
  \(K_{ij}\)-factor sensitivity model.
- Pole-dominance and continuum-threshold criteria.
- A chosen \(M^2\) and \(s_0\) working region.
- Uncertainty propagation over \(m_b\), \(m_c\), \(G^2\), \(G^3\), \(M^2\),
  and \(s_0\).

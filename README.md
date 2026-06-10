# B_c Axial-Vector Mixing Angle Sum Rule

This workspace contains a Mathematica/FeynCalc setup for studying the
mixing angle between the axial-vector \(B_c(1P)\) states, following the
logic of Aliev et al. but using a momentum-space heavy-heavy correlator.

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
- Mass-dimension checks for the current basis and perturbative spectral
  densities.
- A perturbative \(O(\alpha_s)\) sensitivity layer using channel-dependent
  trial \(K\)-factors. This is not a full NLO calculation.

The implemented \(G^3\) term is the standard
\(S_c^{G^3}S_b^0+S_c^0S_b^{G^3}\) contribution. Possible cross-line open-field
terms involving an explicitly open two-gluon propagator still need an
independent derivation before they can be added.

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

The full perturbative \(O(\alpha_s)\) correction is not implemented. As a
first diagnostic, the script can rescale only the perturbative part by
channel-dependent trial factors:

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

This should be read only as an uncertainty stress test, not as an NLO result.

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

Publication-quality stability plots can be generated with:

```wl
stabilityOrder = "pertG2";

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

For now the default Monte Carlo switch is

```wl
$BcMixingMonteCarloIncludeG3 = False;
```

This means a requested `"total"` uncertainty scan is evaluated as `"pertG2"`
unless `G3` is explicitly switched on. The result records both
`"RequestedOrder"` and the actual `"Order"` used for each point. When the
standard single-line \(G^3\) contribution is ready to include in the long scan,
use either

```wl
MonteCarloMixingAngleUncertainty[
  500,
  $BcMixingDefaultUncertaintyRanges,
  "total",
  "IncludeG3" -> True
]
```

or set

```wl
$BcMixingMonteCarloIncludeG3 = True;
```

before running the notebook cells.

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
larger after the final parameter ranges and Borel window are fixed. The fast
paper-draft uncertainty scan should use `IncludeG3 -> False`; later the same
call can be rerun with `IncludeG3 -> True` to quantify the \(G^3\) shift.

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
  guessed here.

## Paper Notes

The current perturbative scan is useful for debugging conventions and finding
a rough stability pattern, but it should not be quoted as the final result.
For a paper-level prediction we still need:

- Independent validation of the \(\langle g_s^2G^2\rangle\) Borel formula.
- Independent validation of the \(\langle g_s^3G^3\rangle\) Borel formula and
  the single-line \(G^3\) approximation/completeness.
- OPE convergence checks across the final window, especially
  \(|\Pi_{G^2}|,|\Pi_{G^3}| < |\Pi_{\rm pert}|\).
- A dedicated perturbative \(O(\alpha_s)\) calculation, beyond the current
  \(K_{ij}\)-factor sensitivity model.
- Pole-dominance and continuum-threshold criteria.
- A chosen \(M^2\) and \(s_0\) working region.
- Uncertainty propagation over \(m_b\), \(m_c\), \(G^2\), \(G^3\), \(M^2\),
  and \(s_0\).

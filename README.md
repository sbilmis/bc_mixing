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
  J^B_\mu=i\bar b\sigma_{\mu\alpha}p^\alpha\gamma_5 c .
  \]
- Spin-1 projection with
  \[
  P_{\mu\nu}^{(1)}=\frac{1}{3}
  \left(g_{\mu\nu}-\frac{p_\mu p_\nu}{p^2}\right).
  \]
- FeynCalc algebra for the `AA`, `AB`, and `BB` correlators.
- Perturbative spectral densities \(\rho^{ij}_{\rm pert}(s)\).
- Numerical Borel moments and perturbative mixing angle.
- Scan/table/plot helpers for trial \(M^2\) and \(s_0\) windows.
- FeynCalc algebra for the dimension-4 gluon condensate
  \(\langle g_s^2G^2\rangle\), not yet converted into the final numerical
  Borel moment.

The dimension-6 triple-gluon condensate \(\langle g_s^3G^3\rangle\) is not
implemented in this version.

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
-8.26908698135649
```

The raw quadrant-safe solution is also available:

```wl
NumericMixingAngleRawDegrees[10, 55, "pert"]
```

which gives

```wl
81.73091301864352
```

These two values differ by \(90^\circ\). The function
`NumericMixingAngleDegrees` reports the conventional principal branch in
\([-45^\circ,45^\circ]\).

This perturbative value is not yet the final QCD sum-rule prediction. The
next required physics step is adding the \(\langle g_s^2G^2\rangle\) Borel
moment.

## Borel-Window And Threshold Scans

Use `{min,max,step}` specifications for trial windows:

```wl
MixingAngleScan[{8, 12, 1}, {50, 60, 5}, "pert"]
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
MixingAngleDataset[{8, 12, 1}, {50, 60, 5}, "pert"]
MixingAngleTable[{8, 12, 1}, {50, 60, 5}, "pert"]
```

For plotting:

```wl
PlotMixingAngle[{8, 12}, 55, $BcMixingDefaultParameters, "pert"]
PlotMixingAngleS0[10, {50, 60}, $BcMixingDefaultParameters, "pert"]
MixingAngleContourPlot[{8, 12}, {50, 60}, $BcMixingDefaultParameters, "pert"]
```

A quick perturbative scan currently gives values near \(-8^\circ\) across
the example window:

```wl
MixingAngleMatrix[{8, 12, 2}, {50, 60, 5}, "pert"]
```

returns approximately

```wl
{{-8.66, -8.40, -8.20},
 {-8.57, -8.27, -8.02},
 {-8.52, -8.19, -7.91}}
```

for \(M^2=\{8,10,12\}\) and \(s_0=\{50,55,60\}\).

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

## Gluon Condensate Status

The script already builds the dimension-4 gluon-condensate algebra from

\[
S_c^{G^2}S_b^0,\qquad
S_c^0S_b^{G^2},\qquad
S_c^GS_b^G .
\]

These can be inspected with:

```wl
Correlator["AA", "G2"]
FeynmanParameterForm["AA", "G2"]
```

However, the \(\langle g_s^2G^2\rangle\) contribution should not be treated
as a smooth ordinary spectral density \(\rho_{G^2}(s)\). The Feynman-parameter
forms contain powers of denominators that generate delta functions and
derivatives of delta functions in the spectral representation.

The correct next implementation step is a direct Borel moment:

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

After this is implemented, the physical numerical angle should be computed
from

\[
\Pi^{ij}=\Pi^{ij}_{\rm pert}+\Pi^{ij}_{G^2}.
\]

Then the code should allow

```wl
NumericMixingAngleDegrees[M2, s0, "total"]
```

where `"total"` means perturbative plus \(\langle g_s^2G^2\rangle\).

## Paper Notes

The current perturbative scan is useful for debugging conventions and finding
a rough stability pattern, but it should not be quoted as the final result.
For a paper-level prediction we still need:

- Direct \(\langle g_s^2G^2\rangle\) Borel moments.
- OPE convergence checks, especially \(|\Pi_{G^2}| < |\Pi_{\rm pert}|\).
- Pole-dominance and continuum-threshold criteria.
- A chosen \(M^2\) and \(s_0\) working region.
- Uncertainty propagation over \(m_b\), \(m_c\), \(G^2\), \(M^2\), and \(s_0\).

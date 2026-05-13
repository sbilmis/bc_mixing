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
- Direct Borel moments for the dimension-4 gluon condensate
  \(\langle g_s^2G^2\rangle\).
- Scan/table/plot helpers for trial \(M^2\) and \(s_0\) windows.
- OPE-convergence scan helpers comparing \(G^2\) to the perturbative moment.

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

The perturbative value is useful for debugging conventions. The first
`"total"` value, including \(\langle g_s^2G^2\rangle\), is now available:

```wl
NumericMixingAngleDegrees[10, 55, "total"]
```

Current result:

```wl
-8.262530639106624
```

At this point the condensate correction is small, so the total angle is close
to the perturbative one. This should still be tested across the accepted
Borel window before quoting a paper-level result.

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

A quick total scan currently gives values near \(-8^\circ\) across
the example window:

```wl
MixingAngleMatrix[{8, 12, 2}, {50, 60, 5}, "total"]
```

returns approximately

```wl
{{-8.64, -8.38, -8.18},
 {-8.57, -8.26, -8.02},
 {-8.51, -8.18, -7.91}}
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
```

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

The physical numerical angle is computed from

\[
\Pi^{ij}=\Pi^{ij}_{\rm pert}+\Pi^{ij}_{G^2}.
\]

The code now allows

```wl
NumericMixingAngleDegrees[M2, s0, "total"]
```

where `"total"` means perturbative plus \(\langle g_s^2G^2\rangle\).

Implementation caveat: the direct \(G^2\) Borel transform uses the phase
convention `-I` to remove the loop-integration prefactor from the
Feynman-parameter amplitudes. This is consistent with the current
perturbative convention and gives a small OPE correction, but it should be
cross-checked against an independent derivation before finalizing the paper.

## Paper Notes

The current perturbative scan is useful for debugging conventions and finding
a rough stability pattern, but it should not be quoted as the final result.
For a paper-level prediction we still need:

- Independent validation of the \(\langle g_s^2G^2\rangle\) Borel formula.
- OPE convergence checks across the final window, especially
  \(|\Pi_{G^2}| < |\Pi_{\rm pert}|\).
- Pole-dominance and continuum-threshold criteria.
- A chosen \(M^2\) and \(s_0\) working region.
- Uncertainty propagation over \(m_b\), \(m_c\), \(G^2\), \(M^2\), and \(s_0\).

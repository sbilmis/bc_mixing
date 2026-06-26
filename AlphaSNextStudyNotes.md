# NLO alpha_s study notes

These notes are for the follow-up project on perturbative \(O(\alpha_s)\)
corrections to the \(B_c\) axial-vector mixing sum rule. They are not part of
the current LO + condensate arXiv paper.

## Channel plan

The mixing angle requires a channel-consistent NLO treatment of

\[
\Pi =
\begin{pmatrix}
\Pi^{AA} & \Pi^{AB}\\
\Pi^{AB} & \Pi^{BB}
\end{pmatrix}.
\]

The working order is:

1. freeze the independently checked \(\Pi^{AA}\) result;
2. import and match the published two-mass tensor-current result for
   \(\Pi^{BB}\);
3. derive the mixed \(\Pi^{AB}\) correlator directly.

Partial NLO shifts should be treated only as diagnostics until all three
entries are available in the same scheme and normalization.

## Tensor-current input for \(\Pi^{BB}\)

The tensor-current ancillary files were taken from the arXiv source associated
with:

T. Generet, "Correlator with tensor currents and two masses at two loops",
Eur. Phys. J. C 86 (2026) 112.

Local copies currently used:

- `external/arxiv_2509_02776_anc/LO_TT.m`
- `external/arxiv_2509_02776_anc/Im_NLO_TT_MSbar.m`
- `external/arxiv_2509_02776_anc/NLO_TT_MSbar.m`

The helper file

- `BcMixingAlphaSTensorBB.wl`

performs the matching checks and provisional \(BB\)-only diagnostics.

## Matching to our \(B\) current

Our normalized tensor current is

\[
J_B^\mu =
\frac{i}{m_b+m_c}\,
\bar b\,\sigma^{\mu\alpha}p_\alpha\gamma_5\,c .
\]

The tensor paper gives the tensor-current correlator. The axial-tensor result
is obtained with the paper's prescription

\[
m_1\to -m_b,\qquad m_2\to m_c .
\]

The LO cut fixes the normalization:

\[
\rho^{BB}_{0,\mathrm{ours}}
=
\frac{3}{(m_b+m_c)^2}
\frac{1}{\pi}
\operatorname{Im}\Pi^{AT}_{0,\mathrm{paper}} .
\]

Numerically, the matching check gives

\[
\frac{\operatorname{Im}\Pi^{AT}_{0,\mathrm{paper}}/\pi}
{\rho^{BB}_{0,\mathrm{ours}}(m_b+m_c)^2}
=
\frac{1}{3}
\]

at representative points \(s=35,40,50~\mathrm{GeV}^2\), with residual
differences below \(10^{-9}\) after applying the factor above.

## NLO convention

The file `Im_NLO_TT_MSbar.m` includes an explicit \(\alpha_s\). Our
`BcMixingAlphaS.wl` convention is

\[
\rho_{\mathrm{pert}}^{ij}(s)
=
\rho_0^{ij}(s)
+\frac{\alpha_s}{\pi}\rho_1^{ij}(s).
\]

Therefore the provisional matched \(BB\) NLO coefficient is

\[
\rho^{BB}_{1,\mathrm{ours}}
=
\frac{3}{(m_b+m_c)^2}
\frac{\operatorname{Im}\Pi^{AT}_{\mathrm{NLO,paper}}}{\alpha_s}.
\]

## Central diagnostic

At

\[
M^2=8~\mathrm{GeV}^2,\qquad s_0=54~\mathrm{GeV}^2,
\]

using the current default parameters and \(\mu=m_b\), the helper gives

\[
\Pi^{BB}_{\mathrm{LO,pert}} = 0.04309,
\]

\[
\Pi^{BB}_{\rho_1,\mathrm{NLO}} = -0.30592,
\]

and

\[
\frac{\alpha_s}{\pi}\Pi^{BB}_{\rho_1,\mathrm{NLO}}
=
-0.02532 .
\]

The corresponding \(BB\)-only relative perturbative shift is approximately

\[
-0.59 .
\]

If only \(BB\) is corrected while \(AA\) and \(AB\) remain at LO, the
perturbative mixing angle changes from \(43.29^\circ\) to \(33.40^\circ\).
This is **not** a physical NLO result; it is only a sensitivity diagnostic.
The mixed \(\Pi^{AB}\) correction is expected to be essential.

## Mixed \(AB\) channel scaffold

The file

- `BcMixingAlphaSMixedAB.wl`

starts the independent mixed axial-vector/tensor calculation. The first
checks are now in place:

\[
\rho^{AB}_{0,\mathrm{independent}}
-
\rho^{AB}_{0,\mathrm{main}}
=0,
\qquad
\frac{\rho^{AB}_{0,\mathrm{independent}}}
{\rho^{AB}_{0,\mathrm{main}}}
=1 .
\]

The two \(\gamma_5\) matrices in the mixed LO trace are eliminated with

\[
\mathrm{Tr}\left[
(\slashed p_c+m_c)\gamma_\mu\gamma_5
(\slashed p_b-m_b)\sigma_{\nu p}\gamma_5
\right]
=
\mathrm{Tr}\left[
(\slashed p_c-m_c)\gamma_\mu
(\slashed p_b-m_b)\sigma_{\nu p}
\right],
\]

with the tensor-current convention used in the main code,

\[
i\sigma_{\nu p}
=
-\frac12[\gamma_\nu,\slashed p].
\]

The \(\gamma_5\)-free identity check gives zero, and the D-dimensional
projected Born normalization ratio is currently

\[
\frac{B_D^{AB}}{B_4^{AB}}=1 .
\]

This is simpler than the \(AA\) case, where the \(O(\epsilon)\) Born
normalization factor was essential.

The virtual \(AB\) integrand has also been constructed with the same physical
routing used in the \(AA\) workbench. The scalar-reduction diagnostic gives:

- no remaining loop momentum after `TID`/`ToPaVe`;
- `ReadyForPackageX -> True`;
- reduced expression leaf count: 653.

The real-emission \(AB\) trace scaffold is present and evaluates numerically.
For example, at a representative physical Dalitz point

\[
s=40~\mathrm{GeV}^2,\qquad t=35~\mathrm{GeV}^2,
\]

with the midpoint of the allowed \(u\)-range, the projected trace evaluates to
approximately

\[
-163.26 .
\]

The next work item is the Package-X evaluation of the virtual scalar
integrals, followed by the soft subtraction and integrated dipole terms for
the real-emission piece.

### Virtual Package-X layer

The \(AB\) helper now includes a Package-X bridge for the unrenormalized
virtual graph:

- `IndependentABVirtualPaXUVIRSplit`
- `IndependentABVirtualPaXUVIRSplitMapped`
- `IndependentABVirtualPaXDiagnostic`
- `IndependentABVirtualRho1DiagnosticPoint`

The symbolic Package-X result has:

- mapped expression leaf count: 26427;
- no surviving `Indeterminate`, `ComplexInfinity`, or directed infinities;
- common-pole expression leaf count: 265;
- finite expression leaf count: 24951.

At the representative point

\[
s=40~\mathrm{GeV}^2,\qquad \mu=m_b=4.18~\mathrm{GeV},
\]

the raw virtual contribution converted to the \(\rho_1^{AB}\) normalization is

\[
\rho^{AB}_{0}=-0.28233,
\]

\[
\rho^{AB}_{1,\mathrm{virtual\ pole}}=-0.75597,
\]

\[
\rho^{AB}_{1,\mathrm{virtual\ finite}}=-2.13987,
\]

so the raw virtual finite ratio is

\[
\frac{\rho^{AB}_{1,\mathrm{virtual\ finite}}}{\rho^{AB}_{0}}
\simeq 7.58.
\]

This is not yet a physical NLO correction: the real-emission contribution,
integrated subtraction terms, and counterterms still have to be combined so
that the infrared poles cancel.

### Real-emission subtraction layer

The \(AB\) helper now contains the channel-specific real-emission subtraction
layer:

- `IndependentABRealEmissionSoftTheoremCheck`
- `IndependentABDipoleSoftCancellationCheck`
- `IndependentABRealMinusDipolesRho1`
- `IndependentABCompleteInsertionFiniteRho1`
- `IndependentABAssembledDiagnosticPoint`

The soft theorem check gives zero difference, and the leading soft difference
between the exact real-emission trace and the dipole sum also vanishes:

\[
\Delta_{\mathrm{soft}}^{AB}=0.
\]

At the representative point

\[
s=40~\mathrm{GeV}^2,\qquad \mu=m_b=4.18~\mathrm{GeV},
\]

the finite real-minus-dipoles integral gives approximately

\[
\rho^{AB}_{1,\mathrm{real-subtracted}}=-0.32822 .
\]

After correcting the external-field counterterm to use the explicit \(AB\)
Born density, the diagnostic assembly gives

\[
\rho^{AB}_{1,\mathrm{virtual\ finite}}=-2.13987,
\]

\[
\rho^{AB}_{1,\mathrm{field}}=+1.42557,
\]

\[
\rho^{AB}_{1,\mathrm{insertion}}=+1.44376,
\]

\[
\rho^{AB}_{1,\mathrm{real-subtracted}}=-0.32822,
\]

and therefore

\[
\rho^{AB}_{1,\mathrm{diagnostic}}=+0.40124,
\qquad
\frac{\rho^{AB}_{1,\mathrm{diagnostic}}}{\rho^{AB}_{0}}
\simeq -1.42.
\]

This is still marked diagnostic because the mixed channel contains one tensor
current. The tensor-current renormalization convention must be included before
this is promoted to the physical \(AB\) NLO coefficient.

### Tensor-current renormalization for \(AB\)

The tensor-current paper uses

\[
Z_T
=
1+\frac{\alpha_s}{4\pi\epsilon}C_F
+O(\alpha_s^2).
\]

For \(AB\), which contains one tensor current, this gives the pure-pole
counterterm

\[
\rho^{AB}_{1,\mathrm{tensor\ CT,pole}}
=
\frac{C_F}{4}\rho^{AB}_0.
\]

At

\[
s=40~\mathrm{GeV}^2,
\]

this pole coefficient is

\[
\rho^{AB}_{1,\mathrm{tensor\ CT,pole}}
=
-0.09411.
\]

There is no finite term in the minimal-subtraction convention, so the finite
diagnostic value above is unchanged. The pole is nevertheless required for
the UV bookkeeping.

### Cached \(AB\) diagnostic grid

The \(AB\) helper now caches the symbolic Package-X virtual result so that
multiple \(s\)-points can be evaluated without repeating the reduction:

- `IndependentABCachedVirtualPaXDiagnostic`
- `IndependentABDiagnosticGrid`

With modest integration settings, the current diagnostic grid gives:

\[
\begin{array}{c|c|c|c}
s~[\mathrm{GeV}^2] & \rho^{AB}_0
& \rho^{AB}_{1,\mathrm{diagnostic}}
& \rho^{AB}_{1,\mathrm{diagnostic}}/\rho^{AB}_0\\
\hline
35 & -0.10921 & 0.05477 & -0.50\\
40 & -0.28233 & 0.40124 & -1.42\\
50 & -0.71735 & 1.75869 & -2.45
\end{array}
\]

The growth of the diagnostic ratio with \(s\) should be checked with tighter
real-emission integration settings and with the final renormalization
conventions before using it in a Borel moment.

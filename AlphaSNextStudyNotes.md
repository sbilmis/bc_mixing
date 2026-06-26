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

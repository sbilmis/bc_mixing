# Diagnostic NLO contribution table

Central point:

\[
M^2=8~\mathrm{GeV}^2,\qquad s_0=54~\mathrm{GeV}^2,\qquad \alpha_s=0.26.
\]

LO perturbative mixing angle:

\[
\theta_{\mathrm{LO,pert}}=43.29^\circ .
\]

The table uses

\[
\Pi^{ij}_{\mathrm{NLO}}
=
\Pi^{ij}_{\mathrm{LO}}
+\frac{\alpha_s}{\pi}\Pi^{ij}_{\rho_1}.
\]

The last column shows the shift in the mixing angle when the NLO correction
is applied to that channel alone, while the other two channels are kept at
LO.

| Channel | \(\Pi^{ij}_{\mathrm{LO}}\) | \(\Pi^{ij}_{\rho_1}\) | \((\alpha_s/\pi)\Pi^{ij}_{\rho_1}\) | Relative shift | \(\Delta\theta\) from this channel only |
|---|---:|---:|---:|---:|---:|
| \(AA\) | \(0.04720\) | \(0.47526\) | \(+0.03933\) | \(+83.3\%\) | \(-14.45^\circ\) |
| \(AB\) | \(-0.03434\) | \(0.05539\) | \(+0.00458\) | \(-13.4\%\) | \(-0.26^\circ\) |
| \(BB\) | \(0.04309\) | \(-0.30592\) | \(-0.02532\) | \(-58.8\%\) | \(-9.89^\circ\) |

If the current diagnostic corrections are applied simultaneously to
\(AA\), \(AB\), and \(BB\), the perturbative moments become

\[
\Pi^{AA}=0.08653,\qquad
\Pi^{AB}=-0.02975,\qquad
\Pi^{BB}=0.01778,
\]

and the diagnostic angle becomes

\[
\theta_{\mathrm{diag}}=20.44^\circ,
\qquad
\Delta\theta_{\mathrm{diag}}=-22.85^\circ .
\]

Important caveat: this is a diagnostic table, not yet a final NLO prediction.
The \(AA\) entry is currently an on-shell fixed-input diagnostic, the \(AB\)
entry is the current mixed-channel diagnostic, and the \(BB\) entry is matched
from the tensor-current paper. A final table requires all three channels in
one common mass/current-renormalization scheme.

## Current combined diagnostic, but not the final NLO prediction

Using the three currently available entries as they stand gives

\[
\theta_{\mathrm{LO,pert}}=43.29^\circ,\qquad
\theta_{\mathrm{diag}}=20.44^\circ,
\]

or

\[
\Delta\theta_{\mathrm{diag}}=-22.85^\circ .
\]

This is the number to use as the present stress test of the calculation:
it tells us that the perturbative \(O(\alpha_s)\) corrections are not a
small cosmetic change in the angle.  It should not be quoted as the final
NLO prediction until \(AA\), \(AB\), and \(BB\) are evaluated with the same
mass definition, the same renormalization scale, and the same current
normalization convention.

Equivalently, the current combined diagnostic can be summarized as

| Input moments | \(\Pi^{AA}\) | \(\Pi^{AB}\) | \(\Pi^{BB}\) | \(\theta\) |
|---|---:|---:|---:|---:|
| LO perturbative | \(0.04720\) | \(-0.03434\) | \(0.04309\) | \(43.29^\circ\) |
| Current NLO diagnostic | \(0.08653\) | \(-0.02975\) | \(0.01778\) | \(20.44^\circ\) |

Thus the current diagnostic shift is

\[
\Delta\theta_{\rm diag}
=
\theta_{\rm diag}-\theta_{\rm LO,pert}
=
-22.85^\circ .
\]

The wording I would use in the notes is:

> Combining the currently available \(O(\alpha_s)\) diagnostic corrections in
> the \(AA\), \(AB\), and \(BB\) channels gives
> \(\theta_{\rm diag}=20.44^\circ\), corresponding to
> \(\Delta\theta_{\rm diag}=-22.85^\circ\) at
> \(M^2=8~\mathrm{GeV}^2\) and \(s_0=54~\mathrm{GeV}^2\).
> This number should be regarded as a diagnostic stress test rather than a
> final NLO prediction, because the three channels have not yet been fully
> synchronized in one common mass and current-renormalization scheme.

## Why the \(AA\) correction is large

The size of the \(AA\) entry is not coming from a single small numerical
mistake in the final angle formula.  At the central point the decomposition
of the \(AA\) Borel coefficient is

\[
\Pi^{AA}_{\rho_1}=0.47526
=0.70931-0.28613+0.05208 ,
\]

where the three terms are, respectively, the virtual plus field-renormalization
finite part, the integrated subtraction contribution, and the real-minus-
subtraction finite remainder.  Thus the large positive virtual/field piece is
only partially cancelled by the subtraction terms.

There is also a physical enhancement.  The Borel integral is strongly weighted
toward the heavy-quark threshold,

\[
s_{\rm th}=(m_b+m_c)^2=29.70~\mathrm{GeV}^2 ,
\]

and the low quadrature points sit very close to threshold.  For the six-node
diagnostic grid one finds approximately

| \(s\) | \(s-s_{\rm th}\) | heavy-quark velocity \(v\) |
|---:|---:|---:|
| \(29.730\) | \(0.028\) | \(0.072\) |
| \(30.400\) | \(0.697\) | \(0.346\) |
| \(33.224\) | \(3.521\) | \(0.660\) |
| \(39.022\) | \(9.319\) | \(0.846\) |
| \(46.465\) | \(16.763\) | \(0.922\) |
| \(52.387\) | \(22.684\) | \(0.948\) |

Near threshold the massive color-singlet heavy-quark spectral density has the
usual Coulomb-type enhancement, schematically \(\sim \alpha_s/v\).  Since the
Borel weight favors precisely this region, the \(AA\) correction becomes large
relative to the LO \(AA\) moment:

\[
\frac{(\alpha_s/\pi)\Pi^{AA}_{\rho_1}}{\Pi^{AA}_{\rm LO}}
=
\frac{0.03933}{0.04720}
\simeq 83\% .
\]

The large angular effect is then amplified by the mixing-angle formula because
\(\Pi^{AA}_{\rm LO}\) and \(\Pi^{BB}_{\rm LO}\) are close to one another:

\[
\Pi^{AA}_{\rm LO}=0.04720,\qquad
\Pi^{BB}_{\rm LO}=0.04309 .
\]

Therefore a correction to \(AA\) changes the denominator
\(\Pi^{AA}-\Pi^{BB}\) rather efficiently.  In short, the large \(AA\) effect is
mainly threshold/Coulomb enhancement plus angle sensitivity, with a sizable
positive virtual/field finite term that is not fully cancelled by the real and
subtraction pieces.

## LaTeX table

```tex
\begin{table}[t]
\centering
\caption{Diagnostic size of the perturbative \(O(\alpha_s)\) corrections at
\(M^2=8~\mathrm{GeV}^2\) and \(s_0=54~\mathrm{GeV}^2\). The last column shows
the change in the mixing angle when the NLO correction is applied to the
specified channel only.}
\begin{tabular}{c c c c c c}
\hline
Channel &
\(\Pi_{\rm LO}^{ij}\) &
\(\Pi_{\rho_1}^{ij}\) &
\((\alpha_s/\pi)\Pi_{\rho_1}^{ij}\) &
Relative shift &
\(\Delta\theta\) \\
\hline
\(AA\) & \(0.04720\) & \(0.47526\) & \(+0.03933\) & \(+83.3\%\) & \(-14.45^\circ\) \\
\(AB\) & \(-0.03434\) & \(0.05539\) & \(+0.00458\) & \(-13.4\%\) & \(-0.26^\circ\) \\
\(BB\) & \(0.04309\) & \(-0.30592\) & \(-0.02532\) & \(-58.8\%\) & \(-9.89^\circ\) \\
\hline
\end{tabular}
\label{tab:nlo-diagnostic-channel-contributions}
\end{table}
```

## LaTeX combined diagnostic table

```tex
\begin{table}[t]
\centering
\caption{Current combined perturbative \(O(\alpha_s)\) diagnostic at
\(M^2=8~\mathrm{GeV}^2\) and \(s_0=54~\mathrm{GeV}^2\). This table is a
stress test of the size of the correction and should not be interpreted as
the final NLO prediction until all three channels are evaluated in one common
mass and current-renormalization scheme.}
\begin{tabular}{c c c c c}
\hline
Input moments &
\(\Pi^{AA}\) &
\(\Pi^{AB}\) &
\(\Pi^{BB}\) &
\(\theta\) \\
\hline
LO perturbative &
\(0.04720\) &
\(-0.03434\) &
\(0.04309\) &
\(43.29^\circ\) \\
Current NLO diagnostic &
\(0.08653\) &
\(-0.02975\) &
\(0.01778\) &
\(20.44^\circ\) \\
\hline
\end{tabular}
\label{tab:nlo-current-combined-diagnostic}
\end{table}
```

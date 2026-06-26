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

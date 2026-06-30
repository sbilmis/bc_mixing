# Synchronized \(AA,AB,BB\) NLO diagnostic

This note records the end-of-session synchronized perturbative
\(O(\alpha_s)\) diagnostic.  It is more consistent than the earlier
fixed-input table because all three channels are evaluated with one common
numerical scheme:

\[
M^2=8~\mathrm{GeV}^2,\qquad
s_0=54~\mathrm{GeV}^2,\qquad
\mu=4.18~\mathrm{GeV}.
\]

The one-loop common-scale \(\overline{\rm MS}\) inputs are

\[
\overline m_b(\mu)=4.1800~\mathrm{GeV},\qquad
\overline m_c(\mu)=1.0440~\mathrm{GeV},
\]

\[
\alpha_s(\mu)=0.21217 .
\]

The corresponding perturbative threshold is

\[
s_{\rm th}=(\overline m_b+\overline m_c)^2=27.2898~\mathrm{GeV}^2 .
\]

## Scheme used

The synchronization prescription is:

1. \(AA\): use the validated independent \(AA\) coefficient and add the
   one-loop pole-to-\(\overline{\rm MS}\) Born-derivative mass conversion.
2. \(BB\): use the imported two-mass tensor-current result
   `Im_NLO_TT_MSbar.m`, evaluated with the same running masses and the same
   scale \(\mu\).
3. \(AB\): use the present finite mixed-channel diagnostic evaluated with the
   same running masses and scale, and add the same Born-derivative
   pole-to-\(\overline{\rm MS}\) mass-conversion term.

The \(AB\) item is the limiting caveat: the finite \(AB\) coefficient is still
the diagnostic construction, not yet an independently published/checkable
closed-form \(\overline{\rm MS}\) coefficient.  Therefore the result below is
best described as a **synchronized NLO diagnostic**, not as the final
publication-grade NLO prediction.

## Channel moments

The perturbative moments are written as

\[
\Pi^{ij}_{\rm pert}
=
\Pi^{ij}_{\rm LO}
+
\frac{\alpha_s}{\pi}\Pi^{ij}_{\rho_1}.
\]

The synchronized central result is:

| Channel | \(\Pi^{ij}_{\rm LO}\) | \(\Pi^{ij}_{\rho_1}\) | \((\alpha_s/\pi)\Pi^{ij}_{\rho_1}\) | Relative shift |
|---|---:|---:|---:|---:|
| \(AA\) | \(0.06947\) | \(-0.49883\) | \(-0.03369\) | \(-48.5\%\) |
| \(AB\) | \(-0.05573\) | \(+1.09800\) | \(+0.07415\) | \(-133.1\%\) |
| \(BB\) | \(0.06900\) | \(-0.38704\) | \(-0.02614\) | \(-37.9\%\) |

Equivalently, as a direct without/with NLO comparison:

| Channel | Without NLO: \(\Pi_{\rm LO}\) | NLO change | With NLO | \(K=(\alpha_s/\pi)\Pi_1/\Pi_{\rm LO}\) |
|---|---:|---:|---:|---:|
| \(AA\) | \(0.06947\) | \(-0.03369\) | \(0.03578\) | \(-0.485\) |
| \(AB\) | \(-0.05573\) | \(+0.07415\) | \(0.01842\) | \(-1.331\) |
| \(BB\) | \(0.06900\) | \(-0.02614\) | \(0.04286\) | \(-0.379\) |

The \(K\)-factor column is a convergence diagnostic.  In the \(AB\) row the
LO moment is negative while the NLO change is positive, so the relative shift
is negative and larger than one in magnitude.

The size of these channel corrections is consistent with the heavy-heavy
threshold sensitivity of the Borel integral.  With the synchronized masses,

\[
s_{\rm th}=27.2898~\mathrm{GeV}^2,
\]

and the first Borel nodes probe small velocities:

| \(s\) | \(s-s_{\rm th}\) | \(v_{\rm rel}\) | \(\alpha_s/v_{\rm rel}\) |
|---:|---:|---:|---:|
| \(27.320\) | \(0.030\) | \(0.083\) | \(2.55\) |
| \(28.056\) | \(0.766\) | \(0.394\) | \(0.54\) |
| \(31.161\) | \(3.871\) | \(0.721\) | \(0.29\) |

Thus a Coulomb-like threshold structure, schematically \(\alpha_s/v_{\rm rel}\),
is not parametrically small in the lowest part of the Borel integral.  This
explains why the fixed-order channel diagnostics can be sizeable, although
the sign and final magnitude still depend on the current projection,
subtraction terms, and mass-scheme conversion.

For \(AA\), the decomposition of the synchronized \(\rho_1\) coefficient is

\[
\Pi^{AA}_{\rho_1,\rm OS~coeff.~at~\overline{MS}~masses}
=0.64786,
\]

\[
\Pi^{AA}_{\rho_1,\rm mass~conversion}
=-1.14669,
\]

so that

\[
\Pi^{AA}_{\rho_1,\overline{\rm MS}}
=-0.49883 .
\]

This is important: the large positive fixed-input \(AA\) coefficient is
substantially reorganized by the common short-distance mass prescription.

For \(AB\), the corresponding diagnostic decomposition is

\[
\Pi^{AB}_{\rho_1,\rm diagnostic~at~\overline{MS}~masses}
=0.10288,
\]

\[
\Pi^{AB}_{\rho_1,\rm mass~conversion}
=0.99512,
\]

so that

\[
\Pi^{AB}_{\rho_1,\rm sync.~diagnostic}
=1.09800 .
\]

The \(AB\) mass-conversion term is numerically large.  This is the main reason
the synchronized table should still be treated as a diagnostic.  It should be
rechecked when deriving the final \(AB\) coefficient directly in the common
\(\overline{\rm MS}\) scheme, including the normalized tensor-current
convention.

### Direct check of the \(AB\) mass-conversion term

The possible concern is that the large \(AB\) mass-conversion term might be an
artifact of differentiating the explicit tensor-current normalization

\[
J_B^\mu
=
\frac{i}{m_b+m_c}\,
\bar b\,\sigma^{\mu\alpha}p_\alpha\gamma_5\,c .
\]

To test this, the Born-derivative pole-to-\(\overline{\rm MS}\) conversion was
split into two pieces:

1. a conversion of the unnormalized spectral density, holding the explicit
   \(1/(m_b+m_c)\) current normalization fixed;
2. the remaining contribution from differentiating the current normalization
   itself.

The result is

\[
\Pi^{AB}_{\rho_1,\rm mass~conv.,full}=0.99512,
\]

\[
\Pi^{AB}_{\rho_1,\rm mass~conv.,norm.~fixed}=0.88991,
\]

\[
\Pi^{AB}_{\rho_1,\rm mass~conv.,norm.~only}=0.10521.
\]

Thus only about

\[
\frac{0.10521}{0.99512}\simeq 11\%
\]

of the \(AB\) mass-conversion term comes from the explicit tensor-current
normalization.  The large conversion is therefore **not** mainly an artifact
of differentiating \(1/(m_b+m_c)\); it is dominantly produced by the
mass-dependence of the underlying \(AB\) Born spectral density.

For comparison, if the tensor-current normalization is artificially held
fixed, the synchronized \(AB\) coefficient becomes

\[
\Pi^{AB}_{\rho_1,\rm sync.,norm.~fixed}
=
0.10288+0.88991
=0.99279,
\]

instead of the full

\[
\Pi^{AB}_{\rho_1,\rm sync.,full}=1.09800.
\]

The corresponding all-channel synchronized diagnostic angle changes from

\[
\theta_{\rm sync.~diag.,full}=39.56^\circ
\]

to

\[
\theta_{\rm sync.~diag.,norm.~fixed}=36.32^\circ .
\]

Both variants remain a sizeable NLO effect.  This verifies that the large
\(AB\) correction is not removed by the tensor-current normalization choice.

## Mixing angle

Using the synchronized LO moments gives

\[
\theta_{\rm LO}=44.88^\circ .
\]

Applying each channel correction separately gives

| Correction included | \(\theta\) | \(\Delta\theta\) |
|---|---:|---:|
| \(AA\) only | \(-36.70^\circ\) | \(+8.42^\circ\) |
| \(AB\) only | \(-44.63^\circ\) | \(+0.49^\circ\) |
| \(BB\) only | \(38.29^\circ\) | \(-6.59^\circ\) |
| \(AA+AB+BB\) synchronized diagnostic | \(39.56^\circ\) | \(-5.32^\circ\) |

Angles are reported in the same normalized convention used by the workbench.
The negative angles differ from their positive representatives by the
mixing-angle periodicity convention; the quoted \(\Delta\theta\) values are
the normalized shifts.

Thus the synchronized diagnostic result is

\[
\boxed{
\theta_{\rm sync.~diag.}=39.56^\circ,
\qquad
\Delta\theta_{\rm sync.~diag.}=-5.32^\circ .
}
\]

For quick comparison, the relevant LO/NLO values are:

| Setup | Mass/scheme convention | Perturbative content | \(\theta\) |
|---|---|---|---:|
| Earlier central LO diagnostic | fixed-input masses \(m_b=4.18,\ m_c=1.27\) | LO only | \(43.29^\circ\) |
| Synchronized LO baseline | common-scale \(\overline{\rm MS}\), \(\mu=4.18~\mathrm{GeV}\) | LO only | \(44.88^\circ\) |
| Synchronized NLO diagnostic | common-scale \(\overline{\rm MS}\), \(\mu=4.18~\mathrm{GeV}\) | LO + \(O(\alpha_s)\) in \(AA,AB,BB\) | \(39.56^\circ\) |

Thus the NLO shift should be quoted relative to the synchronized LO baseline,
not relative to the earlier fixed-input LO number:

\[
\Delta\theta_{\rm sync.~diag.}
=
39.56^\circ-44.88^\circ
=
-5.32^\circ .
\]

## Interpretation

This synchronized diagnostic changes the picture relative to the earlier
fixed-input table:

- the fixed-input \(AA\) correction was \(+83\%\);
- after common-scale \(\overline{\rm MS}\) conversion, the \(AA\) shift is
  \(-48.5\%\);
- \(BB\) gives a moderate negative shift of \(-37.9\%\);
- the largest remaining scheme-sensitive issue is \(AB\), where the
  Born-derivative mass-conversion term is large.

The end-of-session conclusion is therefore:

\[
\boxed{
\text{The three channels have been synchronized at the diagnostic level, and
the dominant source of the large }AB\text{ mass-conversion term has been
checked.}
}
\]

The synchronized diagnostic is therefore a sensible endpoint for the present
NLO session.  A publication-grade final NLO prediction would still require a
fully independent \(AB\) finite coefficient written directly in the same
\(\overline{\rm MS}\) scheme, but the immediate concern about the normalized
tensor-current denominator has been resolved: it accounts for only a small
part of the large \(AB\) conversion.

## Output files

The numerical output is stored in:

- `AlphaS_synchronized_NLO_diagnostic.csv`
- `AlphaS_synchronized_NLO_diagnostic_summary.mx`
- `AlphaS_synchronized_AA_summary.mx`
- `AlphaS_synchronized_AB_summary.mx`
- `AlphaS_synchronized_BB_summary.mx`
- `AlphaS_AB_MSbar_conversion_split.csv`

The runner is:

- `RunSynchronizedNLODiagnostic.wl`

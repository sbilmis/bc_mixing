# \(AA\) NLO convergence audit

This note is for the follow-up perturbative \(O(\alpha_s)\) study, not for the
current LO + condensate paper.

## Present central-point observation

At the current fixed-input diagnostic point

\[
M^2=8~\mathrm{GeV}^2,\qquad s_0=54~\mathrm{GeV}^2,\qquad \alpha_s=0.26,
\]

the \(AA\) perturbative moments are

\[
\Pi^{AA}_{\rm LO}=0.04720,
\qquad
\frac{\alpha_s}{\pi}\Pi^{AA}_{\rho_1}=0.03933 .
\]

Thus

\[
\frac{(\alpha_s/\pi)\Pi^{AA}_{\rho_1}}
{\Pi^{AA}_{\rm LO}}
\simeq 0.83 .
\]

The NLO correction is not larger than the LO term, but it is close to it.
This is a marginal/poor fixed-order convergence signal.

## Decomposition of the large \(AA\) coefficient

The current Borel coefficient decomposes as

\[
\Pi^{AA}_{\rho_1}
=0.47526
=0.70931-0.28613+0.05208 ,
\]

where the three terms are

\[
\Pi^{AA}_{\rho_1,\rm virt+field}=0.70931,
\]

\[
\Pi^{AA}_{\rho_1,\rm int.\,dipoles}=-0.28613,
\]

\[
\Pi^{AA}_{\rho_1,\rm real-sub}=0.05208 .
\]

Therefore the first target of the audit is the virtual plus field-renormalized
finite term.  Since the finite on-shell field counterterm is proportional to
the LO density as

\[
\rho^{AA}_{1,\rm field}
=
-\frac{C_F}{4}
\left[
8+3\log\frac{\mu^2}{m_b^2}
+3\log\frac{\mu^2}{m_c^2}
\right]\rho^{AA}_0 ,
\]

the field term itself is not expected to be the positive enhancement.  If
\(\rho^{AA}_{1,\rm virt+field}\) is positive and large, the raw virtual finite
piece is even larger before adding the field counterterm.  The audit should
therefore separate

\[
\rho^{AA}_{1,\rm virt},\qquad
\rho^{AA}_{1,\rm field},\qquad
\rho^{AA}_{1,\rm virt+field}
\]

at representative \(s\)-points.

## Threshold/asymptotic check

The code already contains the diagnostic

```wl
IndependentAAThresholdCoulombCheck[{0.05, 0.10, 0.25, 0.50},
  params,
  "RenormalizationScale" -> mb
]
```

Its expected asymptotic behavior is

\[
v_{\rm rel}\frac{\rho^{AA}_1}{\rho^{AA}_0}
\longrightarrow
C_F\pi^2
=
\frac{4}{3}\pi^2
\simeq 13.16 ,
\]

where

\[
v_{\rm rel}
=
\frac{\sqrt{\lambda(s,m_b^2,m_c^2)}}{s-m_b^2-m_c^2}.
\]

This is the most direct check that the large \(AA\) correction is driven by
the usual heavy-heavy Coulomb enhancement.  The current Borel quadrature is
indeed threshold sensitive: for \(m_b=4.18~\mathrm{GeV}\) and
\(m_c=1.27~\mathrm{GeV}\),

\[
s_{\rm th}=(m_b+m_c)^2=29.70~\mathrm{GeV}^2.
\]

The low diagnostic nodes include

| \(s\) | \(s-s_{\rm th}\) | \(v_{\rm rel}\) |
|---:|---:|---:|
| \(29.730\) | \(0.028\) | \(0.072\) |
| \(30.400\) | \(0.697\) | \(0.346\) |
| \(33.224\) | \(3.521\) | \(0.660\) |

The first node is sufficiently close to threshold that a fixed-order
\(\alpha_s/v\) term can easily become numerically large.

## Parameter-stability tests

These scans should be interpreted as diagnostics, not as a way to tune the
answer.

### Incremental scan result

The cached incremental runner

```wl
RunAANLOConvergenceAuditIncremental.wl
```

has now produced the first stability diagnostics.  The central point is
reproduced as

\[
\Pi^{AA}_{\rm LO}=0.04720,\qquad
\Pi^{AA}_{\rho_1}=0.47528,
\]

\[
\frac{\alpha_s}{\pi}\Pi^{AA}_{\rho_1}=0.03933,
\qquad
K_{AA}\equiv
\frac{(\alpha_s/\pi)\Pi^{AA}_{\rho_1}}{\Pi^{AA}_{\rm LO}}
=0.833 .
\]

The \(M^2\)-scan at \(s_0=54~\mathrm{GeV}^2\) and \(\mu=4.18~\mathrm{GeV}\)
gives

| \(M^2~[\mathrm{GeV}^2]\) | \(K_{AA}\) |
|---:|---:|
| \(6\) | \(0.894\) |
| \(7\) | \(0.859\) |
| \(8\) | \(0.833\) |
| \(9\) | \(0.814\) |
| \(10\) | \(0.800\) |
| \(11\) | \(0.788\) |
| \(12\) | \(0.779\) |

The continuum-threshold scan at \(M^2=8~\mathrm{GeV}^2\) and
\(\mu=4.18~\mathrm{GeV}\) gives

| \(s_0~[\mathrm{GeV}^2]\) | \(K_{AA}\) |
|---:|---:|
| \(50\) | \(0.874\) |
| \(52\) | \(0.852\) |
| \(54\) | \(0.833\) |
| \(56\) | \(0.818\) |
| \(58\) | \(0.805\) |

The scale scan at \(M^2=8~\mathrm{GeV}^2\), \(s_0=54~\mathrm{GeV}^2\)
shows no change in the total fixed-input diagnostic coefficient:

| \(\mu~[\mathrm{GeV}]\) | \(K_{AA}\) |
|---:|---:|
| \(2\) | \(0.833\) |
| \(3\) | \(0.833\) |
| \(4.18\) | \(0.833\) |
| \(5\) | \(0.833\) |

In the scale scan the virtual-plus-field and integrated-dipole terms move
separately, but their sum remains stable.  For example,

\[
\Pi^{AA}_{\rho_1,\rm virt+field}:
0.620\to0.688,
\qquad
\Pi^{AA}_{\rho_1,\rm int.\,dipoles}:
-0.197\to-0.265,
\]

as \(\mu\) goes from \(2\) to \(5~\mathrm{GeV}\), while

\[
\Pi^{AA}_{\rho_1,\rm total}=0.47528
\]

is unchanged in this fixed-input diagnostic.

The conclusion of these scans is therefore:

\[
\boxed{
K_{AA}\simeq 0.8\text{--}0.9
\quad\text{throughout the tested window.}
}
\]

The mild decrease with increasing \(M^2\) and \(s_0\) supports the interpretation
that the large correction is enhanced by the threshold-weighted part of the
Borel integral.  However, the correction remains \(O(1)\), so the fixed-order
\(AA\) channel is not comfortably convergent in this diagnostic scheme.

### Interpretation of “robust in this diagnostic scheme”

Here “robust” has a narrow technical meaning.  It does **not** mean that the
number is already a final physical NLO prediction.  It means that the large
relative correction is not removed by ordinary variations of the auxiliary sum
rule parameters within the tested diagnostic window:

\[
K_{AA}=0.78\text{--}0.89
\]

over the scans in \(M^2\), \(s_0\), and \(\mu\).  In particular:

- increasing \(M^2\) from \(6\) to \(12~\mathrm{GeV}^2\) lowers
  \(K_{AA}\) only from \(0.894\) to \(0.779\);
- increasing \(s_0\) from \(50\) to \(58~\mathrm{GeV}^2\) lowers
  \(K_{AA}\) only from \(0.874\) to \(0.805\);
- changing \(\mu\) between \(2\) and \(5~\mathrm{GeV}\) reshuffles the
  virtual-plus-field and integrated-subtraction pieces, but leaves the total
  fixed-input coefficient unchanged in this diagnostic implementation.

This pattern is important.  If the large \(AA\) correction were only an
accidental artifact of one central point, it would be expected to collapse
under one of these scans.  It does not.  The mild downward trend with larger
\(M^2\) and larger \(s_0\) instead points to a threshold-weighting effect:
larger \(M^2\) or \(s_0\) gives relatively more weight to higher-velocity
regions, where an \(\alpha_s/v\)-enhanced contribution is less dominant.

The safest wording is therefore:

> In the present fixed-input diagnostic, the \(AA\) perturbative
> \(O(\alpha_s)\) correction is consistently large,
> \(K_{AA}\simeq0.8\text{--}0.9\), throughout the tested auxiliary-parameter
> window.  This indicates poor fixed-order convergence in the \(AA\) channel
> unless the effect is reorganized, for example by a common short-distance
> mass scheme and/or by treating the heavy-heavy threshold enhancement more
> carefully.

The phrase “in this diagnostic scheme” is essential.  The next-stage physical
prediction must still synchronize \(AA\), \(AB\), and \(BB\) in one mass and
current-renormalization scheme.  A common \(\overline{\rm MS}\)-mass treatment
may change the numerical value, but the present scans show that the large
effect is not a fragile parameter-choice accident.

### Borel-parameter scan

Run

\[
M^2=6,\ 7,\ 8,\ 9,\ 10,\ 11,\ 12~\mathrm{GeV}^2
\]

at fixed \(s_0=54~\mathrm{GeV}^2\), and record

\[
K_{AA}(M^2)
=
\frac{(\alpha_s/\pi)\Pi^{AA}_{\rho_1}}
{\Pi^{AA}_{\rm LO}} .
\]

Expected signature:

- if \(K_{AA}\) decreases as \(M^2\) increases, the large correction is mainly
  threshold/Borel-weight driven;
- if \(K_{AA}\) remains near \(O(1)\) across the accepted window, the fixed
  order is intrinsically marginal in this channel.

### Continuum-threshold scan

Run

\[
s_0=50,\ 52,\ 54,\ 56,\ 58~\mathrm{GeV}^2
\]

at fixed \(M^2=8~\mathrm{GeV}^2\).

Expected signature:

- increasing \(s_0\) gives more weight to larger velocities and may reduce
  the relative \(AA\) correction;
- however \(s_0\) should not be chosen to improve perturbative convergence
  unless the usual pole-dominance/OPE criteria remain acceptable.

### Renormalization-scale scan

Run

\[
\mu=2,\ 3,\ 4.18,\ 5~\mathrm{GeV}.
\]

The \(AA\) result should also be checked in a common
\(\overline{\rm MS}\)-mass scheme.  The existing helper is

```wl
IndependentAAFinalNLOBorelMSbarSummary[
  M2, s0, mu,
  $BcAlphaSMSbarDefaults,
  $BcMixingDefaultParameters,
  "NPoints" -> 6,
  "Progress" -> True
]
```

If the \(AA\) ratio stays large in the common-scale
\(\overline{\rm MS}\) version, the effect is probably physical threshold
enhancement rather than only a pole-mass artifact.

### Threshold-cut diagnostic

As a diagnostic only, repeat the Borel integral with

\[
s_{\min}=s_{\rm th}+\Delta,
\qquad
\Delta=0.1,\ 0.25,\ 0.5,\ 1.0~\mathrm{GeV}^2 .
\]

This is not a physical sum rule, but it cleanly identifies whether the first
threshold slice dominates the large \(AA\) K-factor.  A strong reduction of
\(K_{AA}\) after this cut would support the Coulomb-enhancement interpretation.

## Calculation checks to perform

1. Reproduce the UV pole cancellation symbolically:

\[
\rho^{AA}_{1,\rm virt,UV}
+
\rho^{AA}_{1,\rm field,UV}
=0 .
\]

2. Reproduce the IR cancellation numerically:

\[
\rho^{AA}_{1,\rm virt,IR}
+
\rho^{AA}_{1,\rm field,IR}
+
\rho^{AA}_{1,\rm real,IR}
=0 .
\]

3. Check the finite virtual normalization using an equal-mass limit against
known vector/axial heavy-quark spectral-density expressions where possible.

4. Check the unequal-mass threshold limit:

\[
v_{\rm rel}\rho^{AA}_1/\rho^{AA}_0\to C_F\pi^2 .
\]

5. Verify the field finite term sign and the \(\mu\)-dependent logarithms:

\[
-\frac{C_F}{4}
\left[
8+3\log\frac{\mu^2}{m_b^2}
+3\log\frac{\mu^2}{m_c^2}
\right]\rho^{AA}_0 .
\]

6. Repeat the central \(AA\) number with higher quadrature points after the
threshold/asymptotic tests pass.

## Literature context

Large perturbative corrections are not by themselves impossible in QCD
sum rules:

- Groote, Körner, and Yakovlev found that perturbative
  \(O(\alpha_s)\) corrections to the leading heavy-baryon spectral function
  can amount to about \(100\%\), while physical extracted masses move much
  less strongly:
  <https://arxiv.org/abs/hep-ph/9609469>.
- \(B_c\) sum-rule and heavy-quarkonium analyses have long emphasized the
  significance of Coulomb-like \(\alpha_s/v\) corrections near threshold.
  This is directly relevant here because the \(B_c\)-type two-heavy-quark
  threshold region is strongly weighted by the Borel kernel.  Examples are
  Kiselev, Likhoded, and Onishchenko,
  <https://arxiv.org/abs/hep-ph/9905359>, and Kiselev, Kovalsky, and
  Likhoded, <https://arxiv.org/abs/hep-ph/0006104>.

The \(B_c\) papers should be used as an order-of-magnitude and mechanism
comparison, not as a one-to-one numerical prediction for the present mixing
correlator.  Their message is that double-heavy systems are special near
threshold: the perturbative expansion can contain Coulombic factors of the
form

\[
\frac{\alpha_s}{v},
\]

or Sommerfeld-type enhancement factors schematically of the form

\[
C(v)
\sim
\frac{4\pi\alpha_s/(3v)}
{1-\exp[-4\pi\alpha_s/(3v)]}.
\]

When \(v\) is small, this correction is \(O(1)\), even if \(\alpha_s\) itself
is moderate.  The present \(AA\) Borel integral samples very small velocities
near threshold; for example the lowest diagnostic node has

\[
v_{\rm rel}\simeq0.072 .
\]

Thus an \(80\%\)-level \(AA\) correction is not unprecedented in the broader
heavy-heavy sum-rule context.  It is, however, a convergence warning.  The
appropriate conclusion is not “the calculation is wrong,” but rather:

\[
\boxed{
\text{the fixed-order }AA\text{ channel is threshold sensitive and must be
treated with care before making a final NLO mixing-angle prediction.}
}

Thus an \(AA\) correction at the \(80\%\) level is a serious convergence
warning, but it is not automatically a proof that the calculation is wrong.
The decisive tests are the threshold asymptotic check, the scheme comparison,
and the \(M^2,s_0,\mu\) stability scans.

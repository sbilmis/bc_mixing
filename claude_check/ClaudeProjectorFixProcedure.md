# Projector-Convention Fix — Procedure and Results

**Date:** 2026-06-30
**Scope:** B_c(1P) mixing-angle QCD sum rule, momentum-space production code

This note documents the independent verification that found a projector-convention
bug in the condensate (G2, G3) part of `BcMixingMomentum.wl`, the one-line fix
applied in a separate copy, and the regenerated stability results.

---

## 1. What was checked first (background)

Before touching the production code, the perturbative spectral densities
ρ^AA, ρ^AB, ρ^BB were independently re-derived from scratch with FeynCalc
(`claude_check/CheckFromScratch.wl`) and compared against the paper's closed-form
formulas (eqs. 23–25). Agreement was at machine precision (< 10⁻¹⁵ relative error).
See `claude_check/VerificationNotes.md` and the `feyncalc-verification` memory
note for the full record, including two now-fixed bugs found in the *scratch*
script itself (a spurious `Tr[1]=4` and an incorrect `1/3` projector) — these
were development bugs in the independent check, not in the paper or in
`BcMixingMomentum.wl`.

The G2 (dimension-4 gluon condensate) contribution was then independently
computed from scratch (`claude_check/CheckG2Scratch.wl`): FeynCalc trace,
Feynman-parameter coefficients, x-limits, and numerical Borel integral for the
charm-line and bottom-line insertions, all cross-checked against an
equal-mass (m_b=m_c) symmetry test.

**Comparing the from-scratch G2 result to the production code's G2_AA value
revealed a ratio of 2.515 ≈ 3 × 0.838**, where 0.838 = (G2c+G2b)/(G2c+G2b+G2gg)
is the fraction of G2 not coming from the two-line gluon-exchange piece
(G2gg), which was *not* independently recomputed. The factor of 3 pointed at a
projector-convention mismatch.

## 2. Root cause

`BcMixingMomentum.wl` has two independent numerator pipelines:

- **Perturbative**: `PerturbativeNumerator[channel]` (line ~663) is a
  hand-derived, hardcoded closed-form result. It does **not** include a `1/3`
  factor. It was verified (Section 1 above) to reproduce the paper's
  ρ^AA, ρ^AB, ρ^BB exactly.
- **Condensates (G2, G3)**: built symbolically via `LoopIntegrand` →
  `Correlator` → `ProjectSpin1`, where `ProjectSpin1` (line 425-433) applies

  ```mathematica
  projector = 1/3 (MT[mu, nu] - FV[p, mu] FV[p, nu]/SP[p, p]);
  ```

Physics: the textbook Lorentz decomposition Π_μν = T_μν Π_1 + L_μν Π_0 (with
T_μν = g_μν − p_μp_ν/s) is inverted by Π_1 = (1/3) T^μν Π_μν — the 1/3 is
needed to extract the *standard* invariant amplitude. But the paper's
convention (confirmed by the machine-precision match of `PerturbativeNumerator`)
is Π_1^paper = T^μν Π_μν, i.e. **3× the standard amplitude, no 1/3**.

Since `PerturbativeNumerator` was derived without the 1/3 and matches the
paper exactly, while `ProjectSpin1` (used for *all* condensate orders: G2c,
G2b, G2gg, G3c, G3b) includes the 1/3, the perturbative and condensate pieces
of the production code are in **different, inconsistent conventions**. The
condensate contributions (G2 and G3, i.e. everything through dimension 6) are
each **3× too small** in the unmodified `BcMixingMomentum.wl`.

This is purely a code bug. **The paper's formulas are not affected** — the
paper's eqs. (23)-(25) match the no-1/3 convention, which is what was verified.

## 3. Other checks performed on the same read-through

- **Dimension-6 (G3) structure**: `SG3Num`/`SG3Den`/`SG3Prefactor`
  (`BcMixingMomentum.wl:302-307`) implement the standard single-quark-line
  ⟨g³G³⟩ insertion (G3 = G3c + G3b, no cross-line G3gg — noted in the code
  comment as intentionally out of scope, handled separately in
  `BcMixingDimension6Complete.wl`). Structure is standard and correct.
- **Built-in dimensional analysis**: `$BcMixingMassDimensions` assigns
  G2→4, G3→6, m_b,m_c→1, k,p→1, M²,s₀,s→2. `CheckMixingMassDimensions[True]`
  returns `True` for all four channels — the perturbative spectral densities
  are dimension 2 as required.
- **SBar(x) and x-limits**: `SBar[x] = (m_c²x + m_b²(1−x))/(x(1−x))` and
  `ContinuumXLimits` (using A = s₀+m_b²−m_c², Källén λ(s₀,m_b²,m_c²)) were
  verified algebraically to be the correct root condition SBar(x)=s₀, and to
  give identical limits for both the G2c (weight x³) and G2b (weight (1−x)³)
  Feynman integrals, since the shifted-momentum denominator Δ(x) is the same
  function in both cases. Confirmed numerically against the equal-mass
  (m_b=m_c=2 GeV, s₀=22 GeV²) symmetry point.
- **Reference for the m_b=m_c limit**: Reinders, Rubinstein, Yazaki,
  *Phys. Rept.* 127 (1985) 1 — gives ρ^AA = N_c s β³/(4π²),
  β=√(1−4m²/s), for equal-mass P-wave quarkonium. Also Shifman, Vainshtein,
  Zakharov, *Nucl. Phys.* B147 (1979) 385, 448, for the SVZ sum-rule
  framework underlying the whole calculation.

## 4. The fix

Copies were made; **the original production files were left untouched**:

| Original | Fixed copy |
|---|---|
| `BcMixingMomentum.wl` | `BcMixingMomentum_claude.wl` |
| `BcMixingMomentum.nb` | `BcMixingMomentum_claude.nb` |
| `RegenerateBcMixingArtifacts.wl` | `RegenerateBcMixingArtifacts_claude.wl` |

One-line change in `BcMixingMomentum_claude.wl` (`ProjectSpin1`, was line 427):

```mathematica
(* before *)
projector = 1/3 (MT[mu, nu] - FV[p, mu] FV[p, nu]/SP[p, p]);
(* after *)
projector = (MT[mu, nu] - FV[p, mu] FV[p, nu]/SP[p, p]);
```

`BcMixingMomentum_claude.nb` was updated to `Get["BcMixingMomentum_claude.wl"]`
instead of the original filename (its only code dependency — the notebook is a
thin wrapper, all physics lives in the .wl file).

`RegenerateBcMixingArtifacts_claude.wl` was updated to:
- load `BcMixingMomentum_claude.wl`,
- use order `"total"` (perturbative + G2 + G3) instead of the original
  `"pertG2"`, so the dim-6 correction is included in the regenerated plots,
- write all CSV/PDF outputs with a `_claude` suffix so nothing in the
  original artifact set is overwritten,
- additionally precompute `G3BorelIntegrandExpression` for all channels.

## 5. Numerical effect of the fix

Single-point check at the paper's reference point (M²=8 GeV², s₀=53 GeV²),
`claude_check/RunFixed.wl` / `claude_check/ComputeAngles.wl`:

| | θ | Δθ vs pert |
|---|---|---|
| Perturbative | 43.170° | — |
| + G2 (buggy, 1/3) | 43.198° | +0.029° |
| + G2 (fixed, no 1/3) | 43.256° | +0.086° |
| + G2 + G3 (fixed) | **43.234°** | **+0.064°** |

G2 condensate values scale by exactly 3× after the fix, as expected. G3
(computed for the first time with the corrected projector — it was not
previously reported through `NumericBorelPi[..., "total", ...]`) has the
**opposite sign** to G2 for the AA channel, partially canceling the G2 shift.

OPE convergence at this point (AA channel): |G2|/pert ≈ 1.26%,
|G3|/pert ≈ 0.29%, |G3|/|G2| ≈ 23% — a healthy convergent hierarchy.

## 6. Full stability scan (M² ∈ [7,9], s₀ ∈ [53,55] GeV², 25 points/curve)

Regenerated with `RegenerateBcMixingArtifacts_claude.wl`, order `"total"`:

- `BcMixingThetaVsM2_WangWindow_claude.csv` / `.pdf`
- `BcMixingThetaVsS0_WangWindow_claude.csv` / `.pdf`

(See these files for the corrected stability plots; they supersede
`BcMixingThetaVsM2_WangWindow.pdf` / `BcMixingThetaVsS0_WangWindow.pdf` for
any plot that is meant to include the condensate correction, until the fix is
folded into the production file.)

## 7. What is still open

1. **Production files are not yet fixed** — `BcMixingMomentum.wl` and
   `BcMixingMomentum.nb` still contain the `1/3` bug. Only the `_claude`
   copies have the fix. Apply the same one-line change to the originals
   before any further use, and regenerate all dependent artifacts
   (Monte Carlo summaries, other stability plots, OPE ratio plots) that were
   produced with the buggy condensate normalization.
2. ~~G2gg was not independently re-derived from scratch~~ **G2gg VERIFIED**
   (`claude_check/CheckG2ggScratch.wl` + `CheckG2ggVerify.wl`, 2026-07-01).
   Independent FeynCalc build using the standard fixed-point-gauge single-gluon
   propagator insertion `S^{(1g)}_{mn}=-1/4[σ_{mn}(q̸+m)+(q̸+m)σ_{mn}]/(q²-m²)²`
   and vacuum average `⟨g²G^a G^b⟩=δ^{ab}/(Nc²-1)×G2/12×tensor`.
   Color-algebra derivation: `Tr_c[T^aT^b]=δ^{ab}/2` combined with the
   vacuum normalization gives prefactor **(G2/24), Nc-independent**.
   `Simplify[FCI[scratch]−FCI[production]]=0` for all three channels (AA, AB, BB).
   `GGVacuumPrefactor[Nc=3]=G2×(9-1)/2/96=G2/24` — exact match confirmed.
3. Any text in the paper that quotes specific Π^{ij}_G2 values or a specific
   Δθ from the condensate correction needs to be updated to the corrected
   numbers in Section 5 above.
4. The `BcMixingCoordinate*.wl` files (coordinate-space implementation)
   were not checked for the same projector convention — worth a quick grep
   for `1/3` and `ProjectSpin1`-like patterns before trusting their output.
5. ~~`BcMixingDimension6Complete.wl` cross-line G3 projector~~ **FIXED**
   (`BcMixingDimension6Complete_claude.wl`, 2026-07-01):
   `D6ProjectSpin1Fast` (line 429) had the same `1/3` bug as `ProjectSpin1`.
   Fix: removed `1/3` from `D6ProjectSpin1Fast` in the `_claude` copy.
   The cached numeric grid `d6_chunks/G3cross_M2Grid_s0_53p_n25.wl` was built
   with the buggy projection; a corrected grid was created by multiplying all
   numeric AA and AB entries by 3 and saved as
   `d6_chunks/G3cross_M2Grid_s0_53p_n25_claude.wl`.
   (BB cross-line timed out at all 25 M² grid points in the original chunk
   computation — the timeout is not caused by the projector bug and persists.)
   The CompleteD6 figure was regenerated with the corrected projector; since
   BB is unavailable, the fourth curve shows theta with BB_cross=0 (partial):

   | | θ at M²=8, s₀=53 |
   |---|---|
   | pert | 43.1697° |
   | + G2 (fixed) | 43.2561° |
   | + G2 + G3 single-line (fixed) | 43.2342° |
   | + G2 + G3 + G3cross(AA+AB; BB_cross=0) | **43.2358°** |

   Cross-line G3 shift (partial): +0.0016° — negligibly small versus the
   single-line G3 shift of −0.022°.

   Output artifacts:
   - `BcMixingMomentumThetaOrdersCompleteD6VsM2_s0_53_claude.pdf` (Mathematica)
   - `output_claude/pdf/BcMixingThetaOrdersCompleteD6Publication_s0_53_claude.pdf` (Python)

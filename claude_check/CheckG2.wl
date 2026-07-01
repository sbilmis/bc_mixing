(* CheckG2.wl
   G2 condensate contribution to Bc mixing Borel moments.

   Loads the production code, runs NumericBorelPiG2 for all three channels,
   compares with perturbative, and reports the mixing angle shift.

   WARNING: First call to NumericBorelPiG2 triggers FeynmanParameterForm
   which does symbolic Feynman parametrization + TID tensor reduction.
   Expect 3-15 min total for AA + AB + BB. Results are memoized.

   Also flags the projector-convention issue:
   - Perturbative spectral density uses no-1/3 projector (matches paper eqs.23-25)
   - G2 Feynman-parameter form uses 1/3 projector (ProjectSpin1)
   These are inconsistent by a factor of 3 unless the paper's G2 formulas
   also use the 1/3 convention. The discrepancy matters when G2/pert is large.
*)

Print["============================================================"];
Print["  CheckG2: G2 condensate Borel moment check"];
Print["============================================================"];
Print[];

(* Load production code *)
Print["Loading BcMixingMomentum.wl ..."];
tLoad = AbsoluteTime[];
Get["/Users/sbilmis/Bc_mixing/BcMixingMomentum.wl"];
Print["Loaded in ", Round[AbsoluteTime[]-tLoad, 0.1], " s"];
Print[];

(* Parameters: use both default (M2=10, s0=55) and paper reference (M2=8, s0=53) *)
pars = $BcMixingDefaultParameters;
channels = {"AA", "AB", "BB"};

(* -----------------------------------------------------------------
   1. Dimension check (built-in)
   ----------------------------------------------------------------- *)
Print["=== 1. Dimension Check ==="];
Print["Mass dimension of spectral density (should all equal 2):"];
dimReport = PerturbativeSpectralDensityDimensionReport[];
Do[
  Print["  rho_pert^", ch, ": dim = ", dimReport[ch]["Dimension"],
        "  Pass=", dimReport[ch]["Pass"]],
  {ch, {"AA", "AB", "BA", "BB"}}
];
Print[];

(* Dimension of G2 symbol (dim 4) and SBar (dim 2) *)
Print["  [G2] = ", MassDimension[G2], "  (expected 4)"];
Print["  [SBar(xi)] = ", MassDimension[SBar[xi]], "  (expected 2)"];
Print["  [SG2Prefactor] = G2/12: dim ", MassDimension[G2/12],
      " -> propagator numerator mc*(k^2+mc*k) has dim 3,",
      " loop d^4k adds dim 4, denominator (k^2-mc^2)^4 * (k-p)^2 has dim 10",
      " => total = 4+4+3-10 = 1? + current factors -> 2 total"];
Print["  (Full dimensional analysis requires the full trace; code's built-in",
      " CheckMixingMassDimensions verifies this automatically.)"];
Print["  CheckMixingMassDimensions[True] = ", CheckMixingMassDimensions[True]];
Print[];

(* -----------------------------------------------------------------
   2. Perturbative Borel moments (fast, from spectral density)
   ----------------------------------------------------------------- *)
Print["=== 2. Perturbative Borel Moments ==="];

computePert[m2v_, s0v_] := Module[{t, res},
  t = AbsoluteTime[];
  res = Association[# -> NumericBorelPi[#, "pert", m2v, s0v] & /@ channels];
  Print["  M2=", m2v, " s0=", s0v, "  time=", Round[AbsoluteTime[]-t, 0.1], " s"];
  Do[Print["    Pi^", ch, "_pert = ", ScientificForm[res[ch], 6]], {ch, channels}];
  res
];

Print["--- Reference point: M2=8, s0=53 ---"];
pertRef = computePert[8., 53.];
{aaP_ref, abP_ref, bbP_ref} = pertRef /@ channels;
thetaPert_ref = 180/Pi * 1/2 * ArcTan[aaP_ref - bbP_ref, -2 abP_ref];
Print["  tan(2theta) denominator Pi^AA-Pi^BB = ", N[aaP_ref - bbP_ref, 5]];
Print["  tan(2theta) numerator -2*Pi^AB = ", N[-2 abP_ref, 5]];
Print["  theta(pert only, M2=8, s0=53) = ", N[thetaPert_ref, 7], " deg"];
Print[];

Print["--- Default params: M2=10, s0=55 ---"];
pertDef = computePert[10., 55.];
{aaP_def, abP_def, bbP_def} = pertDef /@ channels;
thetaPert_def = 180/Pi * 1/2 * ArcTan[aaP_def - bbP_def, -2 abP_def];
Print["  theta(pert only, M2=10, s0=55) = ", N[thetaPert_def, 7], " deg"];
Print[];

(* -----------------------------------------------------------------
   3. G2 Borel moments (slow on first call -- memoized after)
   ----------------------------------------------------------------- *)
Print["=== 3. G2 Borel Moments ==="];
Print["(FeynmanParameterForm + BorelTransformQ2 runs on first call per channel)"];
Print[];

computeG2[ch_String, m2v_, s0v_] := Module[{t, res},
  Print["  Computing G2 for channel ", ch, " ..."];
  t = AbsoluteTime[];
  res = NumericBorelPi[ch, "G2", m2v, s0v];
  Print["  Done in ", Round[AbsoluteTime[]-t, 0.1], " s  =>  Pi^", ch, "_G2 = ",
        ScientificForm[res, 6]];
  res
];

Print["--- M2=8, s0=53 ---"];
g2AA_ref = computeG2["AA", 8., 53.];
g2AB_ref = computeG2["AB", 8., 53.];
g2BB_ref = computeG2["BB", 8., 53.];

Print[];
Print["  G2/pert ratios at M2=8, s0=53:"];
Print["    Pi^AA: G2 = ", ScientificForm[g2AA_ref, 4],
      "  pert = ", ScientificForm[aaP_ref, 4],
      "  ratio = ", N[g2AA_ref/aaP_ref, 4]];
Print["    Pi^AB: G2 = ", ScientificForm[g2AB_ref, 4],
      "  pert = ", ScientificForm[abP_ref, 4],
      "  ratio = ", N[g2AB_ref/abP_ref, 4]];
Print["    Pi^BB: G2 = ", ScientificForm[g2BB_ref, 4],
      "  pert = ", ScientificForm[bbP_ref, 4],
      "  ratio = ", N[g2BB_ref/bbP_ref, 4]];
Print[];

(* -----------------------------------------------------------------
   4. G2 at default params (memoized -- fast)
   ----------------------------------------------------------------- *)
Print["--- M2=10, s0=55 (memoized, fast) ---"];
g2AA_def = NumericBorelPi["AA", "G2", 10., 55.];
g2AB_def = NumericBorelPi["AB", "G2", 10., 55.];
g2BB_def = NumericBorelPi["BB", "G2", 10., 55.];
Print["    Pi^AA: G2 = ", ScientificForm[g2AA_def, 4],
      "  pert = ", ScientificForm[aaP_def, 4],
      "  ratio = ", N[g2AA_def/aaP_def, 4]];
Print["    Pi^AB: G2 = ", ScientificForm[g2AB_def, 4],
      "  pert = ", ScientificForm[abP_def, 4],
      "  ratio = ", N[g2AB_def/abP_def, 4]];
Print["    Pi^BB: G2 = ", ScientificForm[g2BB_def, 4],
      "  pert = ", ScientificForm[bbP_def, 4],
      "  ratio = ", N[g2BB_def/bbP_def, 4]];
Print[];

(* -----------------------------------------------------------------
   5. Mixing angle with G2 included
   ----------------------------------------------------------------- *)
Print["=== 4. Mixing Angle Comparison ==="];

(* Case: production code as-is (G2 uses 1/3 projector, pert uses no-1/3) *)
aaFull_ref = aaP_ref + g2AA_ref;
abFull_ref = abP_ref + g2AB_ref;
bbFull_ref = bbP_ref + g2BB_ref;
thetaFull_ref = 180/Pi * 1/2 * ArcTan[aaFull_ref - bbFull_ref, -2 abFull_ref];

aaFull_def = aaP_def + g2AA_def;
abFull_def = abP_def + g2AB_def;
bbFull_def = bbP_def + g2BB_def;
thetaFull_def = 180/Pi * 1/2 * ArcTan[aaFull_def - bbFull_def, -2 abFull_def];

Print["  M2=8, s0=53:"];
Print["    theta(pert)      = ", N[thetaPert_ref, 7], " deg"];
Print["    theta(pert+G2)   = ", N[thetaFull_ref, 7], " deg"];
Print["    Delta_theta(G2)  = ", N[thetaFull_ref - thetaPert_ref, 4], " deg"];
Print[];
Print["  M2=10, s0=55:"];
Print["    theta(pert)      = ", N[thetaPert_def, 7], " deg"];
Print["    theta(pert+G2)   = ", N[thetaFull_def, 7], " deg"];
Print["    Delta_theta(G2)  = ", N[thetaFull_def - thetaPert_def, 4], " deg"];
Print[];

(* Projector-convention sensitivity: if G2 used no-1/3 (factor of 3 larger) *)
Print["=== 5. Projector Convention Sensitivity ==="];
Print["  The production code uses 1/3 in ProjectSpin1 for G2,"];
Print["  but the perturbative rho uses no-1/3 (paper convention)."];
Print["  If G2 should also use no-1/3, multiply G2 moments by 3:"];
Print[];

aaFull3_ref = aaP_ref + 3 g2AA_ref;
abFull3_ref = abP_ref + 3 g2AB_ref;
bbFull3_ref = bbP_ref + 3 g2BB_ref;
thetaFull3_ref = 180/Pi * 1/2 * ArcTan[aaFull3_ref - bbFull3_ref, -2 abFull3_ref];

Print["  M2=8, s0=53 with G2 scaled by 3:"];
Print["    theta(pert+3*G2) = ", N[thetaFull3_ref, 7], " deg"];
Print["    Delta_theta      = ", N[thetaFull3_ref - thetaPert_ref, 4], " deg"];
Print[];
Print["  This brackets the uncertainty from the projector convention:"];
Print["  Delta_theta is between ", N[thetaFull_ref - thetaPert_ref, 3],
      " and ", N[thetaFull3_ref - thetaPert_ref, 3], " deg"];

Print[];
Print["============================================================"];
Print["  SUMMARY"];
Print["============================================================"];
Print["  Perturbative theta (M2=8, s0=53):  ", N[thetaPert_ref, 6], " deg"];
Print["  G2 contribution:"];
Print["    Pi^AA_G2 / Pi^AA_pert = ", N[g2AA_ref/aaP_ref, 4]];
Print["    Pi^AB_G2 / Pi^AB_pert = ", N[g2AB_ref/abP_ref, 4]];
Print["    Pi^BB_G2 / Pi^BB_pert = ", N[g2BB_ref/bbP_ref, 4]];
Print["  Mixing angle shift from G2:"];
Print["    With production-code convention (1/3): Delta_theta = ",
      N[thetaFull_ref - thetaPert_ref, 4], " deg"];
Print["    If G2 should use no-1/3 convention:   Delta_theta = ",
      N[thetaFull3_ref - thetaPert_ref, 4], " deg"];
Print[];
Quit[];

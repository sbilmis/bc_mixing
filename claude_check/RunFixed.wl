(* RunFixed.wl
   Loads the projector-fixed production code and computes G2+G3 Borel moments
   for all three channels at (M2=8,s0=53) and (M2=10,s0=55).
   Compares with perturbative to get the corrected mixing angle.
*)

Print["============================================================"];
Print["  RunFixed: condensate moments with corrected projector"];
Print["  Fix: removed 1/3 from ProjectSpin1 in BcMixingMomentum_fixed.wl"];
Print["============================================================"];
Print[];

tLoad = AbsoluteTime[];
Get["/Users/sbilmis/Bc_mixing/claude_check/BcMixingMomentum_fixed.wl"];
Print["Loaded in ", Round[AbsoluteTime[]-tLoad, 0.1], " s"];
Print[];

channels = {"AA", "AB", "BB"};

(* ---- Perturbative ---- *)
Print["=== Perturbative moments ==="];
{aaP8, abP8, bbP8} = NumericBorelPi[#, "pert", 8., 53.] & /@ channels;
{aaP10, abP10, bbP10} = NumericBorelPi[#, "pert", 10., 55.] & /@ channels;
thetaP8  = 180/Pi * 1/2 * ArcTan[aaP8  - bbP8,  -2 abP8];
thetaP10 = 180/Pi * 1/2 * ArcTan[aaP10 - bbP10, -2 abP10];
Print["  M2=8,  s0=53: Pi^AA=", N[aaP8,6],  "  Pi^AB=", N[abP8,6],  "  Pi^BB=", N[bbP8,6]];
Print["  theta_pert(8,53)  = ", N[thetaP8, 7], " deg"];
Print["  M2=10, s0=55: Pi^AA=", N[aaP10,6], "  Pi^AB=", N[abP10,6], "  Pi^BB=", N[bbP10,6]];
Print["  theta_pert(10,55) = ", N[thetaP10, 7], " deg"];
Print[];

(* ---- G2 (fixed projector) ---- *)
Print["=== G2 moments (fixed projector, no 1/3) ==="];
Do[
  Print["  Computing G2 channel ", ch, " at M2=8, s0=53 ..."];
  t = AbsoluteTime[];
  v = NumericBorelPi[ch, "G2", 8., 53.];
  Print["    => ", ScientificForm[v, 6], "   (", Round[AbsoluteTime[]-t, 0.1], " s)"],
  {ch, channels}
];
{g2AA8, g2AB8, g2BB8} = NumericBorelPi[#, "G2", 8., 53.] & /@ channels;
Print[];
Print["  G2/pert ratios (M2=8, s0=53):"];
Print["    AA: ", N[g2AA8/aaP8, 4]];
Print["    AB: ", N[g2AB8/abP8, 4]];
Print["    BB: ", N[g2BB8/bbP8, 4]];
Print[];

(* Mixing angle with G2 *)
theta_pertG2_8 = 180/Pi * 1/2 * ArcTan[(aaP8+g2AA8)-(bbP8+g2BB8), -2(abP8+g2AB8)];
Print["  theta(pert+G2_fixed, M2=8, s0=53) = ", N[theta_pertG2_8, 7], " deg"];
Print["  Delta_theta(G2) = ", N[theta_pertG2_8 - thetaP8, 4], " deg"];
Print[];

(* Same at M2=10, s0=55 — memoized so fast *)
{g2AA10, g2AB10, g2BB10} = NumericBorelPi[#, "G2", 10., 55.] & /@ channels;
theta_pertG2_10 = 180/Pi * 1/2 * ArcTan[(aaP10+g2AA10)-(bbP10+g2BB10), -2(abP10+g2AB10)];
Print["  theta(pert+G2_fixed, M2=10, s0=55) = ", N[theta_pertG2_10, 7], " deg"];
Print["  Delta_theta(G2) = ", N[theta_pertG2_10 - thetaP10, 4], " deg"];
Print[];

(* ---- G3 (dim-6, fixed projector) ---- *)
Print["=== G3 moments (dim-6, fixed projector) ==="];
Do[
  Print["  Computing G3 channel ", ch, " at M2=8, s0=53 ..."];
  t = AbsoluteTime[];
  v = NumericBorelPi[ch, "G3", 8., 53.];
  Print["    => ", ScientificForm[v, 6], "   (", Round[AbsoluteTime[]-t, 0.1], " s)"],
  {ch, channels}
];
{g3AA8, g3AB8, g3BB8} = NumericBorelPi[#, "G3", 8., 53.] & /@ channels;
Print[];
Print["  G3/pert ratios (M2=8, s0=53):"];
Print["    AA: ", N[g3AA8/aaP8, 4]];
Print["    AB: ", N[g3AB8/abP8, 4]];
Print["    BB: ", N[g3BB8/bbP8, 4]];
Print[];

(* Mixing angle with G2+G3 *)
theta_total_8 = 180/Pi * 1/2 * ArcTan[
  (aaP8+g2AA8+g3AA8) - (bbP8+g2BB8+g3BB8),
  -2(abP8+g2AB8+g3AB8)
];
Print["  theta(pert+G2+G3_fixed, M2=8, s0=53) = ", N[theta_total_8, 7], " deg"];
Print["  Delta_theta(G2+G3) = ", N[theta_total_8 - thetaP8, 4], " deg"];
Print[];

(* Same at M2=10, s0=55 *)
{g3AA10, g3AB10, g3BB10} = NumericBorelPi[#, "G3", 10., 55.] & /@ channels;
theta_total_10 = 180/Pi * 1/2 * ArcTan[
  (aaP10+g2AA10+g3AA10) - (bbP10+g2BB10+g3BB10),
  -2(abP10+g2AB10+g3AB10)
];
Print["  theta(pert+G2+G3_fixed, M2=10, s0=55) = ", N[theta_total_10, 7], " deg"];
Print["  Delta_theta(G2+G3) = ", N[theta_total_10 - thetaP10, 4], " deg"];
Print[];

Print["============================================================"];
Print["  SUMMARY (corrected projector)"];
Print["============================================================"];
Print["  M2=8, s0=53:"];
Print["    theta(pert)        = ", N[thetaP8, 7], " deg"];
Print["    theta(pert+G2)     = ", N[theta_pertG2_8, 7], " deg   Delta=", N[theta_pertG2_8-thetaP8,4], " deg"];
Print["    theta(pert+G2+G3)  = ", N[theta_total_8, 7], " deg   Delta=", N[theta_total_8-thetaP8,4], " deg"];
Print[];
Print["  M2=10, s0=55:"];
Print["    theta(pert)        = ", N[thetaP10, 7], " deg"];
Print["    theta(pert+G2)     = ", N[theta_pertG2_10, 7], " deg   Delta=", N[theta_pertG2_10-thetaP10,4], " deg"];
Print["    theta(pert+G2+G3)  = ", N[theta_total_10, 7], " deg   Delta=", N[theta_total_10-thetaP10,4], " deg"];
Print[];
Quit[];

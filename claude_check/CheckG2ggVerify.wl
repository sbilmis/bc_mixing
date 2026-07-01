(* CheckG2ggVerify.wl
   Symbolic equality check: independent G2gg scratch == production LoopIntegrand.
   Scratch results are saved to a private context before Get[] clears Global`.
*)
Needs["FeynCalc`"];
Quiet[FCSetDiracGammaScheme["NDR"]];
$PrePrint = Identity;
Print["=== CheckG2ggVerify: symbolic equality test ==="];
Print[];

(* ---- Build independent scratch integrands ---- *)
indVA[l_] := GA[l] . GA[5];
indVB[l_] := I / (mb + mc) * DiracSigma[GA[l], GS[p]] . GA[5];
indV["A", l_] := indVA[l];
indV["B", l_] := indVB[l];
indSGNum[q_, m_, a_, b_] := -1/4 (
  DiracSigma[GA[a], GA[b]] . (GS[q] + m) +
  (GS[q] + m) . DiracSigma[GA[a], GA[b]]
);
indSGDen[q_, m_] := FAD[{q, m, 2}];
indGGTensor[a_, b_, r_, t_] := MT[a, r] MT[b, t] - MT[a, t] MT[b, r];
indGGPrefactor = G2/24;

buildTrace[c1_, c2_] := Module[{chain},
  chain = indV[c1, mu] . indSGNum[k, mc, al, be] .
          indV[c2, nu] . indSGNum[k - p, mb, rh, si];
  chain // DotSimplify // DiracSigmaExplicit // DiracTrace // DiracSimplify // Contract // FCE
];
buildIntegrand[tr_] := indGGPrefactor *
  (Contract[indGGTensor[al, be, rh, si] tr] // FCE // Contract) *
  indSGDen[k, mc] indSGDen[k - p, mb] // FCE;

Print["Building scratch integrands..."];
t0 = AbsoluteTime[];
scrAA0 = buildIntegrand[buildTrace["A", "A"]];
scrAB0 = buildIntegrand[buildTrace["A", "B"]];
scrBB0 = buildIntegrand[buildTrace["B", "B"]];
Print["  done (", Round[AbsoluteTime[] - t0, 0.1], " s)"];

(* Save to private context so ClearAll["Global`*"] inside Get[] cannot wipe them *)
BeginPackage["G2ggV`"];
Quiet[G2ggV`sAA::usage=""; G2ggV`sAB::usage=""; G2ggV`sBB::usage=""];
EndPackage[];
G2ggV`sAA = scrAA0;
G2ggV`sAB = scrAB0;
G2ggV`sBB = scrBB0;
Print["Saved to G2ggV` context."];
Print[];

(* ---- Load production code ---- *)
Get["/Users/sbilmis/Bc_mixing/BcMixingMomentum_claude.wl"];
Print[];

(* ---- Retrieve production integrands ---- *)
Print["Retrieving production LoopIntegrand[X,\"G2gg\"]..."];
t0 = AbsoluteTime[];
prodAA = LoopIntegrand["AA", "G2gg"];
prodAB = LoopIntegrand["AB", "G2gg"];
prodBB = LoopIntegrand["BB", "G2gg"];
Print["  done (", Round[AbsoluteTime[] - t0, 0.1], " s)"];
Print[];

(* ---- Symbolic diff test ----
   FCI converts both to canonical internal FeynCalc form, then Simplify checks
   whether the difference vanishes identically. *)
checkDiff[saved_, prod_, label_] := Module[{diff, res},
  diff = FCI[saved] - FCI[prod];
  res  = Simplify[diff] === 0;
  Print["  ", label, ":  diff Simplify[]=0? ", res];
  If[!res,
    (* secondary check: FullSimplify with extra time *)
    res2 = FullSimplify[diff] === 0;
    Print["    (FullSimplify: ", res2, ")"];
    If[!res2,
      Print["    Non-zero diff: ", FullSimplify[diff] // InputForm]
    ]
  ]
];

Print["=== Symbolic difference checks ==="];
checkDiff[G2ggV`sAA, prodAA, "AA"];
checkDiff[G2ggV`sAB, prodAB, "AB"];
checkDiff[G2ggV`sBB, prodBB, "BB"];
Print[];

(* ---- GGVacuumPrefactor cross-check ---- *)
pfProd = N[GGVacuumPrefactor[] /. G2 -> 1];
pfInd  = N[1/24];
Print["=== GGVacuumPrefactor check ==="];
Print["  Production GGVacuumPrefactor[Nc=3, G2=1] = ", pfProd];
Print["  Independent G2/24 derivation   [G2=1]   = ", pfInd];
Print["  Exact match: ", pfProd === pfInd];
Print[];

Print["=== CheckG2ggVerify COMPLETE ==="];
Quit[];

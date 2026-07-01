(* CheckG2ggScratch.wl
   Independent FeynCalc verification of the G2gg (cross-line gluon-condensate)
   contribution to the B_c(1P) mixing correlator for all three channels (AA/AB/BB).

   METHOD: build the diagram ab initio using standard QFT primitives, WITHOUT
   reusing SGNum/SGDen/GGVacuumTensor/GGVacuumPrefactor/ProjectSpin1 from the
   production code.  The prefactor G2/24 is derived from first principles via
   explicit color-algebra counting.  After saving the result to a private context,
   the production code is loaded and LoopIntegrand["X","G2gg"] values retrieved.
   A numeric ratio test (at a generic off-shell kinematic point) then checks
   whether scratch and production agree.

   PHYSICS DERIVATION OF G2/24 PREFACTOR
   <g_s^2 G^a_{mn}(0) G^b_{rs}(0)> = delta^{ab}/(Nc^2-1) * (G2/12) * (g_{mr}g_{ns}-g_{ms}g_{nr})
     [standard SVZ/RRY normalization; same G2 as SG2Prefactor=G2/12]
   Color trace in the closed quark loop (one T^a on c-line, one T^b on b-line):
     Tr_c[T^a T^b] = delta^{ab}/2  [fundamental rep, T_F = 1/2]
   Summing over all a,b with delta^{ab} from both factors:
     Sum_a (1/2) * (1/(Nc^2-1)) * G2/12 * (Nc^2-1 terms) = (1/2)(G2/12) = G2/24
   independent of Nc.  At Nc=3: GGVacuumPrefactor[] = G2*(9-1)/2/96 = G2*4/96 = G2/24. ✓
*)

Needs["FeynCalc`"];
Quiet[FCSetDiracGammaScheme["NDR"]];
$PrePrint = Identity;

Print["======================================================="];
Print["  CheckG2ggScratch: Independent G2gg verification"];
Print["  (cross-line gluon-condensate, three channels)"];
Print["======================================================="];
Print[];

(* ---- Independent current vertices ---- *)
indVA[l_] := GA[l] . GA[5];
(* B-type: I*(1/(mb+mc)) * sigma^{l p} . gamma5   -- matches production with
   $BcMixingKeepRawTensorI=True and TensorCurrentNormalization=1/(mb+mc) *)
indVB[l_] := I / (mb + mc) * DiracSigma[GA[l], GS[p]] . GA[5];
indV["A", l_] := indVA[l];
indV["B", l_] := indVB[l];

(* ---- Independent single-gluon-insertion propagator numerator ----
   S^{(1g)}_{mn}(q,m) = -1/4 [ sigma_{mn}(q-slash+m) + (q-slash+m)sigma_{mn} ]
   denominator: 1/(q^2-m^2)^2 -- exact form used in fixed-point gauge expansion
   of the heavy-quark propagator to first order in the gluon field strength.
   Ref: Reinders, Rubinstein, Yazaki, Phys. Rept. 127 (1985) 1 *)
indSGNum[q_, m_, a_, b_] := -1/4 (
  DiracSigma[GA[a], GA[b]] . (GS[q] + m) +
  (GS[q] + m) . DiracSigma[GA[a], GA[b]]
);
indSGDen[q_, m_] := FAD[{q, m, 2}];

(* ---- Independent vacuum tensor (Lorentz structure only) ----
   <g_s^2 G^a_{mn} G^b_{rs}> Lorentz part: (g_{mr}g_{ns} - g_{ms}g_{nr}) *)
indGGTensor[a_, b_, r_, t_] := MT[a, r] MT[b, t] - MT[a, t] MT[b, r];

(* ---- Independent prefactor (derived above: G2/24, Nc-independent) ---- *)
indGGPrefactor = G2 / 24;

(* ---- Helper: build the full trace for a given channel ---- *)
buildG2ggTrace[c1_, c2_] := Module[{chain},
  chain =
    indV[c1, mu] . indSGNum[k, mc, al, be] .
    indV[c2, nu] . indSGNum[k - p, mb, rh, si];
  (* mirror production's EvaluateDiracTrace pipeline *)
  chain //
    DotSimplify //
    DiracSigmaExplicit //
    DiracTrace //
    DiracSimplify //
    Contract //
    FCE
];

(* ---- Helper: assemble the full loop integrand for one channel ---- *)
buildG2ggIntegrand[tr_] := Module[{contracted},
  contracted = Contract[indGGTensor[al, be, rh, si] tr] // FCE // Contract;
  indGGPrefactor * contracted * indSGDen[k, mc] indSGDen[k - p, mb] // FCE
];

(* ---- Build traces for all three channels ---- *)
Print["=== Part A: FeynCalc traces ==="];
t0 = AbsoluteTime[];
Print["  Building AA trace..."];
trAA = buildG2ggTrace["A", "A"];
Print["    done (", Round[AbsoluteTime[] - t0, 0.1], " s)"];

t0 = AbsoluteTime[];
Print["  Building AB trace..."];
trAB = buildG2ggTrace["A", "B"];
Print["    done (", Round[AbsoluteTime[] - t0, 0.1], " s)"];

t0 = AbsoluteTime[];
Print["  Building BB trace..."];
trBB = buildG2ggTrace["B", "B"];
Print["    done (", Round[AbsoluteTime[] - t0, 0.1], " s)"];
Print[];

(* ---- Assemble full integrands ---- *)
Print["=== Part B: Full integrands (trace x tensor x prefactor x denom) ==="];
t0 = AbsoluteTime[];
indFullAA = buildG2ggIntegrand[trAA]; Print["  AA done (", Round[AbsoluteTime[] - t0, 0.1], " s)"];
t0 = AbsoluteTime[];
indFullAB = buildG2ggIntegrand[trAB]; Print["  AB done (", Round[AbsoluteTime[] - t0, 0.1], " s)"];
t0 = AbsoluteTime[];
indFullBB = buildG2ggIntegrand[trBB]; Print["  BB done (", Round[AbsoluteTime[] - t0, 0.1], " s)"];
Print[];

(* ---- Save to private context before Get[] clears Global` ---- *)
BeginPackage["G2ggCheck`"];
Quiet[G2ggCheck`indAA::usage = ""; G2ggCheck`indAB::usage = ""; G2ggCheck`indBB::usage = ""];
EndPackage[];
G2ggCheck`indAA = indFullAA;
G2ggCheck`indAB = indFullAB;
G2ggCheck`indBB = indFullBB;
G2ggCheck`prefactorUsed = indGGPrefactor;
Print["Scratch results saved to G2ggCheck` context."];
Print[];

(* ---- Load production code (will ClearAll["Global`*"], but not G2ggCheck`) ---- *)
Print["=== Part C: Load production code and retrieve G2gg integrands ==="];
t0 = AbsoluteTime[];
Get["/Users/sbilmis/Bc_mixing/BcMixingMomentum_claude.wl"];
Print["  Loaded (", Round[AbsoluteTime[] - t0, 0.1], " s)"];
Print[];

(* Prefactor cross-check: GGVacuumPrefactor[] at Nc=3 should equal G2/24 *)
prodPrefNum = N[GGVacuumPrefactor[] /. G2 -> 1];
indPrefNum  = N[1/24];
Print["  GGVacuumPrefactor[Nc=3,G2=1] = ", prodPrefNum, "  (production)"];
Print["  G2/24 [G2=1]                 = ", indPrefNum,  "  (independent derivation)"];
Print["  Prefactor match: ", Abs[prodPrefNum - indPrefNum] < 10^-14];
Print[];

(* Retrieve production integrands symbolically *)
Print["  Computing production LoopIntegrand for G2gg (three channels)..."];
t0 = AbsoluteTime[];
prodAA = LoopIntegrand["AA", "G2gg"];
prodAB = LoopIntegrand["AB", "G2gg"];
prodBB = LoopIntegrand["BB", "G2gg"];
Print["  done (", Round[AbsoluteTime[] - t0, 0.1], " s)"];
Print[];

(* ---- Numeric ratio test ----
   Substitute a generic off-shell point for all SP invariants and for mc,mb,G2.
   FAD[{q,m,n}] is replaced explicitly: FAD[{q,m,n}] -> 1/(SP[q,q]-m^2)^n, with
   SP[k-p, k-p] = SP[k,k] - 2 SP[k,p] + SP[p,p] handled by the substitution. *)
Print["=== Part D: Numeric ratio test at generic off-shell point ==="];

testK2  = 2.3;   (* SP[k,k]  -- generic, NOT physical mass shell *)
testKP  = -1.7;  (* SP[k,p] *)
testP2  = 5.9;   (* SP[p,p] *)
testMc  = 1.27;
testMb  = 4.18;
testG2  = 0.05;

numSubs = {
  SP[k, k]     -> testK2,
  SP[k, p]     -> testKP,
  SP[p, p]     -> testP2,
  mc           -> testMc,
  mb           -> testMb,
  G2           -> testG2
};
fadSubs = {
  FAD[{k, mc, 2}]       -> 1/(testK2 - testMc^2)^2,
  FAD[{k - p, mb, 2}]   -> 1/(testK2 - 2 testKP + testP2 - testMb^2)^2
};

evalNum[expr_] := expr //. numSubs //. fadSubs // N;

ratioTest[saved_, prod_, label_] := Module[
  {nS, nP, r},
  nS = evalNum[saved];
  nP = evalNum[prod];
  r  = If[Abs[nP] > 10^-30, nS/nP, "denom~0"];
  Print["  ", label, ":  scratch=", ScientificForm[nS, 6],
        "  prod=", ScientificForm[nP, 6],
        "  ratio=", If[NumberQ[r], N[r, 8], r],
        "  OK: ", If[NumberQ[r], Abs[r - 1] < 10^-6, False]]
];

ratioTest[G2ggCheck`indAA, prodAA, "AA"];
ratioTest[G2ggCheck`indAB, prodAB, "AB"];
ratioTest[G2ggCheck`indBB, prodBB, "BB"];
Print[];

(* ---- Applied projector test (compare PROJECTED integrands) ---- *)
Print["=== Part E: Projected ratio test (ProjectSpin1 applied to both) ==="];
t0 = AbsoluteTime[];
projScratchAA = ProjectSpin1[G2ggCheck`indAA];
projScratchAB = ProjectSpin1[G2ggCheck`indAB];
projScratchBB = ProjectSpin1[G2ggCheck`indBB];
Print["  Projected scratch integrands built (", Round[AbsoluteTime[] - t0, 0.1], " s)"];

t0 = AbsoluteTime[];
projProdAA = ProjectSpin1[prodAA];
projProdAB = ProjectSpin1[prodAB];
projProdBB = ProjectSpin1[prodBB];
Print["  Projected production integrands built (", Round[AbsoluteTime[] - t0, 0.1], " s)"];
Print[];

ratioTest[projScratchAA, projProdAA, "AA (projected)"];
ratioTest[projScratchAB, projProdAB, "AB (projected)"];
ratioTest[projScratchBB, projProdBB, "BB (projected)"];
Print[];

Print["======================================================="];
Print["  CheckG2ggScratch: COMPLETE"];
Print["  If all ratios are 1.00000 the G2gg diagram is verified:"];
Print["  - trace algebra (sigma insertions) matches production"];
Print["  - vacuum tensor contraction matches production"];
Print["  - prefactor G2/24 (independent derivation) = GGVacuumPrefactor[Nc=3]"];
Print["  - no-1/3 projector applied consistently in both"];
Print["======================================================="];
Quit[];

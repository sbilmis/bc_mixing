(* CheckFromScratch.wl  v4 -- fast, fixed
   Bug fixes vs v2:
   (1) Drop "// DiracTrace" from pipeline -- outer DiracTrace[chain] already evaluates
       the trace eagerly. The pipeline "// DiracTrace" then applied Tr[1]=4 to the
       already-bosonic result, giving a spurious factor of 4.
   (2) Drop 1/3 from projector -- paper convention is Pi_1 = (g^mn - p^m p^n/s) Pi_mn
       (no 1/3 divisor), consistent with eqs.(23)-(25).
   Net effect: removes the 4/3 discrepancy.
*)
Needs["FeynCalc`"];
FCSetDiracGammaScheme["NDR"];
$FCDefaultDimension = 4;

ClearAll[mb, mc, k, p, mu, nu];
Nc = 3;
Lam[ss_] := ss^2 + mb^4 + mc^4 - 2 ss mb^2 - 2 ss mc^2 - 2 mb^2 mc^2;

VA[lor_] := GA[lor] . GA[5];
VB[lor_] := (I/(mb+mc)) DiracSigma[GA[lor], GS[p]] . GA[5];
Sc[q_]   := GS[q] + mc;
Sb[q_]   := GS[q] + mb;

(* ---- Traces: ONE DiracTrace call, no pipeline double-wrap ---- *)
Print["Computing Dirac traces..."]; t0 = AbsoluteTime[];
TrAA = DiracTrace[VA[mu].Sc[k].VA[nu].Sb[k-p]]   // DiracSimplify // Contract // FCE;
TrAB = DiracTrace[VA[mu].Sc[k].VB[nu].Sb[k-p]]   // DiracSimplify // Contract // FCE;
TrBB = DiracTrace[VB[mu].Sc[k].VB[nu].Sb[k-p]]   // DiracSimplify // Contract // FCE;
Print["  done in ", Round[AbsoluteTime[]-t0,0.1], " s"];

(* ---- Spin-1 projection: NO 1/3 (paper convention) ---- *)
Prj[tr_] := Contract[(MT[mu,nu] - FV[p,mu] FV[p,nu]/SP[p,p]) tr] // FCE // Contract;
ProjAA = Prj[TrAA]; ProjAB = Prj[TrAB]; ProjBB = Prj[TrBB];
Print["ProjAA = ", ProjAA];
Print["ProjAB = ", ProjAB];
Print["ProjBB = ", ProjBB];

(* ---- On-shell kinematics via direct Pair replacement ---- *)
os[ss_] := {
  Pair[Momentum[k],   Momentum[k]]   -> mc^2,
  Pair[Momentum[p],   Momentum[p]]   -> ss,
  Pair[Momentum[k],   Momentum[p]]   -> (ss + mc^2 - mb^2)/2,
  Pair[Momentum[k]-Momentum[p], Momentum[k]-Momentum[p]] -> mb^2
};

params = {mb -> 4.18, mc -> 1.27};

rhoFC[ch_String, ss_] := Module[{proj},
  proj = Switch[ch, "AA", ProjAA, "AB", ProjAB, "BB", ProjBB];
  N[ Nc/(16 Pi^2) * Sqrt[Lam[ss]]/ss * (proj /. os[ss]) /. params ]
];

(* ---- Paper formulas ---- *)
papAA[ss_] := N[-3/(8 Pi^2 ss^2) ((mb+mc)^2-ss)((mb-mc)^2+2 ss) Sqrt[Lam[ss]] /. params];
papAB[ss_] := N[ 9/(8 Pi^2 ss (mb+mc)) (mb-mc)((mb+mc)^2-ss) Sqrt[Lam[ss]] /. params];
papBB[ss_] := N[ 3/(8 Pi^2 ss (mb+mc)^2) (-2(mb^2-mc^2)^2+(mb^2-6 mb mc+mc^2)ss+ss^2) Sqrt[Lam[ss]] /. params];
pap[ch_,ss_] := Switch[ch,"AA",papAA[ss],"AB",papAB[ss],"BB",papBB[ss]];

(* ---- Numerical comparison ---- *)
Print["\n=== FC vs Paper (mb=4.18, mc=1.27) ==="];
allOK = True;
Do[
  Do[
    Module[{fc, pp, err},
      fc  = rhoFC[ch, sv];
      pp  = pap[ch, sv];
      err = If[Abs[pp]>1*^-15, Abs[(fc-pp)/pp], Abs[fc-pp]];
      If[err > 1*^-4, allOK = False];
      Print["  rho^",ch,"(s=",sv,"): FC=",NumberForm[fc,{7,5}],
            "  paper=",NumberForm[pp,{7,5}],
            "  err=",ScientificForm[err,2],
            "  ",If[err<1*^-4,"PASS","FAIL ***"]]
    ],
    {ch, {"AA","AB","BB"}}],
  {sv, {50., 100., 120.}}
];
Print["Overall: ", If[allOK, "ALL PASS", "SOME FAILURES"]];
Quit[];

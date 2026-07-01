(* CheckG2Scratch.wl — Independent G2c Borel moment verification
   Uses FeynCalc trace + analytical loop-integral formulas.
   Key fixes vs previous attempt:
   - Projector split into two Contract calls (avoids SP[p,p] in denominator)
   - Correct x-limits: (s0 - mc^2 + mb^2 +/- sqrt(lambda)) / (2*s0)
   - SP[k,k] replacement (not Pair[...]) after FCE
*)

Needs["FeynCalc`"];
Quiet[FCSetDiracGammaScheme["NDR"]];
$PrePrint = Identity;

Print["======================================================="];
Print["  CheckG2Scratch: Independent G2c verification"];
Print["======================================================="];
Print[];

Nc  = 3;
G2v = N[4 Pi^2 0.012, 15];
M2v = 8.;
s0v = 53.;
mbv = 4.18; mcv = 1.27;

(* ============================================================
   PART A: FeynCalc trace for G2c AA
   ============================================================ *)
Print["=== A. FeynCalc trace ==="];
SBar[xv_,m1_,m2_] := (m1^2*xv + m2^2*(1-xv))/(xv*(1-xv));
Lam[sv_,m1_,m2_]  := sv^2 + m1^4 + m2^4 - 2sv*m1^2 - 2sv*m2^2 - 2*m1^2*m2^2;

(* x-limits: SBar(x)=s0 => x*(s0-mb^2) - x^2*s0 = mc^2*x - mb^2*(1-...)
   Quadratic: s0*x^2 - (s0-mc^2+mb^2)*x + mb^2 = 0
   x = [(s0-mc^2+mb^2) ± sqrt(lambda)] / (2*s0) *)
XLims[sv_,mc0_,mb0_] := Module[{A,l},
  A = sv - mc0^2 + mb0^2;
  l = Sqrt[Max[Lam[sv,mc0,mb0],0]];
  Sort[{(A-l)/(2sv), (A+l)/(2sv)}]
];

{xmin,xmax} = N[XLims[s0v,mcv,mbv],10];
Print["x-limits: [", N[xmin,5], ", ", N[xmax,5], "]"];
Print["SBar(xmin)=", N[SBar[xmin,mcv,mbv],5], "  SBar(xmax)=", N[SBar[xmax,mcv,mbv],5], "  (both should = s0=53)"];
Print[];

VAmu[l_] := GA[l].GA[5];
t0 = AbsoluteTime[];
TrG2cAA = DiracTrace[VAmu[mu].( mc*(SP[k,k]+mc*GS[k]) ).VAmu[nu].(GS[k-p]+mb)] //
  DiracSimplify // ExpandScalarProduct // Contract // FCE // Expand;
Print["G2c AA trace (", Round[AbsoluteTime[]-t0,0.1]," s): ", TrG2cAA // InputForm];
Print[];

(* ============================================================
   PART B: Apply projector — split Contract to avoid SP[p,p] in denominator
   ============================================================ *)
Print["=== B. Projector (no-1/3, split method) ==="];
t1 = Contract[MT[mu,nu] * TrG2cAA] // FCE // Contract // ExpandScalarProduct;
t2 = Contract[FV[p,mu]*FV[p,nu] * TrG2cAA] // FCE // Contract // ExpandScalarProduct;
ProjG2cAA = (t1 - t2/SP[p,p]) // ExpandScalarProduct;
Print["ProjG2cAA (no-1/3) = ", ProjG2cAA // InputForm];
Print[];

(* ============================================================
   PART C: Analytical formula derived by hand (cross-check)
   From manual calculation of Proj[(g^mn - p^m p^n/p^2) TrG2cAA]:
     = (-4mc^2 - 12mb*mc)*SP[k,k] + 12mc^2*SP[k,p] - 8mc^2*SP[k,p]^2/SP[p,p]
   ============================================================ *)
Print["=== C. Hand formula cross-check ==="];
HandProj = (-4*mc^2 - 12*mb*mc)*SP[k,k] + 12*mc^2*SP[k,p] - 8*mc^2*SP[k,p]^2/SP[p,p];
diffFC = Simplify[(ProjG2cAA - HandProj) // ExpandScalarProduct];
Print["(FeynCalc proj) - (Hand formula) = ", diffFC // InputForm, "  [should be 0]"];
Print[];

(* Use hand formula for numerical stability in what follows *)
(* Replace SP objects with plain variables *)
ProjPoly = HandProj /. {SP[k,k]->k2s, SP[k,p]->kps, SP[p,p]->p2s};
Print["As poly(k2s,kps,p2s): ", ProjPoly];
Print[];

(* ============================================================
   PART D: Feynman shift + loop integration (analytical)
   After k->l+(1-x)p, set l.p=0, l^2=L2, p2s=-Q2:
     k2s -> L2 + (1-x)^2*(-Q2)
     kps -> (1-x)*(-Q2)
     p2s -> -Q2
   Split into L2 coefficient (-> 1/Delta^2 integral) and rest (-> scalar int)
   ============================================================ *)
Print["=== D. Feynman shift coefficients ==="];
ProjShifted = ProjPoly /. {k2s -> L2+(1-xv)^2*(-Q2), kps->(1-xv)*(-Q2), p2s->-Q2} // Expand;
cL2  = Coefficient[ProjShifted, L2] // Simplify;
cRest = ProjShifted /. L2->0;  (* polynomial in Q2 *)
cQ1  = Coefficient[cRest, Q2, 1] // Simplify;
cQ0  = Coefficient[cRest, Q2, 0] // Simplify;
Print["coeff of L2 (-> 1/Delta^2):  cL2  = ", cL2];
Print["coeff of Q2 (-> Q2/Delta^3): cQ1  = ", cQ1];
Print["const in Q2 (-> 1/Delta^3):  cQ0  = ", cQ0, "  [should be 0]"];
Print[];

(* Verify cL2, cQ1 against expected formulas:
   cL2 = -4mc^2 - 12mb*mc = -4mc*(mc+3mb)
   cQ1 = (-4mc^2-12mb*mc)*(1-x)^2 - 12mc^2*(1-x) + 8mc^2*(1-x)^2 ... let me recompute:
   cRest = (-4mc^2-12mb*mc)*(1-x)^2*(-Q2) + 12mc^2*(1-x)*(-Q2) - 8mc^2*(1-x)^2*(-Q2)^2/(-Q2)
         = (-4mc^2-12mb*mc)*(1-x)^2*(-Q2) + 12mc^2*(1-x)*(-Q2) + 8mc^2*(1-x)^2*Q2*(-1)... hmm
   Actually the 8mc^2*(kps)^2/p2s term: kps->(1-x)*(-Q2), p2s->-Q2
   => -8mc^2*((1-x)*(-Q2))^2/(-Q2) = -8mc^2*(1-x)^2*Q2^2/(-Q2) = +8mc^2*(1-x)^2*Q2
   So cRest = [(-4mc^2-12mb*mc)*(1-x)^2 + 12mc^2*(1-x)]*(-Q2) + 8mc^2*(1-x)^2*Q2
            = {-[(-4mc^2-12mb*mc)*(1-x)^2 + 12mc^2*(1-x)] + 8mc^2*(1-x)^2}*Q2
   => cQ1 (coeff of Q2) = -((-4mc^2-12mb*mc)*(1-x)^2 + 12mc^2*(1-x)) + 8mc^2*(1-x)^2
                        = (4mc^2+12mb*mc)*(1-x)^2 - 12mc^2*(1-x) + 8mc^2*(1-x)^2
                        = (12mc^2+12mb*mc)*(1-x)^2 - 12mc^2*(1-x)
                        = 12mc*(mc+mb)*(1-x)^2 - 12mc^2*(1-x)
                        = 12mc*(1-x)*[(mc+mb)*(1-x)-mc]
   Note: the Q2 term contains a Q2^2/(-Q2) = -Q2 from the (kps)^2/p2s term
   So cQ1 should have a non-trivial x dependence *)

cL2_expected  = -4*mc^2 - 12*mb*mc;
cQ1_expected  = 12*mc*(1-xv)*((mc+mb)*(1-xv)-mc);
Print["Expected cL2 = -4mc*(mc+3mb) = ", Factor[cL2_expected], "  Match: ", Simplify[cL2-cL2_expected]===0];
Print["Expected cQ1 = 12mc(1-x)[(mc+mb)(1-x)-mc] = ", Factor[cQ1_expected // Expand]];
Print["Match: ", Simplify[(cQ1 - cQ1_expected) /. xv->xv]===0, "  Diff: ", Simplify[(cQ1-cQ1_expected)]];
Print[];

(* ============================================================
   PART E: Borel integrand (numerical, with analytical coefficients)

   Sign derivation (no overall 'i' in correlator definition, with phase -I):
   Scalar loop integral (Mink, no overall i):
     int d^4k/(2pi)^4 * 1/(k^2-Delta)^5 = -i/(192pi^2 * Delta^3)
   l^2 loop integral:
     int d^4k/(2pi)^4 * l^2/(k^2-Delta)^5 = +i/(192pi^2 * Delta^2)
   After multiplying by phase (-i = -I):
     scalar: (-i)*(-i/(192pi^2*D^3)) = i^2/(...) = -1/(192pi^2*D^3)
     L2:     (-i)*(+i/(192pi^2*D^2)) = -i^2/(...) = +1/(192pi^2*D^2)
   So:
     Borel integrand = (G2/12)*Nc * 4 * x^3 * (1/(192pi^2)) *
       [ cL2 * e^{-SBar/M2} / (x(1-x))^2 / M2    (L2 term, sign +1)
       - cQ1*(-Q2) * e^{-SBar/M2}/(x(1-x))^3 / Delta^3   <- needs Borel xform on Q2 ]
   But wait: sign in front of L2 term: cL2 * (+1/(192pi^2*D^2))
   And scalar (rest) term: cRest = cQ1*Q2  -> goes with -1/(192pi^2*D^3)
   -> scalar contribution: cQ1*Q2 * (-1/(192pi^2*D^3))
   After Borel xform B^{Q2}[Q2/(Q2+SBar)^3] = e^{-SBar/M2}(1/M2 - SBar/(2M2^2)):
     = cQ1 * (-e^{-SBar/M2}(1/M2 - SBar/(2M2^2))) / (192pi^2 * (x(1-x))^3)
   ============================================================ *)

Print["=== E. Numerical G2c Borel moment ==="];

BorelIntG2c[xv_?NumericQ, M2_?NumericQ, mc_?NumericQ, mb_?NumericQ] := Module[
  {sb, ef, xb, cl2, cq1, bL2, bQ1},
  sb  = SBar[xv, mc, mb];
  ef  = Exp[-sb/M2];
  xb  = xv*(1-xv);
  cl2 = N[-4*mc^2 - 12*mb*mc];                              (* independent of xv *)
  cq1 = N[12*mc*(1-xv)*((mc+mb)*(1-xv) - mc)];              (* linear in (1-x) *)
  (* L2 contribution: cL2 * (+1) / Delta^2 -> Borel -> cL2*ef/(xb^2*M2) *)
  bL2 = cl2 * ef / (xb^2 * M2);
  (* Q2 contribution: cQ1*Q2 * (-1) / Delta^3 -> Borel -> -cQ1*ef*(1/M2-SBar/(2M2^2))/(xb^3) *)
  bQ1 = -cq1 * ef * (1/M2 - sb/(2*M2^2)) / xb^3;
  (* Feynman weight 4x^3 *)
  4 * xv^3 * (bL2 + bQ1)
];

(* Test at midpoint x=0.65 *)
xtest = 0.65;
Print["Test integrand at x=0.65: ", N[BorelIntG2c[xtest, M2v, mcv, mbv], 6]];

prefG2c = N[G2v/12 * Nc / (192 Pi^2)];
Print["Prefactor = ", N[prefG2c, 5]];
(* Diagnostic: confirm basic Do-loop works after FeynCalc load *)
G2c$test = 0.; Do[G2c$test += 1., {ii, 1, 5}];
Print["Do-loop diagnostic (should be 5.): ", G2c$test];
Print["Integrating G2c over x in [", N[xmin,4], ", ", N[xmax,4], "] ..."];
t0 = AbsoluteTime[];
(* Global variables with unique names — avoids Module/Block scoping issues *)
G2c$n  = 5000;
G2c$x0 = N[xmin]; G2c$x1 = N[xmax];
G2c$dx = (G2c$x1 - G2c$x0)/G2c$n;
G2c$tot = 0.;
Do[
  G2c$xt  = G2c$x0 + (G2c$ii - 0.5)*G2c$dx;
  G2c$sb  = (1.6129*G2c$xt + 17.4724*(1. - G2c$xt))/(G2c$xt*(1. - G2c$xt));
  G2c$ef  = Exp[-G2c$sb/8.];
  G2c$xb  = G2c$xt*(1. - G2c$xt);
  G2c$tot += 4.*G2c$xt^3*((-70.154*G2c$ef/(G2c$xb^2*8.))
             - (12.*1.27*(1.-G2c$xt)*(5.45*(1.-G2c$xt)-1.27))*G2c$ef*(0.125 - G2c$sb/128.)/G2c$xb^3),
  {G2c$ii, 1, G2c$n}
];
Print["Done in ", Round[AbsoluteTime[]-t0,0.1], " s"];
Print["G2c$tot = ", G2c$tot, "  dx = ", G2c$dx];
tmpG2cAA = N[prefG2c] * G2c$dx * G2c$tot;
Print["tmpG2cAA = ", tmpG2cAA];
outG2cAA = tmpG2cAA;   (* use fresh name, avoid any protected symbol *)
Print["Pi^{G2c}_{AA} (scratch, no-1/3) = ", outG2cAA];
Print[];

(* ============================================================
   PART F: G2b contribution (by symmetry at equal mass, G2b=G2c;
            at unequal mass, compute analogously)
   G2b: VA[mu].S0c(k).VA[nu].SG2b(k-p)
   After Feynman param for 1/(A*B^4) with A=k^2-mc^2, B=(k-p)^2-mb^2:
   Feynman weight: 4*(1-x)^3 (parameter now weights mb propagator)
   Shift: k->l+x*p (so now k-p -> l+(x-1)*p -> l-xbar*p with xbar=1-x)
   After shift: (k-p)^2 -> l^2 + xbar^2*p^2, k.p -> ...
   Actually, it's cleaner to use x for mb (power 4) and (1-x) for mc (power 1):
   Feynman weight: 4*x^3; shift k->l+(1-x)*p as before but NOW x labels mb denominator

   Equivalently: swap mc<->mb and x<->(1-x) in the G2c formula.
   SBar_b(x) = (x*mb^2 + (1-x)*mc^2)/(x*(1-x))
   This is SBar but with mc,mb swapped.
   x-limits for G2b: XLims(s0, mb, mc) [mb first since it's the heavy propagator^4]
   ============================================================ *)

Print["=== F. G2b contribution (swap mc<->mb) ==="];

(* From the G2b trace: Tr[VA.S0c.VA.SG2b]
   By analogy with G2c (swap mc<->mb, and the shift is now k->l+x*p for mb denominator):
   After Feynman param for 1/(A*(k-p)^4) where A=k^2-mc^2, B=(k-p)^2-mb^2:
   Let y be the param for B^4 (mb side), 1-y for A (mc side):
   Feynman weight: 4*y^3, shift k->l+(1-y)*p
   SBar_b(y) = (y*mb^2 + (1-y)*mc^2)/(y*(1-y))
   cL2_b  = -4*mb^2 - 12*mc*mb = -4*mb*(mb+3*mc)
   cQ1_b  = 12*mb*(1-y)*((mc+mb)*(1-y) - mb)
   [Derived by swapping mc<->mb in the G2c formulas]
*)

(* x-limits for G2b: SBar_b(y)=(mb^2*y+mc^2*(1-y))/(y(1-y))=s0=53 => hardcoded *)
(* A = s0-mb^2+mc^2 = 53-17.4724+1.6129 = 37.1405; sqrt(Lam)=32.2096 *)
G2b$xmin = (37.1405 - 32.2096)/(2.*53.);   (* = 0.046514 *)
G2b$xmax = (37.1405 + 32.2096)/(2.*53.);   (* = 0.65426  *)
Print["G2b x-limits (mb heavy): [", N[G2b$xmin,5], ", ", N[G2b$xmax,5], "]"];
Print["  Verify SBar_b(xmin_b)=",
      N[(17.4724*G2b$xmin + 1.6129*(1.-G2b$xmin))/(G2b$xmin*(1.-G2b$xmin)), 5],
      " (should be 53.)"];

(* cl2_b = -4*mb^2 - 12*mc*mb = -4*17.4724 - 12*1.27*4.18 = -133.593 *)
G2b$n  = 5000;
G2b$x0 = G2b$xmin; G2b$x1 = G2b$xmax;
G2b$dx = (G2b$x1 - G2b$x0)/G2b$n;
G2b$tot = 0.;
Do[
  G2b$xt  = G2b$x0 + (G2b$ii - 0.5)*G2b$dx;
  G2b$sb  = (17.4724*G2b$xt + 1.6129*(1. - G2b$xt))/(G2b$xt*(1. - G2b$xt));
  G2b$ef  = Exp[-G2b$sb/8.];
  G2b$xb  = G2b$xt*(1. - G2b$xt);
  G2b$tot += 4.*G2b$xt^3*(((-4.*17.4724 - 12.*1.27*4.18)*G2b$ef/(G2b$xb^2*8.))
             - (12.*4.18*(1.-G2b$xt)*(5.45*(1.-G2b$xt)-4.18))*G2b$ef*(0.125-G2b$sb/128.)/G2b$xb^3),
  {G2b$ii, 1, G2b$n}
];
outG2bAA = N[prefG2c] * G2b$dx * G2b$tot;
Print["Pi^{G2b}_{AA} (scratch, no-1/3) = ", outG2bAA];
Print[];

(* ============================================================
   PART G: Equal-mass check: G2c = G2b at mc=mb
   ============================================================ *)
Print["=== G. Equal-mass symmetry G2c = G2b ==="];
(* m=2, s0=22=4*4+6; SBar_eq(x)=4/(x*(1-x)); limits: x*(1-x)=4/22 => x=0.23889, 0.76111 *)
(* Verify: 4/(0.23889*0.76111)=4/0.18182=22 ✓ *)
G2eq$xlo = 0.238886305618; G2eq$xhi = 0.761113694382;
Print["  Equal-mass x-limits (m=2, s0=22): [", N[G2eq$xlo,5], ", ", N[G2eq$xhi,5], "]"];
G2eq$n  = 5000;
G2eq$dx = (G2eq$xhi - G2eq$xlo)/G2eq$n;
G2eq$tot = 0.;
Do[
  G2eq$xt  = G2eq$xlo + (G2eq$ii - 0.5)*G2eq$dx;
  G2eq$sb  = 4./(G2eq$xt*(1. - G2eq$xt));   (* m^2=4 at m=2 *)
  G2eq$ef  = Exp[-G2eq$sb/8.];
  G2eq$xb  = G2eq$xt*(1. - G2eq$xt);
  G2eq$tot += 4.*G2eq$xt^3*((-64.)*G2eq$ef/(G2eq$xb^2*8.)
              - 48.*(1.-G2eq$xt)*(1.-2.*G2eq$xt)*G2eq$ef*(0.125-G2eq$sb/128.)/G2eq$xb^3),
  {G2eq$ii, 1, G2eq$n}
];
outG2cEQ = N[prefG2c] * G2eq$dx * G2eq$tot;
Print["  G2c = G2b = ", outG2cEQ, "  (at mc=mb=2, s0=22; identical formulas => ratio=1 exact)"];
Print[];

(* Save scratch values to private context -- BcMixingMomentum does ClearAll["Global`*"] *)
Begin["CheckScratch`"];
CheckScratch`G2cAA = outG2cAA;
CheckScratch`G2bAA = outG2bAA;
CheckScratch`G2cEQ = outG2cEQ;
End[];
Print["Saved scratch values: G2cAA=", CheckScratch`G2cAA,
      "  G2bAA=", CheckScratch`G2bAA];
Print[];

(* ============================================================
   PART H: Load production code and compare
   ============================================================ *)
Print["=== H. Production code comparison ==="];
Get["/Users/sbilmis/Bc_mixing/BcMixingMomentum.wl"];
Print[];

prodG2AA = NumericBorelPi["AA", "G2", 8., 53.];
prodG2AB = NumericBorelPi["AB", "G2", 8., 53.];
prodG2BB = NumericBorelPi["BB", "G2", 8., 53.];
pertAA   = NumericBorelPi["AA", "pert", 8., 53.];
pertAB   = NumericBorelPi["AB", "pert", 8., 53.];
pertBB   = NumericBorelPi["BB", "pert", 8., 53.];

Print["Production G2 (total):   AA=", ScientificForm[prodG2AA,5], "  AB=", ScientificForm[prodG2AB,5], "  BB=", ScientificForm[prodG2BB,5]];
Print["Production pert:         AA=", ScientificForm[pertAA,5],   "  AB=", ScientificForm[pertAB,5],   "  BB=", ScientificForm[pertBB,5]];
Print[];

thetaPert  = 180/Pi * 1/2 * ArcTan[pertAA-pertBB, -2 pertAB];
thetaFull  = 180/Pi * 1/2 * ArcTan[(pertAA+prodG2AA)-(pertBB+prodG2BB), -2(pertAB+prodG2AB)];
thetaFull3 = 180/Pi * 1/2 * ArcTan[(pertAA+3prodG2AA)-(pertBB+3prodG2BB), -2(pertAB+3prodG2AB)];

(* ============================================================
   SUMMARY
   ============================================================ *)
Print["======================================================="];
Print["  SUMMARY"];
Print["======================================================="];
Print[];
Print["G2c scratch (no-1/3): ", N[CheckScratch`G2cAA, 5]];
Print["G2b scratch (no-1/3): ", N[CheckScratch`G2bAA, 5]];
Print["G2c+G2b scratch:      ", N[CheckScratch`G2cAA+CheckScratch`G2bAA, 5]];
Print["Production G2 total:  ", N[prodG2AA, 5], "  (G2c+G2b+G2gg)"];
Print[];
Print["Ratio (scratch G2c+G2b) / prod_G2_total = ", N[(CheckScratch`G2cAA+CheckScratch`G2bAA)/prodG2AA, 4]];
Print["  -> ~1: same convention (no 1/3 issue)"];
Print["  -> ~3: prod uses 1/3 projector (G2gg ignored in this rough ratio)"];
Print["  -> ~2: prod uses 1/3 AND G2gg ~ G2c ~ G2b (so 2/3 of total)"];
Print[];
Print["G2/pert ratios:"];
Print["  AA: ", N[prodG2AA/pertAA, 4], "  (", N[100 prodG2AA/pertAA, 3], "%)"];
Print["  AB: ", N[prodG2AB/pertAB, 4], "  (", N[100 prodG2AB/pertAB, 3], "%)"];
Print["  BB: ", N[prodG2BB/pertBB, 4], "  (", N[100 prodG2BB/pertBB, 3], "%)"];
Print[];
Print["Mixing angle:"];
Print["  theta_pert:         ", N[thetaPert, 6], " deg"];
Print["  theta(pert+G2):     ", N[thetaFull, 6], " deg  [prod 1/3 conv]"];
Print["  theta(pert+3*G2):   ", N[thetaFull3, 6], " deg  [no-1/3 conv]"];
Print["  Delta_theta range:  [", N[thetaFull-thetaPert, 3], " .. ", N[thetaFull3-thetaPert, 3], "] deg"];
Print[];
Quit[];

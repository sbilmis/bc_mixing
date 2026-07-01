(* ComputeAngles.wl — compute mixing angles from the RunFixed.wl output values *)

(* Perturbative *)
aaP8  =  0.04571010554889539;
abP8  = -0.033231831182789155;
bbP8  =  0.04145796654574899;
aaP10 =  0.14417168258604204;
abP10 = -0.10515771924189928;
bbP10 =  0.13481345134770945;

(* G2 fixed (no 1/3) *)
g2AA8  = -0.000575953150957735;
g2AB8  =  0.0003779706194065955;
g2BB8  = -0.0003285190726971222;

(* G3 fixed (no 1/3) *)
g3AA8  =  0.00013130960655404717;
g3AB8  = -0.00010178263349496048;
g3BB8  =  0.00006813094899303654;

ang[aa_, ab_, bb_] := 180/Pi * 1/2 * ArcTan[aa-bb, -2 ab];

thetaP8  = ang[aaP8, abP8, bbP8];
thetaP10 = ang[aaP10, abP10, bbP10];

thetaG2v8   = ang[aaP8+g2AA8, abP8+g2AB8, bbP8+g2BB8];
thetaTot8   = ang[aaP8+g2AA8+g3AA8, abP8+g2AB8+g3AB8, bbP8+g2BB8+g3BB8];

Print["=== CORRECTED RESULTS (projector fixed: no 1/3) ==="];
Print[];
Print["M2=8, s0=53:"];
Print["  theta(pert)       = ", N[thetaP8, 7], " deg"];
Print["  theta(pert+G2)    = ", N[thetaG2v8, 7], " deg   Delta=", N[thetaG2v8-thetaP8, 4], " deg"];
Print["  theta(pert+G2+G3) = ", N[thetaTot8, 7], " deg   Delta=", N[thetaTot8-thetaP8, 4], " deg"];
Print[];
Print["G2 values (fixed, 3x old):"];
Print["  Pi^AA_G2 = ", ScientificForm[g2AA8, 5], "   ratio/pert = ", N[g2AA8/aaP8*100, 3], " %"];
Print["  Pi^AB_G2 = ", ScientificForm[g2AB8, 5], "   ratio/pert = ", N[g2AB8/abP8*100, 3], " %"];
Print["  Pi^BB_G2 = ", ScientificForm[g2BB8, 5], "   ratio/pert = ", N[g2BB8/bbP8*100, 3], " %"];
Print[];
Print["G3 values (fixed):"];
Print["  Pi^AA_G3 = ", ScientificForm[g3AA8, 5], "   ratio/pert = ", N[g3AA8/aaP8*100, 3], " %"];
Print["  Pi^AB_G3 = ", ScientificForm[g3AB8, 5], "   ratio/pert = ", N[g3AB8/abP8*100, 3], " %"];
Print["  Pi^BB_G3 = ", ScientificForm[g3BB8, 5], "   ratio/pert = ", N[g3BB8/bbP8*100, 3], " %"];
Print[];
Print["OPE check (G2+G3 vs pert):"];
Print["  |G2|/pert AA = ", N[Abs[g2AA8]/Abs[aaP8]*100, 3], " %"];
Print["  |G3|/pert AA = ", N[Abs[g3AA8]/Abs[aaP8]*100, 3], " %"];
Print["  |G3|/|G2|  AA = ", N[Abs[g3AA8]/Abs[g2AA8]*100, 3], " %  (convergence check)"];
Quit[];

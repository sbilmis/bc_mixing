(* ::Package:: *)

(*  BcMixingAlphaSMixedAB.wl

    Workbench for the mixed axial-vector/tensor channel Pi^AB at
    O(alpha_s).  This file is intentionally separate from the validated AA
    workbench and from the tensor-paper BB import layer.

    First milestone:
      reproduce the existing LO rho_0^AB from an explicit two-body cut trace.

    Next milestones:
      build the gamma_5-free D-dimensional virtual integrand and the
      real-emission trace for J_A x J_B.
*)

If[! TrueQ[ValueQ[$BcAlphaSChannels]],
  Get[FileNameJoin[{Directory[], "BcMixingAlphaS.wl"}]]
];

ClearAll[
  IndependentABTensorVertex,
  IndependentABLORawTrace,
  IndependentABLOGamma5FreeRawTrace,
  IndependentABLOGamma5EliminationCheck,
  IndependentABLOProjectedTrace,
  IndependentABLOSpectralDensity,
  IndependentABLODerivationCheck,
  IndependentABLOGamma5FreeProjectedTraceD,
  IndependentABLODimensionalNormalizationSeries,
  IndependentABVirtualVertexIntegrandGamma5Free,
  IndependentABVirtualProjectedIntegrandGamma5Free,
  IndependentABVirtualScalarReductionGamma5Free,
  IndependentABVirtualReductionDiagnosticGamma5Free,
  IndependentABRealEmissionAChain,
  IndependentABRealEmissionBConjugateChain,
  IndependentABRealEmissionProjectedTrace,
  IndependentABRealEmissionTraceFormula,
  IndependentABRealEmissionTraceCheck,
  IndependentABStatus
];

(* The B current used in the sum rule is

     J_B^nu = i sigma^{nu alpha} p_alpha gamma_5 /(mb+mc).

   BcMixingMomentum.wl keeps the optional raw i by default.  Since
   FeynCalc's DiracSigma already contains i/2 [gamma, gamma], the effective
   vertex is real:

     i DiracSigma[gamma_lor, pslash] = -1/2 (gamma_lor pslash - pslash gamma_lor).

   We write this commutator explicitly to avoid irregular DiracTrace
   structures from nested DiracSigma objects. *)
IndependentABTensorVertex[lor_, mom_: pAA] :=
  -1/2 TensorCurrentNormalization[] * (GA[lor] . GS[mom] - GS[mom] . GA[lor]) . GA[5];

IndependentABTensorVertexD[lor_, mom_: pAA] :=
  -1/2 TensorCurrentNormalization[] * (
    FeynCalc`GAD[lor] . FeynCalc`GSD[mom] -
    FeynCalc`GSD[mom] . FeynCalc`GAD[lor]
  );

(* Two-body cut for J_A at the first vertex and J_B at the second vertex. *)
IndependentABLORawTrace[] :=
  DiracTrace[
    DiracSigmaExplicit[
      (GS[pcAA] + mc) . GA[muAA] . GA[5] .
      (GS[pbAA] - mb) . IndependentABTensorVertex[nuAA, pAA]
    ]
  ] // DiracSimplify // Contract // FCE // Simplify;

(* Move the final gamma_5 to the front cyclically and combine it with the
   axial gamma_5.  Since gamma_5 commutes with sigma^{nu alpha}, the mixed
   trace becomes gamma_5-free:

     Tr[(pc+mc) gamma_mu gamma_5 (pb-mb) sigma_{nu p} gamma_5]
       = Tr[(pc-mc) gamma_mu (pb-mb) sigma_{nu p}].
*)
IndependentABLOGamma5FreeRawTrace[] :=
  DiracTrace[
    DiracSigmaExplicit[
      (GS[pcAA] - mc) . GA[muAA] .
      (GS[pbAA] - mb) . (
      -1/2 TensorCurrentNormalization[] * (
        GA[nuAA] . GS[pAA] - GS[pAA] . GA[nuAA]
      )
      )
    ]
  ] // DiracSimplify // Contract // FCE // Simplify;

IndependentABLOGamma5EliminationCheck[] := FullSimplify[
  IndependentABLOGamma5FreeRawTrace[] - IndependentABLORawTrace[]
];

IndependentABLOProjectedTrace[ss_: s] := Module[
  {expr},
  expr = IndependentAASpin1Projector[pAA, muAA, nuAA] IndependentABLORawTrace[];
  expr = Contract[expr] // FCE // DiracSimplify // Contract;
  expr /. IndependentAA2BodyOnShellRules[ss] // Simplify
];

IndependentABLOSpectralDensity[ss_: s] := Module[
  {lam = KallenLambda[ss, mb, mc], trace},
  trace = IndependentABLOProjectedTrace[ss];
  $BcMixingNc/(16 Pi^2) Sqrt[lam]/ss
    IndependentAACutToInvariantFactor[] trace // Simplify
];

IndependentABLODerivationCheck[ss_: s] := Module[
  {ind = IndependentABLOSpectralDensity[ss],
   builtin = AlphaSLOSpectralDensity["AB", ss]},
  <|
    "RawTrace" -> IndependentABLORawTrace[],
    "Gamma5FreeRawTrace" -> IndependentABLOGamma5FreeRawTrace[],
    "Gamma5EliminationDifference" -> IndependentABLOGamma5EliminationCheck[],
    "ProjectedTrace" -> IndependentABLOProjectedTrace[ss],
    "IndependentRho0AB" -> ind,
    "MomentumFileRho0AB" -> builtin,
    "Difference" -> FullSimplify[
      ind - builtin,
      ss > (mb + mc)^2 && mb > 0 && mc > 0
    ],
    "Ratio" -> FullSimplify[
      ind/builtin,
      ss > (mb + mc)^2 && mb > 0 && mc > 0
    ]
  |>
];

IndependentABLOGamma5FreeProjectedTraceD[ss_: s] := Module[
  {expr},
  expr = IndependentAASpin1ProjectorD[pAA, muAA, nuAA] *
    FeynCalc`DiracTrace[
      (FeynCalc`GSD[pcAA] - mc) . FeynCalc`GAD[muAA] .
      (FeynCalc`GSD[pbAA] - mb) . (
      -1/2 TensorCurrentNormalization[] * (
        FeynCalc`GAD[nuAA] . FeynCalc`GSD[pAA] -
        FeynCalc`GSD[pAA] . FeynCalc`GAD[nuAA]
      )
      )
    ];
  expr = FeynCalc`DiracSigmaExplicit[expr] //
    FeynCalc`DiracSimplify // FeynCalc`Contract // Simplify;
  expr /. IndependentAADimensionalOnShellRules[ss] //
    FeynCalc`Contract // FeynCalc`FCE // Simplify
];

IndependentABLODimensionalNormalizationSeries[ss_: s] := Module[
  {epsilon = Unique["epsilon"], ratio},
  ratio = IndependentABLOGamma5FreeProjectedTraceD[ss]/
    IndependentABLOProjectedTrace[ss];
  FullSimplify[
    Normal@Series[ratio /. D -> 4 - 2 epsilon, {epsilon, 0, 1}],
    ss > (mb + mc)^2 && mb > 0 && mc > 0
  ]
];

(* Gamma_5-free virtual vertex with the same physical routing convention used
   in the AA workbench.  This is an unrenormalized virtual integrand; it still
   needs tensor reduction, Package-X evaluation, counterterms, and real
   emission before it becomes rho_1^AB. *)
IndependentABVirtualVertexIntegrandGamma5Free[ell_: l, ss_: s] := Module[
  {den, firstBlock, secondBlock},
  den = FAD[{ell, 0}, {ell + pcAA, mc}, {ell + pbAA, mb}];
  firstBlock =
    (-FeynCalc`GSD[pcAA] + mc) .
    (-FeynCalc`GAD[alphaAA]) .
    (-FeynCalc`GSD[ell] - FeynCalc`GSD[pcAA] + mc) .
    (-FeynCalc`GAD[muAA]);
  secondBlock =
    (-FeynCalc`GSD[ell] - FeynCalc`GSD[pbAA] + mb) .
    FeynCalc`GAD[alphaAA] .
    (FeynCalc`GSD[pbAA] - mb) .
    (
    -1/2 TensorCurrentNormalization[] * (
      FeynCalc`GAD[nuAA] . FeynCalc`GSD[pAA] -
      FeynCalc`GSD[pAA] . FeynCalc`GAD[nuAA]
    )
    );
  <|
    "Integrand" -> -den FeynCalc`DiracTrace[firstBlock . secondBlock],
    "Projection" -> IndependentAASpin1ProjectorD[pAA, muAA, nuAA],
    "TwoBodyOnShellRules" -> IndependentAA2BodyOnShellRules[ss],
    "Status" ->
      "unrenormalized gamma5-free virtual AB integrand; reduce before use"
  |>
];

IndependentABVirtualProjectedIntegrandGamma5Free[
  ell_: l,
  ss_: s
] := Module[
  {data, expr},
  data = IndependentABVirtualVertexIntegrandGamma5Free[ell, ss];
  expr = $BcMixingNc IndependentAAColorFactor[] data["Projection"] data["Integrand"];
  expr = FeynCalc`DiracSigmaExplicit[expr] //
    FeynCalc`DiracSimplify // FeynCalc`Contract // FeynCalc`FCE // Simplify;
  expr /. data["TwoBodyOnShellRules"] // FeynCalc`Contract // FeynCalc`FCE // Simplify
];

IndependentABVirtualScalarReductionGamma5Free[
  ss_: s,
  ell_: l,
  usePaVeBasis_: True,
  loopDimension_: D,
  preReductionRules_: {}
] := Module[
  {expr, reduced},
  expr = IndependentABVirtualProjectedIntegrandGamma5Free[ell, ss] /.
    preReductionRules;
  expr = FeynCalc`ChangeDimension[expr, loopDimension];
  reduced = FeynCalc`TID[
    expr,
    ell,
    FeynCalc`UsePaVeBasis -> usePaVeBasis
  ] // FeynCalc`Contract;
  reduced = FeynCalc`ToPaVe[reduced, ell];
  reduced //
    ReplaceAll[IndependentAADimensionalOnShellRules[ss] /. preReductionRules] //
    FeynCalc`Contract // FeynCalc`FCE // Simplify
];

IndependentABVirtualReductionDiagnosticGamma5Free[
  ss_: s,
  ell_: l,
  usePaVeBasis_: True,
  loopDimension_: D,
  preReductionRules_: {}
] := Module[
  {reduced, remainingLoopObjects},
  reduced = IndependentABVirtualScalarReductionGamma5Free[
    ss, ell, usePaVeBasis, loopDimension, preReductionRules
  ];
  remainingLoopObjects = DeleteDuplicates@Cases[
    reduced,
    x_ /; (
      ! FreeQ[x, FeynCalc`Momentum[ell, ___]] ||
      ! FreeQ[x, FeynCalc`Pair[FeynCalc`Momentum[ell, ___], _]] ||
      ! FreeQ[x, FeynCalc`Pair[_, FeynCalc`Momentum[ell, ___]]]
    ) :> HoldForm[x],
    Infinity
  ];
  <|
    "ScalarReduction" -> reduced,
    "LeafCount" -> LeafCount[reduced],
    "FreeOfLoopMomentum" -> FreeQ[reduced, FeynCalc`Momentum[ell, ___]],
    "RemainingLoopObjects" -> remainingLoopObjects,
    "ReadyForPackageX" -> (
      FreeQ[reduced, FeynCalc`Momentum[ell, ___]] &&
      remainingLoopObjects === {}
    )
  |>
];

(* Real-emission tree trace for

     J_A -> c(pc) + anti-b(pb) + g(kg)

   interfering with the conjugate J_B current.  This is the raw four-
   dimensional real-emission numerator; the subtraction/integration layer is
   still to be added. *)
IndependentABRealEmissionAChain[lor_, gluLor_, u_: uAA, v_: vAA] :=
  GA[gluLor] . (GS[pcAA] + GS[kgAA] + mc) . GA[lor] . GA[5]/u +
    GA[lor] . GA[5] . (-GS[pbAA] - GS[kgAA] + mb) . GA[gluLor]/v;

IndependentABRealEmissionBConjugateChain[lor_, gluLor_, u_: uAA, v_: vAA] :=
  IndependentABTensorVertex[lor, pAA] .
      (GS[pcAA] + GS[kgAA] + mc) . GA[gluLor]/u +
    GA[gluLor] . (-GS[pbAA] - GS[kgAA] + mb) .
      IndependentABTensorVertex[lor, pAA]/v;

IndependentABRealEmissionProjectedTrace[ss_: s, u_: uAA, v_: vAA] := Module[
  {chainA, chainB, expr},
  chainA = IndependentABRealEmissionAChain[muAA, alphaAA, u, v];
  chainB = IndependentABRealEmissionBConjugateChain[nuAA, betaAA, u, v];
  expr =
    IndependentAASpin1Projector[pAA, muAA, nuAA] (-MT[alphaAA, betaAA])
      DiracTrace[
        DiracSigmaExplicit[
          (GS[pcAA] + mc) . chainA .
          (GS[pbAA] - mb) . chainB
        ]
      ];
  expr = expr // DiracSimplify // Contract // FCE // Simplify;
  IndependentAACutToInvariantFactor[] expr /. IndependentAA3BodyOnShellRules[ss, u, v] //
    Simplify[#, ss > (mb + mc)^2 && u > 0 && v > 0] &
];

IndependentABRealEmissionTraceFormula[] :=
  IndependentABRealEmissionTraceFormula[] =
    IndependentABRealEmissionProjectedTrace[s, uAA, vAA] // Simplify;

IndependentABRealEmissionTraceCheck[
  ssVal_?NumericQ,
  uVal_?NumericQ,
  vVal_?NumericQ,
  params_: $BcMixingDefaultParameters
] := Module[
  {rules = DynamicParameterRules[params]},
  N[IndependentABRealEmissionProjectedTrace[ssVal, uVal, vVal] /. rules]
];

IndependentABStatus[] := <|
  "Goal" -> "Derive rho_1^AB for the mixed axial-vector/tensor perturbative spectral density.",
  "LOCheck" -> IndependentABLODerivationCheck[s][["Difference"]],
  "Gamma5Elimination" -> IndependentABLOGamma5EliminationCheck[],
  "DimensionalNormalizationSeries" -> IndependentABLODimensionalNormalizationSeries[s],
  "NextSteps" -> {
    "run IndependentABVirtualReductionDiagnosticGamma5Free[]",
    "evaluate the virtual scalar integrals with Package-X",
    "derive the real-emission AB trace and soft subtraction",
    "combine virtual, counterterms and real pieces before installing rho_1^AB"
  }
|>;

Print["Loaded BcMixingAlphaSMixedAB.wl. Run IndependentABStatus[] and IndependentABLODerivationCheck[]."];

(* ::Package:: *)

(*
  BcMixingCoordinate.wl

  Coordinate-space implementation for the B_c axial-vector mixing calculation.

  Scope:
    - Use the x-space heavy-quark propagator with modified Bessel functions.
    - Build the coordinate-space trace kernels for AA, AB, BA and BB.
    - Evaluate the perturbative spectral densities obtained after the
      Bessel/Schwinger reduction of the coordinate-space expressions.
    - Keep the coordinate-space route logically independent from the
      momentum-space calculation for any result intended as coordinate-paper
      final.

  Important:
    Perturbative coordinate-space moments are independent.  Local single-line
    G2/G3 kernels are present, but the current reduced numerical bridge is a
    comparison aid because it uses momentum-space Feynman/Schwinger helpers.
    A coordinate-paper-final full OPE requires an independent coordinate-space
    derivation of S_c^G(x) S_b^G(-x), plus independent Bessel/radial reduction
    for all condensate pieces.

  Main references for the coordinate-space machinery:
    - Z.-W. Huang and J. Liu, Analytic calculation of doubly heavy hadron
      spectral density in coordinate space, arXiv:1205.3026.
    - K. Azizi, A. R. Olamaei and S. Rostami, Beautiful mathematics for
      beauty-full and other multi-heavy hadronic systems, arXiv:1801.06789.
    - T. M. Aliev et al., heavy axial-vector mixing-angle analysis, for the
      coordinate-space current/correlator organization used in the one-heavy
      case.
*)

BcMixingCoordinate::nofc =
  "FeynCalc could not be loaded. Install FeynCalc or make it visible to the Wolfram kernel.";
BcMixingCoordinate::badchannel =
  "Unknown channel `1`. Use one of AA, AB, BA or BB.";
BcMixingCoordinate::badorder =
  "Unknown coordinate-space order `1`.";
BcMixingCoordinate::norho =
  "No coordinate-space spectral density is installed for channel `1`, order `2`.";
BcMixingCoordinate::fullg2 =
  "The full coordinate-space G2 kernel is available here. Load BcMixingCoordinateOPE.wl for the independent G2full Borel moment.";
BcMixingCoordinate::needreduction =
  "The reduced coordinate-space local-condensate integration needs the Feynman/Schwinger reduction helpers from BcMixingMomentum.wl. Load BcMixingMomentum.wl first, then reload BcMixingCoordinate.wl.";
BcMixingCoordinate::independent =
  "Independent coordinate-space order `1` is not implemented yet. Needed for a coordinate-paper-final result: derive the x-space Bessel/radial reduction for the listed condensate kernels without using BcMixingMomentum.wl.";

Quiet[
  Check[
    Needs["FeynCalc`"],
    Message[BcMixingCoordinate::nofc];
    Abort[]
  ]
];

If[NameQ["FeynCalc`FCSetDiracGammaScheme"],
  Quiet[FCSetDiracGammaScheme["NDR"]]
];

(* ---------------------------------------------------------------------- *)
(* Symbols and defaults                                                    *)
(* ---------------------------------------------------------------------- *)

ClearAll[
  mb, mc, M2, s0, s, G2, G3, k, p, xv, mu, nu, al, be, rh, si,
  r, x2, px
];

$BcCoordinateNc = 3;
$BcCoordinateChannels = <|
  "AA" -> {"A", "A"},
  "AB" -> {"A", "B"},
  "BA" -> {"B", "A"},
  "BB" -> {"B", "B"}
|>;
$BcCoordinateOrders = {
  "pert",
  "G2c", "G2b", "G2local",
  "pertG2local",
  "G2gg", "G2full", "pertG2full",
  "G3c", "G3b", "G3local",
  "G3full", "totalLocal", "totalFull"
};
$BcCoordinateNumericalOrders = {"pert"};
$BcCoordinateReducedLocalOrders = {
  "G2c", "G2b", "G2local",
  "G3c", "G3b", "G3local",
  "pertG2local", "totalLocal"
};
$BcCoordinateIndependentPendingOrders = {
  "G2c", "G2b", "G2local", "G2gg", "G2full", "pertG2full",
  "G3c", "G3b", "G3local", "G3full", "totalFull"
};
$BcCoordinateSpectralDensities = <||>;

$BcCoordinateDefaultParameters = <|
  "mb" -> 4.18,
  "mc" -> 1.27,
  "G2" -> 4 Pi^2 0.012,
  "G3" -> 0.57,
  "M2" -> 10.0,
  "s0" -> 55.0
|>;

$BcCoordinateDefaultUncertaintyRanges = <|
  "mb" -> {4.18 - 0.03, 4.18 + 0.03},
  "mc" -> {1.27 - 0.02, 1.27 + 0.02},
  "G2" -> {4 Pi^2 (0.012 - 0.004), 4 Pi^2 (0.012 + 0.004)},
  "G3" -> {0.57 - 0.29, 0.57 + 0.29},
  "M2" -> {7.0, 9.0},
  "s0" -> {53.0, 55.0}
|>;

$BcCoordinateWangWindow = <|
  "M2Range" -> {7.0, 9.0},
  "M2Values" -> {7.0, 8.0, 9.0},
  "s0Central" -> 54.0,
  "s0Range" -> {53.0, 55.0},
  "s0Values" -> {53.0, 54.0, 55.0}
|>;

$BcCoordinateMomentumComparableThetaRange = {42.30709723493363, 44.30709723493363};

$BcCoordinateAssumptions =
  Element[{mb, mc, M2, s0, s, G2, G3}, Reals] &&
  mb > 0 && mc > 0 && M2 > 0 && s0 > (mb + mc)^2 &&
  G2 >= 0 && G3 >= 0;

MergeCoordinateParameters[assoc_: <||>] :=
  Join[$BcCoordinateDefaultParameters, assoc];

CoordinateParameterRules[assoc_: $BcCoordinateDefaultParameters] := Module[
  {merged = MergeCoordinateParameters[assoc]},
  {
    mb -> merged["mb"],
    mc -> merged["mc"],
    G2 -> merged["G2"],
    G3 -> merged["G3"],
    M2 -> merged["M2"],
    s0 -> merged["s0"]
  }
];

CoordinateThreshold[] := (mb + mc)^2;
CoordinateTensorCurrentScale[] := mb + mc;
CoordinateTensorCurrentNormalization[] := 1/CoordinateTensorCurrentScale[];

ValidateCoordinateChannel[channel_String] := If[
  KeyExistsQ[$BcCoordinateChannels, channel],
  channel,
  Message[BcMixingCoordinate::badchannel, channel];
  Abort[]
];

ValidateCoordinateOrder[order_String] := If[
  MemberQ[$BcCoordinateOrders, order],
  order,
  Message[BcMixingCoordinate::badorder, order];
  Abort[]
];

CoordinateCurrentTensorPower[channel_String] :=
  Count[$BcCoordinateChannels[ValidateCoordinateChannel[channel]], "B"];

CoordinateCurrentNormalizationFactor[channel_String] :=
  CoordinateTensorCurrentScale[]^-CoordinateCurrentTensorPower[channel];

CoordinateCheckEnvironment[] := <|
  "FeynCalcLoaded" -> TrueQ[ValueQ[$FeynCalcVersion]],
  "FeynCalcVersion" -> If[TrueQ[ValueQ[$FeynCalcVersion]], $FeynCalcVersion, Missing["NotLoaded"]],
  "ImplementedOrders" -> $BcCoordinateOrders,
  "NumericalOrders" -> $BcCoordinateNumericalOrders,
  "ReducedLocalOrders" -> $BcCoordinateReducedLocalOrders,
  "IndependentPendingOrders" -> $BcCoordinateIndependentPendingOrders,
  "ReducedLocalIntegrationAvailable" -> CoordinateReducedIntegrationAvailableQ[],
  "TensorCurrentScale" -> CoordinateTensorCurrentScale[],
  "Threshold" -> CoordinateThreshold[],
  "DefaultParameters" -> $BcCoordinateDefaultParameters,
  "WangWindow" -> $BcCoordinateWangWindow
|>;

CoordinateIndependenceStatus[] := <|
  "IndependentNow" -> <|
    "pert" -> "Independent coordinate-space perturbative spectral density and Borel moment.",
    "G2full" -> "Independent dimension-4 G2 Borel moment is available in BcMixingCoordinateOPE.wl."
  |>,
  "DiagnosticOrBorrowedNow" -> <|
    "G3c/G3b/G3local" -> "Coordinate kernels exist, but current numerical reduced bridge uses BcMixingMomentum.wl helper functions.",
    "FullOPEMonteCarloBlocks" -> "Use momentum-space full OPE engine for comparison only, not as an independent coordinate-space result."
  |>,
  "NeededForIndependentCoordinatePaper" -> <|
    "G2Audit" -> "Audit the coordinate-space G2 sign and normalization convention before paper-final use.",
    "G3Audit" -> "Audit whether the single-line G3 truncation is sufficient or whether open-field dimension-6 terms are required.",
    "Uncertainty" -> "After accepting the coordinate-space G2/G3 conventions, run Monte Carlo from the OPE workbench."
  |>
|>;

CoordinateIndependentOrderAvailableQ[order_String] :=
  order === "pert";

CoordinateIndependentBorelPi[
  channel_String,
  order_String : "pert",
  m2Val_?NumericQ,
  continuumVal_?NumericQ,
  params_: $BcCoordinateDefaultParameters,
  opts : OptionsPattern[CoordinateNumericBorelPi]
] := Module[
  {ord = ValidateCoordinateOrder[order]},
  If[CoordinateIndependentOrderAvailableQ[ord],
    Return[CoordinateNumericBorelPi[channel, ord, m2Val, continuumVal, params, opts]]
  ];
  Message[BcMixingCoordinate::independent, ord];
  $Failed
];

(* ---------------------------------------------------------------------- *)
(* Coordinate-space propagator kernels                                     *)
(* ---------------------------------------------------------------------- *)

CoordinateRadius[x2Symbol_: x2] := Sqrt[-x2Symbol];

CoordinateHeavyPropagatorFree[
  mass_,
  sign_: 1,
  xSlash_: GS[xv],
  radius_: r
] :=
  mass^2/(2 Pi)^2 (
    I sign xSlash BesselK[2, mass radius]/radius^2 +
    BesselK[1, mass radius]/radius
  );

CoordinateHeavyPropagatorG2Kernel[
  mass_,
  sign_: 1,
  xSlash_: GS[xv],
  radius_: r,
  x2Symbol_: x2
] :=
  -G2/(2^6 3 (2 Pi)^2) (
    (I sign mass xSlash - 6) BesselK[1, mass radius]/radius +
    4 mass x2Symbol BesselK[2, mass radius]/radius^2
  );

CoordinateHeavyPropagatorGOpenKernel[
  mass_,
  sign_: 1,
  fieldIndex1_: al,
  fieldIndex2_: be,
  xSlash_: GS[xv],
  radius_: r
] := Module[
  {sigma = DiracSigma[GA[fieldIndex1], GA[fieldIndex2]]},
  -1/(8 (2 Pi)^2) (
    I sign mass (sigma . xSlash + xSlash . sigma) BesselK[1, mass radius]/radius +
    2 mass sigma BesselK[0, mass radius]
  )
];

CoordinateHeavyPropagatorG3Kernel[
  mass_,
  sign_: 1,
  xSlash_: GS[xv],
  radius_: r,
  x2Symbol_: x2
] :=
  G3/(2^8 3^2 (2 Pi)^2) (
    -I sign xSlash x2Symbol BesselK[1, mass radius]/(mass radius) +
    4 I sign xSlash x2Symbol BesselK[2, mass radius]/radius^2 +
    10 x2Symbol^2 BesselK[2, mass radius]/(mass radius^2) +
    x2Symbol^2 BesselK[1, mass radius]/radius
  );

CoordinateCurrentVertex["A", lor_] := GA[lor] . GA[5];

CoordinateCurrentVertex["B", lor_] := Module[
  {phase = I},
  phase CoordinateTensorCurrentNormalization[] (DiracSigma[GA[lor], GS[p]] . GA[5])
];

CoordinateEvaluateDiracTrace[chain_] :=
  chain //
    DotSimplify //
    DiracSigmaExplicit //
    DiracTrace //
    DiracSimplify //
    Contract //
    FCE //
    Simplify;

CoordinateProjectSpin1[expr_] := Module[
  {projector},
  projector = 1/3 (MT[mu, nu] - FV[p, mu] FV[p, nu]/SP[p, p]);
  Contract[projector expr] //
    FCE //
    DiracSimplify //
    Contract //
    Simplify
];

CoordinateScalarize[expr_] :=
  expr /. {
      SP[xv, xv] -> x2,
      SP[p, xv] -> px,
      SP[xv, p] -> px,
      SP[p, p] -> s
    } // Simplify;

CoordinateTraceKernel[
  channel_String,
  order_String : "pert",
  projected_: True
] := Module[
  {ch = ValidateCoordinateChannel[channel], pair, sc, sb, expr},
  ValidateCoordinateOrder[order];
  If[order === "G2full",
    Return[
      CoordinateTraceKernel[ch, "G2local", projected] +
      CoordinateTraceKernel[ch, "G2gg", projected] // Simplify
    ]
  ];
  If[order === "pertG2full",
    Return[
      CoordinateTraceKernel[ch, "pert", projected] +
      CoordinateTraceKernel[ch, "G2full", projected] // Simplify
    ]
  ];
  If[order === "G2local",
    Return[
      CoordinateTraceKernel[ch, "G2c", projected] +
      CoordinateTraceKernel[ch, "G2b", projected] // Simplify
    ]
  ];
  If[order === "G3local",
    Return[
      CoordinateTraceKernel[ch, "G3c", projected] +
      CoordinateTraceKernel[ch, "G3b", projected] // Simplify
    ]
  ];
  If[order === "G2gg",
    pair = $BcCoordinateChannels[ch];
    sc = CoordinateHeavyPropagatorGOpenKernel[mc, -1, al, be];
    sb = CoordinateHeavyPropagatorGOpenKernel[mb, 1, rh, si];
    expr =
      -I G2 (($BcCoordinateNc^2 - 1)/2)/96 Contract[
        (MT[al, rh] MT[be, si] - MT[al, si] MT[be, rh])
        CoordinateEvaluateDiracTrace[
          CoordinateCurrentVertex[pair[[1]], mu] . sc .
          CoordinateCurrentVertex[pair[[2]], nu] . sb
        ]
      ];
    If[TrueQ[projected], expr = CoordinateProjectSpin1[expr]];
    Return[CoordinateScalarize[expr]]
  ];
  If[MemberQ[{"G3full", "totalFull"}, order],
    Message[BcMixingCoordinate::independent, order];
    Return[$Failed]
  ];
  If[order === "pertG2local" || order === "totalLocal",
    Message[BcMixingCoordinate::badorder, order];
    Abort[]
  ];
  pair = $BcCoordinateChannels[ch];
  {sc, sb} = Switch[
    order,
    "pert",
      {
        CoordinateHeavyPropagatorFree[mc, -1],
        CoordinateHeavyPropagatorFree[mb, 1]
      },
    "G2c",
      {
        CoordinateHeavyPropagatorG2Kernel[mc, -1],
        CoordinateHeavyPropagatorFree[mb, 1]
      },
    "G2b",
      {
        CoordinateHeavyPropagatorFree[mc, -1],
        CoordinateHeavyPropagatorG2Kernel[mb, 1]
      },
    "G3c",
      {
        CoordinateHeavyPropagatorG3Kernel[mc, -1],
        CoordinateHeavyPropagatorFree[mb, 1]
      },
    "G3b",
      {
        CoordinateHeavyPropagatorFree[mc, -1],
        CoordinateHeavyPropagatorG3Kernel[mb, 1]
      }
  ];
  expr =
    -I $BcCoordinateNc CoordinateEvaluateDiracTrace[
      CoordinateCurrentVertex[pair[[1]], mu] . sc .
      CoordinateCurrentVertex[pair[[2]], nu] . sb
    ];
  If[TrueQ[projected], expr = CoordinateProjectSpin1[expr]];
  CoordinateScalarize[expr]
];

CoordinateTraceKernelTable[] := AssociationMap[
  CoordinateTraceKernel[#, "pert"] &,
  {"AA", "AB", "BA", "BB"}
];

CoordinateCondensateTraceKernelTable[order_String] := Module[
  {ord = ValidateCoordinateOrder[order]},
  AssociationMap[
    CoordinateTraceKernel[#, ord] &,
    {"AA", "AB", "BA", "BB"}
  ]
];

(* ---------------------------------------------------------------------- *)
(* Reduced local-condensate Borel integrations                             *)
(* ---------------------------------------------------------------------- *)

CoordinateReducedIntegrationAvailableQ[] :=
  AllTrue[
    {
      "SimplexAmplitude",
      "BorelTransformQ2",
      "ContinuumXLimits",
      "ParameterRules"
    },
    NameQ
  ];

CoordinateReducedOrderPieces["G2local"] := {"G2c", "G2b"};
CoordinateReducedOrderPieces["G3local"] := {"G3c", "G3b"};
CoordinateReducedOrderPieces["pertG2local"] := {"pert", "G2local"};
CoordinateReducedOrderPieces["totalLocal"] := {"pert", "G2local", "G3local"};
CoordinateReducedOrderPieces[order_String] := {order};

CoordinateReducedBorelIntegrandExpression[channel_String, order_String] :=
  CoordinateReducedBorelIntegrandExpression[channel, order] = Module[
    {ch = ValidateCoordinateChannel[channel], ord = ValidateCoordinateOrder[order]},
    Which[
      ord === "pert" || ord === "pertG2local" || ord === "totalLocal",
        Message[BcMixingCoordinate::badorder, ord];
        $Failed,
      MemberQ[{"G2local", "G3local"}, ord],
        Total[CoordinateReducedBorelIntegrandExpression[ch, #] & /@ CoordinateReducedOrderPieces[ord]] // Simplify,
      ! CoordinateReducedIntegrationAvailableQ[],
        Message[BcMixingCoordinate::needreduction];
        $Failed,
      True,
        ToExpression["BorelTransformQ2"][
          ToExpression["$BcMixingDirectBorelPhase"] ToExpression["SimplexAmplitude"][ch, ord, xi],
          xi,
          M2
        ] // Together // Simplify
    ]
  ];

Options[CoordinateNumericBorelPiReduced] = Options[NIntegrate];

CoordinateNumericBorelPiReduced[
  channel_String,
  order_String,
  m2Val_?NumericQ,
  continuumVal_?NumericQ,
  params_: $BcCoordinateDefaultParameters,
  opts : OptionsPattern[]
] := Module[
  {ch = ValidateCoordinateChannel[channel], ord = ValidateCoordinateOrder[order],
   lims, integrand, pieces},
  Which[
    ord === "pert",
      Return[CoordinateNumericBorelPi[ch, "pert", m2Val, continuumVal, params, opts]],
    ord === "pertG2local" || ord === "totalLocal",
      pieces = CoordinateNumericBorelPiReduced[ch, #, m2Val, continuumVal, params, opts] & /@
        CoordinateReducedOrderPieces[ord];
      If[MemberQ[pieces, $Failed], Return[$Failed]];
      Return[
        Total[pieces]
      ],
    MemberQ[{"G2local", "G3local"}, ord],
      pieces = CoordinateNumericBorelPiReduced[ch, #, m2Val, continuumVal, params, opts] & /@
        CoordinateReducedOrderPieces[ord];
      If[MemberQ[pieces, $Failed], Return[$Failed]];
      Return[
        Total[pieces]
      ]
  ];
  If[! CoordinateReducedIntegrationAvailableQ[],
    Message[BcMixingCoordinate::needreduction];
    Return[$Failed]
  ];
  lims = ToExpression["ContinuumXLimits"][continuumVal, params];
  If[lims === $Failed, Return[0.]];
  integrand = Evaluate[
    CoordinateReducedBorelIntegrandExpression[ch, ord] /.
      DeleteCases[ToExpression["ParameterRules"][params], (M2 -> _) | (s0 -> _)] /.
      M2 -> m2Val
  ];
  If[integrand === $Failed, Return[$Failed]];
  NIntegrate[
    integrand,
    {xi, lims[[1]], lims[[2]]},
    opts
  ]
];

(* ---------------------------------------------------------------------- *)
(* Perturbative spectral density from coordinate-space Bessel reduction     *)
(* ---------------------------------------------------------------------- *)

CoordinateKallenLambda[ss_, m1_, m2_] :=
  ss^2 + m1^4 + m2^4 - 2 ss m1^2 - 2 ss m2^2 - 2 m1^2 m2^2;

CoordinateOnShellKDotP[ss_] := (ss + mc^2 - mb^2)/2;

CoordinatePerturbativeNumerator[channel_String, ss_: s] := Module[
  {kp = CoordinateOnShellKDotP[ss], k2 = mc^2, ch = ValidateCoordinateChannel[channel]},
  Switch[
    ch,
    "AA",
      -4/ss (2 kp^2 + (3 mb mc + k2) ss - 3 kp ss),
    "AB",
      12 (-(mb + mc) kp + mc ss),
    "BA",
      12 (-(mb + mc) kp + mc ss),
    "BB",
      -4 (4 kp^2 + (3 mb mc - k2) ss - 3 kp ss)
  ] // Simplify
];

CoordinatePerturbativeSpectralDensity[channel_String, ss_: s] := Module[
  {lam = CoordinateKallenLambda[ss, mb, mc]},
  $BcCoordinateNc/(16 Pi^2) Sqrt[lam]/ss
    CoordinatePerturbativeNumerator[channel, ss]
    CoordinateCurrentNormalizationFactor[channel]
];

CoordinatePerturbativeSpectralDensityNumeric[
  channel_String,
  ss_?NumericQ,
  params_: $BcCoordinateDefaultParameters
] := Module[
  {ch = ValidateCoordinateChannel[channel], merged = MergeCoordinateParameters[params],
   mbv, mcv, lam, kp, k2, numerator, normalization},
  mbv = N[merged["mb"]];
  mcv = N[merged["mc"]];
  lam = N[CoordinateKallenLambda[ss, mbv, mcv]];
  kp = N[(ss + mcv^2 - mbv^2)/2];
  k2 = mcv^2;
  numerator = Switch[
    ch,
    "AA",
      -4/ss (2 kp^2 + (3 mbv mcv + k2) ss - 3 kp ss),
    "AB" | "BA",
      12 (-(mbv + mcv) kp + mcv ss),
    "BB",
      -4 (4 kp^2 + (3 mbv mcv - k2) ss - 3 kp ss)
  ];
  normalization = (mbv + mcv)^(-CoordinateCurrentTensorPower[ch]);
  N[$BcCoordinateNc/(16 Pi^2) Sqrt[Max[0., lam]]/ss numerator normalization]
];

SetCoordinateSpectralDensity[channel_String, order_String, expr_, var_: s] := Module[
  {ch = ValidateCoordinateChannel[channel], ord = ValidateCoordinateOrder[order]},
  If[! MemberQ[$BcCoordinateNumericalOrders, ord],
    Message[BcMixingCoordinate::badorder, ord];
    Abort[]
  ];
  $BcCoordinateSpectralDensities[{ch, ord}] = With[
    {storedBody = expr, storedVar = var},
    (storedBody /. storedVar -> #) &
  ];
  {ch, ord}
];

InstallCoordinatePerturbativeSpectralDensities[] := (
  Scan[
    SetCoordinateSpectralDensity[#, "pert", CoordinatePerturbativeSpectralDensity[#, s], s] &,
    {"AA", "AB", "BA", "BB"}
  ];
  "Installed coordinate-space perturbative spectral densities for AA, AB, BA and BB."
);

InstallCoordinatePerturbativeSpectralDensities[];

CoordinateSpectralDensity[channel_String, order_String : "pert", var_: s] := Module[
  {ch = ValidateCoordinateChannel[channel], ord = ValidateCoordinateOrder[order]},
  If[! MemberQ[$BcCoordinateNumericalOrders, ord],
    Message[BcMixingCoordinate::norho, ch, ord];
    Return[$Failed]
  ];
  If[
    KeyExistsQ[$BcCoordinateSpectralDensities, {ch, ord}],
    $BcCoordinateSpectralDensities[{ch, ord}][var],
    Message[BcMixingCoordinate::norho, ch, ord];
    $Failed
  ]
];

CoordinateBorelPi[channel_String, order_String : "pert", m2_: M2, continuum_: s0] := Module[
  {var, density},
  density = CoordinateSpectralDensity[channel, order, var];
  If[density === $Failed, Return[$Failed]];
  Integrate[
    Exp[-var/m2] density,
    {var, CoordinateThreshold[], continuum},
    Assumptions -> $BcCoordinateAssumptions
  ]
];

Options[CoordinateNumericBorelPi] = Options[NIntegrate];

CoordinateNumericPerturbativeBorelPi[
  channel_String,
  m2Val_?NumericQ,
  continuumVal_?NumericQ,
  params_: $BcCoordinateDefaultParameters,
  opts : OptionsPattern[NIntegrate]
] := Module[
  {rules, lower},
  ValidateCoordinateChannel[channel];
  rules = Join[CoordinateParameterRules[params], {M2 -> m2Val, s0 -> continuumVal}];
  lower = N[CoordinateThreshold[] /. rules];
  If[continuumVal <= lower, Return[0.]];
  NIntegrate[
    Exp[-ss/m2Val] CoordinatePerturbativeSpectralDensityNumeric[channel, ss, params],
    {ss, lower, continuumVal},
    opts
  ]
];

CoordinateNumericBorelPi[
  channel_String,
  order_String : "pert",
  m2Val_?NumericQ,
  continuumVal_?NumericQ,
  params_: $BcCoordinateDefaultParameters,
  opts : OptionsPattern[]
] := Module[
  {var, rules, lower, density},
  ValidateCoordinateChannel[channel];
  ValidateCoordinateOrder[order];
  If[order === "pert",
    Return[CoordinateNumericPerturbativeBorelPi[channel, m2Val, continuumVal, params, opts]]
  ];
  If[MemberQ[$BcCoordinateReducedLocalOrders, order],
    Return[CoordinateNumericBorelPiReduced[channel, order, m2Val, continuumVal, params, opts]]
  ];
  rules = Join[CoordinateParameterRules[params], {M2 -> m2Val, s0 -> continuumVal}];
  lower = N[CoordinateThreshold[] /. rules];
  If[continuumVal <= lower, Return[0.]];
  density = Evaluate[CoordinateSpectralDensity[channel, order, var] /. rules];
  NIntegrate[
    Evaluate[Exp[-var/m2Val] density],
    {var, lower, continuumVal},
    opts
  ]
];

CoordinateNormalizeMixingAngle[theta_?NumericQ] :=
  theta - (Pi/2) Round[theta/(Pi/2)];

CoordinateNormalizeMixingAngleDegrees[thetaDeg_?NumericQ] :=
  thetaDeg - 90 Round[thetaDeg/90];

CoordinateNumericMixingAngle[
  m2Val_?NumericQ,
  continuumVal_?NumericQ,
  order_String : "pert",
  params_: $BcCoordinateDefaultParameters,
  opts : OptionsPattern[CoordinateNumericBorelPi]
] := Module[
  {aa, ab, bb},
  aa = CoordinateNumericBorelPi["AA", order, m2Val, continuumVal, params, opts];
  ab = CoordinateNumericBorelPi["AB", order, m2Val, continuumVal, params, opts];
  bb = CoordinateNumericBorelPi["BB", order, m2Val, continuumVal, params, opts];
  If[MemberQ[{aa, ab, bb}, $Failed], Return[$Failed]];
  CoordinateNormalizeMixingAngle[1/2 ArcTan[aa - bb, -2 ab]]
];

CoordinateNumericMixingAngleDegrees[
  m2Val_?NumericQ,
  continuumVal_?NumericQ,
  order_String : "pert",
  params_: $BcCoordinateDefaultParameters,
  opts : OptionsPattern[CoordinateNumericBorelPi]
] :=
  CoordinateNormalizeMixingAngleDegrees[
    N[180/Pi CoordinateNumericMixingAngle[m2Val, continuumVal, order, params, opts]]
  ];

CoordinateNumericOPESummary[
  m2Val_?NumericQ,
  continuumVal_?NumericQ,
  order_String : "pert",
  params_: $BcCoordinateDefaultParameters,
  opts : OptionsPattern[CoordinateNumericBorelPi]
] := Module[
  {orders},
  orders = Switch[
    ValidateCoordinateOrder[order],
    "pert", {"pert"},
    "G2local", {"G2c", "G2b", "G2local"},
    "G3local", {"G3c", "G3b", "G3local"},
    "pertG2local", {"pert", "G2c", "G2b", "G2local", "pertG2local"},
    "totalLocal", {"pert", "G2local", "G3local", "pertG2local", "totalLocal"},
    _, {order}
  ];
  AssociationMap[
    Function[
      ch,
      AssociationMap[
        Function[ord, CoordinateNumericBorelPi[ch, ord, m2Val, continuumVal, params, opts]],
        orders
      ]
    ],
    {"AA", "AB", "BB"}
  ]
];

CoordinateMixingAngleSummary[
  m2Val_?NumericQ,
  continuumVal_?NumericQ,
  params_: $BcCoordinateDefaultParameters,
  opts : OptionsPattern[CoordinateNumericBorelPi]
] := <|
  "M2" -> m2Val,
  "s0" -> continuumVal,
  "ThetaPertDeg" -> CoordinateNumericMixingAngleDegrees[m2Val, continuumVal, "pert", params, opts],
  "ThetaPertG2LocalDeg" -> CoordinateNumericMixingAngleDegrees[m2Val, continuumVal, "pertG2local", params, opts],
  "ThetaTotalLocalDeg" -> CoordinateNumericMixingAngleDegrees[m2Val, continuumVal, "totalLocal", params, opts]
|>;

CoordinateMixingAngleGrid[
  m2Values_List,
  s0Values_List,
  params_: $BcCoordinateDefaultParameters,
  opts : OptionsPattern[CoordinateNumericBorelPi]
] :=
  Table[
    <|
      "M2" -> m2v,
      "s0" -> s0v,
      "ThetaPertDeg" -> CoordinateNumericMixingAngleDegrees[m2v, s0v, "pert", params, opts]
    |>,
    {m2v, m2Values},
    {s0v, s0Values}
  ] // Flatten;

CoordinateWangWindowGrid[
  order_String : "pert",
  params_: $BcCoordinateDefaultParameters,
  opts : OptionsPattern[CoordinateNumericBorelPi]
] :=
  Table[
    <|
      "M2" -> m2v,
      "s0" -> s0v,
      "Order" -> order,
      "ThetaDeg" -> CoordinateNumericMixingAngleDegrees[m2v, s0v, order, params, opts]
    |>,
    {m2v, $BcCoordinateWangWindow["M2Values"]},
    {s0v, $BcCoordinateWangWindow["s0Values"]}
  ] // Flatten;

CoordinateCompareToMomentum[
  m2Val_?NumericQ,
  continuumVal_?NumericQ,
  params_: $BcCoordinateDefaultParameters,
  opts : OptionsPattern[CoordinateNumericBorelPi]
] := Module[
  {coord, mom},
  coord = CoordinateNumericMixingAngleDegrees[m2Val, continuumVal, "pert", params, opts];
  mom = If[
    NameQ["NumericMixingAngleDegrees"],
    NumericMixingAngleDegrees[m2Val, continuumVal, "pert", params, opts],
    Missing["Load BcMixingMomentum.wl for momentum comparison"]
  ];
  <|
    "CoordinatePertDeg" -> coord,
    "MomentumPertDeg" -> mom,
    "DifferenceDeg" -> If[NumericQ[mom], coord - mom, Missing["NotAvailable"]]
  |>
];

CoordinateLocalCondensateSummary[
  m2Val_?NumericQ,
  continuumVal_?NumericQ,
  params_: $BcCoordinateDefaultParameters,
  opts : OptionsPattern[CoordinateNumericBorelPi]
] := AssociationMap[
  <|
    "pert" -> CoordinateNumericBorelPi[#, "pert", m2Val, continuumVal, params, opts],
    "G2c" -> CoordinateNumericBorelPi[#, "G2c", m2Val, continuumVal, params, opts],
    "G2b" -> CoordinateNumericBorelPi[#, "G2b", m2Val, continuumVal, params, opts],
    "G2local" -> CoordinateNumericBorelPi[#, "G2local", m2Val, continuumVal, params, opts],
    "G3c" -> CoordinateNumericBorelPi[#, "G3c", m2Val, continuumVal, params, opts],
    "G3b" -> CoordinateNumericBorelPi[#, "G3b", m2Val, continuumVal, params, opts],
    "G3local" -> CoordinateNumericBorelPi[#, "G3local", m2Val, continuumVal, params, opts],
    "pertG2local" -> CoordinateNumericBorelPi[#, "pertG2local", m2Val, continuumVal, params, opts],
    "totalLocal" -> CoordinateNumericBorelPi[#, "totalLocal", m2Val, continuumVal, params, opts]
  |>&,
  {"AA", "AB", "BB"}
];

Options[CoordinateLocalCondensateComparisonToMomentum] = Join[
  Options[CoordinateNumericBorelPi],
  {"IncludeG3" -> False}
];

CoordinateLocalCondensateComparisonToMomentum[
  m2Val_?NumericQ,
  continuumVal_?NumericQ,
  params_: $BcCoordinateDefaultParameters,
  opts : OptionsPattern[]
] := Module[
  {channels = {"AA", "AB", "BB"}, localG2, fullG2, localG3, fullG3,
   includeG3 = OptionValue["IncludeG3"], numericOpts},
  If[! NameQ["NumericBorelPi"],
    Return[Missing["Load BcMixingMomentum.wl for full momentum comparison"]]
  ];
  numericOpts = FilterRules[{opts}, Options[CoordinateNumericBorelPi]];
  AssociationMap[
    Function[ch,
      localG2 = CoordinateNumericBorelPi[ch, "G2local", m2Val, continuumVal, params, Sequence @@ numericOpts];
      fullG2 = NumericBorelPi[ch, "G2", m2Val, continuumVal, params, Sequence @@ numericOpts];
      If[TrueQ[includeG3],
        localG3 = CoordinateNumericBorelPi[ch, "G3local", m2Val, continuumVal, params, Sequence @@ numericOpts];
        fullG3 = NumericBorelPi[ch, "G3", m2Val, continuumVal, params, Sequence @@ numericOpts],
        localG3 = Missing["Set IncludeG3 -> True"];
        fullG3 = Missing["Set IncludeG3 -> True"]
      ];
      Join[
        <|
        "CoordinateG2local" -> localG2,
        "MomentumG2full" -> fullG2,
        "ResidualG2fullMinusLocal" -> If[And @@ (NumericQ /@ {localG2, fullG2}), fullG2 - localG2, Missing["NotAvailable"]]
        |>,
        If[TrueQ[includeG3],
          <|
        "CoordinateG3local" -> localG3,
        "MomentumG3" -> fullG3,
        "G3Difference" -> If[And @@ (NumericQ /@ {localG3, fullG3}), fullG3 - localG3, Missing["NotAvailable"]]
          |>,
          <|"G3Comparison" -> Missing["Set IncludeG3 -> True"]|>
        ]
      ]
    ],
    channels
  ]
];

(* ---------------------------------------------------------------------- *)
(* Coordinate-space tables, stability plots and uncertainty analysis        *)
(* ---------------------------------------------------------------------- *)

CoordinatePlotStyles[n_Integer?Positive] :=
  Directive[AbsoluteThickness[2.2], #] & /@ ColorData[97, "ColorList"][[1 ;; n]];

CoordinateThetaYRange[values_, halfWidth_: 1.0, padFraction_: 0.20] := Module[
  {flat = Flatten[N[values]], finite, center, span, pad},
  If[! NumericQ[halfWidth] || ! NumericQ[padFraction], Return[Automatic]];
  finite = Select[flat, NumericQ[#] && TrueQ[Abs[#] < Infinity] &];
  If[finite === {}, Return[Automatic]];
  center = Mean[MinMax[finite]];
  span = Max[Max[finite] - Min[finite], 2 halfWidth];
  pad = padFraction span;
  center + {-span/2 - pad, span/2 + pad}
];

CoordinateLegendNumber[value_?NumericQ] := If[
  Chop[value - Round[value]] == 0,
  ToString[Round[value]],
  ToString[
    NumberForm[
      value,
      {8, 3},
      NumberPadding -> {"", ""},
      NumberPoint -> ".",
      ExponentFunction -> (Null &)
    ]
  ]
];

CoordinateM2StabilityData[
  m2Range : {_?NumericQ, _?NumericQ} : $BcCoordinateWangWindow["M2Range"],
  s0Values_List : $BcCoordinateWangWindow["s0Values"],
  order_String : "pert",
  params_: $BcCoordinateDefaultParameters,
  nPoints_Integer : 25,
  opts : OptionsPattern[CoordinateNumericBorelPi]
] := Module[
  {m2Values = N[Subdivide[m2Range[[1]], m2Range[[2]], Max[1, nPoints - 1]]]},
  Association @ Table[
    s0v -> Table[
      {m2v, CoordinateNumericMixingAngleDegrees[m2v, s0v, order, params, opts]},
      {m2v, m2Values}
    ],
    {s0v, N[s0Values]}
  ]
];

CoordinateS0StabilityData[
  s0Range : {_?NumericQ, _?NumericQ} : $BcCoordinateWangWindow["s0Range"],
  m2Values_List : $BcCoordinateWangWindow["M2Values"],
  order_String : "pert",
  params_: $BcCoordinateDefaultParameters,
  nPoints_Integer : 25,
  opts : OptionsPattern[CoordinateNumericBorelPi]
] := Module[
  {s0Values = N[Subdivide[s0Range[[1]], s0Range[[2]], Max[1, nPoints - 1]]]},
  Association @ Table[
    m2v -> Table[
      {s0v, CoordinateNumericMixingAngleDegrees[m2v, s0v, order, params, opts]},
      {s0v, s0Values}
    ],
    {m2v, N[m2Values]}
  ]
];

CoordinateCSVField[value_?NumericQ] := ToString[N[value], InputForm];
CoordinateCSVField[value_String] := Module[
  {text = value},
  If[StringContainsQ[text, {",", "\"", "\n", "\r"}],
    "\"" <> StringReplace[text, "\"" -> "\"\""] <> "\"",
    text
  ]
];
CoordinateCSVField[value_] := CoordinateCSVField[ToString[value, InputForm]];

CoordinateWriteCSV[file_String, table_List] := Module[
  {stream},
  stream = OpenWrite[file, CharacterEncoding -> "UTF8"];
  WriteString[
    stream,
    StringRiffle[StringRiffle[CoordinateCSVField /@ #, ","] & /@ table, "\n"] <> "\n"
  ];
  Close[stream];
  file
];

CoordinateStabilityDataCSVTable[data_Association, xLabel_String : "x"] := Module[
  {rows},
  rows = Flatten[
    KeyValueMap[
      Function[{fixed, pts},
        ({fixed, #[[1]], #[[2]]} & /@ pts)
      ],
      data
    ],
    1
  ];
  Prepend[rows, {"FixedParameter", xLabel, "ThetaDeg"}]
];

CoordinateExportStabilityDataCSV[data_Association, file_String, xLabel_String : "x"] :=
  CoordinateWriteCSV[file, CoordinateStabilityDataCSVTable[data, xLabel]];

Options[CoordinateM2StabilityPublicationPlot] = Join[
  Options[CoordinateNumericBorelPi],
  {
    "NPoints" -> 25,
    "YHalfWidth" -> 1.0,
    "YPadFraction" -> 0.20,
    ImageSize -> 540,
    LabelStyle -> Directive[Black, 14, FontFamily -> "Times"],
    BaseStyle -> {FontFamily -> "Times"},
    PlotRange -> Automatic
  }
];

CoordinateM2StabilityPublicationPlot[
  m2Range : {_?NumericQ, _?NumericQ} : $BcCoordinateWangWindow["M2Range"],
  s0Values_List : $BcCoordinateWangWindow["s0Values"],
  order_String : "pert",
  params_: $BcCoordinateDefaultParameters,
  opts : OptionsPattern[]
] := Module[
  {nPoints = Max[2, Round[OptionValue["NPoints"]]], numericOpts, data},
  numericOpts = FilterRules[{opts}, Options[CoordinateNumericBorelPi]];
  data = CoordinateM2StabilityData[m2Range, s0Values, order, params, nPoints, Sequence @@ numericOpts];
  CoordinateM2StabilityPublicationPlotFromData[
    data,
    m2Range,
    Sequence @@ FilterRules[{opts}, Options[CoordinateM2StabilityPublicationPlotFromData]]
  ]
];

Options[CoordinateM2StabilityPublicationPlotFromData] =
  Options[CoordinateM2StabilityPublicationPlot];

CoordinateM2StabilityPublicationPlotFromData[
  data_Association,
  m2Range : {_?NumericQ, _?NumericQ} : $BcCoordinateWangWindow["M2Range"],
  opts : OptionsPattern[]
] := Module[
  {styles, labels, yRange, plotRange},
  styles = CoordinatePlotStyles[Length[data]];
  labels = Row[{Subscript["s", 0], " = ", CoordinateLegendNumber[#], " ", Superscript["GeV", 2]}] & /@ Keys[data];
  yRange = CoordinateThetaYRange[Values[data][[All, All, 2]], OptionValue["YHalfWidth"], OptionValue["YPadFraction"]];
  plotRange = Replace[OptionValue[PlotRange], Automatic -> {m2Range, yRange}];
  <|
    "Data" -> data,
    "Plot" -> ListLinePlot[
      Values[data],
      Frame -> True,
      Axes -> False,
      FrameLabel -> {
        Row[{Superscript["M", 2], " (", Superscript["GeV", 2], ")"}],
        Superscript["\[Theta]", "\[Degree]"]
      },
      LabelStyle -> OptionValue[LabelStyle],
      BaseStyle -> OptionValue[BaseStyle],
      ImageSize -> OptionValue[ImageSize],
      ImagePadding -> {{75, 20}, {60, 20}},
      PlotStyle -> styles,
      PlotMarkers -> Automatic,
      PlotRange -> plotRange,
      GridLines -> Automatic,
      GridLinesStyle -> Directive[GrayLevel[0.85], Dashed],
      PlotLegends -> Placed[LineLegend[styles, labels, LegendMarkerSize -> 18], Right]
    ]
  |>
];

Options[CoordinateS0StabilityPublicationPlot] = Options[CoordinateM2StabilityPublicationPlot];

CoordinateS0StabilityPublicationPlot[
  s0Range : {_?NumericQ, _?NumericQ} : $BcCoordinateWangWindow["s0Range"],
  m2Values_List : $BcCoordinateWangWindow["M2Values"],
  order_String : "pert",
  params_: $BcCoordinateDefaultParameters,
  opts : OptionsPattern[]
] := Module[
  {nPoints = Max[2, Round[OptionValue["NPoints"]]], numericOpts, data},
  numericOpts = FilterRules[{opts}, Options[CoordinateNumericBorelPi]];
  data = CoordinateS0StabilityData[s0Range, m2Values, order, params, nPoints, Sequence @@ numericOpts];
  CoordinateS0StabilityPublicationPlotFromData[
    data,
    s0Range,
    Sequence @@ FilterRules[{opts}, Options[CoordinateS0StabilityPublicationPlotFromData]]
  ]
];

Options[CoordinateS0StabilityPublicationPlotFromData] =
  Options[CoordinateS0StabilityPublicationPlot];

CoordinateS0StabilityPublicationPlotFromData[
  data_Association,
  s0Range : {_?NumericQ, _?NumericQ} : $BcCoordinateWangWindow["s0Range"],
  opts : OptionsPattern[]
] := Module[
  {styles, labels, yRange, plotRange},
  styles = CoordinatePlotStyles[Length[data]];
  labels = Row[{Superscript["M", 2], " = ", CoordinateLegendNumber[#], " ", Superscript["GeV", 2]}] & /@ Keys[data];
  yRange = CoordinateThetaYRange[Values[data][[All, All, 2]], OptionValue["YHalfWidth"], OptionValue["YPadFraction"]];
  plotRange = Replace[OptionValue[PlotRange], Automatic -> {s0Range, yRange}];
  <|
    "Data" -> data,
    "Plot" -> ListLinePlot[
      Values[data],
      Frame -> True,
      Axes -> False,
      FrameLabel -> {
        Row[{Subscript["s", 0], " (", Superscript["GeV", 2], ")"}],
        Superscript["\[Theta]", "\[Degree]"]
      },
      LabelStyle -> OptionValue[LabelStyle],
      BaseStyle -> OptionValue[BaseStyle],
      ImageSize -> OptionValue[ImageSize],
      ImagePadding -> {{75, 20}, {60, 20}},
      PlotStyle -> styles,
      PlotMarkers -> Automatic,
      PlotRange -> plotRange,
      GridLines -> Automatic,
      GridLinesStyle -> Directive[GrayLevel[0.85], Dashed],
      PlotLegends -> Placed[LineLegend[styles, labels, LegendMarkerSize -> 18], Right]
    ]
  |>
];

CoordinateNormalizeUncertaintyRanges[ranges_: <||>] := Which[
  AssociationQ[ranges],
    Join[$BcCoordinateDefaultUncertaintyRanges, ranges],
  ListQ[ranges],
    Join[$BcCoordinateDefaultUncertaintyRanges, Association[ranges]],
  True,
    $Failed
];

CoordinateRandomRangeValue[value_?NumericQ] := N[value];
CoordinateRandomRangeValue[range : {_?NumericQ, _?NumericQ}] := RandomReal[N[range]];
CoordinateRandomRangeValue[_] := $Failed;

CoordinateRandomParameterPoint[ranges_: <||>] := Module[
  {merged = CoordinateNormalizeUncertaintyRanges[ranges], sampled},
  If[merged === $Failed, Return[$Failed]];
  sampled = Association @ KeyValueMap[#1 -> CoordinateRandomRangeValue[#2] &, merged];
  If[MemberQ[Values[sampled], $Failed], $Failed, sampled]
];

CoordinateValidParameterPointQ[point_Association] := Module[
  {vals, mbv, mcv, g2v, g3v, m2v, s0v},
  vals = Lookup[point, {"mb", "mc", "G2", "G3", "M2", "s0"}, Missing["KeyAbsent"]];
  If[! VectorQ[vals, NumericQ], Return[False]];
  {mbv, mcv, g2v, g3v, m2v, s0v} = N[vals];
  mbv > 0 && mcv > 0 && g2v >= 0 && g3v >= 0 && m2v > 0 && s0v > (mbv + mcv)^2
];
CoordinateValidParameterPointQ[_] := False;

CoordinateRandomAcceptedParameterPoint[ranges_: <||>, maxAttempts_: 1000] := Module[
  {point = $Failed, attempts = 0},
  If[! IntegerQ[maxAttempts] || maxAttempts <= 0, Return[$Failed]];
  While[attempts < maxAttempts,
    attempts++;
    point = CoordinateRandomParameterPoint[ranges];
    If[AssociationQ[point] && CoordinateValidParameterPointQ[point], Return[point]]
  ];
  $Failed
];

CoordinateRealNumberQ[value_] :=
  NumericQ[value] && TrueQ[Chop[Im[N[value]]] == 0];

CoordinateRealNumber[value_] := Re[N[Chop[value]]];

CoordinateMonteCarloEvaluationOrder[order_String, includeG3_: False] := Module[
  {ord = ValidateCoordinateOrder[order]},
  If[ord === "totalLocal" && ! TrueQ[includeG3], "pertG2local", ord]
];

CoordinateMonteCarloEvaluationOrder[_, includeG3_: False] :=
  CoordinateMonteCarloEvaluationOrder["pert", includeG3];

Options[CoordinateMonteCarloMixingAngleSamples] = Join[
  Options[CoordinateNumericBorelPi],
  {
    "Seed" -> Automatic,
    "MaxAttempts" -> 1000,
    "Progress" -> False,
    "IncludeG3" -> False
  }
];

CoordinateMonteCarloMixingAngleSamples[
  n_Integer?Positive,
  ranges_: <||>,
  order_String : "pert",
  opts : OptionsPattern[]
] := Module[
  {merged = CoordinateNormalizeUncertaintyRanges[ranges], seed = OptionValue["Seed"],
   maxAttempts = OptionValue["MaxAttempts"], progress = OptionValue["Progress"],
   evalOrder = CoordinateMonteCarloEvaluationOrder[order, OptionValue["IncludeG3"]],
   numericOpts, printEvery, point, theta},
  If[merged === $Failed, Return[$Failed]];
  If[seed =!= Automatic, SeedRandom[seed]];
  numericOpts = FilterRules[{opts}, Options[CoordinateNumericBorelPi]];
  printEvery = Max[1, Floor[n/10]];
  DeleteCases[
    Table[
      If[TrueQ[progress] && Mod[i, printEvery] == 0, Print["Coordinate Monte Carlo sample ", i, "/", n]];
      point = CoordinateRandomAcceptedParameterPoint[merged, maxAttempts];
      If[point === $Failed, Return[$Failed]];
      theta = Quiet[
        CoordinateNumericMixingAngleDegrees[
          point["M2"], point["s0"], evalOrder, point, Sequence @@ numericOpts
        ]
      ];
      If[CoordinateRealNumberQ[theta],
        Join[
          <|"Index" -> i, "RequestedOrder" -> order, "Order" -> evalOrder|>,
          Association @ KeyValueMap[#1 -> N[#2] &, KeyTake[point, {"mb", "mc", "G2", "G3", "M2", "s0"}]],
          <|"Threshold" -> N[(point["mb"] + point["mc"])^2], "ThetaDeg" -> CoordinateRealNumber[theta]|>
        ],
        $Failed
      ],
      {i, n}
    ],
    $Failed
  ]
];

CoordinateMonteCarloMixingAngleValues[result_Association] /; KeyExistsQ[result, "Samples"] :=
  CoordinateMonteCarloMixingAngleValues[result["Samples"]];
CoordinateMonteCarloMixingAngleValues[samples_List] :=
  CoordinateRealNumber /@ Select[Lookup[samples, "ThetaDeg", {}], CoordinateRealNumberQ];

CoordinateMonteCarloMixingAngleGaussianSummary[result_Association] /; KeyExistsQ[result, "Samples"] :=
  CoordinateMonteCarloMixingAngleGaussianSummary[result["Samples"]];
CoordinateMonteCarloMixingAngleGaussianSummary[samples_List] := Module[
  {values = CoordinateMonteCarloMixingAngleValues[samples], count, mu, sigma, sampleSigma, q16, q50, q84},
  count = Length[values];
  If[count == 0, Return[<|"Count" -> 0, "MeanDeg" -> Missing["NoSamples"], "GaussianSigmaDeg" -> Missing["NoSamples"]|>]];
  mu = Mean[values];
  sigma = Sqrt[Mean[(values - mu)^2]];
  sampleSigma = If[count > 1, StandardDeviation[values], 0.0];
  {q16, q50, q84} = Quantile[values, {0.16, 0.50, 0.84}];
  <|
    "Count" -> count,
    "MeanDeg" -> N[mu],
    "GaussianSigmaDeg" -> N[sigma],
    "SampleSigmaDeg" -> N[sampleSigma],
    "MedianDeg" -> N[q50],
    "Quantile16Deg" -> N[q16],
    "Quantile84Deg" -> N[q84],
    "MinDeg" -> N[Min[values]],
    "MaxDeg" -> N[Max[values]],
    "GaussianFit" -> NormalDistribution[N[mu], N[sigma]]
  |>
];

Options[CoordinateMonteCarloMixingAngleUncertainty] =
  Options[CoordinateMonteCarloMixingAngleSamples];

CoordinateMonteCarloMixingAngleUncertainty[
  n_Integer?Positive,
  ranges_: <||>,
  order_String : "pert",
  opts : OptionsPattern[]
] := Module[
  {evalOrder = CoordinateMonteCarloEvaluationOrder[order, OptionValue["IncludeG3"]],
   samples},
  samples = CoordinateMonteCarloMixingAngleSamples[n, ranges, order, opts];
  If[samples === $Failed, Return[$Failed]];
  <|
    "RequestedOrder" -> order,
    "Order" -> evalOrder,
    "CoordinateMonteCarloEngine" -> "Independent coordinate engine",
    "CoordinateIndependence" -> If[
      CoordinateIndependentOrderAvailableQ[evalOrder],
      "Independent coordinate-space result.",
      "Diagnostic local-condensate bridge only; not a coordinate-paper-final full OPE."
    ],
    "RequestedSamples" -> n,
    "AcceptedSamples" -> Length[samples],
    "FailedSamples" -> n - Length[samples],
    "Ranges" -> CoordinateNormalizeUncertaintyRanges[ranges],
    "Samples" -> samples,
    "Summary" -> CoordinateMonteCarloMixingAngleGaussianSummary[samples],
    "Diagnostic" -> If[
      Length[samples] == 0,
      "No accepted numeric theta values for order " <> ToString[evalOrder, InputForm] <> ". First test CoordinateNumericMixingAngleDegrees[8, 54, \"pert\"]; use non-perturbative coordinate orders only after their independent reductions are implemented.",
      "OK"
    ]
  |>
];

CoordinateMonteCarloMixingAngleDataset[result_Association] /; KeyExistsQ[result, "Samples"] :=
  Dataset[result["Samples"]];

CoordinateMonteCarloSampleTable[result_Association] /; KeyExistsQ[result, "Samples"] := Module[
  {samples = result["Samples"], keys},
  If[samples === {}, Return[{}]];
  keys = Union[Flatten[Keys /@ samples]];
  Prepend[Lookup[#, keys, ""] & /@ samples, keys]
];

CoordinateExportMonteCarloMixingAngleSamples[
  result_Association,
  file_String : "BcMixingCoordinateMonteCarloSamples.csv"
] :=
  CoordinateWriteCSV[file, CoordinateMonteCarloSampleTable[result]];

CoordinateExportMonteCarloMixingAngleSummary[
  result_Association,
  file_String : "BcMixingCoordinateMonteCarloSummary.csv"
] := Module[
  {summary = result["Summary"]},
  CoordinateWriteCSV[
    file,
    Prepend[KeyValueMap[{#1, ToString[#2, InputForm]} &, summary], {"Quantity", "Value"}]
  ]
];

Options[CoordinateMonteCarloMixingAnglePublicationHistogram] = {
  "HistogramColor" -> RGBColor[0.22, 0.39, 0.62],
  "FitColor" -> RGBColor[0.76, 0.12, 0.10],
  "MeanColor" -> GrayLevel[0.15],
  "ShowMeanLine" -> True,
  ImageSize -> 540,
  LabelStyle -> Directive[Black, 14, FontFamily -> "Times"],
  BaseStyle -> {FontFamily -> "Times"},
  PlotRange -> All
};

CoordinateMonteCarloMixingAnglePublicationHistogram[
  result_,
  bins_: Automatic,
  opts : OptionsPattern[]
] := Module[
  {values = CoordinateMonteCarloMixingAngleValues[result], summary, mu, sigma, x,
   xrange, hist, fit, shown, legend, histColor = OptionValue["HistogramColor"],
   fitColor = OptionValue["FitColor"], meanColor = OptionValue["MeanColor"]},
  If[
    values === {},
    Return[
      Style[
        "No accepted coordinate Monte Carlo samples. Check coordUncertainty[\"Diagnostic\"] and try coordinateMonteCarloOrder = \"pert\".",
        Darker[Red]
      ]
    ]
  ];
  summary = CoordinateMonteCarloMixingAngleGaussianSummary[result];
  mu = summary["MeanDeg"];
  sigma = summary["GaussianSigmaDeg"];
  xrange = MinMax[values];
  If[xrange[[1]] == xrange[[2]], xrange = xrange + {-0.5, 0.5}];
  hist = Histogram[
    values,
    bins,
    "PDF",
    Frame -> True,
    Axes -> False,
    FrameLabel -> {Superscript["\[Theta]", "\[Degree]"], "Probability density"},
    LabelStyle -> OptionValue[LabelStyle],
    BaseStyle -> OptionValue[BaseStyle],
    ImageSize -> OptionValue[ImageSize],
    ImagePadding -> {{75, 20}, {60, 20}},
    PlotLabel -> None,
    PlotRange -> OptionValue[PlotRange],
    ChartStyle -> Directive[histColor, Opacity[0.72], EdgeForm[Directive[GrayLevel[0.25], Thin]]]
  ];
  fit = If[NumericQ[sigma] && sigma > 0,
    Plot[
      PDF[NormalDistribution[mu, sigma], x],
      {x, xrange[[1]], xrange[[2]]},
      PlotStyle -> Directive[fitColor, Thick],
      PlotRange -> OptionValue[PlotRange]
    ],
    Nothing
  ];
  shown = Show[
    Sequence @@ DeleteCases[{hist, fit}, Nothing],
    PlotRange -> OptionValue[PlotRange],
    GridLines -> If[TrueQ[OptionValue["ShowMeanLine"]], {{mu}, None}, None],
    GridLinesStyle -> Directive[meanColor, Dashed, Thick]
  ];
  legend = Column[
    {
      SwatchLegend[{histColor}, {"Coordinate samples"}],
      If[NumericQ[sigma] && sigma > 0,
        LineLegend[
          {Directive[fitColor, Thick], Directive[meanColor, Dashed, Thick]},
          {
            Row[{"Gaussian fit: \[Mu] = ", NumberForm[mu, {6, 3}], "\[Degree]"}],
            Row[{"Width: \[Sigma] = ", NumberForm[sigma, {5, 3}], "\[Degree]"}]
          }
        ],
        LineLegend[{Directive[meanColor, Dashed, Thick]}, {Row[{"Mean: ", NumberForm[mu, {6, 3}], "\[Degree]"}]}]
      ]
    },
    Spacings -> 0.25
  ];
  Legended[shown, Placed[legend, Right]]
];

CoordinateSpectralDensityDerivationNote[] := Column[
  {
    "Coordinate-space v1 uses the free heavy-quark propagator",
    TraditionalForm[
      HoldForm[
        S_Q[x] == m_Q^2/(2 Pi)^2 (
          I \[Gamma].x BesselK[2, m_Q Sqrt[-x^2]]/(-x^2) +
          BesselK[1, m_Q Sqrt[-x^2]]/Sqrt[-x^2]
        )
      ]
    ],
    "The Fourier transform reduces to radial integrals with one J Bessel and two K Bessel functions.",
    "The spectral density installed here is the perturbative result after the Huang-Liu/Azizi Bessel-Schwinger reduction.",
    "Local single-line G2/G3 condensate checks are available through the reduced Borel bridge after loading BcMixingMomentum.wl.",
    "The independent full coordinate-space G2 result and single-line G3 truncation are implemented in BcMixingCoordinateOPE.wl."
  }
];

Print["Loaded BcMixingCoordinate.wl. Run CoordinateCheckEnvironment[] for setup information."];

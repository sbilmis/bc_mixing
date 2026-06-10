(* ::Package:: *)

(*
  BcMixingCoordinate.wl

  Coordinate-space cross-check for the B_c axial-vector mixing calculation.

  Scope of this first coordinate-space implementation:
    - Use the x-space heavy-quark propagator with modified Bessel functions.
    - Build the coordinate-space trace kernels for AA, AB, BA and BB.
    - Evaluate the perturbative spectral densities obtained after the
      Bessel/Schwinger reduction of the coordinate-space expressions.
    - Provide the same numerical mixing-angle interface as the momentum-space
      file for the perturbative OPE.

  Important:
    The dimension-4 and dimension-6 condensate propagator kernels are recorded
    below as extension points, but the numerical coordinate-space Borel moments
    are perturbative in v1.  The condensate pieces should be added only after
    the perturbative coordinate-space result reproduces the momentum-space
    calculation.

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
  "The full coordinate-space G2 term needs the open-field S^(G) S^(G) contraction. Use G2c, G2b or G2local for the local single-line kernels until G2gg is derived.";
BcMixingCoordinate::needreduction =
  "The reduced coordinate-space local-condensate integration needs the Feynman/Schwinger reduction helpers from BcMixingMomentum.wl. Load BcMixingMomentum.wl first, then reload BcMixingCoordinate.wl.";

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
  mb, mc, M2, s0, s, G2, G3, k, p, xv, mu, nu, al, be,
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
  "G3c", "G3b", "G3local",
  "totalLocal"
};
$BcCoordinateNumericalOrders = {"pert"};
$BcCoordinateReducedLocalOrders = {
  "G2c", "G2b", "G2local",
  "G3c", "G3b", "G3local",
  "pertG2local", "totalLocal"
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

$BcCoordinateWangWindow = <|
  "M2Range" -> {7.0, 9.0},
  "M2Values" -> {7.0, 8.0, 9.0},
  "s0Central" -> 54.0,
  "s0Range" -> {53.0, 55.0},
  "s0Values" -> {53.0, 54.0, 55.0}
|>;

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
  "ReducedLocalIntegrationAvailable" -> CoordinateReducedIntegrationAvailableQ[],
  "TensorCurrentScale" -> CoordinateTensorCurrentScale[],
  "Threshold" -> CoordinateThreshold[],
  "DefaultParameters" -> $BcCoordinateDefaultParameters,
  "WangWindow" -> $BcCoordinateWangWindow
|>;

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
   lims, integrand},
  Which[
    ord === "pert",
      Return[CoordinateNumericBorelPi[ch, "pert", m2Val, continuumVal, params, opts]],
    ord === "pertG2local" || ord === "totalLocal",
      Return[
        Total[
          CoordinateNumericBorelPiReduced[ch, #, m2Val, continuumVal, params, opts] & /@
            CoordinateReducedOrderPieces[ord]
        ]
      ],
    MemberQ[{"G2local", "G3local"}, ord],
      Return[
        Total[
          CoordinateNumericBorelPiReduced[ch, #, m2Val, continuumVal, params, opts] & /@
            CoordinateReducedOrderPieces[ord]
        ]
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
      ToExpression["ParameterRules"][params] /.
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
  params_: $BcCoordinateDefaultParameters,
  opts : OptionsPattern[CoordinateNumericBorelPi]
] := AssociationMap[
  CoordinateNumericBorelPi[#, "pert", m2Val, continuumVal, params, opts] &,
  {"AA", "AB", "BB"}
];

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
  params_: $BcCoordinateDefaultParameters,
  opts : OptionsPattern[CoordinateNumericBorelPi]
] :=
  CoordinateMixingAngleGrid[
    $BcCoordinateWangWindow["M2Values"],
    $BcCoordinateWangWindow["s0Values"],
    params,
    opts
  ];

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
    "Condensate kernels are present as CoordinateHeavyPropagatorG2Kernel and CoordinateHeavyPropagatorG3Kernel, but their Borel/spectral reduction is not enabled in v1."
  }
];

Print["Loaded BcMixingCoordinate.wl. Run CoordinateCheckEnvironment[] for setup information."];

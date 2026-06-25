(* ::Package:: *)

(*
  BcMixingCoordinateDirect.wl

  Direct perturbative cross-check for B_c axial-vector mixing without using
  the Azizi et al. Borel-continuum reduction machinery.

  Scope:
    - Perturbative part only.
    - Exposes the coordinate-space support structure
          delta[s - sbar[x]] -> theta[s - (mb + mc)^2] -> x_+(s), x_-(s).
    - Uses the equivalent inverse-K-transform/two-body-cut result for the
      discontinuity of two massive propagators.
    - Provides a numerical mixing-angle interface that can be compared with
      BcMixingCoordinate.wl and BcMixingMomentum.wl.

  Literature guide:
    - Z.-W. Huang and J. Liu, arXiv:1205.3026:
      direct coordinate-space spectral densities from Bessel/hypergeometric
      functions, using both simple integral representations and epsilon
      expansion of hypergeometric functions.
    - S. Groote, J. G. Koerner and A. A. Pivovarov,
      Phys. Lett. B443 (1998) 269, arXiv:hep-ph/9805224:
      spectral densities from inverse K-transforms of products of massive
      coordinate-space propagators.
    - S. Groote, J. G. Koerner and A. A. Pivovarov,
      Annals Phys. 322 (2007) 2374, arXiv:hep-ph/0506286:
      review of configuration-space sunrise-type topologies.

  Important caveat:
    This file does not yet perform the literal oscillatory radial integral
        Integrate[x^(u-1) BesselJ[v, Q x] BesselK[a, mc x] BesselK[b, mb x], ...]
    and then take its branch cut.  Instead, for the perturbative two-point
    function, it uses the known direct discontinuity of the product of two
    massive propagators.  This is the perturbative inverse-K-transform result.
    The condensate terms are not included here because they generate derivative
    delta functions and require separate analytic bookkeeping.
*)

ClearAll["Global`BcDirect`*"];

Quiet[
  Check[
    Needs["FeynCalc`"],
    $BcDirectFeynCalcLoaded = False,
    $BcDirectFeynCalcLoaded = False
  ]
];

If[! ValueQ[$BcDirectFeynCalcLoaded], $BcDirectFeynCalcLoaded = True];
If[NameQ["FeynCalc`FCSetDiracGammaScheme"],
  Quiet[FCSetDiracGammaScheme["NDR"]]
];

ClearAll[
  mb, mc, M2, s0, s, x, xi, k, p, mu, nu, G2, G3,
  DirectMergeParameters, DirectParameterRules,
  DirectKallenLambda, DirectThreshold, DirectSbar,
  DirectXMinus, DirectXPlus, DirectXLimits, DirectSupportQ,
  DirectDeltaJacobian, DirectDeltaReductionFormula,
  DirectDeltaReduceNumeric,
  DirectBorelDeltaDerivativeIntegrand,
  DirectBorelDeltaDerivativeMoment,
  DirectDeltaDerivativeExamples,
  DirectCondensateReductionAvailableQ,
  DirectCondensatePoleCoefficients,
  DirectCondensateDeltaWeights,
  DirectCondensateBorelIntegrandFromWeights,
  DirectNumericCondensateBorelPi,
  DirectCondensateComparisonToMomentum,
  DirectCondensateWeightSummary,
  DirectTwoBodyCutMeasure,
  DirectOnShellKDotP, DirectTensorCurrentScale,
  DirectTensorCurrentNormalization, DirectCurrentTensorPower,
  DirectPerturbativeNumerator, DirectPerturbativeSpectralDensity,
  DirectPerturbativeSpectralDensityWithSupport,
  DirectBorelPi, DirectNumericBorelPi,
  DirectNormalizeMixingAngle, DirectNormalizeMixingAngleDegrees,
  DirectNumericMixingAngle, DirectNumericMixingAngleDegrees,
  DirectCompareToCoordinate, DirectCompareToMomentum,
  DirectPerturbativeCheck, DirectLiteratureNote,
  DirectDeltaSupportNote, DirectEnvironment
];

$BcDirectNc = 3;
$BcDirectChannels = <|
  "AA" -> {"A", "A"},
  "AB" -> {"A", "B"},
  "BA" -> {"B", "A"},
  "BB" -> {"B", "B"}
|>;

$BcDirectDefaultParameters = <|
  "mb" -> 4.18,
  "mc" -> 1.27,
  "G2" -> 4 Pi^2 0.012,
  "G3" -> 0.57,
  "M2" -> 8.0,
  "s0" -> 54.0
|>;

$BcDirectDefaultUncertaintyRanges = <|
  "mb" -> {4.18 - 0.03, 4.18 + 0.03},
  "mc" -> {1.27 - 0.02, 1.27 + 0.02},
  "G2" -> {4 Pi^2 (0.012 - 0.004), 4 Pi^2 (0.012 + 0.004)},
  "G3" -> {0.57 - 0.29, 0.57 + 0.29},
  "M2" -> {7.0, 9.0},
  "s0" -> {53.0, 55.0}
|>;

$BcDirectWangWindow = <|
  "M2Range" -> {7.0, 9.0},
  "M2Values" -> {7.0, 8.0, 9.0},
  "s0Central" -> 54.0,
  "s0Range" -> {53.0, 55.0},
  "s0Values" -> {53.0, 54.0, 55.0}
|>;

$BcDirectMomentumComparableThetaRange = {42.30709723493363, 44.30709723493363};

$BcDirectAssumptions =
  Element[{mb, mc, M2, s0, s, G2, G3}, Reals] &&
  mb > 0 && mc > 0 && M2 > 0 && s0 > (mb + mc)^2 &&
  s > (mb + mc)^2 && G2 >= 0 && G3 >= 0;

DirectMergeParameters[assoc_: <||>] :=
  Join[$BcDirectDefaultParameters, assoc];

DirectParameterRules[assoc_: $BcDirectDefaultParameters] := Module[
  {merged = DirectMergeParameters[assoc]},
  {
    mb -> merged["mb"],
    mc -> merged["mc"],
    G2 -> merged["G2"],
    G3 -> merged["G3"],
    M2 -> merged["M2"],
    s0 -> merged["s0"]
  }
];

DirectEnvironment[] := <|
  "FeynCalcLoaded" -> $BcDirectFeynCalcLoaded,
  "Nc" -> $BcDirectNc,
  "Channels" -> Keys[$BcDirectChannels],
  "DefaultParameters" -> $BcDirectDefaultParameters,
  "Scope" -> "perturbative inverse-K/two-body-cut check only",
  "UsesAziziBorelReduction" -> False,
  "IndependentNow" -> "pert",
  "IndependentPendingOrders" -> {"G2full", "G3full", "totalFull"}
|>;

DirectKallenLambda[ss_, m1_: mb, m2_: mc] :=
  ss^2 + m1^4 + m2^4 - 2 ss m1^2 - 2 ss m2^2 - 2 m1^2 m2^2;

DirectThreshold[] := (mb + mc)^2;

DirectSbar[xx_: x] :=
  (mc^2 xx + mb^2 (1 - xx))/(xx (1 - xx));

DirectXMinus[ss_: s] :=
  (ss + mb^2 - mc^2 - Sqrt[DirectKallenLambda[ss]])/(2 ss);

DirectXPlus[ss_: s] :=
  (ss + mb^2 - mc^2 + Sqrt[DirectKallenLambda[ss]])/(2 ss);

DirectXLimits[ss_: s] := {DirectXMinus[ss], DirectXPlus[ss]};

DirectSupportQ[ss_?NumericQ, params_: $BcDirectDefaultParameters] := Module[
  {rules = DirectParameterRules[params]},
  ss >= N[DirectThreshold[] /. rules]
];

DirectDeltaJacobian[xx_: x] :=
  D[DirectSbar[xx], xx] // Together // Simplify;

DirectDeltaReductionFormula[weight_: 1, var_: x, ss_: s] := Module[
  {sbar, roots, jac},
  sbar = DirectSbar[var];
  roots = DirectXLimits[ss];
  jac = D[sbar, var];
  <|
    "Sbar" -> sbar,
    "Roots" -> Thread[var -> roots],
    "Jacobian" -> jac,
    "FormalReduction" ->
      HeavisideTheta[ss - DirectThreshold[]] Total[
        (weight/Abs[jac]) /. Thread[var -> roots]
      ]
  |>
];

DirectDeltaReduceNumeric[
  weightFunction_,
  ss_?NumericQ,
  params_: $BcDirectDefaultParameters
] := Module[
  {rules, roots, jac, threshold},
  rules = DirectParameterRules[params];
  threshold = N[DirectThreshold[] /. rules];
  If[ss < threshold, Return[0.]];
  roots = N[DirectXLimits[ss] /. rules];
  jac[xx_?NumericQ] := N[DirectDeltaJacobian[x] /. rules /. x -> xx];
  Total[(weightFunction[#]/Abs[jac[#]]) & /@ roots]
];

DirectBorelDeltaDerivativeIntegrand[
  weight_,
  order_Integer : 0,
  var_: x,
  ss_: s,
  m2_: M2
] := Module[
  {sbar = DirectSbar[var], test},
  test = Exp[-ss/m2] weight;
  ((-1)^order D[test, {ss, order}] /. ss -> sbar) //
    Together // Simplify
];

DirectBorelDeltaDerivativeMoment[
  weight_,
  order_Integer : 0,
  m2_: M2,
  continuum_: s0,
  var_: x
] := Module[
  {integrand},
  integrand = DirectBorelDeltaDerivativeIntegrand[weight, order, var, s, m2];
  Integrate[
    integrand,
    {var, DirectXMinus[continuum], DirectXPlus[continuum]},
    Assumptions -> $BcDirectAssumptions
  ]
];

DirectDeltaDerivativeExamples[] := <|
  "Convention" -> "delta^(n)[s - sbar[x]]",
  "Sbar" -> DirectSbar[x],
  "BorelDelta0WeightF" ->
    DirectBorelDeltaDerivativeIntegrand[F[x], 0, x, s, M2],
  "BorelDelta1WeightF" ->
    DirectBorelDeltaDerivativeIntegrand[F[x], 1, x, s, M2],
  "BorelDelta2WeightF" ->
    DirectBorelDeltaDerivativeIntegrand[F[x], 2, x, s, M2],
  "BorelDelta1WeightW" ->
    DirectBorelDeltaDerivativeIntegrand[W[s, x], 1, x, s, M2],
  "BorelDelta2WeightW" ->
    DirectBorelDeltaDerivativeIntegrand[W[s, x], 2, x, s, M2],
  "OppositeArgumentSign" ->
    "For delta^(n)[sbar[x] - s], multiply the delta^(n)[s - sbar[x]] result by (-1)^n."
|>;

DirectCondensateReductionAvailableQ[] :=
  AllTrue[
    {
      "SimplexAmplitude",
      "$BcMixingDirectBorelPhase",
      "NumericBorelPi"
    },
    NameQ
  ];

DirectCondensatePoleCoefficients[
  channel_String,
  condensateOrder_String,
  var_: xi,
  maxPower_Integer : 12
] := DirectCondensatePoleCoefficients[channel, condensateOrder, var, maxPower] = Module[
  {q2, tau, sb, phase, simplex, transformed, coeffs},
  If[! DirectCondensateReductionAvailableQ[], Return[$Failed]];
  sb = DirectSbar[var];
  phase = ToExpression["$BcMixingDirectBorelPhase"];
  simplex = ToExpression["SimplexAmplitude"][channel, condensateOrder, var];
  transformed =
    phase simplex /. s -> -q2 /. q2 -> tau - sb;
  transformed = Apart[Together[transformed], tau] // Expand;
  coeffs = Association@Table[
    n -> (Coefficient[transformed, tau, -n] // Together // Simplify),
    {n, 1, maxPower}
  ];
  Select[coeffs, # =!= 0 &]
];

DirectCondensateDeltaWeights[
  channel_String,
  condensateOrder_String,
  var_: xi,
  maxPower_Integer : 12
] := Module[
  {coeffs},
  coeffs = DirectCondensatePoleCoefficients[channel, condensateOrder, var, maxPower];
  If[coeffs === $Failed, Return[$Failed]];
  Association @ KeyValueMap[
    (#1 - 1) -> (#2/Factorial[#1 - 1] // Together // Simplify) &,
    coeffs
  ]
];

DirectCondensateBorelIntegrandFromWeights[
  channel_String,
  condensateOrder_String,
  var_: xi,
  m2_: M2,
  maxPower_Integer : 12
] := Module[
  {weights},
  weights = DirectCondensateDeltaWeights[channel, condensateOrder, var, maxPower];
  If[weights === $Failed, Return[$Failed]];
  Total[
    KeyValueMap[
      DirectBorelDeltaDerivativeIntegrand[#2, #1, var, s, m2] &,
      weights
    ]
  ] // Together // Simplify
];

Options[DirectNumericCondensateBorelPi] = Options[NIntegrate];

DirectNumericCondensateBorelPi[
  channel_String,
  condensateOrder_String,
  m2Val_?NumericQ,
  continuumVal_?NumericQ,
  params_: $BcDirectDefaultParameters,
  opts : OptionsPattern[]
] := Module[
  {lims, integrand},
  If[! DirectCondensateReductionAvailableQ[], Return[$Failed]];
  lims = N[DirectXLimits[continuumVal] /. DirectParameterRules[params]];
  If[! VectorQ[lims, NumericQ], Return[$Failed]];
  integrand = Evaluate[
    DirectCondensateBorelIntegrandFromWeights[channel, condensateOrder, xi, M2] /.
      DeleteCases[DirectParameterRules[params], (M2 -> _) | (s0 -> _)] /.
      M2 -> m2Val
  ];
  NIntegrate[
    integrand,
    {xi, Min @@ lims, Max @@ lims},
    opts
  ]
];

DirectCondensateComparisonToMomentum[
  m2Val_?NumericQ,
  continuumVal_?NumericQ,
  condensateOrder_String : "G2",
  params_: $BcDirectDefaultParameters,
  opts : OptionsPattern[DirectNumericCondensateBorelPi]
] := Module[
  {direct, momentum},
  If[! DirectCondensateReductionAvailableQ[], Return[$Failed]];
  AssociationMap[
    Function[
      ch,
      direct = DirectNumericCondensateBorelPi[ch, condensateOrder, m2Val, continuumVal, params, opts];
      momentum = ToExpression["NumericBorelPi"][ch, condensateOrder, m2Val, continuumVal, params, opts];
      <|
        "DirectDeltaDerivative" -> direct,
        "MomentumDirectBorel" -> momentum,
        "Difference" -> direct - momentum
      |>
    ],
    {"AA", "AB", "BB"}
  ]
];

DirectCondensateWeightSummary[
  channel_String,
  condensateOrder_String,
  var_: xi
] := Module[
  {weights = DirectCondensateDeltaWeights[channel, condensateOrder, var]},
  If[weights === $Failed, Return[$Failed]];
  <|
    "Channel" -> channel,
    "Order" -> condensateOrder,
    "DeltaDerivativeOrders" -> Keys[weights],
    "Weights" -> weights
  |>
];

DirectTwoBodyCutMeasure[ss_: s] :=
  Sqrt[DirectKallenLambda[ss]]/(16 Pi^2 ss);

DirectOnShellKDotP[ss_: s] :=
  (ss + mc^2 - mb^2)/2;

DirectTensorCurrentScale[] := mb + mc;
DirectTensorCurrentNormalization[] := 1/DirectTensorCurrentScale[];

DirectCurrentTensorPower[channel_String] :=
  Count[$BcDirectChannels[channel], "B"];

DirectPerturbativeNumerator[channel_String, ss_: s] := Module[
  {kp = DirectOnShellKDotP[ss], k2 = mc^2},
  Switch[
    channel,
    "AA",
      -4/ss (2 kp^2 + (3 mb mc + k2) ss - 3 kp ss),
    "AB" | "BA",
      12 (-(mb + mc) kp + mc ss),
    "BB",
      -4 (4 kp^2 + (3 mb mc - k2) ss - 3 kp ss),
    _,
      Message[DirectPerturbativeNumerator::badchannel, channel];
      $Failed
  ] // Simplify
];

DirectPerturbativeSpectralDensity[channel_String, ss_: s] := Module[
  {power},
  If[! KeyExistsQ[$BcDirectChannels, channel], Return[$Failed]];
  power = DirectCurrentTensorPower[channel];
  $BcDirectNc DirectTwoBodyCutMeasure[ss]
    DirectPerturbativeNumerator[channel, ss]
    DirectTensorCurrentScale[]^-power // Simplify
];

DirectPerturbativeSpectralDensityWithSupport[channel_String, ss_: s] :=
  HeavisideTheta[ss - DirectThreshold[]]
    DirectPerturbativeSpectralDensity[channel, ss];

DirectBorelPi[channel_String, m2_: M2, continuum_: s0] := Module[
  {var},
  Integrate[
    Exp[-var/m2] DirectPerturbativeSpectralDensity[channel, var],
    {var, DirectThreshold[], continuum},
    Assumptions -> $BcDirectAssumptions
  ]
];

Options[DirectNumericBorelPi] = Options[NIntegrate];

DirectNumericBorelPi[
  channel_String,
  m2Val_?NumericQ,
  continuumVal_?NumericQ,
  params_: $BcDirectDefaultParameters,
  opts : OptionsPattern[]
] := Module[
  {rules, lower, density, var},
  rules = Join[DirectParameterRules[params], {M2 -> m2Val, s0 -> continuumVal}];
  lower = N[DirectThreshold[] /. rules];
  If[continuumVal <= lower, Return[0.]];
  density = Evaluate[DirectPerturbativeSpectralDensity[channel, var] /. rules];
  NIntegrate[
    Evaluate[Exp[-var/m2Val] density],
    {var, lower, continuumVal},
    opts
  ]
];

DirectNormalizeMixingAngle[theta_?NumericQ] :=
  theta - (Pi/2) Round[theta/(Pi/2)];

DirectNormalizeMixingAngleDegrees[thetaDeg_?NumericQ] :=
  thetaDeg - 90 Round[thetaDeg/90];

DirectNumericMixingAngle[
  m2Val_?NumericQ,
  continuumVal_?NumericQ,
  params_: $BcDirectDefaultParameters,
  opts : OptionsPattern[DirectNumericBorelPi]
] := Module[
  {aa, ab, bb},
  aa = DirectNumericBorelPi["AA", m2Val, continuumVal, params, opts];
  ab = DirectNumericBorelPi["AB", m2Val, continuumVal, params, opts];
  bb = DirectNumericBorelPi["BB", m2Val, continuumVal, params, opts];
  DirectNormalizeMixingAngle[1/2 ArcTan[aa - bb, -2 ab]]
];

DirectNumericMixingAngleDegrees[
  m2Val_?NumericQ,
  continuumVal_?NumericQ,
  params_: $BcDirectDefaultParameters,
  opts : OptionsPattern[DirectNumericBorelPi]
] :=
  DirectNormalizeMixingAngleDegrees[
    N[180/Pi DirectNumericMixingAngle[m2Val, continuumVal, params, opts]]
  ];

DirectCompareToCoordinate[
  m2Val_?NumericQ,
  continuumVal_?NumericQ,
  params_: $BcDirectDefaultParameters,
  opts : OptionsPattern[DirectNumericBorelPi]
] := Module[
  {direct, coord},
  direct = DirectNumericMixingAngleDegrees[m2Val, continuumVal, params, opts];
  If[! NameQ["CoordinateNumericMixingAngleDegrees"],
    Return[<|
      "DirectPertDeg" -> direct,
      "CoordinatePertDeg" -> Missing["Load BcMixingCoordinate.wl to compare"],
      "DifferenceDeg" -> Missing["NotAvailable"]
    |>]
  ];
  coord = ToExpression["CoordinateNumericMixingAngleDegrees"][
    m2Val, continuumVal, "pert",
    KeyDrop[DirectMergeParameters[params], {}],
    opts
  ];
  <|
    "DirectPertDeg" -> direct,
    "CoordinatePertDeg" -> coord,
    "DifferenceDeg" -> direct - coord
  |>
];

DirectCompareToMomentum[
  m2Val_?NumericQ,
  continuumVal_?NumericQ,
  params_: $BcDirectDefaultParameters,
  opts : OptionsPattern[DirectNumericBorelPi]
] := Module[
  {direct, mom},
  direct = DirectNumericMixingAngleDegrees[m2Val, continuumVal, params, opts];
  If[! NameQ["NumericMixingAngleDegrees"],
    Return[<|
      "DirectPertDeg" -> direct,
      "MomentumPertDeg" -> Missing["Load BcMixingMomentum.wl to compare"],
      "DifferenceDeg" -> Missing["NotAvailable"]
    |>]
  ];
  mom = ToExpression["NumericMixingAngleDegrees"][
    m2Val, continuumVal, "pert",
    KeyDrop[DirectMergeParameters[params], {}],
    opts
  ];
  <|
    "DirectPertDeg" -> direct,
    "MomentumPertDeg" -> mom,
    "DifferenceDeg" -> direct - mom
  |>
];

(* ---------------------------------------------------------------------- *)
(* Direct-coordinate tables, stability plots and uncertainty analysis       *)
(* ---------------------------------------------------------------------- *)

DirectOPESummary[
  m2Val_?NumericQ,
  continuumVal_?NumericQ,
  params_: $BcDirectDefaultParameters,
  opts : OptionsPattern[DirectNumericBorelPi]
] := AssociationMap[
  <|"pert" -> DirectNumericBorelPi[#, m2Val, continuumVal, params, opts]|> &,
  {"AA", "AB", "BB"}
];

DirectMixingAngleSummary[
  m2Val_?NumericQ,
  continuumVal_?NumericQ,
  params_: $BcDirectDefaultParameters,
  opts : OptionsPattern[DirectNumericBorelPi]
] := <|
  "M2" -> m2Val,
  "s0" -> continuumVal,
  "ThetaPertDeg" -> DirectNumericMixingAngleDegrees[m2Val, continuumVal, params, opts]
|>;

DirectCompareAll[
  m2Val_?NumericQ,
  continuumVal_?NumericQ,
  params_: $BcDirectDefaultParameters,
  opts : OptionsPattern[DirectNumericBorelPi]
] := <|
  "Direct" -> DirectMixingAngleSummary[m2Val, continuumVal, params, opts],
  "CoordinateComparison" -> DirectCompareToCoordinate[m2Val, continuumVal, params, opts],
  "MomentumComparison" -> DirectCompareToMomentum[m2Val, continuumVal, params, opts]
|>;

DirectPlotStyles[n_Integer?Positive] :=
  Directive[AbsoluteThickness[2.2], #] & /@ ColorData[97, "ColorList"][[1 ;; n]];

DirectThetaYRange[values_, halfWidth_: 1.0, padFraction_: 0.20] := Module[
  {flat = Flatten[N[values]], finite, center, span, pad},
  If[! NumericQ[halfWidth] || ! NumericQ[padFraction], Return[Automatic]];
  finite = Select[flat, NumericQ[#] && TrueQ[Abs[#] < Infinity] &];
  If[finite === {}, Return[Automatic]];
  center = Mean[MinMax[finite]];
  span = Max[Max[finite] - Min[finite], 2 halfWidth];
  pad = padFraction span;
  center + {-span/2 - pad, span/2 + pad}
];

DirectLegendNumber[value_?NumericQ] := If[
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

DirectM2StabilityData[
  m2Range : {_?NumericQ, _?NumericQ} : $BcDirectWangWindow["M2Range"],
  s0Values_List : $BcDirectWangWindow["s0Values"],
  params_: $BcDirectDefaultParameters,
  nPoints_Integer : 25,
  opts : OptionsPattern[DirectNumericBorelPi]
] := Module[
  {m2Values = N[Subdivide[m2Range[[1]], m2Range[[2]], Max[1, nPoints - 1]]]},
  Association @ Table[
    s0v -> Table[
      {m2v, DirectNumericMixingAngleDegrees[m2v, s0v, params, opts]},
      {m2v, m2Values}
    ],
    {s0v, N[s0Values]}
  ]
];

DirectS0StabilityData[
  s0Range : {_?NumericQ, _?NumericQ} : $BcDirectWangWindow["s0Range"],
  m2Values_List : $BcDirectWangWindow["M2Values"],
  params_: $BcDirectDefaultParameters,
  nPoints_Integer : 25,
  opts : OptionsPattern[DirectNumericBorelPi]
] := Module[
  {s0Values = N[Subdivide[s0Range[[1]], s0Range[[2]], Max[1, nPoints - 1]]]},
  Association @ Table[
    m2v -> Table[
      {s0v, DirectNumericMixingAngleDegrees[m2v, s0v, params, opts]},
      {s0v, s0Values}
    ],
    {m2v, N[m2Values]}
  ]
];

DirectCSVField[value_?NumericQ] := ToString[N[value], InputForm];
DirectCSVField[value_String] := Module[
  {text = value},
  If[StringContainsQ[text, {",", "\"", "\n", "\r"}],
    "\"" <> StringReplace[text, "\"" -> "\"\""] <> "\"",
    text
  ]
];
DirectCSVField[value_] := DirectCSVField[ToString[value, InputForm]];

DirectWriteCSV[file_String, table_List] := Module[
  {stream},
  stream = OpenWrite[file, CharacterEncoding -> "UTF8"];
  WriteString[
    stream,
    StringRiffle[StringRiffle[DirectCSVField /@ #, ","] & /@ table, "\n"] <> "\n"
  ];
  Close[stream];
  file
];

DirectStabilityDataCSVTable[data_Association, xLabel_String : "x"] := Module[
  {rows},
  rows = Flatten[
    KeyValueMap[
      Function[{fixed, pts}, ({fixed, #[[1]], #[[2]]} & /@ pts)],
      data
    ],
    1
  ];
  Prepend[rows, {"FixedParameter", xLabel, "ThetaDeg"}]
];

DirectExportStabilityDataCSV[data_Association, file_String, xLabel_String : "x"] :=
  DirectWriteCSV[file, DirectStabilityDataCSVTable[data, xLabel]];

Options[DirectM2StabilityPublicationPlot] = Join[
  Options[DirectNumericBorelPi],
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

DirectM2StabilityPublicationPlot[
  m2Range : {_?NumericQ, _?NumericQ} : $BcDirectWangWindow["M2Range"],
  s0Values_List : $BcDirectWangWindow["s0Values"],
  params_: $BcDirectDefaultParameters,
  opts : OptionsPattern[]
] := Module[
  {nPoints = Max[2, Round[OptionValue["NPoints"]]], numericOpts, data, styles, labels, yRange, plotRange},
  numericOpts = FilterRules[{opts}, Options[DirectNumericBorelPi]];
  data = DirectM2StabilityData[m2Range, s0Values, params, nPoints, Sequence @@ numericOpts];
  styles = DirectPlotStyles[Length[data]];
  labels = Row[{Subscript["s", 0], " = ", DirectLegendNumber[#], " ", Superscript["GeV", 2]}] & /@ Keys[data];
  yRange = DirectThetaYRange[Values[data][[All, All, 2]], OptionValue["YHalfWidth"], OptionValue["YPadFraction"]];
  plotRange = Replace[OptionValue[PlotRange], Automatic -> {m2Range, yRange}];
  <|
    "Data" -> data,
    "Plot" -> ListLinePlot[
      Values[data],
      Frame -> True,
      Axes -> False,
      FrameLabel -> {Row[{Superscript["M", 2], " (", Superscript["GeV", 2], ")"}], Superscript["\[Theta]", "\[Degree]"]},
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

Options[DirectS0StabilityPublicationPlot] = Options[DirectM2StabilityPublicationPlot];

DirectS0StabilityPublicationPlot[
  s0Range : {_?NumericQ, _?NumericQ} : $BcDirectWangWindow["s0Range"],
  m2Values_List : $BcDirectWangWindow["M2Values"],
  params_: $BcDirectDefaultParameters,
  opts : OptionsPattern[]
] := Module[
  {nPoints = Max[2, Round[OptionValue["NPoints"]]], numericOpts, data, styles, labels, yRange, plotRange},
  numericOpts = FilterRules[{opts}, Options[DirectNumericBorelPi]];
  data = DirectS0StabilityData[s0Range, m2Values, params, nPoints, Sequence @@ numericOpts];
  styles = DirectPlotStyles[Length[data]];
  labels = Row[{Superscript["M", 2], " = ", DirectLegendNumber[#], " ", Superscript["GeV", 2]}] & /@ Keys[data];
  yRange = DirectThetaYRange[Values[data][[All, All, 2]], OptionValue["YHalfWidth"], OptionValue["YPadFraction"]];
  plotRange = Replace[OptionValue[PlotRange], Automatic -> {s0Range, yRange}];
  <|
    "Data" -> data,
    "Plot" -> ListLinePlot[
      Values[data],
      Frame -> True,
      Axes -> False,
      FrameLabel -> {Row[{Subscript["s", 0], " (", Superscript["GeV", 2], ")"}], Superscript["\[Theta]", "\[Degree]"]},
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

DirectNormalizeUncertaintyRanges[ranges_: <||>] := Which[
  AssociationQ[ranges],
    Join[$BcDirectDefaultUncertaintyRanges, ranges],
  ListQ[ranges],
    Join[$BcDirectDefaultUncertaintyRanges, Association[ranges]],
  True,
    $Failed
];

DirectRandomRangeValue[value_?NumericQ] := N[value];
DirectRandomRangeValue[range : {_?NumericQ, _?NumericQ}] := RandomReal[N[range]];
DirectRandomRangeValue[_] := $Failed;

DirectRandomParameterPoint[ranges_: <||>] := Module[
  {merged = DirectNormalizeUncertaintyRanges[ranges], sampled},
  If[merged === $Failed, Return[$Failed]];
  sampled = Association @ KeyValueMap[#1 -> DirectRandomRangeValue[#2] &, merged];
  If[MemberQ[Values[sampled], $Failed], $Failed, sampled]
];

DirectValidParameterPointQ[point_Association] := Module[
  {vals, mbv, mcv, m2v, s0v},
  vals = Lookup[point, {"mb", "mc", "M2", "s0"}, Missing["KeyAbsent"]];
  If[! VectorQ[vals, NumericQ], Return[False]];
  {mbv, mcv, m2v, s0v} = N[vals];
  mbv > 0 && mcv > 0 && m2v > 0 && s0v > (mbv + mcv)^2
];
DirectValidParameterPointQ[_] := False;

DirectRandomAcceptedParameterPoint[ranges_: <||>, maxAttempts_: 1000] := Module[
  {point = $Failed, attempts = 0},
  If[! IntegerQ[maxAttempts] || maxAttempts <= 0, Return[$Failed]];
  While[attempts < maxAttempts,
    attempts++;
    point = DirectRandomParameterPoint[ranges];
    If[AssociationQ[point] && DirectValidParameterPointQ[point], Return[point]]
  ];
  $Failed
];

DirectRealNumberQ[value_] :=
  NumericQ[value] && TrueQ[Chop[Im[N[value]]] == 0];
DirectRealNumber[value_] := Re[N[Chop[value]]];

Options[DirectMonteCarloMixingAngleSamples] = Join[
  Options[DirectNumericBorelPi],
  {"Seed" -> Automatic, "MaxAttempts" -> 1000, "Progress" -> False}
];

DirectMonteCarloMixingAngleSamples[
  n_Integer?Positive,
  ranges_: <||>,
  opts : OptionsPattern[]
] := Module[
  {merged = DirectNormalizeUncertaintyRanges[ranges], seed = OptionValue["Seed"],
   maxAttempts = OptionValue["MaxAttempts"], progress = OptionValue["Progress"],
   numericOpts, printEvery, point, theta},
  If[merged === $Failed, Return[$Failed]];
  If[seed =!= Automatic, SeedRandom[seed]];
  numericOpts = FilterRules[{opts}, Options[DirectNumericBorelPi]];
  printEvery = Max[1, Floor[n/10]];
  DeleteCases[
    Table[
      If[TrueQ[progress] && Mod[i, printEvery] == 0, Print["Direct coordinate Monte Carlo sample ", i, "/", n]];
      point = DirectRandomAcceptedParameterPoint[merged, maxAttempts];
      If[point === $Failed, Return[$Failed]];
      theta = Quiet[
        DirectNumericMixingAngleDegrees[point["M2"], point["s0"], point, Sequence @@ numericOpts]
      ];
      If[DirectRealNumberQ[theta],
        Join[
          <|"Index" -> i, "Order" -> "pert"|>,
          Association @ KeyValueMap[#1 -> N[#2] &, KeyTake[point, {"mb", "mc", "G2", "G3", "M2", "s0"}]],
          <|"Threshold" -> N[(point["mb"] + point["mc"])^2], "ThetaDeg" -> DirectRealNumber[theta]|>
        ],
        $Failed
      ],
      {i, n}
    ],
    $Failed
  ]
];

DirectMonteCarloMixingAngleValues[result_Association] /; KeyExistsQ[result, "Samples"] :=
  DirectMonteCarloMixingAngleValues[result["Samples"]];
DirectMonteCarloMixingAngleValues[samples_List] :=
  DirectRealNumber /@ Select[Lookup[samples, "ThetaDeg", {}], DirectRealNumberQ];

DirectMonteCarloMixingAngleGaussianSummary[result_Association] /; KeyExistsQ[result, "Samples"] :=
  DirectMonteCarloMixingAngleGaussianSummary[result["Samples"]];
DirectMonteCarloMixingAngleGaussianSummary[samples_List] := Module[
  {values = DirectMonteCarloMixingAngleValues[samples], count, mu, sigma, sampleSigma, q16, q50, q84},
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

DirectMonteCarloMixingAngleUncertainty[
  n_Integer?Positive,
  ranges_: <||>,
  opts : OptionsPattern[DirectMonteCarloMixingAngleSamples]
] := Module[
  {samples},
  samples = DirectMonteCarloMixingAngleSamples[n, ranges, opts];
  If[samples === $Failed, Return[$Failed]];
  <|
    "Order" -> "pert",
    "DirectMonteCarloEngine" -> "Independent direct-coordinate engine",
    "DirectIndependence" -> "Independent perturbative direct-coordinate result. Full G2/G3 OPE is not implemented in this direct file.",
    "RequestedSamples" -> n,
    "AcceptedSamples" -> Length[samples],
    "Ranges" -> DirectNormalizeUncertaintyRanges[ranges],
    "Samples" -> samples,
    "Summary" -> DirectMonteCarloMixingAngleGaussianSummary[samples]
  |>
];

DirectMonteCarloMixingAngleDataset[result_Association] /; KeyExistsQ[result, "Samples"] :=
  Dataset[result["Samples"]];

DirectMonteCarloSampleTable[result_Association] /; KeyExistsQ[result, "Samples"] := Module[
  {samples = result["Samples"], keys},
  If[samples === {}, Return[{}]];
  keys = Union[Flatten[Keys /@ samples]];
  Prepend[Lookup[#, keys, ""] & /@ samples, keys]
];

DirectExportMonteCarloMixingAngleSamples[
  result_Association,
  file_String : "BcMixingCoordinateDirectMonteCarloSamples.csv"
] :=
  DirectWriteCSV[file, DirectMonteCarloSampleTable[result]];

DirectExportMonteCarloMixingAngleSummary[
  result_Association,
  file_String : "BcMixingCoordinateDirectMonteCarloSummary.csv"
] := Module[
  {summary = result["Summary"]},
  DirectWriteCSV[
    file,
    Prepend[KeyValueMap[{#1, ToString[#2, InputForm]} &, summary], {"Quantity", "Value"}]
  ]
];

Options[DirectMonteCarloMixingAnglePublicationHistogram] = {
  "HistogramColor" -> RGBColor[0.22, 0.39, 0.62],
  "FitColor" -> RGBColor[0.76, 0.12, 0.10],
  "MeanColor" -> GrayLevel[0.15],
  "ShowMeanLine" -> True,
  ImageSize -> 540,
  LabelStyle -> Directive[Black, 14, FontFamily -> "Times"],
  BaseStyle -> {FontFamily -> "Times"},
  PlotRange -> All
};

DirectMonteCarloMixingAnglePublicationHistogram[
  result_,
  bins_: Automatic,
  opts : OptionsPattern[]
] := Module[
  {values = DirectMonteCarloMixingAngleValues[result], summary, mu, sigma, x,
   xrange, hist, fit, shown, legend, histColor = OptionValue["HistogramColor"],
   fitColor = OptionValue["FitColor"], meanColor = OptionValue["MeanColor"]},
  If[values === {}, Return[$Failed]];
  summary = DirectMonteCarloMixingAngleGaussianSummary[result];
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
      SwatchLegend[{histColor}, {"Direct coordinate samples"}],
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

DirectPerturbativeCheck[
  m2Val_: 8.0,
  continuumVal_: 54.0,
  params_: $BcDirectDefaultParameters
] := <|
  "Environment" -> DirectEnvironment[],
  "Threshold" -> N[DirectThreshold[] /. DirectParameterRules[params]],
  "xLimitsAtS0" -> N[DirectXLimits[continuumVal] /. DirectParameterRules[params]],
  "RhoAAAtS0" -> N[DirectPerturbativeSpectralDensity["AA", continuumVal] /. DirectParameterRules[params]],
  "RhoABAtS0" -> N[DirectPerturbativeSpectralDensity["AB", continuumVal] /. DirectParameterRules[params]],
  "RhoBBAtS0" -> N[DirectPerturbativeSpectralDensity["BB", continuumVal] /. DirectParameterRules[params]],
  "ThetaPertDeg" -> DirectNumericMixingAngleDegrees[m2Val, continuumVal, params]
|>;

DirectLiteratureNote[] := Column[
  {
    "Direct non-Azizi route for the perturbative part:",
    "1. Huang-Liu express the coordinate-space two-heavy correlator through hypergeometric functions.",
    "2. They extract spectral densities using simple integral representations or epsilon expansion.",
    "3. Groote-Koerner-Pivovarov formulate the same type of problem as an inverse K-transform of products of massive propagators.",
    "4. For the present two-point perturbative B_c loop, the inverse-K discontinuity is the ordinary two-body cut, proportional to Sqrt[lambda(s,mb,mc)]/s.",
    "5. Condensate terms are not automatic in this file because derivative delta functions must be treated separately."
  }
];

DirectDeltaSupportNote[] := Column[
  {
    "The direct support variable is",
    TraditionalForm[s == DirectSbar[x]],
    "The two roots are",
    TraditionalForm[DirectXLimits[s]],
    "The formal delta reduction is",
    TraditionalForm[DirectDeltaReductionFormula[F[x], x, s]["FormalReduction"]],
    "Numerically, DirectDeltaReduceNumeric[f, s0] evaluates the same root/Jacobian sum.",
    "For derivative delta functions inside Borel moments, run DirectDeltaDerivativeExamples[]."
  }
];

Print["Loaded BcMixingCoordinateDirect.wl. Run DirectPerturbativeCheck[] for the non-Azizi perturbative check."];

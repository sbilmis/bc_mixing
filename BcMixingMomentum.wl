(* ::Package:: *)

(*  BcMixingMomentum.wl

    Momentum-space QCD sum-rule algebra for B_c axial-vector mixing.

    System:
      B_c^+ = \bar b c

    Currents:
      J_A[mu] = \bar b gamma_mu gamma_5 c
      J_B[mu] = i \bar b sigma_{mu alpha} p^alpha/(m_b + m_c) gamma_5 c

    Implemented OPE algebra:
      - perturbative heavy-heavy loop
      - dimension-4 gluon condensate <g_s^2 G^2>
      - dimension-6 triple-gluon condensate <g_s^3 G^3>, standard
        vacuum-averaged single-heavy-propagator term

    Implemented numerical spectral densities:
      - perturbative heavy-heavy loop

    Implemented direct Borel moments:
      - dimension-4 gluon condensate <g_s^2 G^2>
      - dimension-6 triple-gluon condensate <g_s^3 G^3>

    Important:
      The G2 contribution is not treated as an ordinary smooth rho(s).
      It is evaluated as a direct Borel moment because its spectral
      representation contains delta-function derivative terms.

    G3 caveat:
      The implemented G3 term is the standard vacuum-averaged contribution
      from S_c^(G3) S_b^0 + S_c^0 S_b^(G3).  Possible cross-line open-field
      terms involving an explicitly open two-gluon propagator and one
      one-gluon propagator require a separate derivation and are not guessed
      here.

    Alpha_s caveat:
      Full perturbative O(alpha_s) corrections are not implemented.  The
      K-factor helpers provide only a sensitivity model in which the LO
      perturbative moments are rescaled as
        Pi_pert^ij -> (1 + alpha_s K_ij/Pi) Pi_pert^ij.

    Notes:
      1. The tensor current contains the explicit current factor
         i sigma_{mu alpha} p^alpha/(m_b + m_c) gamma_5.  The denominator
         gives J_A and J_B the same mass dimension. Since FeynCalc's
         DiracSigma already contains the conventional i/2 commutator,
         retaining the current's extra factor of i makes the projected AB
         and BB invariant amplitudes real.
      2. BorelPi is intentionally written in terms of spectral densities
         rho[channel, order][s].  Use SetSpectralDensity after deriving or
         importing the spectral densities from the projected Feynman-parameter
         expressions.  This keeps the FeynCalc algebra and numerical sum-rule
         stage cleanly separated.
*)

ClearAll["Global`*"];

BcMixingMomentum::nofc =
  "FeynCalc could not be loaded. Install/configure FeynCalc in the active Wolfram kernel.";
BcMixingMomentum::badchannel =
  "Unknown channel `1`. Valid channels are \"AA\", \"AB\", \"BA\" and \"BB\".";
BcMixingMomentum::badorder =
  "Unknown OPE order `1`. Valid orders are \"pert\", \"G2c\", \"G2b\", \"G2gg\", \"G2\", \"pertG2\", \"G3c\", \"G3b\", \"G3\" and \"total\".";
BcMixingMomentum::g3 =
  "The implemented <g_s^3 G^3> term is the standard vacuum-averaged single-line propagator contribution. Cross-line open-field G3 terms are not included.";

If[! TrueQ[ValueQ[$FeynCalcVersion]],
  Quiet[
    Check[
      Needs["FeynCalc`"],
      Message[BcMixingMomentum::nofc];
      Abort[]
    ]
  ];
];

If[NameQ["FeynCalc`FCSetDiracGammaScheme"],
  Quiet[FCSetDiracGammaScheme["NDR"]]
];

(* ---------------------------------------------------------------------- *)
(* Global symbols and defaults                                             *)
(* ---------------------------------------------------------------------- *)

ClearAll[
  mb, mc, M2, s0, s, G2, G3, alphaS, eps,
  k, p, mu, nu, al, be, rh, si, x, z, xi
];

$BcMixingNc = 3;
$BcMixingKeepRawTensorI = True;
$BcMixingDirectBorelPhase = -I;
$BcMixingG2BorelPhase = $BcMixingDirectBorelPhase;
$BcMixingChannels = <|
  "AA" -> {"A", "A"},
  "AB" -> {"A", "B"},
  "BA" -> {"B", "A"},
  "BB" -> {"B", "B"}
|>;

$BcMixingOrders = {"pert", "G2c", "G2b", "G2gg", "G2", "pertG2", "G3c", "G3b", "G3", "total"};
$BcMixingSpectralDensities = <||>;

$BcMixingDefaultParameters = <|
  "mb" -> 4.18,
  "mc" -> 1.27,
  "G2" -> 4 Pi^2 0.012,
  "G3" -> 0.57,
  "alphaS" -> 0.26,
  "M2" -> 10.0,
  "s0" -> 55.0
|>;

$Assumptions =
  Element[{mb, mc, M2, s0, s, G2, G3, alphaS}, Reals] &&
  mb > 0 && mc > 0 && M2 > 0 && s0 > (mb + mc)^2 &&
  G2 >= 0 && G3 >= 0 && alphaS >= 0;

ClearBcMixingCache[] := Null;

MergeDefaultParameters[assoc_: <||>] := Join[$BcMixingDefaultParameters, assoc];

ParameterRules[assoc_: $BcMixingDefaultParameters] := Module[
  {merged = MergeDefaultParameters[assoc]},
  {
    mb -> merged["mb"],
    mc -> merged["mc"],
    G2 -> merged["G2"],
    G3 -> merged["G3"],
    alphaS -> merged["alphaS"],
    M2 -> merged["M2"],
    s0 -> merged["s0"]
  }
];

BcThreshold[] := (mb + mc)^2;

TensorCurrentScale[] := mb + mc;
TensorCurrentNormalization[] := 1/TensorCurrentScale[];

CheckEnvironment[] := <|
  "FeynCalcLoaded" -> TrueQ[ValueQ[$FeynCalcVersion]],
  "FeynCalcVersion" -> If[TrueQ[ValueQ[$FeynCalcVersion]], $FeynCalcVersion, Missing["NotLoaded"]],
  "TensorCurrentKeepsRawI" -> $BcMixingKeepRawTensorI,
  "TensorCurrentScale" -> TensorCurrentScale[],
  "Nc" -> $BcMixingNc,
  "Threshold" -> BcThreshold[],
  "DefaultParameters" -> $BcMixingDefaultParameters
|>;

(* ---------------------------------------------------------------------- *)
(* Vertices and propagator pieces                                          *)
(* ---------------------------------------------------------------------- *)

ValidateChannel[channel_String] := If[
  KeyExistsQ[$BcMixingChannels, channel],
  channel,
  Message[BcMixingMomentum::badchannel, channel];
  Abort[]
];

ValidateOrder[order_String] := If[
  MemberQ[$BcMixingOrders, order],
  order,
  Message[BcMixingMomentum::badorder, order];
  Abort[]
];

CurrentTensorPower[channel_String] :=
  Count[$BcMixingChannels[ValidateChannel[channel]], "B"];

CurrentNormalizationFactor[channel_String] :=
  TensorCurrentScale[]^-CurrentTensorPower[channel];

CurrentMassDimension["A", normalized_: True] := 3;
CurrentMassDimension["B", normalized_: True] := If[TrueQ[normalized], 3, 4];

ChannelCurrentMassDimensions[channel_String, normalized_: True] :=
  CurrentMassDimension[#, normalized] & /@ $BcMixingChannels[ValidateChannel[channel]];

CorrelatorMassDimension[channel_String, normalized_: True] :=
  Total[ChannelCurrentMassDimensions[channel, normalized]] - 4;

SpectralDensityMassDimension[channel_String, normalized_: True] :=
  CorrelatorMassDimension[channel, normalized];

BorelMomentMassDimension[channel_String, normalized_: True] :=
  SpectralDensityMassDimension[channel, normalized] + 2;

MixingMassDimensionReport[normalized_: True] := AssociationMap[
  <|
    "CurrentDimensions" -> ChannelCurrentMassDimensions[#, normalized],
    "CorrelatorDimension" -> CorrelatorMassDimension[#, normalized],
    "SpectralDensityDimension" -> SpectralDensityMassDimension[#, normalized],
    "BorelMomentDimensionInThisConvention" -> BorelMomentMassDimension[#, normalized]
  |>&,
  {"AA", "AB", "BA", "BB"}
];

CheckMixingMassDimensions[normalized_: True] := Module[
  {dims = Values[AssociationMap[SpectralDensityMassDimension[#, normalized] &, {"AA", "AB", "BA", "BB"}]]},
  SameQ @@ dims
];

CurrentVertex["A", lor_] := GA[lor] . GA[5];

CurrentVertex["B", lor_] := Module[
  {phase = If[TrueQ[$BcMixingKeepRawTensorI], I, 1]},
  phase TensorCurrentNormalization[] (DiracSigma[GA[lor], GS[p]] . GA[5])
];

S0Num[q_, m_] := GS[q] + m;
S0Den[q_, m_] := FAD[{q, m}];

SGNum[q_, m_, a_, b_] :=
  -1/4 (
    DiracSigma[GA[a], GA[b]] . (GS[q] + m) +
    (GS[q] + m) . DiracSigma[GA[a], GA[b]]
  );
SGDen[q_, m_] := FAD[{q, m, 2}];

SG2Num[q_, m_] := m (SP[q, q] + m GS[q]);
SG2Den[q_, m_] := FAD[{q, m, 4}];
SG2Prefactor[] := G2/12;

SG3Num[q_, m_] :=
  (GS[q] + m) .
    ((SP[q, q] - 3 m^2) GS[q] + 2 m (2 SP[q, q] - m^2)) .
    (GS[q] + m);
SG3Den[q_, m_] := FAD[{q, m, 6}];
SG3Prefactor[] := G3/48;

GGVacuumTensor[a_, b_, r_, t_] :=
  MT[a, r] MT[b, t] - MT[a, t] MT[b, r];

GGVacuumPrefactor[] := G2 (($BcMixingNc^2 - 1)/2)/96;

EvaluateDiracTrace[chain_] :=
  chain //
    DotSimplify //
    DiracSigmaExplicit //
    DiracTrace //
    DiracSimplify //
    Contract //
    FCE //
    Simplify;

TraceForChannel[channel_String, cNum_, bNum_] := Module[
  {pair = $BcMixingChannels[ValidateChannel[channel]]},
  EvaluateDiracTrace[
    CurrentVertex[pair[[1]], mu] . cNum .
    CurrentVertex[pair[[2]], nu] . bNum
  ]
];

(* ---------------------------------------------------------------------- *)
(* Loop integrands                                                         *)
(* ---------------------------------------------------------------------- *)

LoopIntegrand[channel_String, "pert"] := Module[
  {qc = k, qb = k - p},
  $BcMixingNc
    TraceForChannel[channel, S0Num[qc, mc], S0Num[qb, mb]]
    S0Den[qc, mc] S0Den[qb, mb]
];

LoopIntegrand[channel_String, "G2c"] := Module[
  {qc = k, qb = k - p},
  $BcMixingNc SG2Prefactor[]
    TraceForChannel[channel, SG2Num[qc, mc], S0Num[qb, mb]]
    SG2Den[qc, mc] S0Den[qb, mb]
];

LoopIntegrand[channel_String, "G2b"] := Module[
  {qc = k, qb = k - p},
  $BcMixingNc SG2Prefactor[]
    TraceForChannel[channel, S0Num[qc, mc], SG2Num[qb, mb]]
    S0Den[qc, mc] SG2Den[qb, mb]
];

LoopIntegrand[channel_String, "G2gg"] := Module[
  {qc = k, qb = k - p},
  GGVacuumPrefactor[]
    Contract[
      GGVacuumTensor[al, be, rh, si]
      TraceForChannel[
        channel,
        SGNum[qc, mc, al, be],
        SGNum[qb, mb, rh, si]
      ]
    ]
    SGDen[qc, mc] SGDen[qb, mb] //
    Contract //
    FCE //
    Simplify
];

LoopIntegrand[channel_String, "G2"] :=
  Total[LoopIntegrand[channel, #] & /@ {"G2c", "G2b", "G2gg"}] // Simplify;

LoopIntegrand[channel_String, "G3c"] := Module[
  {qc = k, qb = k - p},
  $BcMixingNc SG3Prefactor[]
    TraceForChannel[channel, SG3Num[qc, mc], S0Num[qb, mb]]
    SG3Den[qc, mc] S0Den[qb, mb]
];

LoopIntegrand[channel_String, "G3b"] := Module[
  {qc = k, qb = k - p},
  $BcMixingNc SG3Prefactor[]
    TraceForChannel[channel, S0Num[qc, mc], SG3Num[qb, mb]]
    S0Den[qc, mc] SG3Den[qb, mb]
];

LoopIntegrand[channel_String, "G3"] :=
  Total[LoopIntegrand[channel, #] & /@ {"G3c", "G3b"}] // Simplify;

LoopIntegrand[channel_String, "pertG2"] :=
  LoopIntegrand[channel, "pert"] + LoopIntegrand[channel, "G2"] // Simplify;

LoopIntegrand[channel_String, "total"] :=
  LoopIntegrand[channel, "pertG2"] + LoopIntegrand[channel, "G3"] // Simplify;

LoopIntegrand[channel_String, order_String] /; ! MemberQ[$BcMixingOrders, order] := (
  Message[BcMixingMomentum::badorder, order];
  Abort[]
);

(* ---------------------------------------------------------------------- *)
(* Projection and Feynman-parameter forms                                  *)
(* ---------------------------------------------------------------------- *)

ProjectSpin1[expr_] := Module[
  {projector},
  projector = 1/3 (MT[mu, nu] - FV[p, mu] FV[p, nu]/SP[p, p]);
  Contract[projector expr] //
    FCE //
    DiracSimplify //
    Contract //
    Simplify
];

Options[Correlator] = {
  "Projected" -> True,
  "TensorReduce" -> False,
  "UsePaVeBasis" -> True,
  "SimplifyResult" -> True
};

Correlator[channel_String, order_String : "total", OptionsPattern[]] := Module[
  {expr},
  ValidateChannel[channel];
  ValidateOrder[order];
  expr = LoopIntegrand[channel, order];

  If[TrueQ[OptionValue["Projected"]],
    expr = ProjectSpin1[expr]
  ];

  If[TrueQ[OptionValue["TensorReduce"]],
    expr = ChangeDimension[expr, D];
    expr = TID[expr, k, UsePaVeBasis -> OptionValue["UsePaVeBasis"]]
  ];

  If[TrueQ[OptionValue["SimplifyResult"]],
    expr = expr // Contract // FCE // Simplify
  ];

  expr
];

Options[FeynmanParameterForm] = Join[
  DeleteCases[Options[Correlator], ("TensorReduce" -> _) | ("UsePaVeBasis" -> _)],
  {
    "TensorReduce" -> True,
    "UsePaVeBasis" -> False,
    "InvariantSymbol" -> s,
    "EpsilonSymbol" -> eps,
    "FeynmanParameterHead" -> x,
    "FeynmanIntegralPrefactor" -> "Textbook"
  }
];

FeynmanParameterForm[channel_String, order_String : "total", opts : OptionsPattern[]] := Module[
  {expr, corOpts, inv, ep, head, expanded, terms, loopTerms},
  corOpts = FilterRules[{opts}, Options[Correlator]];
  inv = OptionValue["InvariantSymbol"];
  ep = OptionValue["EpsilonSymbol"];
  head = OptionValue["FeynmanParameterHead"];

  expr = Correlator[channel, order, Sequence @@ corOpts];
  expr = ChangeDimension[expr, D];
  expr = expr /. {
    SPD[p, p] -> inv,
    SPD[p] -> inv,
    Pair[Momentum[p, D], Momentum[p, D]] -> inv
  };
  expanded = Expand[expr];
  terms = If[Head[expanded] === Plus, List @@ expanded, {expanded}];
  loopTerms = Select[terms, ! FreeQ[FCI[#], FeynAmpDenominator] &];

  FCFeynmanParametrize[
    #,
    {k},
    Names -> head,
    FeynmanIntegralPrefactor -> OptionValue["FeynmanIntegralPrefactor"],
    FinalSubstitutions -> {
      SPD[p, p] -> inv,
      SPD[p] -> inv,
      Pair[Momentum[p, D], Momentum[p, D]] -> inv
    },
    FCReplaceD -> {D -> 4 - 2 ep}
  ] & /@ loopTerms
];

(* ---------------------------------------------------------------------- *)
(* Spectral densities, Borel moments and mixing angle                      *)
(* ---------------------------------------------------------------------- *)

SpectralDensityDefinedQ[channel_String, order_String] := Which[
  KeyExistsQ[$BcMixingSpectralDensities, {channel, order}], True,
  order === "G2", AllTrue[{"G2c", "G2b", "G2gg"}, SpectralDensityDefinedQ[channel, #] &],
  order === "pertG2", SpectralDensityDefinedQ[channel, "pert"] && SpectralDensityDefinedQ[channel, "G2"],
  order === "G3", AllTrue[{"G3c", "G3b"}, SpectralDensityDefinedQ[channel, #] &],
  order === "total", SpectralDensityDefinedQ[channel, "pertG2"] && SpectralDensityDefinedQ[channel, "G3"],
  True, False
];

SetSpectralDensity[channel_String, order_String, expr_, var_: s] := Module[
  {ch = ValidateChannel[channel], ord = ValidateOrder[order], body = expr, vv = var},
  $BcMixingSpectralDensities[{ch, ord}] = With[
    {storedBody = body, storedVar = vv},
    (storedBody /. storedVar -> #) &
  ];
  {ch, ord}
];

ClearSpectralDensities[] := ($BcMixingSpectralDensities = <||>;);

KallenLambda[ss_, m1_, m2_] :=
  ss^2 + m1^4 + m2^4 - 2 ss m1^2 - 2 ss m2^2 - 2 m1^2 m2^2;

OnShellKDotP[ss_] := (ss + mc^2 - mb^2)/2;

$BcMixingMassDimensions = <|
  mb -> 1,
  mc -> 1,
  M2 -> 2,
  s0 -> 2,
  s -> 2,
  G2 -> 4,
  G3 -> 6,
  alphaS -> 0,
  k -> 1,
  p -> 1
|>;

MassDimensionFailureQ[dim_] := MatchQ[dim, _Failure];

MassDimension[expr_, dimRules_: Automatic] := Module[
  {rules = Replace[dimRules, Automatic -> $BcMixingMassDimensions]},
  MassDimensionInternal[expr, rules]
];

MassDimensionInternal[expr_, rules_Association] /; NumericQ[expr] := 0;

MassDimensionInternal[expr_Symbol, rules_Association] := Lookup[rules, expr, 0];

MassDimensionInternal[expr_Plus, rules_Association] := Module[
  {termDims = MassDimensionInternal[#, rules] & /@ List @@ expr, first},
  If[AnyTrue[termDims, MassDimensionFailureQ],
    Return[Failure["MassDimensionSubexpressionFailed", <|"Expression" -> HoldForm[expr], "TermDimensions" -> termDims|>]]
  ];
  first = First[termDims];
  If[AllTrue[Rest[termDims], TrueQ[Simplify[# == first]] &],
    first,
    Failure["InhomogeneousMassDimension", <|"Expression" -> HoldForm[expr], "TermDimensions" -> termDims|>]
  ]
];

MassDimensionInternal[expr_Times, rules_Association] := Module[
  {factorDims = MassDimensionInternal[#, rules] & /@ List @@ expr},
  If[AnyTrue[factorDims, MassDimensionFailureQ],
    Failure["MassDimensionSubexpressionFailed", <|"Expression" -> HoldForm[expr], "FactorDimensions" -> factorDims|>],
    Simplify[Total[factorDims]]
  ]
];

MassDimensionInternal[Power[base_, exponent_?NumericQ], rules_Association] := Module[
  {baseDim = MassDimensionInternal[base, rules]},
  If[MassDimensionFailureQ[baseDim],
    baseDim,
    Simplify[exponent baseDim]
  ]
];

MassDimensionInternal[Exp[arg_], rules_Association] := Module[
  {argDim = MassDimensionInternal[arg, rules]},
  Which[
    MassDimensionFailureQ[argDim], argDim,
    TrueQ[Simplify[argDim == 0]], 0,
    True, Failure["DimensionfulExponentialArgument", <|"Expression" -> HoldForm[Exp[arg]], "ArgumentDimension" -> argDim|>]
  ]
];

MassDimensionInternal[Log[arg_], rules_Association] := Module[
  {argDim = MassDimensionInternal[arg, rules]},
  Which[
    MassDimensionFailureQ[argDim], argDim,
    TrueQ[Simplify[argDim == 0]], 0,
    True, Failure["DimensionfulLogArgument", <|"Expression" -> HoldForm[Log[arg]], "ArgumentDimension" -> argDim|>]
  ]
];

MassDimensionInternal[Abs[arg_], rules_Association] := MassDimensionInternal[arg, rules];

MassDimensionInternal[HeavisideTheta[_], rules_Association] := 0;

MassDimensionInternal[DiracDelta[arg_], rules_Association] := Module[
  {argDim = MassDimensionInternal[arg, rules]},
  If[MassDimensionFailureQ[argDim], argDim, -argDim]
];

MassDimensionInternal[expr_, rules_Association] := Module[
  {known = Keys[rules]},
  If[FreeQ[expr, Alternatives @@ known],
    0,
    Failure["UnknownMassDimension", <|"Expression" -> HoldForm[expr]|>]
  ]
];

MassDimensionCheck[name_, expr_, expected_: Automatic, dimRules_: Automatic] := Module[
  {dim = MassDimension[expr, dimRules], pass},
  pass = ! MassDimensionFailureQ[dim] &&
    (expected === Automatic || TrueQ[Simplify[dim == expected]]);
  <|
    "Name" -> name,
    "Dimension" -> dim,
    "Expected" -> expected,
    "Pass" -> pass
  |>
];

PerturbativeSpectralDensityDimensionReport[] := AssociationMap[
  MassDimensionCheck["rhoPert" <> #, PerturbativeSpectralDensity[#, s], 2] &,
  {"AA", "AB", "BA", "BB"}
];

PerturbativeNumerator[channel_String, ss_: s] := Module[
  {kp = OnShellKDotP[ss], k2 = mc^2, ch = ValidateChannel[channel]},
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

PerturbativeSpectralDensity[channel_String, ss_: s] := Module[
  {lam = KallenLambda[ss, mb, mc]},
  $BcMixingNc/(16 Pi^2) Sqrt[lam]/ss PerturbativeNumerator[channel, ss]
    CurrentNormalizationFactor[channel]
];

InstallPerturbativeSpectralDensities[] := (
  Scan[
    SetSpectralDensity[#, "pert", PerturbativeSpectralDensity[#, s], s] &,
    {"AA", "AB", "BA", "BB"}
  ];
  "Installed perturbative spectral densities for AA, AB, BA and BB."
);

InstallPerturbativeSpectralDensities[];

(* ---------------------------------------------------------------------- *)
(* Direct Borel moments for condensates without smooth spectral densities  *)
(* ---------------------------------------------------------------------- *)

SBar[xvar_] := (mc^2 xvar + mb^2 (1 - xvar))/(xvar (1 - xvar));

CleanFeynmanParameterTerms[channel_String, order_String] :=
  CleanFeynmanParameterTerms[channel, order] = Select[
    FeynmanParameterForm[channel, order] /. eps -> 0,
    #[[1]] =!= 0 && FreeQ[#, ComplexInfinity | Indeterminate | DirectedInfinity] &
  ];

SimplexAmplitude[channel_String, order_String, xvar_] := Module[
  {terms},
  terms = CleanFeynmanParameterTerms[channel, order];
  Total[(#[[1]] #[[2]]) & /@ terms] /. {x[1] -> xvar, x[2] -> 1 - xvar}
];

G2SimplexAmplitude[channel_String] :=
  G2SimplexAmplitude[channel] = (
    $BcMixingDirectBorelPhase SimplexAmplitude[channel, "G2", xi] //
      Together //
      Simplify
  );

G3SimplexAmplitude[channel_String] :=
  G3SimplexAmplitude[channel] = (
    $BcMixingDirectBorelPhase SimplexAmplitude[channel, "G3", xi] //
      Together //
      Simplify
  );

BorelTransformQ2[expr_, xvar_, m2_] := Module[
  {q2, tau, sb, transformed, maxPower = 12},
  sb = SBar[xvar];
  transformed = expr /. s -> -q2 /. q2 -> tau - sb;
  transformed = Apart[Together[transformed], tau] // Expand;
  Exp[-sb/m2] Sum[
    Coefficient[transformed, tau, -n]/(Factorial[n - 1] m2^(n - 1)),
    {n, 1, maxPower}
  ] // Simplify
];

G2BorelIntegrandExpression[channel_String] :=
  G2BorelIntegrandExpression[channel] =
    BorelTransformQ2[G2SimplexAmplitude[channel], xi, M2];

G3BorelIntegrandExpression[channel_String] :=
  G3BorelIntegrandExpression[channel] =
    BorelTransformQ2[G3SimplexAmplitude[channel], xi, M2];

ContinuumXLimits[continuumVal_?NumericQ, params_: $BcMixingDefaultParameters] := Module[
  {rules, mbv, mcv, lam, xm, xp},
  rules = ParameterRules[params];
  mbv = N[mb /. rules];
  mcv = N[mc /. rules];
  lam = N[KallenLambda[continuumVal, mbv, mcv]];
  If[lam <= 0, Return[$Failed]];
  xm = (continuumVal + mbv^2 - mcv^2 - Sqrt[lam])/(2 continuumVal);
  xp = (continuumVal + mbv^2 - mcv^2 + Sqrt[lam])/(2 continuumVal);
  Sort[{xm, xp}]
];

Options[NumericBorelPiG2] = Options[NIntegrate];

NumericBorelPiG2[
  channel_String,
  m2Val_?NumericQ,
  continuumVal_?NumericQ,
  params_: $BcMixingDefaultParameters,
  opts : OptionsPattern[]
] := Module[
  {lims, integrand},
  ValidateChannel[channel];
  lims = ContinuumXLimits[continuumVal, params];
  If[lims === $Failed, Return[0.]];
  integrand = Evaluate[
    G2BorelIntegrandExpression[channel] /.
      ParameterRules[params] /.
      M2 -> m2Val
  ];
  NIntegrate[
    integrand,
    {xi, lims[[1]], lims[[2]]},
    opts
  ]
];

Options[NumericBorelPiG3] = Options[NIntegrate];

NumericBorelPiG3[
  channel_String,
  m2Val_?NumericQ,
  continuumVal_?NumericQ,
  params_: $BcMixingDefaultParameters,
  opts : OptionsPattern[]
] := Module[
  {lims, integrand},
  ValidateChannel[channel];
  lims = ContinuumXLimits[continuumVal, params];
  If[lims === $Failed, Return[0.]];
  integrand = Evaluate[
    G3BorelIntegrandExpression[channel] /.
      ParameterRules[params] /.
      M2 -> m2Val
  ];
  NIntegrate[
    integrand,
    {xi, lims[[1]], lims[[2]]},
    opts
  ]
];

SpectralDensity[channel_String, order_String, var_: s] := Module[
  {ch = ValidateChannel[channel], ord = ValidateOrder[order]},
  Which[
    KeyExistsQ[$BcMixingSpectralDensities, {ch, ord}],
      $BcMixingSpectralDensities[{ch, ord}][var],
    ord === "G2",
      Total[SpectralDensity[ch, #, var] & /@ {"G2c", "G2b", "G2gg"}],
    ord === "pertG2",
      SpectralDensity[ch, "pert", var] + SpectralDensity[ch, "G2", var],
    ord === "G3",
      Total[SpectralDensity[ch, #, var] & /@ {"G3c", "G3b"}],
    ord === "total",
      SpectralDensity[ch, "pertG2", var] + SpectralDensity[ch, "G3", var],
    True,
      rho[ch, ord][var]
  ]
];

Options[BorelPi] = {
  "InactiveWhenFormal" -> True,
  Assumptions -> Automatic
};

BorelPi[channel_String, order_String : "total", m2_: M2, continuum_: s0, OptionsPattern[]] := Module[
  {var, density, lower, head, asm},
  ValidateChannel[channel];
  ValidateOrder[order];

  lower = BcThreshold[];
  density = SpectralDensity[channel, order, var];
  head = If[
    TrueQ[OptionValue["InactiveWhenFormal"]] && ! SpectralDensityDefinedQ[channel, order],
    Inactive[Integrate],
    Integrate
  ];
  asm = OptionValue[Assumptions] /. Automatic -> $Assumptions;

  head[Evaluate[Exp[-var/m2] density], {var, lower, continuum}, Assumptions -> asm]
];

MixingAngle[m2_: M2, continuum_: s0, order_String : "total"] :=
  1/2 ArcTan[
    BorelPi["AA", order, m2, continuum] - BorelPi["BB", order, m2, continuum],
    -2 BorelPi["AB", order, m2, continuum]
  ];

MixingAngleDegrees[m2_: M2, continuum_: s0, order_String : "total"] :=
  180/Pi MixingAngle[m2, continuum, order];

NormalizeMixingAngle[theta_?NumericQ] :=
  theta - (Pi/2) Round[theta/(Pi/2)];

NormalizeMixingAngleDegrees[thetaDeg_?NumericQ] :=
  thetaDeg - 90 Round[thetaDeg/90];

Options[NumericBorelPi] = Options[NIntegrate];

NumericBorelPi[
  channel_String,
  "G2",
  m2Val_?NumericQ,
  continuumVal_?NumericQ,
  params_: $BcMixingDefaultParameters,
  opts : OptionsPattern[]
] :=
  NumericBorelPiG2[channel, m2Val, continuumVal, params, opts];

NumericBorelPi[
  channel_String,
  "G3",
  m2Val_?NumericQ,
  continuumVal_?NumericQ,
  params_: $BcMixingDefaultParameters,
  opts : OptionsPattern[]
] :=
  NumericBorelPiG3[channel, m2Val, continuumVal, params, opts];

NumericBorelPi[
  channel_String,
  "pertG2",
  m2Val_?NumericQ,
  continuumVal_?NumericQ,
  params_: $BcMixingDefaultParameters,
  opts : OptionsPattern[]
] :=
  NumericBorelPi[channel, "pert", m2Val, continuumVal, params, opts] +
  NumericBorelPi[channel, "G2", m2Val, continuumVal, params, opts];

NumericBorelPi[
  channel_String,
  "total",
  m2Val_?NumericQ,
  continuumVal_?NumericQ,
  params_: $BcMixingDefaultParameters,
  opts : OptionsPattern[]
] :=
  NumericBorelPi[channel, "pertG2", m2Val, continuumVal, params, opts] +
  NumericBorelPi[channel, "G3", m2Val, continuumVal, params, opts];

NumericBorelPi[
  channel_String,
  order_String : "pert",
  m2Val_?NumericQ,
  continuumVal_?NumericQ,
  params_: $BcMixingDefaultParameters,
  opts : OptionsPattern[]
] := Module[
  {var, rules, lower, density},
  ValidateChannel[channel];
  ValidateOrder[order];
  If[! SpectralDensityDefinedQ[channel, order],
    Message[
      NumericBorelPi::norho,
      channel,
      order
    ];
    Return[$Failed]
  ];
  rules = Join[ParameterRules[params], {M2 -> m2Val, s0 -> continuumVal}];
  lower = N[BcThreshold[] /. rules];
  density = Evaluate[SpectralDensity[channel, order, var] /. rules];
  NIntegrate[
    Evaluate[Exp[-var/m2Val] density],
    {var, lower, continuumVal},
    opts
  ]
];

NumericBorelPi::norho =
  "No installed spectral density for channel `1`, order `2`. Use order \"pert\", \"G2\", \"G3\", \"pertG2\", or \"total\" for the implemented numerical moments.";

NumericMixingAngle[
  m2Val_?NumericQ,
  continuumVal_?NumericQ,
  order_String : "pert",
  params_: $BcMixingDefaultParameters,
  opts : OptionsPattern[NumericBorelPi]
] := Module[
  {aa, ab, bb},
  aa = NumericBorelPi["AA", order, m2Val, continuumVal, params, opts];
  ab = NumericBorelPi["AB", order, m2Val, continuumVal, params, opts];
  bb = NumericBorelPi["BB", order, m2Val, continuumVal, params, opts];
  If[MemberQ[{aa, ab, bb}, $Failed], Return[$Failed]];
  NormalizeMixingAngle[1/2 ArcTan[aa - bb, -2 ab]]
];

NumericMixingAngleRaw[
  m2Val_?NumericQ,
  continuumVal_?NumericQ,
  order_String : "pert",
  params_: $BcMixingDefaultParameters,
  opts : OptionsPattern[NumericBorelPi]
] := Module[
  {aa, ab, bb},
  aa = NumericBorelPi["AA", order, m2Val, continuumVal, params, opts];
  ab = NumericBorelPi["AB", order, m2Val, continuumVal, params, opts];
  bb = NumericBorelPi["BB", order, m2Val, continuumVal, params, opts];
  If[MemberQ[{aa, ab, bb}, $Failed], Return[$Failed]];
  1/2 ArcTan[aa - bb, -2 ab]
];

NumericMixingAngleDegrees[
  m2Val_?NumericQ,
  continuumVal_?NumericQ,
  order_String : "pert",
  params_: $BcMixingDefaultParameters,
  opts : OptionsPattern[NumericBorelPi]
] :=
  N[180/Pi NumericMixingAngle[m2Val, continuumVal, order, params, opts]];

NumericMixingAngleRawDegrees[
  m2Val_?NumericQ,
  continuumVal_?NumericQ,
  order_String : "pert",
  params_: $BcMixingDefaultParameters,
  opts : OptionsPattern[NumericBorelPi]
] :=
  N[180/Pi NumericMixingAngleRaw[m2Val, continuumVal, order, params, opts]];

NumericOPESummary[
  m2Val_?NumericQ,
  continuumVal_?NumericQ,
  params_: $BcMixingDefaultParameters,
  opts : OptionsPattern[NumericBorelPi]
] := Association[
  Table[
    Module[
      {pert = NumericBorelPi[ch, "pert", m2Val, continuumVal, params, opts],
       g2 = NumericBorelPi[ch, "G2", m2Val, continuumVal, params, opts],
       g3 = NumericBorelPi[ch, "G3", m2Val, continuumVal, params, opts]},
      ch -> <|
        "pert" -> pert,
        "G2" -> g2,
        "G3" -> g3,
        "pertG2" -> pert + g2,
        "total" -> pert + g2 + g3,
        "G2OverPert" -> g2/pert,
        "G3OverPert" -> g3/pert
      |>
    ],
    {ch, {"AA", "AB", "BB"}}
  ]
];

(* ---------------------------------------------------------------------- *)
(* Perturbative alpha_s K-factor sensitivity                               *)
(* ---------------------------------------------------------------------- *)

$BcMixingDefaultKFactors = <|"AA" -> 0, "AB" -> 0, "BA" -> 0, "BB" -> 0|>;

NormalizeKFactors[kFactors_?NumericQ] :=
  AssociationMap[kFactors &, Keys[$BcMixingDefaultKFactors]];

NormalizeKFactors[kFactors_: <||>] := Which[
  AssociationQ[kFactors],
    Join[$BcMixingDefaultKFactors, kFactors],
  ListQ[kFactors],
    Join[$BcMixingDefaultKFactors, Association[kFactors]],
  True,
    $BcMixingDefaultKFactors
];

KFactorAssociation[kAA_?NumericQ, kAB_?NumericQ, kBB_?NumericQ] :=
  <|"AA" -> kAA, "AB" -> kAB, "BA" -> kAB, "BB" -> kBB|>;

KFactorValue[channel_String, kFactors_: <||>] := Module[
  {ch = ValidateChannel[channel], assoc = NormalizeKFactors[kFactors]},
  Lookup[assoc, ch, 0]
];

AlphaSValue[Automatic, params_: $BcMixingDefaultParameters] :=
  MergeDefaultParameters[params]["alphaS"];
AlphaSValue[value_?NumericQ, params_: $BcMixingDefaultParameters] := value;

PerturbativeKMultiplier[channel_String, kFactors_: <||>, alphaVal_: Automatic, params_: $BcMixingDefaultParameters] :=
  1 + AlphaSValue[alphaVal, params]/Pi KFactorValue[channel, kFactors];

MomentFromSummary[summary_Association, channel_String, order_String : "total"] := Module[
  {ch = ValidateChannel[channel], ord = ValidateOrder[order]},
  If[! KeyExistsQ[summary, ch], Return[$Failed]];
  Switch[
    ord,
    "pert", summary[ch]["pert"],
    "G2", summary[ch]["G2"],
    "G3", summary[ch]["G3"],
    "pertG2", summary[ch]["pertG2"],
    "total", summary[ch]["total"],
    _, $Failed
  ]
];

AlphaSCorrectedMomentFromSummary[
  summary_Association,
  channel_String,
  order_String : "total",
  kFactors_: <||>,
  alphaVal_: Automatic,
  params_: $BcMixingDefaultParameters
] := Module[
  {ch = ValidateChannel[channel], ord = ValidateOrder[order], entry, pertK},
  If[! KeyExistsQ[summary, ch], Return[$Failed]];
  entry = summary[ch];
  pertK = PerturbativeKMultiplier[ch, kFactors, alphaVal, params] entry["pert"];
  Switch[
    ord,
    "pert", pertK,
    "G2", entry["G2"],
    "G3", entry["G3"],
    "pertG2", pertK + entry["G2"],
    "total", pertK + entry["G2"] + entry["G3"],
    _, $Failed
  ]
];

MixingAngleFromMomentValues[aa_?NumericQ, ab_?NumericQ, bb_?NumericQ] :=
  NormalizeMixingAngle[1/2 ArcTan[aa - bb, -2 ab]];

MixingAngleDegreesFromMomentValues[aa_?NumericQ, ab_?NumericQ, bb_?NumericQ] :=
  N[180/Pi MixingAngleFromMomentValues[aa, ab, bb]];

MixingAngleFromSummary[summary_Association, order_String : "total"] := Module[
  {aa, ab, bb},
  aa = MomentFromSummary[summary, "AA", order];
  ab = MomentFromSummary[summary, "AB", order];
  bb = MomentFromSummary[summary, "BB", order];
  If[MemberQ[{aa, ab, bb}, $Failed], Return[$Failed]];
  MixingAngleFromMomentValues[aa, ab, bb]
];

MixingAngleDegreesFromSummary[summary_Association, order_String : "total"] := Module[
  {theta = MixingAngleFromSummary[summary, order]},
  If[theta === $Failed, $Failed, N[180/Pi theta]]
];

AlphaSCorrectedMixingAngleFromSummary[
  summary_Association,
  kFactors_: <||>,
  alphaVal_: Automatic,
  order_String : "total",
  params_: $BcMixingDefaultParameters
] := Module[
  {aa, ab, bb},
  aa = AlphaSCorrectedMomentFromSummary[summary, "AA", order, kFactors, alphaVal, params];
  ab = AlphaSCorrectedMomentFromSummary[summary, "AB", order, kFactors, alphaVal, params];
  bb = AlphaSCorrectedMomentFromSummary[summary, "BB", order, kFactors, alphaVal, params];
  If[MemberQ[{aa, ab, bb}, $Failed], Return[$Failed]];
  MixingAngleFromMomentValues[aa, ab, bb]
];

AlphaSCorrectedMixingAngleDegreesFromSummary[
  summary_Association,
  kFactors_: <||>,
  alphaVal_: Automatic,
  order_String : "total",
  params_: $BcMixingDefaultParameters
] := Module[
  {theta = AlphaSCorrectedMixingAngleFromSummary[summary, kFactors, alphaVal, order, params]},
  If[theta === $Failed, $Failed, N[180/Pi theta]]
];

NumericMixingAngleWithKFactorsDegrees[
  m2Val_?NumericQ,
  continuumVal_?NumericQ,
  kFactors_: <||>,
  alphaVal_: Automatic,
  order_String : "total",
  params_: $BcMixingDefaultParameters,
  opts : OptionsPattern[NumericBorelPi]
] := Module[
  {summary = NumericOPESummary[m2Val, continuumVal, params, opts]},
  AlphaSCorrectedMixingAngleDegreesFromSummary[summary, kFactors, alphaVal, order, params]
];

KFactorSensitivityRecordFromSummary[
  summary_Association,
  m2Val_?NumericQ,
  continuumVal_?NumericQ,
  kFactors_: <||>,
  alphaVal_: Automatic,
  order_String : "total",
  params_: $BcMixingDefaultParameters
] := Module[
  {assoc = NormalizeKFactors[kFactors], alpha = AlphaSValue[alphaVal, params],
   thetaBase, thetaK, aaK, abK, bbK},
  thetaBase = MixingAngleDegreesFromSummary[summary, order];
  thetaK = AlphaSCorrectedMixingAngleDegreesFromSummary[summary, assoc, alpha, order, params];
  aaK = AlphaSCorrectedMomentFromSummary[summary, "AA", order, assoc, alpha, params];
  abK = AlphaSCorrectedMomentFromSummary[summary, "AB", order, assoc, alpha, params];
  bbK = AlphaSCorrectedMomentFromSummary[summary, "BB", order, assoc, alpha, params];
  <|
    "M2" -> N[m2Val],
    "s0" -> N[continuumVal],
    "Order" -> order,
    "alphaS" -> N[alpha],
    "KAA" -> assoc["AA"],
    "KAB" -> assoc["AB"],
    "KBB" -> assoc["BB"],
    "MultiplierAA" -> N[PerturbativeKMultiplier["AA", assoc, alpha, params]],
    "MultiplierAB" -> N[PerturbativeKMultiplier["AB", assoc, alpha, params]],
    "MultiplierBB" -> N[PerturbativeKMultiplier["BB", assoc, alpha, params]],
    "PiAAAlphaS" -> aaK,
    "PiABAlphaS" -> abK,
    "PiBBAlphaS" -> bbK,
    "ThetaBaseDeg" -> thetaBase,
    "ThetaAlphaSDeg" -> thetaK,
    "DeltaThetaDeg" -> NormalizeMixingAngleDegrees[thetaK - thetaBase]
  |>
];

KFactorSensitivityRecord[
  m2Val_?NumericQ,
  continuumVal_?NumericQ,
  kFactors_: <||>,
  alphaVal_: Automatic,
  order_String : "total",
  params_: $BcMixingDefaultParameters,
  opts : OptionsPattern[NumericBorelPi]
] := Module[
  {summary = NumericOPESummary[m2Val, continuumVal, params, opts]},
  KFactorSensitivityRecordFromSummary[summary, m2Val, continuumVal, kFactors, alphaVal, order, params]
];

KFactorSensitivityGrid[
  m2Val_?NumericQ,
  continuumVal_?NumericQ,
  kSpec_,
  alphaVal_: Automatic,
  order_String : "total",
  params_: $BcMixingDefaultParameters,
  opts : OptionsPattern[NumericBorelPi]
] :=
  KFactorSensitivityGrid[
    m2Val, continuumVal, kSpec, kSpec, kSpec, alphaVal, order, params, opts
  ];

KFactorSensitivityGrid[
  m2Val_?NumericQ,
  continuumVal_?NumericQ,
  kAASpec_,
  kABSpec_,
  kBBSpec_,
  alphaVal_: Automatic,
  order_String : "total",
  params_: $BcMixingDefaultParameters,
  opts : OptionsPattern[NumericBorelPi]
] := Module[
  {kAAVals = ScanValues[kAASpec], kABVals = ScanValues[kABSpec], kBBVals = ScanValues[kBBSpec],
   summary},
  If[MemberQ[{kAAVals, kABVals, kBBVals}, $Failed], Return[$Failed]];
  summary = NumericOPESummary[m2Val, continuumVal, params, opts];
  Flatten[
    Table[
      KFactorSensitivityRecordFromSummary[
        summary,
        m2Val,
        continuumVal,
        KFactorAssociation[kAA, kAB, kBB],
        alphaVal,
        order,
        params
      ],
      {kAA, kAAVals},
      {kAB, kABVals},
      {kBB, kBBVals}
    ],
    2
  ]
];

KFactorSensitivityDataset[args___] :=
  Dataset[KFactorSensitivityGrid[args]];

KFactorSensitivityEnvelope[args___] := Module[
  {records = KFactorSensitivityGrid[args], angles, deltas, minPos, maxPos, maxAbsPos},
  If[records === $Failed || records === {}, Return[$Failed]];
  angles = Lookup[records, "ThetaAlphaSDeg"];
  deltas = Lookup[records, "DeltaThetaDeg"];
  minPos = First[Ordering[angles, 1]];
  maxPos = First[Ordering[angles, -1]];
  maxAbsPos = First[Ordering[Abs[deltas], -1]];
  <|
    "ThetaBaseDeg" -> records[[1, "ThetaBaseDeg"]],
    "ThetaMinDeg" -> angles[[minPos]],
    "ThetaMaxDeg" -> angles[[maxPos]],
    "DeltaThetaMinDeg" -> Min[deltas],
    "DeltaThetaMaxDeg" -> Max[deltas],
    "MaxAbsDeltaThetaDeg" -> Abs[deltas[[maxAbsPos]]],
    "RecordAtMinTheta" -> records[[minPos]],
    "RecordAtMaxTheta" -> records[[maxPos]],
    "RecordAtMaxAbsDelta" -> records[[maxAbsPos]]
  |>
];

(* ---------------------------------------------------------------------- *)
(* Borel-window and continuum-threshold scan helpers                       *)
(* ---------------------------------------------------------------------- *)

BcMixingMomentum::badscan =
  "Scan specification `1` is not valid. Use {min,max,step} or an explicit numeric list.";

ScanValues[spec : {_?NumericQ, _?NumericQ, _?NumericQ}] := Module[
  {min = spec[[1]], max = spec[[2]], step = spec[[3]], vals},
  If[step == 0 || Sign[max - min] =!= Sign[step],
    Message[BcMixingMomentum::badscan, spec];
    Return[$Failed]
  ];
  vals = Range[min, max, step];
  If[vals === {} || Abs[Last[vals] - max] > 10^-10,
    vals = Append[vals, max]
  ];
  N[vals]
];

ScanValues[spec_List] /; VectorQ[spec, NumericQ] := N[spec];

ScanValues[spec_] := (
  Message[BcMixingMomentum::badscan, spec];
  $Failed
);

NumericMomentRecord[
  m2Val_?NumericQ,
  continuumVal_?NumericQ,
  order_String : "pert",
  params_: $BcMixingDefaultParameters,
  opts : OptionsPattern[NumericBorelPi]
] := Module[
  {aa, ab, bb, thetaRaw, theta},
  aa = NumericBorelPi["AA", order, m2Val, continuumVal, params, opts];
  ab = NumericBorelPi["AB", order, m2Val, continuumVal, params, opts];
  bb = NumericBorelPi["BB", order, m2Val, continuumVal, params, opts];
  If[MemberQ[{aa, ab, bb}, $Failed], Return[$Failed]];
  thetaRaw = 1/2 ArcTan[aa - bb, -2 ab];
  theta = NormalizeMixingAngle[thetaRaw];
  <|
    "M2" -> N[m2Val],
    "s0" -> N[continuumVal],
    "Order" -> order,
    "PiAA" -> aa,
    "PiAB" -> ab,
    "PiBB" -> bb,
    "ThetaRawDeg" -> N[180/Pi thetaRaw],
    "ThetaDeg" -> N[180/Pi theta]
  |>
];

Options[MixingAngleScan] = Options[NumericBorelPi];

MixingAngleScan[
  m2Spec_,
  s0Spec_,
  order_String : "pert",
  params_: $BcMixingDefaultParameters,
  opts : OptionsPattern[]
] := Module[
  {m2Vals = ScanValues[m2Spec], s0Vals = ScanValues[s0Spec], records},
  If[m2Vals === $Failed || s0Vals === $Failed, Return[$Failed]];
  records = Flatten[
    Table[
      NumericMomentRecord[m2v, s0v, order, params, opts],
      {m2v, m2Vals},
      {s0v, s0Vals}
    ],
    1
  ];
  DeleteCases[records, $Failed]
];

MixingAngleDataset[
  m2Spec_,
  s0Spec_,
  order_String : "pert",
  params_: $BcMixingDefaultParameters,
  opts : OptionsPattern[MixingAngleScan]
] :=
  Dataset[MixingAngleScan[m2Spec, s0Spec, order, params, opts]];

MixingAngleMatrix[
  m2Spec_,
  s0Spec_,
  order_String : "pert",
  params_: $BcMixingDefaultParameters,
  opts : OptionsPattern[MixingAngleScan]
] := Module[
  {m2Vals = ScanValues[m2Spec], s0Vals = ScanValues[s0Spec], matrix},
  If[m2Vals === $Failed || s0Vals === $Failed, Return[$Failed]];
  matrix = Table[
    NumericMixingAngleDegrees[m2v, s0v, order, params, opts],
    {m2v, m2Vals},
    {s0v, s0Vals}
  ];
  <|
    "M2Values" -> m2Vals,
    "s0Values" -> s0Vals,
    "ThetaDegMatrix" -> matrix
  |>
];

MixingAngleTable[
  m2Spec_,
  s0Spec_,
  order_String : "pert",
  params_: $BcMixingDefaultParameters,
  opts : OptionsPattern[MixingAngleScan]
] := Module[
  {data = MixingAngleMatrix[m2Spec, s0Spec, order, params, opts]},
  If[data === $Failed, Return[$Failed]];
  Grid[
    Prepend[
      MapThread[Prepend, {data["ThetaDegMatrix"], data["M2Values"]}],
      Prepend[data["s0Values"], "M2 \\ s0"]
    ],
    Frame -> All,
    Alignment -> Center
  ]
];

OPEConvergenceRecord[
  m2Val_?NumericQ,
  continuumVal_?NumericQ,
  params_: $BcMixingDefaultParameters,
  opts : OptionsPattern[NumericBorelPi]
] := Module[
  {summary, g2Ratios, g3Ratios, thetaPert, thetaPertG2, thetaTotal},
  summary = NumericOPESummary[m2Val, continuumVal, params, opts];
  g2Ratios = AssociationMap[summary[#]["G2OverPert"] &, {"AA", "AB", "BB"}];
  g3Ratios = AssociationMap[summary[#]["G3OverPert"] &, {"AA", "AB", "BB"}];
  thetaPert = NumericMixingAngleDegrees[m2Val, continuumVal, "pert", params, opts];
  thetaPertG2 = NumericMixingAngleDegrees[m2Val, continuumVal, "pertG2", params, opts];
  thetaTotal = NumericMixingAngleDegrees[m2Val, continuumVal, "total", params, opts];
  <|
    "M2" -> N[m2Val],
    "s0" -> N[continuumVal],
    "AA_G2OverPert" -> g2Ratios["AA"],
    "AB_G2OverPert" -> g2Ratios["AB"],
    "BB_G2OverPert" -> g2Ratios["BB"],
    "MaxAbsG2OverPert" -> Max[Abs[Values[g2Ratios]]],
    "AA_G3OverPert" -> g3Ratios["AA"],
    "AB_G3OverPert" -> g3Ratios["AB"],
    "BB_G3OverPert" -> g3Ratios["BB"],
    "MaxAbsG3OverPert" -> Max[Abs[Values[g3Ratios]]],
    "ThetaPertDeg" -> thetaPert,
    "ThetaPertG2Deg" -> thetaPertG2,
    "ThetaTotalDeg" -> thetaTotal,
    "DeltaThetaG2Deg" -> thetaPertG2 - thetaPert,
    "DeltaThetaG3Deg" -> thetaTotal - thetaPertG2,
    "DeltaThetaTotalDeg" -> thetaTotal - thetaPert
  |>
];

Options[OPEConvergenceScan] = Options[NumericBorelPi];

OPEConvergenceScan[
  m2Spec_,
  s0Spec_,
  params_: $BcMixingDefaultParameters,
  opts : OptionsPattern[]
] := Module[
  {m2Vals = ScanValues[m2Spec], s0Vals = ScanValues[s0Spec]},
  If[m2Vals === $Failed || s0Vals === $Failed, Return[$Failed]];
  Flatten[
    Table[
      OPEConvergenceRecord[m2v, s0v, params, opts],
      {m2v, m2Vals},
      {s0v, s0Vals}
    ],
    1
  ]
];

OPEConvergenceDataset[
  m2Spec_,
  s0Spec_,
  params_: $BcMixingDefaultParameters,
  opts : OptionsPattern[OPEConvergenceScan]
] :=
  Dataset[OPEConvergenceScan[m2Spec, s0Spec, params, opts]];

OPESummary[
  m2Val_?NumericQ,
  continuumVal_?NumericQ,
  params_: $BcMixingDefaultParameters
] :=
  NumericOPESummary[m2Val, continuumVal, params];

OPESummary[m2_: M2, continuum_: s0, params_: $BcMixingDefaultParameters] := Association[
  Table[
	    ch -> <|
	      "pert" -> Quiet[N[BorelPi[ch, "pert", m2, continuum] /. ParameterRules[params]]],
	      "G2" -> Quiet[N[BorelPi[ch, "G2", m2, continuum] /. ParameterRules[params]]],
	      "G3" -> Quiet[N[BorelPi[ch, "G3", m2, continuum] /. ParameterRules[params]]],
	      "pertG2" -> Quiet[N[BorelPi[ch, "pertG2", m2, continuum] /. ParameterRules[params]]],
	      "total" -> Quiet[N[BorelPi[ch, "total", m2, continuum] /. ParameterRules[params]]],
	      "G2OverPert" -> Quiet[
	        N[
	          BorelPi[ch, "G2", m2, continuum]/
	          BorelPi[ch, "pert", m2, continuum] /. ParameterRules[params]
	        ]
	      ],
	      "G3OverPert" -> Quiet[
	        N[
	          BorelPi[ch, "G3", m2, continuum]/
	          BorelPi[ch, "pert", m2, continuum] /. ParameterRules[params]
	        ]
	      ]
	    |>,
    {ch, {"AA", "AB", "BB"}}
  ]
];

PlotMixingAngle[m2Range : {_?NumericQ, _?NumericQ}, continuum_?NumericQ, params_: $BcMixingDefaultParameters, order_String : "pert"] :=
  Module[{m2var},
    Plot[
      NumericMixingAngleDegrees[m2var, continuum, order, params],
      {m2var, m2Range[[1]], m2Range[[2]]},
      AxesLabel -> {"M^2", "theta [deg]"},
      PlotLabel -> Row[{"B_c mixing angle vs M^2, s0 = ", continuum, ", order = ", order}],
      GridLines -> Automatic
    ]
  ];

PlotMixingAngleS0[fixedM2_?NumericQ, s0Range : {_?NumericQ, _?NumericQ}, params_: $BcMixingDefaultParameters, order_String : "pert"] :=
  Module[{s0var},
    Plot[
      NumericMixingAngleDegrees[fixedM2, s0var, order, params],
      {s0var, s0Range[[1]], s0Range[[2]]},
      AxesLabel -> {"s0", "theta [deg]"},
      PlotLabel -> Row[{"B_c mixing angle vs s0, M^2 = ", fixedM2, ", order = ", order}],
      GridLines -> Automatic
    ]
  ];

MixingAngleContourPlot[m2Range : {_?NumericQ, _?NumericQ}, s0Range : {_?NumericQ, _?NumericQ}, params_: $BcMixingDefaultParameters, order_String : "pert"] :=
  Module[{m2var, s0var},
    ContourPlot[
      NumericMixingAngleDegrees[m2var, s0var, order, params],
      {m2var, m2Range[[1]], m2Range[[2]]},
      {s0var, s0Range[[1]], s0Range[[2]]},
      FrameLabel -> {"M^2", "s0"},
      PlotLabel -> Row[{"B_c mixing angle [deg], order = ", order}],
      Contours -> 12,
      ColorFunction -> "TemperatureMap",
      PlotLegends -> Automatic
    ]
  ];

Print["Loaded BcMixingMomentum.wl.  Run CheckEnvironment[] for setup information."];

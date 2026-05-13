(* ::Package:: *)

(*  BcMixingMomentum.wl

    Momentum-space QCD sum-rule algebra for B_c axial-vector mixing.

    System:
      B_c^+ = \bar b c

    Currents:
      J_A[mu] = \bar b gamma_mu gamma_5 c
      J_B[mu] = i \bar b sigma_{mu alpha} p^alpha gamma_5 c

    Implemented OPE terms:
      - perturbative heavy-heavy loop
      - dimension-4 gluon condensate <g_s^2 G^2>

    Not implemented in v1:
      - dimension-6 triple-gluon condensate <g_s^3 G^3>

    Notes:
      1. The tensor-current factor i is normally removed from the real
         invariant functions after combining current, conjugate current and
         the overall i in the correlator definition.  Therefore the default
         algebraic B vertex below is sigma.p gamma_5.  Set
         $BcMixingKeepRawTensorI = True before evaluating correlators if you
         want the raw vertex i sigma.p gamma_5 instead.
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
  "Unknown OPE order `1`. Valid orders are \"pert\", \"G2c\", \"G2b\", \"G2gg\", \"G2\", \"total\" and \"G3\".";
BcMixingMomentum::g3 =
  "The <g_s^3 G^3> contribution is not implemented in this v1 file.";

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
  mb, mc, M2, s0, s, G2, eps,
  k, p, mu, nu, al, be, rh, si, x, z
];

$BcMixingNc = 3;
$BcMixingKeepRawTensorI = False;
$BcMixingChannels = <|
  "AA" -> {"A", "A"},
  "AB" -> {"A", "B"},
  "BA" -> {"B", "A"},
  "BB" -> {"B", "B"}
|>;

$BcMixingOrders = {"pert", "G2c", "G2b", "G2gg", "G2", "total", "G3"};
$BcMixingSpectralDensities = <||>;

$BcMixingDefaultParameters = <|
  "mb" -> 4.18,
  "mc" -> 1.27,
  "G2" -> 4 Pi^2 0.012,
  "M2" -> 10.0,
  "s0" -> 55.0
|>;

$Assumptions =
  Element[{mb, mc, M2, s0, s, G2}, Reals] &&
  mb > 0 && mc > 0 && M2 > 0 && s0 > (mb + mc)^2 && G2 >= 0;

ClearBcMixingCache[] := Null;

ParameterRules[assoc_: $BcMixingDefaultParameters] := {
  mb -> assoc["mb"],
  mc -> assoc["mc"],
  G2 -> assoc["G2"],
  M2 -> assoc["M2"],
  s0 -> assoc["s0"]
};

BcThreshold[] := (mb + mc)^2;

CheckEnvironment[] := <|
  "FeynCalcLoaded" -> TrueQ[ValueQ[$FeynCalcVersion]],
  "FeynCalcVersion" -> If[TrueQ[ValueQ[$FeynCalcVersion]], $FeynCalcVersion, Missing["NotLoaded"]],
  "TensorCurrentKeepsRawI" -> $BcMixingKeepRawTensorI,
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

CurrentVertex["A", lor_] := GA[lor] . GA[5];

CurrentVertex["B", lor_] := Module[
  {phase = If[TrueQ[$BcMixingKeepRawTensorI], I, 1]},
  phase DiracSigma[GA[lor], GS[p]] . GA[5]
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

LoopIntegrand[channel_String, "total"] :=
  LoopIntegrand[channel, "pert"] + LoopIntegrand[channel, "G2"] // Simplify;

LoopIntegrand[channel_String, "G3"] := (
  Message[BcMixingMomentum::g3];
  0
);

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
  order === "total", SpectralDensityDefinedQ[channel, "pert"] && SpectralDensityDefinedQ[channel, "G2"],
  True, False
];

SetSpectralDensity[channel_String, order_String, expr_, var_: s] := Module[
  {ch = ValidateChannel[channel], ord = ValidateOrder[order]},
  $BcMixingSpectralDensities[{ch, ord}] = Function[{z}, Evaluate[expr /. var -> z]];
  {ch, ord}
];

ClearSpectralDensities[] := ($BcMixingSpectralDensities = <||>;);

SpectralDensity[channel_String, order_String, var_: s] := Module[
  {ch = ValidateChannel[channel], ord = ValidateOrder[order]},
  Which[
    KeyExistsQ[$BcMixingSpectralDensities, {ch, ord}],
      $BcMixingSpectralDensities[{ch, ord}][var],
    ord === "G2",
      Total[SpectralDensity[ch, #, var] & /@ {"G2c", "G2b", "G2gg"}],
    ord === "total",
      SpectralDensity[ch, "pert", var] + SpectralDensity[ch, "G2", var],
    ord === "G3",
      Message[BcMixingMomentum::g3]; 0,
    True,
      rho[ch, ord][var]
  ]
];

Options[BorelPi] = {
  "InactiveWhenFormal" -> True,
  Assumptions -> Automatic
};

BorelPi[channel_String, order_String : "total", m2_: M2, continuum_: s0, OptionsPattern[]] := Module[
  {var = Unique["s"], density, lower, head, asm},
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

  head[Exp[-var/m2] density, {var, lower, continuum}, Assumptions -> asm]
];

MixingAngle[m2_: M2, continuum_: s0, order_String : "total"] :=
  1/2 ArcTan[
    BorelPi["AA", order, m2, continuum] - BorelPi["BB", order, m2, continuum],
    -2 BorelPi["AB", order, m2, continuum]
  ];

MixingAngleDegrees[m2_: M2, continuum_: s0, order_String : "total"] :=
  180/Pi MixingAngle[m2, continuum, order];

OPESummary[m2_: M2, continuum_: s0, params_: $BcMixingDefaultParameters] := Association[
  Table[
    ch -> <|
      "pert" -> Quiet[N[BorelPi[ch, "pert", m2, continuum] /. ParameterRules[params]]],
      "G2" -> Quiet[N[BorelPi[ch, "G2", m2, continuum] /. ParameterRules[params]]],
      "total" -> Quiet[N[BorelPi[ch, "total", m2, continuum] /. ParameterRules[params]]],
      "G2OverPert" -> Quiet[
        N[
          BorelPi[ch, "G2", m2, continuum]/
          BorelPi[ch, "pert", m2, continuum] /. ParameterRules[params]
        ]
      ]
    |>,
    {ch, {"AA", "AB", "BB"}}
  ]
];

PlotMixingAngle[m2Range : {_, _}, continuum_, params_: $BcMixingDefaultParameters, order_String : "total"] :=
  Module[{m2var},
    Plot[
      Evaluate[MixingAngleDegrees[m2var, continuum, order] /. ParameterRules[params]],
      {m2var, m2Range[[1]], m2Range[[2]]},
      AxesLabel -> {"M^2", "theta [deg]"},
      PlotLabel -> Row[{"B_c mixing angle, order = ", order}],
      GridLines -> Automatic
    ]
  ];

Print["Loaded BcMixingMomentum.wl.  Run CheckEnvironment[] for setup information."];

(* ::Package:: *)

(*  BcMixingAlphaSTensorBB.wl

    Helper layer for importing the tensor-current NLO result of

      T. Generet, "Correlator with tensor currents and two masses at two loops",
      Eur. Phys. J. C 86 (2026) 112.

    The file deliberately does not modify BcMixingMomentum.wl or
    BcMixingAlphaS.wl.  It provides reproducible diagnostics for matching the
    paper's tensor-current convention to our normalized B-current convention,

      J_B^mu = i \bar b sigma^{mu alpha} p_alpha gamma_5 c/(m_b + m_c).

    Matching convention found from the LO cut:

      rho_BB,ours = 3/(m_b + m_c)^2 * Im Pi_AT,paper/Pi,

    where Pi_AT is obtained from the paper's tensor result by m1 -> -m1.
    Since the paper's Im_NLO_TT_MSbar.m includes an explicit alpha_s, the
    rho_1 convention used by BcMixingAlphaS.wl,

      rho = rho_0 + alpha_s/Pi rho_1,

    corresponds to

      rho_1_BB,ours = 3/(m_b + m_c)^2 * Im Pi_NLO_AT,paper/alpha_s.
*)

If[! TrueQ[ValueQ[$BcMixingAlphaSDirectory]],
  Get[FileNameJoin[{Directory[], "BcMixingAlphaS.wl"}]]
];

$BcAlphaSTensorBBDirectory = If[
  StringQ[$InputFileName] && StringLength[$InputFileName] > 0,
  DirectoryName[$InputFileName],
  Directory[]
];

$TensorPaperAncillaryDirectory =
  FileNameJoin[{$BcAlphaSTensorBBDirectory, "external", "arxiv_2509_02776_anc"}];

$TensorPaperLOTTFile =
  FileNameJoin[{$TensorPaperAncillaryDirectory, "LO_TT.m"}];

$TensorPaperImNLOTTMSbarFile =
  FileNameJoin[{$TensorPaperAncillaryDirectory, "Im_NLO_TT_MSbar.m"}];

ClearAll[
  Kallen\[Lambda],
  TensorPaperKallenLambda,
  TensorPaperLOTTFinite,
  TensorPaperImNLOTTMSbar,
  TensorPaperAxialTensorLOImOverPi,
  TensorPaperBBLOMatchingCheck,
  TensorPaperBBRho1MSbar,
  TensorPaperBBNLOMomentMSbar,
  TensorPaperBBNLOMomentSummary,
  InstallTensorPaperBBNLOMSbar
];

TensorPaperKallenLambda[x_, y_, z_] :=
  x^2 + y^2 + z^2 - 2 x y - 2 x z - 2 y z;

Kallen\[Lambda][x_, y_, z_] := TensorPaperKallenLambda[x, y, z];

TensorPaperLOTTFinite[] := TensorPaperLOTTFinite[] = Module[
  {expr},
  If[! FileExistsQ[$TensorPaperLOTTFile],
    Return[Failure["MissingFile", <|"File" -> $TensorPaperLOTTFile|>]]
  ];
  expr = Get[$TensorPaperLOTTFile];
  SeriesCoefficient[expr, 0]
];

TensorPaperImNLOTTMSbar[] := TensorPaperImNLOTTMSbar[] = Module[
  {},
  If[! FileExistsQ[$TensorPaperImNLOTTMSbarFile],
    Return[Failure["MissingFile", <|"File" -> $TensorPaperImNLOTTMSbarFile|>]]
  ];
  Get[$TensorPaperImNLOTTMSbarFile]
];

TensorPaperAxialTensorLOImOverPi[
  ss_?NumericQ,
  params_: $BcMixingDefaultParameters,
  q2ImaginaryPart_: 10^-8
] := Module[
  {rules = ParameterRules[params], mbv, mcv, muval, expr},
  mbv = mb /. rules;
  mcv = mc /. rules;
  muval = mbv;
  expr = TensorPaperLOTTFinite[];
  If[FailureQ[expr], Return[expr]];
  N[
    Im[
      expr /. {
        q2 -> ss + I q2ImaginaryPart,
        m1 -> -mbv,
        m2 -> mcv,
        mu -> muval
      }
    ]/Pi
  ]
];

TensorPaperBBLOMatchingCheck[
  sValues_List : {35., 40., 50.},
  params_: $BcMixingDefaultParameters
] := Module[
  {rules = ParameterRules[params], mbv, mcv, scale},
  mbv = mb /. rules;
  mcv = mc /. rules;
  scale = (mbv + mcv)^2;
  Association /@ Table[
    With[
      {
        our = N[PerturbativeSpectralDensity["BB", ss] /. rules],
        paper = TensorPaperAxialTensorLOImOverPi[ss, params]
      },
      <|
        "s" -> ss,
        "rho0BBOurNormalized" -> our,
        "rho0BBOurUnnormalized" -> N[scale our],
        "paperAxialTensorImOverPi" -> paper,
        "paperOverOurUnnormalized" -> N[paper/(scale our)],
        "matchedPaperToOurNormalized" -> N[3 paper/scale],
        "matchedMinusOurNormalized" -> N[3 paper/scale - our]
      |>
    ],
    {ss, sValues}
  ]
];

Options[TensorPaperBBRho1MSbar] = {"Mu" -> Automatic};

TensorPaperBBRho1MSbar[
  ss_?NumericQ,
  params_: $BcMixingDefaultParameters,
  OptionsPattern[]
] := Module[
  {rules = ParameterRules[params], mbv, mcv, muval, expr},
  mbv = mb /. rules;
  mcv = mc /. rules;
  muval = Replace[OptionValue["Mu"], Automatic -> mbv];
  expr = TensorPaperImNLOTTMSbar[];
  If[FailureQ[expr], Return[expr]];
  Chop @ N[
    3/(mbv + mcv)^2 *
      (expr /. {
        m1 -> -mbv,
        m2 -> mcv,
        mu -> muval,
        s -> ss,
        \[Alpha]s -> 1,
        HeavisideTheta[_] -> 1
      })
  ]
];

Options[TensorPaperBBNLOMomentMSbar] =
  Join[Options[NIntegrate], Options[TensorPaperBBRho1MSbar]];

TensorPaperBBNLOMomentMSbar[
  m2Val_?NumericQ,
  continuumVal_?NumericQ,
  params_: $BcMixingDefaultParameters,
  opts : OptionsPattern[]
] := Module[
  {rules = ParameterRules[params], lower, muOpt, nintOpts},
  lower = N[BcThreshold[] /. rules];
  muOpt = OptionValue["Mu"];
  nintOpts = FilterRules[{opts}, Options[NIntegrate]];
  NIntegrate[
    Exp[-ss/m2Val] TensorPaperBBRho1MSbar[ss, params, "Mu" -> muOpt],
    {ss, lower, continuumVal},
    Evaluate[Sequence @@ nintOpts]
  ]
];

Options[TensorPaperBBNLOMomentSummary] =
  Options[TensorPaperBBNLOMomentMSbar];

TensorPaperBBNLOMomentSummary[
  m2Val_: 8.,
  continuumVal_: 54.,
  params_: $BcMixingDefaultParameters,
  opts : OptionsPattern[]
] := Module[
  {alpha = MergeDefaultParameters[params]["alphaS"], lo, nlo},
  lo = NumericBorelPi["BB", "pert", m2Val, continuumVal, params];
  nlo = Chop[TensorPaperBBNLOMomentMSbar[m2Val, continuumVal, params, opts]];
  <|
    "M2" -> m2Val,
    "s0" -> continuumVal,
    "PiBB_LOPert" -> lo,
    "PiBB_NLOBareRho1_MSbar" -> nlo,
    "AlphaSOverPi_NLOMoment" -> alpha/Pi nlo,
    "RelativeBBPertShift" -> alpha/Pi nlo/lo
  |>
];

InstallTensorPaperBBNLOMSbar[params_: $BcMixingDefaultParameters, muOpt_: Automatic] := Module[
  {rules = ParameterRules[params], mbv, mcv, muval, expr},
  mbv = mb /. rules;
  mcv = mc /. rules;
  muval = Replace[muOpt, Automatic -> mbv];
  expr = TensorPaperImNLOTTMSbar[];
  If[FailureQ[expr], Return[expr]];
  SetAlphaSNLOSpectralDensity[
    "BB",
    3/(mbv + mcv)^2 *
      (expr /. {
        m1 -> -mbv,
        m2 -> mcv,
        mu -> muval,
        \[Alpha]s -> 1,
        HeavisideTheta[_] -> 1
      }),
    s
  ]
];

Print["Loaded BcMixingAlphaSTensorBB.wl. Run TensorPaperBBLOMatchingCheck[] and TensorPaperBBNLOMomentSummary[]."];

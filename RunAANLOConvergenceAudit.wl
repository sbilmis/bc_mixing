(* ::Package:: *)

(* Run with, for example:

   WOLFRAMSCRIPT_KERNELPATH=/Applications/Wolfram.app/Contents/MacOS/WolframKernel \
   wolframscript -file RunAANLOConvergenceAudit.wl

   The output CSV files are diagnostic only.  They are meant to test the
   convergence and threshold sensitivity of the AA perturbative O(alpha_s)
   correction, not to define the final NLO prediction.
*)

SetDirectory[DirectoryName[$InputFileName]];
Print["Starting AA NLO convergence audit in ", Directory[]];
Print["Loading BcMixingAlphaS.wl ..."];
Get["BcMixingAlphaS.wl"];
Print["Loaded BcMixingAlphaS.wl."];

$AuditParams = $BcMixingDefaultParameters;
$AuditAlpha = MergeDefaultParameters[$AuditParams]["alphaS"];
$AuditNPoints = 6;

Clear[aaSummaryRow];
aaSummaryRow[m2_?NumericQ, s0_?NumericQ, scale_: Automatic] := Module[
  {opts, summary, lo, nloShift, rel, virtual, integrated, real},
  opts = {
    "NPoints" -> $AuditNPoints,
    "Progress" -> True,
    AccuracyGoal -> 5,
    PrecisionGoal -> 5,
    MaxRecursion -> 4
  };
  summary = IndependentAAFinalNLOBorelSummary[
    m2, s0, $AuditParams,
    Sequence @@ opts,
    "RenormalizationScale" -> scale
  ];
  If[summary === $Failed, Return[$Failed]];
  lo = summary["LOPerturbativeMoment"];
  nloShift = summary["AlphaSOverPiNLOShift"];
  rel = summary["RelativeNLOShift"];
  virtual = summary["VirtualPlusFieldFiniteBorelRho1"];
  integrated = summary["IntegratedDipolesFiniteBorelRho1"];
  real = summary["RealMinusDipolesBorelRho1"];
  {
    m2, s0, Replace[scale, Automatic -> "sqrt(s)"],
    lo,
    summary["BareRho1BorelMoment"],
    nloShift,
    rel,
    virtual,
    integrated,
    real,
    summary["BreakdownClosure"]
  }
];

Clear[aaCutMoment];
aaCutMoment[m2_?NumericQ, s0_?NumericQ, delta_?NumericQ,
    scale_: Automatic] := Module[
  {rules, threshold, lower, range, quadrature, rows, total, virtualTotal,
   integratedTotal, realTotal, lo, nloShift},
  rules = DynamicParameterRules[$AuditParams];
  threshold = N[BcThreshold[] /. rules];
  lower = threshold + delta;
  If[s0 <= lower, Return[$Failed]];
  range = s0 - lower;
  quadrature = IndependentAAGaussLegendreRule[$AuditNPoints];
  rows = Map[
    Function[node,
      Module[{z, weight, ssVal, jac, rhoData, rhoOpts},
        {z, weight} = node;
        ssVal = lower + range z^2;
        jac = 2 range z;
        rhoOpts = {"RenormalizationScale" -> scale};
        rhoData = IndependentAAFinalRho1Numeric[
          ssVal, $AuditParams, Sequence @@ rhoOpts
        ];
        If[rhoData === $Failed, Return[$Failed]];
        <|
          "s" -> ssVal,
          "Weight" -> weight,
          "BorelFactor" -> weight jac Exp[-ssVal/m2],
          "Rho1" -> rhoData["TotalRho1"],
          "Breakdown" -> rhoData
        |>
      ]
    ],
    quadrature
  ];
  If[MemberQ[rows, $Failed], Return[$Failed]];
  total = Total[Lookup[rows, "BorelFactor"] Lookup[rows, "Rho1"]];
  virtualTotal = Total[
    Lookup[rows, "BorelFactor"] *
      Lookup[Lookup[rows, "Breakdown"], "VirtualPlusFieldFiniteRho1"]
  ];
  integratedTotal = Total[
    Lookup[rows, "BorelFactor"] *
      Lookup[Lookup[rows, "Breakdown"], "IntegratedDipolesFiniteRho1"]
  ];
  realTotal = Total[
    Lookup[rows, "BorelFactor"] *
      Lookup[Lookup[rows, "Breakdown"], "RealMinusDipolesRho1"]
  ];
  lo = NIntegrate[
    Exp[-ss/m2] (AlphaSLOSpectralDensity["AA", ss] /. rules),
    {ss, lower, s0},
    AccuracyGoal -> 6,
    PrecisionGoal -> 6,
    MaxRecursion -> 8
  ];
  nloShift = $AuditAlpha/Pi total;
  {
    m2, s0, delta, lower, lo, total, nloShift, nloShift/lo,
    virtualTotal, integratedTotal, realTotal,
    virtualTotal + integratedTotal + realTotal - total
  }
];

headers = {
  "M2", "s0", "mu", "PiAA_LO", "PiAA_rho1", "alphaOverPi_rho1",
  "relative_shift", "virtual_plus_field", "integrated_dipoles",
  "real_minus_dipoles", "breakdown_closure"
};

cutHeaders = {
  "M2", "s0", "delta", "lower", "PiAA_LO_cut", "PiAA_rho1_cut",
  "alphaOverPi_rho1_cut", "relative_shift_cut",
  "virtual_plus_field_cut", "integrated_dipoles_cut",
  "real_minus_dipoles_cut", "breakdown_closure"
};

Print["Running AA M2 scan..."];
m2Rows = DeleteCases[
  aaSummaryRow[#, 54., 4.18] & /@ {6., 7., 8., 9., 10., 11., 12.},
  $Failed
];
Export["AlphaS_AA_M2_scan.csv", Prepend[m2Rows, headers]];

Print["Running AA s0 scan..."];
s0Rows = DeleteCases[
  aaSummaryRow[8., #, 4.18] & /@ {50., 52., 54., 56., 58.},
  $Failed
];
Export["AlphaS_AA_s0_scan.csv", Prepend[s0Rows, headers]];

Print["Running AA mu scan..."];
muRows = DeleteCases[
  aaSummaryRow[8., 54., #] & /@ {2., 3., 4.18, 5.},
  $Failed
];
Export["AlphaS_AA_mu_scan.csv", Prepend[muRows, headers]];

Print["Running AA threshold-cut scan..."];
cutRows = DeleteCases[
  aaCutMoment[8., 54., #, 4.18] & /@ {0., 0.1, 0.25, 0.5, 1.0},
  $Failed
];
Export["AlphaS_AA_threshold_cut_scan.csv", Prepend[cutRows, cutHeaders]];

Print["Running AA Coulomb asymptotic check..."];
coulomb = IndependentAAThresholdCoulombCheck[
  {0.05, 0.10, 0.25, 0.50},
  $AuditParams,
  "RenormalizationScale" -> 4.18
];
Export["AlphaS_AA_coulomb_check.mx", coulomb];
Export[
  "AlphaS_AA_coulomb_check.csv",
  Prepend[
    (Lookup[#, {
       "DeltaS", "s", "RelativeVelocity", "Rho1OverRho0",
       "VelocityTimesRho1OverRho0", "ExpectedCoulombCoefficient",
       "DifferenceFromCoulombCoefficient"
     }] & /@ coulomb["Rows"]),
    {
      "DeltaS", "s", "vRel", "rho1OverRho0",
      "vRelTimesRho1OverRho0", "expectedCFPi2", "difference"
    }
  ]
];

Print["Done.  Wrote AlphaS_AA_*_scan.csv and AlphaS_AA_coulomb_check.csv."];

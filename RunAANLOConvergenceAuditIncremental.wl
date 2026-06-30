(* ::Package:: *)

(* Incremental/cached AA NLO convergence audit.

   This version is designed for long runs.  It writes CSV rows as soon as
   they are available and caches the expensive rho_1(s) evaluations, so the
   M^2 scan does not recompute the same spectral points repeatedly.

   Run with:

   /Applications/Wolfram.app/Contents/MacOS/WolframKernel -noprompt -run \
     'Get["/Users/sbilmis/Bc_mixing/RunAANLOConvergenceAuditIncremental.wl"]; Exit[]'
*)

SetDirectory[DirectoryName[$InputFileName]];
Print["Starting incremental AA NLO convergence audit in ", Directory[]];
Print["Loading BcMixingAlphaS.wl ..."];
Get["BcMixingAlphaS.wl"];
Print["Loaded BcMixingAlphaS.wl."];

$AuditParams = $BcMixingDefaultParameters;
$AuditAlpha = MergeDefaultParameters[$AuditParams]["alphaS"];
$AuditNPoints = 6;
$AuditNodeTimeLimitSeconds = 900;
$AuditRhoCache = <||>;

Clear[csvValue, appendCSVRow, resetCSV];
csvValue[x_String] := "\"" <> StringReplace[x, "\"" -> "\"\""] <> "\"";
csvValue[x_] := ToString[FortranForm[N[x, 16]]];

appendCSVRow[file_String, row_List] := Module[{stream},
  stream = OpenAppend[file];
  WriteString[stream, StringRiffle[csvValue /@ row, ","] <> "\n"];
  Close[stream];
];

resetCSV[file_String, header_List] := (
  If[FileExistsQ[file], DeleteFile[file]];
  appendCSVRow[file, header];
);

Clear[scaleLabel, scaleKey];
scaleLabel[scale_] := Replace[scale, Automatic -> "sqrt(s)"];
scaleKey[scale_] := ToString[InputForm[scaleLabel[scale]]];

Clear[getAARhoData];
getAARhoData[ssVal_?NumericQ, scale_] := Module[
  {key, result},
  key = ToString[NumberForm[ssVal, {18, 12}], InputForm] <> "|" <> scaleKey[scale];
  If[KeyExistsQ[$AuditRhoCache, key], Return[$AuditRhoCache[key]]];
  Print["  computing rho1 at s = ", NumberForm[ssVal, {8, 5}],
    ", mu = ", scaleLabel[scale]];
  result = TimeConstrained[
    IndependentAAFinalRho1Numeric[
      ssVal, $AuditParams,
      "RenormalizationScale" -> scale
    ],
    $AuditNodeTimeLimitSeconds,
    $TimedOut
  ];
  If[result === $TimedOut,
    Print["  TIMED OUT at s = ", ssVal, ", mu = ", scaleLabel[scale]];
    Return[$TimedOut]
  ];
  $AuditRhoCache[key] = result;
  result
];

Clear[aaMomentCached];
aaMomentCached[m2_?NumericQ, s0_?NumericQ, scale_] := Module[
  {rules, threshold, range, quadrature, rows, total, virtualTotal,
   integratedTotal, realTotal, lo},
  rules = DynamicParameterRules[$AuditParams];
  threshold = N[BcThreshold[] /. rules];
  If[s0 <= threshold, Return[$Failed]];
  range = s0 - threshold;
  quadrature = IndependentAAGaussLegendreRule[$AuditNPoints];
  rows = Map[
    Function[node,
      Module[{z, weight, ssVal, jac, rhoData, bf},
        {z, weight} = node;
        ssVal = threshold + range z^2;
        jac = 2 range z;
        rhoData = getAARhoData[ssVal, scale];
        If[rhoData === $TimedOut || rhoData === $Failed, Return[$Failed]];
        bf = weight jac Exp[-ssVal/m2];
        <|
          "s" -> ssVal,
          "BorelFactor" -> bf,
          "Rho1" -> rhoData["TotalRho1"],
          "VirtualPlusField" -> rhoData["VirtualPlusFieldFiniteRho1"],
          "IntegratedDipoles" -> rhoData["IntegratedDipolesFiniteRho1"],
          "RealMinusDipoles" -> rhoData["RealMinusDipolesRho1"]
        |>
      ]
    ],
    quadrature
  ];
  If[MemberQ[rows, $Failed], Return[$Failed]];
  total = Total[Lookup[rows, "BorelFactor"] Lookup[rows, "Rho1"]];
  virtualTotal = Total[Lookup[rows, "BorelFactor"] Lookup[rows, "VirtualPlusField"]];
  integratedTotal = Total[Lookup[rows, "BorelFactor"] Lookup[rows, "IntegratedDipoles"]];
  realTotal = Total[Lookup[rows, "BorelFactor"] Lookup[rows, "RealMinusDipoles"]];
  lo = NumericBorelPi["AA", "pert", m2, s0, $AuditParams];
  <|
    "M2" -> m2,
    "s0" -> s0,
    "mu" -> scaleLabel[scale],
    "PiAA_LO" -> lo,
    "PiAA_rho1" -> total,
    "alphaOverPi_rho1" -> $AuditAlpha/Pi total,
    "relative_shift" -> ($AuditAlpha/Pi total)/lo,
    "virtual_plus_field" -> virtualTotal,
    "integrated_dipoles" -> integratedTotal,
    "real_minus_dipoles" -> realTotal,
    "breakdown_closure" -> virtualTotal + integratedTotal + realTotal - total
  |>
];

Clear[aaMomentRow];
aaMomentRow[m2_?NumericQ, s0_?NumericQ, scale_] := Module[{a},
  a = aaMomentCached[m2, s0, scale];
  If[a === $Failed, Return[$Failed]];
  Lookup[a, {
    "M2", "s0", "mu", "PiAA_LO", "PiAA_rho1", "alphaOverPi_rho1",
    "relative_shift", "virtual_plus_field", "integrated_dipoles",
    "real_minus_dipoles", "breakdown_closure"
  }]
];

headers = {
  "M2", "s0", "mu", "PiAA_LO", "PiAA_rho1", "alphaOverPi_rho1",
  "relative_shift", "virtual_plus_field", "integrated_dipoles",
  "real_minus_dipoles", "breakdown_closure"
};

resetCSV["AlphaS_AA_M2_scan_incremental.csv", headers];
resetCSV["AlphaS_AA_s0_scan_incremental.csv", headers];
resetCSV["AlphaS_AA_mu_scan_incremental.csv", headers];

Print["Running cached AA M2 scan..."];
Do[
  Module[{row = aaMomentRow[m2, 54., 4.18]},
    If[row === $Failed,
      appendCSVRow["AlphaS_AA_M2_scan_incremental.csv", {m2, 54., 4.18, "FAILED"}],
      appendCSVRow["AlphaS_AA_M2_scan_incremental.csv", row];
      Print["  wrote M2 row: ", m2]
    ]
  ],
  {m2, {6., 7., 8., 9., 10., 11., 12.}}
];

Print["Running cached AA s0 scan..."];
Do[
  Module[{row = aaMomentRow[8., s0, 4.18]},
    If[row === $Failed,
      appendCSVRow["AlphaS_AA_s0_scan_incremental.csv", {8., s0, 4.18, "FAILED"}],
      appendCSVRow["AlphaS_AA_s0_scan_incremental.csv", row];
      Print["  wrote s0 row: ", s0]
    ]
  ],
  {s0, {50., 52., 54., 56., 58.}}
];

Print["Running cached AA mu scan..."];
Do[
  Module[{row = aaMomentRow[8., 54., mu]},
    If[row === $Failed,
      appendCSVRow["AlphaS_AA_mu_scan_incremental.csv", {8., 54., mu, "FAILED"}],
      appendCSVRow["AlphaS_AA_mu_scan_incremental.csv", row];
      Print["  wrote mu row: ", mu]
    ]
  ],
  {mu, {2., 3., 4.18, 5.}}
];

Print["Done.  Wrote incremental AA scan CSV files."];

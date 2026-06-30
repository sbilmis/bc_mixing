(* ::Package:: *)

(* Synchronized central NLO diagnostic for AA, AB, BB.

   This is a diagnostic synchronization, not yet a publication-grade final
   NLO prediction.  It puts the three channels into one common numerical
   setup:

     - one-loop common-scale MSbar masses and alpha_s;
     - AA: validated independent coefficient plus pole-to-MSbar mass conversion;
     - BB: imported tensor-current MSbar result, evaluated with the same
       running masses and scale;
     - AB: current diagnostic finite coefficient evaluated with the same
       running masses and scale, plus the same Born-derivative pole-to-MSbar
       mass conversion used for AA.

   Run with:

   /Applications/Wolfram.app/Contents/MacOS/WolframKernel -noprompt -run \
     'Get["/Users/sbilmis/Bc_mixing/RunSynchronizedNLODiagnostic.wl"]; Exit[]'
*)

SetDirectory[DirectoryName[$InputFileName]];
Print["Starting synchronized AA/AB/BB NLO diagnostic in ", Directory[]];
Print["Loading workbench files ..."];
Get["BcMixingAlphaS.wl"];
Get["BcMixingAlphaSTensorBB.wl"];
Get["BcMixingAlphaSMixedAB.wl"];
Print["Loaded workbench files."];

$SyncM2 = 8.;
$SyncS0 = 54.;
$SyncScale = 4.18;
$SyncNPoints = 6;

Clear[syncCSVValue, syncWriteKV, syncAppendKV];
syncCSVValue[x_String] := "\"" <> StringReplace[x, "\"" -> "\"\""] <> "\"";
syncCSVValue[x_] := ToString[FortranForm[N[x, 16]]];

syncWriteKV[file_String, rows_List] := Module[{stream},
  stream = OpenWrite[file];
  WriteString[stream, "key,value\n"];
  Scan[
    WriteString[stream, syncCSVValue[#[[1]]] <> "," <> syncCSVValue[#[[2]]] <> "\n"] &,
    rows
  ];
  Close[stream];
];

syncAppendKV[file_String, key_String, value_] := Module[{stream},
  stream = OpenAppend[file];
  WriteString[stream, syncCSVValue[key] <> "," <> syncCSVValue[value] <> "\n"];
  Close[stream];
];

If[FileExistsQ["AlphaS_synchronized_NLO_diagnostic.csv"],
  DeleteFile["AlphaS_synchronized_NLO_diagnostic.csv"]
];
syncWriteKV[
  "AlphaS_synchronized_NLO_diagnostic.csv",
  {
    {"Status", "started"},
    {"M2", $SyncM2},
    {"s0", $SyncS0},
    {"mu", $SyncScale}
  }
];

Print["Computing common running parameters ..."];
running = IndependentAAMSbarRunningParameters[$SyncScale];
paramsMu = Join[
  $BcMixingDefaultParameters,
  <|
    "mb" -> running["mbMSbar"],
    "mc" -> running["mcMSbar"],
    "alphaS" -> running["alphaS"]
  |>
];
alpha = running["alphaS"];
rulesMu = Join[DynamicParameterRules[paramsMu], {muR -> $SyncScale}];
threshold = N[BcThreshold[] /. rulesMu];

syncAppendKV["AlphaS_synchronized_NLO_diagnostic.csv", "mb_MSbar_mu", running["mbMSbar"]];
syncAppendKV["AlphaS_synchronized_NLO_diagnostic.csv", "mc_MSbar_mu", running["mcMSbar"]];
syncAppendKV["AlphaS_synchronized_NLO_diagnostic.csv", "alphaS_mu", running["alphaS"]];
syncAppendKV["AlphaS_synchronized_NLO_diagnostic.csv", "threshold", threshold];

Clear[genericMSbarMassConversionRho1];
genericMSbarMassConversionRho1[channel_String, ss_: s, scale_: muR] := Module[
  {rho0 = AlphaSLOSpectralDensity[channel, ss]},
  mb (4/3 + Log[scale^2/mb^2]) D[rho0, mb] +
    mc (4/3 + Log[scale^2/mc^2]) D[rho0, mc] //
    Simplify
];

Print["Computing AA MSbar summary ..."];
aa = IndependentAAFinalNLOBorelMSbarSummary[
  $SyncM2, $SyncS0, $SyncScale,
  $BcAlphaSMSbarDefaults,
  $BcMixingDefaultParameters,
  "NPoints" -> $SyncNPoints,
  "Progress" -> True,
  AccuracyGoal -> 5,
  PrecisionGoal -> 5,
  MaxRecursion -> 4
];
If[aa === $Failed, Print["AA failed."]; Abort[]];
loAA = aa["LOPerturbativeMomentMSbar"];
rhoAA = aa["BareRho1MSbarBorelMoment"];
shiftAA = aa["AlphaSOverPiNLOShiftMSbar"];
syncAppendKV["AlphaS_synchronized_NLO_diagnostic.csv", "PiAA_LO_MSbar", loAA];
syncAppendKV["AlphaS_synchronized_NLO_diagnostic.csv", "PiAA_rho1_MSbar", rhoAA];
syncAppendKV["AlphaS_synchronized_NLO_diagnostic.csv", "PiAA_alphaOverPi_shift_MSbar", shiftAA];
syncAppendKV["AlphaS_synchronized_NLO_diagnostic.csv", "PiAA_relative_shift_MSbar", shiftAA/loAA];
syncAppendKV["AlphaS_synchronized_NLO_diagnostic.csv", "PiAA_OSCoeffAtMSbarMasses", aa["OSCoefficientBorelAtMSbarMasses"]];
syncAppendKV["AlphaS_synchronized_NLO_diagnostic.csv", "PiAA_mass_conversion", aa["PoleToMSbarConversionBorelRho1"]];
Export["AlphaS_synchronized_AA_summary.mx", aa];

Print["Computing AB synchronized diagnostic ..."];
ab = IndependentABDiagnosticBorelSummary[
  $SyncM2, $SyncS0, paramsMu,
  "NPoints" -> $SyncNPoints,
  "Progress" -> True,
  "Scale" -> $SyncScale,
  AccuracyGoal -> 5,
  PrecisionGoal -> 5,
  MaxRecursion -> 8
];
If[FailureQ[ab] || ab === $Failed || Head[ab] =!= Association,
  Print["AB failed or remained unevaluated: ", InputForm[ab]];
  Abort[]
];
loAB = ab["PiAB_LOPert"];
convABExpr = genericMSbarMassConversionRho1["AB", s, muR];
convAB = NIntegrate[
  Exp[-ss/$SyncM2] (convABExpr /. rulesMu /. s -> ss),
  {ss, threshold, $SyncS0},
  AccuracyGoal -> 6,
  PrecisionGoal -> 6,
  MaxRecursion -> 8
];
rhoABDiagnostic = ab["DiagnosticRho1BorelMoment"];
rhoABSync = rhoABDiagnostic + convAB;
shiftAB = alpha/Pi rhoABSync;
syncAppendKV["AlphaS_synchronized_NLO_diagnostic.csv", "PiAB_LO_MSbarInput", loAB];
syncAppendKV["AlphaS_synchronized_NLO_diagnostic.csv", "PiAB_rho1_diagnostic_at_MSbar_masses", rhoABDiagnostic];
syncAppendKV["AlphaS_synchronized_NLO_diagnostic.csv", "PiAB_mass_conversion", convAB];
syncAppendKV["AlphaS_synchronized_NLO_diagnostic.csv", "PiAB_rho1_synchronized_diagnostic", rhoABSync];
syncAppendKV["AlphaS_synchronized_NLO_diagnostic.csv", "PiAB_alphaOverPi_shift_synchronized", shiftAB];
syncAppendKV["AlphaS_synchronized_NLO_diagnostic.csv", "PiAB_relative_shift_synchronized", shiftAB/loAB];
Export[
  "AlphaS_synchronized_AB_summary.mx",
  Join[
    ab,
    <|
      "PoleToMSbarMassConversionBorelRho1" -> convAB,
      "SynchronizedDiagnosticRho1BorelMoment" -> rhoABSync,
      "AlphaSOverPiSynchronizedShift" -> shiftAB,
      "RelativeSynchronizedShift" -> shiftAB/loAB
    |>
  ]
];

Print["Computing BB MSbar summary ..."];
bb = TensorPaperBBNLOMomentSummary[
  $SyncM2, $SyncS0, paramsMu,
  "Mu" -> $SyncScale,
  AccuracyGoal -> 6,
  PrecisionGoal -> 6,
  MaxRecursion -> 8
];
If[FailureQ[bb] || bb === $Failed, Print["BB failed."]; Abort[]];
loBB = bb["PiBB_LOPert"];
rhoBB = bb["PiBB_NLOBareRho1_MSbar"];
shiftBB = bb["AlphaSOverPi_NLOMoment"];
syncAppendKV["AlphaS_synchronized_NLO_diagnostic.csv", "PiBB_LO_MSbar", loBB];
syncAppendKV["AlphaS_synchronized_NLO_diagnostic.csv", "PiBB_rho1_MSbar", rhoBB];
syncAppendKV["AlphaS_synchronized_NLO_diagnostic.csv", "PiBB_alphaOverPi_shift_MSbar", shiftBB];
syncAppendKV["AlphaS_synchronized_NLO_diagnostic.csv", "PiBB_relative_shift_MSbar", shiftBB/loBB];
Export["AlphaS_synchronized_BB_summary.mx", bb];

Clear[syncThetaDeg];
syncThetaDeg[aaa_, abb_, bbb_] :=
  N[180/Pi NormalizeMixingAngle[1/2 ArcTan[aaa - bbb, -2 abb]]];

thetaLO = syncThetaDeg[loAA, loAB, loBB];
thetaAAOnly = syncThetaDeg[loAA + shiftAA, loAB, loBB];
thetaABOnly = syncThetaDeg[loAA, loAB + shiftAB, loBB];
thetaBBOnly = syncThetaDeg[loAA, loAB, loBB + shiftBB];
thetaSync = syncThetaDeg[loAA + shiftAA, loAB + shiftAB, loBB + shiftBB];

syncAppendKV["AlphaS_synchronized_NLO_diagnostic.csv", "theta_LO_deg", thetaLO];
syncAppendKV["AlphaS_synchronized_NLO_diagnostic.csv", "theta_AA_only_deg", thetaAAOnly];
syncAppendKV["AlphaS_synchronized_NLO_diagnostic.csv", "delta_theta_AA_only_deg", NormalizeMixingAngleDegrees[thetaAAOnly - thetaLO]];
syncAppendKV["AlphaS_synchronized_NLO_diagnostic.csv", "theta_AB_only_deg", thetaABOnly];
syncAppendKV["AlphaS_synchronized_NLO_diagnostic.csv", "delta_theta_AB_only_deg", NormalizeMixingAngleDegrees[thetaABOnly - thetaLO]];
syncAppendKV["AlphaS_synchronized_NLO_diagnostic.csv", "theta_BB_only_deg", thetaBBOnly];
syncAppendKV["AlphaS_synchronized_NLO_diagnostic.csv", "delta_theta_BB_only_deg", NormalizeMixingAngleDegrees[thetaBBOnly - thetaLO]];
syncAppendKV["AlphaS_synchronized_NLO_diagnostic.csv", "theta_synchronized_diagnostic_deg", thetaSync];
syncAppendKV["AlphaS_synchronized_NLO_diagnostic.csv", "delta_theta_synchronized_diagnostic_deg", NormalizeMixingAngleDegrees[thetaSync - thetaLO]];
syncAppendKV["AlphaS_synchronized_NLO_diagnostic.csv", "Status", "completed"];

Export[
  "AlphaS_synchronized_NLO_diagnostic_summary.mx",
  <|
    "M2" -> $SyncM2,
    "s0" -> $SyncS0,
    "Scale" -> $SyncScale,
    "RunningParameters" -> running,
    "MomentsLO" -> <|"AA" -> loAA, "AB" -> loAB, "BB" -> loBB|>,
    "Rho1" -> <|"AA" -> rhoAA, "AB" -> rhoABSync, "BB" -> rhoBB|>,
    "AlphaSOverPiShifts" -> <|"AA" -> shiftAA, "AB" -> shiftAB, "BB" -> shiftBB|>,
    "AnglesDegrees" -> <|
      "LO" -> thetaLO,
      "AAOnly" -> thetaAAOnly,
      "ABOnly" -> thetaABOnly,
      "BBOnly" -> thetaBBOnly,
      "SynchronizedDiagnostic" -> thetaSync
    |>,
    "Caveat" ->
      "Synchronized diagnostic: AA and BB use MSbar inputs; AB uses the current finite diagnostic plus Born-derivative pole-to-MSbar mass conversion. Use as the end-of-session diagnostic, not as a publication-grade final NLO prediction."
  |>
];

Print["Done.  Wrote AlphaS_synchronized_NLO_diagnostic.csv."];

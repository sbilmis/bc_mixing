(* ::Package:: *)

(*
  RunMonteCarlo_claude.wl

  Reproduces the publication Monte Carlo uncertainty estimate using the
  projector-corrected BcMixingMomentum_claude.wl.  Output files get _claude suffix.
*)

If[$InputFileName =!= "",
  SetDirectory[DirectoryName[$InputFileName]]
];

Get["BcMixingMomentum_claude.wl"];

mcLog[msg_] := Print[DateString[{"Hour", ":", "Minute", ":", "Second"}], "  ", msg];

publicationMonteCarloSamples = 1000;
publicationMonteCarloSeed    = 1234;
publicationUncertaintyRanges = Join[
  $BcMixingDefaultUncertaintyRanges,
  <|
    "M2" -> {7.0, 9.0},
    "s0" -> {53.0, 55.0}
  |>
];

mcLog["Starting Monte Carlo (" <> ToString[publicationMonteCarloSamples] <> " samples, seed=" <> ToString[publicationMonteCarloSeed] <> ")"];
mcLog["Order: total (pert + G2 + G3, projector fixed)"];

publicationUncertaintyRun = MonteCarloMixingAngleUncertainty[
  publicationMonteCarloSamples,
  publicationUncertaintyRanges,
  "total",
  "IncludeG3" -> True,
  "Seed"      -> publicationMonteCarloSeed,
  "Progress"  -> True
];

mcLog["Monte Carlo complete. Exporting..."];
ExportMonteCarloMixingAngleSamples[
  publicationUncertaintyRun,
  "BcMixingMonteCarloSamplesPublication_claude.csv"
];
ExportMonteCarloMixingAngleSummary[
  publicationUncertaintyRun,
  "BcMixingMonteCarloSummaryPublication_claude.csv"
];

mcLog["Done"];
Print[InputForm[publicationUncertaintyRun["Summary"]]];

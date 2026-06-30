(* Reproducible production Monte Carlo for the publication histogram. *)

If[$InputFileName =!= "",
  SetDirectory[DirectoryName[$InputFileName]]
];

Get["BcMixingMomentum.wl"];

publicationMonteCarloSamples = 1000;
publicationMonteCarloSeed = 1234;
publicationUncertaintyRanges = Join[
  $BcMixingDefaultUncertaintyRanges,
  <|
    "M2" -> {7.0, 9.0},
    "s0" -> {53.0, 55.0}
  |>
];

publicationUncertaintyRun = MonteCarloMixingAngleUncertainty[
  publicationMonteCarloSamples,
  publicationUncertaintyRanges,
  "total",
  "IncludeG3" -> True,
  "Seed" -> publicationMonteCarloSeed,
  "Progress" -> True
];

ExportMonteCarloMixingAngleSamples[
  publicationUncertaintyRun,
  "BcMixingMonteCarloSamplesPublication.csv"
];
ExportMonteCarloMixingAngleSummary[
  publicationUncertaintyRun,
  "BcMixingMonteCarloSummaryPublication.csv"
];

Print[InputForm[publicationUncertaintyRun["Summary"]]];

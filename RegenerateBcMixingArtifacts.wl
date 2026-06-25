(* ::Package:: *)

(*
  RegenerateBcMixingArtifacts.wl

  Progress-printing regeneration of the B_c mixing artifacts after changes to
  the condensate direct-Borel implementation.  The script intentionally
  computes the numeric tables first, exports CSV files, and only then builds
  PDF plots.  This makes long Mathematica runs easier to monitor.
*)

If[$InputFileName =!= "",
  SetDirectory[DirectoryName[$InputFileName]]
];

Get["BcMixingMomentum.wl"];

regenerateLog[msg_] := Print[DateString[{"Hour", ":", "Minute", ":", "Second"}], "  ", msg];

regenerateOrder = "pertG2";
regenerateNPoints = 25;
regenerateParams = $BcMixingDefaultParameters;
regenerateUseMaTeX = False;
regenerateExportPDF = False;

regenerateLog["Precomputing condensate Borel integrands"];
Scan[
  (regenerateLog["  G2 integrand " <> #]; G2BorelIntegrandExpression[#];) &,
  {"AA", "AB", "BB"}
];

regenerateM2Values = N[Subdivide[
  $BcMixingWangWindow["M2Range"][[1]],
  $BcMixingWangWindow["M2Range"][[2]],
  regenerateNPoints - 1
]];

regenerateS0Values = N[Subdivide[
  $BcMixingWangWindow["s0Range"][[1]],
  $BcMixingWangWindow["s0Range"][[2]],
  regenerateNPoints - 1
]];

regenerateM2CurveIndex = 0;
regenerateM2Data = Association @ Table[
  regenerateM2CurveIndex++;
  regenerateLog[
    "M2 stability curve for s0 = " <> ToString[s0v] <>
    " (" <> ToString[regenerateM2CurveIndex] <> "/" <> ToString[Length[$BcMixingWangWindow["s0Values"]]] <> ")"
  ];
  s0v -> Table[
    regenerateLog["  M2 = " <> ToString[m2v]];
    {
      m2v,
      NumericMixingAngleDegrees[m2v, s0v, regenerateOrder, regenerateParams]
    },
    {m2v, regenerateM2Values}
  ],
  {s0v, N[$BcMixingWangWindow["s0Values"]]}
];

regenerateS0CurveIndex = 0;
regenerateS0Data = Association @ Table[
  regenerateS0CurveIndex++;
  regenerateLog[
    "s0 stability curve for M2 = " <> ToString[m2v] <>
    " (" <> ToString[regenerateS0CurveIndex] <> "/" <> ToString[Length[$BcMixingWangWindow["M2Values"]]] <> ")"
  ];
  m2v -> Table[
    regenerateLog["  s0 = " <> ToString[s0v]];
    {
      s0v,
      NumericMixingAngleDegrees[m2v, s0v, regenerateOrder, regenerateParams]
    },
    {s0v, regenerateS0Values}
  ],
  {m2v, N[$BcMixingWangWindow["M2Values"]]}
];

regenerateLog["Exporting stability CSV files"];
ExportStabilityDataCSV[regenerateM2Data, "BcMixingThetaVsM2_WangWindow.csv", "M2"];
ExportStabilityDataCSV[regenerateS0Data, "BcMixingThetaVsS0_WangWindow.csv", "s0"];

If[TrueQ[regenerateExportPDF],

regenerateYRange[data_] := PublicationThetaYRange[
  Values[data][[All, All, 2]],
  1.0,
  0.20
];

regenerateM2Styles = PublicationPlotStyles[Length[regenerateM2Data]];
regenerateS0Styles = PublicationPlotStyles[Length[regenerateS0Data]];

regenerateM2Labels = BcMixingLegendLabel[
  "s_0",
  Subscript["s", 0],
  #,
  regenerateUseMaTeX,
  1.1
] & /@ Keys[regenerateM2Data];

regenerateS0Labels = BcMixingLegendLabel[
  "M^2",
  Superscript["M", 2],
  #,
  regenerateUseMaTeX,
  1.1
] & /@ Keys[regenerateS0Data];

regenerateM2FrameLabel = {
  BcMixingMaTeXLabel[
    "M^2\\,(\\mathrm{GeV}^2)",
    Row[{Superscript["M", 2], " (", Superscript["GeV", 2], ")"}],
    regenerateUseMaTeX,
    1.1
  ],
  BcMixingMaTeXLabel[
    "\\theta^\\circ",
    Superscript["\[Theta]", "\[Degree]"],
    regenerateUseMaTeX,
    1.1
  ]
};

regenerateS0FrameLabel = {
  BcMixingMaTeXLabel[
    "s_0\\,(\\mathrm{GeV}^2)",
    Row[{Subscript["s", 0], " (", Superscript["GeV", 2], ")"}],
    regenerateUseMaTeX,
    1.1
  ],
  BcMixingMaTeXLabel[
    "\\theta^\\circ",
    Superscript["\[Theta]", "\[Degree]"],
    regenerateUseMaTeX,
    1.1
  ]
};

regenerateLog["Building stability PDF plots"];
regenerateM2Plot = ListLinePlot[
  Values[regenerateM2Data],
  Frame -> True,
  Axes -> False,
  FrameLabel -> regenerateM2FrameLabel,
  LabelStyle -> Directive[Black, 14, FontFamily -> "Times"],
  BaseStyle -> {FontFamily -> "Times"},
  ImageSize -> 540,
  ImagePadding -> {{75, 20}, {60, 20}},
  PlotStyle -> regenerateM2Styles,
  PlotMarkers -> Automatic,
  PlotRange -> {$BcMixingWangWindow["M2Range"], regenerateYRange[regenerateM2Data]},
  GridLines -> Automatic,
  GridLinesStyle -> Directive[GrayLevel[0.85], Dashed],
  PlotLegends -> Placed[LineLegend[regenerateM2Styles, regenerateM2Labels, LegendMarkerSize -> 18], Right]
];

regenerateS0Plot = ListLinePlot[
  Values[regenerateS0Data],
  Frame -> True,
  Axes -> False,
  FrameLabel -> regenerateS0FrameLabel,
  LabelStyle -> Directive[Black, 14, FontFamily -> "Times"],
  BaseStyle -> {FontFamily -> "Times"},
  ImageSize -> 540,
  ImagePadding -> {{75, 20}, {60, 20}},
  PlotStyle -> regenerateS0Styles,
  PlotMarkers -> Automatic,
  PlotRange -> {$BcMixingWangWindow["s0Range"], regenerateYRange[regenerateS0Data]},
  GridLines -> Automatic,
  GridLinesStyle -> Directive[GrayLevel[0.85], Dashed],
  PlotLegends -> Placed[LineLegend[regenerateS0Styles, regenerateS0Labels, LegendMarkerSize -> 18], Right]
];

Export["BcMixingThetaVsM2_WangWindow.pdf", regenerateM2Plot];
Export["BcMixingThetaVsS0_WangWindow.pdf", regenerateS0Plot];

,
  regenerateLog["Skipping PDF export. Set regenerateExportPDF = True for final plot export."]
];

regenerateLog["Done"];
Print[InputForm[
  <|
    "M2FirstPoint" -> First[First[Values[regenerateM2Data]]],
    "S0FirstPoint" -> First[First[Values[regenerateS0Data]]],
    "M2CSV" -> "BcMixingThetaVsM2_WangWindow.csv",
    "S0CSV" -> "BcMixingThetaVsS0_WangWindow.csv"
  |>
]];

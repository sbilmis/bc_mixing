(* ::Package:: *)

(*
  RegenerateCompleteD6Figure_claude.wl

  Generates BcMixingMomentumThetaOrdersCompleteD6VsM2_s0_53_claude.pdf
  using:
    - BcMixingDimension6Complete_claude.wl  (D6ProjectSpin1Fast projector fixed)
    - d6_chunks/G3cross_M2Grid_s0_53p_n25_claude.wl  (AA/AB moments x3 corrected)

  Because BB timed out in the original chunk computation, the full
  "totalCompleteD6" theta (AA+AB+BB cross-line) cannot be computed.
  We instead show a "totalPartialCrossLine" curve where BB_cross = 0,
  which gives the best available estimate of the cross-line shift.
  The figure is clearly labelled as partial.
*)

If[$InputFileName =!= "",
  SetDirectory[DirectoryName[$InputFileName]]
];

d6Log[msg_] := Print[DateString[{"Hour", ":", "Minute", ":", "Second"}], "  ", msg];

(* ---- load base file first, then D6 extensions ---- *)
d6Log["Loading BcMixingMomentum_claude.wl..."];
Get["BcMixingMomentum_claude.wl"];
d6Log["Loading BcMixingDimension6Complete_claude.wl..."];
Get["BcMixingDimension6Complete_claude.wl"];
d6Log["Loaded."];

(* ---- load corrected grid ---- *)
gridFile = "d6_chunks/G3cross_M2Grid_s0_53p_n25_claude.wl";
If[! FileExistsQ[gridFile],
  d6Log["ERROR: corrected grid not found. Run BuildCorrectedD6Grid_claude.wl first."];
  Exit[1]
];
correctedGrid = Get[gridFile];
d6Log["Loaded corrected grid: " <> gridFile];

params      = $BcMixingDefaultParameters;
continuumVal = 53.0;
m2Range     = {7., 9.};
nPts        = 25;
m2Values    = N[Subdivide[m2Range[[1]], m2Range[[2]], nPts - 1]];

(* ---- compute base OPE summaries ---- *)
d6Log["Precomputing G2/G3 integrands..."];
Scan[(d6Log["  G2 " <> #]; G2BorelIntegrandExpression[#];) &, {"AA", "AB", "BB"}];
Scan[(d6Log["  G3 " <> #]; G3BorelIntegrandExpression[#];) &, {"AA", "AB", "BB"}];
d6Log["Integrands ready."];

d6Log["Computing base OPE summaries (pert, pertG2, total) ..."];
baseSummaries = AssociationMap[
  NumericOPESummary[#, continuumVal, params] &,
  m2Values
];
d6Log["Base summaries done."];

(* ---- cross-line records from corrected grid ---- *)
crossRecords = Association[correctedGrid["Records"]];

(* ---- build theta data for each order ---- *)
pertData    = {#, MixingAngleDegreesFromSummary[baseSummaries[#], "pert"]}    & /@ m2Values;
pertG2Data  = {#, MixingAngleDegreesFromSummary[baseSummaries[#], "pertG2"]}  & /@ m2Values;
totalData   = {#, MixingAngleDegreesFromSummary[baseSummaries[#], "total"]}   & /@ m2Values;

(* totalPartialCrossLine: AA+AB cross-line corrected, BB_cross = 0 *)
totalPartialData = Table[
  Module[
    {base, cr, fullAA, fullAB, fullBB},
    base = AssociationMap[baseSummaries[m2v][#]["total"] &, {"AA", "AB", "BB"}];
    cr   = crossRecords[m2v];
    fullAA = base["AA"] + If[NumericQ[cr["AA"]], cr["AA"], 0.];
    fullAB = base["AB"] + If[NumericQ[cr["AB"]], cr["AB"], 0.];
    fullBB = base["BB"];  (* BB cross-line = 0 *)
    {m2v, 1/2 ArcTan[fullAA - fullBB, -2 fullAB] 180/Pi}
  ],
  {m2v, m2Values}
];

(* ---- print table ---- *)
d6Log["Theta at M2=8, s0=53:"];
Print["  pert            = ", pertData[[13, 2]]];
Print["  pertG2          = ", pertG2Data[[13, 2]]];
Print["  total           = ", totalData[[13, 2]]];
Print["  partialCrossLine= ", totalPartialData[[13, 2]]];
Print["  Delta(total->partialCL) = ", totalPartialData[[13,2]] - totalData[[13,2]]];

(* ---- export CSV for Python figure ---- *)
csvFile = "BcMixingCompleteD6ThetaData_s0_53_claude.csv";
csvLines = {"M2,ThetaPert,ThetaPertG2,ThetaTotal,ThetaPartialCrossLine"};
Do[
  AppendTo[csvLines,
    StringRiffle[
      ToString /@ {m2Values[[i]], pertData[[i,2]], pertG2Data[[i,2]],
                   totalData[[i,2]], totalPartialData[[i,2]]},
      ","
    ]
  ],
  {i, 1, nPts}
];
Export[csvFile, StringRiffle[csvLines, "\n"], "Text"];
d6Log["Exported CSV: " <> csvFile];

(* ---- generate plot ---- *)
d6Log["Generating plot..."];

data = <|
  "pert"              -> pertData,
  "pertG2"            -> pertG2Data,
  "total"             -> totalData,
  "totalPartialCrossLine" -> totalPartialData
|>;

(* Use standard style function if available, otherwise fall back *)
styles = PublicationPlotStyles[Length[data]];
labels = {
  "pert",
  "pert + G\[ThinSpace]2",
  "pert + G\[ThinSpace]2 + G\[ThinSpace]3",
  "pert + G\[ThinSpace]2 + G\[ThinSpace]3 + G3cross\[Null] (AA+AB)"
};

yAll = Join @@ Map[#[[All, 2]] &, Values[data]];
yMid  = Mean[yAll];
yHalf = 1.1 Max[Abs[yAll - yMid]];

plt = ListLinePlot[
  Values[data],
  Frame       -> True,
  Axes        -> False,
  FrameLabel  -> {
    Row[{Superscript["M", 2], " (", Superscript["GeV", 2], ")"}],
    Superscript["\[Theta]", "\[Degree]"]
  },
  LabelStyle  -> Directive[Black, 14, FontFamily -> "Times"],
  BaseStyle   -> {FontFamily -> "Times"},
  ImageSize   -> 620,
  PlotStyle   -> styles,
  PlotMarkers -> Automatic,
  PlotRange   -> {{7, 9}, {yMid - yHalf, yMid + yHalf}},
  GridLines   -> Automatic,
  GridLinesStyle -> Directive[GrayLevel[0.85], Dashed],
  PlotLabel   -> Row[{"Momentum space (corrected projector), ",
                       Subscript["s", 0], " = 53 ", Superscript["GeV", 2],
                       " [BB cross-line = 0]"}],
  PlotLegends -> Placed[LineLegend[styles, labels, LegendMarkerSize -> 18], Right]
];

outPDF = "BcMixingMomentumThetaOrdersCompleteD6VsM2_s0_53_claude.pdf";
Export[outPDF, plt["Plot"]];
d6Log["Exported: " <> outPDF];
Print["Done."];

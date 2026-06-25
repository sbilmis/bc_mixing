(* ::Package:: *)

(* Run one dimension-6 cross-line side with resumable chunk caches.

   Usage:
     WolframKernel -noprompt -script RunD6CrossLineSide.wl AA c1b2
     WolframKernel -noprompt -script RunD6CrossLineSide.wl AB c2b1

   The script writes intermediate files to d6_chunks/ and records the central
   Borel value at M2=8 GeV^2, s0=54 GeV^2.
*)

SetDirectory["/Users/sbilmis/Bc_mixing"];
Get["BcMixingMomentum.wl"];
Get["BcMixingDimension6Complete.wl"];

rawArgs = If[ListQ[$ScriptCommandLine], $ScriptCommandLine, {}];
args = Select[
  rawArgs,
  ! StringEndsQ[#, "RunD6CrossLineSide.wl"] &
];
envChannel = Environment["D6_RUN_CHANNEL"];
envSide = Environment["D6_RUN_SIDE"];
channel = If[
  StringQ[envChannel] && envChannel =!= "",
  envChannel,
  If[Length[args] >= 1, args[[1]], "AA"]
];
side = If[
  StringQ[envSide] && envSide =!= "",
  envSide,
  If[Length[args] >= 2, args[[2]], "c1b2"]
];

If[! MemberQ[{"AA", "AB", "BB"}, channel],
  Print["Bad channel: ", channel];
  Quit[1]
];

If[! MemberQ[{"c2b1", "c1b2"}, side],
  Print["Bad side: ", side];
  Quit[1]
];

If[! DirectoryQ["d6_chunks"], CreateDirectory["d6_chunks"]];

prefix = FileNameJoin[{"d6_chunks", channel <> "_" <> side <> "_fast"}];
traceRanges = {Range[1, 20], Range[21, 50], Range[51, 90], Range[91, 120], Range[121, 152]};

traceChunkFile[range_] :=
  prefix <> "_" <>
    IntegerString[First[range], 10, 3] <> "_" <>
    IntegerString[Last[range], 10, 3] <> ".wl";

Print["Running trace chunks for ", channel, " ", side];
Do[
  file = traceChunkFile[range];
  If[FileExistsQ[file],
    Print["  trace cache exists: ", file],
    chunk = D6SaveCrossLineTraceChunk[file, channel, side, range, -I/2, 60, True, "Fast"];
    timed = Cases[chunk["Results"], a_Association /; a["Output"] === $TimedOut :> a["Index"]];
    Print["  trace ", First[range], "-", Last[range], ": done=",
      Count[chunk["Results"][[All, "Output"]], Except[$TimedOut]],
      " timed=", timed
    ];
  ],
  {range, traceRanges}
];

traceFiles = Join[
  traceChunkFile /@ traceRanges,
  FileNames[prefix <> "_retry_*.wl"]
];
traceChunks = D6LoadCrossLineTraceChunks[traceFiles];
traceAssembly = D6AssembleCrossLineTraceChunks[traceChunks, 152];
traceAssemblyFile = prefix <> "_assembled.wl";
Put[traceAssembly, traceAssemblyFile];
Print["Trace assembly: done=", traceAssembly["CompletedTermCount"],
  " missing=", traceAssembly["MissingIndices"],
  " file=", traceAssemblyFile
];

If[traceAssembly["MissingIndices"] =!= {},
  Print["Trace incomplete; stopping before Feynman parameterization."];
  Quit[2]
];

loopTermCount = Length[D6CrossLineLoopTermsFromExpression[traceAssembly["Expression"]]];
Print["Loop terms: ", loopTermCount];

fpRanges = Table[
  Range[start, Min[start + 19, loopTermCount]],
  {start, 1, loopTermCount, 20}
];

fpChunkFile[range_] :=
  prefix <> "_fp_" <>
    IntegerString[First[range], 10, 3] <> "_" <>
    IntegerString[Last[range], 10, 3] <> ".wl";

Print["Running Feynman-parameter chunks for ", channel, " ", side];
Do[
  file = fpChunkFile[range];
  If[FileExistsQ[file],
    Print["  fp cache exists: ", file],
    chunk = D6SaveFeynmanParameterChunkFromAssembly[file, traceAssemblyFile, range, 90];
    timed = Cases[chunk["Results"], a_Association /; a["Output"] === $TimedOut :> a["Index"]];
    Print["  fp ", First[range], "-", Last[range], ": done=",
      Count[chunk["Results"][[All, "Output"]], Except[$TimedOut]],
      " timed=", timed
    ];
  ],
  {range, fpRanges}
];

fpFiles = Join[
  fpChunkFile /@ fpRanges,
  FileNames[prefix <> "_fp_retry_*.wl"]
];
fpChunks = D6LoadFeynmanParameterChunks[fpFiles];
fpAssembly = D6AssembleFeynmanParameterChunks[fpChunks, loopTermCount];
fpAssemblyFile = prefix <> "_fp_assembled.wl";
Put[fpAssembly, fpAssemblyFile];
Print["FP assembly: done=", fpAssembly["CompletedTermCount"],
  " missing=", fpAssembly["MissingIndices"],
  " file=", fpAssemblyFile
];

If[fpAssembly["MissingIndices"] =!= {},
  Print["Feynman parameterization incomplete; stopping before Borel integration."];
  Quit[3]
];

terms = fpAssembly["FeynmanParameterTerms"] /. eps -> 0;
amp = $BcMixingDirectBorelPhase Total[(#[[1]] #[[2]]) & /@ terms] /.
    {x[1] -> xi, x[2] -> 1 - xi} // Together // Simplify;
borel = BorelTransformQ2[amp, xi, M2];
borelFile = prefix <> "_borel_integrand.wl";
Put[borel, borelFile];

lims = ContinuumXLimits[54., $BcMixingDefaultParameters];
value = NIntegrate[
  Evaluate[borel /. DynamicParameterRules[] /. M2 -> 8.],
  {xi, lims[[1]], lims[[2]]},
  WorkingPrecision -> MachinePrecision,
  AccuracyGoal -> 6,
  PrecisionGoal -> 6
];

valueRecord = <|
  "Channel" -> channel,
  "Side" -> side,
  "M2" -> 8.,
  "s0" -> 54.,
  "Value" -> value,
  "TraceAssembly" -> traceAssemblyFile,
  "FeynmanParameterAssembly" -> fpAssemblyFile,
  "BorelIntegrand" -> borelFile
|>;
valueFile = prefix <> "_central_value.wl";
Put[valueRecord, valueFile];

Print["Central value: ", InputForm[value]];
Print["Value file: ", valueFile];
Quit[0];

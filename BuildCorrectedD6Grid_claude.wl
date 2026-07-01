(* ::Package:: *)

(*
  BuildCorrectedD6Grid_claude.wl

  Corrects the D6 cross-line numeric grid for the 1/3 projector bug:
    D6ProjectSpin1Fast used  1/3*(MT[mu,nu]-...)  instead of  (MT[mu,nu]-...)
  so every numeric G3cross moment is 1/3 of the correct value.

  Strategy: load the existing grid, multiply every *numeric* AA and AB entry by 3,
  keep BB as-is (Failure at all 25 points), write corrected grid to
    d6_chunks/G3cross_M2Grid_s0_53p_n25_claude.wl

  No FeynCalc or BcMixing package is needed — pure association manipulation.
*)

If[$InputFileName =!= "",
  SetDirectory[DirectoryName[$InputFileName]]
];

(* ---- load the original buggy grid ---- *)
origFile = "d6_chunks/G3cross_M2Grid_s0_53p_n25.wl";
If[! FileExistsQ[origFile],
  Print["ERROR: grid file not found: ", origFile];
  Exit[1]
];

origGrid = Get[origFile];
Print["Loaded original grid: ", origFile];
Print["  M2 range: ", origGrid["M2Range"],
      "  NPoints: ", origGrid["NPoints"],
      "  s0: ", origGrid["s0"]];

(* ---- rescale numeric AA and AB by 3; leave BB (Failure) unchanged ---- *)
FixRecord[rec_Association] := Module[
  {aaVal, abVal, bbVal},
  aaVal = rec["AA"];
  abVal = rec["AB"];
  bbVal = rec["BB"];
  <|
    "AA" -> If[NumericQ[aaVal], 3 aaVal, aaVal],
    "AB" -> If[NumericQ[abVal], 3 abVal, abVal],
    "BB" -> bbVal  (* Failure stays as Failure *)
  |>
];

origRecords = Association[origGrid["Records"]];
correctedRecords = FixRecord /@ origRecords;

(* ---- sanity check at M2=8 ---- *)
r8 = correctedRecords[8.0];
Print["Corrected record at M2=8:"];
Print["  AA = ", r8["AA"], " (was ", origRecords[8.0]["AA"], ")"];
Print["  AB = ", r8["AB"], " (was ", origRecords[8.0]["AB"], ")"];
Print["  Ratio AA: ", r8["AA"] / origRecords[8.0]["AA"]];
Print["  Ratio AB: ", r8["AB"] / origRecords[8.0]["AB"]];

(* ---- build the corrected grid association ---- *)
correctedGrid = <|
  "Type"              -> "D6CrossLineM2Grid",
  "Order"             -> "G3cross",
  "M2Range"           -> origGrid["M2Range"],
  "s0"                -> origGrid["s0"],
  "NPoints"           -> origGrid["NPoints"],
  "M2Values"          -> origGrid["M2Values"],
  "ParameterSnapshot" -> origGrid["ParameterSnapshot"],
  "Records"           -> Normal[correctedRecords],
  "ProjectorFixNote"  -> "D6ProjectSpin1Fast: 1/3 factor removed; AA and AB rescaled x3 from original buggy grid.",
  "UpdatedAt"         -> DateString[{"Year", "-", "Month", "-", "Day", " ", "Hour", ":", "Minute", ":", "Second"}]
|>;

(* ---- write corrected grid ---- *)
outFile = "d6_chunks/G3cross_M2Grid_s0_53p_n25_claude.wl";
Put[correctedGrid, outFile];
Print["Wrote corrected grid: ", outFile];

(* ---- count valid vs failed ---- *)
allRecords = Association[correctedGrid["Records"]];
Print["Points with numeric AA: ", Count[Values[allRecords], r_ /; NumericQ[r["AA"]]]];
Print["Points with numeric AB: ", Count[Values[allRecords], r_ /; NumericQ[r["AB"]]]];
Print["Points with Failure  BB: ", Count[Values[allRecords], r_ /; Head[r["BB"]] === Failure]];
Print["Done."];

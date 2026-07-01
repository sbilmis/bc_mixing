(* ::Package:: *)

(*
  RegenerateAllFigures_claude.wl

  Regenerates ALL paper figures that depend on the momentum-space OPE code,
  using the projector-corrected BcMixingMomentum_claude.wl (1/3 removed from
  ProjectSpin1).  Output files get a _claude suffix.

  Figures produced:
    1. BcMixingMomentumThetaOrdersVsM2_s0_53_claude.pdf  -- theta(M^2) by OPE order
    2. BcMixingMomentumOPERatiosVsM2_s0_53_claude.pdf    -- |G_i/pert| ratios
    3. BcMixingThetaOrdersData_s0_53_claude.csv           -- raw data for Python figure
    4. BcMixingOPERatiosData_s0_53_claude.csv             -- OPE ratio data
  (WangWindow stability PDFs were already produced by RegenerateBcMixingArtifacts_claude.wl)
*)

If[$InputFileName =!= "",
  SetDirectory[DirectoryName[$InputFileName]]
];

Get["BcMixingMomentum_claude.wl"];

figLog[msg_] := Print[DateString[{"Hour", ":", "Minute", ":", "Second"}], "  ", msg];

figNPoints = 25;
figS0 = 53.0;
figParams = $BcMixingDefaultParameters;
figM2Range = $BcMixingWangWindow["M2Range"];

(* ---- Precompute condensate integrands (memoized, shared across all plots) ---- *)
figLog["Precomputing condensate integrands..."];
Scan[(figLog["  G2 " <> #]; G2BorelIntegrandExpression[#];) &, {"AA", "AB", "BB"}];
Scan[(figLog["  G3 " <> #]; G3BorelIntegrandExpression[#];) &, {"AA", "AB", "BB"}];
figLog["  done"];

(* ======================================================
   Figure 1: theta(M^2) by OPE order at s0=53
   ====================================================== *)
figLog["Computing theta-vs-M2 by OPE order (pert, pertG2, total)..."];
thetaOrderResult = MixingAngleOrderM2PublicationPlot[
  figM2Range,
  figS0,
  {"pert", "pertG2", "total"},
  figParams,
  "NPoints" -> figNPoints
];
figLog["  done — exporting PDF"];
Export["BcMixingMomentumThetaOrdersVsM2_s0_53_claude.pdf", thetaOrderResult["Plot"]];
figLog["  BcMixingMomentumThetaOrdersVsM2_s0_53_claude.pdf written"];

(* Export raw data as CSV for the Python publication figure *)
figLog["  Exporting CSV for Python figure..."];
thetaOrderData = thetaOrderResult["Data"];
m2Vals = thetaOrderData["pert"][[All, 1]];
pertVals  = thetaOrderData["pert"][[All, 2]];
g2Vals    = thetaOrderData["pertG2"][[All, 2]];
totalVals = thetaOrderData["total"][[All, 2]];
thetaCSV = Prepend[
  Transpose[{m2Vals, pertVals, g2Vals, totalVals}],
  {"M2", "ThetaPert", "ThetaPertG2", "ThetaPertG2G3"}
];
Export["BcMixingThetaOrdersData_s0_53_claude.csv", thetaCSV];
figLog["  BcMixingThetaOrdersData_s0_53_claude.csv written"];
figLog["  M2=8, s0=53:  pert=" <> ToString[N[pertVals[[13]],8]]
       <> "  pertG2=" <> ToString[N[g2Vals[[13]],8]]
       <> "  total=" <> ToString[N[totalVals[[13]],8]]];

(* ======================================================
   Figure 2: OPE ratios |G_i/pert| vs M^2 at s0=53
   ====================================================== *)
figLog["Computing OPE contribution ratios..."];
ratioResult = OPEContributionRatioM2PublicationPlot[
  figM2Range,
  figS0,
  figParams,
  "NPoints" -> figNPoints,
  "UseAbs" -> True
];
figLog["  done — exporting PDF"];
Export["BcMixingMomentumOPERatiosVsM2_s0_53_claude.pdf", ratioResult["Plot"]];
figLog["  BcMixingMomentumOPERatiosVsM2_s0_53_claude.pdf written"];

(* Export OPE ratio data as CSV *)
ratioData = ratioResult["Data"];
g2aaVals = Abs[ratioData["AA"][[All, 2]]];
g3aaVals = Abs[ratioData["AA"][[All, 3]]];
g2abVals = Abs[ratioData["AB"][[All, 2]]];
g3abVals = Abs[ratioData["AB"][[All, 3]]];
g2bbVals = Abs[ratioData["BB"][[All, 2]]];
g3bbVals = Abs[ratioData["BB"][[All, 3]]];
ratioCSV = Prepend[
  Transpose[{m2Vals, g2aaVals, g3aaVals, g2abVals, g3abVals, g2bbVals, g3bbVals}],
  {"M2", "AA_G2OverPert", "AA_G3OverPert", "AB_G2OverPert", "AB_G3OverPert", "BB_G2OverPert", "BB_G3OverPert"}
];
Export["BcMixingOPERatiosData_s0_53_claude.csv", ratioCSV];
figLog["  BcMixingOPERatiosData_s0_53_claude.csv written"];

figLog["Done"];
Print[InputForm[<|
  "ThetaOrdersPDF" -> "BcMixingMomentumThetaOrdersVsM2_s0_53_claude.pdf",
  "OPERatiosPDF"   -> "BcMixingMomentumOPERatiosVsM2_s0_53_claude.pdf",
  "ThetaCSV"       -> "BcMixingThetaOrdersData_s0_53_claude.csv",
  "OPERatiosCSV"   -> "BcMixingOPERatiosData_s0_53_claude.csv",
  "PertAt8_53"     -> pertVals[[13]],
  "PertG2At8_53"   -> g2Vals[[13]],
  "TotalAt8_53"    -> totalVals[[13]]
|>]];

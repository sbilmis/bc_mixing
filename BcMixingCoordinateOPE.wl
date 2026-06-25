(* ::Package:: *)

(*
  BcMixingCoordinateOPE.wl

  Independent coordinate-space OPE workbench for the B_c axial-vector
  mixing calculation.

  This file is deliberately separate from BcMixingMomentum.wl.  It must not
  call the momentum-space Feynman/Schwinger helper functions.  Its purpose is
  to build the coordinate-space condensate kernels and to keep the remaining
  Bessel/Schwinger reduction steps explicit.

  Current status:
    - G2c, G2b, G2local kernels are available from coordinate-space
      propagators.
    - G2c, G2b and G2gg have independent pole-weight Borel reductions.
    - G3c and G3b have independent pole-weight Borel reductions for the
      single-line dimension-6 truncation.
    - The full G2 result also requires the open-field cross-line term G2gg:
          S_c^(G)(-x) S_b^(G)(x).
*)

If[! NameQ["CoordinateTraceKernel"],
  Get["BcMixingCoordinate.wl"]
];

BcMixingCoordinateOPE::pending =
  "Independent coordinate-space Borel moment for order `1` is pending. Use CoordinateOPEStatus[] and CoordinateOPEReductionPlan[`1`] for the required derivation steps.";

BcMixingCoordinateOPE::badorder =
  "Unknown coordinate OPE order `1`.";

BcMixingCoordinateOPE::badscan =
  "Invalid scan specification `1`. Use {min,max,n}, {min,max}, or an explicit numeric list.";

ClearAll[
  CoordinateOPEStatus,
  CoordinateOPEEnvironment,
  CoordinateOPEValidateOrder,
  CoordinateOPEG2Status,
  CoordinateOPEG2KernelReport,
  CoordinateOPEExportG2KernelsTeX,
  CoordinateOPEExportAllG2KernelsTeX,
  CoordinateOPEKernel,
  CoordinateOPEKernelTable,
  CoordinateOPEScalarize,
  CoordinateOPEKernelTerms,
  CoordinateOPEBesselFactors,
  CoordinateOPEKernelTermData,
  CoordinateOPEKernelReductionTable,
  CoordinateOPEBesselSchwingerMap,
  CoordinateOPETermBorelTemplate,
  CoordinateOPEKernelBorelTemplate,
  CoordinateOPEGaussianFourierRule,
  CoordinateOPEGaussianOperatorRecipe,
  CoordinateOPESchwingerVariableRecipe,
  CoordinateOPETermWeightRecipe,
  CoordinateOPEKernelWeightRecipe,
  CoordinateOPEExportG2ReductionTeX,
  CoordinateOPEExportAllG2ReductionTeX,
  CoordinateOPEMixingChannels,
  CoordinateOPEOrderPieces,
  CoordinateOPEWeightKey,
  CoordinateOPEInstallWeight,
  CoordinateOPEClearInstalledWeights,
  CoordinateOPEInstalledWeightKeys,
  CoordinateOPERequiredWeightKeys,
  CoordinateOPERequiredWeightSymbols,
  CoordinateOPEMissingWeightReport,
  CoordinateOPEInstalledWeight,
  CoordinateOPEBorelIntegrandFromWeights,
  CoordinateOPEResidualPowerSummary,
  CoordinateOPECanonicalSchwingerPrefactor,
  CoordinateOPECanonicalResidualPower,
  CoordinateOPECanonicalSchwingerIntegrand,
  CoordinateOPEFourierOperatorExpression,
  CoordinateOPETermDerivationSheet,
  CoordinateOPEKernelDerivationSheets,
  CoordinateOPEG2ReductionWorkbook,
  CoordinateOPEG2CompletionReport,
  CoordinateOPEBorelMomentReadyQ,
  CoordinateOPEKernelInventory,
  CoordinateOPEBesselIdentity,
  CoordinateOPESbar,
  CoordinateOPEXMinus,
  CoordinateOPEXPlus,
  CoordinateOPESupportRule,
  CoordinateOPEDeltaDerivativeRule,
  CoordinateOPEReductionPlan,
  CoordinateOPEBorelMoment,
  CoordinateOPEMixingAngle,
  CoordinateOPEG2ggFourierPhase,
  CoordinateOPEG2ggPolynomialMultiplier,
  CoordinateOPEFeynCalcGaussianMultiplier,
  CoordinateOPEFeynCalcGaussianMultiplierCheck,
  CoordinateOPEFeynCalcGaussianMultiplierReport,
  CoordinateOPEG2AmplitudeTerm,
  CoordinateOPEG2Amplitude,
  CoordinateOPEG2PoleWeights,
  CoordinateOPEG2PoleWeightCheck,
  CoordinateOPEG2BorelIntegrand,
  CoordinateOPEG2BorelMoment,
  CoordinateOPEG3PoleWeights,
  CoordinateOPEG3PoleWeightCheck,
  CoordinateOPEG3BorelMoment,
  CoordinateOPENumericOPESummary,
  CoordinateOPEG2ggAmplitudeTerm,
  CoordinateOPEG2ggAmplitude,
  CoordinateOPEG2ggPoleWeights,
  CoordinateOPEG2ggPoleWeightCheck,
  CoordinateOPEBorelTransformFromAmplitude,
  CoordinateOPEG2ggBorelIntegrand,
  CoordinateOPEG2ggBorelMoment,
CoordinateOPEMixingAngleWithG2gg,
  CoordinateOPEConvergenceRecord,
  CoordinateOPEConvergenceScan,
  CoordinateOPEConvergenceDataset,
  CoordinateOPEConvergenceCSVTable,
  CoordinateOPEExportConvergenceCSV,
  CoordinateOPEScanValues,
  CoordinateOPEContributionRecord,
  CoordinateOPEContributionDataset,
  CoordinateOPEContributionBarChart,
  CoordinateOPEMixingAngleOrderM2Data,
  CoordinateOPEMixingAngleOrderM2PublicationPlot,
  CoordinateOPEMixingAngleOrderM2PublicationPlotFromData,
  CoordinateOPEContributionRatioM2Data,
  CoordinateOPEContributionRatioM2PublicationPlot,
  CoordinateOPEContributionRatioM2PublicationPlotFromData,
  CoordinateOPEM2StabilityData,
  CoordinateOPES0StabilityData,
  CoordinateOPEM2StabilityPublicationPlot,
  CoordinateOPES0StabilityPublicationPlot,
  CoordinateOPEM2StabilityPublicationPlotFromData,
  CoordinateOPES0StabilityPublicationPlotFromData,
  CoordinateOPEMonteCarloEvaluationOrder,
  CoordinateOPEMonteCarloMixingAngleSamples,
  CoordinateOPEMonteCarloMixingAngleUncertainty,
  CoordinateOPEMonteCarloMixingAngleDataset,
  CoordinateOPEMonteCarloMixingAngleValues,
  CoordinateOPEMonteCarloMixingAngleGaussianSummary,
  CoordinateOPEMonteCarloMixingAnglePublicationHistogram,
  CoordinateOPEMonteCarloSampleTable,
  CoordinateOPEExportMonteCarloMixingAngleSamples,
  CoordinateOPEExportMonteCarloMixingAngleSummary,
  CoordinateOPEG2ggOpenFieldPropagatorNote,
  CoordinateOPEG2ggContraction,
  CoordinateOPEParametersAndOptions,
  CoordinateOPEJournalChecklist
];

$BcCoordinateOPEOrders = {
  "pert",
  "G2c", "G2b", "G2local",
  "G2gg", "G2full", "pertG2full",
  "G3c", "G3b", "G3local",
  "G3full", "totalFull"
};

$BcCoordinateOPEKernelOrders = {
  "pert",
  "G2c", "G2b", "G2local", "G2gg", "G2full", "pertG2full",
  "G3c", "G3b", "G3local"
};

$BcCoordinateOPEMixingChannels = {"AA", "AB", "BB"};
$BcCoordinateOPEWeightRules = <||>;
$BcCoordinateOPEPoleWeightOrders = {"G2c", "G2b", "G2gg", "G3c", "G3b"};
$BcCoordinateOPEGaussianPowerPairs = {
  {0, 0}, {1, 0}, {2, 0},
  {0, 1}, {1, 1}, {2, 1},
  {0, 2}, {1, 2}, {2, 2}
};

CoordinateOPEMixingChannels[] := $BcCoordinateOPEMixingChannels;

CoordinateOPEScanValues[spec : {_?NumericQ, _?NumericQ, _Integer?Positive}] := Module[
  {lo = spec[[1]], hi = spec[[2]], n = spec[[3]]},
  N[Subdivide[lo, hi, Max[1, n - 1]]]
];

CoordinateOPEScanValues[spec : {_?NumericQ, _?NumericQ}] :=
  N[spec];

CoordinateOPEScanValues[spec_List] /; VectorQ[spec, NumericQ] :=
  N[spec];

CoordinateOPEScanValues[spec_] := (
  Message[BcMixingCoordinateOPE::badscan, ToString[Unevaluated[spec], InputForm]];
  $Failed
);

CoordinateOPEOrderPieces["G2local"] := {"G2c", "G2b"};
CoordinateOPEOrderPieces["G2full"] := {"G2c", "G2b", "G2gg"};
CoordinateOPEOrderPieces["pertG2full"] := {"pert", "G2full"};
CoordinateOPEOrderPieces["G3local"] := {"G3c", "G3b"};
CoordinateOPEOrderPieces["G3full"] := {"G3c", "G3b"};
CoordinateOPEOrderPieces["totalFull"] := {"pert", "G2full", "G3full"};
CoordinateOPEOrderPieces[order_String] := {order};

CoordinateOPEParametersAndOptions[params_, opts_List] := If[
  AssociationQ[params],
  {params, opts},
  {$BcCoordinateDefaultParameters, Join[{params}, opts]}
];

CoordinateOPEWeightKey[
  channel_String,
  order_String,
  termIndex_,
  derivativeOrder_
] := {
  channel,
  order,
  Round[termIndex],
  Round[derivativeOrder]
};

CoordinateOPEValidateOrder[order_String] := If[
  MemberQ[$BcCoordinateOPEOrders, order],
  order,
  Message[BcMixingCoordinateOPE::badorder, order];
  Abort[]
];

CoordinateOPEStatus[] := <|
  "IndependentFile" -> "BcMixingCoordinateOPE.wl",
  "DoesNotLoadMomentumOPE" -> True,
  "KernelLevelAvailable" -> $BcCoordinateOPEKernelOrders,
  "NumericalBorelAvailableNow" -> {
    "pert",
    "G2c", "G2b", "G2local", "G2gg", "G2full", "pertG2full",
    "G3c", "G3b", "G3local", "G3full", "totalFull"
  },
  "PendingNumericalBorel" -> Complement[
    $BcCoordinateOPEOrders,
    {
      "pert",
      "G2c", "G2b", "G2local", "G2gg", "G2full", "pertG2full",
      "G3c", "G3b", "G3local", "G3full", "totalFull"
    }
  ],
  "FeynCalcDerivativeAudit" ->
    "Available: CoordinateOPEFeynCalcGaussianMultiplierReport[] checks the Gaussian source multipliers with FourDivergence and FourLaplacian.",
  "MainNextTarget" -> "Audit the shared coordinate-space sign/normalization convention and check OPE hierarchy across the Borel window.",
  "PublicationRule" -> "G2full and the single-line G3full truncation are numerically available; quote them only after the sign/normalization audit is accepted."
|>;

CoordinateOPEEnvironment[] := <|
  "CoordinateLoaded" -> NameQ["CoordinateTraceKernel"],
  "CoordinateStatus" -> If[NameQ["CoordinateIndependenceStatus"], CoordinateIndependenceStatus[], Missing["NotLoaded"]],
  "OPEStatus" -> CoordinateOPEStatus[],
  "Threshold" -> If[NameQ["CoordinateThreshold"], CoordinateThreshold[], Missing["NotLoaded"]],
  "TensorCurrentScale" -> If[NameQ["CoordinateTensorCurrentScale"], CoordinateTensorCurrentScale[], Missing["NotLoaded"]]
|>;

CoordinateOPEG2Status[channel_String : "AA"] := <|
  "Channel" -> channel,
  "KernelPieces" -> <|
    "G2c" -> If[CoordinateOPEKernel[channel, "G2c"] === $Failed, "Missing", "Available"],
    "G2b" -> If[CoordinateOPEKernel[channel, "G2b"] === $Failed, "Missing", "Available"],
    "G2gg" -> If[CoordinateOPEKernel[channel, "G2gg"] === $Failed, "Missing", "Available"],
    "G2full" -> If[CoordinateOPEKernel[channel, "G2full"] === $Failed, "Missing", "Available"]
  |>,
  "NumericalBorelPieces" -> <|
    "G2c" -> "Available: explicit pole weights and direct Borel moment implemented",
    "G2b" -> "Available: explicit pole weights and direct Borel moment implemented",
    "G2gg" -> "Available: explicit pole weights and direct Borel moment implemented",
    "G2full" -> "Available as G2c + G2b + G2gg"
  |>,
  "NextStep" -> "Audit the overall sign/normalization convention against an independent hand check."
|>;

CoordinateOPEG2KernelReport[channel_String : "AA", projected_: True] := Module[
  {pieces = {"G2c", "G2b", "G2gg", "G2full"}, kernels, inventories},
  kernels = AssociationMap[CoordinateOPEKernel[channel, #, projected] &, pieces];
  inventories = AssociationMap[CoordinateOPEKernelInventory[channel, #, projected] &, pieces];
  <|
    "Channel" -> channel,
    "Projected" -> projected,
    "Status" -> CoordinateOPEG2Status[channel],
    "Kernels" -> kernels,
    "Inventories" -> inventories,
    "Check" -> "Verify G2full equals G2c + G2b + G2gg and audit the shared sign/normalization convention."
  |>
];

CoordinateOPEExportG2KernelsTeX[
  channel_String : "AA",
  file_String : Automatic,
  projected_: True
] := Module[
  {target, pieces = {"G2c", "G2b", "G2gg", "G2full"}, stream},
  target = Replace[file, Automatic -> ("BcMixingCoordinateOPE_" <> channel <> "_G2Kernels.tex")];
  stream = OpenWrite[target, CharacterEncoding -> "UTF8"];
  WriteString[stream, "% Coordinate-space G2 kernels for channel " <> channel <> "\n"];
  WriteString[stream, "% Generated by CoordinateOPEExportG2KernelsTeX.\n\n"];
  Do[
    WriteString[stream, "\\subsection*{" <> piece <> "}\n"];
    WriteString[
      stream,
      Quiet[
        ToString[TeXForm[CoordinateOPEKernel[channel, piece, projected]]],
        TeXForm::unspt
      ] <> "\n\n"
    ],
    {piece, pieces}
  ];
  Close[stream];
  target
];

CoordinateOPEExportAllG2KernelsTeX[
  channels_: Automatic,
  directory_String : ".",
  projected_: True
] := Module[
  {chs = Replace[channels, Automatic -> CoordinateOPEMixingChannels[]]},
  AssociationMap[
    CoordinateOPEExportG2KernelsTeX[
      #,
      FileNameJoin[{directory, "BcMixingCoordinateOPE_" <> # <> "_G2Kernels.tex"}],
      projected
    ] &,
    chs
  ]
];

CoordinateOPEKernel[
  channel_String,
  order_String,
  projected_: True
] := CoordinateOPEKernel[channel, order, projected] = Module[
  {ord = CoordinateOPEValidateOrder[order]},
  If[! MemberQ[$BcCoordinateOPEKernelOrders, ord],
    Message[BcMixingCoordinateOPE::pending, ord];
    Return[$Failed]
  ];
  CoordinateTraceKernel[channel, ord, projected]
];

CoordinateOPEKernelTable[order_String, projected_: True] := Module[
  {ord = CoordinateOPEValidateOrder[order]},
  AssociationMap[
    CoordinateOPEKernel[#, ord, projected] &,
    {"AA", "AB", "BB"}
  ]
];

CoordinateOPEScalarize[expr_] :=
  expr /. {
      SP[xv, xv] -> x2,
      SP[p, xv] -> px,
      SP[xv, p] -> px,
      SP[p, p] -> s,
      Pair[Momentum[xv], Momentum[xv]] -> x2,
      Pair[Momentum[p], Momentum[xv]] -> px,
      Pair[Momentum[xv], Momentum[p]] -> px,
      Pair[Momentum[p], Momentum[p]] -> s
    } // Simplify;

CoordinateOPEKernelTerms[
  channel_String,
  order_String,
  projected_: True
] := CoordinateOPEKernelTerms[channel, order, projected] = Module[
  {kernel = CoordinateOPEKernel[channel, order, projected], expanded},
  If[kernel === $Failed, Return[$Failed]];
  expanded = Expand[CoordinateOPEScalarize[kernel]];
  If[Head[expanded] === Plus, List @@ expanded, {expanded}]
];

CoordinateOPEBesselFactors[term_] :=
  Cases[term, BesselK[nu_, arg_] :> BesselK[nu, arg], Infinity];

CoordinateOPEPower[expr_, sym_] := Module[
  {pow},
  pow = Exponent[expr, sym];
  If[pow === -Infinity, 0, pow]
];

CoordinateOPEKernelTermData[
  term_,
  index_Integer : 1
] := Module[
  {bessels, stripped, pxPow, x2Pow, rPow, coefficient, besselData},
  bessels = CoordinateOPEBesselFactors[term];
  stripped = If[bessels === {}, term, term/(Times @@ bessels)] // Together;
  pxPow = CoordinateOPEPower[stripped, px];
  stripped = Together[stripped/px^pxPow];
  x2Pow = CoordinateOPEPower[stripped, x2];
  stripped = Together[stripped/x2^x2Pow];
  rPow = CoordinateOPEPower[stripped, r];
  coefficient = Together[stripped/r^rPow] // Simplify;
  besselData = bessels /. BesselK[nu_, mass_. r] :> <|"Nu" -> nu, "Mass" -> mass|>;
  <|
    "Index" -> index,
    "Coefficient" -> coefficient,
    "PxPower" -> pxPow,
    "X2Power" -> x2Pow,
    "RPower" -> rPow,
    "BesselFactors" -> besselData,
    "OriginalTerm" -> term,
    "SchwingerTarget" -> "Reduce coefficient * px^a * x2^b * r^c * Product[K_nu(m r)] using the Bessel identities and p-derivatives."
  |>
];

CoordinateOPEKernelReductionTable[
  channel_String,
  order_String,
  projected_: True
] := CoordinateOPEKernelReductionTable[channel, order, projected] = Module[
  {terms = CoordinateOPEKernelTerms[channel, order, projected]},
  If[terms === $Failed, Return[$Failed]];
  MapIndexed[
    CoordinateOPEKernelTermData[#1, First[#2]] &,
    terms
  ]
];

CoordinateOPEBesselSchwingerMap[besselAssoc_Association, schwingerSymbol_] := Module[
  {nu = besselAssoc["Nu"], mass = besselAssoc["Mass"]},
  <|
    "Bessel" -> HoldForm[BesselK[nu, mass r]],
    "CanonicalIdentity" -> CoordinateOPEBesselIdentity[nu, mass, r, schwingerSymbol],
    "Note" -> "If the term has extra powers of r, keep them with X2Power/RPower before the Gaussian x integral."
  |>
];

CoordinateOPETermBorelTemplate[termAssoc_Association, var_: x] := Module[
  {a = termAssoc["PxPower"], b = termAssoc["X2Power"], c = termAssoc["RPower"],
   coeff = termAssoc["Coefficient"], bmap},
  bmap = MapIndexed[
    CoordinateOPEBesselSchwingerMap[#1, ToExpression["t" <> ToString[First[#2]]]] &,
    termAssoc["BesselFactors"]
  ];
  <|
    "TermIndex" -> termAssoc["Index"],
    "Coefficient" -> coeff,
    "PDerivativeOrder" -> a,
    "X2Power" -> b,
    "RPower" -> c,
    "BesselSchwingerMaps" -> bmap,
    "Sbar" -> CoordinateOPESbar[var],
    "Support" -> CoordinateOPESupportRule[var, s],
    "DeltaDerivativeFamily" -> Table[
      CoordinateOPEDeltaDerivativeRule[W[termAssoc["Index"], n, var], n, var, s, M2],
      {n, 0, Max[0, a + Abs[c]]}
    ],
    "Status" -> "Template only: W[index,n,x] must be filled by carrying out the Gaussian x integral and Schwinger parameter reduction."
  |>
];

CoordinateOPEKernelBorelTemplate[
  channel_String,
  order_String,
  projected_: True,
  var_: x
] := CoordinateOPEKernelBorelTemplate[channel, order, projected, var] = Module[
  {table = CoordinateOPEKernelReductionTable[channel, order, projected]},
  If[table === $Failed, Return[$Failed]];
  CoordinateOPETermBorelTemplate[#, var] & /@ table
];

CoordinateOPEGaussianFourierRule[scale_: A, source_: ell] := <|
  "Integral" -> HoldForm[
    FourDimensionalIntegral[
      Exp[I source (p . xCoord) + scale xCoord^2],
      xCoord
    ]
  ],
  "ReducedForm" -> HoldForm[
    Pi^2/(-scale)^2 Exp[-source^2 p2/(4 scale)]
  ],
  "Convention" -> "Four-dimensional Euclidean radial reduction after Wick rotation; scale must be negative for convergence.",
  "Use" -> "Generate powers of px by differentiating with respect to the source, and powers of x2 by differentiating with respect to the Gaussian scale."
|>;

CoordinateOPEGaussianOperatorRecipe[termAssoc_Association] := Module[
  {a = termAssoc["PxPower"], b = termAssoc["X2Power"], c = termAssoc["RPower"],
   nuSum, canonicalRPower, residualRPower, x2Extra, x2DerivativeOrder,
   residualCaveat},
  nuSum = Total[Lookup[termAssoc["BesselFactors"], "Nu", {}]];
  canonicalRPower = -nuSum;
  residualRPower = c - canonicalRPower;
  x2Extra = If[IntegerQ[residualRPower] && EvenQ[residualRPower] && residualRPower >= 0,
    residualRPower/2,
    Missing["NotGeneratedBySimpleX2Derivative"]
  ];
  x2DerivativeOrder = If[Head[x2Extra] === Missing,
    Missing["NeedsSeparateRadialReduction"],
    b + x2Extra
  ];
  residualCaveat = Which[
    residualRPower === 0,
      "All r-powers are absorbed by the canonical K_nu(m r)/r^nu Schwinger maps.",
    Head[x2Extra] === Missing,
      "Residual r-power is not a non-negative even power. This term needs a separate radial-derivative or integration-by-parts reduction before numerical use.",
    True,
      "Residual r-power can be written as (r^2)^n and generated with x2/Gaussian-scale derivatives, up to the Euclidean sign convention."
  ];
  <|
    "PxPower" -> a,
    "X2Power" -> b,
    "RPowerInTerm" -> c,
    "SumOfBesselOrders" -> nuSum,
    "CanonicalRPowerNeededByBesselMaps" -> canonicalRPower,
    "ResidualRPowerAfterBesselMaps" -> residualRPower,
    "ExtraX2DerivativeFromResidualR" -> x2Extra,
    "TotalX2DerivativeOrderCandidate" -> x2DerivativeOrder,
    "SourceDerivativeRecipe" -> HoldForm[
      (1/I^a) D[GaussianBase[A, ell], {ell, a}] /. ell -> 1
    ],
    "ScaleDerivativeRecipe" -> If[Head[x2DerivativeOrder] === Missing,
      Missing["NeedsSeparateRadialReduction"],
      HoldForm[D[GaussianBase[A, ell], {A, x2DerivativeOrder}]]
    ],
    "Caveat" -> residualCaveat
  |>
];

CoordinateOPESchwingerVariableRecipe[var_: x] := <|
  "Purpose" -> "After replacing Bessel functions by Schwinger parameters, combine the Gaussian scales into one Feynman parameter.",
  "SupportSbar" -> CoordinateOPESbar[var],
  "PhysicalDomain" -> HoldForm[0 < var < 1],
  "ContinuumDomain" -> HoldForm[CoordinateOPEXMinus[s0] < var < CoordinateOPEXPlus[s0]],
  "BorelSupport" -> CoordinateOPESupportRule[var, s],
  "RequiredManualCheck" -> "Fix the exact Jacobian and sign convention from the chosen K_nu/r^nu identities before turning W[index,n,x] into numeric code."
|>;

CoordinateOPETermWeightRecipe[termAssoc_Association, var_: x] := Module[
  {template = CoordinateOPETermBorelTemplate[termAssoc, var],
   gaussian = CoordinateOPEGaussianOperatorRecipe[termAssoc]},
  <|
    "TermIndex" -> termAssoc["Index"],
    "Coefficient" -> termAssoc["Coefficient"],
    "OriginalTerm" -> termAssoc["OriginalTerm"],
    "Powers" -> KeyTake[termAssoc, {"PxPower", "X2Power", "RPower"}],
    "BesselFactors" -> termAssoc["BesselFactors"],
    "BesselSchwingerMaps" -> template["BesselSchwingerMaps"],
    "GaussianOperatorRecipe" -> gaussian,
    "SchwingerVariableRecipe" -> CoordinateOPESchwingerVariableRecipe[var],
    "DeltaDerivativeFamily" -> template["DeltaDerivativeFamily"],
    "WeightSymbolsToDerive" -> Cases[
      template["DeltaDerivativeFamily"],
      W[termAssoc["Index"], n_, var] :> W[termAssoc["Index"], n, var],
      Infinity
    ],
    "Status" -> "Ready for hand reduction: derive the W[index,n,x] weights from the listed Bessel maps, Gaussian operator and Schwinger-variable Jacobian."
  |>
];

CoordinateOPEKernelWeightRecipe[
  channel_String,
  order_String,
  projected_: True,
  var_: x
] := CoordinateOPEKernelWeightRecipe[channel, order, projected, var] = Module[
  {table = CoordinateOPEKernelReductionTable[channel, order, projected]},
  If[table === $Failed, Return[$Failed]];
  CoordinateOPETermWeightRecipe[#, var] & /@ table
];

CoordinateOPEExportG2ReductionTeX[
  channel_String : "AA",
  file_String : Automatic,
  projected_: True
] := Module[
  {target, pieces = {"G2c", "G2b", "G2gg", "G2full"}, stream},
  target = Replace[file, Automatic -> ("BcMixingCoordinateOPE_" <> channel <> "_G2Reduction.tex")];
  stream = OpenWrite[target, CharacterEncoding -> "UTF8"];
  WriteString[stream, "% Coordinate-space G2 reduction recipes for channel " <> channel <> "\n"];
  WriteString[stream, "% Generated by CoordinateOPEExportG2ReductionTeX.\n"];
  WriteString[stream, "% These are reduction recipes, not final numerical Borel moments.\n\n"];
  Do[
    WriteString[stream, "\\subsection*{" <> piece <> " reduction table}\n"];
    WriteString[
      stream,
      Quiet[
        ToString[TeXForm[CoordinateOPEKernelReductionTable[channel, piece, projected]]],
        TeXForm::unspt
      ] <> "\n\n"
    ];
    WriteString[stream, "\\subsection*{" <> piece <> " weight recipe}\n"];
    WriteString[
      stream,
      Quiet[
        ToString[TeXForm[CoordinateOPEKernelWeightRecipe[channel, piece, projected]]],
        TeXForm::unspt
      ] <> "\n\n"
    ],
    {piece, pieces}
  ];
  Close[stream];
  target
];

CoordinateOPEExportAllG2ReductionTeX[
  channels_: Automatic,
  directory_String : ".",
  projected_: True
] := Module[
  {chs = Replace[channels, Automatic -> CoordinateOPEMixingChannels[]]},
  AssociationMap[
    CoordinateOPEExportG2ReductionTeX[
      #,
      FileNameJoin[{directory, "BcMixingCoordinateOPE_" <> # <> "_G2Reduction.tex"}],
      projected
    ] &,
    chs
  ]
];

CoordinateOPERequiredWeightSymbols[
  channel_String,
  order_String,
  projected_: True,
  var_: x
] := CoordinateOPERequiredWeightSymbols[channel, order, projected, var] = Module[
  {ord = CoordinateOPEValidateOrder[order], pieces, activePieces,
   recipe},
  If[MemberQ[$BcCoordinateOPEPoleWeightOrders, ord], Return[{}]];
  pieces = CoordinateOPEOrderPieces[ord];
  activePieces = DeleteCases[pieces, "pert" | "G2gg"];
  If[Length[pieces] > 1,
    Return[
      DeleteDuplicates @ Flatten[
        CoordinateOPERequiredWeightSymbols[channel, #, projected, var] & /@ activePieces
      ]
    ]
  ];
  recipe = CoordinateOPEKernelWeightRecipe[channel, ord, projected, var];
  If[recipe === $Failed, Return[$Failed]];
  DeleteDuplicates @ Flatten[Lookup[recipe, "WeightSymbolsToDerive", {}]]
];

CoordinateOPERequiredWeightKeys[
  channel_String,
  order_String,
  projected_: True,
  var_: x
] := CoordinateOPERequiredWeightKeys[channel, order, projected, var] = Module[
  {symbols = CoordinateOPERequiredWeightSymbols[channel, order, projected, var]},
  If[symbols === $Failed, Return[$Failed]];
  DeleteDuplicates[
    Cases[
      symbols,
      W[index_, deriv_, var] :> CoordinateOPEWeightKey[channel, order, index, deriv],
      Infinity
    ]
  ]
];

CoordinateOPEInstallWeight[
  channel_String,
  order_String,
  termIndex_Integer,
  derivativeOrder_Integer,
  weightExpr_,
  var_: x
] := Module[
  {key = CoordinateOPEWeightKey[channel, order, termIndex, derivativeOrder], record},
  record = <|
    "Channel" -> channel,
    "Order" -> order,
    "TermIndex" -> Round[termIndex],
    "DerivativeOrder" -> Round[derivativeOrder],
    "Variable" -> var,
    "Weight" -> weightExpr,
    "Convention" -> "Weight multiplies delta^(n)(s - sbar[x]) after the independent coordinate-space Schwinger/Gaussian reduction."
  |>;
  AssociateTo[$BcCoordinateOPEWeightRules, key -> record];
  key
];

CoordinateOPEClearInstalledWeights[] := (
  $BcCoordinateOPEWeightRules = <||>;
  "Cleared coordinate-space OPE installed weights."
);

CoordinateOPEInstalledWeightKeys[] := Keys[$BcCoordinateOPEWeightRules];

CoordinateOPEInstalledWeight[
  channel_String,
  order_String,
  termIndex_Integer,
  derivativeOrder_Integer
] := Module[
  {key = CoordinateOPEWeightKey[channel, order, termIndex, derivativeOrder]},
  If[
    KeyExistsQ[$BcCoordinateOPEWeightRules, key],
    $BcCoordinateOPEWeightRules[key],
    Missing["NotInstalled"]
  ]
];

CoordinateOPEMissingWeightReport[
  channel_String,
  order_String,
  projected_: True,
  var_: x
] := Module[
  {pieces = CoordinateOPEOrderPieces[order], expanded, needed, installed},
  expanded = DeleteCases[pieces, "pert" | "G2gg"];
  needed = If[expanded === {order},
    CoordinateOPERequiredWeightKeys[channel, order, projected, var],
    Flatten[CoordinateOPERequiredWeightKeys[channel, #, projected, var] & /@ expanded, 1]
  ];
  If[MemberQ[needed, $Failed], Return[$Failed]];
  installed = CoordinateOPEInstalledWeightKeys[];
  <|
    "Channel" -> channel,
    "Order" -> order,
    "RequiredCount" -> Length[needed],
    "InstalledCount" -> Count[needed, _?(MemberQ[installed, #] &)],
    "MissingCount" -> Length[Complement[needed, installed]],
    "MissingKeys" -> Complement[needed, installed],
    "InstalledKeysForOrder" -> Intersection[needed, installed]
  |>
];

CoordinateOPEBorelIntegrandFromWeights[
  channel_String,
  order_String,
  projected_: True,
  var_: x
] := Module[
  {missing = CoordinateOPEMissingWeightReport[channel, order, projected, var],
   keys, contributions},
  If[missing === $Failed, Return[$Failed]];
  If[missing["MissingCount"] > 0, Return[Missing["WeightsNotInstalled", missing]]];
  keys = missing["InstalledKeysForOrder"];
  contributions = Function[key,
    With[
      {
        ch = key[[1]],
        ord = key[[2]],
        index = key[[3]],
        deriv = key[[4]]
      },
      With[
        {record = CoordinateOPEInstalledWeight[ch, ord, index, deriv]},
        CoordinateOPEDeltaDerivativeRule[record["Weight"], deriv, var, s, M2]["BorelWeight"]
      ]
    ]
  ] /@ keys;
  Total[contributions] // Together // Simplify
];

CoordinateOPEResidualPowerSummary[
  channel_String,
  order_String,
  projected_: True
] := CoordinateOPEResidualPowerSummary[channel, order, projected] = Module[
  {table = CoordinateOPEKernelReductionTable[channel, order, projected],
   recipes, residuals, caveats},
  If[table === $Failed, Return[$Failed]];
  recipes = CoordinateOPEGaussianOperatorRecipe /@ table;
  residuals = Lookup[recipes, "ResidualRPowerAfterBesselMaps", {}];
  caveats = Lookup[recipes, "Caveat", {}];
  <|
    "Channel" -> channel,
    "Order" -> order,
    "TermCount" -> Length[table],
    "ResidualRPowerCounts" -> Counts[residuals],
    "CaveatCounts" -> Counts[caveats],
    "NeedsSeparateRadialReduction" ->
      Count[caveats, _String?(StringContainsQ[#, "separate radial-derivative"] &)],
    "SimpleGaussianScaleDerivativeTerms" ->
      Count[caveats, _String?(StringContainsQ[#, "generated with x2/Gaussian-scale"] &)],
    "CanonicalTerms" ->
      Count[caveats, _String?(StringContainsQ[#, "absorbed by the canonical"] &)]
  |>
];

CoordinateOPECanonicalSchwingerPrefactor[termAssoc_Association] := Module[
  {bessels = termAssoc["BesselFactors"]},
  Times @@ (
    bessels /. assoc_Association :>
      assoc["Mass"]^assoc["Nu"]/2^(assoc["Nu"] + 1)
  )
];

CoordinateOPECanonicalResidualPower[termAssoc_Association] := Module[
  {c = termAssoc["RPower"], nuSum},
  nuSum = Total[Lookup[termAssoc["BesselFactors"], "Nu", {}]];
  c + nuSum
];

CoordinateOPECanonicalSchwingerIntegrand[termAssoc_Association] := Module[
  {bessels = termAssoc["BesselFactors"], tSymbols, schwingerProduct,
   gaussianScale, prefactor, residualPower},
  tSymbols = Table[ToExpression["t" <> ToString[i]], {i, Length[bessels]}];
  schwingerProduct = Times @@ MapThread[
    (#2^(-#1["Nu"] - 1) Exp[-#2]) &,
    {bessels, tSymbols}
  ];
  gaussianScale = Total @ MapThread[
    (#1["Mass"]^2/(4 #2)) &,
    {bessels, tSymbols}
  ];
  prefactor = CoordinateOPECanonicalSchwingerPrefactor[termAssoc];
  residualPower = CoordinateOPECanonicalResidualPower[termAssoc];
  With[
    {
      coeff = termAssoc["Coefficient"],
      pf = prefactor,
      measure = schwingerProduct,
      aPow = termAssoc["PxPower"],
      bPow = termAssoc["X2Power"],
      rPow = residualPower,
      scale = gaussianScale
    },
    <|
      "TermIndex" -> termAssoc["Index"],
      "CanonicalBesselPrefactor" -> prefactor,
      "SchwingerVariables" -> tSymbols,
      "SchwingerMeasureKernel" -> schwingerProduct,
      "GaussianScaleA" -> gaussianScale,
      "ResidualRPowerAfterCanonicalBesselMaps" -> residualPower,
      "FormalIntegrandBeforeGaussianXIntegral" -> HoldForm[
        coeff pf measure
          (p . xCoord)^aPow (xCoord^2)^bPow r^rPow
          Exp[I p . xCoord + scale xCoord^2]
      ],
      "Note" -> "The displayed expression is formal; replace r^2 by -xCoord^2 consistently after Wick rotation."
    |>
  ]
];

CoordinateOPEFourierOperatorExpression[termAssoc_Association] := Module[
  {gaussian = CoordinateOPEGaussianOperatorRecipe[termAssoc]},
  <|
    "TermIndex" -> termAssoc["Index"],
    "GaussianBase" -> CoordinateOPEGaussianFourierRule[A, ell],
    "SourceDerivativeOrder" -> gaussian["PxPower"],
    "ScaleDerivativeOrderCandidate" -> gaussian["TotalX2DerivativeOrderCandidate"],
    "SourceDerivative" -> gaussian["SourceDerivativeRecipe"],
    "ScaleDerivative" -> gaussian["ScaleDerivativeRecipe"],
    "ResidualPowerCaveat" -> gaussian["Caveat"]
  |>
];

CoordinateOPETermDerivationSheet[termAssoc_Association, var_: x] := <|
  "TermData" -> termAssoc,
  "CanonicalSchwingerStep" -> CoordinateOPECanonicalSchwingerIntegrand[termAssoc],
  "FourierOperatorStep" -> CoordinateOPEFourierOperatorExpression[termAssoc],
  "BorelTemplate" -> CoordinateOPETermBorelTemplate[termAssoc, var],
  "WeightRecipe" -> CoordinateOPETermWeightRecipe[termAssoc, var],
  "InstallTemplate" -> HoldForm[
    CoordinateOPEInstallWeight[channel, order, termIndex, derivativeOrder, weightExpression, var]
  ] /. {
    termIndex -> termAssoc["Index"]
  }
|>;

CoordinateOPEKernelDerivationSheets[
  channel_String,
  order_String,
  projected_: True,
  var_: x
] := CoordinateOPEKernelDerivationSheets[channel, order, projected, var] = Module[
  {table = CoordinateOPEKernelReductionTable[channel, order, projected]},
  If[table === $Failed, Return[$Failed]];
  CoordinateOPETermDerivationSheet[#, var] & /@ table
];

CoordinateOPEG2ReductionWorkbook[
  channels_: Automatic,
  projected_: True
] := Module[
  {chs = Replace[channels, Automatic -> CoordinateOPEMixingChannels[]],
   pieces = {"G2c", "G2b", "G2gg", "G2full"}},
  AssociationMap[
    Function[ch,
      AssociationMap[
        Function[piece,
          <|
            "Inventory" -> CoordinateOPEKernelInventory[ch, piece, projected],
            "ResidualPowerSummary" -> CoordinateOPEResidualPowerSummary[ch, piece, projected],
            "RequiredWeightSymbols" -> CoordinateOPERequiredWeightSymbols[ch, piece, projected],
            "MissingWeights" -> CoordinateOPEMissingWeightReport[ch, piece, projected],
            "WeightRecipePreview" -> Short[CoordinateOPEKernelWeightRecipe[ch, piece, projected], 3]
          |>
        ],
        pieces
      ]
    ],
    chs
  ]
];

CoordinateOPEBorelMomentReadyQ[order_String] := Module[
  {ord = CoordinateOPEValidateOrder[order], pieces},
  If[MemberQ[Join[{"pert"}, $BcCoordinateOPEPoleWeightOrders], ord], Return[True]];
  pieces = CoordinateOPEOrderPieces[ord];
  AllTrue[pieces, CoordinateOPEBorelMomentReadyQ]
];

CoordinateOPEBorelMomentReadyQ[
  channel_String,
  order_String,
  projected_: True,
  var_: x
] := Module[
  {ord = CoordinateOPEValidateOrder[order], pieces, missing},
  If[ord === "pert", Return[True]];
  If[MemberQ[$BcCoordinateOPEPoleWeightOrders, ord],
    Return[CoordinateOPEG2PoleWeightCheck[channel, ord, var] === 0]
  ];
  pieces = CoordinateOPEOrderPieces[ord];
  If[Length[pieces] > 1,
    Return[AllTrue[pieces, CoordinateOPEBorelMomentReadyQ[channel, #, projected, var] &]]
  ];
  missing = CoordinateOPEMissingWeightReport[channel, ord, projected, var];
  If[missing === $Failed, Return[False]];
  missing["MissingCount"] === 0
];

CoordinateOPEG2CompletionReport[
  channels_: Automatic,
  projected_: True
] := Module[
  {chs = Replace[channels, Automatic -> CoordinateOPEMixingChannels[]],
   pieces = {"G2c", "G2b", "G2gg", "G2full"}, kernelStatus},
  kernelStatus = AssociationMap[
    Function[ch,
      AssociationMap[
        Function[piece,
          <|
            "KernelAvailable" -> TrueQ[CoordinateOPEKernel[ch, piece, projected] =!= $Failed],
            "BorelMomentReady" -> CoordinateOPEBorelMomentReadyQ[ch, piece, projected],
            "ResidualPowerSummary" -> CoordinateOPEResidualPowerSummary[ch, piece, projected],
            "RequiredWeights" -> Short[CoordinateOPERequiredWeightSymbols[ch, piece, projected], 3]
          |>
        ],
        pieces
      ]
    ],
    chs
  ];
  <|
    "ChannelsNeededForTheta" -> chs,
    "OrdersNeededForFullDimension4" -> pieces,
    "KernelLevelStatus" -> kernelStatus,
    "NumericalCoordinateG2Status" ->
      "Not enabled yet: derive and install explicit W[index,n,x] weights for each listed channel and order.",
    "SafeNotebookUseNow" ->
      "Use this workbook to export kernels and reduction recipes; do not quote coordinate-space G2 numerical angles from it yet.",
    "NextImplementationStep" ->
      "The canonical G2 weights are generated by CoordinateOPEG2PoleWeights. Remaining noncanonical future kernels can still use the manual W[index,n,x] installation path."
  |>
];

CoordinateOPEKernelInventory[
  channel_String,
  order_String,
  projected_: True
] := CoordinateOPEKernelInventory[channel, order, projected] = Module[
  {terms = CoordinateOPEKernelTerms[channel, order, projected]},
  If[terms === $Failed, Return[$Failed]];
  <|
    "Channel" -> channel,
    "Order" -> order,
    "Projected" -> projected,
    "TermCount" -> Length[terms],
    "BesselProducts" ->
      Counts[
        Sort /@ (
          Cases[#, BesselK[nu_, arg_] :> {nu, arg}, Infinity] & /@ terms
        )
      ],
    "ReductionTablePreview" -> Short[CoordinateOPEKernelReductionTable[channel, order, projected], 5],
    "BorelTemplatePreview" -> Short[CoordinateOPEKernelBorelTemplate[channel, order, projected], 3],
    "WeightRecipePreview" -> Short[CoordinateOPEKernelWeightRecipe[channel, order, projected], 3],
    "SampleTerms" -> Short[terms, 5]
  |>
];

CoordinateOPEBesselIdentity[nu_, mass_: m, radius_: r, schwinger_: t] :=
  HoldForm[
    BesselK[nu, mass radius]/radius^nu ==
      mass^nu/2^(nu + 1)
        Integrate[
          schwinger^(-nu - 1) Exp[-schwinger - mass^2 radius^2/(4 schwinger)],
          {schwinger, 0, Infinity}
        ]
  ];

CoordinateOPESbar[var_: x] :=
  (mc^2 var + mb^2 (1 - var))/(var (1 - var));

CoordinateOPEXMinus[ss_: s] :=
  (ss + mb^2 - mc^2 - Sqrt[CoordinateKallenLambda[ss, mb, mc]])/(2 ss);

CoordinateOPEXPlus[ss_: s] :=
  (ss + mb^2 - mc^2 + Sqrt[CoordinateKallenLambda[ss, mb, mc]])/(2 ss);

CoordinateOPESupportRule[var_: x, ss_: s] := <|
  "Sbar" -> CoordinateOPESbar[var],
  "PhysicalThreshold" -> (mb + mc)^2,
  "Support" -> HoldForm[HeavisideTheta[ss - (mb + mc)^2]],
  "ContinuumDomain" -> HoldForm[
    CoordinateOPEXMinus[s0] < var < CoordinateOPEXPlus[s0]
  ],
  "ContinuumReplacement" -> HoldForm[
    Integrate[F[var] HeavisideTheta[s0 - CoordinateOPESbar[var]], {var, 0, 1}] ->
      Integrate[F[var], {var, CoordinateOPEXMinus[s0], CoordinateOPEXPlus[s0]}]
  ]
|>;

CoordinateOPEDeltaDerivativeRule[
  weight_: F[x],
  derivativeOrder_Integer : 0,
  var_: x,
  ss_: s,
  m2_: M2
] := Module[
  {sbar = CoordinateOPESbar[var]},
  <|
    "Distribution" -> HoldForm[Derivative[derivativeOrder][DiracDelta][ss - sbar]],
    "BorelWeight" ->
      ((-1)^derivativeOrder D[Exp[-ss/m2] weight, {ss, derivativeOrder}] /. ss -> sbar) //
        Together // Simplify,
    "Support" -> CoordinateOPESupportRule[var, ss]
  |>
];

CoordinateOPEReductionPlan[order_String] := Module[
  {ord = CoordinateOPEValidateOrder[order]},
  Switch[
    ord,
    "pert",
      {
        "Use the independent coordinate-space perturbative spectral density already implemented in BcMixingCoordinate.wl.",
        "Evaluate with CoordinateOPEBorelMoment[channel, \"pert\", M2, s0].",
        "No condensate W[index,n,x] weights are needed for this order."
      },
    "G2c" | "G2b",
      {
        "Start from CoordinateOPEKernel[channel, \"" <> ord <> "\"]",
        "Expand the kernel into scalar monomials in x2 and px times BesselK[nu, mc r] BesselK[mu, mb r].",
        "Use CoordinateOPEBesselIdentity for both BesselK factors.",
        "Do the Gaussian x integral; powers of px are generated by p-derivatives.",
        "Change Schwinger variables to the single Feynman parameter x and the total scale.",
        "Apply the Borel transform, producing delta derivatives in s - sbar[x].",
        "Use CoordinateOPEDeltaDerivativeRule and integrate over x in the finite x_- to x_+ domain."
      },
    "G2gg",
      {
        "Write the open-field coordinate propagator S_Q^(G)(x) before vacuum averaging.",
        "Build Tr[Gamma_i S_c^(G)(-x) Gamma_j S_b^(G)(x)].",
        "Contract the two background fields with CoordinateOPEG2ggContraction[].",
        "Reduce the resulting Bessel/radial terms with the same pole-weight method.",
        "This piece is implemented in CoordinateOPEG2ggPoleWeights and checked by CoordinateOPEG2ggPoleWeightCheck."
      },
    "G2local",
      Join[CoordinateOPEReductionPlan["G2c"], CoordinateOPEReductionPlan["G2b"]],
    "G2full" | "pertG2full",
      {
        "Use the implemented independent G2c, G2b and G2gg Borel moments.",
        "G2full = G2c + G2b + G2gg.",
        "pertG2full = pert + G2full.",
        "Before paper-final use, audit the common coordinate-space phase/sign and normalization convention."
      },
    "G3c" | "G3b",
      {
        "Start from CoordinateOPEKernel[channel, \"" <> ord <> "\"]",
        "Reduce the local single-line G3 Bessel products independently.",
        "Check OPE hierarchy against perturbative and G2full moments."
      },
    "G3local",
      Join[CoordinateOPEReductionPlan["G3c"], CoordinateOPEReductionPlan["G3b"]],
    "G3full" | "totalFull",
      {
        "Use the implemented single-line G3c and G3b Borel moments.",
        "G3full = G3c + G3b in the current truncation.",
        "totalFull = pert + G2full + G3full.",
        "Before paper-final use, state that open-field dimension-6 cross-line terms are not included, or derive them separately."
      }
  ]
];

CoordinateOPEG2ggOpenFieldPropagatorNote[] := <|
  "Purpose" -> "This term is required for a full independent coordinate-space G2 result.",
  "CoordinateOpenFieldKernelUsed" -> HoldForm[
    -1/(8 (2 Pi)^2) (
      I sign mQ (sigma[alpha, beta] . Slash[x] + Slash[x] . sigma[alpha, beta])
        BesselK[1, mQ R]/R +
      2 mQ sigma[alpha, beta] BesselK[0, mQ R]
    )
  ],
  "CoordinateTask" -> "Fourier transform this open-field propagator, keep G_A^{alpha beta} explicit, and only then contract S_c^(G) S_b^(G).",
  "Caveat" -> "The exact x-space open-field Bessel form and signs must be checked against the heavy-quark propagator convention before numerical use."
|>;

CoordinateOPEG2ggContraction[] :=
  HoldForm[
    VacuumAverage[
      gs^2 Gfield[A, alpha, beta] Gfield[B, rho, sigma]
    ] ==
      delta[A, B] G2/96 (
        g[alpha, rho] g[beta, sigma] -
        g[alpha, sigma] g[beta, rho]
      )
  ];

CoordinateOPEBorelMoment[
  channel_String,
  order_String,
  m2Val_?NumericQ,
  continuumVal_?NumericQ,
  params_: $BcCoordinateDefaultParameters,
  opts : OptionsPattern[NIntegrate]
] := Module[
  {ord = CoordinateOPEValidateOrder[order], parameterAssoc, optionList,
   pieces, values, missing, integrand, lims, numericIntegrand, numericOpts},
  {parameterAssoc, optionList} = CoordinateOPEParametersAndOptions[params, {opts}];
  numericOpts = FilterRules[optionList, Options[NIntegrate]];
  If[ord === "pert",
    Return[CoordinateNumericBorelPi[channel, "pert", m2Val, continuumVal, parameterAssoc, Sequence @@ numericOpts]]
  ];
  If[MemberQ[$BcCoordinateOPEPoleWeightOrders, ord],
    Return[CoordinateOPEG2BorelMoment[channel, ord, m2Val, continuumVal, parameterAssoc, Sequence @@ numericOpts]]
  ];
  pieces = CoordinateOPEOrderPieces[ord];
  If[Length[pieces] > 1,
    values = CoordinateOPEBorelMoment[channel, #, m2Val, continuumVal, parameterAssoc, Sequence @@ numericOpts] & /@ pieces;
    If[AllTrue[values, NumericQ], Return[Total[values]]];
    Message[BcMixingCoordinateOPE::pending, ord];
    Return[
      <|
        "Channel" -> channel,
        "Order" -> ord,
        "M2" -> m2Val,
        "s0" -> continuumVal,
        "Status" -> "Pending because at least one component is not numerically ready.",
        "ComponentValues" -> AssociationThread[pieces, values],
        "ReductionPlan" -> CoordinateOPEReductionPlan[ord]
      |>
    ]
  ];
  missing = CoordinateOPEMissingWeightReport[channel, ord];
  If[missing === $Failed, Return[$Failed]];
  If[missing["MissingCount"] > 0,
    Message[BcMixingCoordinateOPE::pending, ord];
    Return[
      <|
        "Channel" -> channel,
        "Order" -> ord,
        "M2" -> m2Val,
        "s0" -> continuumVal,
        "KernelStatus" -> If[
          MemberQ[$BcCoordinateOPEKernelOrders, ord],
          "Kernel available; numerical Borel reduction pending.",
          "Kernel or truncation rule pending."
        ],
        "Status" -> "Pending independent Bessel/Schwinger reduction weights.",
        "MissingWeights" -> missing,
        "ReductionPlan" -> CoordinateOPEReductionPlan[ord]
      |>
    ]
  ];
  integrand = CoordinateOPEBorelIntegrandFromWeights[channel, ord];
  If[Head[integrand] === Missing, Return[integrand]];
  lims = {
      CoordinateOPEXMinus[s0],
      CoordinateOPEXPlus[s0]
    } /. CoordinateParameterRules[parameterAssoc] /. s0 -> continuumVal;
  numericIntegrand = Evaluate[
    integrand /. CoordinateParameterRules[parameterAssoc] /. {M2 -> m2Val, s0 -> continuumVal}
  ];
  If[TrueQ[numericIntegrand === 0] || TrueQ[PossibleZeroQ[numericIntegrand]],
    Return[0.]
  ];
  Apply[
    NIntegrate,
    Join[
      {
        Evaluate[numericIntegrand],
        {x, N[lims[[1]]], N[lims[[2]]]}
      },
      numericOpts
    ]
  ]
];

CoordinateOPEG2ggFourierPhase[] := -I;

CoordinateOPEG2ggSchwingerFraction[mass_, var_: x] := Which[
  TrueQ[Simplify[mass === mc]], var,
  TrueQ[Simplify[mass === mb]], 1 - var,
  True, f[mass, var]
];

CoordinateOPEG2ggPolynomialMultiplier[
  pxPower_Integer,
  x2Power_Integer,
  lambda_,
  var_: x,
  ss_: s
] := Module[
  {ell = lambda var (1 - var), source = jj, scale = aa, gaussian},
  gaussian = scale^-2 Exp[-source^2 ss/(4 scale)];
  FullSimplify[
    ((1/I)^pxPower (-1)^x2Power
      D[gaussian, {source, pxPower}, {scale, x2Power}]/gaussian) /.
      {source -> 1, scale -> -1/(4 ell)}
  ]
];

CoordinateOPEFeynCalcDirectionalDerivative[expr_, source_, vector_] := Module[
  {idx = Unique["fcLor"]},
  FeynCalc`Contract[
    FeynCalc`FV[vector, idx]
      FeynCalc`FourDivergence[expr, FeynCalc`FV[source, idx]]
  ] // FeynCalc`FCE // FeynCalc`Contract // Simplify
];

CoordinateOPEFeynCalcLaplacianDerivative[expr_, source_] :=
  FeynCalc`FourLaplacian[expr, source, source] //
    FeynCalc`FCE // FeynCalc`Contract // Simplify;

CoordinateOPEFeynCalcScalarRules[source_, vector_, ss_] := {
  FeynCalc`Pair[FeynCalc`Momentum[source, ___], FeynCalc`Momentum[source, ___]] -> ss,
  FeynCalc`Pair[FeynCalc`Momentum[source, ___], FeynCalc`Momentum[vector, ___]] -> ss,
  FeynCalc`Pair[FeynCalc`Momentum[vector, ___], FeynCalc`Momentum[source, ___]] -> ss,
  FeynCalc`Pair[FeynCalc`Momentum[vector, ___], FeynCalc`Momentum[vector, ___]] -> ss,
  HoldPattern[dim_Symbol /; SymbolName[Unevaluated[dim]] === "D"] :> 4
};

CoordinateOPEFeynCalcGaussianMultiplier[
  pxPower_Integer,
  x2Power_Integer,
  lambda_,
  var_: x,
  ss_: s
] := Module[
  {ell = lambda var (1 - var), source = jjv, scale = aa, gaussian,
   differentiated, ratio},
  Needs["FeynCalc`"];
  gaussian = FeynCalc`FCI[
    scale^-2 Exp[-FeynCalc`SP[source, source]/(4 scale)]
  ];
  differentiated = Nest[
    CoordinateOPEFeynCalcDirectionalDerivative[#, source, p] &,
    gaussian,
    pxPower
  ];
  differentiated = Nest[
    -CoordinateOPEFeynCalcLaplacianDerivative[#, source] &,
    differentiated,
    x2Power
  ];
  ratio = Together[
    (1/I)^pxPower differentiated/gaussian
      /. CoordinateOPEFeynCalcScalarRules[source, p, ss]
      /. scale -> -1/(4 ell)
  ];
  FullSimplify[ratio]
];

CoordinateOPEFeynCalcGaussianMultiplierCheck[
  pxPower_Integer,
  x2Power_Integer,
  lambda_: lam,
  var_: x,
  ss_: s
] := FullSimplify[
  CoordinateOPEFeynCalcGaussianMultiplier[pxPower, x2Power, lambda, var, ss] -
    CoordinateOPEG2ggPolynomialMultiplier[pxPower, x2Power, lambda, var, ss]
];

CoordinateOPEFeynCalcGaussianMultiplierReport[pairs_: Automatic] := Module[
  {powerPairs = Replace[pairs, Automatic -> $BcCoordinateOPEGaussianPowerPairs]},
  <|
    "Purpose" ->
      "Independent FeynCalc FourDivergence/FourLaplacian check of the Gaussian source multipliers used in the coordinate-space pole weights.",
    "Convention" ->
      "(p.x)^a is generated by (1/I)^a directional source derivatives; (x^2)^b is generated by b applications of -FourLaplacian on the source.",
    "PowerChecks" -> (
      <|
        "PxPower" -> #[[1]],
        "X2Power" -> #[[2]],
        "MathematicaDMultiplier" ->
          CoordinateOPEG2ggPolynomialMultiplier[#[[1]], #[[2]], lam, x, s],
        "FeynCalcMultiplier" ->
          CoordinateOPEFeynCalcGaussianMultiplier[#[[1]], #[[2]], lam, x, s],
        "Difference" ->
          CoordinateOPEFeynCalcGaussianMultiplierCheck[#[[1]], #[[2]], lam, x, s]
      |> & /@ powerPairs
    )
  |>
];

CoordinateOPEG2AmplitudeTerm[termAssoc_Association, var_: x] := Module[
  {lambda = lam, bessels = termAssoc["BesselFactors"], fracs, prefactor,
   residualPower, measure, base, poly, integrandNoExp, d, expanded, powers},
  residualPower = termAssoc["RPower"] + Total[Lookup[bessels, "Nu", {}]];
  If[residualPower =!= 0,
    Return[HoldForm[ResidualRadialPowerNeedsReduction[termAssoc["Index"], residualPower]]]
  ];
  fracs = CoordinateOPEG2ggSchwingerFraction[#, var] & /@ Lookup[bessels, "Mass", {}];
  prefactor = Times @@ (
    bessels /. assoc_Association :>
      assoc["Mass"]^(-assoc["Nu"])/2^(assoc["Nu"] + 1)
  );
  measure = lambda Times @@ MapThread[
    (lambda #2)^(-#1["Nu"] - 1) &,
    {bessels, fracs}
  ];
  base = CoordinateOPEG2ggFourierPhase[] Pi^2 16 lambda^2 var^2 (1 - var)^2;
  poly = CoordinateOPEG2ggPolynomialMultiplier[
    termAssoc["PxPower"],
    termAssoc["X2Power"],
    lambda,
    var,
    s
  ];
  d = mc^2 var + mb^2 (1 - var) - s var (1 - var);
  integrandNoExp = Together[
    termAssoc["Coefficient"] prefactor measure base poly
  ] // Expand;
  powers = Exponent[integrandNoExp, lambda];
  If[powers === -Infinity, Return[0]];
  Total[
    Table[
      With[
        {c = Coefficient[integrandNoExp, lambda, n]},
        If[c === 0, 0, c Factorial[n]/d^(n + 1)]
      ],
      {n, 0, powers}
    ]
  ] // Together // Simplify
];

CoordinateOPEG2Amplitude[channel_String, order_String, var_: x] :=
  CoordinateOPEG2Amplitude[channel, order, var] = Module[
    {ord = CoordinateOPEValidateOrder[order],
     terms},
    If[! MemberQ[$BcCoordinateOPEPoleWeightOrders, ord], Return[$Failed]];
    terms = CoordinateOPEKernelReductionTable[channel, ord];
    If[terms === $Failed, Return[$Failed]];
    Total[CoordinateOPEG2AmplitudeTerm[#, var] & /@ terms] //
      Together // Simplify
  ];

CoordinateOPEG2PoleWeights[channel_String, order_String, var_: x, m2_: M2] :=
  CoordinateOPEG2PoleWeights[channel, order, var, m2] = Module[
    {ord = CoordinateOPEValidateOrder[order],
     terms, sb, u, termExpr, shifted, maxPole, coeff},
    If[! MemberQ[$BcCoordinateOPEPoleWeightOrders, ord], Return[$Failed]];
    terms = CoordinateOPEKernelReductionTable[channel, ord];
    If[terms === $Failed, Return[$Failed]];
    sb = CoordinateOPESbar[var];
    u = Unique["pole"];
    DeleteCases[
      Flatten[
        Table[
          termExpr = CoordinateOPEG2AmplitudeTerm[term, var];
          shifted = Apart[Together[termExpr /. s -> sb + u], u] // Expand;
          maxPole = Max[
            Cases[shifted, Power[u, n_Integer?Negative] :> -n, Infinity],
            0
          ];
          Table[
            coeff = Coefficient[shifted, u, -r] // Together // Simplify;
            If[TrueQ[coeff === 0],
              Nothing,
              <|
                "Channel" -> channel,
                "Order" -> ord,
                "TermIndex" -> term["Index"],
                "PoleOrder" -> r,
                "DerivativeOrder" -> r - 1,
                "PoleWeight" -> coeff,
                "BorelWeight" ->
                  Together[
                    (-1)^r coeff Exp[-sb/m2]/(Factorial[r - 1] m2^(r - 1))
                  ] // Simplify,
                "Convention" ->
                  "PoleWeight is the coefficient of (s - sbar[x])^-PoleOrder. BorelWeight is the direct Borel contribution."
              |>
            ],
            {r, 1, maxPole}
          ],
          {term, terms}
        ],
        1
      ],
      Null
    ]
  ];

CoordinateOPEG2BorelIntegrand[channel_String, order_String, var_: x, m2_: M2] :=
  CoordinateOPEG2BorelIntegrand[channel, order, var, m2] =
    Total[Lookup[CoordinateOPEG2PoleWeights[channel, order, var, m2], "BorelWeight", {}]] //
      Together // Simplify;

CoordinateOPEG2PoleWeightCheck[channel_String, order_String, var_: x, m2_: M2] := Module[
  {fromWeights, direct},
  fromWeights = CoordinateOPEG2BorelIntegrand[channel, order, var, m2];
  direct = CoordinateOPEBorelTransformFromAmplitude[
    CoordinateOPEG2Amplitude[channel, order, var],
    var,
    m2
  ];
  Together[fromWeights - direct] // Simplify
];

CoordinateOPEG2ggAmplitudeTerm[termAssoc_Association, var_: x] :=
  CoordinateOPEG2AmplitudeTerm[termAssoc, var];

CoordinateOPEG2ggAmplitude[channel_String, var_: x] :=
  CoordinateOPEG2Amplitude[channel, "G2gg", var];

CoordinateOPEG2ggPoleWeights[channel_String, var_: x, m2_: M2] :=
  CoordinateOPEG2PoleWeights[channel, "G2gg", var, m2];

CoordinateOPEG2ggPoleWeightCheck[channel_String, var_: x, m2_: M2] :=
  CoordinateOPEG2PoleWeightCheck[channel, "G2gg", var, m2];

CoordinateOPEG3PoleWeights[channel_String, order_String, var_: x, m2_: M2] :=
  CoordinateOPEG2PoleWeights[channel, order, var, m2] /;
    MemberQ[{"G3c", "G3b"}, CoordinateOPEValidateOrder[order]];

CoordinateOPEG3PoleWeightCheck[channel_String, order_String, var_: x, m2_: M2] :=
  CoordinateOPEG2PoleWeightCheck[channel, order, var, m2] /;
    MemberQ[{"G3c", "G3b"}, CoordinateOPEValidateOrder[order]];

CoordinateOPEBorelTransformFromAmplitude[expr_, var_: x, m2_: M2] := Module[
  {q2, tau, sb, transformed, maxPower = 12},
  sb = CoordinateOPESbar[var];
  transformed = expr /. s -> -q2 /. q2 -> tau - sb;
  transformed = Apart[Together[transformed], tau] // Expand;
  Exp[-sb/m2] Sum[
    Coefficient[transformed, tau, -n]/(Factorial[n - 1] m2^(n - 1)),
    {n, 1, maxPower}
  ] // Together // Simplify
];

CoordinateOPEG2ggBorelIntegrand[channel_String, var_: x, m2_: M2] :=
  CoordinateOPEG2BorelIntegrand[channel, "G2gg", var, m2];

Options[CoordinateOPEG2BorelMoment] = Options[NIntegrate];

CoordinateOPEG2BorelMoment[
  channel_String,
  order_String,
  m2Val_?NumericQ,
  continuumVal_?NumericQ,
  params_: $BcCoordinateDefaultParameters,
  opts : OptionsPattern[]
] := Module[
  {ord = CoordinateOPEValidateOrder[order], parameterAssoc, optionList,
   lims, integrand, numericOpts},
  If[! MemberQ[$BcCoordinateOPEPoleWeightOrders, ord], Return[$Failed]];
  {parameterAssoc, optionList} = CoordinateOPEParametersAndOptions[params, {opts}];
  numericOpts = FilterRules[optionList, Options[NIntegrate]];
  lims = {
      CoordinateOPEXMinus[s0],
      CoordinateOPEXPlus[s0]
    } /. CoordinateParameterRules[parameterAssoc] /. s0 -> continuumVal;
  integrand = Evaluate[
    CoordinateOPEG2BorelIntegrand[channel, ord, x, M2] /.
      CoordinateParameterRules[parameterAssoc] /. {M2 -> m2Val, s0 -> continuumVal}
  ];
  If[TrueQ[integrand === 0] || TrueQ[PossibleZeroQ[integrand]], Return[0.]];
  Apply[
    NIntegrate,
    Join[
      {
        Evaluate[integrand],
        {x, N[lims[[1]]], N[lims[[2]]]}
      },
      numericOpts
    ]
  ]
];

Options[CoordinateOPEG3BorelMoment] = Options[NIntegrate];

CoordinateOPEG3BorelMoment[
  channel_String,
  order_String,
  m2Val_?NumericQ,
  continuumVal_?NumericQ,
  params_: $BcCoordinateDefaultParameters,
  opts : OptionsPattern[]
] /; MemberQ[{"G3c", "G3b"}, CoordinateOPEValidateOrder[order]] :=
  CoordinateOPEG2BorelMoment[channel, order, m2Val, continuumVal, params, opts];

Options[CoordinateOPEG2ggBorelMoment] = Options[NIntegrate];

CoordinateOPEG2ggBorelMoment[
  channel_String,
  m2Val_?NumericQ,
  continuumVal_?NumericQ,
  params_: $BcCoordinateDefaultParameters,
  opts : OptionsPattern[]
] := Module[
  {},
  CoordinateOPEG2BorelMoment[channel, "G2gg", m2Val, continuumVal, params, opts]
];

CoordinateOPEMixingAngleWithG2gg[
  m2Val_?NumericQ,
  continuumVal_?NumericQ,
  params_: $BcCoordinateDefaultParameters,
  opts : OptionsPattern[NIntegrate]
] := Module[
  {parameterAssoc, optionList, numericOpts, aa, ab, bb},
  {parameterAssoc, optionList} = CoordinateOPEParametersAndOptions[params, {opts}];
  numericOpts = FilterRules[optionList, Options[NIntegrate]];
  aa = CoordinateOPEBorelMoment["AA", "pert", m2Val, continuumVal, parameterAssoc, Sequence @@ numericOpts] +
    CoordinateOPEG2ggBorelMoment["AA", m2Val, continuumVal, parameterAssoc, Sequence @@ numericOpts];
  ab = CoordinateOPEBorelMoment["AB", "pert", m2Val, continuumVal, parameterAssoc, Sequence @@ numericOpts] +
    CoordinateOPEG2ggBorelMoment["AB", m2Val, continuumVal, parameterAssoc, Sequence @@ numericOpts];
  bb = CoordinateOPEBorelMoment["BB", "pert", m2Val, continuumVal, parameterAssoc, Sequence @@ numericOpts] +
    CoordinateOPEG2ggBorelMoment["BB", m2Val, continuumVal, parameterAssoc, Sequence @@ numericOpts];
  1/2 ArcTan[aa - bb, -2 ab] 180/Pi
];

CoordinateOPEMixingAngle[
  m2Val_?NumericQ,
  continuumVal_?NumericQ,
  order_String,
  params_: $BcCoordinateDefaultParameters,
  opts : OptionsPattern[NIntegrate]
] := Module[
  {ord = CoordinateOPEValidateOrder[order], parameterAssoc, optionList,
   aa, ab, bb, numericOpts},
  {parameterAssoc, optionList} = CoordinateOPEParametersAndOptions[params, {opts}];
  numericOpts = FilterRules[optionList, Options[NIntegrate]];
  aa = CoordinateOPEBorelMoment["AA", ord, m2Val, continuumVal, parameterAssoc, Sequence @@ numericOpts];
  ab = CoordinateOPEBorelMoment["AB", ord, m2Val, continuumVal, parameterAssoc, Sequence @@ numericOpts];
  bb = CoordinateOPEBorelMoment["BB", ord, m2Val, continuumVal, parameterAssoc, Sequence @@ numericOpts];
  If[And @@ (NumericQ /@ {aa, ab, bb}),
    1/2 ArcTan[aa - bb, -2 ab] 180/Pi,
    Message[BcMixingCoordinateOPE::pending, ord];
    <|
      "Order" -> ord,
      "M2" -> m2Val,
      "s0" -> continuumVal,
      "Status" -> "Pending independent coordinate-space condensate Borel moments",
      "AA" -> aa,
      "AB" -> ab,
      "BB" -> bb
    |>
  ]
];

CoordinateOPENumericOPESummary[
  m2Val_?NumericQ,
  continuumVal_?NumericQ,
  params_: $BcCoordinateDefaultParameters,
  opts : OptionsPattern[NIntegrate]
] := Module[
  {parameterAssoc, optionList, numericOpts, channels = {"AA", "AB", "BB"},
   byChannel, theta},
  {parameterAssoc, optionList} = CoordinateOPEParametersAndOptions[params, {opts}];
  numericOpts = FilterRules[optionList, Options[NIntegrate]];
  byChannel = AssociationMap[
    Function[ch,
      Module[{pert, g2, g3},
        pert = CoordinateOPEBorelMoment[ch, "pert", m2Val, continuumVal, parameterAssoc, Sequence @@ numericOpts];
        g2 = CoordinateOPEBorelMoment[ch, "G2full", m2Val, continuumVal, parameterAssoc, Sequence @@ numericOpts];
        g3 = CoordinateOPEBorelMoment[ch, "G3full", m2Val, continuumVal, parameterAssoc, Sequence @@ numericOpts];
        <|
          "pert" -> pert,
          "G2full" -> g2,
          "G3fullSingleLine" -> g3,
          "G2OverPert" -> g2/pert,
          "G3OverPert" -> g3/pert,
          "G3OverG2" -> g3/g2
        |>
      ]
    ],
    channels
  ];
  theta = <|
    "pert" -> CoordinateOPEMixingAngle[m2Val, continuumVal, "pert", parameterAssoc, Sequence @@ numericOpts],
    "pertG2full" -> CoordinateOPEMixingAngle[m2Val, continuumVal, "pertG2full", parameterAssoc, Sequence @@ numericOpts],
    "totalFull" -> CoordinateOPEMixingAngle[m2Val, continuumVal, "totalFull", parameterAssoc, Sequence @@ numericOpts]
  |>;
  <|
    "M2" -> m2Val,
    "s0" -> continuumVal,
    "Channels" -> byChannel,
    "ThetaDegrees" -> theta,
    "DeltaThetaG2Deg" -> theta["pertG2full"] - theta["pert"],
    "DeltaThetaG3Deg" -> theta["totalFull"] - theta["pertG2full"],
    "G3Convention" -> "single-line G3c + G3b truncation; no open-field cross-line dimension-6 terms included"
  |>
];

Options[CoordinateOPEConvergenceRecord] = Options[NIntegrate];

CoordinateOPEConvergenceRecord[
  m2Val_?NumericQ,
  continuumVal_?NumericQ,
  params_: $BcCoordinateDefaultParameters,
  opts : OptionsPattern[]
] := Module[
  {summary, channels = CoordinateOPEMixingChannels[], moments, theta,
   g2Ratios, g3Ratios, g3OverG2Ratios, finiteG3OverG2},
  summary = CoordinateOPENumericOPESummary[m2Val, continuumVal, params, opts];
  moments = summary["Channels"];
  theta = summary["ThetaDegrees"];
  g2Ratios = AssociationMap[moments[#]["G2OverPert"] &, channels];
  g3Ratios = AssociationMap[moments[#]["G3OverPert"] &, channels];
  g3OverG2Ratios = AssociationMap[
    If[TrueQ[PossibleZeroQ[moments[#]["G2full"]]], Indeterminate,
      moments[#]["G3fullSingleLine"]/moments[#]["G2full"]
    ] &,
    channels
  ];
  finiteG3OverG2 = DeleteCases[Abs[Values[g3OverG2Ratios]], _Indeterminate];
  <|
    "M2" -> N[m2Val],
    "s0" -> N[continuumVal],
    "AA_G2OverPert" -> g2Ratios["AA"],
    "AB_G2OverPert" -> g2Ratios["AB"],
    "BB_G2OverPert" -> g2Ratios["BB"],
    "MaxAbsG2OverPert" -> Max[Abs[Values[g2Ratios]]],
    "AA_G3OverPert" -> g3Ratios["AA"],
    "AB_G3OverPert" -> g3Ratios["AB"],
    "BB_G3OverPert" -> g3Ratios["BB"],
    "MaxAbsG3OverPert" -> Max[Abs[Values[g3Ratios]]],
    "AA_G3OverG2" -> g3OverG2Ratios["AA"],
    "AB_G3OverG2" -> g3OverG2Ratios["AB"],
    "BB_G3OverG2" -> g3OverG2Ratios["BB"],
    "MaxAbsG3OverG2" -> If[finiteG3OverG2 === {}, Indeterminate, Max[finiteG3OverG2]],
    "ThetaPertDeg" -> theta["pert"],
    "ThetaPertG2FullDeg" -> theta["pertG2full"],
    "ThetaTotalFullDeg" -> theta["totalFull"],
    "DeltaThetaG2FullDeg" -> theta["pertG2full"] - theta["pert"],
    "DeltaThetaG3FullDeg" -> theta["totalFull"] - theta["pertG2full"],
    "DeltaThetaTotalFullDeg" -> theta["totalFull"] - theta["pert"],
    "Convention" -> "Independent coordinate-space OPE workbench: G2full = G2c + G2b + G2gg; G3full = G3c + G3b single-line truncation."
  |>
];

Options[CoordinateOPEConvergenceScan] = Options[CoordinateOPEConvergenceRecord];

CoordinateOPEConvergenceScan[
  m2Spec_ : Append[$BcCoordinateWangWindow["M2Range"], 3],
  s0Spec_ : Append[$BcCoordinateWangWindow["s0Range"], 3],
  params_: $BcCoordinateDefaultParameters,
  opts : OptionsPattern[]
] := Module[
  {m2Vals = CoordinateOPEScanValues[m2Spec],
   s0Vals = CoordinateOPEScanValues[s0Spec]},
  If[m2Vals === $Failed || s0Vals === $Failed, Return[$Failed]];
  Flatten[
    Table[
      CoordinateOPEConvergenceRecord[m2v, s0v, params, opts],
      {m2v, m2Vals},
      {s0v, s0Vals}
    ],
    1
  ]
];

CoordinateOPEConvergenceDataset[
  m2Spec_ : Append[$BcCoordinateWangWindow["M2Range"], 3],
  s0Spec_ : Append[$BcCoordinateWangWindow["s0Range"], 3],
  params_: $BcCoordinateDefaultParameters,
  opts : OptionsPattern[CoordinateOPEConvergenceScan]
] :=
  Dataset[CoordinateOPEConvergenceScan[m2Spec, s0Spec, params, opts]];

CoordinateOPEConvergenceCSVTable[records_List] := Module[
  {keys},
  keys = {
    "M2", "s0",
    "AA_G2OverPert", "AB_G2OverPert", "BB_G2OverPert", "MaxAbsG2OverPert",
    "AA_G3OverPert", "AB_G3OverPert", "BB_G3OverPert", "MaxAbsG3OverPert",
    "AA_G3OverG2", "AB_G3OverG2", "BB_G3OverG2", "MaxAbsG3OverG2",
    "ThetaPertDeg", "ThetaPertG2FullDeg", "ThetaTotalFullDeg",
    "DeltaThetaG2FullDeg", "DeltaThetaG3FullDeg", "DeltaThetaTotalFullDeg"
  };
  Prepend[Lookup[#, keys] & /@ records, keys]
];

CoordinateOPEExportConvergenceCSV[
  records_List,
  file_String : "BcMixingCoordinateOPEConvergence.csv"
] :=
  CoordinateWriteCSV[file, CoordinateOPEConvergenceCSVTable[records]];

CoordinateOPEExportConvergenceCSV[
  m2Spec_,
  s0Spec_,
  file_String,
  params_: $BcCoordinateDefaultParameters,
  opts : OptionsPattern[CoordinateOPEConvergenceScan]
] := Module[
  {records = CoordinateOPEConvergenceScan[m2Spec, s0Spec, params, opts]},
  If[records === $Failed, Return[$Failed]];
  CoordinateOPEExportConvergenceCSV[records, file]
];

CoordinateOPEContributionRecord[
  m2Val_?NumericQ,
  continuumVal_?NumericQ,
  opts : OptionsPattern[NIntegrate]
] :=
  CoordinateOPEContributionRecord[
    m2Val, continuumVal, $BcCoordinateDefaultParameters, opts
  ];

CoordinateOPEContributionRecord[
  m2Val_?NumericQ,
  continuumVal_?NumericQ,
  params_Association,
  opts : OptionsPattern[NIntegrate]
] := Module[
  {summary = CoordinateOPENumericOPESummary[m2Val, continuumVal, params, opts],
   moments},
  moments = summary["Channels"];
  AssociationMap[
    <|
      "pert" -> moments[#]["pert"],
      "G2" -> moments[#]["G2full"],
      "G3" -> moments[#]["G3fullSingleLine"],
      "total" -> moments[#]["pert"] + moments[#]["G2full"] + moments[#]["G3fullSingleLine"],
      "G2OverPert" -> moments[#]["G2OverPert"],
      "G3OverPert" -> moments[#]["G3OverPert"]
    |> &,
    CoordinateOPEMixingChannels[]
  ]
];

CoordinateOPEContributionDataset[args___] :=
  Dataset[CoordinateOPEContributionRecord[args]];

Options[CoordinateOPEContributionBarChart] = {
  "Normalization" -> "OverPert",
  ImageSize -> 520,
  LabelStyle -> Directive[Black, 14, FontFamily -> "Times"],
  BaseStyle -> {FontFamily -> "Times"},
  PlotRange -> Automatic
};

CoordinateOPEContributionBarChart[
  m2Val_?NumericQ,
  continuumVal_?NumericQ,
  opts : OptionsPattern[]
] :=
  CoordinateOPEContributionBarChart[
    m2Val, continuumVal, $BcCoordinateDefaultParameters, opts
  ];

CoordinateOPEContributionBarChart[
  m2Val_?NumericQ,
  continuumVal_?NumericQ,
  params_Association,
  opts : OptionsPattern[]
] := Module[
  {numericOpts, record, channels = CoordinateOPEMixingChannels[], norm,
   values, legends, ylabel},
  numericOpts = FilterRules[{opts}, Options[NIntegrate]];
  record = CoordinateOPEContributionRecord[m2Val, continuumVal, params, Sequence @@ numericOpts];
  norm = OptionValue["Normalization"];
  {values, ylabel} = Switch[
    norm,
    "OverPert",
      {
        ({1, record[#]["G2OverPert"], record[#]["G3OverPert"]} & /@ channels),
        "Contribution / perturbative"
      },
    "Raw",
      {
        ({record[#]["pert"], record[#]["G2"], record[#]["G3"]} & /@ channels),
        "Borel moment"
      },
    "PercentOfTotal",
      {
        (100 {record[#]["pert"], record[#]["G2"], record[#]["G3"]}/record[#]["total"] & /@ channels),
        "Contribution / total (%)"
      },
    _,
      {
        ({1, record[#]["G2OverPert"], record[#]["G3OverPert"]} & /@ channels),
        "Contribution / perturbative"
      }
  ];
  legends = {"pert", Superscript["G", 2], Superscript["G", 3]};
  BarChart[
    values,
    ChartLayout -> "Grouped",
    ChartLegends -> Placed[legends, Above],
    ChartLabels -> Placed[channels, Below],
    ChartStyle -> {
      RGBColor[0.22, 0.39, 0.62],
      RGBColor[0.9, 0.55, 0.12],
      RGBColor[0.49, 0.65, 0.18]
    },
    Frame -> True,
    Axes -> False,
    FrameLabel -> {None, ylabel},
    LabelStyle -> OptionValue[LabelStyle],
    BaseStyle -> OptionValue[BaseStyle],
    ImageSize -> OptionValue[ImageSize],
    PlotRange -> OptionValue[PlotRange],
    GridLines -> {None, Automatic},
    GridLinesStyle -> Directive[GrayLevel[0.85], Dashed],
    PlotLabel -> Row[{
      "Coordinate space, ", Superscript["M", 2], " = ", m2Val, " ",
      Superscript["GeV", 2], ", ", Subscript["s", 0], " = ",
      continuumVal, " ", Superscript["GeV", 2]
    }]
  ]
];

CoordinateOPEM2StabilityData[
  m2Range : {_?NumericQ, _?NumericQ} : $BcCoordinateWangWindow["M2Range"],
  s0Values_List : $BcCoordinateWangWindow["s0Values"],
  order_String : "totalFull",
  params_: $BcCoordinateDefaultParameters,
  nPoints_Integer : 25,
  opts : OptionsPattern[NIntegrate]
] := Module[
  {m2Values = N[Subdivide[m2Range[[1]], m2Range[[2]], Max[1, nPoints - 1]]]},
  Association @ Table[
    s0v -> Table[
      {m2v, CoordinateOPEMixingAngle[m2v, s0v, order, params, opts]},
      {m2v, m2Values}
    ],
    {s0v, N[s0Values]}
  ]
];

CoordinateOPES0StabilityData[
  s0Range : {_?NumericQ, _?NumericQ} : $BcCoordinateWangWindow["s0Range"],
  m2Values_List : $BcCoordinateWangWindow["M2Values"],
  order_String : "totalFull",
  params_: $BcCoordinateDefaultParameters,
  nPoints_Integer : 25,
  opts : OptionsPattern[NIntegrate]
] := Module[
  {s0Values = N[Subdivide[s0Range[[1]], s0Range[[2]], Max[1, nPoints - 1]]]},
  Association @ Table[
    m2v -> Table[
      {s0v, CoordinateOPEMixingAngle[m2v, s0v, order, params, opts]},
      {s0v, s0Values}
    ],
    {m2v, N[m2Values]}
  ]
];

Options[CoordinateOPEM2StabilityPublicationPlot] = Join[
  Options[NIntegrate],
  {
    "NPoints" -> 25,
    "YHalfWidth" -> 1.0,
    "YPadFraction" -> 0.20,
    ImageSize -> 540,
    LabelStyle -> Directive[Black, 14, FontFamily -> "Times"],
    BaseStyle -> {FontFamily -> "Times"},
    PlotRange -> Automatic
  }
];

CoordinateOPEM2StabilityPublicationPlot[
  m2Range : {_?NumericQ, _?NumericQ} : $BcCoordinateWangWindow["M2Range"],
  s0Values_List : $BcCoordinateWangWindow["s0Values"],
  order_String : "totalFull",
  params_: $BcCoordinateDefaultParameters,
  opts : OptionsPattern[]
] := Module[
  {nPoints = Max[2, Round[OptionValue["NPoints"]]], numericOpts, data},
  numericOpts = FilterRules[{opts}, Options[NIntegrate]];
  data = CoordinateOPEM2StabilityData[m2Range, s0Values, order, params, nPoints, Sequence @@ numericOpts];
  CoordinateOPEM2StabilityPublicationPlotFromData[
    data,
    m2Range,
    Sequence @@ FilterRules[{opts}, Options[CoordinateOPEM2StabilityPublicationPlotFromData]]
  ]
];

Options[CoordinateOPEM2StabilityPublicationPlotFromData] =
  Options[CoordinateOPEM2StabilityPublicationPlot];

CoordinateOPEM2StabilityPublicationPlotFromData[
  data_Association,
  m2Range : {_?NumericQ, _?NumericQ} : $BcCoordinateWangWindow["M2Range"],
  opts : OptionsPattern[]
] := Module[
  {styles, labels, yRange, plotRange},
  styles = CoordinatePlotStyles[Length[data]];
  labels = Row[{Subscript["s", 0], " = ", CoordinateLegendNumber[#], " ", Superscript["GeV", 2]}] & /@ Keys[data];
  yRange = CoordinateThetaYRange[Values[data][[All, All, 2]], OptionValue["YHalfWidth"], OptionValue["YPadFraction"]];
  plotRange = Replace[OptionValue[PlotRange], Automatic -> {m2Range, yRange}];
  <|
    "Data" -> data,
    "Plot" -> ListLinePlot[
      Values[data],
      Frame -> True,
      Axes -> False,
      FrameLabel -> {
        Row[{Superscript["M", 2], " (", Superscript["GeV", 2], ")"}],
        Superscript["\[Theta]", "\[Degree]"]
      },
      LabelStyle -> OptionValue[LabelStyle],
      BaseStyle -> OptionValue[BaseStyle],
      ImageSize -> OptionValue[ImageSize],
      ImagePadding -> {{75, 20}, {60, 20}},
      PlotStyle -> styles,
      PlotMarkers -> Automatic,
      PlotRange -> plotRange,
      GridLines -> Automatic,
      GridLinesStyle -> Directive[GrayLevel[0.85], Dashed],
      PlotLegends -> Placed[LineLegend[styles, labels, LegendMarkerSize -> 18], Right]
    ]
  |>
];

Options[CoordinateOPES0StabilityPublicationPlot] = Options[CoordinateOPEM2StabilityPublicationPlot];

CoordinateOPES0StabilityPublicationPlot[
  s0Range : {_?NumericQ, _?NumericQ} : $BcCoordinateWangWindow["s0Range"],
  m2Values_List : $BcCoordinateWangWindow["M2Values"],
  order_String : "totalFull",
  params_: $BcCoordinateDefaultParameters,
  opts : OptionsPattern[]
] := Module[
  {nPoints = Max[2, Round[OptionValue["NPoints"]]], numericOpts, data},
  numericOpts = FilterRules[{opts}, Options[NIntegrate]];
  data = CoordinateOPES0StabilityData[s0Range, m2Values, order, params, nPoints, Sequence @@ numericOpts];
  CoordinateOPES0StabilityPublicationPlotFromData[
    data,
    s0Range,
    Sequence @@ FilterRules[{opts}, Options[CoordinateOPES0StabilityPublicationPlotFromData]]
  ]
];

Options[CoordinateOPES0StabilityPublicationPlotFromData] =
  Options[CoordinateOPES0StabilityPublicationPlot];

CoordinateOPES0StabilityPublicationPlotFromData[
  data_Association,
  s0Range : {_?NumericQ, _?NumericQ} : $BcCoordinateWangWindow["s0Range"],
  opts : OptionsPattern[]
] := Module[
  {styles, labels, yRange, plotRange},
  styles = CoordinatePlotStyles[Length[data]];
  labels = Row[{Superscript["M", 2], " = ", CoordinateLegendNumber[#], " ", Superscript["GeV", 2]}] & /@ Keys[data];
  yRange = CoordinateThetaYRange[Values[data][[All, All, 2]], OptionValue["YHalfWidth"], OptionValue["YPadFraction"]];
  plotRange = Replace[OptionValue[PlotRange], Automatic -> {s0Range, yRange}];
  <|
    "Data" -> data,
    "Plot" -> ListLinePlot[
      Values[data],
      Frame -> True,
      Axes -> False,
      FrameLabel -> {
        Row[{Subscript["s", 0], " (", Superscript["GeV", 2], ")"}],
        Superscript["\[Theta]", "\[Degree]"]
      },
      LabelStyle -> OptionValue[LabelStyle],
      BaseStyle -> OptionValue[BaseStyle],
      ImageSize -> OptionValue[ImageSize],
      ImagePadding -> {{75, 20}, {60, 20}},
      PlotStyle -> styles,
      PlotMarkers -> Automatic,
      PlotRange -> plotRange,
      GridLines -> Automatic,
      GridLinesStyle -> Directive[GrayLevel[0.85], Dashed],
      PlotLegends -> Placed[LineLegend[styles, labels, LegendMarkerSize -> 18], Right]
    ]
  |>
];

CoordinateOPEMixingAngleOrderM2Data[
  m2Range : {_?NumericQ, _?NumericQ} : $BcCoordinateWangWindow["M2Range"],
  continuumVal_?NumericQ,
  orders_List : {"pert", "pertG2full", "totalFull"},
  params_: $BcCoordinateDefaultParameters,
  nPoints_Integer : 25,
  opts : OptionsPattern[NIntegrate]
] := Module[
  {m2Values = N[Subdivide[m2Range[[1]], m2Range[[2]], Max[1, nPoints - 1]]],
   numericOpts},
  numericOpts = FilterRules[{opts}, Options[NIntegrate]];
  Association @ Table[
    order -> Table[
      {m2v, CoordinateOPEMixingAngle[m2v, continuumVal, order, params, Sequence @@ numericOpts]},
      {m2v, m2Values}
    ],
    {order, orders}
  ]
];

CoordinateOPEMixingAngleOrderLabel["pert"] := "\[Theta] pert";
CoordinateOPEMixingAngleOrderLabel["pertG2full"] := "\[Theta] pert + G2";
CoordinateOPEMixingAngleOrderLabel["totalFull"] := "\[Theta] pert + G2 + G3";
CoordinateOPEMixingAngleOrderLabel[order_] := ToString[order];

Options[CoordinateOPEMixingAngleOrderM2PublicationPlot] =
  Options[CoordinateOPEM2StabilityPublicationPlot];

CoordinateOPEMixingAngleOrderM2PublicationPlot[
  m2Range : {_?NumericQ, _?NumericQ} : $BcCoordinateWangWindow["M2Range"],
  continuumVal_?NumericQ,
  orders_List : {"pert", "pertG2full", "totalFull"},
  params_: $BcCoordinateDefaultParameters,
  opts : OptionsPattern[]
] := Module[
  {nPoints = Max[2, Round[OptionValue["NPoints"]]], numericOpts, data},
  numericOpts = FilterRules[{opts}, Options[NIntegrate]];
  data = CoordinateOPEMixingAngleOrderM2Data[m2Range, continuumVal, orders, params, nPoints, Sequence @@ numericOpts];
  CoordinateOPEMixingAngleOrderM2PublicationPlotFromData[
    data,
    m2Range,
    continuumVal,
    Sequence @@ FilterRules[{opts}, Options[CoordinateOPEMixingAngleOrderM2PublicationPlotFromData]]
  ]
];

Options[CoordinateOPEMixingAngleOrderM2PublicationPlotFromData] =
  Options[CoordinateOPEMixingAngleOrderM2PublicationPlot];

CoordinateOPEMixingAngleOrderM2PublicationPlotFromData[
  data_Association,
  m2Range : {_?NumericQ, _?NumericQ} : $BcCoordinateWangWindow["M2Range"],
  continuumVal_?NumericQ,
  opts : OptionsPattern[]
] := Module[
  {styles, labels, yRange, plotRange},
  styles = CoordinatePlotStyles[Length[data]];
  labels = CoordinateOPEMixingAngleOrderLabel /@ Keys[data];
  yRange = CoordinateThetaYRange[Values[data][[All, All, 2]], OptionValue["YHalfWidth"], OptionValue["YPadFraction"]];
  plotRange = Replace[OptionValue[PlotRange], Automatic -> {m2Range, yRange}];
  <|
    "Data" -> data,
    "Plot" -> ListLinePlot[
      Values[data],
      Frame -> True,
      Axes -> False,
      FrameLabel -> {
        Row[{Superscript["M", 2], " (", Superscript["GeV", 2], ")"}],
        Superscript["\[Theta]", "\[Degree]"]
      },
      LabelStyle -> OptionValue[LabelStyle],
      BaseStyle -> OptionValue[BaseStyle],
      ImageSize -> OptionValue[ImageSize],
      ImagePadding -> {{75, 20}, {60, 20}},
      PlotStyle -> styles,
      PlotMarkers -> Automatic,
      PlotRange -> plotRange,
      GridLines -> Automatic,
      GridLinesStyle -> Directive[GrayLevel[0.85], Dashed],
      PlotLabel -> Row[{
        "Coordinate space, ", Subscript["s", 0], " = ",
        CoordinateLegendNumber[continuumVal], " ", Superscript["GeV", 2]
      }],
      PlotLegends -> Placed[LineLegend[styles, labels, LegendMarkerSize -> 18], Right]
    ]
  |>
];

CoordinateOPEContributionRatioM2Data[
  m2Range : {_?NumericQ, _?NumericQ} : $BcCoordinateWangWindow["M2Range"],
  continuumVal_?NumericQ,
  params_: $BcCoordinateDefaultParameters,
  nPoints_Integer : 25,
  opts : OptionsPattern[NIntegrate]
] := Module[
  {m2Values = N[Subdivide[m2Range[[1]], m2Range[[2]], Max[1, nPoints - 1]]],
   numericOpts, rec},
  numericOpts = FilterRules[{opts}, Options[NIntegrate]];
  Association @ Table[
    channel -> Table[
      rec = CoordinateOPEContributionRecord[m2v, continuumVal, params, Sequence @@ numericOpts];
      {m2v, rec[channel]["G2OverPert"], rec[channel]["G3OverPert"]},
      {m2v, m2Values}
    ],
    {channel, CoordinateOPEMixingChannels[]}
  ]
];

Options[CoordinateOPEContributionRatioM2PublicationPlot] = Join[
  Options[NIntegrate],
  {
    "NPoints" -> 25,
    "UseAbs" -> True,
    ImageSize -> 620,
    LabelStyle -> Directive[Black, 14, FontFamily -> "Times"],
    BaseStyle -> {FontFamily -> "Times"},
    PlotRange -> Automatic
  }
];

CoordinateOPEContributionRatioM2PublicationPlot[
  m2Range : {_?NumericQ, _?NumericQ} : $BcCoordinateWangWindow["M2Range"],
  continuumVal_?NumericQ,
  params_: $BcCoordinateDefaultParameters,
  opts : OptionsPattern[]
] := Module[
  {nPoints = Max[2, Round[OptionValue["NPoints"]]], numericOpts, data},
  numericOpts = FilterRules[{opts}, Options[NIntegrate]];
  data = CoordinateOPEContributionRatioM2Data[m2Range, continuumVal, params, nPoints, Sequence @@ numericOpts];
  CoordinateOPEContributionRatioM2PublicationPlotFromData[
    data,
    m2Range,
    continuumVal,
    Sequence @@ FilterRules[{opts}, Options[CoordinateOPEContributionRatioM2PublicationPlotFromData]]
  ]
];

Options[CoordinateOPEContributionRatioM2PublicationPlotFromData] =
  Options[CoordinateOPEContributionRatioM2PublicationPlot];

CoordinateOPEContributionRatioM2PublicationPlotFromData[
  data_Association,
  m2Range : {_?NumericQ, _?NumericQ} : $BcCoordinateWangWindow["M2Range"],
  continuumVal_?NumericQ,
  opts : OptionsPattern[]
] := Module[
  {useAbs = TrueQ[OptionValue["UseAbs"]], curves, labels, styles, yLabel},
  curves = Flatten[
    KeyValueMap[
      Function[{channel, points},
        {
          ({#[[1]], If[useAbs, Abs[#[[2]]], #[[2]]]} & /@ points),
          ({#[[1]], If[useAbs, Abs[#[[3]]], #[[3]]]} & /@ points)
        }
      ],
      data
    ],
    1
  ];
  labels = Flatten[({# <> " G2", # <> " G3"} & /@ Keys[data])];
  styles = {
    Directive[RGBColor[0.22, 0.39, 0.62], AbsoluteThickness[2.2]],
    Directive[RGBColor[0.22, 0.39, 0.62], Dashed, AbsoluteThickness[2.2]],
    Directive[RGBColor[0.9, 0.55, 0.12], AbsoluteThickness[2.2]],
    Directive[RGBColor[0.9, 0.55, 0.12], Dashed, AbsoluteThickness[2.2]],
    Directive[RGBColor[0.49, 0.65, 0.18], AbsoluteThickness[2.2]],
    Directive[RGBColor[0.49, 0.65, 0.18], Dashed, AbsoluteThickness[2.2]]
  };
  yLabel = If[useAbs, "|contribution / perturbative|", "contribution / perturbative"];
  <|
    "Data" -> data,
    "Plot" -> ListLinePlot[
      curves,
      Frame -> True,
      Axes -> False,
      FrameLabel -> {
        Row[{Superscript["M", 2], " (", Superscript["GeV", 2], ")"}],
        yLabel
      },
      LabelStyle -> OptionValue[LabelStyle],
      BaseStyle -> OptionValue[BaseStyle],
      ImageSize -> OptionValue[ImageSize],
      ImagePadding -> {{85, 20}, {60, 20}},
      PlotStyle -> styles,
      PlotRange -> OptionValue[PlotRange],
      GridLines -> Automatic,
      GridLinesStyle -> Directive[GrayLevel[0.85], Dashed],
      PlotLabel -> Row[{
        "Coordinate OPE hierarchy, ", Subscript["s", 0], " = ",
        CoordinateLegendNumber[continuumVal], " ", Superscript["GeV", 2]
      }],
      PlotLegends -> Placed[LineLegend[styles, labels, LegendMarkerSize -> 18], Right]
    ]
  |>
];

CoordinateOPEMonteCarloEvaluationOrder[order_String, includeG3_: True] := Module[
  {ord = CoordinateOPEValidateOrder[order]},
  If[ord === "totalFull" && ! TrueQ[includeG3], "pertG2full", ord]
];

CoordinateOPEMonteCarloMixingAngleValues[result_Association] /; KeyExistsQ[result, "Samples"] :=
  CoordinateOPEMonteCarloMixingAngleValues[result["Samples"]];
CoordinateOPEMonteCarloMixingAngleValues[samples_List] :=
  CoordinateRealNumber /@ Select[Lookup[samples, "ThetaDeg", {}], CoordinateRealNumberQ];

CoordinateOPEMonteCarloMixingAngleGaussianSummary[result_Association] /; KeyExistsQ[result, "Samples"] :=
  CoordinateOPEMonteCarloMixingAngleGaussianSummary[result["Samples"]];
CoordinateOPEMonteCarloMixingAngleGaussianSummary[samples_List] := Module[
  {values = CoordinateOPEMonteCarloMixingAngleValues[samples], count, mu,
   sigma, sampleSigma, q16, q50, q84},
  count = Length[values];
  If[count == 0,
    Return[<|"Count" -> 0, "MeanDeg" -> Missing["NoSamples"], "GaussianSigmaDeg" -> Missing["NoSamples"]|>]
  ];
  mu = Mean[values];
  sigma = Sqrt[Mean[(values - mu)^2]];
  sampleSigma = If[count > 1, StandardDeviation[values], 0.0];
  {q16, q50, q84} = Quantile[values, {0.16, 0.50, 0.84}];
  <|
    "Count" -> count,
    "MeanDeg" -> N[mu],
    "GaussianSigmaDeg" -> N[sigma],
    "SampleSigmaDeg" -> N[sampleSigma],
    "MedianDeg" -> N[q50],
    "Quantile16Deg" -> N[q16],
    "Quantile84Deg" -> N[q84],
    "MinDeg" -> N[Min[values]],
    "MaxDeg" -> N[Max[values]],
    "GaussianFit" -> NormalDistribution[N[mu], N[sigma]]
  |>
];

Options[CoordinateOPEMonteCarloMixingAngleSamples] = Join[
  Options[NIntegrate],
  {
    "Seed" -> Automatic,
    "MaxAttempts" -> 1000,
    "Progress" -> False,
    "IncludeG3" -> True
  }
];

CoordinateOPEMonteCarloMixingAngleSamples[
  n_Integer?Positive,
  ranges_: <||>,
  order_String : "totalFull",
  opts : OptionsPattern[]
] := Module[
  {merged = CoordinateNormalizeUncertaintyRanges[ranges], seed = OptionValue["Seed"],
   maxAttempts = OptionValue["MaxAttempts"], progress = OptionValue["Progress"],
   includeG3 = OptionValue["IncludeG3"],
   evalOrder = CoordinateOPEMonteCarloEvaluationOrder[order, OptionValue["IncludeG3"]],
   numericOpts, printEvery, point, theta},
  If[merged === $Failed, Return[$Failed]];
  If[seed =!= Automatic, SeedRandom[seed]];
  numericOpts = FilterRules[{opts}, Options[NIntegrate]];
  printEvery = Max[1, Floor[n/10]];
  DeleteCases[
    Table[
      If[TrueQ[progress] && Mod[i, printEvery] == 0,
        Print["Coordinate OPE Monte Carlo sample ", i, "/", n]
      ];
      point = CoordinateRandomAcceptedParameterPoint[merged, maxAttempts];
      If[point === $Failed, Return[$Failed]];
      theta = Quiet[
        CoordinateOPEMixingAngle[
          point["M2"], point["s0"], evalOrder, point, Sequence @@ numericOpts
        ]
      ];
      If[CoordinateRealNumberQ[theta],
        Join[
          <|
            "Index" -> i,
            "RequestedOrder" -> order,
            "Order" -> evalOrder,
            "IncludeG3" -> TrueQ[includeG3]
          |>,
          Association @ KeyValueMap[#1 -> N[#2] &, KeyTake[point, {"mb", "mc", "G2", "G3", "M2", "s0"}]],
          <|
            "Threshold" -> N[(point["mb"] + point["mc"])^2],
            "ThetaDeg" -> CoordinateRealNumber[theta]
          |>
        ],
        $Failed
      ],
      {i, n}
    ],
    $Failed
  ]
];

Options[CoordinateOPEMonteCarloMixingAngleUncertainty] =
  Options[CoordinateOPEMonteCarloMixingAngleSamples];

CoordinateOPEMonteCarloMixingAngleUncertainty[
  n_Integer?Positive,
  ranges_: <||>,
  order_String : "totalFull",
  opts : OptionsPattern[]
] := Module[
  {evalOrder = CoordinateOPEMonteCarloEvaluationOrder[order, OptionValue["IncludeG3"]],
   samples},
  samples = CoordinateOPEMonteCarloMixingAngleSamples[n, ranges, order, opts];
  If[samples === $Failed, Return[$Failed]];
  <|
    "RequestedOrder" -> order,
    "Order" -> evalOrder,
    "IncludeG3" -> TrueQ[OptionValue["IncludeG3"]],
    "CoordinateOPEMonteCarloEngine" -> "Independent coordinate/Azizi OPE engine",
    "CoordinateIndependence" -> "Uses CoordinateOPEMixingAngle and does not call the momentum-space Monte Carlo engine.",
    "RequestedSamples" -> n,
    "AcceptedSamples" -> Length[samples],
    "FailedSamples" -> n - Length[samples],
    "Ranges" -> CoordinateNormalizeUncertaintyRanges[ranges],
    "Samples" -> samples,
    "Summary" -> CoordinateOPEMonteCarloMixingAngleGaussianSummary[samples],
    "Diagnostic" -> If[
      Length[samples] == 0,
      "No accepted numeric theta values. First test CoordinateOPEMixingAngle[8, 54, \"pertG2full\"] or \"totalFull\".",
      "OK"
    ]
  |>
];

CoordinateOPEMonteCarloMixingAngleDataset[result_Association] /; KeyExistsQ[result, "Samples"] :=
  Dataset[result["Samples"]];

CoordinateOPEMonteCarloSampleTable[result_Association] /; KeyExistsQ[result, "Samples"] := Module[
  {samples = result["Samples"], keys},
  If[samples === {}, Return[{}]];
  keys = Union[Flatten[Keys /@ samples]];
  Prepend[Lookup[#, keys, ""] & /@ samples, keys]
];

CoordinateOPEExportMonteCarloMixingAngleSamples[
  result_Association,
  file_String : "BcMixingCoordinateAziziMonteCarloSamples.csv"
] :=
  CoordinateWriteCSV[file, CoordinateOPEMonteCarloSampleTable[result]];

CoordinateOPEExportMonteCarloMixingAngleSummary[
  result_Association,
  file_String : "BcMixingCoordinateAziziMonteCarloSummary.csv"
] := Module[
  {summary = result["Summary"]},
  CoordinateWriteCSV[
    file,
    Prepend[KeyValueMap[{#1, ToString[#2, InputForm]} &, summary], {"Quantity", "Value"}]
  ]
];

Options[CoordinateOPEMonteCarloMixingAnglePublicationHistogram] =
  Options[CoordinateMonteCarloMixingAnglePublicationHistogram];

CoordinateOPEMonteCarloMixingAnglePublicationHistogram[
  result_,
  bins_: Automatic,
  opts : OptionsPattern[]
] :=
  CoordinateMonteCarloMixingAnglePublicationHistogram[result, bins, opts];

CoordinateOPEJournalChecklist[] := {
  "Quote S_Q^(0), S_Q^(G2), S_Q^(G3), and the open-field S_Q^(G) convention.",
  "Show one channel kernel before radial reduction, preferably AA.",
  "Show the BesselK Schwinger representation used for K_nu/r^nu.",
  "Show how delta derivatives in s - sbar[x] appear after the Borel transform.",
  "State the x_-(s0) to x_+(s0) continuum subtraction domain.",
  "List the implemented G2c, G2b and G2gg pole weights or provide a representative table.",
  "State that G3full is the single-line G3c + G3b truncation unless open-field dimension-6 terms are derived.",
  "Quote pert, pertG2full and totalFull coordinate-space angles only after the shared sign/normalization audit is accepted."
};

Print["Loaded BcMixingCoordinateOPE.wl. Run CoordinateOPEStatus[] for the independent condensate roadmap."];

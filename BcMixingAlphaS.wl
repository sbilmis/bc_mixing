(* ::Package:: *)

(*  BcMixingAlphaS.wl

    Workbench for the perturbative O(alpha_s) correction to the B_c
    axial-vector mixing sum rule.

    This file deliberately does not modify BcMixingMomentum.wl.  The stable
    LO + condensate workflow remains there.  Here we prepare the NLO
    perturbative layer:

      rho_pert^ij(s) = rho_0^ij(s) + alpha_s/Pi rho_1^ij(s),

    where ij = AA, AB, BB.  The LO functions rho_0^ij are imported from
    BcMixingMomentum.wl.  The true rho_1^ij functions must be derived from
    the virtual plus real gluon contributions.

    Practical roadmap:

      1. Derive the unequal-mass AA correction independently with the
         Cutkosky/optical-theorem method.
      2. Verify the real soft theorem and the UV/IR pole cancellations.
      3. Combine the finite virtual and real remainders.
      4. Only then compare AA with published results as an external check.
      5. Apply the validated method to the tensor-current channels AB and BB.
      6. Install the resulting rho_1^ij(s) with
            SetAlphaSNLOSpectralDensity["AA", expr, s]
         and then evaluate NumericMixingAngleAlphaSDegrees.

    Why this file is only a workbench:
      A true O(alpha_s) correction is a two-loop spectral-density
      calculation.  A channel-dependent K-factor is not enough for the paper.
      The K-factor tools in BcMixingMomentum.wl are useful only as sensitivity
      checks.
*)

ClearAll["Global`*"];

(* ---------------------------------------------------------------------- *)
(* Load the existing LO momentum-space calculation                         *)
(* ---------------------------------------------------------------------- *)

(* Loading BcMixingMomentum.wl gives us the LO spectral densities,
   parameters, Borel integrals, and the current normalization convention. *)

$BcAlphaSDirectory = If[
  StringQ[$InputFileName] && StringLength[$InputFileName] > 0,
  DirectoryName[$InputFileName],
  Directory[]
];

(* FeynArts is bundled with the local FeynCalc installation.  FeynHelpers is
   optional but useful for Package-X/FIRE interfaces.  These switches must be
   set before FeynCalc is loaded, hence they live here rather than later in
   the file. *)
$LoadFeynArts = True;
$BcAlphaSFeynHelpersDirectory =
  FileNameJoin[{$UserBaseDirectory, "Applications", "FeynCalc", "AddOns", "FeynHelpers"}];
If[DirectoryQ[$BcAlphaSFeynHelpersDirectory],
  $LoadAddOns = DeleteDuplicates@Join[
    If[ListQ[Quiet[$LoadAddOns]], $LoadAddOns, {}],
    {"FeynHelpers"}
  ]
];

(* Load FeynCalc with the requested add-ons before importing
   BcMixingMomentum.wl.  This avoids losing the switches when that file clears
   Global` at startup. *)
If[! TrueQ[ValueQ[$FeynCalcVersion]],
  Needs["FeynCalc`"]
];

If[! FileExistsQ[FileNameJoin[{$BcAlphaSDirectory, "BcMixingMomentum.wl"}]],
  Print["Could not load BcMixingMomentum.wl from ", $BcAlphaSDirectory];
  Abort[]
];

Get[FileNameJoin[{$BcAlphaSDirectory, "BcMixingMomentum.wl"}]];

$BcAlphaSFeynHelpersDirectory =
  FileNameJoin[{$UserBaseDirectory, "Applications", "FeynCalc", "AddOns", "FeynHelpers"}];

(* BcMixingMomentum.wl clears Global` while loading, so AlphaS-specific
   messages must be defined after the Get above. *)
BcMixingAlphaS::badchannel =
  "Unknown channel `1`. Valid NLO channels are \"AA\", \"AB\", \"BA\" and \"BB\".";
BcMixingAlphaS::nonlo =
  "No O(alpha_s) spectral density rho_1 is installed for channel `1`.";
BcMixingAlphaS::notimplemented =
  "`1` is a derivation placeholder. Use AlphaSNLOStatus[] to see the remaining steps.";

(* ---------------------------------------------------------------------- *)
(* NLO bookkeeping                                                         *)
(* ---------------------------------------------------------------------- *)

$BcAlphaSChannels = {"AA", "AB", "BA", "BB"};
$BcAlphaSNLOSpectralDensities = <||>;

$BcAlphaSReferences = <|
  "UnequalMassNLOVectorAxialScalarPseudoscalar" ->
    "Z.-G. Wang, Next-to-leading order perturbative contributions in the QCD sum rules for mesonic two-point correlation functions with unequal quark masses, arXiv:1303.4146",
  "ClassicReview" ->
    "L. J. Reinders, H. Rubinstein and S. Yazaki, Phys. Rept. 127 (1985) 1",
  "TensorChannels" ->
    "AB and BB are tensor-current channels in our basis and must be derived separately."
|>;

$BcAlphaSIndependentReferences = <|
  "Status" ->
    "Independent AA workbench.  The Wang formula below is kept only for a later cross-check and is not used by these functions.",
  "Method" ->
    "Optical-theorem/Cutkosky calculation: reproduce the two-body AA cut at LO, then add virtual one-gluon corrections and real q qbar g emission with the same spin-1 projector.",
  "MassiveDipoleSubtraction" ->
    "S. Catani, S. Dittmaier, M. H. Seymour and Z. Trocsanyi, Nucl. Phys. B627 (2002) 189, arXiv:hep-ph/0201036. Use the unequal-mass final-state dipoles and integrated eikonal functions for the finite real-virtual assembly.",
  "HeavyLightLimit" ->
    "K. G. Chetyrkin and M. Steinhauser, arXiv:hep-ph/0108017. Use after matching the heavy-light current and spectral-density conventions.",
  "BcNRQCDCurrentMatching" ->
    "J. Lee, W. Sang and S. Kim, arXiv:1011.2274. Useful for unequal-mass NRQCD current matching, but not a direct transverse P-wave spectral-density check.",
  "HighEnergyExpansions" ->
    "A. Maier and P. Marquard, arXiv:1110.5581. Useful for expansion structure; the published non-diagonal and axial channels are not exactly the present unequal-mass axial observable."
|>;

ValidateAlphaSChannel[channel_String] := If[
  MemberQ[$BcAlphaSChannels, channel],
  channel,
  Message[BcMixingAlphaS::badchannel, channel];
  Abort[]
];

(* Store a derived rho_1^ij(s).  The expression should NOT include alpha_s/Pi;
   the numerical functions multiply by alpha_s/Pi automatically. *)
SetAlphaSNLOSpectralDensity[channel_String, expr_, var_: s] := Module[
  {ch = ValidateAlphaSChannel[channel], body = expr, vv = var},
  $BcAlphaSNLOSpectralDensities[ch] = With[
    {storedBody = body, storedVar = vv},
    (storedBody /. storedVar -> #) &
  ];
  ch
];

ClearAlphaSNLOSpectralDensities[] := ($BcAlphaSNLOSpectralDensities = <||>;);

AlphaSNLOSpectralDensityDefinedQ[channel_String] :=
  KeyExistsQ[$BcAlphaSNLOSpectralDensities, ValidateAlphaSChannel[channel]];

AlphaSNLOSpectralDensity[channel_String, var_: s] := Module[
  {ch = ValidateAlphaSChannel[channel]},
  If[
    AlphaSNLOSpectralDensityDefinedQ[ch],
    $BcAlphaSNLOSpectralDensities[ch][var],
    rho1[ch][var]
  ]
];

AlphaSLOSpectralDensity[channel_String, var_: s] :=
  SpectralDensity[ValidateAlphaSChannel[channel], "pert", var];

AlphaSTotalPerturbativeSpectralDensity[channel_String, var_: s, params_: $BcMixingDefaultParameters] :=
  AlphaSLOSpectralDensity[channel, var] +
    alphaS/Pi AlphaSNLOSpectralDensity[channel, var] /. DynamicParameterRules[params];

(* ---------------------------------------------------------------------- *)
(* Numerical Borel moments with installed rho_1 functions                  *)
(* ---------------------------------------------------------------------- *)

Options[NumericAlphaSNLOBorelPi] = Options[NIntegrate];

(* Bare NLO moment, i.e. integral of rho_1 only. *)
NumericAlphaSNLOBorelPi[
  channel_String,
  m2Val_?NumericQ,
  continuumVal_?NumericQ,
  params_: $BcMixingDefaultParameters,
  opts : OptionsPattern[]
] := Module[
  {ch = ValidateAlphaSChannel[channel], var, rules, lower, density},
  If[! AlphaSNLOSpectralDensityDefinedQ[ch],
    Message[BcMixingAlphaS::nonlo, ch];
    Return[$Failed]
  ];
  rules = Join[ParameterRules[params], {M2 -> m2Val, s0 -> continuumVal}];
  lower = N[BcThreshold[] /. rules];
  density = Evaluate[AlphaSNLOSpectralDensity[ch, var] /. rules];
  If[TrueQ[density == 0], Return[0.]];
  NIntegrate[
    Evaluate[Exp[-var/m2Val] density],
    {var, lower, continuumVal},
    opts
  ]
];

(* Full perturbative moment rho_0 + alpha_s/Pi rho_1. *)
NumericAlphaSCorrectedPerturbativeBorelPi[
  channel_String,
  m2Val_?NumericQ,
  continuumVal_?NumericQ,
  params_: $BcMixingDefaultParameters,
  opts : OptionsPattern[NumericAlphaSNLOBorelPi]
] := Module[
  {alpha = MergeDefaultParameters[params]["alphaS"], lo, nlo},
  lo = NumericBorelPi[channel, "pert", m2Val, continuumVal, params, opts];
  nlo = NumericAlphaSNLOBorelPi[channel, m2Val, continuumVal, params, opts];
  If[MemberQ[{lo, nlo}, $Failed], Return[$Failed]];
  lo + alpha/Pi nlo
];

(* Build the mixing angle from perturbative moments only, but with NLO
   corrections included in AA, AB, and BB. *)
NumericMixingAngleAlphaS[
  m2Val_?NumericQ,
  continuumVal_?NumericQ,
  params_: $BcMixingDefaultParameters,
  opts : OptionsPattern[NumericAlphaSNLOBorelPi]
] := Module[
  {aa, ab, bb},
  aa = NumericAlphaSCorrectedPerturbativeBorelPi["AA", m2Val, continuumVal, params, opts];
  ab = NumericAlphaSCorrectedPerturbativeBorelPi["AB", m2Val, continuumVal, params, opts];
  bb = NumericAlphaSCorrectedPerturbativeBorelPi["BB", m2Val, continuumVal, params, opts];
  If[MemberQ[{aa, ab, bb}, $Failed], Return[$Failed]];
  NormalizeMixingAngle[1/2 ArcTan[aa - bb, -2 ab]]
];

NumericMixingAngleAlphaSDegrees[args___] := Module[
  {theta = NumericMixingAngleAlphaS[args]},
  If[theta === $Failed, $Failed, N[180/Pi theta]]
];

AlphaSNLOMomentSummary[
  m2Val_?NumericQ,
  continuumVal_?NumericQ,
  params_: $BcMixingDefaultParameters,
  opts : OptionsPattern[NumericAlphaSNLOBorelPi]
] := AssociationMap[
  Module[
    {lo, nlo, alpha, total},
    lo = NumericBorelPi[#, "pert", m2Val, continuumVal, params, opts];
    nlo = If[
      AlphaSNLOSpectralDensityDefinedQ[#],
      NumericAlphaSNLOBorelPi[#, m2Val, continuumVal, params, opts],
      Missing["rho1 not installed"]
    ];
    alpha = MergeDefaultParameters[params]["alphaS"];
    total = If[NumericQ[nlo], lo + alpha/Pi nlo, Missing["rho1 not installed"]];
    <|
      "LO" -> lo,
      "NLOBareRho1Moment" -> nlo,
      "AlphaSOverPiNLO" -> If[NumericQ[nlo], alpha/Pi nlo, Missing["rho1 not installed"]],
      "PerturbativeNLOTotal" -> total,
      "RelativeAlphaSShift" -> If[NumericQ[nlo] && lo =!= 0, alpha/Pi nlo/lo, Missing["rho1 not installed"]]
    |>
  ] &,
  {"AA", "AB", "BB"}
];

(* ---------------------------------------------------------------------- *)
(* Independent AA derivation workbench                                     *)
(* ---------------------------------------------------------------------- *)

(* This section intentionally does not call WangAxialNLOBareSpectralDensity.
   It starts from the Feynman rules and the spin sums.  The first milestone is
   to reproduce the AA LO spectral density in our projector normalization.
   After that we keep explicit virtual and real-emission building blocks for
   the O(alpha_s) calculation. *)

ClearAll[
  pcAA, pbAA, kgAA, pAA, muAA, nuAA, alphaAA, betaAA, ssAA,
  uAA, vAA, xAA, yAA, deltaAA, epsUV, epsIR, muR, etaIR,
  IndependentAASpin1Projector, IndependentAASpin1ProjectorD,
  IndependentAASPRule, IndependentAA2BodyOnShellRules,
  IndependentAADimensionalOnShellRules, IndependentAA3BodyOnShellRules,
  IndependentAACutToInvariantFactor,
  IndependentAAColorFactor, IndependentAAThreeBodyTBounds,
  IndependentAAThreeBodyUBounds, IndependentAAThreeBodyPhaseSpaceFactor,
  IndependentAARealEmissionSoftYBounds, IndependentAARealEmissionSoftKernel,
  IndependentAARealEmissionSoftLogCoefficient,
  IndependentAARealEmissionSoftSubtractedRho1Cutoff,
  IndependentAARealEmissionSoftFitCheck, IndependentAARealEmissionSoftTheoremCheck,
  IndependentAALORawTrace, IndependentAALOProjectedTrace,
  IndependentAALOSpectralDensity, IndependentAALODerivationCheck,
  IndependentAALOGamma5FreeRawTrace, IndependentAALOGamma5EliminationCheck,
  IndependentAALOGamma5FreeProjectedTraceD,
  IndependentAALODimensionalNormalizationSeries,
  IndependentAARealEmissionChain, IndependentAARealEmissionConjugateChain,
  IndependentAARealEmissionProjectedTrace, IndependentAARealEmissionTraceFormula,
  IndependentAARealEmissionTraceCheck, IndependentAARealEmissionRho1Cutoff,
  IndependentAAVirtualVertexIntegrand, IndependentAAVirtualProjectedIntegrand,
  IndependentAAVirtualVertexIntegrandGamma5Free,
  IndependentAAVirtualProjectedIntegrandGamma5Free,
  IndependentAAVirtualVertexIntegrandPhysicalRouting,
  IndependentAAVirtualProjectedIntegrandPhysicalRouting,
  IndependentAAVirtualScalarReduction, IndependentAAVirtualReductionDiagnostic,
  IndependentAAVirtualScalarReductionGamma5Free,
  IndependentAAVirtualReductionDiagnosticGamma5Free,
  IndependentAAVirtualScalarReductionPhysicalRouting,
  IndependentAAVirtualReductionDiagnosticPhysicalRouting,
  IndependentAAEqualMassVirtualPaXBenchmark,
  IndependentAAEqualMassCataniF1FiniteRatio,
  IndependentAAEqualMassCataniAxialFiniteRatio,
  IndependentAAEqualMassVirtualBenchmarkReport,
  IndependentAAVirtualPaXReduce, IndependentAAVirtualPaXUVIRSplit,
  IndependentAAPaXConventionRules, IndependentAAPaXToCountertermConventions,
  IndependentAAVirtualPaXUVIRSplitMapped, IndependentAAPoleCoefficients,
  IndependentAAVirtualPoleCoefficients, IndependentAARealEmissionCutoffScan,
  IndependentAAVirtualRawPoleToRho1, IndependentAAVirtualUVPoleRho1,
  IndependentAAVirtualSoftNumerator, IndependentAAC0IRPoleCoefficient,
  IndependentAAVirtualIRPoleRho1, IndependentAARealIRPoleRho1,
  IndependentAAUVPoleCancellationCheck, IndependentAAIRPoleCancellationCheck,
  IndependentAAVirtualFiniteRho1, IndependentAAFieldCountertermFiniteRho1,
  IndependentAARenormalizedVirtualFiniteRho1,
  IndependentAARenormalizedVirtualFiniteNumeric,
  IndependentAADipoleVelocity, IndependentAADipoleBracket,
  IndependentAADipoleProjectedTrace, IndependentAADipoleSumProjectedTrace,
  IndependentAADipoleSoftCancellationCheck,
  IndependentAARealMinusDipolesRho1,
  IndependentAAIntegratedEikonalFinite,
  IndependentAAIntegratedCollinearFinite,
  IndependentAAIntegratedDipoleFinite,
  IndependentAAIntegratedDipolePole,
  IndependentAAIntegratedDipolesFiniteRho1,
  IndependentAAIntegratedDipolesPoleRho1,
  IndependentAAInsertionKinematics,
  IndependentAAInsertionVSFinite,
  IndependentAAInsertionVqNS,
  IndependentAAInsertionQuarkFinite,
  IndependentAACompleteInsertionFiniteRho1,
  IndependentAAIntegratedDipolesFiniteRho1AtScale,
  IndependentAARenormalizedVirtualFiniteRho1EpsilonBar,
  IndependentAACachedVirtualFiniteExpression,
  IndependentAAFinalRho1Numeric,
  IndependentAARelativeVelocity,
  IndependentAAThresholdCoulombCheck,
  IndependentAAHighEnergyLimitCheck,
  IndependentAAHeavyLightLimitCheck,
  IndependentAAMassExchangeSymmetryCheck,
  IndependentAADimensionalScalingCheck,
  IndependentAAGaussLegendreRule,
  IndependentAAFinalNLOBorelMoment,
  IndependentAAFinalNLOBorelSummary,
  IndependentAAAlphaSOneLoop,
  IndependentAARunMassOneLoop,
  IndependentAAMSbarRunningParameters,
  IndependentAAMSbarConversionRho1,
  IndependentAAFinalRho1MSbarNumeric,
  IndependentAAFinalNLOBorelMSbarMoment,
  IndependentAAFinalNLOBorelMSbarSummary,
  IndependentAAOffShellRegulatorRules, IndependentAAVirtualOffShellNumeric,
  IndependentAANLOAssemblyReport,
  IndependentAAQuarkFieldDeltaZ2OS, IndependentAAQuarkMassDeltaZOS,
  IndependentAAMassCountertermRho1, IndependentAAFieldCountertermRho1,
  IndependentAAAmplitudeCountertermRho1, IndependentAACountertermRho1,
  IndependentAARenormalizationSummary,
  IndependentAAStatus
];

IndependentAASpin1Projector[ptot_, lor1_, lor2_] :=
  1/3 (MT[lor1, lor2] - FV[ptot, lor1] FV[ptot, lor2]/SP[ptot, ptot]);

(* The virtual graph must be reduced in D=4-2 epsilon dimensions from the
   beginning.  Applying ChangeDimension only after a four-dimensional trace
   loses O(epsilon) terms that multiply loop poles and alter the finite part. *)
IndependentAASpin1ProjectorD[ptot_, lor1_, lor2_] :=
  1/(D - 1) (
    FeynCalc`MTD[lor1, lor2] -
    FeynCalc`FVD[ptot, lor1] FeynCalc`FVD[ptot, lor2]/
      FeynCalc`SPD[ptot, ptot]
  );

(* The two-body Cutkosky trace below is a physical spin-summed cut.  The
   scalar invariant used in BcMixingMomentum.wl is obtained from the closed
   fermion-loop correlator with the transverse coefficient convention.
   In four dimensions this gives an overall -3 bridge between the cut trace
   with the averaged projector and the stored rho_AA numerator. *)
IndependentAACutToInvariantFactor[] := -3;

IndependentAAColorFactor[] := ($BcMixingNc^2 - 1)/(2 $BcMixingNc);

IndependentAASPRule[a_, b_, val_] := {
  SP[a, b] -> val,
  Pair[Momentum[a], Momentum[b]] -> val,
  Pair[Momentum[a, D], Momentum[b, D]] -> val
};

IndependentAA2BodyOnShellRules[ss_: s] := Flatten[{
  IndependentAASPRule[pcAA, pcAA, mc^2],
  IndependentAASPRule[pbAA, pbAA, mb^2],
  IndependentAASPRule[pAA, pAA, ss],
  IndependentAASPRule[pcAA, pbAA, (ss - mc^2 - mb^2)/2],
  IndependentAASPRule[pbAA, pcAA, (ss - mc^2 - mb^2)/2],
  IndependentAASPRule[pcAA, pAA, (ss + mc^2 - mb^2)/2],
  IndependentAASPRule[pAA, pcAA, (ss + mc^2 - mb^2)/2],
  IndependentAASPRule[pbAA, pAA, (ss + mb^2 - mc^2)/2],
  IndependentAASPRule[pAA, pbAA, (ss + mb^2 - mc^2)/2]
}];

(* Fully qualified D-dimensional rules used after TID.  Keeping this separate
   from the convenient SP rules above prevents context-shadowing from leaving
   external invariants unevaluated in the Package-X input. *)
IndependentAADimensionalOnShellRules[ss_: s] := {
  FeynCalc`Pair[
    FeynCalc`Momentum[pcAA, D], FeynCalc`Momentum[pcAA, D]
  ] -> mc^2,
  FeynCalc`Pair[
    FeynCalc`Momentum[pbAA, D], FeynCalc`Momentum[pbAA, D]
  ] -> mb^2,
  FeynCalc`Pair[
    FeynCalc`Momentum[pAA, D], FeynCalc`Momentum[pAA, D]
  ] -> ss,
  FeynCalc`Pair[
    FeynCalc`Momentum[pcAA, D], FeynCalc`Momentum[pbAA, D]
  ] -> (ss - mc^2 - mb^2)/2,
  FeynCalc`Pair[
    FeynCalc`Momentum[pbAA, D], FeynCalc`Momentum[pcAA, D]
  ] -> (ss - mc^2 - mb^2)/2,
  FeynCalc`Pair[
    FeynCalc`Momentum[pcAA, D], FeynCalc`Momentum[pAA, D]
  ] -> (ss + mc^2 - mb^2)/2,
  FeynCalc`Pair[
    FeynCalc`Momentum[pAA, D], FeynCalc`Momentum[pcAA, D]
  ] -> (ss + mc^2 - mb^2)/2,
  FeynCalc`Pair[
    FeynCalc`Momentum[pbAA, D], FeynCalc`Momentum[pAA, D]
  ] -> (ss + mb^2 - mc^2)/2,
  FeynCalc`Pair[
    FeynCalc`Momentum[pAA, D], FeynCalc`Momentum[pbAA, D]
  ] -> (ss + mb^2 - mc^2)/2,
  Global`Pair[
    Global`Momentum[pcAA, D], Global`Momentum[pcAA, D]
  ] -> mc^2,
  Global`Pair[
    Global`Momentum[pbAA, D], Global`Momentum[pbAA, D]
  ] -> mb^2,
  Global`Pair[
    Global`Momentum[pAA, D], Global`Momentum[pAA, D]
  ] -> ss,
  Global`Pair[
    Global`Momentum[pcAA, D], Global`Momentum[pbAA, D]
  ] -> (ss - mc^2 - mb^2)/2,
  Global`Pair[
    Global`Momentum[pbAA, D], Global`Momentum[pcAA, D]
  ] -> (ss - mc^2 - mb^2)/2,
  Global`Pair[
    Global`Momentum[pcAA, D], Global`Momentum[pAA, D]
  ] -> (ss + mc^2 - mb^2)/2,
  Global`Pair[
    Global`Momentum[pAA, D], Global`Momentum[pcAA, D]
  ] -> (ss + mc^2 - mb^2)/2,
  Global`Pair[
    Global`Momentum[pbAA, D], Global`Momentum[pAA, D]
  ] -> (ss + mb^2 - mc^2)/2,
  Global`Pair[
    Global`Momentum[pAA, D], Global`Momentum[pbAA, D]
  ] -> (ss + mb^2 - mc^2)/2
};

IndependentAA3BodyOnShellRules[ss_: s, u_: uAA, v_: vAA] := Flatten[{
  IndependentAASPRule[pcAA, pcAA, mc^2],
  IndependentAASPRule[pbAA, pbAA, mb^2],
  IndependentAASPRule[kgAA, kgAA, 0],
  IndependentAASPRule[pAA, pAA, ss],
  IndependentAASPRule[pcAA, kgAA, u/2],
  IndependentAASPRule[kgAA, pcAA, u/2],
  IndependentAASPRule[pbAA, kgAA, v/2],
  IndependentAASPRule[kgAA, pbAA, v/2],
  IndependentAASPRule[pcAA, pbAA, (ss - mc^2 - mb^2 - u - v)/2],
  IndependentAASPRule[pbAA, pcAA, (ss - mc^2 - mb^2 - u - v)/2],
  IndependentAASPRule[pcAA, pAA, (ss + mc^2 - mb^2 - v)/2],
  IndependentAASPRule[pAA, pcAA, (ss + mc^2 - mb^2 - v)/2],
  IndependentAASPRule[pbAA, pAA, (ss + mb^2 - mc^2 - u)/2],
  IndependentAASPRule[pAA, pbAA, (ss + mb^2 - mc^2 - u)/2],
  IndependentAASPRule[kgAA, pAA, (u + v)/2],
  IndependentAASPRule[pAA, kgAA, (u + v)/2]
}];

IndependentAAThreeBodyTBounds[ss_] := {(mb + mc)^2, ss};

(* Three-body phase space is parameterized by
      t = (p_c+p_b)^2,  u = 2 p_c.k_g,  v = 2 p_b.k_g = s-t-u.
   For fixed t the physical u range follows from the two nested two-body
   decays q -> P(t)+g and P(t) -> c+\bar b. *)
IndependentAAThreeBodyUBounds[ss_, tt_] := Module[
  {root = Sqrt[KallenLambda[tt, mb, mc]], pref},
  pref = (ss - tt)/(2 tt);
  {
    pref (tt + mc^2 - mb^2 - root),
    pref (tt + mc^2 - mb^2 + root)
  }
];

(* Dalitz measure after integrating the overall orientation:
      d Phi_3 = dt du/(128 Pi^3 s).
   The spectral density rho=(1/Pi) Im Pi contains the additional
   optical-theorem factor 1/(2 Pi), applied below. *)
IndependentAAThreeBodyPhaseSpaceFactor[ss_] := 1/(128 Pi^3 ss);

IndependentAARealEmissionSoftYBounds[ss_] := Module[
  {root = Sqrt[KallenLambda[ss, mb, mc]]},
  {
    (ss + mc^2 - mb^2 - root)/(2 ss),
    (ss + mc^2 - mb^2 + root)/(2 ss)
  }
];

(* Two-body cut for J_mu^A = \bar b gamma_mu gamma_5 c.  The anti-bottom
   spin sum is (\slash p_b - m_b), as appropriate for the cut heavy antiquark
   in the current-current correlator. *)
IndependentAALORawTrace[] :=
  DiracTrace[
    (GS[pcAA] + mc) . GA[muAA] . GA[5] .
    (GS[pbAA] - mb) . GA[nuAA] . GA[5]
  ] // DiracSimplify // Contract // FCE // Simplify;

IndependentAALOProjectedTrace[ss_: s] := Module[
  {expr},
  expr = IndependentAASpin1Projector[pAA, muAA, nuAA] IndependentAALORawTrace[];
  expr = Contract[expr] // FCE // DiracSimplify // Contract;
  expr /. IndependentAA2BodyOnShellRules[ss] // Simplify
];

IndependentAALOSpectralDensity[ss_: s] := Module[
  {lam = KallenLambda[ss, mb, mc], trace},
  trace = IndependentAALOProjectedTrace[ss];
  $BcMixingNc/(16 Pi^2) Sqrt[lam]/ss
    IndependentAACutToInvariantFactor[] trace // Simplify
];

IndependentAALODerivationCheck[ss_: s] := Module[
  {ind = IndependentAALOSpectralDensity[ss], builtin = AlphaSLOSpectralDensity["AA", ss]},
  <|
    "RawTrace" -> IndependentAALORawTrace[],
    "ProjectedTrace" -> IndependentAALOProjectedTrace[ss],
    "IndependentRho0AA" -> ind,
    "MomentumFileRho0AA" -> builtin,
    "Difference" -> FullSimplify[ind - builtin, ss > (mb + mc)^2 && mb > 0 && mc > 0],
    "Ratio" -> FullSimplify[ind/builtin, ss > (mb + mc)^2 && mb > 0 && mc > 0]
  |>
];

(* For a nonsinglet current the two gamma_5 matrices in the cut trace may be
   anticommuted together before continuing the algebra to D dimensions.  This
   avoids mixing four-dimensional GA[5] with D-dimensional gamma matrices in
   the virtual graph.  The identity used here follows by cyclically moving the
   last gamma_5 to the front and conjugating the first fermion-current block:

     gamma_5 (pcslash+mc) gamma_mu gamma_5
       = (pcslash-mc) gamma_mu .

   The four-dimensional check below must vanish before the gamma_5-free
   virtual representation is used. *)
IndependentAALOGamma5FreeRawTrace[] :=
  DiracTrace[
    (GS[pcAA] - mc) . GA[muAA] .
    (GS[pbAA] - mb) . GA[nuAA]
  ] // DiracSimplify // Contract // FCE // Simplify;

IndependentAALOGamma5EliminationCheck[] := FullSimplify[
  IndependentAALOGamma5FreeRawTrace[] - IndependentAALORawTrace[]
];

IndependentAALOGamma5FreeProjectedTraceD[ss_: s] := Module[
  {expr},
  expr = IndependentAASpin1ProjectorD[pAA, muAA, nuAA] *
    FeynCalc`DiracTrace[
      (FeynCalc`GSD[pcAA] - mc) . FeynCalc`GAD[muAA] .
      (FeynCalc`GSD[pbAA] - mb) . FeynCalc`GAD[nuAA]
    ];
  expr = FeynCalc`DiracSimplify[expr] // FeynCalc`Contract // Simplify;
  expr /. IndependentAADimensionalOnShellRules[ss] //
    FeynCalc`Contract // FeynCalc`FCE // Simplify
];

IndependentAALODimensionalNormalizationSeries[ss_: s] := Module[
  {epsilon = Unique["epsilon"], ratio},
  ratio = IndependentAALOGamma5FreeProjectedTraceD[ss]/
    IndependentAALOProjectedTrace[ss];
  FullSimplify[
    Normal@Series[ratio /. D -> 4 - 2 epsilon, {epsilon, 0, 1}],
    ss > (mb + mc)^2 && mb > 0 && mc > 0
  ]
];

(* Real-emission tree amplitude for the cut current
      current -> c(pcAA) + \bar b(pbAA) + g(kgAA).
   u = 2 pc.kg and v = 2 pb.kg are kept as independent three-body variables.
   The relative sign between the quark and antiquark emission terms follows
   the usual outgoing-fermion/outgoing-antifermion QCD vertices.  This object
   is the algebraic numerator; the color factor C_F and the three-body
   phase-space integration are applied in the next step of the NLO derivation. *)
IndependentAARealEmissionChain[lor_, gluLor_, u_: uAA, v_: vAA] :=
  GA[gluLor] . (GS[pcAA] + GS[kgAA] + mc) . GA[lor] . GA[5]/u +
    GA[lor] . GA[5] . (-GS[pbAA] - GS[kgAA] + mb) . GA[gluLor]/v;

IndependentAARealEmissionConjugateChain[lor_, gluLor_, u_: uAA, v_: vAA] :=
  GA[lor] . GA[5] . (GS[pcAA] + GS[kgAA] + mc) . GA[gluLor]/u +
    GA[gluLor] . (-GS[pbAA] - GS[kgAA] + mb) . GA[lor] . GA[5]/v;

IndependentAARealEmissionProjectedTrace[ss_: s, u_: uAA, v_: vAA] := Module[
  {chain, chainBar, expr},
  chain = IndependentAARealEmissionChain[muAA, alphaAA, u, v];
  chainBar = IndependentAARealEmissionConjugateChain[nuAA, betaAA, u, v];
  expr =
    IndependentAASpin1Projector[pAA, muAA, nuAA] (-MT[alphaAA, betaAA])
      DiracTrace[
        (GS[pcAA] + mc) . chain .
        (GS[pbAA] - mb) . chainBar
      ];
  expr = expr // DiracSimplify // Contract // FCE // Simplify;
  IndependentAACutToInvariantFactor[] expr /. IndependentAA3BodyOnShellRules[ss, u, v] //
    Simplify[#, ss > (mb + mc)^2 && u > 0 && v > 0] &
];

IndependentAARealEmissionTraceFormula[] :=
  IndependentAARealEmissionTraceFormula[] =
    IndependentAARealEmissionProjectedTrace[s, uAA, vAA] // Simplify;

IndependentAARealEmissionTraceCheck[ssVal_?NumericQ, uVal_?NumericQ, vVal_?NumericQ,
  params_: $BcMixingDefaultParameters] := Module[
  {rules = DynamicParameterRules[params]},
  N[IndependentAARealEmissionProjectedTrace[ssVal, uVal, vVal] /. rules]
];

Options[IndependentAARealEmissionRho1Cutoff] = Options[NIntegrate];

(* Diagnostic real-emission contribution to rho_1^AA(s) with a soft cutoff.
   The full real piece is infrared divergent as t -> s and becomes physical
   only after adding the virtual correction.  DeltaSoft cuts away the endpoint
   t = s by integrating up to t = s - DeltaSoft.  This function is therefore
   for testing the independent real-emission machinery, not for final paper
   numbers by itself.

   Since rho(s) = rho_0(s) + alpha_s/Pi rho_1(s), the g_s^2 factor from real
   emission contributes 4 Pi^2 C_F to rho_1 after dividing by alpha_s/Pi. *)
IndependentAARealEmissionRho1Cutoff[
  ssVal_?NumericQ,
  deltaSoft_?NumericQ,
  params_: $BcMixingDefaultParameters,
  opts : OptionsPattern[]
] := Module[
  {rules = DynamicParameterRules[params], mbv, mcv, tMin, tMax, trace, coeff,
   uMinus, uPlus},
  mbv = mb /. rules;
  mcv = mc /. rules;
  tMin = (mbv + mcv)^2;
  tMax = ssVal - deltaSoft;
  If[tMax <= tMin, Return[$Failed]];
  trace = Evaluate[IndependentAARealEmissionTraceFormula[] /. rules /. s -> ssVal];
  coeff = $BcMixingNc * IndependentAAColorFactor[] * 4 Pi^2 *
    IndependentAAThreeBodyPhaseSpaceFactor[ssVal]/(2 Pi);
  NIntegrate[
    {uMinus, uPlus} = IndependentAAThreeBodyUBounds[ssVal, tt] /. rules;
    Evaluate[coeff (trace /. {uAA -> uu, vAA -> ssVal - tt - uu})],
    {tt, tMin, tMax},
    {uu, uMinus, uPlus},
    opts
  ]
];

Options[IndependentAARealEmissionCutoffScan] =
  Options[IndependentAARealEmissionRho1Cutoff];

IndependentAARealEmissionCutoffScan[
  ssVal_?NumericQ,
  deltaList_List,
  params_: $BcMixingDefaultParameters,
  opts : OptionsPattern[]
] := Association /@ Table[
  <|
    "s" -> ssVal,
    "DeltaSoft" -> delta,
    "LogDeltaSoft" -> Log[delta],
    "RealRho1Cutoff" ->
      IndependentAARealEmissionRho1Cutoff[ssVal, delta, params, opts]
  |>,
  {delta, deltaList}
];

(* Soft endpoint extraction.  Put t=s-delta, u=delta y and
   v=delta(1-y).  The limit delta^2 Trace_real is finite; after du=delta dy
   this gives the coefficient of the endpoint logarithm. *)
IndependentAARealEmissionSoftKernel[ss_: s, yy_: yAA] :=
  IndependentAARealEmissionSoftKernel[ss, yy] = Module[
    {trace = IndependentAARealEmissionTraceFormula[] /. s -> ss},
    Limit[
      deltaAA^2 (trace /. {uAA -> deltaAA yy, vAA -> deltaAA (1 - yy)}),
      deltaAA -> 0,
      Assumptions -> ss > (mb + mc)^2 && mb > 0 && mc > 0 && 0 < yy < 1
    ] // FullSimplify[#, ss > (mb + mc)^2 && mb > 0 && mc > 0] &
  ];

Options[IndependentAARealEmissionSoftLogCoefficient] = Options[NIntegrate];

IndependentAARealEmissionSoftLogCoefficient[
  ssVal_?NumericQ,
  params_: $BcMixingDefaultParameters,
  opts : OptionsPattern[]
] := Module[
  {rules = DynamicParameterRules[params], yMinus, yPlus, kernel, coeff},
  {yMinus, yPlus} = N[IndependentAARealEmissionSoftYBounds[ssVal] /. rules];
  kernel = Evaluate[IndependentAARealEmissionSoftKernel[ssVal, yAA] /. rules];
  coeff = $BcMixingNc IndependentAAColorFactor[] 4 Pi^2
    IndependentAAThreeBodyPhaseSpaceFactor[ssVal]/(2 Pi);
  NIntegrate[
    Evaluate[coeff kernel],
    {yAA, yMinus, yPlus},
    opts
  ]
];

Options[IndependentAARealEmissionSoftSubtractedRho1Cutoff] =
  Options[IndependentAARealEmissionRho1Cutoff];

(* Removes the leading logarithmic endpoint term from the cutoff integral.
   The result should approach a constant as DeltaSoft -> 0 if the soft
   coefficient has been extracted correctly.  This is still only the real
   emission piece; virtual+counterterm cancellation is checked separately. *)
IndependentAARealEmissionSoftSubtractedRho1Cutoff[
  ssVal_?NumericQ,
  deltaSoft_?NumericQ,
  params_: $BcMixingDefaultParameters,
  opts : OptionsPattern[]
] := Module[
  {raw, softCoeff},
  raw = IndependentAARealEmissionRho1Cutoff[ssVal, deltaSoft, params, opts];
  If[raw === $Failed, Return[$Failed]];
  softCoeff = IndependentAARealEmissionSoftLogCoefficient[ssVal, params, opts];
  raw + softCoeff Log[deltaSoft]
];

Options[IndependentAARealEmissionSoftFitCheck] =
  Options[IndependentAARealEmissionRho1Cutoff];

IndependentAARealEmissionSoftFitCheck[
  ssVal_?NumericQ,
  deltaList_List,
  params_: $BcMixingDefaultParameters,
  opts : OptionsPattern[]
] := Module[
  {scan, data, fit, softCoeff},
  scan = IndependentAARealEmissionCutoffScan[ssVal, deltaList, params, opts];
  data = {#["LogDeltaSoft"], #["RealRho1Cutoff"]} & /@ scan;
  fit = LinearModelFit[data, xAA, xAA];
  softCoeff = IndependentAARealEmissionSoftLogCoefficient[ssVal, params, opts];
  <|
    "Scan" -> scan,
    "LinearFitInLogDelta" -> fit,
    "FitIntercept" -> fit["BestFitParameters"][[1]],
    "FitSlope" -> fit["BestFitParameters"][[2]],
    "PredictedSlopeFromSoftLimit" -> -softCoeff,
    "SoftLogCoefficientK" -> softCoeff,
    "Note" -> "For I(Delta)=const-K Log[Delta], the fitted slope should approach -K for small Delta."
  |>
];

(* The soft limit must reproduce the universal massive eikonal current.
   The extra -3 is not a discrepancy: it is the same cut-to-invariant bridge
   already verified in the LO two-body calculation. *)
IndependentAARealEmissionSoftTheoremCheck[ss_: s, yy_: yAA] := Module[
  {ratio, eikonal},
  ratio = FullSimplify[
    IndependentAARealEmissionSoftKernel[ss, yy]/
      IndependentAALOProjectedTrace[ss],
    ss > (mb + mc)^2 && mb > 0 && mc > 0 && 0 < yy < 1
  ];
  eikonal = 4 (
    -mc^2/yy^2 - mb^2/(1 - yy)^2 +
    (ss - mb^2 - mc^2)/(yy (1 - yy))
  );
  <|
    "SoftKernelOverBorn" -> ratio,
    "UniversalEikonal" -> eikonal,
    "ExpectedBridgeTimesEikonal" ->
      IndependentAACutToInvariantFactor[] eikonal,
    "Difference" -> FullSimplify[
      ratio - IndependentAACutToInvariantFactor[] eikonal,
      ss > (mb + mc)^2 && mb > 0 && mc > 0 && 0 < yy < 1
    ]
  |>
];

(* ------------------------------------------------------------------ *)
(* Unequal-mass final-state dipole subtraction                         *)
(* ------------------------------------------------------------------ *)

(* Catani-Dittmaier-Seymour-Trocsanyi, hep-ph/0201036, Eqs. (5.12),
   (5.14) and (5.16).  The emitted gluon is massless.  r=2 p_Q.k_g and
   q=2 p_spectator.k_g. *)
IndependentAADipoleVelocity[
  ss_, r_, emitterMass_, spectatorMass_
] := Sqrt[
  (ss - emitterMass^2 - spectatorMass^2 - r)^2 -
    4 spectatorMass^2 (emitterMass^2 + r)
]/(ss - emitterMass^2 - spectatorMass^2 - r);

IndependentAADipoleBracket[
  ss_, r_, q_, emitterMass_, spectatorMass_
] := Module[
  {a, y, zEmitter, vTilde, vLocal},
  a = ss - emitterMass^2 - spectatorMass^2;
  y = r/a;
  zEmitter = (a - r - q)/(a - r);
  vTilde = Sqrt[
    KallenLambda[ss, emitterMass, spectatorMass]
  ]/a;
  vLocal = IndependentAADipoleVelocity[
    ss, r, emitterMass, spectatorMass
  ];
  2/(1 - zEmitter (1 - y)) -
    vTilde/vLocal (1 + zEmitter + 2 emitterMass^2/r)
];

(* After factoring out the common g_s^2 N_c C_F, Eq. (5.16) contributes
   2*bracket times the mapped Born trace.  The same -3 bridge used by the
   exact real trace converts it to our stored spin-1 invariant convention. *)
IndependentAADipoleProjectedTrace[
  ss_, r_, q_, emitterMass_, spectatorMass_
] := IndependentAACutToInvariantFactor[] * 2 *
  IndependentAADipoleBracket[
    ss, r, q, emitterMass, spectatorMass
  ]/r * IndependentAALOProjectedTrace[ss];

IndependentAADipoleSumProjectedTrace[
  ss_: s,
  u_: uAA,
  v_: vAA
] := IndependentAADipoleProjectedTrace[ss, u, v, mc, mb] +
  IndependentAADipoleProjectedTrace[ss, v, u, mb, mc];

IndependentAADipoleSoftCancellationCheck[ss_: s, yy_: yAA] := Module[
  {exact, dipoles, difference},
  exact = IndependentAARealEmissionTraceFormula[] /. {
    s -> ss,
    uAA -> deltaAA yy,
    vAA -> deltaAA (1 - yy)
  };
  dipoles = IndependentAADipoleSumProjectedTrace[
    ss, deltaAA yy, deltaAA (1 - yy)
  ];
  difference = FullSimplify[
    Limit[
      deltaAA^2 (exact - dipoles),
      deltaAA -> 0,
      Assumptions ->
        ss > (mb + mc)^2 && mb > 0 && mc > 0 && 0 < yy < 1
    ],
    ss > (mb + mc)^2 && mb > 0 && mc > 0 && 0 < yy < 1
  ];
  <|
    "LeadingSoftDifference" -> difference,
    "CancelsQ" -> TrueQ[difference == 0]
  |>
];

Options[IndependentAARealMinusDipolesRho1] = Options[NIntegrate];

(* The subtracted three-body integral is finite and can be evaluated directly
   in four dimensions over the complete physical phase space. *)
IndependentAARealMinusDipolesRho1[
  ssVal_?NumericQ,
  params_: $BcMixingDefaultParameters,
  opts : OptionsPattern[]
] := Module[
  {rules, mbv, mcv, tMin, trace, dipoles, coeff, integrand},
  rules = DynamicParameterRules[params];
  mbv = mb /. rules;
  mcv = mc /. rules;
  tMin = (mbv + mcv)^2;
  trace = Evaluate[
    IndependentAARealEmissionTraceFormula[] /. rules /. s -> ssVal
  ];
  dipoles = Evaluate[
    IndependentAADipoleSumProjectedTrace[
      ssVal, uAA, vAA
    ] /. rules
  ];
  coeff = $BcMixingNc * IndependentAAColorFactor[] * 4 Pi^2 *
    IndependentAAThreeBodyPhaseSpaceFactor[ssVal]/(2 Pi);
  integrand[x_?NumericQ, z_?NumericQ] := Module[
    {ttVal, bounds, uMinVal, uMaxVal, uVal, vVal, jac},
    ttVal = tMin + (ssVal - tMin) x;
    bounds = N[
      IndependentAAThreeBodyUBounds[ssVal, ttVal] /. rules
    ];
    {uMinVal, uMaxVal} = bounds;
    uVal = uMinVal + (uMaxVal - uMinVal) z;
    vVal = ssVal - ttVal - uVal;
    jac = (ssVal - tMin) (uMaxVal - uMinVal);
    N[
      coeff jac (
        (trace - dipoles) /. {uAA -> uVal, vAA -> vVal}
      )
    ]
  ];
  NIntegrate[
    integrand[xAA, yAA],
    {xAA, 0, 1},
    {yAA, 0, 1},
    opts
  ]
];

(* Finite symmetric eikonal integral, Eq. (5.34). *)
IndependentAAIntegratedEikonalFinite[
  ss_, mass1_, mass2_
] := Module[
  {mu1, mu2, vel, rho1, rho2, rho},
  mu1 = mass1/Sqrt[ss];
  mu2 = mass2/Sqrt[ss];
  vel = Sqrt[KallenLambda[ss, mass1, mass2]]/
    (ss - mass1^2 - mass2^2);
  rho1 = Sqrt[
    (1 - vel + 2 mu1^2/(1 - mu1^2 - mu2^2))/
    (1 + vel + 2 mu1^2/(1 - mu1^2 - mu2^2))
  ];
  rho2 = Sqrt[
    (1 - vel + 2 mu2^2/(1 - mu1^2 - mu2^2))/
    (1 + vel + 2 mu2^2/(1 - mu1^2 - mu2^2))
  ];
  rho = Sqrt[(1 - vel)/(1 + vel)];
  1/vel (
    -Log[rho] Log[1 - (mu1 + mu2)^2] -
    1/2 Log[rho1]^2 - 1/2 Log[rho2]^2 +
    Pi^2/6 + 2 PolyLog[2, -rho] -
    2 PolyLog[2, 1 - rho] -
    1/2 PolyLog[2, 1 - rho1^2] -
    1/2 PolyLog[2, 1 - rho2^2]
  )
];

(* Finite part of Eq. (5.35), after expanding mu_Q^(-2 eps). *)
IndependentAAIntegratedCollinearFinite[
  ss_, emitterMass_, spectatorMass_
] := Module[
  {muQ, muK, den},
  muQ = emitterMass/Sqrt[ss];
  muK = spectatorMass/Sqrt[ss];
  den = 1 - muQ^2 - muK^2;
  Log[muQ] + 3 -
    2 Log[(1 - muK)^2 - muQ^2] +
    Log[1 - muK] -
    2 muQ^2/den Log[muQ/(1 - muK)] -
    muK/(1 - muK) -
    2 muK (1 - 2 muK)/den
];

IndependentAAIntegratedDipoleFinite[
  ss_, emitterMass_, spectatorMass_
] := IndependentAAColorFactor[] (
  2 IndependentAAIntegratedEikonalFinite[
    ss, emitterMass, spectatorMass
  ] +
  IndependentAAIntegratedCollinearFinite[
    ss, emitterMass, spectatorMass
  ]
);

IndependentAAIntegratedDipolePole[
  ss_, emitterMass_, spectatorMass_
] := Module[
  {vel, rho},
  vel = Sqrt[KallenLambda[ss, emitterMass, spectatorMass]]/
    (ss - emitterMass^2 - spectatorMass^2);
  rho = Sqrt[(1 - vel)/(1 + vel)];
  IndependentAAColorFactor[] (Log[rho]/vel + 1)
];

(* Since the integrated dipole enters with alpha_s/(2 Pi), its contribution
   to rho=rho0+alpha_s/Pi rho1 is one half of rho0 times I. *)
IndependentAAIntegratedDipolesFiniteRho1[ss_: s] :=
  1/2 AlphaSLOSpectralDensity["AA", ss] (
    IndependentAAIntegratedDipoleFinite[ss, mc, mb] +
    IndependentAAIntegratedDipoleFinite[ss, mb, mc]
  );

IndependentAAIntegratedDipolesPoleRho1[ss_: s] :=
  1/2 AlphaSLOSpectralDensity["AA", ss] (
    IndependentAAIntegratedDipolePole[ss, mc, mb] +
    IndependentAAIntegratedDipolePole[ss, mb, mc]
  );

(* The functions above are the integrals of the individual dipoles from
   Sect. 5.1.3 of Catani-Dittmaier-Seymour-Trocsanyi.  They are useful pole
   diagnostics, but they are not by themselves the complete finite insertion
   operator for a physical two-parton Born state.  Eq. (6.16) also contains
   V_q^(NS), Gamma_q, gamma_q and K_q terms.  The following functions implement
   that complete insertion for two unequal massive final-state quarks. *)
IndependentAAInsertionKinematics[
  ss_, emitterMass_, spectatorMass_
] := Module[
  {pairInvariant, root, velocity, rhoEmitter, rhoSpectator, rho},
  pairInvariant = ss - emitterMass^2 - spectatorMass^2;
  root = Sqrt[KallenLambda[ss, emitterMass, spectatorMass]];
  velocity = root/pairInvariant;
  rhoEmitter = Sqrt[
    (1 - velocity + 2 emitterMass^2/pairInvariant)/
    (1 + velocity + 2 emitterMass^2/pairInvariant)
  ];
  rhoSpectator = Sqrt[
    (1 - velocity + 2 spectatorMass^2/pairInvariant)/
    (1 + velocity + 2 spectatorMass^2/pairInvariant)
  ];
  rho = Sqrt[(1 - velocity)/(1 + velocity)];
  <|
    "PairInvariant" -> pairInvariant,
    "Q" -> Sqrt[ss],
    "Velocity" -> velocity,
    "RhoEmitter" -> rhoEmitter,
    "RhoSpectator" -> rhoSpectator,
    "Rho" -> rho
  |>
];

(* Finite part of the singular kernel V^(S), Eq. (6.20), before multiplying
   by the quark color charge C_F. *)
IndependentAAInsertionVSFinite[
  ss_, emitterMass_, spectatorMass_
] := Module[
  {kin, pairInvariant, velocity, rhoEmitter, rhoSpectator, rho},
  kin = IndependentAAInsertionKinematics[
    ss, emitterMass, spectatorMass
  ];
  pairInvariant = kin["PairInvariant"];
  velocity = kin["Velocity"];
  rhoEmitter = kin["RhoEmitter"];
  rhoSpectator = kin["RhoSpectator"];
  rho = kin["Rho"];
  1/velocity (
    -1/4 Log[rhoEmitter^2]^2 -
    1/4 Log[rhoSpectator^2]^2 -
    Pi^2/6 +
    Log[rho] Log[ss/pairInvariant]
  )
];

(* Non-singular massive-quark kernel V_q^(NS), Eq. (6.21).  The ratio
   gamma_q/T_q^2 equals 3/2. *)
IndependentAAInsertionVqNS[
  ss_, emitterMass_, spectatorMass_
] := Module[
  {
    kin, pairInvariant, q, velocity, rhoEmitter, rhoSpectator, rho
  },
  kin = IndependentAAInsertionKinematics[
    ss, emitterMass, spectatorMass
  ];
  pairInvariant = kin["PairInvariant"];
  q = kin["Q"];
  velocity = kin["Velocity"];
  rhoEmitter = kin["RhoEmitter"];
  rhoSpectator = kin["RhoSpectator"];
  rho = kin["Rho"];
  3/2 Log[pairInvariant/ss] +
  1/velocity (
    Log[rho^2] Log[1 + rho^2] +
    2 PolyLog[2, rho^2] -
    PolyLog[2, 1 - rhoEmitter^2] -
    PolyLog[2, 1 - rhoSpectator^2] -
    Pi^2/6
  ) +
  Log[(q - spectatorMass)/q] -
  2 Log[((q - spectatorMass)^2 - emitterMass^2)/ss] -
  2 emitterMass^2/pairInvariant
    Log[emitterMass/(q - spectatorMass)] -
  spectatorMass/(q - spectatorMass) +
  2 spectatorMass (2 spectatorMass - q)/pairInvariant +
  Pi^2/2
];

(* Finite square bracket in Eq. (6.16) for a massive quark j and massive
   spectator k.  The pole coefficient is C_F (Log[rho]/v + 1), matching the
   existing pole-cancellation check. *)
IndependentAAInsertionQuarkFinite[
  ss_, emitterMass_, spectatorMass_, scale_: muR
] := Module[
  {
    kin, pairInvariant, velocity, rho, cf, gammaQ, kQ,
    vPole, vFinite, vNS, gammaFinite
  },
  kin = IndependentAAInsertionKinematics[
    ss, emitterMass, spectatorMass
  ];
  pairInvariant = kin["PairInvariant"];
  velocity = kin["Velocity"];
  rho = kin["Rho"];
  cf = IndependentAAColorFactor[];
  gammaQ = 3 cf/2;
  kQ = (7/2 - Pi^2/6) cf;
  vPole = Log[rho]/velocity;
  vFinite = IndependentAAInsertionVSFinite[
    ss, emitterMass, spectatorMass
  ];
  vNS = IndependentAAInsertionVqNS[
    ss, emitterMass, spectatorMass
  ];
  gammaFinite = cf (
    1/2 Log[emitterMass^2/scale^2] - 2
  );
  cf (
    vFinite + vNS - Pi^2/3 +
    vPole Log[scale^2/pairInvariant]
  ) +
  gammaFinite +
  gammaQ Log[scale^2/pairInvariant] +
  gammaQ +
  kQ
];

(* For a color-singlet q qbar Born state, the color-correlated pair sum in
   Eq. (6.16) produces one emitter term for each heavy quark.  The insertion
   multiplies alpha_s/(2 Pi), hence the factor 1/2 in the rho_1 convention. *)
IndependentAACompleteInsertionFiniteRho1[
  ss_: s,
  scale_: muR
] := 1/2 AlphaSLOSpectralDensity["AA", ss] (
  IndependentAAInsertionQuarkFinite[ss, mc, mb, scale] +
  IndependentAAInsertionQuarkFinite[ss, mb, mc, scale]
);

(* Backward-compatible public name.  The previous implementation used only
   the Sect. 5.1.3 individual-dipole integral and omitted the finite terms in
   the complete insertion operator, causing a failed massless-limit check. *)
IndependentAAIntegratedDipolesFiniteRho1AtScale[
  ss_: s,
  scale_: muR
] := IndependentAACompleteInsertionFiniteRho1[ss, scale];

(* Extract the finite virtual contribution in Package-X's epsilon-bar
   convention.  With PaXSubstituteEpsilon -> False, PaXEpsilonBar denotes

     1/epsilon_bar = 1/epsilon - EulerGamma + Log[4 Pi].

   The integrated massive dipoles in Eqs. (5.34)-(5.35) of
   Catani-Dittmaier-Seymour-Trocsanyi are used in the same convention at
   muR^2=Q^2=s.  Taking the coefficient of z^0 after
   PaXEpsilonBar -> z therefore represents
   1/PaXEpsilonBar = 1/z and removes the pole without introducing an
   unmatched (-EulerGamma+Log[4 Pi]) finite term. *)
IndependentAARenormalizedVirtualFiniteRho1EpsilonBar[
  ss_: s,
  ell_: l
] := Module[
  {raw, z, finite},
  raw = IndependentAAVirtualPaXUVIRSplitMapped[
    ss,
    ell,
    FeynCalc`PaXC0Expand -> True,
    FeynCalc`PaXSubstituteEpsilon -> False
  ];
  z = Unique["epsilonBarInverse"];
  finite = Coefficient[
    Normal@Series[
      raw /. {
        FeynCalc`PaXEpsilonBar -> z,
        epsIR -> z,
        epsUV -> z
      },
      {z, 0, 0}
    ],
    z,
    0
  ];
  IndependentAAVirtualRawPoleToRho1[finite, ss] +
    IndependentAAFieldCountertermFiniteRho1[ss]
];

(* Cache the expensive Package-X finite virtual expression once per kernel.
   It remains symbolic in s, mb, mc and muR and is cheap to evaluate at the
   quadrature nodes afterwards. *)
IndependentAACachedVirtualFiniteExpression[] :=
  IndependentAACachedVirtualFiniteExpression[] =
    IndependentAARenormalizedVirtualFiniteRho1EpsilonBar[s, l];

Options[IndependentAAFinalRho1Numeric] = Join[
  Options[IndependentAARealMinusDipolesRho1],
  {"RenormalizationScale" -> Automatic}
];

IndependentAAFinalRho1Numeric[
  ssVal_?NumericQ,
  params_: $BcMixingDefaultParameters,
  opts : OptionsPattern[]
] := Module[
  {rules, scale, realOpts, virtual, integrated, realSubtracted},
  scale = Replace[
    OptionValue["RenormalizationScale"],
    Automatic -> Sqrt[ssVal]
  ];
  If[! NumericQ[scale] || scale <= 0, Return[$Failed]];
  rules = Join[
    DynamicParameterRules[params],
    {s -> ssVal, muR -> scale}
  ];
  realOpts = FilterRules[
    {opts},
    Options[IndependentAARealMinusDipolesRho1]
  ];
  virtual = Re[N[
    IndependentAACachedVirtualFiniteExpression[] /. rules
  ]];
  integrated = Re[N[
    IndependentAAIntegratedDipolesFiniteRho1AtScale[s, muR] /. rules
  ]];
  realSubtracted = IndependentAARealMinusDipolesRho1[
    ssVal, params, Sequence @@ realOpts
  ];
  If[! And @@ (NumericQ /@ {virtual, integrated, realSubtracted}),
    Return[$Failed]
  ];
  <|
    "s" -> ssVal,
    "RenormalizationScale" -> scale,
    "VirtualPlusFieldFiniteRho1" -> virtual,
    "IntegratedDipolesFiniteRho1" -> integrated,
    "RealMinusDipolesRho1" -> realSubtracted,
    "TotalRho1" -> virtual + integrated + realSubtracted
  |>
];

(* ------------------------------------------------------------------ *)
(* Independent asymptotic and symmetry checks                          *)
(* ------------------------------------------------------------------ *)

(* Relativistic relative velocity used for the unequal-mass threshold
   expansion.  It reduces to the usual quark velocity for equal masses:

     v_rel = sqrt(lambda)/(s-m_b^2-m_c^2).

   With this convention the first Coulomb term is
     rho_1/rho_0 -> C_F Pi^2/v_rel. *)
IndependentAARelativeVelocity[
  ss_?NumericQ,
  params_: $BcMixingDefaultParameters
] := Module[
  {rules = DynamicParameterRules[params], mbv, mcv},
  mbv = mb /. rules;
  mcv = mc /. rules;
  N[
    Sqrt[KallenLambda[ss, mbv, mcv]]/
      (ss - mbv^2 - mcv^2)
  ]
];

Options[IndependentAAThresholdCoulombCheck] =
  Options[IndependentAAFinalRho1Numeric];

IndependentAAThresholdCoulombCheck[
  deltaSList_List,
  params_: $BcMixingDefaultParameters,
  opts : OptionsPattern[]
] := Module[
  {rules, threshold, rhoOpts, rows, expected},
  rules = DynamicParameterRules[params];
  threshold = N[BcThreshold[] /. rules];
  rhoOpts = FilterRules[
    {opts}, Options[IndependentAAFinalRho1Numeric]
  ];
  expected = N[IndependentAAColorFactor[] Pi^2];
  rows = Table[
    Module[{ssVal, rho, rho0, velocity, ratio, scaled},
      ssVal = threshold + deltaS;
      rho = IndependentAAFinalRho1Numeric[
        ssVal, params, Sequence @@ rhoOpts
      ];
      If[rho === $Failed, Return[$Failed]];
      rho0 = N[
        AlphaSLOSpectralDensity["AA", ssVal] /. rules
      ];
      velocity = IndependentAARelativeVelocity[ssVal, params];
      ratio = rho["TotalRho1"]/rho0;
      scaled = velocity ratio;
      <|
        "DeltaS" -> deltaS,
        "s" -> ssVal,
        "RelativeVelocity" -> velocity,
        "Rho1OverRho0" -> ratio,
        "VelocityTimesRho1OverRho0" -> scaled,
        "ExpectedCoulombCoefficient" -> expected,
        "DifferenceFromCoulombCoefficient" -> scaled - expected
      |>
    ],
    {deltaS, deltaSList}
  ];
  <|
    "Convention" ->
      "For v_rel=sqrt(lambda)/(s-mb^2-mc^2), the leading Coulomb coefficient is C_F Pi^2.",
    "ExpectedCoulombCoefficient" -> expected,
    "Rows" -> rows
  |>
];

Options[IndependentAAHighEnergyLimitCheck] =
  Options[IndependentAAFinalRho1Numeric];

IndependentAAHighEnergyLimitCheck[
  sValues_List,
  params_: $BcMixingDefaultParameters,
  opts : OptionsPattern[]
] := Module[
  {rules, rhoOpts},
  rules = DynamicParameterRules[params];
  rhoOpts = FilterRules[
    {opts}, Options[IndependentAAFinalRho1Numeric]
  ];
  <|
    "ExpectedLimit" -> 1,
    "Rows" -> Table[
      Module[{rho, rho0, ratio},
        rho = IndependentAAFinalRho1Numeric[
          ssVal, params, Sequence @@ rhoOpts
        ];
        If[rho === $Failed, Return[$Failed]];
        rho0 = N[
          AlphaSLOSpectralDensity["AA", ssVal] /. rules
        ];
        ratio = rho["TotalRho1"]/rho0;
        <|
          "s" -> ssVal,
          "Rho1OverRho0" -> ratio,
          "DifferenceFromMasslessLimit" -> ratio - 1
        |>
      ],
      {ssVal, sValues}
    ]
  |>
];

Options[IndependentAAHeavyLightLimitCheck] =
  Options[IndependentAAFinalRho1Numeric];

(* This is a continuity diagnostic, not by itself an analytic validation.
   The m_light -> 0 endpoint can later be compared with the known heavy-light
   correlator after matching current and spectral-density conventions. *)
IndependentAAHeavyLightLimitCheck[
  ssVal_?NumericQ,
  lightMassValues_List,
  heavyMass_?NumericQ,
  params_: $BcMixingDefaultParameters,
  opts : OptionsPattern[]
] := Module[
  {rhoOpts},
  rhoOpts = FilterRules[
    {opts}, Options[IndependentAAFinalRho1Numeric]
  ];
  <|
    "HeavyMass" -> heavyMass,
    "s" -> ssVal,
    "Rows" -> Table[
      Module[{localParams, rules, rho, rho0},
        localParams = Join[
          params, <|"mb" -> heavyMass, "mc" -> lightMass|>
        ];
        rules = DynamicParameterRules[localParams];
        rho = IndependentAAFinalRho1Numeric[
          ssVal, localParams, Sequence @@ rhoOpts
        ];
        If[rho === $Failed, Return[$Failed]];
        rho0 = N[
          AlphaSLOSpectralDensity["AA", ssVal] /. rules
        ];
        <|
          "LightMass" -> lightMass,
          "Rho1OverRho0" -> rho["TotalRho1"]/rho0
        |>
      ],
      {lightMass, lightMassValues}
    ],
    "Interpretation" ->
      "The sequence should remain finite and smooth. A literature comparison requires matching to the heavy-light vector/axial convention."
  |>
];

Options[IndependentAAMassExchangeSymmetryCheck] =
  Options[IndependentAAFinalRho1Numeric];

IndependentAAMassExchangeSymmetryCheck[
  ssVal_?NumericQ,
  params_: $BcMixingDefaultParameters,
  opts : OptionsPattern[]
] := Module[
  {merged, swapped, rhoOpts, direct, reverse, difference},
  merged = MergeDefaultParameters[params];
  swapped = Join[
    merged,
    <|"mb" -> merged["mc"], "mc" -> merged["mb"]|>
  ];
  rhoOpts = FilterRules[
    {opts}, Options[IndependentAAFinalRho1Numeric]
  ];
  direct = IndependentAAFinalRho1Numeric[
    ssVal, merged, Sequence @@ rhoOpts
  ]["TotalRho1"];
  reverse = IndependentAAFinalRho1Numeric[
    ssVal, swapped, Sequence @@ rhoOpts
  ]["TotalRho1"];
  difference = direct - reverse;
  <|
    "Direct" -> direct,
    "MassesExchanged" -> reverse,
    "Difference" -> difference,
    "PassesQ" -> TrueQ[Abs[difference] < 10^-8]
  |>
];

Options[IndependentAADimensionalScalingCheck] =
  Options[IndependentAAFinalRho1Numeric];

(* The AA spectral density has mass dimension two.  Under
     m_Q -> scale m_Q,  s -> scale^2 s,  mu -> scale mu,
   both rho_0 and rho_1 must scale as scale^2. *)
IndependentAADimensionalScalingCheck[
  ssVal_?NumericQ,
  scale_?NumericQ,
  params_: $BcMixingDefaultParameters,
  opts : OptionsPattern[]
] := Module[
  {merged, scaledParams, rhoOpts, direct, scaled, ratio},
  merged = MergeDefaultParameters[params];
  scaledParams = Join[
    merged,
    <|
      "mb" -> scale merged["mb"],
      "mc" -> scale merged["mc"]
    |>
  ];
  rhoOpts = FilterRules[
    {opts}, Options[IndependentAAFinalRho1Numeric]
  ];
  direct = IndependentAAFinalRho1Numeric[
    ssVal, merged,
    "RenormalizationScale" -> Sqrt[ssVal],
    Sequence @@ DeleteCases[
      rhoOpts, ("RenormalizationScale" -> _)
    ]
  ]["TotalRho1"];
  scaled = IndependentAAFinalRho1Numeric[
    scale^2 ssVal, scaledParams,
    "RenormalizationScale" -> scale Sqrt[ssVal],
    Sequence @@ DeleteCases[
      rhoOpts, ("RenormalizationScale" -> _)
    ]
  ]["TotalRho1"];
  ratio = scaled/(scale^2 direct);
  <|
    "ScaleFactor" -> scale,
    "OriginalRho1" -> direct,
    "ScaledRho1" -> scaled,
    "ScaledOverExpected" -> ratio,
    "DifferenceFromOne" -> ratio - 1,
    "PassesQ" -> TrueQ[Abs[ratio - 1] < 10^-5]
  |>
];

IndependentAAGaussLegendreRule[n_Integer?Positive] := Module[
  {roots, deriv, weights},
  roots = xAA /. NSolve[
    LegendreP[n, xAA] == 0 && -1 < xAA < 1,
    xAA,
    Reals
  ];
  roots = Sort[N[roots, 30]];
  deriv = D[LegendreP[n, xAA], xAA];
  weights = 2/((1 - #^2) (deriv /. xAA -> #)^2) & /@ roots;
  Transpose[{(1 + roots)/2, weights/2}]
];

Options[IndependentAAFinalNLOBorelMoment] = Join[
  Options[IndependentAAFinalRho1Numeric],
  {"NPoints" -> 20, "Progress" -> True}
];

IndependentAAFinalNLOBorelMoment[
  m2Val_?NumericQ,
  continuumVal_?NumericQ,
  params_: $BcMixingDefaultParameters,
  opts : OptionsPattern[]
] := Module[
  {
    rules, threshold, range, quadrature, realOpts, progress, rows, total,
    virtualTotal, integratedTotal, realTotal
  },
  rules = DynamicParameterRules[params];
  threshold = N[BcThreshold[] /. rules];
  If[continuumVal <= threshold, Return[$Failed]];
  range = continuumVal - threshold;
  quadrature = IndependentAAGaussLegendreRule[OptionValue["NPoints"]];
  realOpts = FilterRules[{opts}, Options[IndependentAAFinalRho1Numeric]];
  progress = TrueQ[OptionValue["Progress"]];
  rows = MapIndexed[
    Function[{node, index},
      Module[{z, weight, ssVal, rhoData, jac},
        {z, weight} = node;
        (* s=threshold+range*z^2 clusters nodes near the heavy-heavy
           threshold while the Jacobian keeps the integral exact. *)
        ssVal = threshold + range z^2;
        jac = 2 range z;
        If[progress,
          Print[
            "Independent AA NLO Borel node ",
            First[index], "/", Length[quadrature],
            ", s = ", NumberForm[ssVal, {7, 4}]
          ]
        ];
        rhoData = IndependentAAFinalRho1Numeric[
          ssVal, params, Sequence @@ realOpts
        ];
        If[rhoData === $Failed, Return[$Failed]];
        <|
          "z" -> z,
          "s" -> ssVal,
          "Weight" -> weight,
          "Rho1" -> rhoData["TotalRho1"],
          "BorelFactor" -> weight jac Exp[-ssVal/m2Val],
          "Contribution" ->
            weight jac Exp[-ssVal/m2Val] rhoData["TotalRho1"],
          "Breakdown" -> rhoData
        |>
      ]
    ],
    quadrature
  ];
  If[MemberQ[rows, $Failed], Return[$Failed]];
  total = Total[Lookup[rows, "Contribution"]];
  virtualTotal = Total[
    Lookup[rows, "BorelFactor"] *
      Lookup[Lookup[rows, "Breakdown"], "VirtualPlusFieldFiniteRho1"]
  ];
  integratedTotal = Total[
    Lookup[rows, "BorelFactor"] *
      Lookup[Lookup[rows, "Breakdown"], "IntegratedDipolesFiniteRho1"]
  ];
  realTotal = Total[
    Lookup[rows, "BorelFactor"] *
      Lookup[Lookup[rows, "Breakdown"], "RealMinusDipolesRho1"]
  ];
  <|
    "M2" -> m2Val,
    "s0" -> continuumVal,
    "NPoints" -> OptionValue["NPoints"],
    "BareRho1BorelMoment" -> total,
    "VirtualPlusFieldFiniteBorelRho1" -> virtualTotal,
    "IntegratedDipolesFiniteBorelRho1" -> integratedTotal,
    "RealMinusDipolesBorelRho1" -> realTotal,
    "BreakdownClosure" ->
      virtualTotal + integratedTotal + realTotal - total,
    "Rows" -> rows
  |>
];

Options[IndependentAAFinalNLOBorelSummary] =
  Options[IndependentAAFinalNLOBorelMoment];

IndependentAAFinalNLOBorelSummary[
  m2Val_?NumericQ,
  continuumVal_?NumericQ,
  params_: $BcMixingDefaultParameters,
  opts : OptionsPattern[]
] := Module[
  {moment, alpha, lo, shift},
  moment = IndependentAAFinalNLOBorelMoment[
    m2Val, continuumVal, params, opts
  ];
  If[moment === $Failed, Return[$Failed]];
  alpha = MergeDefaultParameters[params]["alphaS"];
  lo = NumericBorelPi[
    "AA", "pert", m2Val, continuumVal, params
  ];
  shift = alpha/Pi moment["BareRho1BorelMoment"];
  Join[
    KeyDrop[moment, {"Rows"}],
    <|
      "ValidationStatus" ->
        "Validated AA coefficient: equal-mass Catani virtual benchmark, UV/IR cancellation, scale cancellation and rho1/rho0 -> 1 small-mass limit pass. The fixed 4.18/1.27 inputs are an on-shell-scheme diagnostic, not a consistent MSbar paper result.",
      "CoefficientValidatedQ" -> True,
      "PaperReadyQ" -> False,
      "LOPerturbativeMoment" -> lo,
      "AlphaS" -> alpha,
      "AlphaSOverPiNLOShift" -> shift,
      "LOPlusNLO" -> lo + shift,
      "RelativeNLOShift" -> shift/lo,
      "Rows" -> moment["Rows"]
    |>
  ]
];

(* ------------------------------------------------------------------ *)
(* Common-scale MSbar conversion and one-loop running                  *)
(* ------------------------------------------------------------------ *)

(* A one-loop RGE is the perturbatively consistent running accuracy for the
   present O(alpha_s) coefficient.  Threshold matching is continuous at this
   order.  The defaults use mb(mb), mc(mc), and alpha_s(MZ) as boundary
   conditions. *)
$BcAlphaSMSbarDefaults = <|
  "mbAtMb" -> 4.18,
  "mcAtMc" -> 1.27,
  "alphaSAtMZ" -> 0.1180,
  "MZ" -> 91.1876
|>;

IndependentAAAlphaSOneLoopSameNf[
  alpha0_?NumericQ,
  scale0_?NumericQ,
  scale_?NumericQ,
  nf_Integer
] := Module[{beta0 = 11 - 2 nf/3},
  alpha0/(1 + alpha0 beta0/(2 Pi) Log[scale/scale0])
];

IndependentAAAlphaSOneLoop[
  scale_?NumericQ,
  inputs_: $BcAlphaSMSbarDefaults
] := Module[
  {data, mc0, alphaMZ, mz},
  data = Join[$BcAlphaSMSbarDefaults, inputs];
  mc0 = data["mcAtMc"];
  alphaMZ = data["alphaSAtMZ"];
  mz = data["MZ"];
  If[scale < mc0, Return[$Failed]];
  (* The correlator contains an explicit bottom field, so its common-scale
     coefficient is evaluated in the five-flavour full theory. *)
  IndependentAAAlphaSOneLoopSameNf[alphaMZ, mz, scale, 5]
];

IndependentAARunMassOneLoop[
  mass0_?NumericQ,
  alpha0_?NumericQ,
  alpha1_?NumericQ,
  nf_Integer
] := mass0 (alpha1/alpha0)^(12/(33 - 2 nf));

IndependentAAMSbarRunningParameters[
  scale_?NumericQ,
  inputs_: $BcAlphaSMSbarDefaults
] := Module[
  {
    data, mb0, mc0, alphaMZ, mz, alphaMb, alphaMc4, alphaMu,
    mbMu, mcAtMb, mcMu
  },
  data = Join[$BcAlphaSMSbarDefaults, inputs];
  mb0 = data["mbAtMb"];
  mc0 = data["mcAtMc"];
  alphaMZ = data["alphaSAtMZ"];
  mz = data["MZ"];
  If[scale < mc0, Return[$Failed]];
  alphaMb = IndependentAAAlphaSOneLoopSameNf[
    alphaMZ, mz, mb0, 5
  ];
  alphaMc4 = IndependentAAAlphaSOneLoopSameNf[
    alphaMb, mb0, mc0, 4
  ];
  alphaMu = IndependentAAAlphaSOneLoop[scale, data];
  mbMu = IndependentAARunMassOneLoop[
    mb0, alphaMb, alphaMu, 5
  ];
  (* mc(mc) is supplied in the four-flavour theory.  At one loop the
     decoupling relation is continuous, so run it to mb with nf=4, match
     there, and continue with nf=5 to the common correlator scale. *)
  mcAtMb = IndependentAARunMassOneLoop[
    mc0, alphaMc4, alphaMb, 4
  ];
  mcMu = IndependentAARunMassOneLoop[
    mcAtMb, alphaMb, alphaMu, 5
  ];
  <|
    "Scale" -> scale,
    "mbMSbar" -> mbMu,
    "mcMSbar" -> mcMu,
    "alphaS" -> alphaMu,
    "ActiveFlavors" -> 5,
    "BoundaryInputs" -> data,
    "RunningOrder" ->
      "one-loop; mc is matched continuously from nf=4 to the nf=5 full theory at mb"
  |>
];

(* At O(alpha_s), converting the pole masses appearing in the OS coefficient
   to MSbar masses adds the derivative of the Born density.  The one-loop
   relation used here is

     M_Q = mbar_Q(mu) [1 + alpha_s/Pi
       (4/3 + Log[mu^2/mbar_Q(mu)^2])].
*)
IndependentAAMSbarConversionRho1[
  ss_: s,
  scale_: muR
] := Module[{rho0 = AlphaSLOSpectralDensity["AA", ss]},
  mb (4/3 + Log[scale^2/mb^2]) D[rho0, mb] +
  mc (4/3 + Log[scale^2/mc^2]) D[rho0, mc] //
    Simplify
];

Options[IndependentAAFinalRho1MSbarNumeric] =
  Options[IndependentAAFinalRho1Numeric];

IndependentAAFinalRho1MSbarNumeric[
  ssVal_?NumericQ,
  scale_?NumericQ,
  inputs_: $BcAlphaSMSbarDefaults,
  params_: $BcMixingDefaultParameters,
  opts : OptionsPattern[]
] := Module[
  {running, paramsMu, rhoOpts, osData, rules, conversion},
  running = IndependentAAMSbarRunningParameters[scale, inputs];
  If[running === $Failed, Return[$Failed]];
  paramsMu = Join[
    params,
    <|
      "mb" -> running["mbMSbar"],
      "mc" -> running["mcMSbar"],
      "alphaS" -> running["alphaS"]
    |>
  ];
  rhoOpts = DeleteCases[
    FilterRules[{opts}, Options[IndependentAAFinalRho1Numeric]],
    ("RenormalizationScale" -> _)
  ];
  osData = IndependentAAFinalRho1Numeric[
    ssVal,
    paramsMu,
    "RenormalizationScale" -> scale,
    Sequence @@ rhoOpts
  ];
  If[osData === $Failed, Return[$Failed]];
  rules = Join[
    DynamicParameterRules[paramsMu],
    {s -> ssVal, muR -> scale}
  ];
  conversion = Re[N[
    IndependentAAMSbarConversionRho1[s, muR] /. rules
  ]];
  Join[
    osData,
    <|
      "MassScheme" -> "MSbar",
      "RunningParameters" -> running,
      "OSCoefficientAtMSbarMasses" -> osData["TotalRho1"],
      "PoleToMSbarConversionRho1" -> conversion,
      "TotalRho1MSbar" -> osData["TotalRho1"] + conversion
    |>
  ]
];

Options[IndependentAAFinalNLOBorelMSbarMoment] = Join[
  Options[IndependentAAFinalRho1MSbarNumeric],
  {"NPoints" -> 20, "Progress" -> True}
];

IndependentAAFinalNLOBorelMSbarMoment[
  m2Val_?NumericQ,
  continuumVal_?NumericQ,
  scale_?NumericQ,
  inputs_: $BcAlphaSMSbarDefaults,
  params_: $BcMixingDefaultParameters,
  opts : OptionsPattern[]
] := Module[
  {
    running, paramsMu, threshold, range, quadrature, rhoOpts, progress,
    rows, osTotal, conversionTotal, total
  },
  running = IndependentAAMSbarRunningParameters[scale, inputs];
  If[running === $Failed, Return[$Failed]];
  paramsMu = Join[
    params,
    <|
      "mb" -> running["mbMSbar"],
      "mc" -> running["mcMSbar"],
      "alphaS" -> running["alphaS"]
    |>
  ];
  threshold = (running["mbMSbar"] + running["mcMSbar"])^2;
  If[continuumVal <= threshold, Return[$Failed]];
  range = continuumVal - threshold;
  quadrature = IndependentAAGaussLegendreRule[OptionValue["NPoints"]];
  rhoOpts = FilterRules[
    {opts},
    Options[IndependentAAFinalRho1MSbarNumeric]
  ];
  progress = TrueQ[OptionValue["Progress"]];
  rows = MapIndexed[
    Function[{node, index},
      Module[{z, weight, ssVal, jac, rhoData, borelFactor},
        {z, weight} = node;
        ssVal = threshold + range z^2;
        jac = 2 range z;
        If[progress,
          Print[
            "Independent AA MSbar NLO Borel node ",
            First[index], "/", Length[quadrature],
            ", s = ", NumberForm[ssVal, {7, 4}]
          ]
        ];
        rhoData = IndependentAAFinalRho1MSbarNumeric[
          ssVal, scale, inputs, params,
          Sequence @@ rhoOpts
        ];
        If[rhoData === $Failed, Return[$Failed]];
        borelFactor = weight jac Exp[-ssVal/m2Val];
        <|
          "z" -> z,
          "s" -> ssVal,
          "BorelFactor" -> borelFactor,
          "OSContribution" ->
            borelFactor rhoData["OSCoefficientAtMSbarMasses"],
          "ConversionContribution" ->
            borelFactor rhoData["PoleToMSbarConversionRho1"],
          "Contribution" ->
            borelFactor rhoData["TotalRho1MSbar"],
          "Breakdown" -> rhoData
        |>
      ]
    ],
    quadrature
  ];
  If[MemberQ[rows, $Failed], Return[$Failed]];
  osTotal = Total[Lookup[rows, "OSContribution"]];
  conversionTotal = Total[Lookup[rows, "ConversionContribution"]];
  total = Total[Lookup[rows, "Contribution"]];
  <|
    "M2" -> m2Val,
    "s0" -> continuumVal,
    "RenormalizationScale" -> scale,
    "NPoints" -> OptionValue["NPoints"],
    "RunningParameters" -> running,
    "ParametersAtScale" -> paramsMu,
    "OSCoefficientBorelAtMSbarMasses" -> osTotal,
    "PoleToMSbarConversionBorelRho1" -> conversionTotal,
    "BareRho1MSbarBorelMoment" -> total,
    "BreakdownClosure" -> osTotal + conversionTotal - total,
    "Rows" -> rows
  |>
];

Options[IndependentAAFinalNLOBorelMSbarSummary] =
  Options[IndependentAAFinalNLOBorelMSbarMoment];

IndependentAAFinalNLOBorelMSbarSummary[
  m2Val_?NumericQ,
  continuumVal_?NumericQ,
  scale_?NumericQ,
  inputs_: $BcAlphaSMSbarDefaults,
  params_: $BcMixingDefaultParameters,
  opts : OptionsPattern[]
] := Module[
  {moment, running, paramsMu, lo, shift},
  moment = IndependentAAFinalNLOBorelMSbarMoment[
    m2Val, continuumVal, scale, inputs, params, opts
  ];
  If[moment === $Failed, Return[$Failed]];
  running = moment["RunningParameters"];
  paramsMu = moment["ParametersAtScale"];
  lo = NumericBorelPi[
    "AA", "pert", m2Val, continuumVal, paramsMu
  ];
  shift = running["alphaS"]/Pi moment["BareRho1MSbarBorelMoment"];
  Join[
    KeyDrop[moment, {"Rows"}],
    <|
      "ValidationStatus" ->
        "Validated AA coefficient converted to a common-scale one-loop MSbar scheme. Quote a renormalization-scale band and do not infer the mixing-angle correction until AB and BB are also calculated.",
      "CoefficientValidatedQ" -> True,
      "PaperReadyQ" -> False,
      "LOPerturbativeMomentMSbar" -> lo,
      "AlphaSAtScale" -> running["alphaS"],
      "AlphaSOverPiNLOShiftMSbar" -> shift,
      "LOPlusNLOMSbar" -> lo + shift,
      "RelativeNLOShiftMSbar" -> shift/lo,
      "Rows" -> moment["Rows"]
    |>
  ]
];

(* ------------------------------------------------------------------ *)
(* Counterterm bookkeeping for the independent AA NLO path             *)
(* ------------------------------------------------------------------ *)

(* These are the standard on-shell heavy-quark renormalization constants
   written for the coefficient of alpha_s/(4 Pi).  They are kept symbolic in
   epsUV, epsIR and muR so that the pole cancellation can be audited.  The
   final rho_1 convention uses alpha_s/Pi, so counterterm contributions below
   carry an additional factor 1/4. *)
IndependentAAQuarkFieldDeltaZ2OS[m_] :=
  -IndependentAAColorFactor[] (
    1/epsUV + 2/epsIR + 4 + 3 Log[muR^2/m^2]
  );

IndependentAAQuarkMassDeltaZOS[m_] :=
  -IndependentAAColorFactor[] (
    3/epsUV + 4 + 3 Log[muR^2/m^2]
  );

(* Field renormalization of the two quark fields in the bilinear current.
   Each current contributes sqrt(Z2_b Z2_c); the two-point correlator
   therefore receives the sum of the two one-loop field counterterms. *)
IndependentAAFieldCountertermRho1[ss_: s] :=
  1/4 (IndependentAAQuarkFieldDeltaZ2OS[mb] +
    IndependentAAQuarkFieldDeltaZ2OS[mc]) AlphaSLOSpectralDensity["AA", ss] //
    Simplify;

(* Mass renormalization is implemented by differentiating the LO spectral
   density with respect to the two heavy masses.  Since delta m_Q = m_Q
   delta Z_m, the alpha_s/Pi rho_1 coefficient receives the 1/4 factor. *)
IndependentAAMassCountertermRho1[ss_: s] :=
  1/4 (
    mb IndependentAAQuarkMassDeltaZOS[mb] D[AlphaSLOSpectralDensity["AA", ss], mb] +
    mc IndependentAAQuarkMassDeltaZOS[mc] D[AlphaSLOSpectralDensity["AA", ss], mc]
  ) // Simplify;

(* In the optical-theorem amplitude calculation the external quarks are
   already on their physical mass shells.  The renormalized virtual
   amplitude therefore receives the OS field factors.  A derivative of the
   LO phase space with respect to the pole masses is not added here; that
   derivative belongs to a bare-mass reparametrization of the correlator and
   would double count the amplitude-based treatment. *)
IndependentAAAmplitudeCountertermRho1[ss_: s] :=
  IndependentAAFieldCountertermRho1[ss];

IndependentAACountertermRho1[ss_: s] :=
  IndependentAAAmplitudeCountertermRho1[ss];

IndependentAARenormalizationSummary[ss_: s] := <|
  "Convention" -> "Counterterms are coefficients of alpha_s/Pi in rho_1.",
  "DeltaZ2OSCoefficientAlphaSOver4Pi" -> <|
    "b" -> IndependentAAQuarkFieldDeltaZ2OS[mb],
    "c" -> IndependentAAQuarkFieldDeltaZ2OS[mc]
  |>,
  "DeltaZmOSCoefficientAlphaSOver4Pi" -> <|
    "b" -> IndependentAAQuarkMassDeltaZOS[mb],
    "c" -> IndependentAAQuarkMassDeltaZOS[mc]
  |>,
  "FieldCountertermRho1" -> IndependentAAFieldCountertermRho1[ss],
  "MassDerivativeDiagnosticNotAddedToAmplitude" ->
    IndependentAAMassCountertermRho1[ss],
  "AmplitudeCountertermRho1" -> IndependentAAAmplitudeCountertermRho1[ss],
  "StillNeeded" ->
    "The UV and IR poles now cancel in the dedicated checks. The finite virtual and real remainders must still be combined."
|>;

(* Virtual one-gluon correction before loop integration.  The scalar
   denominators are shown explicitly so that Package-X/FeynHelpers can be
   used in the next step to reduce the one-loop vertex.  This is not yet the
   renormalized rho_1^AA; it is the integrand-level starting point. *)
IndependentAAVirtualVertexIntegrand[ell_: l, ss_: s] := Module[
  {den, chain},
  den = FAD[{ell, 0}, {ell + pcAA, mc}, {ell - pbAA, mb}];
  chain =
    FeynCalc`GAD[alphaAA] .
    (FeynCalc`GSD[ell] + FeynCalc`GSD[pcAA] + mc) .
    FeynCalc`GAD[muAA] . GA[5] .
    (FeynCalc`GSD[ell] - FeynCalc`GSD[pbAA] + mb) .
    FeynCalc`GAD[alphaAA];
  <|
    "Integrand" ->
      den DiracTrace[
        (FeynCalc`GSD[pcAA] + mc) . chain .
        (FeynCalc`GSD[pbAA] - mb) .
        FeynCalc`GAD[nuAA] . GA[5]
      ],
    "Projection" -> IndependentAASpin1ProjectorD[pAA, muAA, nuAA],
    "TwoBodyOnShellRules" -> IndependentAA2BodyOnShellRules[ss],
    "ColorFactor" -> "C_F = (N_c^2-1)/(2 N_c)",
    "Status" -> "unrenormalized virtual AA integrand; reduce with Package-X/FeynHelpers, then add counterterms and real emission"
  |>
];

(* Gamma_5-free form of the same nonsinglet axial virtual trace.  After
   cyclically moving the final gamma_5 to the front, conjugation of the block

     (pcslash+mc) gamma_alpha (ellslash+pcslash+mc) gamma_mu

   changes every gamma matrix sign while leaving scalar masses unchanged.
   This representation is preferred for the finite D-dimensional audit,
   because no prescription for gamma_5 away from four dimensions remains. *)
IndependentAAVirtualVertexIntegrandGamma5Free[ell_: l, ss_: s] := Module[
  {den, firstBlock, secondBlock},
  den = FAD[{ell, 0}, {ell + pcAA, mc}, {ell - pbAA, mb}];
  firstBlock =
    (-FeynCalc`GSD[pcAA] + mc) .
    (-FeynCalc`GAD[alphaAA]) .
    (-FeynCalc`GSD[ell] - FeynCalc`GSD[pcAA] + mc) .
    (-FeynCalc`GAD[muAA]);
  secondBlock =
    (FeynCalc`GSD[ell] - FeynCalc`GSD[pbAA] + mb) .
    FeynCalc`GAD[alphaAA] .
    (FeynCalc`GSD[pbAA] - mb) .
    FeynCalc`GAD[nuAA];
  <|
    "Integrand" -> den DiracTrace[firstBlock . secondBlock],
    "Projection" -> IndependentAASpin1ProjectorD[pAA, muAA, nuAA],
    "TwoBodyOnShellRules" -> IndependentAA2BodyOnShellRules[ss],
    "Status" ->
      "unrenormalized gamma5-free D-dimensional virtual AA integrand"
  |>
];

IndependentAAVirtualProjectedIntegrand[ell_: l, ss_: s] := Module[
  {data, expr},
  data = IndependentAAVirtualVertexIntegrand[ell, ss];
  expr = $BcMixingNc IndependentAAColorFactor[] data["Projection"] data["Integrand"];
  expr = expr // DiracSimplify // Contract // FCE // Simplify;
  expr /. data["TwoBodyOnShellRules"] // Contract // FCE // Simplify
];

IndependentAAVirtualProjectedIntegrandGamma5Free[
  ell_: l,
  ss_: s
] := Module[
  {data, expr},
  data = IndependentAAVirtualVertexIntegrandGamma5Free[ell, ss];
  expr = $BcMixingNc IndependentAAColorFactor[] data["Projection"] data["Integrand"];
  expr = expr // DiracSimplify // Contract // FCE // Simplify;
  expr /. data["TwoBodyOnShellRules"] // Contract // FCE // Simplify
];

(* Physical fermion-flow routing for current -> c(pcAA)+anti-b(pbAA).
   With loop momentum ell flowing from the charm line to the antiquark line,
   the internal momenta are pcAA+ell and -pbAA-ell along the fermion arrow.
   The latter gives numerator -ellslash-pbslash+mb and denominator
   (ell+pbAA)^2-mb^2.  The explicit overall minus is the remaining product of
   the two quark-gluon vertices and the Feynman-gauge gluon propagator in the
   convention where the Born chain has no explicit i factors. *)
IndependentAAVirtualVertexIntegrandPhysicalRouting[
  ell_: l,
  ss_: s
] := Module[
  {den, firstBlock, secondBlock},
  den = FAD[{ell, 0}, {ell + pcAA, mc}, {ell + pbAA, mb}];
  firstBlock =
    (-FeynCalc`GSD[pcAA] + mc) .
    (-FeynCalc`GAD[alphaAA]) .
    (-FeynCalc`GSD[ell] - FeynCalc`GSD[pcAA] + mc) .
    (-FeynCalc`GAD[muAA]);
  secondBlock =
    (-FeynCalc`GSD[ell] - FeynCalc`GSD[pbAA] + mb) .
    FeynCalc`GAD[alphaAA] .
    (FeynCalc`GSD[pbAA] - mb) .
    FeynCalc`GAD[nuAA];
  <|
    "Integrand" -> -den DiracTrace[firstBlock . secondBlock],
    "Projection" -> IndependentAASpin1ProjectorD[pAA, muAA, nuAA],
    "TwoBodyOnShellRules" -> IndependentAA2BodyOnShellRules[ss],
    "Status" ->
      "physical fermion-flow routing, gamma5 eliminated before D-dimensional reduction"
  |>
];

IndependentAAVirtualProjectedIntegrandPhysicalRouting[
  ell_: l,
  ss_: s
] := Module[
  {data, expr},
  data = IndependentAAVirtualVertexIntegrandPhysicalRouting[ell, ss];
  expr = $BcMixingNc IndependentAAColorFactor[] data["Projection"] data["Integrand"];
  expr = expr // DiracSimplify // Contract // FCE // Simplify;
  expr /. data["TwoBodyOnShellRules"] // Contract // FCE // Simplify
];

(* Keep the package contexts explicit in this section.  BcMixingMomentum.wl
   clears Global` while loading, and an unqualified TID/PaXEvaluate symbol can
   otherwise be recreated in Global`.  In that failure mode TID remains
   unevaluated and Package-X receives a tensor numerator. *)
IndependentAAVirtualScalarReduction[
  ss_: s,
  ell_: l,
  usePaVeBasis_: True,
  loopDimension_: D
] := Module[
  {expr, bornNormalization, reduced},
  (* Eliminate the two nonsinglet gamma_5 matrices before continuing to D
     dimensions.  Normalize the D-dimensional projected Born trace back to
     the four-dimensional scalar-density convention before expanding loop
     poles.  The O(epsilon) part of this factor is essential: omitting it
     shifts the finite virtual coefficient by a pole times a finite number. *)
  bornNormalization =
    IndependentAALOProjectedTrace[ss]/
      IndependentAALOGamma5FreeProjectedTraceD[ss];
  expr = bornNormalization *
    IndependentAAVirtualProjectedIntegrandGamma5Free[ell, ss];
  expr = FeynCalc`ChangeDimension[expr, loopDimension];
  reduced = FeynCalc`TID[
    expr,
    ell,
    FeynCalc`UsePaVeBasis -> usePaVeBasis
  ] // FeynCalc`Contract;
  (* TID may leave scalar FAD objects next to PaVe functions.  Convert those
     scalar integrals as well before imposing the on-shell invariants, so
     Package-X never has to rediscover p_b^2=m_b^2 or p_c^2=m_c^2. *)
  reduced = FeynCalc`ToPaVe[reduced, ell];
  reduced //
    ReplaceAll[IndependentAADimensionalOnShellRules[ss]] //
    FeynCalc`Contract // FeynCalc`FCE // Simplify
];

IndependentAAVirtualScalarReductionGamma5Free[
  ss_: s,
  ell_: l,
  usePaVeBasis_: True,
  loopDimension_: D,
  preReductionRules_: {},
  projectorAverage_: "D"
] := Module[
  {expr, projectorFactor, reduced},
  expr = IndependentAAVirtualProjectedIntegrandGamma5Free[ell, ss] /.
    preReductionRules;
  projectorFactor = Switch[
    projectorAverage,
    "D", 1,
    "FourDimensional", (D - 1)/3,
    _, Return[Failure[
      "UnknownProjectorAverage",
      <|"ProjectorAverage" -> projectorAverage|>
    ]]
  ];
  expr = projectorFactor expr;
  expr = FeynCalc`ChangeDimension[expr, loopDimension];
  reduced = FeynCalc`TID[
    expr,
    ell,
    FeynCalc`UsePaVeBasis -> usePaVeBasis
  ] // FeynCalc`Contract;
  reduced = FeynCalc`ToPaVe[reduced, ell];
  reduced //
    ReplaceAll[IndependentAADimensionalOnShellRules[ss] /. preReductionRules] //
    FeynCalc`Contract // FeynCalc`FCE // Simplify
];

IndependentAAVirtualReductionDiagnosticGamma5Free[
  ss_: s,
  ell_: l,
  usePaVeBasis_: True,
  loopDimension_: D,
  preReductionRules_: {},
  projectorAverage_: "D"
] := Module[
  {reduced, remainingLoopObjects},
  reduced = IndependentAAVirtualScalarReductionGamma5Free[
    ss, ell, usePaVeBasis, loopDimension, preReductionRules,
    projectorAverage
  ];
  remainingLoopObjects = DeleteDuplicates@Cases[
    reduced,
    x_ /; (
      ! FreeQ[x, FeynCalc`Momentum[ell, ___]] ||
      ! FreeQ[x, FeynCalc`Pair[FeynCalc`Momentum[ell, ___], _]] ||
      ! FreeQ[x, FeynCalc`Pair[_, FeynCalc`Momentum[ell, ___]]]
    ) :> HoldForm[x],
    Infinity
  ];
  <|
    "ScalarReduction" -> reduced,
    "FreeOfLoopMomentum" -> FreeQ[reduced, FeynCalc`Momentum[ell, ___]],
    "RemainingLoopObjects" -> remainingLoopObjects,
    "ReadyForPackageX" -> (
      FreeQ[reduced, FeynCalc`Momentum[ell, ___]] &&
      remainingLoopObjects === {}
    )
  |>
];

IndependentAAVirtualScalarReductionPhysicalRouting[
  ss_: s,
  ell_: l,
  usePaVeBasis_: True,
  loopDimension_: D,
  preReductionRules_: {}
] := Module[
  {expr, reduced},
  expr = IndependentAAVirtualProjectedIntegrandPhysicalRouting[ell, ss] /.
    preReductionRules;
  expr = FeynCalc`ChangeDimension[expr, loopDimension];
  reduced = FeynCalc`TID[
    expr,
    ell,
    FeynCalc`UsePaVeBasis -> usePaVeBasis
  ] // FeynCalc`Contract;
  reduced = FeynCalc`ToPaVe[reduced, ell];
  reduced //
    ReplaceAll[IndependentAADimensionalOnShellRules[ss] /. preReductionRules] //
    FeynCalc`Contract // FeynCalc`FCE // Simplify
];

IndependentAAVirtualReductionDiagnosticPhysicalRouting[
  ss_: s,
  ell_: l,
  usePaVeBasis_: True,
  loopDimension_: D,
  preReductionRules_: {}
] := Module[
  {reduced, remainingLoopObjects},
  reduced = IndependentAAVirtualScalarReductionPhysicalRouting[
    ss, ell, usePaVeBasis, loopDimension, preReductionRules
  ];
  remainingLoopObjects = DeleteDuplicates@Cases[
    reduced,
    x_ /; (
      ! FreeQ[x, FeynCalc`Momentum[ell, ___]] ||
      ! FreeQ[x, FeynCalc`Pair[FeynCalc`Momentum[ell, ___], _]] ||
      ! FreeQ[x, FeynCalc`Pair[_, FeynCalc`Momentum[ell, ___]]]
    ) :> HoldForm[x],
    Infinity
  ];
  <|
    "ScalarReduction" -> reduced,
    "FreeOfLoopMomentum" -> FreeQ[reduced, FeynCalc`Momentum[ell, ___]],
    "RemainingLoopObjects" -> remainingLoopObjects,
    "ReadyForPackageX" -> (
      FreeQ[reduced, FeynCalc`Momentum[ell, ___]] &&
      remainingLoopObjects === {}
    )
  |>
];

IndependentAAVirtualReductionDiagnostic[
  ss_: s,
  ell_: l,
  usePaVeBasis_: True,
  loopDimension_: D
] := Module[
  {reduced, remainingLoopObjects},
  reduced = IndependentAAVirtualScalarReduction[
    ss, ell, usePaVeBasis, loopDimension
  ];
  remainingLoopObjects = DeleteDuplicates@Cases[
    reduced,
    x_ /; (
      ! FreeQ[x, FeynCalc`Momentum[ell, ___]] ||
      ! FreeQ[x, FeynCalc`Pair[FeynCalc`Momentum[ell, ___], _]] ||
      ! FreeQ[x, FeynCalc`Pair[_, FeynCalc`Momentum[ell, ___]]]
    ) :> HoldForm[x],
    Infinity
  ];
  <|
    "ScalarReduction" -> reduced,
    "LeafCount" -> LeafCount[reduced],
    "FreeOfLoopMomentum" -> FreeQ[reduced, FeynCalc`Momentum[ell, ___]],
    "RemainingLoopObjects" -> remainingLoopObjects,
    "ReadyForPackageX" -> (
      FreeQ[reduced, FeynCalc`Momentum[ell, ___]] &&
      remainingLoopObjects === {}
    )
  |>
];

Options[IndependentAAVirtualPaXReduce] = Join[
  Options[FeynCalc`PaXEvaluate],
  {"TensorReduce" -> True, "UsePaVeBasis" -> True, "LoopDimension" -> D}
];

(* Package-X/FeynHelpers reduction of the unrenormalized virtual vertex.
   This returns the analytic loop-integral result for the virtual diagram
   only.  It is not yet rho_1^AA: wave-function/mass counterterms and the
   real-emission contribution must be added before the IR poles cancel. *)
IndependentAAVirtualPaXReduce[
  ss_: s,
  ell_: l,
  opts : OptionsPattern[]
] := Module[
  {expr, diagnostic, paxOpts},
  If[Length[Names["FeynCalc`PaXEvaluate"]] == 0,
    Return[Failure["PaXEvaluateUnavailable", <|"Message" -> "Load FeynHelpers/Package-X first."|>]]
  ];
  If[TrueQ[OptionValue["TensorReduce"]],
    diagnostic = IndependentAAVirtualReductionDiagnostic[
      ss, ell, OptionValue["UsePaVeBasis"], OptionValue["LoopDimension"]
    ];
    If[! TrueQ[diagnostic["ReadyForPackageX"]],
      Return[Failure[
        "TensorReductionIncomplete",
        <|
          "Message" -> "Loop momentum remains after TID; Package-X was not called.",
          "RemainingLoopObjects" -> diagnostic["RemainingLoopObjects"]
        |>
      ]]
    ];
    expr = diagnostic["ScalarReduction"],
    expr = FeynCalc`ChangeDimension[
      IndependentAALOProjectedTrace[ss]/
        IndependentAALOGamma5FreeProjectedTraceD[ss] *
        IndependentAAVirtualProjectedIntegrandGamma5Free[ell, ss],
      OptionValue["LoopDimension"]
    ]
  ];
  paxOpts = FilterRules[{opts}, Options[FeynCalc`PaXEvaluate]];
  paxOpts = Join[
    {
      FeynCalc`PaXImplicitPrefactor ->
        1/(2 Pi)^(4 - 2 FeynCalc`Epsilon)
    },
    paxOpts
  ];
  FeynCalc`PaXEvaluate[expr, ell, Sequence @@ paxOpts]
];

Options[IndependentAAVirtualPaXUVIRSplit] = Join[
  Options[FeynCalc`PaXEvaluateUVIRSplit],
  {"TensorReduce" -> True, "UsePaVeBasis" -> True, "LoopDimension" -> D}
];

IndependentAAVirtualPaXUVIRSplit[
  ss_: s,
  ell_: l,
  opts : OptionsPattern[]
] := Module[
  {expr, diagnostic, paxOpts},
  If[Length[Names["FeynCalc`PaXEvaluateUVIRSplit"]] == 0,
    Return[Failure["PaXEvaluateUVIRSplitUnavailable", <|"Message" -> "Load FeynHelpers/Package-X first."|>]]
  ];
  If[TrueQ[OptionValue["TensorReduce"]],
    diagnostic = IndependentAAVirtualReductionDiagnostic[
      ss, ell, OptionValue["UsePaVeBasis"], OptionValue["LoopDimension"]
    ];
    If[! TrueQ[diagnostic["ReadyForPackageX"]],
      Return[Failure[
        "TensorReductionIncomplete",
        <|
          "Message" -> "Loop momentum remains after TID; Package-X was not called.",
          "RemainingLoopObjects" -> diagnostic["RemainingLoopObjects"]
        |>
      ]]
    ];
    expr = diagnostic["ScalarReduction"],
    expr = FeynCalc`ChangeDimension[
      IndependentAALOProjectedTrace[ss]/
        IndependentAALOGamma5FreeProjectedTraceD[ss] *
        IndependentAAVirtualProjectedIntegrandGamma5Free[ell, ss],
      OptionValue["LoopDimension"]
    ]
  ];
  paxOpts = FilterRules[{opts}, Options[FeynCalc`PaXEvaluateUVIRSplit]];
  paxOpts = Join[
    {
      FeynCalc`PaXImplicitPrefactor ->
        1/(2 Pi)^(4 - 2 FeynCalc`Epsilon)
    },
    paxOpts
  ];
  FeynCalc`PaXEvaluateUVIRSplit[expr, ell, Sequence @@ paxOpts]
];

(* Equal-mass finite-virtual benchmark.

   The main unequal-mass reduction is intentionally left untouched while this
   audit runs.  Here mb=mc=m and s are inserted before tensor reduction, which
   makes the Package-X calculation much smaller.  The standard loop measure
   d^D ell/(2 Pi)^D is supplied explicitly.  Dividing the result by
   i/(16 Pi^2) then produces the same dimensionless loop coefficient that the
   old default-Package-X bridge obtained from raw/(i Pi^2), but now retains
   the O(epsilon) expansion of the physical measure. *)
Options[IndependentAAEqualMassVirtualPaXBenchmark] = {
  "Routing" -> "Legacy",
  "ProjectorAverage" -> "D",
  "NormalizeToFourDimensionalBorn" -> True
};

IndependentAAEqualMassVirtualPaXBenchmark[
  ssVal_?NumericQ,
  massVal_?NumericQ,
  scaleVal_?NumericQ,
  OptionsPattern[]
] := Module[
  {rules, routing, projectorAverage, normalizeBorn, diagnostic,
   normalizationFactor, reducedExpression, raw, mapped, z, poleUV,
   poleIR, finiteRaw,
   phaseBridge, virtualFinite, fieldFinite},
  rules = {mb -> massVal, mc -> massVal, muR -> scaleVal};
  routing = OptionValue["Routing"];
  projectorAverage = OptionValue["ProjectorAverage"];
  normalizeBorn = TrueQ[OptionValue["NormalizeToFourDimensionalBorn"]];
  diagnostic = Switch[
    routing,
    "Physical",
      IndependentAAVirtualReductionDiagnosticPhysicalRouting[
        ssVal, l, True, D, rules
      ],
    "Legacy",
      IndependentAAVirtualReductionDiagnosticGamma5Free[
        ssVal, l, True, D, rules, projectorAverage
      ],
    _,
      Return[Failure[
        "UnknownRouting",
        <|"Routing" -> routing, "Allowed" -> {"Physical", "Legacy"}|>
      ]]
  ];
  If[! TrueQ[diagnostic["ReadyForPackageX"]],
    Return[Failure[
      "TensorReductionIncomplete",
      <|"Diagnostic" -> diagnostic|>
    ]]
  ];
  normalizationFactor = If[
    normalizeBorn,
    IndependentAALOProjectedTrace[ssVal]/
      IndependentAALOGamma5FreeProjectedTraceD[ssVal] /. rules,
    1
  ];
  reducedExpression = normalizationFactor diagnostic["ScalarReduction"];
  raw = FeynCalc`PaXEvaluateUVIRSplit[
    reducedExpression,
    l,
    FeynCalc`PaXC0Expand -> True,
    FeynCalc`PaXSubstituteEpsilon -> False,
    FeynCalc`PaXImplicitPrefactor ->
      1/(2 Pi)^(4 - 2 FeynCalc`Epsilon)
  ];
  mapped = IndependentAAPaXToCountertermConventions[raw] /. muR -> scaleVal;
  z = Unique["epsilonBarInverse"];
  poleUV = IndependentAAPoleCoefficients[mapped]["1/epsUV"];
  poleIR = IndependentAAPoleCoefficients[mapped]["1/epsIR"];
  finiteRaw = Coefficient[
    Normal@Series[
      mapped /. {
        FeynCalc`PaXEpsilonBar -> z,
        epsIR -> z,
        epsUV -> z
      },
      {z, 0, 0}
    ],
    z,
    0
  ];
  phaseBridge =
    (Sqrt[KallenLambda[ssVal, massVal, massVal]]/ssVal)/(16 Pi^2) *
    IndependentAACutToInvariantFactor[] * (1/2);
  virtualFinite = phaseBridge finiteRaw/(I/(16 Pi^2));
  fieldFinite = IndependentAAFieldCountertermFiniteRho1[ssVal] /. rules;
  <|
    "s" -> ssVal,
    "m" -> massVal,
    "mu" -> scaleVal,
    "Routing" -> routing,
    "ProjectorAverage" -> projectorAverage,
    "NormalizeToFourDimensionalBorn" -> normalizeBorn,
    "Gamma5EliminationLOCheck" -> IndependentAALOGamma5EliminationCheck[],
    "VirtualUVPoleRho1" -> N[phaseBridge poleUV/(I/(16 Pi^2))],
    "VirtualIRPoleRho1" -> N[phaseBridge poleIR/(I/(16 Pi^2))],
    "VirtualFiniteRho1" -> Re[N[virtualFinite]],
    "FieldCountertermFiniteRho1" -> N[fieldFinite],
    "RenormalizedVirtualFiniteRho1" ->
      Re[N[virtualFinite + fieldFinite]],
    "LOSpectralDensity" -> N[
      AlphaSLOSpectralDensity["AA", ssVal] /. rules
    ],
    "RenormalizedVirtualFiniteRatio" -> Re[N[
      (virtualFinite + fieldFinite)/
        (AlphaSLOSpectralDensity["AA", ssVal] /. rules)
    ]]
  |>
];

(* Catani et al., Nucl. Phys. B627 (2002) 189, Appendix D, Eq. (D.17).
   This is the finite epsilon-bar coefficient of the renormalized equal-mass
   vector form factor f_1.  In the m^2/s -> 0 limit the transverse nonsinglet
   axial current has the same coefficient.  Since the spectral density
   contains the Born-loop interference, rho_1/rho_0 equals C_F times the
   bracket below in the convention rho=rho_0+(alpha_s/Pi)rho_1. *)
IndependentAAEqualMassCataniF1FiniteRatio[
  ss_?NumericQ,
  mass_?NumericQ,
  scale_?NumericQ
] := Module[
  {velocity, logRatio, ratio, poleBracket, finiteBracket},
  velocity = Sqrt[1 - 4 mass^2/ss];
  logRatio = Log[(1 - velocity)/(1 + velocity)];
  ratio = (1 - velocity)/(1 + velocity);
  poleBracket = -(
    1 + (1 + velocity^2)/(2 velocity) logRatio
  );
  finiteBracket =
    -2 - (1 + 2 velocity^2)/(2 velocity) logRatio +
    (1 + velocity^2)/velocity (
      PolyLog[2, ratio] + Pi^2/3 - 1/4 logRatio^2 +
      logRatio Log[2 velocity/(1 + velocity)]
    );
  N[IndependentAAColorFactor[] (
    finiteBracket + poleBracket Log[scale^2/mass^2]
  )]
];

(* The pure-axial matrix element also contains the finite Pauli form factor
   f_2 in Catani et al. Eq. (D.16).  Dividing its axial coefficient by the
   Born axial matrix element gives -2 Re f_2.  Therefore, in our
   rho=rho_0+(alpha_s/Pi)rho_1 convention, the exact additional ratio is

     -C_F (1-v^2)/(2v) Log[(1-v)/(1+v)].

   It vanishes as m^2/s -> 0 but is needed for an exact finite-mass check. *)
IndependentAAEqualMassCataniAxialFiniteRatio[
  ss_?NumericQ,
  mass_?NumericQ,
  scale_?NumericQ
] := Module[
  {velocity, logRatio, f2Ratio},
  velocity = Sqrt[1 - 4 mass^2/ss];
  logRatio = Log[(1 - velocity)/(1 + velocity)];
  f2Ratio = -IndependentAAColorFactor[] *
    (1 - velocity^2)/(2 velocity) logRatio;
  N[
    IndependentAAEqualMassCataniF1FiniteRatio[ss, mass, scale] +
    f2Ratio
  ]
];

Options[IndependentAAEqualMassVirtualBenchmarkReport] =
  Options[IndependentAAEqualMassVirtualPaXBenchmark];

IndependentAAEqualMassVirtualBenchmarkReport[
  ssVal_?NumericQ,
  massVal_?NumericQ,
  scaleVal_?NumericQ,
  opts : OptionsPattern[]
] := Module[
  {pax, expected, difference},
  pax = IndependentAAEqualMassVirtualPaXBenchmark[
    ssVal, massVal, scaleVal, opts
  ];
  If[FailureQ[pax], Return[pax]];
  expected = IndependentAAEqualMassCataniAxialFiniteRatio[
    ssVal, massVal, scaleVal
  ];
  difference = pax["RenormalizedVirtualFiniteRatio"] - expected;
  Join[
    pax,
    <|
      "CataniF1FiniteRatio" ->
        IndependentAAEqualMassCataniF1FiniteRatio[
          ssVal, massVal, scaleVal
        ],
      "CataniAxialFiniteRatio" -> expected,
      "Difference" -> difference,
      "RelativeDifference" -> difference/expected,
      "PassesFiniteBenchmarkQ" -> TrueQ[Abs[difference] < 10^-6]
    |>
  ]
];

IndependentAAPaXConventionRules[] := {
  FeynCalc`EpsilonUV -> epsUV,
  FeynCalc`EpsilonIR -> epsIR,
  FeynCalc`Epsilon -> epsUV,
  FeynCalc`ScaleMu -> muR
};

IndependentAAPaXToCountertermConventions[expr_] :=
  expr /. ConditionalExpression[body_, _] :> body /.
    IndependentAAPaXConventionRules[];

Options[IndependentAAVirtualPaXUVIRSplitMapped] =
  Options[IndependentAAVirtualPaXUVIRSplit];

IndependentAAVirtualPaXUVIRSplitMapped[
  ss_: s,
  ell_: l,
  opts : OptionsPattern[]
] := IndependentAAPaXToCountertermConventions[
  IndependentAAVirtualPaXUVIRSplit[ss, ell, opts]
];

IndependentAAPoleCoefficients[expr_] := Module[
  {expanded, zUV = Unique["zUV"], zIR = Unique["zIR"], uvSeries, irSeries,
   mixedSeries},
  expanded = expr /. ConditionalExpression[body_, _] :> body;
  expanded = Expand[expanded];
  uvSeries = Expand[expanded /. epsUV -> 1/zUV];
  irSeries = Expand[expanded /. epsIR -> 1/zIR];
  mixedSeries = Expand[expanded /. {epsUV -> 1/zUV, epsIR -> 1/zIR}];
  <|
    "1/epsUV^2" -> Coefficient[uvSeries, zUV, 2],
    "1/epsUV" -> Coefficient[uvSeries, zUV, 1],
    "1/epsIR^2" -> Coefficient[irSeries, zIR, 2],
    "1/epsIR" -> Coefficient[irSeries, zIR, 1],
    "1/(epsUV epsIR)" ->
      Coefficient[Coefficient[mixedSeries, zUV, 1], zIR, 1],
    "FiniteBySettingPolesZero" ->
      expanded /. {epsUV -> Infinity, epsIR -> Infinity}
  |>
];

Options[IndependentAAVirtualPoleCoefficients] =
  Options[IndependentAAVirtualPaXUVIRSplitMapped];

IndependentAAVirtualPoleCoefficients[
  ss_: s,
  ell_: l,
  opts : OptionsPattern[]
] := IndependentAAPoleCoefficients[
  IndependentAAVirtualPaXUVIRSplitMapped[ss, ell, opts]
];

(* Convert a pole coefficient of the projected virtual trace, evaluated with
   the physical loop measure d^D ell/(2 Pi)^D, to the coefficient rho_1 in
      rho = rho_0 + alpha_s/Pi rho_1.
   The factor 1/2 combines the alpha_s/(4 Pi) loop normalization with the
   factor 2 from Born-loop interference. *)
IndependentAAVirtualRawPoleToRho1[rawPole_, ss_: s] :=
  Simplify[
    Sqrt[KallenLambda[ss, mb, mc]]/ss/(16 Pi^2) *
    IndependentAACutToInvariantFactor[] * (1/2) *
    rawPole/(I/(16 Pi^2))
  ];

Options[IndependentAAVirtualUVPoleRho1] =
  Options[IndependentAAVirtualPoleCoefficients];

IndependentAAVirtualUVPoleRho1[
  ss_: s,
  ell_: l,
  opts : OptionsPattern[]
] := IndependentAAVirtualRawPoleToRho1[
  IndependentAAVirtualPoleCoefficients[ss, ell, opts]["1/epsUV"],
  ss
];

(* Only the constant soft numerator multiplies the infrared-singular scalar
   triangle.  Its exact factorization onto the Born trace is checked
   independently by the real-emission soft theorem. *)
IndependentAAVirtualSoftNumerator[ss_: s] :=
  Simplify[
    $BcMixingNc * IndependentAAColorFactor[] * 2 *
    (mb^2 + mc^2 - ss) * IndependentAALOProjectedTrace[ss]
  ];

(* Real part of the on-shell scalar triangle's 1/epsIR coefficient. *)
IndependentAAC0IRPoleCoefficient[ss_: s] :=
  -Log[
    (ss - mb^2 - mc^2 + Sqrt[KallenLambda[ss, mb, mc]])/(2 mb mc)
  ]/Sqrt[KallenLambda[ss, mb, mc]];

IndependentAAVirtualIRPoleRho1[ss_: s] :=
  Simplify[
    Sqrt[KallenLambda[ss, mb, mc]]/ss/(16 Pi^2) *
    IndependentAACutToInvariantFactor[] * (1/2) *
    IndependentAAVirtualSoftNumerator[ss] *
    IndependentAAC0IRPoleCoefficient[ss]
  ];

Options[IndependentAARealIRPoleRho1] =
  Options[IndependentAARealEmissionSoftLogCoefficient];

(* In D=4-2 eps the endpoint measure is
      integral_0 d delta delta^(-1-2 eps) = -1/(2 eps) + finite.
   Hence the real-emission 1/epsIR coefficient is -K/2, where K is the
   independently integrated coefficient of the four-dimensional log cutoff. *)
IndependentAARealIRPoleRho1[
  ssVal_?NumericQ,
  params_: $BcMixingDefaultParameters,
  opts : OptionsPattern[]
] := -1/2 IndependentAARealEmissionSoftLogCoefficient[
  ssVal, params, opts
];

Options[IndependentAAUVPoleCancellationCheck] =
  Options[IndependentAAVirtualUVPoleRho1];

IndependentAAUVPoleCancellationCheck[
  ss_: s,
  ell_: l,
  opts : OptionsPattern[]
] := Module[
  {virtual, field, total},
  virtual = IndependentAAVirtualUVPoleRho1[ss, ell, opts];
  field = IndependentAAPoleCoefficients[
    IndependentAAAmplitudeCountertermRho1[ss]
  ]["1/epsUV"];
  total = FullSimplify[
    virtual + field,
    ss > (mb + mc)^2 && mb > 0 && mc > 0
  ];
  <|
    "VirtualUVPoleRho1" -> virtual,
    "FieldCountertermUVPoleRho1" -> field,
    "Sum" -> total,
    "CancelsQ" -> TrueQ[total == 0]
  |>
];

Options[IndependentAAIRPoleCancellationCheck] =
  Options[IndependentAARealIRPoleRho1];

IndependentAAIRPoleCancellationCheck[
  ssVal_?NumericQ,
  params_: $BcMixingDefaultParameters,
  opts : OptionsPattern[]
] := Module[
  {rules, virtual, field, real, total},
  rules = DynamicParameterRules[params];
  virtual = N[IndependentAAVirtualIRPoleRho1[s] /. rules /. s -> ssVal];
  field = N[
    IndependentAAPoleCoefficients[
      IndependentAAAmplitudeCountertermRho1[s]
    ]["1/epsIR"] /. rules /. s -> ssVal
  ];
  real = IndependentAARealIRPoleRho1[ssVal, params, opts];
  total = virtual + field + real;
  <|
    "s" -> ssVal,
    "VirtualIRPoleRho1" -> virtual,
    "FieldCountertermIRPoleRho1" -> field,
    "RealIRPoleRho1" -> real,
    "Sum" -> total,
    "CancelsNumericallyQ" -> TrueQ[Abs[total] < 10^-8]
  |>
];

Options[IndependentAAVirtualFiniteRho1] =
  Options[IndependentAAVirtualPaXUVIRSplitMapped];

(* Finite part of the virtual vertex after removing the explicitly labelled
   UV and IR poles.  It is still only the virtual contribution; the finite
   field counterterm is added by the next wrapper. *)
IndependentAAVirtualFiniteRho1[
  ss_: s,
  ell_: l,
  opts : OptionsPattern[]
] := Module[
  {mapped, finite},
  mapped = IndependentAAVirtualPaXUVIRSplitMapped[ss, ell, opts];
  finite = IndependentAAPoleCoefficients[mapped][
    "FiniteBySettingPolesZero"
  ];
  IndependentAAVirtualRawPoleToRho1[finite, ss]
];

IndependentAAFieldCountertermFiniteRho1[ss_: s] :=
  Expand[IndependentAAAmplitudeCountertermRho1[ss]] /.
    {epsUV -> Infinity, epsIR -> Infinity};

Options[IndependentAARenormalizedVirtualFiniteRho1] =
  Options[IndependentAAVirtualFiniteRho1];

IndependentAARenormalizedVirtualFiniteRho1[
  ss_: s,
  ell_: l,
  opts : OptionsPattern[]
] := IndependentAAVirtualFiniteRho1[ss, ell, opts] +
  IndependentAAFieldCountertermFiniteRho1[ss];

Options[IndependentAARenormalizedVirtualFiniteNumeric] =
  Options[IndependentAARenormalizedVirtualFiniteRho1];

IndependentAARenormalizedVirtualFiniteNumeric[
  ssVal_?NumericQ,
  params_: $BcMixingDefaultParameters,
  opts : OptionsPattern[]
] := Module[
  {rules, value},
  rules = Join[
    DynamicParameterRules[params],
    {s -> ssVal, muR -> Sqrt[ssVal]}
  ];
  value = IndependentAARenormalizedVirtualFiniteRho1[
    s, l, opts
  ] /. rules;
  Re[N[value]]
];

(* Off-shell regulator for inspecting the virtual expression numerically.
   This keeps the two cut quarks slightly off shell:
      p_b^2 = m_b^2 (1-eta), p_c^2 = m_c^2 (1-eta).
   It is only a diagnostic regulator.  The final NLO result must be obtained
   from the regulator-independent real+virtual+counterterm combination. *)
IndependentAAOffShellRegulatorRules[ss_?NumericQ, eta_?NumericQ,
  params_: $BcMixingDefaultParameters] := Module[
  {rules = DynamicParameterRules[params], mbv, mcv, pb2, pc2, pbc},
  mbv = mb /. rules;
  mcv = mc /. rules;
  pb2 = mbv^2 (1 - eta);
  pc2 = mcv^2 (1 - eta);
  pbc = (ss - pb2 - pc2)/2;
  Join[
    rules,
    {
      s -> ss,
      Pair[Momentum[pbAA, D], Momentum[pbAA, D]] -> pb2,
      Pair[Momentum[pcAA, D], Momentum[pcAA, D]] -> pc2,
      Pair[Momentum[pbAA, D], Momentum[pcAA, D]] -> pbc,
      Pair[Momentum[pcAA, D], Momentum[pbAA, D]] -> pbc,
      Pair[Momentum[pAA, D], Momentum[pAA, D]] -> ss,
      Pair[Momentum[pAA, D], Momentum[pbAA, D]] -> (ss + pb2 - pc2)/2,
      Pair[Momentum[pbAA, D], Momentum[pAA, D]] -> (ss + pb2 - pc2)/2,
      Pair[Momentum[pAA, D], Momentum[pcAA, D]] -> (ss + pc2 - pb2)/2,
      Pair[Momentum[pcAA, D], Momentum[pAA, D]] -> (ss + pc2 - pb2)/2
    }
  ]
];

Options[IndependentAAVirtualOffShellNumeric] =
  Options[IndependentAAVirtualPaXReduce];

IndependentAAVirtualOffShellNumeric[
  ssVal_?NumericQ,
  eta_?NumericQ,
  params_: $BcMixingDefaultParameters,
  opts : OptionsPattern[]
] := Module[
  {expr, rules},
  expr = IndependentAAPaXToCountertermConventions[
    IndependentAAVirtualPaXReduce[ssVal, l, opts]
  ];
  rules = IndependentAAOffShellRegulatorRules[ssVal, eta, params];
  N[expr /. rules /. {epsUV -> Infinity, epsIR -> Infinity, muR -> Sqrt[ssVal]}]
];

IndependentAANLOAssemblyReport[
  ssVal_?NumericQ,
  deltaSoft_?NumericQ,
  eta_?NumericQ,
  params_: $BcMixingDefaultParameters
] := Module[
  {rules = DynamicParameterRules[params], lo, real, softCoeff, realSubtracted,
   ct, uvCheck, irCheck},
  lo = N[AlphaSLOSpectralDensity["AA", ssVal] /. rules];
  real = IndependentAARealEmissionRho1Cutoff[
    ssVal, deltaSoft, params,
    AccuracyGoal -> 4, PrecisionGoal -> 4, MaxRecursion -> 4
  ];
  softCoeff = IndependentAARealEmissionSoftLogCoefficient[
    ssVal, params,
    AccuracyGoal -> 4, PrecisionGoal -> 4, MaxRecursion -> 4
  ];
  realSubtracted = If[
    real === $Failed || softCoeff === $Failed,
    $Failed,
    real + softCoeff Log[deltaSoft]
  ];
  ct = IndependentAACountertermRho1[s] /. rules /. s -> ssVal;
  uvCheck = IndependentAAUVPoleCancellationCheck[
    s, l, FeynCalc`PaXC0Expand -> True
  ];
  irCheck = IndependentAAIRPoleCancellationCheck[
    ssVal, params,
    AccuracyGoal -> 5, PrecisionGoal -> 5, MaxRecursion -> 5
  ];
  <|
    "UseOfWangFormula" -> False,
    "s" -> ssVal,
    "LO_rho0_AA" -> lo,
    "Real_rho1_cutoff_diagnostic" -> real,
    "DeltaSoft" -> deltaSoft,
    "RealSoftLogCoefficientK" -> softCoeff,
    "RealSoftSlopePredictionMinusK" -> -softCoeff,
    "RealSoftSubtractedDiagnostic" -> realSubtracted,
    "Virtual_offshell_regulator_eta" -> eta,
    "AmplitudeFieldCounterterm_rho1_symbolic" -> ct,
    "UVPoleCancellation" -> uvCheck,
    "IRPoleCancellation" -> irCheck,
    "FinalIndependentRho1AA" -> IndependentAAFinalRho1Numeric[
      ssVal,
      params,
      AccuracyGoal -> 5,
      PrecisionGoal -> 5,
      MaxRecursion -> 10
    ],
    "CanCompareToWang" -> True,
    "NextRequiredStep" ->
      "Repeat the independently validated virtual-real-dipole construction for the AB and BB tensor-current channels."
  |>
];

IndependentAAStatus[] := <|
  "UseOfWangFormula" -> "None in the IndependentAA* functions; Wang is retained only as a later comparison.",
  "Completed" -> {
    "AA LO two-body cut derived from spin sums",
    "AA LO projected spectral density check against BcMixingMomentum.wl",
    "AA real-emission projected Dirac trace with u=2 pc.k and v=2 pb.k variables",
    "AA real-emission antiquark sign fixed by an exact universal soft-theorem check",
    "AA real-emission phase-space limits and cutoff diagnostic integral",
    "AA three-body Dalitz measure and optical-theorem normalization audited",
    "AA virtual vertex reduced to scalar integrals without tensor warnings",
    "AA on-shell field counterterm prepared in the amplitude scheme",
    "AA virtual UV pole cancels the OS field counterterm exactly",
    "AA virtual+field IR pole cancels the real-emission pole numerically",
    "AA finite renormalized virtual contribution evaluates numerically",
    "AA hard-real soft-subtracted remainder approaches a cutoff-independent limit",
    "AA unequal-mass local dipoles reproduce the exact soft limit",
    "AA integrated dipole pole cancels the virtual-plus-field IR pole",
    "AA finite virtual, integrated-dipole and real-minus-dipole pieces can be assembled numerically",
    "Package-X epsilon-bar convention corrected: 1/PaXEpsilonBar is the epsilon-bar pole",
    "D-dimensional projected Born trace normalized to the four-dimensional spectral-density convention before finite-part extraction",
    "equal-mass virtual coefficient reproduces the exact Catani f1+f2 axial result at multiple masses",
    "equal-mass small-mass limit satisfies rho1/rho0 -> 1",
    "AA Borel quadrature is numerically stable at 12 and 20 nodes"
  },
  "StillNeededForPaperNLO" -> {
    "repeat the pointwise comparison with an independently transcribed unequal-mass result",
    "quote a common-scale MSbar result with a renormalization-scale band",
    "repeat the independent derivation for AB",
    "repeat the independent derivation for BB",
    "propagate the three NLO channel corrections into the mixing angle"
  },
  "RecommendedChecks" -> {
    "IndependentAALODerivationCheck[s][\"Difference\"] should be 0",
    "IndependentAARealEmissionTraceCheck[ss,u,v] should be finite inside physical phase space",
    "IndependentAARealEmissionCutoffScan[s,{...}] should show the expected endpoint-cutoff dependence",
    "IndependentAARealEmissionSoftTheoremCheck[s,y][\"Difference\"] should be 0",
    "IndependentAAUVPoleCancellationCheck[s][\"CancelsQ\"] should be True",
    "IndependentAAIRPoleCancellationCheck[40.][\"CancelsNumericallyQ\"] should be True",
    "IndependentAAEqualMassVirtualBenchmarkReport[40,1/5,Sqrt[40]][\"PassesFiniteBenchmarkQ\"] should be True",
    "IndependentAAThresholdCoulombCheck[{0.1,0.25,0.5}] should approach C_F Pi^2",
    "IndependentAAHighEnergyLimitCheck[{100.,400.,1600.}] should approach 1",
    "IndependentAAMassExchangeSymmetryCheck[40.][\"PassesQ\"] should be True",
    "IndependentAADimensionalScalingCheck[40.,2.][\"PassesQ\"] should be True",
    "the equal-mass small-mass limit must satisfy rho1/rho0 -> 1",
    "the virtual ln(mu^2) slope must equal its IR-pole coefficient",
    "Wang or any other published expression is only an external comparison and must pass the same limiting checks"
  }
|>;

(* ---------------------------------------------------------------------- *)
(* Literature validation: unequal-mass axial-vector NLO density            *)
(* ---------------------------------------------------------------------- *)

(* Wang, arXiv:1303.4146, gives the unequal-mass NLO spectral density for
   vector/axial-vector currents.  This section transcribes the axial-vector
   result in the convention

      rho_A(s) = rho_A^0(s) + alphaS/Pi rho_A^1,bare(s).

   The first use is a normalization check: WangAxialLOSpectralDensity should
   agree with our AA LO spectral density after m1 -> mb, m2 -> mc. *)

WangKallen[ss_, m1_, m2_] :=
  ss^2 + m1^4 + m2^4 - 2 ss m1^2 - 2 ss m2^2 - 2 m1^2 m2^2;

WangSBar[ss_, m1_, m2_] := ss - (m1 - m2)^2;

WangOmega[ss_, m1_, m2_] :=
  Sqrt[(ss - (m1 + m2)^2)/(ss - (m1 - m2)^2)];

WangOmega1[ss_, m1_, m2_] :=
  Sqrt[WangKallen[ss, m1, m2]]/(ss + m1^2 - m2^2);

WangOmega2[ss_, m1_, m2_] :=
  Sqrt[WangKallen[ss, m1, m2]]/(ss + m2^2 - m1^2);

WangM[m1_, m2_] := (m1 + m2)/(m1 - m2);

WangLogW[ss_, m1_, m2_] :=
  Log[(1 + WangOmega[ss, m1, m2])/(1 - WangOmega[ss, m1, m2])];

WangLi2[z_] := PolyLog[2, z];

WangAxialLOSpectralDensity[ss_, m1_, m2_] := Module[
  {lam = WangKallen[ss, m1, m2]},
  3/(8 Pi^2) Sqrt[lam]/ss (ss - (m1 + m2)^2 - lam/(3 ss))
];

WangVbar00[ss_, m1_, m2_] := Module[
  {lam = WangKallen[ss, m1, m2], w = WangOmega[ss, m1, m2],
   w1 = WangOmega1[ss, m1, m2], w2 = WangOmega2[ss, m1, m2]},
  1/Sqrt[lam] (
    Log[1 - w1^2]^2/4 - Log[1 + w1]^2 +
    Log[1 - w2^2]^2/4 - Log[1 + w2]^2 +
    2 Log[w1 + w2] Log[(1 + w)/(1 - w)] -
    Log[w1] Log[(1 + w2)/(1 - w2)] -
    Log[w2] Log[(1 + w1)/(1 - w1)] -
    WangLi2[2 w1/(1 + w1)] -
    WangLi2[2 w2/(1 + w2)] + Pi^2
  )
];

WangV10[ss_, m1_, m2_] := Module[
  {w = WangOmega[ss, m1, m2], w1 = WangOmega1[ss, m1, m2],
   w2 = WangOmega2[ss, m1, m2]},
  1/ss (1/2 Log[(1 - w1^2)/(1 - w2^2)] -
    1/w2 Log[(1 + w)/(1 - w)] + Log[w2/w1])
];

WangV01[ss_, m1_, m2_] := WangV10[ss, m2, m1];

WangV20[ss_, m1_, m2_] := Module[
  {w = WangOmega[ss, m1, m2], w1 = WangOmega1[ss, m1, m2],
   w2 = WangOmega2[ss, m1, m2], den},
  den = w1 + w2;
  1/(2 ss) (
    -w1 w2/den Log[(1 + w)/(1 - w)] -
    w1/(w2 den) Log[(1 + w)/(1 - w)] +
    w1/den Log[(1 - w1^2)/(1 - w2^2)] +
    2 w1/den Log[w2/w1] + 1
  )
];

WangV02[ss_, m1_, m2_] := WangV20[ss, m2, m1];

WangV11[ss_, m1_, m2_] := Module[
  {w = WangOmega[ss, m1, m2], w1 = WangOmega1[ss, m1, m2],
   w2 = WangOmega2[ss, m1, m2], den},
  den = w1 + w2;
  1/(2 ss) (
    w1 w2/den Log[(1 + w)/(1 - w)] -
    (w1 - w2)/(2 den) Log[(1 - w1^2)/(1 - w2^2)] -
    1/den Log[(1 + w)/(1 - w)] +
    w1/den Log[w1/w2] + w2/den Log[w2/w1] - 1
  )
];

WangVbar[ss_, m1_, m2_] := Module[
  {w = WangOmega[ss, m1, m2], w1 = WangOmega1[ss, m1, m2],
   w2 = WangOmega2[ss, m1, m2], den},
  den = w1 + w2;
  1 - 2 w1 w2/den Log[(1 + w)/(1 - w)] -
    w2/den Log[1 - w1^2] -
    w1/den Log[1 - w2^2] -
    2 (w1 Log[w1] + w2 Log[w2])/den +
    2 Log[den]
];

WangFbarAxial[ss_, m1_, m2_] :=
  WangVbar[ss, m1, m2] +
  2 (ss - m1^2 - m2^2) (
    WangVbar00[ss, m1, m2] - WangV10[ss, m1, m2] -
      WangV01[ss, m1, m2] + WangV11[ss, m1, m2]
  ) -
  2 m1 m2 (WangV10[ss, m1, m2] + WangV01[ss, m1, m2]) +
  2 m1^2 (WangV10[ss, m1, m2] - WangV20[ss, m1, m2]) +
  2 m2^2 (WangV01[ss, m1, m2] - WangV02[ss, m1, m2]);

WangF1Axial[ss_, m1_, m2_] :=
  4 m1 WangV20[ss, m1, m2] + 4 m2 WangV01[ss, m1, m2] -
    4 m2 WangV11[ss, m1, m2];

WangF2Axial[ss_, m1_, m2_] :=
  -4 m2 WangV02[ss, m1, m2] - 4 m1 WangV10[ss, m1, m2] +
    4 m1 WangV11[ss, m1, m2];

WangR0[ss_, m1_, m2_] := Module[
  {lam = WangKallen[ss, m1, m2], w = WangOmega[ss, m1, m2],
   mm = WangM[m1, m2]},
  (m1^2 - m2^2)/4 Log[(mm + w)/(mm - w)] -
    (ss m1^2 + ss m2^2 - 2 m1^2 m2^2)/(4 ss) WangLogW[ss, m1, m2] +
    Sqrt[lam] (ss + m1^2 + m2^2)/(8 ss)
];

WangRbar11[ss_, m1_, m2_] := Module[
  {lam = WangKallen[ss, m1, m2], w = WangOmega[ss, m1, m2],
   w1 = WangOmega1[ss, m1, m2]},
  -(ss + m1^2 - m2^2)/(2 Sqrt[lam]) Log[(1 + w1)/(1 - w1)] -
    (m1^2 - m2^2)/Sqrt[lam] Log[(1 + w1)/(1 - w1)] -
    (ss - m1^2 + m2^2)/Sqrt[lam] Log[(1 + w)/(1 - w)]
];

WangRbar22[ss_, m1_, m2_] := WangRbar11[ss, m2, m1];

WangRbar12[ss_, m1_, m2_] := Module[
  {lam = WangKallen[ss, m1, m2], w = WangOmega[ss, m1, m2],
   w1 = WangOmega1[ss, m1, m2], w2 = WangOmega2[ss, m1, m2],
   mm = WangM[m1, m2], sb = WangSBar[ss, m1, m2]},
  1/Sqrt[lam] (
    -2 Log[m1/m2] Log[(mm + w)/(mm - w)] -
    WangLogW[ss, m1, m2]^2 +
    2 Log[ss/sb] WangLogW[ss, m1, m2] -
    4 WangLi2[2 w/(1 + w)] +
    2 WangLi2[(w - 1)/(w - mm)] +
    2 WangLi2[(w - 1)/(w + mm)] -
    2 WangLi2[(w + 1)/(w - mm)] -
    2 WangLi2[(w + 1)/(w + mm)] -
    1/2 WangLi2[(1 + w1)/2] -
    1/2 WangLi2[(1 + w2)/2] -
    WangLi2[w1] - WangLi2[w2] +
    Log[2] Log[(1 + w1) (1 + w2)]/2 -
    Log[2]^2/2 + Pi^2/12
  )
];

WangR12One[ss_, m1_, m2_] := Module[
  {lam = WangKallen[ss, m1, m2], w = WangOmega[ss, m1, m2],
   mm = WangM[m1, m2], sb = WangSBar[ss, m1, m2]},
  ss/Sqrt[lam] (
    Log[1 - w]^2 - Log[1 + w]^2 +
    2 Log[2 ss/sb] WangLogW[ss, m1, m2] +
    2 WangLi2[(1 - w)/2] - 2 WangLi2[(1 + w)/2] +
    2 WangLi2[(1 + w)/(1 + mm)] +
    2 WangLi2[(1 + w)/(1 - mm)] -
    2 WangLi2[(1 - w)/(1 - mm)] -
    2 WangLi2[(1 - w)/(1 + mm)]
  )
];

WangR12Two[ss_, m1_, m2_] := Module[
  {lam = WangKallen[ss, m1, m2], w = WangOmega[ss, m1, m2],
   mm = WangM[m1, m2], sb = WangSBar[ss, m1, m2]},
  ss^2/Sqrt[lam] (
    Log[1 - w]^2 - Log[1 + w]^2 +
    2 Log[4 ss/sb] WangLogW[ss, m1, m2] +
    2 WangLi2[(1 - w)/2] - 2 WangLi2[(1 + w)/2] +
    2 WangLi2[(1 + w)/(1 + mm)] +
    2 WangLi2[(1 + w)/(1 - mm)] -
    2 WangLi2[(1 - w)/(1 - mm)] -
    2 WangLi2[(1 - w)/(1 + mm)] +
    2 w sb/ss - sb/ss (1 + w^2) WangLogW[ss, m1, m2]
  )
];

WangAxialNLOBareSpectralDensity[ss_, m1_, m2_] := Module[
  {lam = WangKallen[ss, m1, m2], root, rho0, lW, common, extra},
  root = Sqrt[lam];
  rho0 = WangAxialLOSpectralDensity[ss, m1, m2];
  lW = WangLogW[ss, m1, m2];
  common =
    rho0 (
      1/2 WangFbarAxial[ss, m1, m2] -
      WangRbar11[ss, m1, m2] -
      WangRbar22[ss, m1, m2] +
      (ss - m1^2 - m2^2) WangRbar12[ss, m1, m2] -
      5/6 +
      2 Log[(m1^7 m2^7 ss)^(1/4)/lam] +
      2 (ss - m1^2 - m2^2)/root lW Log[lam/(m1 m2 ss)] -
      2 (ss - m1^2 - m2^2)/(3 root) lW -
      WangR12One[ss, m1, m2]
    );
  extra =
    (ss - (m1 + m2)^2)/(4 ss Pi^2) (lW (ss - m1^2 - m2^2) - root) +
    root/(16 ss Pi^2) WangR12Two[ss, m1, m2] (2 + (m1 + m2)^2/ss) -
    WangR0[ss, m1, m2]/Pi^2 +
    root^3/ss^2 (
      1/(12 Pi^2) (1 - (ss - m1^2 - m2^2)/root lW) -
      (m1 - m2) (WangF1Axial[ss, m1, m2] + WangF2Axial[ss, m1, m2])/(32 Pi^2)
    );
  4/3 (common + extra)
];

WangAALONormalizationRatio[ss_?NumericQ, params_: $BcMixingDefaultParameters] := Module[
  {rules = DynamicParameterRules[params], m1, m2, ours, wang},
  m1 = mb /. rules;
  m2 = mc /. rules;
  ours = N[AlphaSLOSpectralDensity["AA", ss] /. rules];
  wang = N[WangAxialLOSpectralDensity[ss, m1, m2]];
  ours/wang
];

Options[InstallWangAxialNLOAA] = {
  "MatchLONormalization" -> True,
  "ReferenceS" -> 40.0
};

(* Install the known axial-vector NLO density for AA.  By default we multiply
   Wang's rho_1 by the same constant that maps Wang's LO axial density to our
   projected AA LO density.  Numerically this ratio is 3 in our conventions. *)
InstallWangAxialNLOAA[OptionsPattern[]] := Module[
  {expr, norm = 1, ref = OptionValue["ReferenceS"]},
  If[TrueQ[OptionValue["MatchLONormalization"]],
    norm = WangAALONormalizationRatio[ref]
  ];
  expr = norm WangAxialNLOBareSpectralDensity[s, mb, mc];
  SetAlphaSNLOSpectralDensity["AA", expr, s]
];

WangAxialNLOValidationPoint[
  ss_?NumericQ,
  params_: $BcMixingDefaultParameters
] := Module[
  {rules = DynamicParameterRules[params], m1, m2},
  m1 = mb /. rules;
  m2 = mc /. rules;
  <|
    "s" -> ss,
    "Threshold" -> N[(m1 + m2)^2],
    "LOOurAA" -> N[AlphaSLOSpectralDensity["AA", ss] /. rules],
    "LOWangA" -> N[WangAxialLOSpectralDensity[ss, m1, m2]],
    "LORatioOurOverWang" -> WangAALONormalizationRatio[ss, params],
    "NLOBareWangA" -> N[WangAxialNLOBareSpectralDensity[ss, m1, m2]],
    "NLOBareMatchedToOurAA" ->
      N[WangAALONormalizationRatio[ss, params] WangAxialNLOBareSpectralDensity[ss, m1, m2]],
    "RelativeAlphaSShiftDensity" ->
      N[(MergeDefaultParameters[params]["alphaS"]/Pi) *
        WangAxialNLOBareSpectralDensity[ss, m1, m2]/
        WangAxialLOSpectralDensity[ss, m1, m2]]
  |>
];

(* ---------------------------------------------------------------------- *)
(* Derivation checklist and symbolic ingredients                           *)
(* ---------------------------------------------------------------------- *)

AlphaSNLOStatus[] := <|
  "Goal" -> "Derive rho_1^AA, rho_1^AB and rho_1^BB for the perturbative spectral densities.",
  "CurrentState" -> <|
    "AA" -> If[
      AlphaSNLOSpectralDensityDefinedQ["AA"],
      "rho_1 installed",
      "independent finite evaluator is validated; install/export a tabulated rho_1 only after choosing the paper mass scheme"
    ],
    "AB" -> If[AlphaSNLOSpectralDensityDefinedQ["AB"], "rho_1 installed", "pending tensor-current derivation"],
    "BB" -> If[AlphaSNLOSpectralDensityDefinedQ["BB"], "rho_1 installed", "pending tensor-current derivation"]
  |>,
  "NeededPieces" -> {
    "choose and document the common-scale MSbar central scale and scale band for AA",
    "repeat the validated construction for AB",
    "repeat the validated construction for BB",
    "then propagate all three channel corrections to the mixing angle"
  },
  "RecommendedFirstCheck" ->
    "Run IndependentAARealEmissionSoftTheoremCheck, IndependentAAUVPoleCancellationCheck and IndependentAAIRPoleCancellationCheck before any finite scan.",
  "InstalledSoftware" -> <|
    "FeynCalc" -> TrueQ[ValueQ[$FeynCalcVersion]],
    "PackageX" -> Quiet@FindFile["X`"] =!= $Failed,
    "FeynHelpers" -> DirectoryQ[$BcAlphaSFeynHelpersDirectory] || Length[Names["*PaXEvaluate"]] > 0,
    "FeynArts" -> NameQ["FeynArts`CreateTopologies"]
  |>,
  "References" -> Join[$BcAlphaSReferences, $BcAlphaSIndependentReferences]
|>;

(* The next functions are intentionally explicit symbolic building blocks.
   They are not a completed NLO calculation.  They let us inspect the Dirac
   structures for real-emission and virtual-correction work in the same
   current convention used at LO. *)

ClearAll[q1, q2, glu, aCol, alphaG];

AlphaSCurrentVertex["A", lor_] := CurrentVertex["A", lor];
AlphaSCurrentVertex["B", lor_] := CurrentVertex["B", lor];

(* Real-gluon emission amplitude at the current insertion.  This is the
   numerator-level object corresponding to emission from either heavy line.
   Phase-space integration and Cutkosky cuts are not done here yet. *)
RealEmissionDiracChain[current_String, lor_, gluonLor_] := Module[
  {vertex = AlphaSCurrentVertex[current, lor]},
  GA[gluonLor] . (GS[q1] + GS[glu] + mc) . vertex +
    vertex . (-GS[q2] - GS[glu] + mb) . GA[gluonLor]
];

RealEmissionSquaredTrace[channel_String] := Module[
  {pair = $BcMixingChannels[ValidateAlphaSChannel[channel]]},
  EvaluateDiracTrace[
    RealEmissionDiracChain[pair[[1]], mu, alphaG] .
    RealEmissionDiracChain[pair[[2]], nu, alphaG]
  ]
];

VirtualCorrectionPlaceholder[channel_String] := (
  ValidateAlphaSChannel[channel];
  Message[BcMixingAlphaS::notimplemented, "VirtualCorrectionPlaceholder[" <> channel <> "]"];
  <|
    "Channel" -> channel,
    "Status" -> "pending",
    "Meaning" -> "one-gluon vertex plus wave-function/mass counterterms"
  |>
);

RealEmissionPlaceholder[channel_String] := (
  ValidateAlphaSChannel[channel];
  Message[BcMixingAlphaS::notimplemented, "RealEmissionPlaceholder[" <> channel <> "]"];
  <|
    "Channel" -> channel,
    "Status" -> "pending",
    "Meaning" -> "three-body cut q qbar gluon phase-space contribution"
  |>
);

(* A tiny self-test that does not require rho_1.  It confirms that the LO
   machinery was imported and that rho_0 can be integrated. *)
AlphaSWorkbenchSelfTest[] := <|
  "FeynCalcLoaded" -> TrueQ[ValueQ[$FeynCalcVersion]],
  "LOThetaPertDegM2_8_s0_54" -> NumericMixingAngleDegrees[8.0, 54.0, "pert"],
  "NLOInstalledChannels" -> Select[$BcAlphaSChannels, AlphaSNLOSpectralDensityDefinedQ]
|>;

Print["Loaded BcMixingAlphaS.wl. Run AlphaSWorkbenchSelfTest[] and AlphaSNLOStatus[]."];

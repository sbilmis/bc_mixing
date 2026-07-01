(* ::Package:: *)

(*  BcMixingDimension6Complete.wl

    Workbench for completing the dimension-6 gluon-condensate sector.

    The already implemented G3 contribution in BcMixingMomentum.wl and
    BcMixingCoordinateOPE.wl is the standard vacuum-averaged single-line
    heavy-quark propagator contribution,

      S_c^(G3) S_b^(0) + S_c^(0) S_b^(G3).

    The missing completion terms are cross-line open-field contractions,

      S_c^(GG,open) S_b^(G,open) + S_c^(G,open) S_b^(GG,open),

    followed by a triple-gluon vacuum average.  This file makes those pieces
    explicit and prevents the single-line G3 truncation from being confused
    with the complete dimension-6 result.
*)

ClearAll[
  D6CompleteOperatorInventory,
  D6CompleteMissingCrossLineOperators,
  D6TripleGluonTensor,
  D6TripleGluonVacuumAverage,
  D6TripleGluonTensorNormalizationCheck,
  D6OpenTwoGluonPropagatorTemplate,
  D6OpenTwoGluonPropagatorDerivationRecipe,
  D6OneLineG2CalibrationRequirement,
  D6FADCombine,
  D6MomentumDerivative,
  D6OpenInsertionOperator,
  D6OneGluonFromInsertion,
  D6OneGluonCalibrationResidual,
  D6OpenTwoGluonCandidate,
  D6OpenTwoGluonCandidateMetadata,
  D6ExpandedTerms,
  D6TermwiseMap,
  D6TripleGluonTensorFC,
  D6ProjectSpin1Fast,
  D6CrossLineSGGTerms,
  D6CrossLineTraceTerm,
  D6CrossLineTraceTerms,
  D6CrossLineTraceExpression,
  D6CrossLineTraceChunk,
  D6SaveCrossLineTraceChunk,
  D6LoadCrossLineTraceChunks,
  D6AssembleCrossLineTraceChunks,
  D6CrossLineLoopTermsFromExpression,
  D6FeynmanParameterizeLoopTerm,
  D6FeynmanParameterChunkFromExpression,
  D6SaveFeynmanParameterChunkFromAssembly,
  D6LoadFeynmanParameterChunks,
  D6AssembleFeynmanParameterChunks,
  D6CrossLineLoopIntegrand,
  D6CrossLineFeynmanParameterForm,
  D6CrossLineSimplexAmplitude,
  D6CrossLineBorelIntegrandExpression,
  D6NumericBorelPiCrossLine,
  D6NumericCrossLineSummary,
  D6CrossLineM2GridFile,
  D6ComputeCrossLineM2Grid,
  D6LoadCrossLineM2Grid,
  D6CompleteThetaFromMoments,
  D6CompleteThetaOrderM2DataFromGrid,
  D6CompleteThetaOrderM2PublicationPlotFromGrid,
  D6CrossLineCentralValue,
  D6CrossLineCentralSummary,
  D6CrossLineCentralAngleShift,
  D6CrossLineValidationStatus,
  D6InstallOpenTwoGluonPropagator,
  D6ClearOpenTwoGluonPropagator,
  D6OpenTwoGluonPropagatorInstalledQ,
  D6OpenTwoGluonPropagator,
  D6CrossLineReadyQ,
  D6CrossLineBorelMoment,
  D6CrossLineKernelTemplate,
  D6CompletionChecklist,
  D6CompletenessReport,
  D6PaperStatement
];

$D6CompleteNc = 3;
$D6CompleteLorentzDimension = 4;
$D6OpenTwoGluonPropagatorStore = <||>;

D6CompleteOperatorInventory[] := {
  <|
    "Dimension" -> 0,
    "Order" -> "pert",
    "OperatorProduct" -> "S_c^(0) S_b^(0)",
    "Status" -> "Implemented"
  |>,
  <|
    "Dimension" -> 4,
    "Order" -> "G2c",
    "OperatorProduct" -> "S_c^(G2) S_b^(0)",
    "Status" -> "Implemented"
  |>,
  <|
    "Dimension" -> 4,
    "Order" -> "G2b",
    "OperatorProduct" -> "S_c^(0) S_b^(G2)",
    "Status" -> "Implemented"
  |>,
  <|
    "Dimension" -> 4,
    "Order" -> "G2gg",
    "OperatorProduct" -> "S_c^(G,open) S_b^(G,open)",
    "VacuumAverage" -> HoldForm[
      VacuumAverage[g_s^2 G_A[alpha, beta] G_B[rho, sigma]]
    ],
    "Status" -> "Implemented"
  |>,
  <|
    "Dimension" -> 6,
    "Order" -> "G3c",
    "OperatorProduct" -> "S_c^(G3) S_b^(0)",
    "Status" -> "Implemented: standard single-line propagator"
  |>,
  <|
    "Dimension" -> 6,
    "Order" -> "G3b",
    "OperatorProduct" -> "S_c^(0) S_b^(G3)",
    "Status" -> "Implemented: standard single-line propagator"
  |>,
  <|
    "Dimension" -> 6,
    "Order" -> "G3cross-c2-b1",
    "OperatorProduct" -> "S_c^(GG,open) S_b^(G,open)",
    "VacuumAverage" -> HoldForm[
      VacuumAverage[
        g_s^3 G_A[alpha, beta] G_B[lambda, tau] G_C[rho, sigma]
      ]
    ],
    "Status" -> "Missing: needs open two-gluon heavy-quark propagator"
  |>,
  <|
    "Dimension" -> 6,
    "Order" -> "G3cross-c1-b2",
    "OperatorProduct" -> "S_c^(G,open) S_b^(GG,open)",
    "VacuumAverage" -> HoldForm[
      VacuumAverage[
        g_s^3 G_A[alpha, beta] G_B[rho, sigma] G_C[lambda, tau]
      ]
    ],
    "Status" -> "Missing: needs open two-gluon heavy-quark propagator"
  |>,
  <|
    "Dimension" -> 8,
    "Order" -> "G4cross-c2-b2",
    "OperatorProduct" -> "S_c^(GG,open) S_b^(GG,open)",
    "VacuumAverage" -> HoldForm[
      VacuumAverage[
        g_s^4 G_A[alpha, beta] G_B[lambda, tau]
          G_C[rho, sigma] G_D[eta, zeta]
      ]
    ],
    "Status" -> "Not part of dimension-6. This is dimension-8, usually modeled as <G2>^2 or neglected."
  |>
};

D6CompleteMissingCrossLineOperators[] :=
  Select[D6CompleteOperatorInventory[], #["Dimension"] == 6 && StringStartsQ[#["Order"], "G3cross"] &];

(* Antisymmetric Lorentz tensor for
   <G_A^{alpha beta} G_B^{rho sigma} G_C^{lambda tau}>.
   It is normalized below by requiring
   f^{ABC}<G_A^{mu nu} G_B^{nu rho} G_C^{rho mu}> = <G^3>. *)
D6TripleGluonTensor[alpha_, beta_, rho_, sigma_, lambda_, tau_] :=
  g[alpha, rho] (g[beta, lambda] g[sigma, tau] - g[beta, tau] g[sigma, lambda])
  - g[alpha, sigma] (g[beta, lambda] g[rho, tau] - g[beta, tau] g[rho, lambda])
  - g[beta, rho] (g[alpha, lambda] g[sigma, tau] - g[alpha, tau] g[sigma, lambda])
  + g[beta, sigma] (g[alpha, lambda] g[rho, tau] - g[alpha, tau] g[rho, lambda]);

D6TripleGluonVacuumAverage[
  colorA_: A,
  alpha_: alpha,
  beta_: beta,
  colorB_: B,
  rho_: rho,
  sigma_: sigma,
  colorC_: C,
  lambda_: lambda,
  tau_: tau
] :=
  HoldForm[
    VacuumAverage[
      g_s^3 G[colorA, alpha, beta] G[colorB, rho, sigma] G[colorC, lambda, tau]
    ] ==
      f[colorA, colorB, colorC] G3/576
        D6TripleGluonTensor[alpha, beta, rho, sigma, lambda, tau]
  ];

D6TripleGluonTensorNormalizationCheck[] := <|
  "LorentzContraction" -> HoldForm[
    D6TripleGluonTensor[mu, nu, nu, rho, rho, mu] == 24
  ],
  "ColorContractionSU3" -> HoldForm[f[A, B, C] f[A, B, C] == 24],
  "CandidateCoefficient" -> HoldForm[1/(24 24) == 1/576],
  "NormalizationCondition" -> HoldForm[
    f[A, B, C] VacuumAverage[
      g_s^3 G[A, mu, nu] G[B, nu, rho] G[C, rho, mu]
    ] == G3
  ],
  "Status" -> "Candidate tensor. Check signs and index order against the chosen G3 definition before numerical use."
|>;

D6OpenTwoGluonPropagatorTemplate[line_String : "Q"] := <|
  "NeededObject" -> "Open two-gluon heavy-quark propagator in momentum or coordinate space",
  "SymbolicForm" -> "S_Q^(GG,open)(q,m; A,alpha,beta; B,lambda,tau)",
  "MustInclude" -> {
    "ordered color matrices T^A T^B and T^B T^A, or the equivalent commutator/anticommutator basis",
    "all Lorentz structures antisymmetric in each gluon field-strength pair",
    "the denominator powers generated by the two background-field insertions",
    "the convention matching the already implemented one-gluon propagator S^(G)"
  },
  "NotAvailableFrom" -> "The vacuum-averaged S^(G2) term alone. It has already contracted two gluons on one line and cannot be unaveraged uniquely."
|>;

D6OpenTwoGluonPropagatorDerivationRecipe[] := <|
  "Gauge" -> "Fixed-point/Fock-Schwinger gauge, x.A(x)=0",
  "BackgroundFieldExpansion" -> {
    "Write A_mu^A(y) = (1/2) y^alpha G_{alpha mu}^A(0) + ... for constant local field strength.",
    "In momentum space y^alpha acts as i d/dk_alpha.",
    "Use the recursive expansion S = S0 + S1 + S2 + ... of (gamma.Pi-m) S = 1.",
    "Choose the insertion normalization so that S1 exactly reproduces the one-gluon propagator SGNum[q,m,alpha,beta] SGDen[q,m] used in BcMixingMomentum.wl.",
    "Apply the same calibrated insertion once more to S1, keeping the color order T^A T^B and T^B T^A explicit.",
    "Only after this step contract S2(open) with S1(open) on the other line using the triple-gluon vacuum average."
  },
  "WhyCalibrationIsMandatory" ->
    "Different sign conventions for the covariant derivative, Fourier transform and field-strength tensor shift signs and factors of I. Reproducing the known averaged S^(G2) term is the local check that fixes those conventions.",
  "OneLineCheck" -> "Vacuum-average the two open gluons inside S_Q^(GG,open). The result must reproduce the already implemented SG2Prefactor[] SG2Num[q,m] SG2Den[q,m]."
|>;

D6OneLineG2CalibrationRequirement[] := <|
  "KnownTargetInMomentumFile" ->
    "SG2Prefactor[] SG2Num[q,m] SG2Den[q,m] = (G2/12) m (q^2 + m qslash)/(q^2-m^2)^4",
  "OpenObjectToCheck" ->
    "Contract S_Q^(GG,open)(q,m;A,alpha,beta;B,rho,sigma) with <g_s^2 G_A^{alpha beta} G_B^{rho sigma}>.",
  "RequiredPassCondition" ->
    "The contracted result equals the known target in the same phase and metric convention used by BcMixingMomentum.wl.",
  "Consequence" ->
    "If this check fails, G3cross cannot be used numerically. If it passes, the same S_Q^(GG,open) can be used in S^(GG)S^(G)+S^(G)S^(GG)."
|>;

(* ---------------------------------------------------------------------- *)
(* Experimental fixed-point-gauge insertion algebra                         *)
(* ---------------------------------------------------------------------- *)

D6FADCombine[expr_] := FixedPoint[
  Expand[#] //. {
    FAD[a___] FAD[b___] :> FAD[a, b],
    Power[FAD[a___], n_Integer?Positive] :>
      Apply[FAD, Flatten[ConstantArray[{a}, n], 1]]
  } &,
  expr
];

D6MomentumDerivative[expr_Plus, q_, idx_] :=
  Total[D6MomentumDerivative[#, q, idx] & /@ (List @@ expr)];

D6MomentumDerivative[c_?NumericQ, q_, idx_] := 0;

D6MomentumDerivative[s_Symbol, q_, idx_] := 0;

D6MomentumDerivative[GS[arg_], q_, idx_] :=
  If[arg === q, GA[idx], 0];

D6MomentumDerivative[GA[_], q_, idx_] := 0;

D6MomentumDerivative[DiracSigma[_, _], q_, idx_] := 0;

D6MomentumDerivative[FV[arg_, lor_], q_, idx_] :=
  If[arg === q, MT[lor, idx], 0];

D6MomentumDerivative[Pair[LorentzIndex[lor_], Momentum[arg_, ___]], q_, idx_] :=
  If[arg === q, MT[lor, idx], 0];

D6MomentumDerivative[Pair[Momentum[arg_, ___], LorentzIndex[lor_]], q_, idx_] :=
  If[arg === q, MT[lor, idx], 0];

D6MomentumDerivative[Pair[Momentum[arg_, ___], Momentum[arg_, ___]], q_, idx_] :=
  If[arg === q, 2 FV[arg, idx], 0];

D6MomentumDerivative[Pair[Momentum[arg_, ___], Momentum[other_, ___]], q_, idx_] :=
  If[arg === q, FV[other, idx], If[other === q, FV[arg, idx], 0]];

D6MomentumDerivative[FAD[args___], q_, idx_] := Module[
  {lst = {args}, n, first},
  n = Length[lst];
  first = If[n > 0, First[lst], Missing[]];
  If[
    n > 0 && AllTrue[lst, # === first &] && MatchQ[first, {q, _}],
    -2 n FV[q, idx] Apply[FAD, Append[lst, first]],
    0
  ]
];

D6MomentumDerivative[expr_, q_, idx_] /; Head[expr] === Times := Module[
  {lst = List @@ expr},
  Total[
    MapIndexed[
      D6MomentumDerivative[#1, q, idx] Times @@ Delete[lst, First[#2]] &,
      lst
    ]
  ]
];

D6MomentumDerivative[expr_, q_, idx_] /; Head[expr] === Dot := Module[
  {lst = List @@ expr},
  Total[
    MapIndexed[
      Dot @@ ReplacePart[lst, First[#2] -> D6MomentumDerivative[#1, q, idx]] &,
      lst
    ]
  ]
];

D6MomentumDerivative[expr_, q_, idx_] /; FreeQ[Unevaluated[expr], q] := 0;

D6MomentumDerivative[expr_, q_, idx_] :=
  Failure[
    "UnhandledMomentumDerivative",
    <|
      "Expression" -> HoldForm[expr],
      "Momentum" -> q,
      "Index" -> idx
    |>
  ];

D6OpenInsertionOperator[
  expr_,
  q_,
  m_,
  alpha_,
  beta_,
  coefficient_: Cins
] :=
  D6FADCombine[
    coefficient (GS[q] + m) . GA[beta] .
      D6MomentumDerivative[expr, q, alpha] FAD[{q, m}]
  ];

D6OneGluonFromInsertion[
  q_: k,
  m_: mc,
  alpha_: al,
  beta_: be,
  coefficient_: Cins
] := Module[
  {s0, raw},
  s0 = Expand[(GS[q] + m) FAD[{q, m}]];
  raw = D6OpenInsertionOperator[s0, q, m, alpha, beta, coefficient];
  D6FADCombine[(raw - (raw /. {alpha -> beta, beta -> alpha}))/2]
];

D6OneGluonCalibrationResidual[
  q_: k,
  m_: mc,
  alpha_: al,
  beta_: be,
  coefficient_: Cins
] := Module[
  {generated, target},
  generated = D6OneGluonFromInsertion[q, m, alpha, beta, coefficient];
  target = SGNum[q, m, alpha, beta] SGDen[q, m];
  D6FADCombine[generated - target]
];

D6OpenTwoGluonCandidate[
  q_: k,
  m_: mc,
  alpha_: al,
  beta_: be,
  rho_: rh,
  sigma_: si,
  coefficient_: Cins
] := Module[
  {s1, ordered12, ordered21},
  s1 = D6OneGluonFromInsertion[q, m, alpha, beta, coefficient];
  ordered12 = D6OpenInsertionOperator[s1, q, m, rho, sigma, coefficient];
  ordered21 = D6OpenInsertionOperator[
    D6OneGluonFromInsertion[q, m, rho, sigma, coefficient],
    q, m, alpha, beta, coefficient
  ];
  <|
    "Ordered12" -> D6FADCombine[ordered12],
    "Ordered21" -> D6FADCombine[ordered21],
    "SymmetricColorPart" -> D6FADCombine[(ordered12 + ordered21)/2],
    "AntisymmetricColorPart" -> D6FADCombine[(ordered12 - ordered21)/2]
  |>
];

D6OpenTwoGluonCandidateMetadata[] := <|
  "Status" -> "Experimental algebraic candidate, not yet paper-final.",
  "OneGluonCalibration" ->
    "D6OneGluonCalibrationResidual must vanish after fixing Cins and simplifying in the same Dirac/FAD convention as BcMixingMomentum.wl.",
  "G2Calibration" ->
    "The symmetric color part must reproduce the implemented SG2 term after the <G G> vacuum average.",
  "G3CrossUse" ->
    "Only the antisymmetric color part contributes to f^{ABC}<G_A G_B G_C>. It is not fixed by the same-line G2 calibration alone."
|>;

D6ExpandedTerms[expr_] :=
  List @@ Expand[DotSimplify[Expand[expr]]];

D6TermwiseMap[f_, expr_, timeLimit_: 20] := Module[
  {terms = D6ExpandedTerms[expr]},
  MapIndexed[
    <|
      "Index" -> First[#2],
      "Input" -> #1,
      "Output" -> TimeConstrained[f[#1], timeLimit, $TimedOut]
    |>&,
    terms
  ]
];

D6TripleGluonTensorFC[alpha_, beta_, rho_, sigma_, lambda_, tau_] :=
  MT[alpha, rho] (MT[beta, lambda] MT[sigma, tau] - MT[beta, tau] MT[sigma, lambda])
  - MT[alpha, sigma] (MT[beta, lambda] MT[rho, tau] - MT[beta, tau] MT[rho, lambda])
  - MT[beta, rho] (MT[alpha, lambda] MT[sigma, tau] - MT[alpha, tau] MT[sigma, lambda])
  + MT[beta, sigma] (MT[alpha, lambda] MT[rho, tau] - MT[alpha, tau] MT[rho, lambda]);

D6ProjectSpin1Fast[expr_] := Module[
  {projector},
  projector = (MT[mu, nu] - FV[p, mu] FV[p, nu]/SP[p, p]);
  Contract[projector expr] // FCE // Contract
];

D6CrossLineSGGTerms[
  which_String : "c2b1",
  coefficient_: -I/2
] := Module[
  {qc = k, qb = k - p, sgg},
  sgg = Switch[
    which,
    "c2b1",
      D6OpenTwoGluonCandidate[qc, mc, al, be, la, ta, coefficient]["AntisymmetricColorPart"],
    "c1b2",
      D6OpenTwoGluonCandidate[qb, mb, rh, si, la, ta, coefficient]["AntisymmetricColorPart"],
    _,
      Return[Failure["BadCrossLineSide", <|"Side" -> which|>]]
  ];
  D6ExpandedTerms[sgg]
];

D6CrossLineTraceTerm[
  channel_String,
  term_,
  which_String : "c2b1",
  projected_: True,
  projectionMode_: "Full"
] := Module[
  {qc = k, qb = k - p, trace, expr},
  trace = Switch[
    which,
    "c2b1",
      D6TripleGluonTensorFC[al, be, la, ta, rh, si]
        TraceForChannel[channel, term, SGNum[qb, mb, rh, si]]
        SGDen[qb, mb],
    "c1b2",
      D6TripleGluonTensorFC[al, be, rh, si, la, ta]
        TraceForChannel[channel, SGNum[qc, mc, al, be], term]
        SGDen[qc, mc],
    _,
      Failure["BadCrossLineSide", <|"Side" -> which|>]
  ];
  expr = D6FADCombine[I G3/48 trace];
  If[TrueQ[projected],
    expr = Switch[
      projectionMode,
      "Fast", D6ProjectSpin1Fast[expr],
      _, ProjectSpin1[expr]
    ],
    expr = expr // Contract // FCE // Simplify
  ];
  D6FADCombine[expr]
];

D6CrossLineTraceTerms[
  channel_String,
  which_String : "c2b1",
  coefficient_: -I/2,
  timeLimit_: 20,
  projected_: True,
  indices_: All,
  projectionMode_: "Full"
] := Module[
  {terms, selected},
  terms = D6CrossLineSGGTerms[which, coefficient];
  If[Head[terms] === Failure, Return[terms]];
  selected = If[indices === All, Range[Length[terms]], indices];
  Map[
    <|
      "Index" -> #,
      "Input" -> terms[[#]],
      "Output" -> TimeConstrained[
        D6CrossLineTraceTerm[channel, terms[[#]], which, projected, projectionMode],
        timeLimit,
        $TimedOut
      ]
    |>&,
    selected
  ]
];

D6CrossLineTraceExpression[
  channel_String,
  which_String : "c2b1",
  coefficient_: -I/2,
  shortTime_: 5,
  hardTime_: 60,
  projected_: True,
  projectionMode_: "Full"
] := Module[
  {first, timed, retry, byIndex, remaining, outputs},
  first = D6CrossLineTraceTerms[channel, which, coefficient, shortTime, projected, All, projectionMode];
  If[Head[first] === Failure, Return[first]];
  timed = Cases[first, a_Association /; a["Output"] === $TimedOut :> a["Index"]];
  retry = If[timed === {},
    {},
    D6CrossLineTraceTerms[channel, which, coefficient, hardTime, projected, timed, projectionMode]
  ];
  byIndex = Association[
    (#["Index"] -> #["Output"]) & /@ Join[
      Select[first, #["Output"] =!= $TimedOut &],
      Select[retry, #["Output"] =!= $TimedOut &]
    ]
  ];
  remaining = Complement[Range[Length[first]], Keys[byIndex]];
  outputs = Values[KeySort[byIndex]];
  <|
    "Channel" -> channel,
    "Side" -> which,
    "Coefficient" -> coefficient,
    "Projected" -> projected,
    "ProjectionMode" -> projectionMode,
    "TermCount" -> Length[first],
    "CompletedTermCount" -> Length[outputs],
    "TimedOutIndices" -> remaining,
    "Expression" -> If[remaining === {}, D6FADCombine[Total[outputs]], $Failed],
    "RawTerms" -> Join[first, retry]
  |>
];

D6CrossLineTraceChunk[
  channel_String,
  which_String,
  indices_List,
  coefficient_: -I/2,
  timeLimit_: 60,
  projected_: True,
  projectionMode_: "Fast"
] := <|
  "Channel" -> channel,
  "Side" -> which,
  "Indices" -> indices,
  "Coefficient" -> coefficient,
  "Projected" -> projected,
  "ProjectionMode" -> projectionMode,
  "TimeLimit" -> timeLimit,
  "GeneratedAt" -> DateString[{"Year", "-", "Month", "-", "Day", " ", "Hour", ":", "Minute", ":", "Second"}],
  "Results" -> D6CrossLineTraceTerms[
    channel,
    which,
    coefficient,
    timeLimit,
    projected,
    indices,
    projectionMode
  ]
|>;

D6SaveCrossLineTraceChunk[
  file_String,
  channel_String,
  which_String,
  indices_List,
  coefficient_: -I/2,
  timeLimit_: 60,
  projected_: True,
  projectionMode_: "Fast"
] := Module[
  {chunk},
  chunk = D6CrossLineTraceChunk[
    channel,
    which,
    indices,
    coefficient,
    timeLimit,
    projected,
    projectionMode
  ];
  Put[chunk, file];
  chunk
];

D6LoadCrossLineTraceChunks[files_List] := Get /@ files;

D6AssembleCrossLineTraceChunks[
  chunks_List,
  totalTerms_: Automatic
] := Module[
  {rows, completed, byIndex, termCount, missing, outputs},
  rows = Flatten[Lookup[chunks, "Results", {}]];
  completed = Select[rows, AssociationQ[#] && #["Output"] =!= $TimedOut &];
  byIndex = Association[(#["Index"] -> #["Output"]) & /@ completed];
  termCount = Replace[
    totalTerms,
    Automatic :> Max[Join[{0}, Lookup[rows, "Index", {}]]]
  ];
  missing = Complement[Range[termCount], Keys[byIndex]];
  outputs = Values[KeySort[byIndex]];
  <|
    "CompletedTermCount" -> Length[outputs],
    "TermCount" -> termCount,
    "MissingIndices" -> missing,
    "Expression" -> If[missing === {}, D6FADCombine[Total[outputs]], $Failed],
    "Rows" -> rows
  |>
];

D6CrossLineLoopTermsFromExpression[
  expr_,
  inv_: s
] := Module[
  {converted, expanded, terms},
  converted = ChangeDimension[expr, D] /. {
    SPD[p, p] -> inv,
    SPD[p] -> inv,
    Pair[Momentum[p, D], Momentum[p, D]] -> inv
  };
  expanded = Expand[converted];
  terms = If[Head[expanded] === Plus, List @@ expanded, {expanded}];
  Select[terms, FreeQ[FCI[#], FeynAmpDenominator] === False &]
];

D6FeynmanParameterizeLoopTerm[
  term_,
  inv_: s,
  ep_: eps,
  head_: x,
  prefactor_: "Textbook"
] := FCFeynmanParametrize[
  term,
  {k},
  Names -> head,
  FeynmanIntegralPrefactor -> prefactor,
  FinalSubstitutions -> {
    SPD[p, p] -> inv,
    SPD[p] -> inv,
    Pair[Momentum[p, D], Momentum[p, D]] -> inv
  },
  FCReplaceD -> {D -> 4 - 2 ep}
];

D6FeynmanParameterChunkFromExpression[
  expr_,
  indices_List,
  timeLimit_: 60,
  inv_: s,
  ep_: eps,
  head_: x,
  prefactor_: "Textbook"
] := Module[
  {terms = D6CrossLineLoopTermsFromExpression[expr, inv]},
  <|
    "Indices" -> indices,
    "TermCount" -> Length[terms],
    "TimeLimit" -> timeLimit,
    "GeneratedAt" -> DateString[{"Year", "-", "Month", "-", "Day", " ", "Hour", ":", "Minute", ":", "Second"}],
    "Results" -> Map[
      <|
        "Index" -> #,
        "Output" -> TimeConstrained[
          D6FeynmanParameterizeLoopTerm[terms[[#]], inv, ep, head, prefactor],
          timeLimit,
          $TimedOut
        ]
      |>&,
      indices
    ]
  |>
];

D6SaveFeynmanParameterChunkFromAssembly[
  file_String,
  assemblyFile_String,
  indices_List,
  timeLimit_: 60,
  inv_: s,
  ep_: eps,
  head_: x,
  prefactor_: "Textbook"
] := Module[
  {assembly, chunk},
  assembly = Get[assemblyFile];
  chunk = D6FeynmanParameterChunkFromExpression[
    assembly["Expression"],
    indices,
    timeLimit,
    inv,
    ep,
    head,
    prefactor
  ];
  Put[chunk, file];
  chunk
];

D6LoadFeynmanParameterChunks[files_List] := Get /@ files;

D6AssembleFeynmanParameterChunks[
  chunks_List,
  totalTerms_: Automatic
] := Module[
  {rows, completed, byIndex, termCount, missing, outputs},
  rows = Flatten[Lookup[chunks, "Results", {}]];
  completed = Select[rows, AssociationQ[#] && #["Output"] =!= $TimedOut &];
  byIndex = Association[(#["Index"] -> #["Output"]) & /@ completed];
  termCount = Replace[
    totalTerms,
    Automatic :> Max[Join[{0}, Lookup[rows, "Index", {}]]]
  ];
  missing = Complement[Range[termCount], Keys[byIndex]];
  outputs = Values[KeySort[byIndex]];
  <|
    "CompletedTermCount" -> Length[outputs],
    "TermCount" -> termCount,
    "MissingIndices" -> missing,
    "FeynmanParameterTerms" -> If[missing === {}, outputs, $Failed],
    "Rows" -> rows
  |>
];

Options[D6CrossLineLoopIntegrand] = {
  "Coefficient" -> -I/2,
  "ShortTimeLimit" -> 5,
  "HardTimeLimit" -> 60,
  "Projected" -> True,
  "ProjectionMode" -> "Full"
};

D6CrossLineLoopIntegrand[
  channel_String,
  which_String,
  OptionsPattern[]
] := D6CrossLineLoopIntegrand[
  channel,
  which,
  OptionValue["Coefficient"],
    OptionValue["ShortTimeLimit"],
    OptionValue["HardTimeLimit"],
    OptionValue["Projected"],
    OptionValue["ProjectionMode"]
] = Module[
  {result},
  result = D6CrossLineTraceExpression[
    channel,
    which,
    OptionValue["Coefficient"],
    OptionValue["ShortTimeLimit"],
    OptionValue["HardTimeLimit"],
    OptionValue["Projected"],
    OptionValue["ProjectionMode"]
  ];
  If[result["TimedOutIndices"] === {},
    result["Expression"],
    Failure[
      "CrossLineTraceTimedOut",
      <|
        "Channel" -> channel,
        "Side" -> which,
        "TimedOutIndices" -> result["TimedOutIndices"],
        "CompletedTermCount" -> result["CompletedTermCount"],
        "TermCount" -> result["TermCount"]
      |>
    ]
  ]
];

D6CrossLineLoopIntegrand[
  channel_String,
  "G3cross",
  opts : OptionsPattern[]
] := Module[
  {left, right},
  left = D6CrossLineLoopIntegrand[channel, "c2b1", opts];
  right = D6CrossLineLoopIntegrand[channel, "c1b2", opts];
  If[Head[left] === Failure || Head[right] === Failure,
    Failure["CrossLineTraceFailed", <|"c2b1" -> left, "c1b2" -> right|>],
    D6FADCombine[left + right]
  ]
];

Options[D6CrossLineFeynmanParameterForm] = {
  "Coefficient" -> -I/2,
  "ShortTimeLimit" -> 5,
  "HardTimeLimit" -> 60,
  "InvariantSymbol" -> s,
  "EpsilonSymbol" -> eps,
  "FeynmanParameterHead" -> x,
  "FeynmanIntegralPrefactor" -> "Textbook",
  "ProjectionMode" -> "Full"
};

D6CrossLineFeynmanParameterForm[
  channel_String,
  which_String : "G3cross",
  opts : OptionsPattern[]
] := D6CrossLineFeynmanParameterForm[channel, which] = Module[
  {expr, inv, ep, head, expanded, terms, loopTerms},
  inv = OptionValue["InvariantSymbol"];
  ep = OptionValue["EpsilonSymbol"];
  head = OptionValue["FeynmanParameterHead"];
  expr = D6CrossLineLoopIntegrand[
    channel,
    which,
    "Coefficient" -> OptionValue["Coefficient"],
    "ShortTimeLimit" -> OptionValue["ShortTimeLimit"],
    "HardTimeLimit" -> OptionValue["HardTimeLimit"],
    "Projected" -> True,
    "ProjectionMode" -> OptionValue["ProjectionMode"]
  ];
  If[Head[expr] === Failure, Return[expr]];
  expr = ChangeDimension[expr, D] /. {
    SPD[p, p] -> inv,
    SPD[p] -> inv,
    Pair[Momentum[p, D], Momentum[p, D]] -> inv
  };
  expanded = Expand[expr];
  terms = If[Head[expanded] === Plus, List @@ expanded, {expanded}];
  loopTerms = Select[terms, ! FreeQ[FCI[#], FeynAmpDenominator] &];
  FCFeynmanParametrize[
    #,
    {k},
    Names -> head,
    FeynmanIntegralPrefactor -> OptionValue["FeynmanIntegralPrefactor"],
    FinalSubstitutions -> {
      SPD[p, p] -> inv,
      SPD[p] -> inv,
      Pair[Momentum[p, D], Momentum[p, D]] -> inv
    },
    FCReplaceD -> {D -> 4 - 2 ep}
  ] & /@ loopTerms
];

D6CrossLineSimplexAmplitude[
  channel_String,
  which_String : "G3cross",
  xvar_: xi
] := D6CrossLineSimplexAmplitude[channel, which] = Module[
  {terms},
  terms = D6CrossLineFeynmanParameterForm[channel, which] /. eps -> 0;
  If[Head[terms] === Failure, Return[terms]];
  terms = Select[
    terms,
    #[[1]] =!= 0 && FreeQ[#, ComplexInfinity | Indeterminate | DirectedInfinity] &
  ];
  $BcMixingDirectBorelPhase Total[(#[[1]] #[[2]]) & /@ terms] /.
    {x[1] -> xvar, x[2] -> 1 - xvar} // Together // Simplify
];

D6CrossLineBorelIntegrandExpression[
  channel_String,
  which_String : "G3cross"
] := D6CrossLineBorelIntegrandExpression[channel, which] = Module[
  {amp},
  amp = D6CrossLineSimplexAmplitude[channel, which, xi];
  If[Head[amp] === Failure,
    amp,
    BorelTransformQ2[amp, xi, M2]
  ]
];

Options[D6NumericBorelPiCrossLine] = Options[NIntegrate];

D6NumericBorelPiCrossLine[
  channel_String,
  m2Val_?NumericQ,
  continuumVal_?NumericQ,
  params_: $BcMixingDefaultParameters,
  which_String : "G3cross",
  opts : OptionsPattern[]
] := Module[
  {lims, integrand},
  ValidateChannel[channel];
  lims = ContinuumXLimits[continuumVal, params];
  If[lims === $Failed, Return[0.]];
  integrand = D6CrossLineBorelIntegrandExpression[channel, which];
  If[Head[integrand] === Failure, Return[integrand]];
  integrand = Evaluate[
    integrand /.
      DynamicParameterRules[params] /.
      M2 -> m2Val
  ];
  NIntegrate[integrand, {xi, lims[[1]], lims[[2]]}, opts]
];

D6NumericCrossLineSummary[
  m2Val_?NumericQ,
  continuumVal_?NumericQ,
  params_: $BcMixingDefaultParameters,
  opts : OptionsPattern[D6NumericBorelPiCrossLine]
] := AssociationMap[
  D6NumericBorelPiCrossLine[#, m2Val, continuumVal, params, "G3cross", opts] &,
  {"AA", "AB", "BB"}
];

D6CrossLineM2GridFile[
  continuumVal_?NumericQ,
  nPoints_Integer,
  cacheDirectory_String : "d6_chunks"
] := FileNameJoin[
  {
    cacheDirectory,
    "G3cross_M2Grid_s0_" <>
      StringReplace[ToString[N[continuumVal], InputForm], "." -> "p"] <>
      "_n" <> ToString[nPoints] <> ".wl"
  }
];

Options[D6ComputeCrossLineM2Grid] = Join[
  Options[D6NumericBorelPiCrossLine],
  {
    "NPoints" -> 9,
    "CacheDirectory" -> "d6_chunks",
    "Overwrite" -> False,
    "Progress" -> True
  }
];

D6ComputeCrossLineM2Grid[
  m2Range : {_?NumericQ, _?NumericQ} : $BcMixingWangWindow["M2Range"],
  continuumVal_?NumericQ,
  params_: $BcMixingDefaultParameters,
  opts : OptionsPattern[]
] := Module[
  {nPoints = Max[2, Round[OptionValue["NPoints"]]], cacheDirectory,
   overwrite = TrueQ[OptionValue["Overwrite"]], progress = TrueQ[OptionValue["Progress"]],
   file, m2Values, numericOpts, existing, records},
  cacheDirectory = OptionValue["CacheDirectory"];
  If[! DirectoryQ[cacheDirectory],
    CreateDirectory[cacheDirectory, CreateIntermediateDirectories -> True]
  ];
  file = D6CrossLineM2GridFile[continuumVal, nPoints, cacheDirectory];
  If[FileExistsQ[file] && ! overwrite,
    Return[Get[file]]
  ];
  m2Values = N[Subdivide[m2Range[[1]], m2Range[[2]], nPoints - 1]];
  numericOpts = FilterRules[{opts}, Options[D6NumericBorelPiCrossLine]];
  existing = If[FileExistsQ[file], Quiet[Check[Get[file], <||>]], <||>];
  records = Association[Lookup[existing, "Records", {}]];
  Do[
    If[! KeyExistsQ[records, m2v],
      If[progress, Print["Computing G3cross grid point M2 = ", m2v, ", s0 = ", continuumVal]];
      records[m2v] = D6NumericCrossLineSummary[
        m2v,
        continuumVal,
        params,
        Sequence @@ numericOpts
      ];
      Put[
        <|
          "Type" -> "D6CrossLineM2Grid",
          "Order" -> "G3cross",
          "M2Range" -> N[m2Range],
          "s0" -> N[continuumVal],
          "NPoints" -> nPoints,
          "M2Values" -> m2Values,
          "ParameterSnapshot" -> params,
          "Records" -> Normal[records],
          "UpdatedAt" -> DateString[{"Year", "-", "Month", "-", "Day", " ", "Hour", ":", "Minute", ":", "Second"}]
        |>,
        file
      ];
    ],
    {m2v, m2Values}
  ];
  Get[file]
];

D6LoadCrossLineM2Grid[
  continuumVal_?NumericQ,
  nPoints_Integer,
  cacheDirectory_String : "d6_chunks"
] := Module[
  {file = D6CrossLineM2GridFile[continuumVal, nPoints, cacheDirectory]},
  If[FileExistsQ[file], Get[file], Missing["NoGridCache", file]]
];

D6CompleteThetaFromMoments[
  baseMoments_Association,
  crossMoments_Association
] := Module[
  {full},
  If[! AllTrue[Lookup[crossMoments, {"AA", "AB", "BB"}, Missing[]], NumericQ],
    Return[Missing["IncompleteCrossLineMoments", crossMoments]]
  ];
  full = AssociationMap[baseMoments[#] + crossMoments[#] &, {"AA", "AB", "BB"}];
  1/2 ArcTan[full["AA"] - full["BB"], -2 full["AB"]] 180/Pi
];

D6CompleteThetaOrderM2DataFromGrid[
  grid_Association,
  params_: $BcMixingDefaultParameters,
  opts : OptionsPattern[NumericBorelPi]
] := Module[
  {records, m2Values, continuumVal, numericOpts, baseSummaries},
  records = Association[Lookup[grid, "Records", <||>]];
  If[records === <||>, Return[Failure["EmptyCrossLineGrid", <|"Grid" -> grid|>]]];
  m2Values = N @ Lookup[grid, "M2Values", Keys[records]];
  continuumVal = Lookup[grid, "s0", Missing["s0"]];
  If[! NumericQ[continuumVal], Return[Failure["MissingContinuum", <|"Grid" -> grid|>]]];
  numericOpts = FilterRules[{opts}, Options[NumericBorelPi]];
  baseSummaries = AssociationMap[
    NumericOPESummary[#, continuumVal, params, Sequence @@ numericOpts] &,
    m2Values
  ];
  <|
    "pert" -> ({#, MixingAngleDegreesFromSummary[baseSummaries[#], "pert"]} & /@ m2Values),
    "pertG2" -> ({#, MixingAngleDegreesFromSummary[baseSummaries[#], "pertG2"]} & /@ m2Values),
    "total" -> ({#, MixingAngleDegreesFromSummary[baseSummaries[#], "total"]} & /@ m2Values),
    "totalCompleteD6" -> Table[
      {
        m2v,
        D6CompleteThetaFromMoments[
          AssociationMap[baseSummaries[m2v][#]["total"] &, {"AA", "AB", "BB"}],
          Association[records[m2v]]
        ]
      },
      {m2v, m2Values}
    ]
  |>
];

MixingAngleOrderLabel["totalCompleteD6"] :=
  "\[Theta] pert + G2 + G3 + G3 cross";

D6CompleteThetaOrderM2PublicationPlotFromGrid[
  grid_Association,
  opts : OptionsPattern[MixingAngleOrderM2PublicationPlotFromData]
] := D6CompleteThetaOrderM2PublicationPlotFromGrid[
  grid,
  $BcMixingDefaultParameters,
  opts
];

D6CompleteThetaOrderM2PublicationPlotFromGrid[
  grid_Association,
  params_: $BcMixingDefaultParameters,
  opts : OptionsPattern[MixingAngleOrderM2PublicationPlotFromData]
] := Module[
  {data, m2Range, continuumVal},
  data = D6CompleteThetaOrderM2DataFromGrid[
    grid,
    params,
    Sequence @@ FilterRules[{opts}, Options[NumericBorelPi]]
  ];
  If[Head[data] === Failure, Return[data]];
  m2Range = Lookup[grid, "M2Range", {Min[Keys[Association[grid["Records"]]]], Max[Keys[Association[grid["Records"]]]]}];
  continuumVal = grid["s0"];
  MixingAngleOrderM2PublicationPlotFromData[
    data,
    m2Range,
    continuumVal,
    Sequence @@ FilterRules[{opts}, Options[MixingAngleOrderM2PublicationPlotFromData]]
  ]
];

D6CrossLineCentralValue[
  channel_String,
  side_String,
  cacheDirectory_String : "d6_chunks"
] := Module[
  {file, record},
  file = FileNameJoin[{cacheDirectory, channel <> "_" <> side <> "_fast_central_value.wl"}];
  If[! FileExistsQ[file], Return[Missing["NotComputed", file]]];
  record = Get[file];
  record["Value"]
];

D6CrossLineCentralSummary[
  cacheDirectory_String : "d6_chunks"
] := AssociationMap[
  With[
    {
      c2b1 = D6CrossLineCentralValue[#, "c2b1", cacheDirectory],
      c1b2 = D6CrossLineCentralValue[#, "c1b2", cacheDirectory]
    },
    <|
      "c2b1" -> c2b1,
      "c1b2" -> c1b2,
      "sum" -> If[NumericQ[c2b1] && NumericQ[c1b2], c2b1 + c1b2, Missing["Incomplete"]]
    |>
  ]&,
  {"AA", "AB", "BB"}
];

D6CrossLineCentralAngleShift[] :=
  D6CrossLineCentralAngleShift[8., 54., $BcMixingDefaultParameters, "d6_chunks"];

D6CrossLineCentralAngleShift[
  m2Val_?NumericQ,
  continuumVal_?NumericQ,
  params_: $BcMixingDefaultParameters,
  cacheDirectory_String : "d6_chunks"
] := Module[
  {cross, summary, base, full, thetaBase, thetaFull},
  cross = AssociationMap[D6CrossLineCentralSummary[cacheDirectory][#]["sum"] &, {"AA", "AB", "BB"}];
  If[! AllTrue[Values[cross], NumericQ],
    Return[Failure["IncompleteCrossLineCache", <|"CrossLine" -> cross|>]]
  ];
  summary = NumericOPESummary[m2Val, continuumVal, params];
  base = AssociationMap[summary[#]["total"] &, {"AA", "AB", "BB"}];
  full = Merge[{base, cross}, Total];
  thetaBase = MixingAngleDegreesFromSummary[summary, "total"];
  thetaFull = 1/2 ArcTan[full["AA"] - full["BB"], -2 full["AB"]] 180/Pi;
  <|
    "M2" -> m2Val,
    "s0" -> continuumVal,
    "BaseMoments" -> base,
    "CrossLineMoments" -> cross,
    "CompleteMoments" -> full,
    "ThetaSingleLineG3Deg" -> thetaBase,
    "ThetaWithCrossLineDeg" -> thetaFull,
    "DeltaThetaDeg" -> thetaFull - thetaBase,
    "CrossLineOverBase" -> AssociationMap[cross[#]/base[#] &, {"AA", "AB", "BB"}]
  |>
];

D6CrossLineValidationStatus[] := <|
  "Status" -> "Experimental workbench implemented; not yet paper-final.",
  "ImplementedPieces" -> {
    "fixed-point-gauge derivative candidate for S_Q^(GG,open)",
    "antisymmetric color component needed by f^{ABC}<G_A G_B G_C>",
    "termwise projected traces for S_c^(GG)S_b^(G) and S_c^(G)S_b^(GG)",
    "Feynman-parameter and direct-Borel hooks for cross-line moments"
  },
  "ValidatedInKernel" -> {
    "AA c2b1 projected trace completed with 152/152 terms",
    "AA c2b1 Feynman parameterization completed with 31 terms",
    "AA c2b1 central test at M2=8, s0=54 gave -1.6756975780964764*^-6",
    "AA c1b2 mirror trace completed with 152/152 cached fast-projection terms",
    "AA c1b2 Feynman parameterization completed with 79/79 cached terms",
    "AA c1b2 central test at M2=8, s0=54 gave 3.378713957299235*^-7",
    "AB c2b1 central test at M2=8, s0=54 gave 6.907526226109287*^-7",
    "AB c1b2 central test at M2=8, s0=54 gave 1.1921369599555478*^-7",
    "BB c2b1 central test at M2=8, s0=54 gave -1.168414043165516*^-6",
    "BB c1b2 central test at M2=8, s0=54 gave -7.557182424790687*^-7",
    "Representative fast-vs-full projection checks for AA c1b2 terms {1,5,23} returned True",
    "Representative fast-vs-full projection checks for AB and BB terms returned True"
  },
  "StillPending" -> {
    "one-gluon calibration residual must be reduced to zero or explained by convention before paper use",
    "the final G3complete order is deliberately not connected to NumericBorelPi until the convention audit passes"
  },
  "SafeUsage" -> {
    "Use D6CrossLineCentralSummary[] to read the cached central cross-line moments.",
    "Use D6CrossLineCentralAngleShift[] to compare the cached central cross-line shift against the production total.",
    "Do not replace the existing momentum-space total by G3complete until D6CrossLineValidationStatus[] has no pending items."
  }
|>;

D6InstallOpenTwoGluonPropagator[
  name_String,
  expr_,
  metadata_Association : <||>
] := (
  $D6OpenTwoGluonPropagatorStore[name] = <|
    "Expression" -> HoldComplete[expr],
    "Metadata" -> metadata,
    "InstalledAt" -> DateString[{"Year", "-", "Month", "-", "Day", " ", "Hour", ":", "Minute", ":", "Second"}]
  |>;
  name
);

D6ClearOpenTwoGluonPropagator[] := (
  $D6OpenTwoGluonPropagatorStore = <||>;
  Null
);

D6OpenTwoGluonPropagatorInstalledQ[name_String : "default"] :=
  KeyExistsQ[$D6OpenTwoGluonPropagatorStore, name];

D6OpenTwoGluonPropagator[name_String : "default"] := If[
  D6OpenTwoGluonPropagatorInstalledQ[name],
  $D6OpenTwoGluonPropagatorStore[name],
  Failure[
    "MissingOpenTwoGluonPropagator",
    <|
      "Message" -> "No calibrated S_Q^(GG,open) has been installed.",
      "NeededBeforeNumerics" -> D6OpenTwoGluonPropagatorTemplate[],
      "Calibration" -> D6OneLineG2CalibrationRequirement[]
    |>
  ]
];

D6CrossLineReadyQ[name_String : "default"] :=
  D6OpenTwoGluonPropagatorInstalledQ[name];

D6CrossLineBorelMoment[
  channel_String,
  m2Val_?NumericQ,
  continuumVal_?NumericQ,
  name_String : "default"
] := If[
  D6CrossLineReadyQ[name],
  Failure[
    "CrossLineReductionNotYetConnected",
    <|
      "Channel" -> channel,
      "M2" -> m2Val,
      "s0" -> continuumVal,
      "InstalledOpenPropagator" -> name,
      "NextStep" -> "Connect the installed S_Q^(GG,open) expression to the FeynCalc trace, Feynman-parameter reduction and direct Borel transform."
    |>
  ],
  Failure[
    "MissingOpenTwoGluonPropagator",
    <|
      "Channel" -> channel,
      "M2" -> m2Val,
      "s0" -> continuumVal,
      "Reason" -> "The complete dimension-6 cross-line term cannot be evaluated until S_Q^(GG,open) is derived and calibrated.",
      "DerivationRecipe" -> D6OpenTwoGluonPropagatorDerivationRecipe[],
      "Calibration" -> D6OneLineG2CalibrationRequirement[]
    |>
  ]
];

D6CrossLineKernelTemplate[channel_String : "AA"] := <|
  "Channel" -> channel,
  "CharmTwoBottomOne" ->
    "Tr[Gamma_i S_c^(GG,open)(k,mc;A,alpha,beta;B,lambda,tau) Gamma_j S_b^(G,open)(k-p,mb;C,rho,sigma)]",
  "CharmOneBottomTwo" ->
    "Tr[Gamma_i S_c^(G,open)(k,mc;A,alpha,beta) Gamma_j S_b^(GG,open)(k-p,mb;B,rho,sigma;C,lambda,tau)]",
  "VacuumAverage" -> D6TripleGluonVacuumAverage[],
  "ReductionTarget" -> "After contraction, reduce to Feynman-parameter amplitudes and then direct Borel pole weights, exactly as done for G2gg."
|>;

D6CompletionChecklist[] := {
  "Fix the exact open two-gluon heavy-quark propagator S_Q^(GG,open) in the same convention as SGNum.",
  "Check the triple-gluon vacuum tensor normalization and sign against the definition of <g_s^3 G^3> used in the paper.",
  "Build the two cross-line kernels S_c^(GG)S_b^(G) and S_c^(G)S_b^(GG) for AA, AB and BB.",
  "Reduce the kernels to scalar Feynman-parameter amplitudes.",
  "Convert amplitudes into direct Borel pole weights and test reconstruction against the amplitude.",
  "Only after these checks, define G3complete = G3c + G3b + G3cross and totalComplete = pert + G2full + G3complete."
};

D6CompletenessReport[] := <|
  "ImplementedDimension6" -> {
    "G3c = S_c^(G3) S_b^(0)",
    "G3b = S_c^(0) S_b^(G3)"
  },
  "MissingDimension6" -> D6CompleteMissingCrossLineOperators[],
  "DoNotDoubleCount" ->
    "The cross-line terms are not contained in the vacuum-averaged single-line S^(G3) propagator.",
  "CandidateTripleVacuumAverage" -> D6TripleGluonVacuumAverage[],
  "NormalizationCheck" -> D6TripleGluonTensorNormalizationCheck[],
  "NextRequiredInput" -> D6OpenTwoGluonPropagatorTemplate[],
  "DerivationRecipe" -> D6OpenTwoGluonPropagatorDerivationRecipe[],
  "OneLineG2Calibration" -> D6OneLineG2CalibrationRequirement[],
  "CrossLineReadyQ" -> D6CrossLineReadyQ[],
  "Checklist" -> D6CompletionChecklist[]
|>;

D6PaperStatement[] :=
  "The present production G3 result includes the standard single-line heavy-quark propagator terms. A separate experimental workbench now derives and reduces the cross-line open-field products S_c^(GG)S_b^(G)+S_c^(G)S_b^(GG), but this sector is not yet paper-final because the one-gluon calibration and the slow mirror-side/channel reductions must still be completed.";

Print["Loaded BcMixingDimension6Complete.wl. Run D6CompletenessReport[] for the missing cross-line sector."];

<|"Channel" -> "BB", "Side" -> "c1b2", "Indices" -> {21, 22, 23, 24, 25, 26, 
  27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 
  46, 47, 48, 49, 50}, "Coefficient" -> -1/2*I, "Projected" -> True, 
 "ProjectionMode" -> "Fast", "TimeLimit" -> 60, 
 "GeneratedAt" -> "2026-06-14 00:44:49", 
 "Results" -> {<|"Index" -> 21, "Input" -> 
     (mb*DiracGamma[Momentum[k - p]] . DiracGamma[LorentzIndex[ta]] . 
        DiracGamma[LorentzIndex[si]] . DiracGamma[Momentum[k - p]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[k, D] - 
           Momentum[p, D], mb]]^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
         Momentum[k, D] - Momentum[p, D], mb]]*Pair[LorentzIndex[la], 
        LorentzIndex[rh]])/8, "Output" -> 0|>, 
   <|"Index" -> 22, "Input" -> (mb*DiracGamma[Momentum[k - p]] . 
        DiracGamma[LorentzIndex[ta]] . DiracGamma[Momentum[k - p]] . 
        DiracGamma[LorentzIndex[si]]*FeynAmpDenominator[PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb]]^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb], 
        PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb]]*
       Pair[LorentzIndex[la], LorentzIndex[rh]])/8, 
    "Output" -> (G3*mb*mc*FeynAmpDenominator[PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
          Momentum[k, D], mc], PropagatorDenominator[Momentum[k, D], mc], 
         PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb], 
         PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb]]*
        Pair[Momentum[k], Momentum[k]]*Pair[Momentum[p], Momentum[p]])/
       (96*(mb + mc)^2) - (G3*mb*mc*FeynAmpDenominator[PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
          Momentum[k, D], mc], PropagatorDenominator[Momentum[k, D], mc], 
         PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb], 
         PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb]]*
        Pair[Momentum[k], Momentum[p]]*Pair[Momentum[p], Momentum[p]])/
       (48*(mb + mc)^2) + (G3*mb*mc*FeynAmpDenominator[PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
          Momentum[k, D], mc], PropagatorDenominator[Momentum[k, D], mc], 
         PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb], 
         PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb]]*
        Pair[Momentum[p], Momentum[p]]^2)/(96*(mb + mc)^2)|>, 
   <|"Index" -> 23, "Input" -> -1/8*(DiracGamma[Momentum[k - p]] . 
        DiracGamma[LorentzIndex[si]] . DiracGamma[Momentum[k - p]] . 
        DiracGamma[LorentzIndex[ta]] . DiracGamma[Momentum[k - p]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[k, D] - 
           Momentum[p, D], mb]]^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
         Momentum[k, D] - Momentum[p, D], mb]]*Pair[LorentzIndex[la], 
        LorentzIndex[rh]]), "Output" -> 
     (G3*FeynAmpDenominator[PropagatorDenominator[Momentum[k, D] - 
           Momentum[p, D], mb], PropagatorDenominator[Momentum[k, D] - 
           Momentum[p, D], mb], PropagatorDenominator[Momentum[k, D], mc], 
         PropagatorDenominator[Momentum[k, D], mc], PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb]]*Pair[Momentum[k], 
         Momentum[k]]*Pair[Momentum[k], Momentum[p]]^2)/(72*(mb + mc)^2) - 
      (G3*FeynAmpDenominator[PropagatorDenominator[Momentum[k, D] - 
           Momentum[p, D], mb], PropagatorDenominator[Momentum[k, D] - 
           Momentum[p, D], mb], PropagatorDenominator[Momentum[k, D], mc], 
         PropagatorDenominator[Momentum[k, D], mc], PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb]]*
        Pair[Momentum[k], Momentum[p]]^3)/(36*(mb + mc)^2) - 
      (G3*FeynAmpDenominator[PropagatorDenominator[Momentum[k, D] - 
           Momentum[p, D], mb], PropagatorDenominator[Momentum[k, D] - 
           Momentum[p, D], mb], PropagatorDenominator[Momentum[k, D], mc], 
         PropagatorDenominator[Momentum[k, D], mc], PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb]]*
        Pair[Momentum[k], Momentum[k]]^2*Pair[Momentum[p], Momentum[p]])/
       (288*(mb + mc)^2) - (G3*FeynAmpDenominator[PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
          Momentum[k, D], mc], PropagatorDenominator[Momentum[k, D], mc], 
         PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb], 
         PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb]]*
        Pair[Momentum[k], Momentum[k]]*Pair[Momentum[k], Momentum[p]]*
        Pair[Momentum[p], Momentum[p]])/(288*(mb + mc)^2) + 
      (5*G3*FeynAmpDenominator[PropagatorDenominator[Momentum[k, D] - 
           Momentum[p, D], mb], PropagatorDenominator[Momentum[k, D] - 
           Momentum[p, D], mb], PropagatorDenominator[Momentum[k, D], mc], 
         PropagatorDenominator[Momentum[k, D], mc], PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb]]*
        Pair[Momentum[k], Momentum[p]]^2*Pair[Momentum[p], Momentum[p]])/
       (144*(mb + mc)^2) - (G3*FeynAmpDenominator[PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
          Momentum[k, D], mc], PropagatorDenominator[Momentum[k, D], mc], 
         PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb], 
         PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb]]*
        Pair[Momentum[k], Momentum[k]]*Pair[Momentum[p], Momentum[p]]^2)/
       (288*(mb + mc)^2) - (G3*FeynAmpDenominator[PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
          Momentum[k, D], mc], PropagatorDenominator[Momentum[k, D], mc], 
         PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb], 
         PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb]]*
        Pair[Momentum[k], Momentum[p]]*Pair[Momentum[p], Momentum[p]]^2)/
       (96*(mb + mc)^2)|>, <|"Index" -> 24, 
    "Input" -> (DiracGamma[Momentum[k - p]] . DiracGamma[LorentzIndex[ta]] . 
        DiracGamma[Momentum[k - p]] . DiracGamma[LorentzIndex[si]] . 
        DiracGamma[Momentum[k - p]]*FeynAmpDenominator[PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb]]^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb], 
        PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb]]*
       Pair[LorentzIndex[la], LorentzIndex[rh]])/8, 
    "Output" -> (G3*FeynAmpDenominator[PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
          Momentum[k, D], mc], PropagatorDenominator[Momentum[k, D], mc], 
         PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb], 
         PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb]]*
        Pair[Momentum[k], Momentum[k]]*Pair[Momentum[k], Momentum[p]]^2)/
       (72*(mb + mc)^2) - (G3*FeynAmpDenominator[PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
          Momentum[k, D], mc], PropagatorDenominator[Momentum[k, D], mc], 
         PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb], 
         PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb]]*
        Pair[Momentum[k], Momentum[p]]^3)/(36*(mb + mc)^2) - 
      (G3*FeynAmpDenominator[PropagatorDenominator[Momentum[k, D] - 
           Momentum[p, D], mb], PropagatorDenominator[Momentum[k, D] - 
           Momentum[p, D], mb], PropagatorDenominator[Momentum[k, D], mc], 
         PropagatorDenominator[Momentum[k, D], mc], PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb]]*
        Pair[Momentum[k], Momentum[k]]^2*Pair[Momentum[p], Momentum[p]])/
       (288*(mb + mc)^2) - (G3*FeynAmpDenominator[PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
          Momentum[k, D], mc], PropagatorDenominator[Momentum[k, D], mc], 
         PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb], 
         PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb]]*
        Pair[Momentum[k], Momentum[k]]*Pair[Momentum[k], Momentum[p]]*
        Pair[Momentum[p], Momentum[p]])/(288*(mb + mc)^2) + 
      (5*G3*FeynAmpDenominator[PropagatorDenominator[Momentum[k, D] - 
           Momentum[p, D], mb], PropagatorDenominator[Momentum[k, D] - 
           Momentum[p, D], mb], PropagatorDenominator[Momentum[k, D], mc], 
         PropagatorDenominator[Momentum[k, D], mc], PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb]]*
        Pair[Momentum[k], Momentum[p]]^2*Pair[Momentum[p], Momentum[p]])/
       (144*(mb + mc)^2) - (G3*FeynAmpDenominator[PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
          Momentum[k, D], mc], PropagatorDenominator[Momentum[k, D], mc], 
         PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb], 
         PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb]]*
        Pair[Momentum[k], Momentum[k]]*Pair[Momentum[p], Momentum[p]]^2)/
       (288*(mb + mc)^2) - (G3*FeynAmpDenominator[PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
          Momentum[k, D], mc], PropagatorDenominator[Momentum[k, D], mc], 
         PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb], 
         PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb]]*
        Pair[Momentum[k], Momentum[p]]*Pair[Momentum[p], Momentum[p]]^2)/
       (96*(mb + mc)^2)|>, <|"Index" -> 25, 
    "Input" -> -1/8*(mb^3*DiracGamma[LorentzIndex[ta]] . 
        DiracGamma[LorentzIndex[rh]]*FeynAmpDenominator[PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb]]^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb], 
        PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb]]*
       Pair[LorentzIndex[la], LorentzIndex[si]]), 
    "Output" -> (G3*mb^3*mc*FeynAmpDenominator[PropagatorDenominator[
         Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
         Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
         Momentum[k, D], mc], PropagatorDenominator[Momentum[k, D], mc], 
        PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb], 
        PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb]]*
       Pair[Momentum[p], Momentum[p]])/(16*(mb + mc)^2)|>, 
   <|"Index" -> 26, "Input" -> -1/8*(mb^2*DiracGamma[LorentzIndex[ta]] . 
        DiracGamma[LorentzIndex[rh]] . DiracGamma[Momentum[k - p]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[k, D] - 
           Momentum[p, D], mb]]^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
         Momentum[k, D] - Momentum[p, D], mb]]*Pair[LorentzIndex[la], 
        LorentzIndex[si]]), "Output" -> 
     (G3*mb^2*FeynAmpDenominator[PropagatorDenominator[Momentum[k, D] - 
           Momentum[p, D], mb], PropagatorDenominator[Momentum[k, D] - 
           Momentum[p, D], mb], PropagatorDenominator[Momentum[k, D], mc], 
         PropagatorDenominator[Momentum[k, D], mc], PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb]]*
        Pair[Momentum[k], Momentum[p]]^2)/(24*(mb + mc)^2) - 
      (G3*mb^2*FeynAmpDenominator[PropagatorDenominator[Momentum[k, D] - 
           Momentum[p, D], mb], PropagatorDenominator[Momentum[k, D] - 
           Momentum[p, D], mb], PropagatorDenominator[Momentum[k, D], mc], 
         PropagatorDenominator[Momentum[k, D], mc], PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb]]*Pair[Momentum[k], 
         Momentum[k]]*Pair[Momentum[p], Momentum[p]])/(96*(mb + mc)^2) - 
      (G3*mb^2*FeynAmpDenominator[PropagatorDenominator[Momentum[k, D] - 
           Momentum[p, D], mb], PropagatorDenominator[Momentum[k, D] - 
           Momentum[p, D], mb], PropagatorDenominator[Momentum[k, D], mc], 
         PropagatorDenominator[Momentum[k, D], mc], PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb]]*Pair[Momentum[k], 
         Momentum[p]]*Pair[Momentum[p], Momentum[p]])/(32*(mb + mc)^2)|>, 
   <|"Index" -> 27, "Input" -> -1/8*(mb^2*DiracGamma[LorentzIndex[ta]] . 
        DiracGamma[Momentum[k - p]] . DiracGamma[LorentzIndex[rh]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[k, D] - 
           Momentum[p, D], mb]]^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
         Momentum[k, D] - Momentum[p, D], mb]]*Pair[LorentzIndex[la], 
        LorentzIndex[si]]), "Output" -> 
     -1/24*(G3*mb^2*FeynAmpDenominator[PropagatorDenominator[
           Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
           Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
           Momentum[k, D], mc], PropagatorDenominator[Momentum[k, D], mc], 
          PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb], 
          PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb]]*
         Pair[Momentum[k], Momentum[p]]^2)/(mb + mc)^2 + 
      (G3*mb^2*FeynAmpDenominator[PropagatorDenominator[Momentum[k, D] - 
           Momentum[p, D], mb], PropagatorDenominator[Momentum[k, D] - 
           Momentum[p, D], mb], PropagatorDenominator[Momentum[k, D], mc], 
         PropagatorDenominator[Momentum[k, D], mc], PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb]]*Pair[Momentum[k], 
         Momentum[k]]*Pair[Momentum[p], Momentum[p]])/(96*(mb + mc)^2) + 
      (G3*mb^2*FeynAmpDenominator[PropagatorDenominator[Momentum[k, D] - 
           Momentum[p, D], mb], PropagatorDenominator[Momentum[k, D] - 
           Momentum[p, D], mb], PropagatorDenominator[Momentum[k, D], mc], 
         PropagatorDenominator[Momentum[k, D], mc], PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb]]*Pair[Momentum[k], 
         Momentum[p]]*Pair[Momentum[p], Momentum[p]])/(32*(mb + mc)^2)|>, 
   <|"Index" -> 28, "Input" -> -1/8*(mb^2*DiracGamma[Momentum[k - p]] . 
        DiracGamma[LorentzIndex[ta]] . DiracGamma[LorentzIndex[rh]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[k, D] - 
           Momentum[p, D], mb]]^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
         Momentum[k, D] - Momentum[p, D], mb]]*Pair[LorentzIndex[la], 
        LorentzIndex[si]]), "Output" -> 
     (G3*mb^2*FeynAmpDenominator[PropagatorDenominator[Momentum[k, D] - 
           Momentum[p, D], mb], PropagatorDenominator[Momentum[k, D] - 
           Momentum[p, D], mb], PropagatorDenominator[Momentum[k, D], mc], 
         PropagatorDenominator[Momentum[k, D], mc], PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb]]*
        Pair[Momentum[k], Momentum[p]]^2)/(24*(mb + mc)^2) - 
      (G3*mb^2*FeynAmpDenominator[PropagatorDenominator[Momentum[k, D] - 
           Momentum[p, D], mb], PropagatorDenominator[Momentum[k, D] - 
           Momentum[p, D], mb], PropagatorDenominator[Momentum[k, D], mc], 
         PropagatorDenominator[Momentum[k, D], mc], PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb]]*Pair[Momentum[k], 
         Momentum[k]]*Pair[Momentum[p], Momentum[p]])/(96*(mb + mc)^2) - 
      (G3*mb^2*FeynAmpDenominator[PropagatorDenominator[Momentum[k, D] - 
           Momentum[p, D], mb], PropagatorDenominator[Momentum[k, D] - 
           Momentum[p, D], mb], PropagatorDenominator[Momentum[k, D], mc], 
         PropagatorDenominator[Momentum[k, D], mc], PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb]]*Pair[Momentum[k], 
         Momentum[p]]*Pair[Momentum[p], Momentum[p]])/(32*(mb + mc)^2)|>, 
   <|"Index" -> 29, "Input" -> -1/8*(mb*DiracGamma[LorentzIndex[ta]] . 
        DiracGamma[Momentum[k - p]] . DiracGamma[LorentzIndex[rh]] . 
        DiracGamma[Momentum[k - p]]*FeynAmpDenominator[PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb]]^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb], 
        PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb]]*
       Pair[LorentzIndex[la], LorentzIndex[si]]), 
    "Output" -> -1/32*(G3*mb*mc*FeynAmpDenominator[PropagatorDenominator[
           Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
           Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
           Momentum[k, D], mc], PropagatorDenominator[Momentum[k, D], mc], 
          PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb], 
          PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb]]*
         Pair[Momentum[k], Momentum[k]]*Pair[Momentum[p], Momentum[p]])/
        (mb + mc)^2 + (G3*mb*mc*FeynAmpDenominator[PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
          Momentum[k, D], mc], PropagatorDenominator[Momentum[k, D], mc], 
         PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb], 
         PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb]]*
        Pair[Momentum[k], Momentum[p]]*Pair[Momentum[p], Momentum[p]])/
       (16*(mb + mc)^2) - (G3*mb*mc*FeynAmpDenominator[PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
          Momentum[k, D], mc], PropagatorDenominator[Momentum[k, D], mc], 
         PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb], 
         PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb]]*
        Pair[Momentum[p], Momentum[p]]^2)/(32*(mb + mc)^2)|>, 
   <|"Index" -> 30, "Input" -> -1/8*(mb*DiracGamma[Momentum[k - p]] . 
        DiracGamma[LorentzIndex[ta]] . DiracGamma[LorentzIndex[rh]] . 
        DiracGamma[Momentum[k - p]]*FeynAmpDenominator[PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb]]^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb], 
        PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb]]*
       Pair[LorentzIndex[la], LorentzIndex[si]]), "Output" -> 0|>, 
   <|"Index" -> 31, "Input" -> -1/8*(mb*DiracGamma[Momentum[k - p]] . 
        DiracGamma[LorentzIndex[ta]] . DiracGamma[Momentum[k - p]] . 
        DiracGamma[LorentzIndex[rh]]*FeynAmpDenominator[PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb]]^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb], 
        PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb]]*
       Pair[LorentzIndex[la], LorentzIndex[si]]), 
    "Output" -> -1/32*(G3*mb*mc*FeynAmpDenominator[PropagatorDenominator[
           Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
           Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
           Momentum[k, D], mc], PropagatorDenominator[Momentum[k, D], mc], 
          PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb], 
          PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb]]*
         Pair[Momentum[k], Momentum[k]]*Pair[Momentum[p], Momentum[p]])/
        (mb + mc)^2 + (G3*mb*mc*FeynAmpDenominator[PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
          Momentum[k, D], mc], PropagatorDenominator[Momentum[k, D], mc], 
         PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb], 
         PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb]]*
        Pair[Momentum[k], Momentum[p]]*Pair[Momentum[p], Momentum[p]])/
       (16*(mb + mc)^2) - (G3*mb*mc*FeynAmpDenominator[PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
          Momentum[k, D], mc], PropagatorDenominator[Momentum[k, D], mc], 
         PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb], 
         PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb]]*
        Pair[Momentum[p], Momentum[p]]^2)/(32*(mb + mc)^2)|>, 
   <|"Index" -> 32, "Input" -> -1/8*(DiracGamma[Momentum[k - p]] . 
        DiracGamma[LorentzIndex[ta]] . DiracGamma[Momentum[k - p]] . 
        DiracGamma[LorentzIndex[rh]] . DiracGamma[Momentum[k - p]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[k, D] - 
           Momentum[p, D], mb]]^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
         Momentum[k, D] - Momentum[p, D], mb]]*Pair[LorentzIndex[la], 
        LorentzIndex[si]]), "Output" -> 
     -1/24*(G3*FeynAmpDenominator[PropagatorDenominator[Momentum[k, D] - 
            Momentum[p, D], mb], PropagatorDenominator[Momentum[k, D] - 
            Momentum[p, D], mb], PropagatorDenominator[Momentum[k, D], mc], 
          PropagatorDenominator[Momentum[k, D], mc], PropagatorDenominator[
           Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
           Momentum[k, D] - Momentum[p, D], mb]]*Pair[Momentum[k], 
          Momentum[k]]*Pair[Momentum[k], Momentum[p]]^2)/(mb + mc)^2 + 
      (G3*FeynAmpDenominator[PropagatorDenominator[Momentum[k, D] - 
           Momentum[p, D], mb], PropagatorDenominator[Momentum[k, D] - 
           Momentum[p, D], mb], PropagatorDenominator[Momentum[k, D], mc], 
         PropagatorDenominator[Momentum[k, D], mc], PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb]]*
        Pair[Momentum[k], Momentum[p]]^3)/(12*(mb + mc)^2) + 
      (G3*FeynAmpDenominator[PropagatorDenominator[Momentum[k, D] - 
           Momentum[p, D], mb], PropagatorDenominator[Momentum[k, D] - 
           Momentum[p, D], mb], PropagatorDenominator[Momentum[k, D], mc], 
         PropagatorDenominator[Momentum[k, D], mc], PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb]]*
        Pair[Momentum[k], Momentum[k]]^2*Pair[Momentum[p], Momentum[p]])/
       (96*(mb + mc)^2) + (G3*FeynAmpDenominator[PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
          Momentum[k, D], mc], PropagatorDenominator[Momentum[k, D], mc], 
         PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb], 
         PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb]]*
        Pair[Momentum[k], Momentum[k]]*Pair[Momentum[k], Momentum[p]]*
        Pair[Momentum[p], Momentum[p]])/(96*(mb + mc)^2) - 
      (5*G3*FeynAmpDenominator[PropagatorDenominator[Momentum[k, D] - 
           Momentum[p, D], mb], PropagatorDenominator[Momentum[k, D] - 
           Momentum[p, D], mb], PropagatorDenominator[Momentum[k, D], mc], 
         PropagatorDenominator[Momentum[k, D], mc], PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb]]*
        Pair[Momentum[k], Momentum[p]]^2*Pair[Momentum[p], Momentum[p]])/
       (48*(mb + mc)^2) + (G3*FeynAmpDenominator[PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
          Momentum[k, D], mc], PropagatorDenominator[Momentum[k, D], mc], 
         PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb], 
         PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb]]*
        Pair[Momentum[k], Momentum[k]]*Pair[Momentum[p], Momentum[p]]^2)/
       (96*(mb + mc)^2) + (G3*FeynAmpDenominator[PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
          Momentum[k, D], mc], PropagatorDenominator[Momentum[k, D], mc], 
         PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb], 
         PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb]]*
        Pair[Momentum[k], Momentum[p]]*Pair[Momentum[p], Momentum[p]]^2)/
       (32*(mb + mc)^2)|>, <|"Index" -> 33, 
    "Input" -> -1/8*(mb^2*DiracGamma[LorentzIndex[si]] . 
        DiracGamma[LorentzIndex[rh]] . DiracGamma[LorentzIndex[ta]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[k, D] - 
           Momentum[p, D], mb]]^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
         Momentum[k, D] - Momentum[p, D], mb]]*Pair[LorentzIndex[la], 
        Momentum[k - p]]), "Output" -> 
     -1/72*(G3*mb^2*FeynAmpDenominator[PropagatorDenominator[
           Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
           Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
           Momentum[k, D], mc], PropagatorDenominator[Momentum[k, D], mc], 
          PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb], 
          PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb]]*
         Pair[Momentum[k], Momentum[p]]^2)/(mb + mc)^2 + 
      (G3*mb^2*FeynAmpDenominator[PropagatorDenominator[Momentum[k, D] - 
           Momentum[p, D], mb], PropagatorDenominator[Momentum[k, D] - 
           Momentum[p, D], mb], PropagatorDenominator[Momentum[k, D], mc], 
         PropagatorDenominator[Momentum[k, D], mc], PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb]]*Pair[Momentum[k], 
         Momentum[k]]*Pair[Momentum[p], Momentum[p]])/(288*(mb + mc)^2) + 
      (G3*mb^2*FeynAmpDenominator[PropagatorDenominator[Momentum[k, D] - 
           Momentum[p, D], mb], PropagatorDenominator[Momentum[k, D] - 
           Momentum[p, D], mb], PropagatorDenominator[Momentum[k, D], mc], 
         PropagatorDenominator[Momentum[k, D], mc], PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb]]*Pair[Momentum[k], 
         Momentum[p]]*Pair[Momentum[p], Momentum[p]])/(96*(mb + mc)^2)|>, 
   <|"Index" -> 34, "Input" -> -1/8*(mb^2*DiracGamma[LorentzIndex[si]] . 
        DiracGamma[LorentzIndex[ta]] . DiracGamma[LorentzIndex[rh]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[k, D] - 
           Momentum[p, D], mb]]^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
         Momentum[k, D] - Momentum[p, D], mb]]*Pair[LorentzIndex[la], 
        Momentum[k - p]]), "Output" -> 
     (G3*mb^2*FeynAmpDenominator[PropagatorDenominator[Momentum[k, D] - 
           Momentum[p, D], mb], PropagatorDenominator[Momentum[k, D] - 
           Momentum[p, D], mb], PropagatorDenominator[Momentum[k, D], mc], 
         PropagatorDenominator[Momentum[k, D], mc], PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb]]*
        Pair[Momentum[k], Momentum[p]]^2)/(72*(mb + mc)^2) - 
      (G3*mb^2*FeynAmpDenominator[PropagatorDenominator[Momentum[k, D] - 
           Momentum[p, D], mb], PropagatorDenominator[Momentum[k, D] - 
           Momentum[p, D], mb], PropagatorDenominator[Momentum[k, D], mc], 
         PropagatorDenominator[Momentum[k, D], mc], PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb]]*Pair[Momentum[k], 
         Momentum[k]]*Pair[Momentum[p], Momentum[p]])/(288*(mb + mc)^2) - 
      (G3*mb^2*FeynAmpDenominator[PropagatorDenominator[Momentum[k, D] - 
           Momentum[p, D], mb], PropagatorDenominator[Momentum[k, D] - 
           Momentum[p, D], mb], PropagatorDenominator[Momentum[k, D], mc], 
         PropagatorDenominator[Momentum[k, D], mc], PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb]]*Pair[Momentum[k], 
         Momentum[p]]*Pair[Momentum[p], Momentum[p]])/(96*(mb + mc)^2)|>, 
   <|"Index" -> 35, "Input" -> -1/4*(mb^2*DiracGamma[LorentzIndex[ta]] . 
        DiracGamma[LorentzIndex[rh]] . DiracGamma[LorentzIndex[si]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[k, D] - 
           Momentum[p, D], mb]]^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
         Momentum[k, D] - Momentum[p, D], mb]]*Pair[LorentzIndex[la], 
        Momentum[k - p]]), "Output" -> 
     (G3*mb^2*FeynAmpDenominator[PropagatorDenominator[Momentum[k, D] - 
           Momentum[p, D], mb], PropagatorDenominator[Momentum[k, D] - 
           Momentum[p, D], mb], PropagatorDenominator[Momentum[k, D], mc], 
         PropagatorDenominator[Momentum[k, D], mc], PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb]]*
        Pair[Momentum[k], Momentum[p]]^2)/(36*(mb + mc)^2) - 
      (G3*mb^2*FeynAmpDenominator[PropagatorDenominator[Momentum[k, D] - 
           Momentum[p, D], mb], PropagatorDenominator[Momentum[k, D] - 
           Momentum[p, D], mb], PropagatorDenominator[Momentum[k, D], mc], 
         PropagatorDenominator[Momentum[k, D], mc], PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb]]*Pair[Momentum[k], 
         Momentum[k]]*Pair[Momentum[p], Momentum[p]])/(144*(mb + mc)^2) - 
      (G3*mb^2*FeynAmpDenominator[PropagatorDenominator[Momentum[k, D] - 
           Momentum[p, D], mb], PropagatorDenominator[Momentum[k, D] - 
           Momentum[p, D], mb], PropagatorDenominator[Momentum[k, D], mc], 
         PropagatorDenominator[Momentum[k, D], mc], PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb]]*Pair[Momentum[k], 
         Momentum[p]]*Pair[Momentum[p], Momentum[p]])/(48*(mb + mc)^2)|>, 
   <|"Index" -> 36, "Input" -> (mb^2*DiracGamma[LorentzIndex[ta]] . 
        DiracGamma[LorentzIndex[si]] . DiracGamma[LorentzIndex[rh]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[k, D] - 
           Momentum[p, D], mb]]^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
         Momentum[k, D] - Momentum[p, D], mb]]*Pair[LorentzIndex[la], 
        Momentum[k - p]])/4, "Output" -> 
     (G3*mb^2*FeynAmpDenominator[PropagatorDenominator[Momentum[k, D] - 
           Momentum[p, D], mb], PropagatorDenominator[Momentum[k, D] - 
           Momentum[p, D], mb], PropagatorDenominator[Momentum[k, D], mc], 
         PropagatorDenominator[Momentum[k, D], mc], PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb]]*
        Pair[Momentum[k], Momentum[p]]^2)/(36*(mb + mc)^2) - 
      (G3*mb^2*FeynAmpDenominator[PropagatorDenominator[Momentum[k, D] - 
           Momentum[p, D], mb], PropagatorDenominator[Momentum[k, D] - 
           Momentum[p, D], mb], PropagatorDenominator[Momentum[k, D], mc], 
         PropagatorDenominator[Momentum[k, D], mc], PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb]]*Pair[Momentum[k], 
         Momentum[k]]*Pair[Momentum[p], Momentum[p]])/(144*(mb + mc)^2) - 
      (G3*mb^2*FeynAmpDenominator[PropagatorDenominator[Momentum[k, D] - 
           Momentum[p, D], mb], PropagatorDenominator[Momentum[k, D] - 
           Momentum[p, D], mb], PropagatorDenominator[Momentum[k, D], mc], 
         PropagatorDenominator[Momentum[k, D], mc], PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb]]*Pair[Momentum[k], 
         Momentum[p]]*Pair[Momentum[p], Momentum[p]])/(48*(mb + mc)^2)|>, 
   <|"Index" -> 37, "Input" -> -1/8*(mb*DiracGamma[LorentzIndex[si]] . 
        DiracGamma[LorentzIndex[rh]] . DiracGamma[LorentzIndex[ta]] . 
        DiracGamma[Momentum[k - p]]*FeynAmpDenominator[PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb]]^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb], 
        PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb]]*
       Pair[LorentzIndex[la], Momentum[k - p]]), 
    "Output" -> -1/96*(G3*mb*mc*FeynAmpDenominator[PropagatorDenominator[
           Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
           Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
           Momentum[k, D], mc], PropagatorDenominator[Momentum[k, D], mc], 
          PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb], 
          PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb]]*
         Pair[Momentum[k], Momentum[k]]*Pair[Momentum[p], Momentum[p]])/
        (mb + mc)^2 + (G3*mb*mc*FeynAmpDenominator[PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
          Momentum[k, D], mc], PropagatorDenominator[Momentum[k, D], mc], 
         PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb], 
         PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb]]*
        Pair[Momentum[k], Momentum[p]]*Pair[Momentum[p], Momentum[p]])/
       (48*(mb + mc)^2) - (G3*mb*mc*FeynAmpDenominator[PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
          Momentum[k, D], mc], PropagatorDenominator[Momentum[k, D], mc], 
         PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb], 
         PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb]]*
        Pair[Momentum[p], Momentum[p]]^2)/(96*(mb + mc)^2)|>, 
   <|"Index" -> 38, "Input" -> -1/8*(mb*DiracGamma[LorentzIndex[si]] . 
        DiracGamma[Momentum[k - p]] . DiracGamma[LorentzIndex[ta]] . 
        DiracGamma[LorentzIndex[rh]]*FeynAmpDenominator[PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb]]^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb], 
        PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb]]*
       Pair[LorentzIndex[la], Momentum[k - p]]), 
    "Output" -> (G3*mb*mc*FeynAmpDenominator[PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
          Momentum[k, D], mc], PropagatorDenominator[Momentum[k, D], mc], 
         PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb], 
         PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb]]*
        Pair[Momentum[k], Momentum[k]]*Pair[Momentum[p], Momentum[p]])/
       (32*(mb + mc)^2) - (G3*mb*mc*FeynAmpDenominator[PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
          Momentum[k, D], mc], PropagatorDenominator[Momentum[k, D], mc], 
         PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb], 
         PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb]]*
        Pair[Momentum[k], Momentum[p]]*Pair[Momentum[p], Momentum[p]])/
       (16*(mb + mc)^2) + (G3*mb*mc*FeynAmpDenominator[PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
          Momentum[k, D], mc], PropagatorDenominator[Momentum[k, D], mc], 
         PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb], 
         PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb]]*
        Pair[Momentum[p], Momentum[p]]^2)/(32*(mb + mc)^2)|>, 
   <|"Index" -> 39, "Input" -> -1/4*(mb*DiracGamma[LorentzIndex[ta]] . 
        DiracGamma[Momentum[k - p]] . DiracGamma[LorentzIndex[rh]] . 
        DiracGamma[LorentzIndex[si]]*FeynAmpDenominator[PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb]]^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb], 
        PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb]]*
       Pair[LorentzIndex[la], Momentum[k - p]]), 
    "Output" -> -1/48*(G3*mb*mc*FeynAmpDenominator[PropagatorDenominator[
           Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
           Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
           Momentum[k, D], mc], PropagatorDenominator[Momentum[k, D], mc], 
          PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb], 
          PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb]]*
         Pair[Momentum[k], Momentum[k]]*Pair[Momentum[p], Momentum[p]])/
        (mb + mc)^2 + (G3*mb*mc*FeynAmpDenominator[PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
          Momentum[k, D], mc], PropagatorDenominator[Momentum[k, D], mc], 
         PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb], 
         PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb]]*
        Pair[Momentum[k], Momentum[p]]*Pair[Momentum[p], Momentum[p]])/
       (24*(mb + mc)^2) - (G3*mb*mc*FeynAmpDenominator[PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
          Momentum[k, D], mc], PropagatorDenominator[Momentum[k, D], mc], 
         PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb], 
         PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb]]*
        Pair[Momentum[p], Momentum[p]]^2)/(48*(mb + mc)^2)|>, 
   <|"Index" -> 40, "Input" -> (mb*DiracGamma[LorentzIndex[ta]] . 
        DiracGamma[Momentum[k - p]] . DiracGamma[LorentzIndex[si]] . 
        DiracGamma[LorentzIndex[rh]]*FeynAmpDenominator[PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb]]^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb], 
        PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb]]*
       Pair[LorentzIndex[la], Momentum[k - p]])/4, 
    "Output" -> -1/16*(G3*mb*mc*FeynAmpDenominator[PropagatorDenominator[
           Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
           Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
           Momentum[k, D], mc], PropagatorDenominator[Momentum[k, D], mc], 
          PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb], 
          PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb]]*
         Pair[Momentum[k], Momentum[k]]*Pair[Momentum[p], Momentum[p]])/
        (mb + mc)^2 + (G3*mb*mc*FeynAmpDenominator[PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
          Momentum[k, D], mc], PropagatorDenominator[Momentum[k, D], mc], 
         PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb], 
         PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb]]*
        Pair[Momentum[k], Momentum[p]]*Pair[Momentum[p], Momentum[p]])/
       (8*(mb + mc)^2) - (G3*mb*mc*FeynAmpDenominator[PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
          Momentum[k, D], mc], PropagatorDenominator[Momentum[k, D], mc], 
         PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb], 
         PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb]]*
        Pair[Momentum[p], Momentum[p]]^2)/(16*(mb + mc)^2)|>, 
   <|"Index" -> 41, "Input" -> -1/8*(mb*DiracGamma[Momentum[k - p]] . 
        DiracGamma[LorentzIndex[si]] . DiracGamma[LorentzIndex[rh]] . 
        DiracGamma[LorentzIndex[ta]]*FeynAmpDenominator[PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb]]^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb], 
        PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb]]*
       Pair[LorentzIndex[la], Momentum[k - p]]), 
    "Output" -> -1/96*(G3*mb*mc*FeynAmpDenominator[PropagatorDenominator[
           Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
           Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
           Momentum[k, D], mc], PropagatorDenominator[Momentum[k, D], mc], 
          PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb], 
          PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb]]*
         Pair[Momentum[k], Momentum[k]]*Pair[Momentum[p], Momentum[p]])/
        (mb + mc)^2 + (G3*mb*mc*FeynAmpDenominator[PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
          Momentum[k, D], mc], PropagatorDenominator[Momentum[k, D], mc], 
         PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb], 
         PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb]]*
        Pair[Momentum[k], Momentum[p]]*Pair[Momentum[p], Momentum[p]])/
       (48*(mb + mc)^2) - (G3*mb*mc*FeynAmpDenominator[PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
          Momentum[k, D], mc], PropagatorDenominator[Momentum[k, D], mc], 
         PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb], 
         PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb]]*
        Pair[Momentum[p], Momentum[p]]^2)/(96*(mb + mc)^2)|>, 
   <|"Index" -> 42, "Input" -> -1/8*(mb*DiracGamma[Momentum[k - p]] . 
        DiracGamma[LorentzIndex[si]] . DiracGamma[LorentzIndex[ta]] . 
        DiracGamma[LorentzIndex[rh]]*FeynAmpDenominator[PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb]]^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb], 
        PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb]]*
       Pair[LorentzIndex[la], Momentum[k - p]]), "Output" -> 0|>, 
   <|"Index" -> 43, "Input" -> -1/4*(mb*DiracGamma[Momentum[k - p]] . 
        DiracGamma[LorentzIndex[ta]] . DiracGamma[LorentzIndex[rh]] . 
        DiracGamma[LorentzIndex[si]]*FeynAmpDenominator[PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb]]^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb], 
        PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb]]*
       Pair[LorentzIndex[la], Momentum[k - p]]), 
    "Output" -> (G3*mb*mc*FeynAmpDenominator[PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
          Momentum[k, D], mc], PropagatorDenominator[Momentum[k, D], mc], 
         PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb], 
         PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb]]*
        Pair[Momentum[k], Momentum[k]]*Pair[Momentum[p], Momentum[p]])/
       (48*(mb + mc)^2) - (G3*mb*mc*FeynAmpDenominator[PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
          Momentum[k, D], mc], PropagatorDenominator[Momentum[k, D], mc], 
         PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb], 
         PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb]]*
        Pair[Momentum[k], Momentum[p]]*Pair[Momentum[p], Momentum[p]])/
       (24*(mb + mc)^2) + (G3*mb*mc*FeynAmpDenominator[PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
          Momentum[k, D], mc], PropagatorDenominator[Momentum[k, D], mc], 
         PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb], 
         PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb]]*
        Pair[Momentum[p], Momentum[p]]^2)/(48*(mb + mc)^2)|>, 
   <|"Index" -> 44, "Input" -> (mb*DiracGamma[Momentum[k - p]] . 
        DiracGamma[LorentzIndex[ta]] . DiracGamma[LorentzIndex[si]] . 
        DiracGamma[LorentzIndex[rh]]*FeynAmpDenominator[PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb]]^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb], 
        PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb]]*
       Pair[LorentzIndex[la], Momentum[k - p]])/4, 
    "Output" -> (G3*mb*mc*FeynAmpDenominator[PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
          Momentum[k, D], mc], PropagatorDenominator[Momentum[k, D], mc], 
         PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb], 
         PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb]]*
        Pair[Momentum[k], Momentum[k]]*Pair[Momentum[p], Momentum[p]])/
       (16*(mb + mc)^2) - (G3*mb*mc*FeynAmpDenominator[PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
          Momentum[k, D], mc], PropagatorDenominator[Momentum[k, D], mc], 
         PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb], 
         PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb]]*
        Pair[Momentum[k], Momentum[p]]*Pair[Momentum[p], Momentum[p]])/
       (8*(mb + mc)^2) + (G3*mb*mc*FeynAmpDenominator[PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
          Momentum[k, D], mc], PropagatorDenominator[Momentum[k, D], mc], 
         PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb], 
         PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb]]*
        Pair[Momentum[p], Momentum[p]]^2)/(16*(mb + mc)^2)|>, 
   <|"Index" -> 45, "Input" -> -1/8*(DiracGamma[Momentum[k - p]] . 
        DiracGamma[LorentzIndex[si]] . DiracGamma[LorentzIndex[rh]] . 
        DiracGamma[LorentzIndex[ta]] . DiracGamma[Momentum[k - p]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[k, D] - 
           Momentum[p, D], mb]]^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
         Momentum[k, D] - Momentum[p, D], mb]]*Pair[LorentzIndex[la], 
        Momentum[k - p]]), "Output" -> $TimedOut|>, 
   <|"Index" -> 46, "Input" -> -1/8*(DiracGamma[Momentum[k - p]] . 
        DiracGamma[LorentzIndex[si]] . DiracGamma[Momentum[k - p]] . 
        DiracGamma[LorentzIndex[ta]] . DiracGamma[LorentzIndex[rh]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[k, D] - 
           Momentum[p, D], mb]]^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
         Momentum[k, D] - Momentum[p, D], mb]]*Pair[LorentzIndex[la], 
        Momentum[k - p]]), "Output" -> $TimedOut|>, 
   <|"Index" -> 47, "Input" -> -1/4*(DiracGamma[Momentum[k - p]] . 
        DiracGamma[LorentzIndex[ta]] . DiracGamma[Momentum[k - p]] . 
        DiracGamma[LorentzIndex[rh]] . DiracGamma[LorentzIndex[si]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[k, D] - 
           Momentum[p, D], mb]]^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
         Momentum[k, D] - Momentum[p, D], mb]]*Pair[LorentzIndex[la], 
        Momentum[k - p]]), "Output" -> $TimedOut|>, 
   <|"Index" -> 48, "Input" -> (DiracGamma[Momentum[k - p]] . 
        DiracGamma[LorentzIndex[ta]] . DiracGamma[Momentum[k - p]] . 
        DiracGamma[LorentzIndex[si]] . DiracGamma[LorentzIndex[rh]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[k, D] - 
           Momentum[p, D], mb]]^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
         Momentum[k, D] - Momentum[p, D], mb]]*Pair[LorentzIndex[la], 
        Momentum[k - p]])/4, "Output" -> $TimedOut|>, 
   <|"Index" -> 49, "Input" -> (mb^3*DiracGamma[LorentzIndex[si]] . 
        DiracGamma[LorentzIndex[la]]*FeynAmpDenominator[PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb]]^2*FeynAmpDenominator[
        PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb], 
        PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb]]*
       Pair[LorentzIndex[rh], LorentzIndex[ta]])/8, 
    "Output" -> -1/48*(G3*mb^3*mc*FeynAmpDenominator[PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
          Momentum[k, D], mc], PropagatorDenominator[Momentum[k, D], mc], 
         PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb], 
         PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb]]*
        Pair[Momentum[p], Momentum[p]])/(mb + mc)^2|>, 
   <|"Index" -> 50, "Input" -> (mb^2*DiracGamma[LorentzIndex[si]] . 
        DiracGamma[LorentzIndex[la]] . DiracGamma[Momentum[k - p]]*
       FeynAmpDenominator[PropagatorDenominator[Momentum[k, D] - 
           Momentum[p, D], mb]]^2*FeynAmpDenominator[PropagatorDenominator[
         Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
         Momentum[k, D] - Momentum[p, D], mb]]*Pair[LorentzIndex[rh], 
        LorentzIndex[ta]])/8, "Output" -> 
     -1/72*(G3*mb^2*FeynAmpDenominator[PropagatorDenominator[
           Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
           Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
           Momentum[k, D], mc], PropagatorDenominator[Momentum[k, D], mc], 
          PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb], 
          PropagatorDenominator[Momentum[k, D] - Momentum[p, D], mb]]*
         Pair[Momentum[k], Momentum[p]]^2)/(mb + mc)^2 + 
      (G3*mb^2*FeynAmpDenominator[PropagatorDenominator[Momentum[k, D] - 
           Momentum[p, D], mb], PropagatorDenominator[Momentum[k, D] - 
           Momentum[p, D], mb], PropagatorDenominator[Momentum[k, D], mc], 
         PropagatorDenominator[Momentum[k, D], mc], PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb]]*Pair[Momentum[k], 
         Momentum[k]]*Pair[Momentum[p], Momentum[p]])/(288*(mb + mc)^2) + 
      (G3*mb^2*FeynAmpDenominator[PropagatorDenominator[Momentum[k, D] - 
           Momentum[p, D], mb], PropagatorDenominator[Momentum[k, D] - 
           Momentum[p, D], mb], PropagatorDenominator[Momentum[k, D], mc], 
         PropagatorDenominator[Momentum[k, D], mc], PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb], PropagatorDenominator[
          Momentum[k, D] - Momentum[p, D], mb]]*Pair[Momentum[k], 
         Momentum[p]]*Pair[Momentum[p], Momentum[p]])/(96*(mb + mc)^2)|>}|>

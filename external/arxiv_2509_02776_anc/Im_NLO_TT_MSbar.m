(* Created with the Wolfram Language : www.wolfram.com *)
-1/72*(\[Alpha]s*HeavisideTheta[-(m1 + m2)^2 + s]*
   (Sqrt[Kallen\[Lambda][m1^2, m2^2, s]]*(176*m1^6*s + 352*m1^5*m2*s - 
      224*m1^4*m2^2*s - 800*m1^3*m2^3*s - 224*m1^2*m2^4*s + 352*m1*m2^5*s + 
      176*m2^6*s - 189*m1^4*s^2 - 458*m1^3*m2*s^2 - 490*m1^2*m2^2*s^2 - 
      458*m1*m2^3*s^2 - 189*m2^4*s^2 + 6*m1^2*s^3 + 274*m1*m2*s^3 + 
      6*m2^2*s^3 + 7*s^4 + (-46*m1^8 - 92*m1^7*m2 + 46*m2^8 + 
        2*m1^6*(46*m2^2 - 31*s) + 12*m1^5*m2*(23*m2^2 - 9*s) - 34*m2^6*s + 
        5*m2^4*s^2 - 20*m2^2*s^3 + 3*s^4 + m1^4*s*(66*m2^2 + 85*s) - 
        2*m1^3*m2*(138*m2^4 - 96*m2^2*s - 67*s^2) + 2*m1*m2*(m2^2 - s)*
         (46*m2^4 + 4*m2^2*s + 21*s^2) - 2*m1^2*(46*m2^6 - 15*m2^4*s - 
          39*m2^2*s^2 - 10*s^3))*Log[m1^2/s] + 
      (46*m1^8 + 92*m1^7*m2 + m1^4*s*(30*m2^2 + 5*s) - 
        2*m1^6*(46*m2^2 + 17*s) - 12*m1^5*(23*m2^3 + 7*m2*s) + 
        2*m1^3*m2*(138*m2^4 + 96*m2^2*s + 17*s^2) + 
        2*m1^2*(46*m2^6 + 33*m2^4*s + 39*m2^2*s^2 - 10*s^3) - 
        (m2^2 - s)*(46*m2^6 + 108*m2^4*s + 23*m2^2*s^2 + 3*s^3) - 
        2*m1*m2*(46*m2^6 + 54*m2^4*s - 67*m2^2*s^2 + 21*s^3))*Log[m2^2/s] + 
      96*m1^6*s*Log[mu^2/s] + 192*m1^5*m2*s*Log[mu^2/s] - 
      96*m1^4*m2^2*s*Log[mu^2/s] - 384*m1^3*m2^3*s*Log[mu^2/s] - 
      96*m1^2*m2^4*s*Log[mu^2/s] + 192*m1*m2^5*s*Log[mu^2/s] + 
      96*m2^6*s*Log[mu^2/s] - 90*m1^4*s^2*Log[mu^2/s] - 
      168*m1^3*m2*s^2*Log[mu^2/s] - 156*m1^2*m2^2*s^2*Log[mu^2/s] - 
      168*m1*m2^3*s^2*Log[mu^2/s] - 90*m2^4*s^2*Log[mu^2/s] + 
      84*m1*m2*s^3*Log[mu^2/s] - 6*s^4*Log[mu^2/s] - 
      96*m1^6*s*Log[1 - (4*m1^2*m2^2)/(m1^2 + m2^2 - s - 
            Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])^2] - 
      192*m1^5*m2*s*Log[1 - (4*m1^2*m2^2)/(m1^2 + m2^2 - s - 
            Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])^2] + 
      96*m1^4*m2^2*s*Log[1 - (4*m1^2*m2^2)/(m1^2 + m2^2 - s - 
            Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])^2] + 
      384*m1^3*m2^3*s*Log[1 - (4*m1^2*m2^2)/(m1^2 + m2^2 - s - 
            Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])^2] + 
      96*m1^2*m2^4*s*Log[1 - (4*m1^2*m2^2)/(m1^2 + m2^2 - s - 
            Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])^2] - 
      192*m1*m2^5*s*Log[1 - (4*m1^2*m2^2)/(m1^2 + m2^2 - s - 
            Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])^2] - 
      96*m2^6*s*Log[1 - (4*m1^2*m2^2)/(m1^2 + m2^2 - s - 
            Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])^2] + 
      144*m1^4*s^2*Log[1 - (4*m1^2*m2^2)/(m1^2 + m2^2 - s - 
            Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])^2] + 
      384*m1^3*m2*s^2*Log[1 - (4*m1^2*m2^2)/(m1^2 + m2^2 - s - 
            Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])^2] + 
      480*m1^2*m2^2*s^2*Log[1 - (4*m1^2*m2^2)/(m1^2 + m2^2 - s - 
            Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])^2] + 
      384*m1*m2^3*s^2*Log[1 - (4*m1^2*m2^2)/(m1^2 + m2^2 - s - 
            Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])^2] + 
      144*m2^4*s^2*Log[1 - (4*m1^2*m2^2)/(m1^2 + m2^2 - s - 
            Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])^2] - 
      192*m1*m2*s^3*Log[1 - (4*m1^2*m2^2)/(m1^2 + m2^2 - s - 
            Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])^2] - 
      48*s^4*Log[1 - (4*m1^2*m2^2)/(m1^2 + m2^2 - s - 
            Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])^2] + 
      24*m1^6*s*Log[1 - (2*m1^2)/(m1^2 + m2^2 - s - 
           Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] + 
      48*m1^5*m2*s*Log[1 - (2*m1^2)/(m1^2 + m2^2 - s - 
           Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] - 
      24*m1^4*m2^2*s*Log[1 - (2*m1^2)/(m1^2 + m2^2 - s - 
           Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] - 
      96*m1^3*m2^3*s*Log[1 - (2*m1^2)/(m1^2 + m2^2 - s - 
           Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] - 
      24*m1^2*m2^4*s*Log[1 - (2*m1^2)/(m1^2 + m2^2 - s - 
           Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] + 
      48*m1*m2^5*s*Log[1 - (2*m1^2)/(m1^2 + m2^2 - s - 
           Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] + 
      24*m2^6*s*Log[1 - (2*m1^2)/(m1^2 + m2^2 - s - 
           Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] - 
      36*m1^4*s^2*Log[1 - (2*m1^2)/(m1^2 + m2^2 - s - 
           Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] - 
      96*m1^3*m2*s^2*Log[1 - (2*m1^2)/(m1^2 + m2^2 - s - 
           Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] - 
      120*m1^2*m2^2*s^2*Log[1 - (2*m1^2)/(m1^2 + m2^2 - s - 
           Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] - 
      96*m1*m2^3*s^2*Log[1 - (2*m1^2)/(m1^2 + m2^2 - s - 
           Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] - 
      36*m2^4*s^2*Log[1 - (2*m1^2)/(m1^2 + m2^2 - s - 
           Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] + 
      48*m1*m2*s^3*Log[1 - (2*m1^2)/(m1^2 + m2^2 - s - 
           Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] + 
      12*s^4*Log[1 - (2*m1^2)/(m1^2 + m2^2 - s - Sqrt[Kallen\[Lambda][m1^2, 
             m2^2, s]])] + 24*m1^6*s*
       Log[1 - (2*m2^2)/(m1^2 + m2^2 - s - Sqrt[Kallen\[Lambda][m1^2, m2^2, 
             s]])] + 48*m1^5*m2*s*
       Log[1 - (2*m2^2)/(m1^2 + m2^2 - s - Sqrt[Kallen\[Lambda][m1^2, m2^2, 
             s]])] - 24*m1^4*m2^2*s*
       Log[1 - (2*m2^2)/(m1^2 + m2^2 - s - Sqrt[Kallen\[Lambda][m1^2, m2^2, 
             s]])] - 96*m1^3*m2^3*s*
       Log[1 - (2*m2^2)/(m1^2 + m2^2 - s - Sqrt[Kallen\[Lambda][m1^2, m2^2, 
             s]])] - 24*m1^2*m2^4*s*
       Log[1 - (2*m2^2)/(m1^2 + m2^2 - s - Sqrt[Kallen\[Lambda][m1^2, m2^2, 
             s]])] + 48*m1*m2^5*s*
       Log[1 - (2*m2^2)/(m1^2 + m2^2 - s - Sqrt[Kallen\[Lambda][m1^2, m2^2, 
             s]])] + 24*m2^6*s*Log[1 - (2*m2^2)/(m1^2 + m2^2 - s - 
           Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] - 
      36*m1^4*s^2*Log[1 - (2*m2^2)/(m1^2 + m2^2 - s - 
           Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] - 
      96*m1^3*m2*s^2*Log[1 - (2*m2^2)/(m1^2 + m2^2 - s - 
           Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] - 
      120*m1^2*m2^2*s^2*Log[1 - (2*m2^2)/(m1^2 + m2^2 - s - 
           Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] - 
      96*m1*m2^3*s^2*Log[1 - (2*m2^2)/(m1^2 + m2^2 - s - 
           Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] - 
      36*m2^4*s^2*Log[1 - (2*m2^2)/(m1^2 + m2^2 - s - 
           Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] + 
      48*m1*m2*s^3*Log[1 - (2*m2^2)/(m1^2 + m2^2 - s - 
           Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] + 
      12*s^4*Log[1 - (2*m2^2)/(m1^2 + m2^2 - s - Sqrt[Kallen\[Lambda][m1^2, 
             m2^2, s]])] + 46*m1^8*Log[(-2*m1^2)/(m1^2 + m2^2 - s - 
          Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] + 
      92*m1^7*m2*Log[(-2*m1^2)/(m1^2 + m2^2 - s - 
          Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] - 
      92*m1^6*m2^2*Log[(-2*m1^2)/(m1^2 + m2^2 - s - 
          Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] - 
      276*m1^5*m2^3*Log[(-2*m1^2)/(m1^2 + m2^2 - s - 
          Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] + 
      276*m1^3*m2^5*Log[(-2*m1^2)/(m1^2 + m2^2 - s - 
          Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] + 
      92*m1^2*m2^6*Log[(-2*m1^2)/(m1^2 + m2^2 - s - 
          Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] - 
      92*m1*m2^7*Log[(-2*m1^2)/(m1^2 + m2^2 - s - 
          Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] - 
      46*m2^8*Log[(-2*m1^2)/(m1^2 + m2^2 - s - Sqrt[Kallen\[Lambda][m1^2, 
            m2^2, s]])] + 14*m1^6*s*Log[(-2*m1^2)/(m1^2 + m2^2 - s - 
          Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] - 
      24*m1^5*m2*s*Log[(-2*m1^2)/(m1^2 + m2^2 - s - 
          Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] - 
      162*m1^4*m2^2*s*Log[(-2*m1^2)/(m1^2 + m2^2 - s - 
          Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] - 
      144*m1^3*m2^3*s*Log[(-2*m1^2)/(m1^2 + m2^2 - s - 
          Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] + 
      90*m1^2*m2^4*s*Log[(-2*m1^2)/(m1^2 + m2^2 - s - 
          Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] + 
      168*m1*m2^5*s*Log[(-2*m1^2)/(m1^2 + m2^2 - s - 
          Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] + 
      58*m2^6*s*Log[(-2*m1^2)/(m1^2 + m2^2 - s - Sqrt[Kallen\[Lambda][m1^2, 
            m2^2, s]])] - 76*m1^4*s^2*
       Log[(-2*m1^2)/(m1^2 + m2^2 - s - Sqrt[Kallen\[Lambda][m1^2, m2^2, 
            s]])] - 140*m1^3*m2*s^2*Log[(-2*m1^2)/(m1^2 + m2^2 - s - 
          Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] - 180*m1^2*m2^2*s^2*
       Log[(-2*m1^2)/(m1^2 + m2^2 - s - Sqrt[Kallen\[Lambda][m1^2, m2^2, 
            s]])] - 148*m1*m2^3*s^2*Log[(-2*m1^2)/(m1^2 + m2^2 - s - 
          Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] - 
      32*m2^4*s^2*Log[(-2*m1^2)/(m1^2 + m2^2 - s - 
          Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] - 
      2*m1^2*s^3*Log[(-2*m1^2)/(m1^2 + m2^2 - s - 
          Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] + 
      72*m1*m2*s^3*Log[(-2*m1^2)/(m1^2 + m2^2 - s - 
          Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] + 
      2*m2^2*s^3*Log[(-2*m1^2)/(m1^2 + m2^2 - s - 
          Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] + 
      18*s^4*Log[(-2*m1^2)/(m1^2 + m2^2 - s - Sqrt[Kallen\[Lambda][m1^2, 
            m2^2, s]])] - 46*m1^8*Log[(-2*m2^2)/(m1^2 + m2^2 - s - 
          Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] - 
      92*m1^7*m2*Log[(-2*m2^2)/(m1^2 + m2^2 - s - 
          Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] + 
      92*m1^6*m2^2*Log[(-2*m2^2)/(m1^2 + m2^2 - s - 
          Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] + 
      276*m1^5*m2^3*Log[(-2*m2^2)/(m1^2 + m2^2 - s - 
          Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] - 
      276*m1^3*m2^5*Log[(-2*m2^2)/(m1^2 + m2^2 - s - 
          Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] - 
      92*m1^2*m2^6*Log[(-2*m2^2)/(m1^2 + m2^2 - s - 
          Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] + 
      92*m1*m2^7*Log[(-2*m2^2)/(m1^2 + m2^2 - s - 
          Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] + 
      46*m2^8*Log[(-2*m2^2)/(m1^2 + m2^2 - s - Sqrt[Kallen\[Lambda][m1^2, 
            m2^2, s]])] + 58*m1^6*s*Log[(-2*m2^2)/(m1^2 + m2^2 - s - 
          Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] + 
      168*m1^5*m2*s*Log[(-2*m2^2)/(m1^2 + m2^2 - s - 
          Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] + 
      90*m1^4*m2^2*s*Log[(-2*m2^2)/(m1^2 + m2^2 - s - 
          Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] - 
      144*m1^3*m2^3*s*Log[(-2*m2^2)/(m1^2 + m2^2 - s - 
          Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] - 
      162*m1^2*m2^4*s*Log[(-2*m2^2)/(m1^2 + m2^2 - s - 
          Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] - 
      24*m1*m2^5*s*Log[(-2*m2^2)/(m1^2 + m2^2 - s - 
          Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] + 
      14*m2^6*s*Log[(-2*m2^2)/(m1^2 + m2^2 - s - Sqrt[Kallen\[Lambda][m1^2, 
            m2^2, s]])] - 32*m1^4*s^2*
       Log[(-2*m2^2)/(m1^2 + m2^2 - s - Sqrt[Kallen\[Lambda][m1^2, m2^2, 
            s]])] - 148*m1^3*m2*s^2*Log[(-2*m2^2)/(m1^2 + m2^2 - s - 
          Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] - 180*m1^2*m2^2*s^2*
       Log[(-2*m2^2)/(m1^2 + m2^2 - s - Sqrt[Kallen\[Lambda][m1^2, m2^2, 
            s]])] - 140*m1*m2^3*s^2*Log[(-2*m2^2)/(m1^2 + m2^2 - s - 
          Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] - 
      76*m2^4*s^2*Log[(-2*m2^2)/(m1^2 + m2^2 - s - 
          Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] + 
      2*m1^2*s^3*Log[(-2*m2^2)/(m1^2 + m2^2 - s - 
          Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] + 
      72*m1*m2*s^3*Log[(-2*m2^2)/(m1^2 + m2^2 - s - 
          Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] - 
      2*m2^2*s^3*Log[(-2*m2^2)/(m1^2 + m2^2 - s - 
          Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] + 
      18*s^4*Log[(-2*m2^2)/(m1^2 + m2^2 - s - Sqrt[Kallen\[Lambda][m1^2, 
            m2^2, s]])]) + 3*(m1^2 + 2*m1*m2 + m2^2 - s)*s*
     (8*m1^6*Log[1 - (2*m1^2)/(m1^2 + m2^2 - s - Sqrt[Kallen\[Lambda][m1^2, 
             m2^2, s]])] - 24*m1^4*m2^2*
       Log[1 - (2*m1^2)/(m1^2 + m2^2 - s - Sqrt[Kallen\[Lambda][m1^2, m2^2, 
             s]])] + 24*m1^2*m2^4*
       Log[1 - (2*m1^2)/(m1^2 + m2^2 - s - Sqrt[Kallen\[Lambda][m1^2, m2^2, 
             s]])] - 8*m2^6*Log[1 - (2*m1^2)/(m1^2 + m2^2 - s - 
           Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] - 
      4*m1^4*s*Log[1 - (2*m1^2)/(m1^2 + m2^2 - s - 
           Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] - 
      24*m1^3*m2*s*Log[1 - (2*m1^2)/(m1^2 + m2^2 - s - 
           Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] + 
      24*m1*m2^3*s*Log[1 - (2*m1^2)/(m1^2 + m2^2 - s - 
           Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] + 
      4*m2^4*s*Log[1 - (2*m1^2)/(m1^2 + m2^2 - s - 
           Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] - 
      8*m1^2*s^2*Log[1 - (2*m1^2)/(m1^2 + m2^2 - s - 
           Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] + 
      8*m2^2*s^2*Log[1 - (2*m1^2)/(m1^2 + m2^2 - s - 
           Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] - 
      8*m1^6*Log[1 - (2*m2^2)/(m1^2 + m2^2 - s - Sqrt[Kallen\[Lambda][m1^2, 
             m2^2, s]])] + 24*m1^4*m2^2*
       Log[1 - (2*m2^2)/(m1^2 + m2^2 - s - Sqrt[Kallen\[Lambda][m1^2, m2^2, 
             s]])] - 24*m1^2*m2^4*
       Log[1 - (2*m2^2)/(m1^2 + m2^2 - s - Sqrt[Kallen\[Lambda][m1^2, m2^2, 
             s]])] + 8*m2^6*Log[1 - (2*m2^2)/(m1^2 + m2^2 - s - 
           Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] + 
      4*m1^4*s*Log[1 - (2*m2^2)/(m1^2 + m2^2 - s - 
           Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] + 
      24*m1^3*m2*s*Log[1 - (2*m2^2)/(m1^2 + m2^2 - s - 
           Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] - 
      24*m1*m2^3*s*Log[1 - (2*m2^2)/(m1^2 + m2^2 - s - 
           Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] - 
      4*m2^4*s*Log[1 - (2*m2^2)/(m1^2 + m2^2 - s - 
           Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] + 
      8*m1^2*s^2*Log[1 - (2*m2^2)/(m1^2 + m2^2 - s - 
           Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] - 
      8*m2^2*s^2*Log[1 - (2*m2^2)/(m1^2 + m2^2 - s - 
           Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] + 
      12*m1^5*m2*Log[(-2*m1^2)/(m1^2 + m2^2 - s - 
          Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] + 
      16*m1^4*m2^2*Log[(-2*m1^2)/(m1^2 + m2^2 - s - 
          Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] - 
      24*m1^3*m2^3*Log[(-2*m1^2)/(m1^2 + m2^2 - s - 
          Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] - 
      8*m1^2*m2^4*Log[(-2*m1^2)/(m1^2 + m2^2 - s - 
          Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] + 
      12*m1*m2^5*Log[(-2*m1^2)/(m1^2 + m2^2 - s - 
          Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] + 
      8*m2^6*Log[(-2*m1^2)/(m1^2 + m2^2 - s - Sqrt[Kallen\[Lambda][m1^2, 
            m2^2, s]])] - 5*m1^4*s*Log[(-2*m1^2)/(m1^2 + m2^2 - s - 
          Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] - 
      12*m1^3*m2*s*Log[(-2*m1^2)/(m1^2 + m2^2 - s - 
          Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] - 
      12*m1^2*m2^2*s*Log[(-2*m1^2)/(m1^2 + m2^2 - s - 
          Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] - 
      36*m1*m2^3*s*Log[(-2*m1^2)/(m1^2 + m2^2 - s - 
          Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] - 
      9*m2^4*s*Log[(-2*m1^2)/(m1^2 + m2^2 - s - Sqrt[Kallen\[Lambda][m1^2, 
            m2^2, s]])] + 2*m1^2*s^2*Log[(-2*m1^2)/(m1^2 + m2^2 - s - 
          Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] + 
      24*m1*m2*s^2*Log[(-2*m1^2)/(m1^2 + m2^2 - s - 
          Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] - 
      6*m2^2*s^2*Log[(-2*m1^2)/(m1^2 + m2^2 - s - 
          Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] + 
      7*s^3*Log[(-2*m1^2)/(m1^2 + m2^2 - s - Sqrt[Kallen\[Lambda][m1^2, m2^2, 
            s]])] - 16*m1^6*Log[1 - (4*m1^2*m2^2)/
          (m1^2 + m2^2 - s - Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])^2]*
       Log[(-2*m1^2)/(m1^2 + m2^2 - s - Sqrt[Kallen\[Lambda][m1^2, m2^2, 
            s]])] + 16*m1^4*m2^2*
       Log[1 - (4*m1^2*m2^2)/(m1^2 + m2^2 - s - Sqrt[Kallen\[Lambda][m1^2, 
              m2^2, s]])^2]*Log[(-2*m1^2)/(m1^2 + m2^2 - s - 
          Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] + 
      16*m1^2*m2^4*Log[1 - (4*m1^2*m2^2)/(m1^2 + m2^2 - s - 
            Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])^2]*
       Log[(-2*m1^2)/(m1^2 + m2^2 - s - Sqrt[Kallen\[Lambda][m1^2, m2^2, 
            s]])] - 16*m2^6*Log[1 - (4*m1^2*m2^2)/
          (m1^2 + m2^2 - s - Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])^2]*
       Log[(-2*m1^2)/(m1^2 + m2^2 - s - Sqrt[Kallen\[Lambda][m1^2, m2^2, 
            s]])] + 24*m1^4*s*Log[1 - (4*m1^2*m2^2)/
          (m1^2 + m2^2 - s - Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])^2]*
       Log[(-2*m1^2)/(m1^2 + m2^2 - s - Sqrt[Kallen\[Lambda][m1^2, m2^2, 
            s]])] + 48*m1^3*m2*s*
       Log[1 - (4*m1^2*m2^2)/(m1^2 + m2^2 - s - Sqrt[Kallen\[Lambda][m1^2, 
              m2^2, s]])^2]*Log[(-2*m1^2)/(m1^2 + m2^2 - s - 
          Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] - 
      16*m1^2*m2^2*s*Log[1 - (4*m1^2*m2^2)/(m1^2 + m2^2 - s - 
            Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])^2]*
       Log[(-2*m1^2)/(m1^2 + m2^2 - s - Sqrt[Kallen\[Lambda][m1^2, m2^2, 
            s]])] + 48*m1*m2^3*s*
       Log[1 - (4*m1^2*m2^2)/(m1^2 + m2^2 - s - Sqrt[Kallen\[Lambda][m1^2, 
              m2^2, s]])^2]*Log[(-2*m1^2)/(m1^2 + m2^2 - s - 
          Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] + 
      24*m2^4*s*Log[1 - (4*m1^2*m2^2)/(m1^2 + m2^2 - s - 
            Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])^2]*
       Log[(-2*m1^2)/(m1^2 + m2^2 - s - Sqrt[Kallen\[Lambda][m1^2, m2^2, 
            s]])] - 48*m1*m2*s^2*
       Log[1 - (4*m1^2*m2^2)/(m1^2 + m2^2 - s - Sqrt[Kallen\[Lambda][m1^2, 
              m2^2, s]])^2]*Log[(-2*m1^2)/(m1^2 + m2^2 - s - 
          Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] - 
      8*s^3*Log[1 - (4*m1^2*m2^2)/(m1^2 + m2^2 - s - 
            Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])^2]*
       Log[(-2*m1^2)/(m1^2 + m2^2 - s - Sqrt[Kallen\[Lambda][m1^2, m2^2, 
            s]])] + 8*m1^6*Log[1 - (2*m1^2)/(m1^2 + m2^2 - s - 
           Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])]*
       Log[(-2*m1^2)/(m1^2 + m2^2 - s - Sqrt[Kallen\[Lambda][m1^2, m2^2, 
            s]])] - 8*m1^4*m2^2*Log[1 - (2*m1^2)/(m1^2 + m2^2 - s - 
           Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])]*
       Log[(-2*m1^2)/(m1^2 + m2^2 - s - Sqrt[Kallen\[Lambda][m1^2, m2^2, 
            s]])] - 8*m1^2*m2^4*Log[1 - (2*m1^2)/(m1^2 + m2^2 - s - 
           Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])]*
       Log[(-2*m1^2)/(m1^2 + m2^2 - s - Sqrt[Kallen\[Lambda][m1^2, m2^2, 
            s]])] + 8*m2^6*Log[1 - (2*m1^2)/(m1^2 + m2^2 - s - 
           Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])]*
       Log[(-2*m1^2)/(m1^2 + m2^2 - s - Sqrt[Kallen\[Lambda][m1^2, m2^2, 
            s]])] - 12*m1^4*s*Log[1 - (2*m1^2)/(m1^2 + m2^2 - s - 
           Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])]*
       Log[(-2*m1^2)/(m1^2 + m2^2 - s - Sqrt[Kallen\[Lambda][m1^2, m2^2, 
            s]])] - 24*m1^3*m2*s*
       Log[1 - (2*m1^2)/(m1^2 + m2^2 - s - Sqrt[Kallen\[Lambda][m1^2, m2^2, 
             s]])]*Log[(-2*m1^2)/(m1^2 + m2^2 - s - 
          Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] + 
      8*m1^2*m2^2*s*Log[1 - (2*m1^2)/(m1^2 + m2^2 - s - 
           Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])]*
       Log[(-2*m1^2)/(m1^2 + m2^2 - s - Sqrt[Kallen\[Lambda][m1^2, m2^2, 
            s]])] - 24*m1*m2^3*s*
       Log[1 - (2*m1^2)/(m1^2 + m2^2 - s - Sqrt[Kallen\[Lambda][m1^2, m2^2, 
             s]])]*Log[(-2*m1^2)/(m1^2 + m2^2 - s - 
          Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] - 
      12*m2^4*s*Log[1 - (2*m1^2)/(m1^2 + m2^2 - s - 
           Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])]*
       Log[(-2*m1^2)/(m1^2 + m2^2 - s - Sqrt[Kallen\[Lambda][m1^2, m2^2, 
            s]])] + 24*m1*m2*s^2*
       Log[1 - (2*m1^2)/(m1^2 + m2^2 - s - Sqrt[Kallen\[Lambda][m1^2, m2^2, 
             s]])]*Log[(-2*m1^2)/(m1^2 + m2^2 - s - 
          Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] + 
      4*s^3*Log[1 - (2*m1^2)/(m1^2 + m2^2 - s - Sqrt[Kallen\[Lambda][m1^2, 
             m2^2, s]])]*Log[(-2*m1^2)/(m1^2 + m2^2 - s - 
          Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] + 
      8*m1^6*Log[(-2*m2^2)/(m1^2 + m2^2 - s - Sqrt[Kallen\[Lambda][m1^2, 
            m2^2, s]])] + 12*m1^5*m2*Log[(-2*m2^2)/(m1^2 + m2^2 - s - 
          Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] - 
      8*m1^4*m2^2*Log[(-2*m2^2)/(m1^2 + m2^2 - s - 
          Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] - 
      24*m1^3*m2^3*Log[(-2*m2^2)/(m1^2 + m2^2 - s - 
          Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] + 
      16*m1^2*m2^4*Log[(-2*m2^2)/(m1^2 + m2^2 - s - 
          Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] + 
      12*m1*m2^5*Log[(-2*m2^2)/(m1^2 + m2^2 - s - 
          Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] - 
      9*m1^4*s*Log[(-2*m2^2)/(m1^2 + m2^2 - s - Sqrt[Kallen\[Lambda][m1^2, 
            m2^2, s]])] - 36*m1^3*m2*s*
       Log[(-2*m2^2)/(m1^2 + m2^2 - s - Sqrt[Kallen\[Lambda][m1^2, m2^2, 
            s]])] - 12*m1^2*m2^2*s*Log[(-2*m2^2)/(m1^2 + m2^2 - s - 
          Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] - 
      12*m1*m2^3*s*Log[(-2*m2^2)/(m1^2 + m2^2 - s - 
          Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] - 
      5*m2^4*s*Log[(-2*m2^2)/(m1^2 + m2^2 - s - Sqrt[Kallen\[Lambda][m1^2, 
            m2^2, s]])] - 6*m1^2*s^2*Log[(-2*m2^2)/(m1^2 + m2^2 - s - 
          Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] + 
      24*m1*m2*s^2*Log[(-2*m2^2)/(m1^2 + m2^2 - s - 
          Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] + 
      2*m2^2*s^2*Log[(-2*m2^2)/(m1^2 + m2^2 - s - 
          Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] + 
      7*s^3*Log[(-2*m2^2)/(m1^2 + m2^2 - s - Sqrt[Kallen\[Lambda][m1^2, m2^2, 
            s]])] - 16*m1^6*Log[1 - (4*m1^2*m2^2)/
          (m1^2 + m2^2 - s - Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])^2]*
       Log[(-2*m2^2)/(m1^2 + m2^2 - s - Sqrt[Kallen\[Lambda][m1^2, m2^2, 
            s]])] + 16*m1^4*m2^2*
       Log[1 - (4*m1^2*m2^2)/(m1^2 + m2^2 - s - Sqrt[Kallen\[Lambda][m1^2, 
              m2^2, s]])^2]*Log[(-2*m2^2)/(m1^2 + m2^2 - s - 
          Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] + 
      16*m1^2*m2^4*Log[1 - (4*m1^2*m2^2)/(m1^2 + m2^2 - s - 
            Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])^2]*
       Log[(-2*m2^2)/(m1^2 + m2^2 - s - Sqrt[Kallen\[Lambda][m1^2, m2^2, 
            s]])] - 16*m2^6*Log[1 - (4*m1^2*m2^2)/
          (m1^2 + m2^2 - s - Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])^2]*
       Log[(-2*m2^2)/(m1^2 + m2^2 - s - Sqrt[Kallen\[Lambda][m1^2, m2^2, 
            s]])] + 24*m1^4*s*Log[1 - (4*m1^2*m2^2)/
          (m1^2 + m2^2 - s - Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])^2]*
       Log[(-2*m2^2)/(m1^2 + m2^2 - s - Sqrt[Kallen\[Lambda][m1^2, m2^2, 
            s]])] + 48*m1^3*m2*s*
       Log[1 - (4*m1^2*m2^2)/(m1^2 + m2^2 - s - Sqrt[Kallen\[Lambda][m1^2, 
              m2^2, s]])^2]*Log[(-2*m2^2)/(m1^2 + m2^2 - s - 
          Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] - 
      16*m1^2*m2^2*s*Log[1 - (4*m1^2*m2^2)/(m1^2 + m2^2 - s - 
            Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])^2]*
       Log[(-2*m2^2)/(m1^2 + m2^2 - s - Sqrt[Kallen\[Lambda][m1^2, m2^2, 
            s]])] + 48*m1*m2^3*s*
       Log[1 - (4*m1^2*m2^2)/(m1^2 + m2^2 - s - Sqrt[Kallen\[Lambda][m1^2, 
              m2^2, s]])^2]*Log[(-2*m2^2)/(m1^2 + m2^2 - s - 
          Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] + 
      24*m2^4*s*Log[1 - (4*m1^2*m2^2)/(m1^2 + m2^2 - s - 
            Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])^2]*
       Log[(-2*m2^2)/(m1^2 + m2^2 - s - Sqrt[Kallen\[Lambda][m1^2, m2^2, 
            s]])] - 48*m1*m2*s^2*
       Log[1 - (4*m1^2*m2^2)/(m1^2 + m2^2 - s - Sqrt[Kallen\[Lambda][m1^2, 
              m2^2, s]])^2]*Log[(-2*m2^2)/(m1^2 + m2^2 - s - 
          Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] - 
      8*s^3*Log[1 - (4*m1^2*m2^2)/(m1^2 + m2^2 - s - 
            Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])^2]*
       Log[(-2*m2^2)/(m1^2 + m2^2 - s - Sqrt[Kallen\[Lambda][m1^2, m2^2, 
            s]])] + 8*m1^6*Log[1 - (2*m2^2)/(m1^2 + m2^2 - s - 
           Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])]*
       Log[(-2*m2^2)/(m1^2 + m2^2 - s - Sqrt[Kallen\[Lambda][m1^2, m2^2, 
            s]])] - 8*m1^4*m2^2*Log[1 - (2*m2^2)/(m1^2 + m2^2 - s - 
           Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])]*
       Log[(-2*m2^2)/(m1^2 + m2^2 - s - Sqrt[Kallen\[Lambda][m1^2, m2^2, 
            s]])] - 8*m1^2*m2^4*Log[1 - (2*m2^2)/(m1^2 + m2^2 - s - 
           Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])]*
       Log[(-2*m2^2)/(m1^2 + m2^2 - s - Sqrt[Kallen\[Lambda][m1^2, m2^2, 
            s]])] + 8*m2^6*Log[1 - (2*m2^2)/(m1^2 + m2^2 - s - 
           Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])]*
       Log[(-2*m2^2)/(m1^2 + m2^2 - s - Sqrt[Kallen\[Lambda][m1^2, m2^2, 
            s]])] - 12*m1^4*s*Log[1 - (2*m2^2)/(m1^2 + m2^2 - s - 
           Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])]*
       Log[(-2*m2^2)/(m1^2 + m2^2 - s - Sqrt[Kallen\[Lambda][m1^2, m2^2, 
            s]])] - 24*m1^3*m2*s*
       Log[1 - (2*m2^2)/(m1^2 + m2^2 - s - Sqrt[Kallen\[Lambda][m1^2, m2^2, 
             s]])]*Log[(-2*m2^2)/(m1^2 + m2^2 - s - 
          Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] + 
      8*m1^2*m2^2*s*Log[1 - (2*m2^2)/(m1^2 + m2^2 - s - 
           Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])]*
       Log[(-2*m2^2)/(m1^2 + m2^2 - s - Sqrt[Kallen\[Lambda][m1^2, m2^2, 
            s]])] - 24*m1*m2^3*s*
       Log[1 - (2*m2^2)/(m1^2 + m2^2 - s - Sqrt[Kallen\[Lambda][m1^2, m2^2, 
             s]])]*Log[(-2*m2^2)/(m1^2 + m2^2 - s - 
          Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] - 
      12*m2^4*s*Log[1 - (2*m2^2)/(m1^2 + m2^2 - s - 
           Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])]*
       Log[(-2*m2^2)/(m1^2 + m2^2 - s - Sqrt[Kallen\[Lambda][m1^2, m2^2, 
            s]])] + 24*m1*m2*s^2*
       Log[1 - (2*m2^2)/(m1^2 + m2^2 - s - Sqrt[Kallen\[Lambda][m1^2, m2^2, 
             s]])]*Log[(-2*m2^2)/(m1^2 + m2^2 - s - 
          Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] + 
      4*s^3*Log[1 - (2*m2^2)/(m1^2 + m2^2 - s - Sqrt[Kallen\[Lambda][m1^2, 
             m2^2, s]])]*Log[(-2*m2^2)/(m1^2 + m2^2 - s - 
          Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] - 
      16*(2*m1^6 + 2*m2^6 - 6*m1^3*m2*s - 3*m2^4*s + s^3 + 
        6*m1*m2*s*(-m2^2 + s) - m1^4*(2*m2^2 + 3*s) - 2*m1^2*(m2^4 - m2^2*s))*
       PolyLog[2, (4*m1^2*m2^2)/(m1^2 + m2^2 - s - 
           Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])^2] + 
      8*(2*m1^6 + 2*m2^6 - 6*m1^3*m2*s - 3*m2^4*s + s^3 + 
        6*m1*m2*s*(-m2^2 + s) - m1^4*(2*m2^2 + 3*s) - 2*m1^2*(m2^4 - m2^2*s))*
       PolyLog[2, (2*m1^2)/(m1^2 + m2^2 - s - Sqrt[Kallen\[Lambda][m1^2, 
            m2^2, s]])] + 16*m1^6*PolyLog[2, (2*m2^2)/(m1^2 + m2^2 - s - 
          Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] - 
      16*m1^4*m2^2*PolyLog[2, (2*m2^2)/(m1^2 + m2^2 - s - 
          Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] - 
      16*m1^2*m2^4*PolyLog[2, (2*m2^2)/(m1^2 + m2^2 - s - 
          Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] + 
      16*m2^6*PolyLog[2, (2*m2^2)/(m1^2 + m2^2 - s - 
          Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] - 
      24*m1^4*s*PolyLog[2, (2*m2^2)/(m1^2 + m2^2 - s - 
          Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] - 
      48*m1^3*m2*s*PolyLog[2, (2*m2^2)/(m1^2 + m2^2 - s - 
          Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] + 
      16*m1^2*m2^2*s*PolyLog[2, (2*m2^2)/(m1^2 + m2^2 - s - 
          Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] - 
      48*m1*m2^3*s*PolyLog[2, (2*m2^2)/(m1^2 + m2^2 - s - 
          Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] - 
      24*m2^4*s*PolyLog[2, (2*m2^2)/(m1^2 + m2^2 - s - 
          Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] + 
      48*m1*m2*s^2*PolyLog[2, (2*m2^2)/(m1^2 + m2^2 - s - 
          Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])] + 
      8*s^3*PolyLog[2, (2*m2^2)/(m1^2 + m2^2 - s - 
          Sqrt[Kallen\[Lambda][m1^2, m2^2, s]])])))/
  (Pi^2*(m1^2 + 2*m1*m2 + m2^2 - s)*s^2)

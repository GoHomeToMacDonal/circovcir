#!/usr/bin/env wolframscript
(* DIAGNOSTIC (not a certificate, not load-bearing): proved upper bounds delta*(eta=1/1024) for the LOC
   spread, by geometric bisection on delta of the 44 LOC systems, using the definitions of
   proofs/certificates/23c-n11-b9sharp-glob-loc.wls (loaded from its text up to the main section).
   Compare: wit_exact_J.py locscan printed delta*(1/1024) = 2.4466e-3 (m=5), 2.4907e-3 (m=4). *)
cert = FileNameJoin[{DirectoryName[$InputFileName], "..", "..", "..", "..", "proofs", "certificates", "23c-n11-b9sharp-glob-loc.wls"}];
txt = Import[cert, "Text"];
pre = First[StringSplit[txt, "(* ================= main ================= *)"]];
pre = StringReplace[pre, "#!/usr/bin/env wolframscript" -> ""];
ToExpression[pre];
Do[Module[{sysL, res},
   res = Table[Module[{a = 10^-6, b = 10^-2, c},
      Do[c = Rationalize[Sqrt[N[a b]], 10^-12];
        setupM[m, 10];
        If[certQ[locSystems[m, c][[i, 4]]], b = c, a = c], {14}];
      {locSystems[m, 0][[i, 1 ;; 3]], b}], {i, 44}];
   Print["m=", m, ": delta*(1/1024) = ", N[Max[res[[All, 2]]], 5], "  (L = ", N[Max[res[[All, 2]]]/eta, 4], "), worst triple {witness index, iota, e} = ",
     First[MaximalBy[res, Last]][[1]], ";  min over triples ", N[Min[res[[All, 2]]], 4]]], {m, {5, 4}}];

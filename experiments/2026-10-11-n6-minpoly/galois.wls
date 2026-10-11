(* Galois group of f9 (minimal polynomial of R6^2) is S9, hence R6 is not expressible by radicals.
   Dedekind: for p not dividing disc(f9)*lc, the degree pattern of f9 mod p is the cycle type of a
   Frobenius element of Gal(f9).  An element of type (5, k...) with all k coprime to 5 has a power
   that is a 5-cycle; a transitive group of degree 9 containing a 5-cycle is primitive (a 5-cycle
   cannot act on a block system of 3 blocks of size 3 except trivially), and by Jordan (5 <= 9-3)
   it contains A9.  A non-square discriminant then gives S9.
   Run: wolframscript -file galois.wls *)
f9 = 3072 t^9 + 54016 t^8 - 746832 t^7 + 5156603 t^6 - 19376280 t^5 + 41451480 t^4 -
   63156942 t^3 + 62607492 t^2 - 33449976 t + 7841367;
disc = Discriminant[f9, t];
Print["irreducible: ", IrreduciblePolynomialQ[f9]];
Print["disc = ", FactorInteger[disc]];
Print["disc is a square: ", IntegerQ[Sqrt[disc]]];
pats = Table[If[Mod[disc 3072, p] == 0, Nothing,
    p -> Sort[Exponent[#[[1]], t] & /@ Flatten[Table[#, {#[[2]]}] & /@ Rest[FactorList[f9, Modulus -> p]], 1], Greater]],
   {p, Prime[Range[3, 400]]}];
good = Select[pats, MemberQ[#[[2]], 5] && AllTrue[DeleteCases[#[[2]], 5, 1, 1], CoprimeQ[#, 5] &] &];
Print["first primes with a (5, coprime) pattern: ", Take[good, UpTo[3]]];
Print["pattern counts: ", ReverseSortBy[Tally[Last /@ pats], Last][[;; UpTo[12]]]];
Print["Gal(f9) = S9: ", IrreduciblePolynomialQ[f9] && Length[good] > 0 && ! IntegerQ[Sqrt[disc]]];
(* consequence for R6 itself: deg R6 = 18 and Q(R6^2) has no radical tower, so neither does Q(R6) *)

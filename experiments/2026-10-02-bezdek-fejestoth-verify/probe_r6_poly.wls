#!/usr/bin/env wolframscript
(* Probe: does the degree-8 polynomial quoted for the "six disks problem"
   (math.stackexchange.com/q/2651575) have a root near r6 = 1.7988...?
   P(x) = 6^4 x^8 + 2112 x^7 - 3480 x^6 + 1360 x^5 + 1665 x^4 - 1776 x^3 + 22 x^2 - 800 x + 5^4
   NOTE: the SE polynomial is in an UNKNOWN variable convention (could be r, 1/r, or a
   related length). This probe only CHECKS whether any real positive root matches 1.7988;
   it does not assert the polynomial is correct. Seed fixed (no randomness). *)

P[x_] := 6^4 x^8 + 2112 x^7 - 3480 x^6 + 1360 x^5 + 1665 x^4 - 1776 x^3 + 22 x^2 - 800 x + 5^4;

roots = x /. NSolve[P[x] == 0, x, WorkingPrecision -> 50];
realpos = Select[roots, Abs[Im[#]] < 10^-30 && Re[#] > 0 &];
Print["All real positive roots of P (50 digits):"];
Do[Print["  x = ", InputForm[Re[r]], "   1/x = ", InputForm[1/Re[r]]], {r, realpos}];

R6base = 1.790592575328908;
Print["baseline R6 (sub-record)   = ", InputForm[R6base]];
Print["target r6 (FT2005, 1.7988) = 1.7988..."];

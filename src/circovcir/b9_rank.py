"""Complete top-three radial-rank disjunction for ordered b=9 arcs.

u_0 is already a largest deficit (shortest outer radius). Choose indices i,j
for second/third largest deficits. All 8*7 cases are retained, with non-strict
inequalities so ties cannot fall through a gap. No reflection assumption.
"""
from __future__ import annotations

from fractions import Fraction as Q
from itertools import permutations

from .ordered_arcs import contract_radial_order, contract_simplex, radial_order_floors


def rank_cases():
    return tuple(permutations(range(1, 9), 2))


def checked_rank(rank):
    rank = tuple(rank)
    if len(rank) != 2 or any(type(i) is not int for i in rank) or rank not in rank_cases():
        raise ValueError("rank must specify distinct second/third indices in 1..8")
    return rank


def rank_edges(rank):
    i, j = checked_rank(rank)
    return ((0, i), (i, j), *((j, k) for k in range(1, 9) if k not in (i, j)))


def contract_ranked(radius, bounds, rank, *, dps=60):
    """Exact necessary bound contraction on a specified rank case.

    Besides pairwise bound consistency, x_i=t forces all predecessors >=t and
    all successors <=t. The sum=1 constraint then gives sharper individual
    bounds by solving a piecewise linear monotone capacity condition exactly.
    None denotes an empty necessary domain, not an inconclusive numerical LP.
    """
    i, j = checked_rank(rank)
    b = contract_radial_order(radius, bounds, dps=dps)
    if b is None:
        return None
    floors = radial_order_floors(radius, dps=dps)
    b = [list(p) for p in b]
    for k, floor in zip((0, i, j), floors, strict=True):
        b[k][0] = max(b[k][0], floor)
    edges = rank_edges(rank)
    ancestors = [{k} for k in range(18)]
    descendants = [{k} for k in range(18)]
    for _ in range(3):
        for a, z in edges:
            ancestors[z] |= ancestors[a]
            descendants[a] |= descendants[z]

    def upper_cap(lower, affected):
        # Largest t allowed by sum(max(lower[k],t), k in affected)+others <=1.
        ordered = sorted(lower[k] for k in affected)
        spare = 1-sum(lower)
        if spare < 0:
            return Q(-1)
        level = ordered[0]
        for n in range(1, len(ordered)):
            cost = n*(ordered[n]-level)
            if cost >= spare:
                return level+spare/n
            spare -= cost
            level = ordered[n]
        return level+spare/len(ordered)

    for _ in range(30):
        old = tuple(tuple(p) for p in b)
        for a, z in edges:
            b[a][0] = max(b[a][0], b[z][0])
            b[z][1] = min(b[z][1], b[a][1])
        if any(lo > hi for lo, hi in b):
            return None
        lower, upper = [p[0] for p in b], [p[1] for p in b]
        for k in range(18):
            b[k][1] = min(b[k][1], upper_cap(lower, ancestors[k]))
            # sum(min(upper[k],t))>=1 is equivalent after y=1-x:
            # sum(max(1-upper[k],1-t))+others <= 17.
            # Use the same water-fill with shifted total capacity.
            affected = descendants[k]
            ordered = sorted((upper[v] for v in affected), reverse=True)
            spare = sum(upper)-1
            if spare < 0:
                return None
            level = ordered[0]
            for n in range(1, len(ordered)):
                cost = n*(level-ordered[n])
                if cost >= spare:
                    level -= spare/n
                    break
                spare -= cost
                level = ordered[n]
            else:
                level -= spare/len(ordered)
            b[k][0] = max(b[k][0], level)
        if any(lo > hi for lo, hi in b):
            return None
        b = contract_simplex(b)
        if b is None or b == old:
            return b
        b = [list(p) for p in b]
    return tuple(tuple(p) for p in b)


# --- reflection involution (proofs/20 section 5) --------------------------------
# Reflection that fixes anchor 0 and reverses the cyclic order maps
#   u_k -> u_{-k mod 9},  v_k -> v_{-k-1 mod 9}   (v_k = overlap of arcs k, k+1)
# and therefore rank case (i, j) -> (9-i, 9-j).  A covering exists in a domain iff
# one exists in its mirror domain, so excluding one case of an orbit excludes both.

def reflect_index_map():
    """Position map on the 18 parameters (u_0..u_8, v_0..v_8)."""
    return tuple([(-k) % 9 for k in range(9)] + [9 + (-k - 1) % 9 for k in range(9)])


def reflect_parameters(values):
    """Apply the reflection to a length-18 sequence (floats, Fractions or bound pairs)."""
    values = list(values)
    if len(values) != 18:
        raise ValueError("expected 18 parameters")
    out = [None] * 18
    for src, dst in enumerate(reflect_index_map()):
        out[dst] = values[src]
    return out


def reflect_rank(rank):
    i, j = checked_rank(rank)
    return (9 - i, 9 - j)


def rank_orbit_representatives():
    """One case per reflection orbit (28 of the 56); the lexicographically smaller one."""
    return tuple(sorted({min(r, reflect_rank(r)) for r in rank_cases()}))

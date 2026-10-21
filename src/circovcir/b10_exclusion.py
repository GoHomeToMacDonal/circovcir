"""Leaf test L-a for b=10 (proofs/20 §16): residual cannot be covered by ONE unit disk.

Given exact Cartesian boxes for the ten boundary centers, a certificate is two or
three rational points of the target disk, each uniformly missed by every box
(``exclusion.check_witness``), that no single unit disk contains
(``exclusion.unit_disk_conflict``).  Then the eleventh disk cannot complete the
covering for any configuration in the box product.  Proposals use floats; the
check is exact.  None means unresolved, never "covered".
"""

from __future__ import annotations

from itertools import combinations

from .exclusion import check_witness, checked_boxes, residual_candidates, unit_disk_conflict


def _grid_residual(boxes, radius, n=181):
    import numpy as np

    R = float(radius)
    lo = np.array([[float(v) for v in b[0]] for b in boxes])
    hi = np.array([[float(v) for v in b[1]] for b in boxes])
    g = np.linspace(-R, R, n)
    X, Y = np.meshgrid(g, g)
    P = np.column_stack([X.ravel(), Y.ravel()])
    P = P[(P ** 2).sum(1) <= R * R * (1 - 1e-12)]
    delta = np.maximum(np.maximum(lo[None] - P[:, None], P[:, None] - hi[None]), 0)
    d2 = (delta ** 2).sum(2).min(1)
    return P[d2 > 1 + 1e-9]


def _farthest_candidates(boxes, radius):
    """Float proposal: residual diameter pair and widest triple (by circumradius)."""
    import numpy as np

    from .exclusion import rational_inside

    P = _grid_residual(boxes, radius)
    if len(P) < 2:
        return []
    if len(P) > 1500:
        P = P[np.random.default_rng(0).choice(len(P), 1500, replace=False)]
    D = np.linalg.norm(P[:, None] - P[None], axis=2)
    i, j = np.unravel_index(np.argmax(D), D.shape)
    out = [(i, j)]
    # third point maximizing min distance to the pair
    k = int(np.argmax(np.minimum(D[i], D[j])))
    out.append((i, j, k))
    return [[rational_inside(P[t], radius) for t in combo] for combo in out]


def propose_b10_exclusion(boxes, radius, *, limit=24):
    boxes = checked_boxes(boxes)
    for combo in _farthest_candidates(boxes, radius):
        if all(check_witness(boxes, radius, p) is not None for p in combo) \
                and unit_disk_conflict(combo):
            return {"points": [tuple(map(str, p)) for p in combo]}
    pts = residual_candidates(boxes, radius, limit=limit)
    for k in (2, 3):
        for combo in combinations(pts, k):
            if unit_disk_conflict(combo):
                cert = {"points": [tuple(map(str, p)) for p in combo]}
                if check_b10_exclusion(boxes, radius, cert):
                    return cert
    return None


def check_b10_exclusion(boxes, radius, certificate) -> bool:
    from fractions import Fraction

    boxes = checked_boxes(boxes)
    pts = [tuple(Fraction(v) for v in p) for p in certificate["points"]]
    if len(pts) not in (2, 3):
        return False
    if any(check_witness(boxes, radius, p) is None for p in pts):
        return False
    return unit_disk_conflict(pts)

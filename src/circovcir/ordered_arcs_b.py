"""Ordered irredundant boundary-arc parameterization for n=11 with b boundary disks.

Generalises ``ordered_arcs`` (b=9, proofs/13 §2) to any b; for b=10 see
proofs/20 §15-16.  Parameters x=(u_0..u_{b-1}, v_0..v_{b-1}) >= 0 with sum 1;
a = asin(1/R), D = b*a - pi > 0; arc half widths a - D*u_i, overlaps 2D*v_i;
the anchor (index 0) is a minimum-radius outer center fixed at angle 0.

All certificate quantities are outward-rounded mpmath intervals with exact
binary endpoints, exactly as in ``ordered_arcs``; for b=9 every function here
returns the same rational endpoints (tests/test_ordered_arcs_b.py).
"""

from __future__ import annotations

from fractions import Fraction as Q

from mpmath.ctx_iv import MPIntervalContext

from .ordered_arcs import _interval, _iv, endpoints

R_MIN = Q("2.63169")
R_MAX = Q("3.25")


def radius_interval(radius):
    lo, hi = map(Q, radius) if isinstance(radius, (list, tuple)) else (Q(radius), Q(radius))
    if not R_MIN <= lo <= hi <= R_MAX:
        raise ValueError(f"supported domain: {R_MIN} <= Rlo <= Rhi <= {R_MAX}")
    return lo, hi


def _check_b(b):
    if type(b) is not int or not 3 <= b <= 10:
        raise ValueError("b must be an int in 3..10")


def contract_simplex(bounds, b, *, anchor=True):
    """Exact bound consistency for sum(x)=1 and u_0>=u_i; None certifies emptiness."""
    _check_b(b)
    bb = [[Q(lo), Q(hi)] for lo, hi in bounds]
    if len(bb) != 2 * b or any(lo > hi for lo, hi in bb):
        raise ValueError(f"expected {2 * b} ordered intervals")
    for pair in bb:
        pair[0] = max(Q(0), pair[0])
        pair[1] = min(Q(1), pair[1])
    for _ in range(40):
        old = [p.copy() for p in bb]
        if any(lo > hi for lo, hi in bb):
            return None
        slo = sum(p[0] for p in bb)
        shi = sum(p[1] for p in bb)
        if slo > 1 or shi < 1:
            return None
        bb = [[max(lo, 1 - shi + hi), min(hi, 1 - slo + lo)] for lo, hi in bb]
        if anchor:
            bb[0][0] = max(bb[0][0], *(bb[i][0] for i in range(1, b)))
            for i in range(1, b):
                bb[i][1] = min(bb[i][1], bb[0][1])
        if bb == old:
            break
    if any(lo > hi for lo, hi in bb):
        return None
    return tuple(tuple(p) for p in bb)


def simplex_linear_range(bounds, coefficients, b):
    """Exact LP range of a linear functional on a box intersected with sum=1."""
    box = contract_simplex(bounds, b, anchor=False)
    c = tuple(map(Q, coefficients))
    if box is None or len(c) != 2 * b:
        raise ValueError("empty simplex or wrong coefficient dimension")

    def extreme(reverse):
        x = [p[0] for p in box]
        spare = 1 - sum(x)
        for i in sorted(range(2 * b), key=lambda i: c[i], reverse=reverse):
            take = min(spare, box[i][1] - box[i][0])
            x[i] += take
            spare -= take
        if spare != 0:
            raise ValueError("empty simplex")
        return sum(a * z for a, z in zip(c, x, strict=True))

    return extreme(False), extreme(True)


def constants(radius, b, *, dps=60):
    _check_b(b)
    lo, hi = radius_interval(radius)
    if dps < 30:
        raise ValueError("dps must be at least 30")
    ctx = MPIntervalContext()
    ctx.dps = dps
    r = _interval(ctx, lo, hi)
    a = ctx.atan2(1, ctx.sqrt(r * r - 1))
    deficit = b * a - ctx.pi
    if endpoints(deficit)[0] <= 0:
        raise ValueError("D = b*a - pi must be positive on the radius interval")
    return ctx, r, a, deficit


def radial_bounds(radius, b, index, parameter, *, dps=60):
    """Stable inverse image of one u interval (same formula as ordered_arcs)."""
    if type(index) is not int or not 0 <= index < b:
        raise ValueError(f"center index must be 0..{b - 1}")
    uvlo, uvhi = map(Q, parameter)
    if not 0 <= uvlo <= uvhi <= 1:
        raise ValueError("expected 0 <= ulo <= uhi <= 1")
    ctx, r, _, deficit = constants(radius, b, dps=dps)
    max_rad = ctx.sqrt(r * r - 1)
    radial_ends = []
    for uv in (uvlo, uvhi):
        loss = deficit * _iv(ctx, uv)
        co, si = ctx.cos(loss), ctx.sin(loss)
        first = 2 * ctx.sin(loss / 2) ** 2 + max_rad * si
        second = 1 + co - max_rad * si
        f0, f1 = endpoints(first)
        s0, s1 = endpoints(second)
        first = _interval(ctx, max(Q(0), f0), min(Q(1), f1))
        second = _interval(ctx, max(Q(1), s0), min(Q(2), s1))
        radial_ends.append(max_rad * co + si - ctx.sqrt(first * second))
    lo = max(radius_interval(radius)[0] - 1, endpoints(radial_ends[1])[0])
    hi = min(endpoints(max_rad)[1], endpoints(radial_ends[0])[1])
    return endpoints(_interval(ctx, lo, hi))


def ordered_polar_bounds(radius, b, bounds, *, dps=60):
    """Outward (radial, angular) intervals; angles via exact LP ranges."""
    bounds = contract_simplex(bounds, b)
    if bounds is None:
        return None
    ctx, r, a, deficit = constants(radius, b, dps=dps)
    boxes = []
    for j in range(b):
        radial = radial_bounds(radius, b, j, bounds[j], dps=dps)
        if j == 0:
            boxes.append((radial, (Q(0), Q(0))))
            continue
        coeff = [Q(0)] * (2 * b)
        coeff[0] = coeff[j] = Q(1)
        for i in range(1, j):
            coeff[i] = Q(2)
        for i in range(j):
            coeff[b + i] = Q(2)
        mass = _interval(ctx, *simplex_linear_range(bounds, coeff, b))
        angle = 2 * j * a - deficit * mass
        boxes.append((radial, endpoints(angle)))
    return tuple(boxes)


def ordered_center_boxes(radius, b, bounds, *, dps=60):
    """Cartesian enclosure of all centers for the radius/simplex domain."""
    polar = ordered_polar_bounds(radius, b, bounds, dps=dps)
    if polar is None:
        return None
    ctx, _, _, _ = constants(radius, b, dps=dps)
    boxes = []
    for radial, angle in polar:
        s, theta = _interval(ctx, *radial), _interval(ctx, *angle)
        xx, yy = endpoints(s * ctx.cos(theta)), endpoints(s * ctx.sin(theta))
        boxes.append(((xx[0], yy[0]), (xx[1], yy[1])))
    return tuple(boxes)


def decode_float(radius, b, parameters):
    """Diagnostic only: evaluate the ordered parameterization in float64."""
    import numpy as np

    _check_b(b)
    x = np.asarray(parameters, float)
    if x.shape != (2 * b,):
        raise ValueError(f"expected {2 * b} parameters")
    a = np.arcsin(1 / float(radius))
    deficit = b * a - np.pi
    width = a - deficit * x[:b]
    radial = float(radius) * np.cos(width) - np.sqrt(
        np.maximum(0, 1 - float(radius) ** 2 * np.sin(width) ** 2))
    gaps = 2 * a - deficit * (x[:b] + np.roll(x[:b], -1) + 2 * x[b:])
    angle = np.r_[0., np.cumsum(gaps[:-1])]
    return radial[:, None] * np.column_stack([np.cos(angle), np.sin(angle)])

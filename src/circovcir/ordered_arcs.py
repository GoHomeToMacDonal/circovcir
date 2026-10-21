"""Ordered irredundant boundary-arc parameterization for n=11, b=9.

All certificate bounds are outward rounded by an independent mpmath interval
context. Returned Cartesian boxes have exact rational endpoints. Float is used
only by the separate witness proposer. See proofs/13-n11-technical-route.md.

Parameters x=(u_0,...,u_8,v_0,...,v_8) are nonnegative and sum to 1.
Let a=asin(1/R), D=9a-pi. Arc half widths are a-D*u_i and successive
arc overlaps are 2D*v_i. The anchor is a minimum-radius outer center.
"""

from __future__ import annotations

from fractions import Fraction as Q

from mpmath.ctx_iv import MPIntervalContext


def _dyadic(t):
    sign, mantissa, exponent, bitcount = t
    if not isinstance(mantissa, int) or bitcount < 0 or exponent < -100000:
        raise ValueError("nonfinite interval endpoint")
    return (-1 if sign else 1)*Q(int(mantissa))*Q(2)**int(exponent)


def endpoints(interval):
    """Recover the exact binary endpoints, without decimal formatting."""
    return tuple(_dyadic(t) for t in interval._mpi_)


def _iv(ctx, x):
    x = Q(x)
    return ctx.mpf(x.numerator)/x.denominator


def _interval(ctx, lo, hi):
    return ctx.mpf([_iv(ctx, lo).a, _iv(ctx, hi).b])


def contract_simplex(bounds, *, anchor=True):
    """Exact bound consistency for sum(x)=1 and u_0>=u_i (i=1,...,8).

    No surviving feasible point is removed. None certifies an empty domain;
    a nonempty return does not certify feasibility of all nonlinear constraints.
    """
    b = [[Q(lo), Q(hi)] for lo, hi in bounds]
    if len(b) != 18 or any(lo > hi for lo, hi in b):
        raise ValueError("expected 18 ordered intervals")
    for pair in b:
        pair[0] = max(Q(0), pair[0])
        pair[1] = min(Q(1), pair[1])
    # A bounded number of monotone contractions suffices for soundness.
    for _ in range(40):
        old = [p.copy() for p in b]
        if any(lo > hi for lo, hi in b):
            return None
        slo = sum(p[0] for p in b)
        shi = sum(p[1] for p in b)
        if slo > 1 or shi < 1:
            return None
        b = [[max(lo, 1-shi+hi), min(hi, 1-slo+lo)] for lo, hi in b]
        if anchor:
            b[0][0] = max(b[0][0], *(b[i][0] for i in range(1, 9)))
            for i in range(1, 9):
                b[i][1] = min(b[i][1], b[0][1])
        if b == old:
            break
    if any(lo > hi for lo, hi in b):
        return None
    return tuple(tuple(p) for p in b)


def simplex_linear_range(bounds, coefficients):
    """Exact LP range of a linear functional on a box intersected with sum=1."""
    b = contract_simplex(bounds, anchor=False)
    c = tuple(map(Q, coefficients))
    if b is None or len(c) != 18:
        raise ValueError("empty simplex or wrong coefficient dimension")

    def extreme(reverse):
        x = [p[0] for p in b]
        spare = 1-sum(x)
        for i in sorted(range(18), key=lambda i: c[i], reverse=reverse):
            take = min(spare, b[i][1]-b[i][0])
            x[i] += take
            spare -= take
        if spare != 0:
            raise ValueError("empty simplex")
        return sum(a*z for a, z in zip(c, x, strict=True))

    return extreme(False), extreme(True)


def radius_interval(radius):
    """Validate a fixed radius or an exact closed radius interval."""
    lo, hi = map(Q, radius) if isinstance(radius, (list, tuple)) else (Q(radius), Q(radius))
    if not Q("2.63169") <= lo <= hi <= Q("2.82"):
        raise ValueError("supported domain: 2.63169 <= Rlo <= Rhi <= 2.82")
    return lo, hi


def constants(radius, *, dps=60):
    """Isolated outward interval context; radius may itself be an interval."""
    lo, hi = radius_interval(radius)
    if dps < 30:
        raise ValueError("dps must be at least 30")
    ctx = MPIntervalContext()
    ctx.dps = dps
    r = _interval(ctx, lo, hi)
    a = ctx.atan2(1, ctx.sqrt(r*r-1))
    deficit = 9*a-ctx.pi
    return ctx, r, a, deficit


def global_simplex(radius, *, dps=60):
    """One ordered global root, with the shortest radial center fixed at angle 0."""
    ctx, _, a, deficit = constants(radius, dps=dps)
    # w(R,2) decreases in R>sqrt(3); endpoint evaluation avoids dependency
    # blowup in (R^2+3)/(4R) on a broad radius interval.
    w2ends = []
    for endpoint in radius_interval(radius):
        r = _iv(ctx, endpoint)
        cosine = (r*r+3)/(4*r)
        w2ends.append(ctx.atan2(ctx.sqrt(1-cosine*cosine), cosine))
    w2 = _interval(ctx, endpoints(w2ends[1])[0], endpoints(w2ends[0])[1])
    anchor_min = endpoints((a-w2)/deficit)[0]
    if anchor_min > 1:
        return None
    bounds = [(Q(0), Q(1)) for _ in range(18)]
    bounds[0] = (max(Q(0), anchor_min), Q(1))
    return contract_radial_order(radius, bounds, dps=dps)


def radial_order_floors(radius, *, dps=60):
    """Necessary largest-three u thresholds from s_(k)<=1+R_(k+1).

    Uses exact R2=1, R3=2/sqrt(3), R4=sqrt(2); certificate 15b and
    proofs/15 supply the geometric argument. No ordering of u_1..u_8 is assumed.
    """
    ctx, _, a, deficit = constants(radius, dps=dps)
    caps = [ctx.mpf(2), 1+2/ctx.sqrt(3), 1+ctx.sqrt(2)]
    floors = []
    for cap in caps:
        widths = []
        for endpoint in radius_interval(radius):
            r = _iv(ctx, endpoint)
            co = (r*r+cap*cap-1)/(2*r*cap)
            widths.append(ctx.atan2(ctx.sqrt(1-co*co), co))
        width = _interval(ctx, endpoints(widths[1])[0], endpoints(widths[0])[1])
        floors.append(max(Q(0), endpoints((a-width)/deficit)[0]))
    return tuple(floors)


def contract_radial_order(radius, bounds, *, dps=60):
    """Safe exact contractions from order statistics, without fixing extra labels."""
    b = contract_simplex(bounds)
    if b is None:
        return None
    floors = radial_order_floors(radius, dps=dps)
    if sum(floors) > 1:
        return None
    for _ in range(8):
        old = b
        b = [list(p) for p in b]
        for k, threshold in enumerate(floors, 1):
            possible = [i for i in range(9) if b[i][1] >= threshold]
            if len(possible) < k:
                return None
            if len(possible) == k:
                for i in possible:
                    b[i][0] = max(b[i][0], threshold)
        # sum(u)>=sum(floors), hence sum(v)<=1-sum(floors).
        overlap_cap = 1-sum(floors)
        overlap_min = sum(b[i][0] for i in range(9, 18))
        if overlap_min > overlap_cap:
            return None
        for i in range(9, 18):
            b[i][1] = min(b[i][1], overlap_cap-overlap_min+b[i][0])
        if any(lo > hi for lo, hi in b):
            return None
        b = contract_simplex(b)
        if b is None or b == old:
            return b
    return b


def radial_bounds(radius, index, parameter, *, dps=60):
    """Stable inverse image for one u interval; no angular independence assumed."""
    if type(index) is not int or not 0 <= index < 9:
        raise ValueError("center index must be 0..8")
    uvlo, uvhi = map(Q, parameter)
    if not 0 <= uvlo <= uvhi <= 1:
        raise ValueError("expected 0 <= ulo <= uhi <= 1")
    ctx, r, _, deficit = constants(radius, dps=dps)
    max_rad = ctx.sqrt(r*r-1)
    radial_ends = []
    for uv in (uvlo, uvhi):
        # s decreases with u; factor the radical to retain exact zero at u=0.
        loss = deficit*_iv(ctx, uv)
        co, si = ctx.cos(loss), ctx.sin(loss)
        first = 2*ctx.sin(loss/2)**2+max_rad*si
        second = 1+co-max_rad*si
        f0, f1 = endpoints(first)
        s0, s1 = endpoints(second)
        first = _interval(ctx, max(Q(0), f0), min(Q(1), f1))
        second = _interval(ctx, max(Q(1), s0), min(Q(2), s1))
        radial_ends.append(max_rad*co+si-ctx.sqrt(first*second))
    lo = max(radius_interval(radius)[0]-1, endpoints(radial_ends[1])[0])
    hi = min(endpoints(max_rad)[1], endpoints(radial_ends[0])[1])
    return endpoints(_interval(ctx, lo, hi))


def ordered_polar_bounds(radius, bounds, *, dps=60):
    """Outward (radial, angular) intervals, preserving the stable radial inverse."""
    bounds = contract_simplex(bounds)
    if bounds is None:
        return None
    ctx, r, a, deficit = constants(radius, dps=dps)
    boxes = []
    for j in range(9):
        radial = radial_bounds(radius, j, bounds[j], dps=dps)
        if j == 0:
            boxes.append((radial, (Q(0), Q(0))))
            continue
        coeff = [Q(0)]*18
        coeff[0] = coeff[j] = Q(1)
        for i in range(1, j):
            coeff[i] = Q(2)
        for i in range(j):
            coeff[9+i] = Q(2)
        mass = _interval(ctx, *simplex_linear_range(bounds, coeff))
        angle = 2*j*a-deficit*mass
        boxes.append((radial, endpoints(angle)))
    return tuple(boxes)


def ordered_center_boxes(radius, bounds, *, dps=60):
    """Cartesian enclosure of the entire radius/simplex domain; no symmetry assumed."""
    polar = ordered_polar_bounds(radius, bounds, dps=dps)
    if polar is None:
        return None
    ctx, _, _, _ = constants(radius, dps=dps)
    boxes = []
    for radial, angle in polar:
        s, theta = _interval(ctx, *radial), _interval(ctx, *angle)
        xx, yy = endpoints(s*ctx.cos(theta)), endpoints(s*ctx.sin(theta))
        boxes.append(((xx[0], yy[0]), (xx[1], yy[1])))
    return tuple(boxes)


def decode_float(radius, parameters):
    """Diagnostic only: evaluate the ordered parameterization in float64."""
    import numpy as np

    x = np.asarray(parameters, float)
    if x.shape != (18,):
        raise ValueError("expected 18 parameters")
    a = np.arcsin(1/float(radius))
    deficit = 9*a-np.pi
    width = a-deficit*x[:9]
    radial = float(radius)*np.cos(width)-np.sqrt(
        np.maximum(0, 1-float(radius)**2*np.sin(width)**2))
    gaps = 2*a-deficit*(x[:9]+np.roll(x[:9], -1)+2*x[9:])
    angle = np.r_[0., np.cumsum(gaps[:-1])]
    return radial[:, None]*np.column_stack([np.cos(angle), np.sin(angle)])

"""circovcir -- n unit circles covering the largest circle."""

from .arcs import covered_arc, max_covered_arc, ring_alpha, ring_config, ring_radius
from .geometry import (
    candidate_points,
    covering_radius,
    is_covered,
    max_covered_radius,
    tight_points,
)

__all__ = ["candidate_points", "covering_radius", "is_covered", "max_covered_radius",
           "tight_points", "covered_arc", "max_covered_arc", "ring_alpha", "ring_config",
           "ring_radius"]

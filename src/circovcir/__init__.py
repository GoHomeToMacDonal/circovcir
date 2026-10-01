"""circovcir -- n unit circles covering the largest circle."""

from .geometry import (
    candidate_points,
    covering_radius,
    is_covered,
    max_covered_radius,
    tight_points,
)

__all__ = ["candidate_points", "covering_radius", "is_covered", "max_covered_radius",
           "tight_points"]

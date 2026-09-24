#ifndef GFANLIB_GROEBNER_WALK_H
#define GFANLIB_GROEBNER_WALK_H

#include "Singular/subexpr.h"

/**
 * Generic Groebner walk towards the ordering of currRing.
 *
 * The first argument is a source-ring standard basis mapped into currRing;
 * the second argument is its source ring.  Facets are oriented using exact
 * comparisons in the target term ordering instead of a large perturbation
 * weight vector.
 */
BOOLEAN genericGroebnerWalk(leftv result, leftv args);

/** As genericGroebnerWalk, but return the basis and its representation in
 * terms of the input source basis. */
BOOLEAN genericGroebnerWalkLift(leftv result, leftv args);

#endif

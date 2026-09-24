#include "groebnerWalk.h"

#include <vector>
#include <stdexcept>
#include <cstring>

#include "kernel/GBEngine/kstd1.h"
#include "kernel/groebner_walk/walkSupport.h"
#include "kernel/ideals.h"
#include "misc/int64vec.h"
#include "misc/options.h"
#include "Singular/attrib.h"
#include "Singular/ipid.h"
#include "Singular/ipshell.h"
#include "Singular/lists.h"
#include "polys/matpol.h"
#include "polys/monomials/p_polys.h"
#include "polys/monomials/ring.h"
#include "polys/prCopy.h"
#include "gfanlib/gfanlib.h"

class WalkOptionGuard
{
private:
  BITSET savedOptions1;
  BITSET savedOptions2;

public:
  WalkOptionGuard()
  {
    SI_SAVE_OPT(savedOptions1, savedOptions2);
  }

  ~WalkOptionGuard()
  {
    SI_RESTORE_OPT(savedOptions1, savedOptions2);
  }
};

static bool supportedWalkOrder(const ring r)
{
  for (int i = 0; r->order[i] != ringorder_no; ++i)
  {
    switch (r->order[i])
    {
      case ringorder_lp:
      case ringorder_dp:
      case ringorder_Dp:
      case ringorder_wp:
      case ringorder_Wp:
      case ringorder_C:
        break;
      case ringorder_M:
        if (i != 0)
          return false;
        break;
      default:
        return false;
    }
  }
  return true;
}

static bool compatibleWalkRings(const ring source, const ring target)
{
  if ((source == NULL) || (target == NULL))
  {
    WerrorS("groebnerWalk: invalid source or target ring");
    return false;
  }
  if ((source->qideal != NULL) || (target->qideal != NULL))
  {
    WerrorS("groebnerWalk: quotient rings are not supported");
    return false;
  }
  if (rHasLocalOrMixedOrdering(source) || rHasLocalOrMixedOrdering(target))
  {
    WerrorS("groebnerWalk: source and target orderings must be global");
    return false;
  }
  if (!supportedWalkOrder(source) || !supportedWalkOrder(target))
  {
    WerrorS("groebnerWalk: unsupported ordering block");
    return false;
  }
  if (rField_is_Ring(source) || rField_is_Ring(target))
  {
    WerrorS("groebnerWalk: coefficient domains are not supported");
    return false;
  }
  if ((rVar(source) != rVar(target)) || (rPar(source) != rPar(target)))
  {
    WerrorS("groebnerWalk: source and target rings have different dimensions");
    return false;
  }
  for (int i = 0; i < rVar(source); ++i)
    if (strcmp(source->names[i], target->names[i]) != 0)
    {
      WerrorS("groebnerWalk: variable names and positions must agree");
      return false;
    }
  for (int i = 0; i < rPar(source); ++i)
    if (strcmp(source->cf->extRing->names[i],
               target->cf->extRing->names[i]) != 0)
    {
      WerrorS("groebnerWalk: parameter names and positions must agree");
      return false;
    }
  if (n_SetMap(target->cf, source->cf) == NULL
      || n_SetMap(source->cf, target->cf) == NULL)
  {
    WerrorS("groebnerWalk: coefficient fields are incompatible");
    return false;
  }
  return true;
}

static ideal copyIdealToRing(const ideal input, const ring from, const ring to)
{
  nMapFunc coefficientMap = n_SetMap(from->cf, to->cf);
  ideal output = idInit(IDELEMS(input), input->rank);
  for (int i = 0; i < IDELEMS(input); ++i)
    if (input->m[i] != NULL)
      output->m[i] = p_PermPoly(input->m[i], NULL, from, to,
                                coefficientMap, NULL, 0);
  return output;
}

static gfan::ZMatrix orderMatrix(const ring r)
{
  const int n = rVar(r);
  int64vec* raw = rGetGlobalOrderMatrix(r);
  gfan::ZMatrix result(n, n);
  for (int i = 0; i < n; ++i)
    for (int j = 0; j < n; ++j)
      result[i][j] = gfan::Integer((*raw)[i*n+j]);
  delete raw;
  gfan::ZMatrix rankTest(result);
  if (rankTest.reduceAndComputeRank() != n)
    throw std::runtime_error("ordering matrix does not have full rank");
  return result;
}

/* Sign of d in the group order represented by the rows of M. */
static int orderSign(const gfan::ZVector& d, const gfan::ZMatrix& M)
{
  for (int i = 0; i < M.getHeight(); ++i)
  {
    gfan::Integer value;
    for (int j = 0; j < M.getWidth(); ++j)
      value.madd(M[i][j], d[j]);
    if (value.sign() != 0)
      return value.sign();
  }
  return 0;
}

/*
 * Facet preorder (Fukuda--Jensen--Lauritzen--Thomas, equation (3)):
 *   u < v  iff  T*u*v^t <_source T*v*u^t.
 * It is the exact symbolic replacement for comparing crossing parameters.
 */
static bool facetLess(const gfan::ZVector& u, const gfan::ZVector& v,
                      const gfan::ZMatrix& sourceOrder,
                      const gfan::ZMatrix& targetOrder)
{
  for (int i = 0; i < targetOrder.getHeight(); ++i)
  {
    gfan::Integer targetU;
    gfan::Integer targetV;
    for (int j = 0; j < targetOrder.getWidth(); ++j)
    {
      targetU.madd(targetOrder[i][j], u[j]);
      targetV.madd(targetOrder[i][j], v[j]);
    }

    gfan::ZVector difference(u.size());
    for (unsigned j = 0; j < u.size(); ++j)
      difference[j] = targetU*v[j] - targetV*u[j];
    const int comparison = orderSign(difference, sourceOrder);
    if (comparison != 0)
      return comparison < 0;
  }
  return false;
}

static gfan::ZVector exponentVector(const poly term, const ring r)
{
  const int n = rVar(r);
  gfan::ZVector result(n);
  for (int i = 0; i < n; ++i)
    result[i] = gfan::Integer(p_GetExp(term, i + 1, r));
  return result;
}

static bool hasExponent(const poly term, const gfan::ZVector& exponent,
                        const ring r)
{
  for (int i = 0; i < rVar(r); ++i)
    if (gfan::Integer(p_GetExp(term, i + 1, r)) != exponent[i])
      return false;
  return true;
}

static poly markedTerm(const poly polynomial,
                       const gfan::ZVector& mark, const ring r)
{
  for (poly term = polynomial; term != NULL; pIter(term))
    if (hasExponent(term, mark, r))
      return term;
  return NULL;
}

static void normalizeMarkedPolynomial(poly& polynomial,
                                      const gfan::ZVector& mark,
                                      matrix representation,
                                      const int column, const ring r)
{
  poly marked = markedTerm(polynomial, mark, r);
  if (marked == NULL)
    throw std::runtime_error("marked term disappeared during the walk");
  if (n_IsOne(p_GetCoeff(marked, r), r->cf))
    return;

  number coefficient = n_Copy(p_GetCoeff(marked, r), r->cf);
  number inverse = n_Invers(coefficient, r->cf);
  polynomial = p_Mult_nn(polynomial, inverse, r);
  for (int row = 1; row <= MATROWS(representation); ++row)
    MATELEM(representation, row, column)
      = p_Mult_nn(MATELEM(representation, row, column), inverse, r);
  n_Delete(&inverse, r->cf);
  n_Delete(&coefficient, r->cf);
}

/* Autoreduction using the distinguished terms rather than the head terms in
 * the storage ring.  This is step (vi) of the generic walk algorithm. */
static void markedAutoreduce(ideal basis,
                             const std::vector<gfan::ZVector>& marks,
                             matrix representation,
                             const ring r)
{
  if (marks.size() != (unsigned)IDELEMS(basis))
    throw std::runtime_error("inconsistent marking during the walk");
  if (MATCOLS(representation) != IDELEMS(basis))
    throw std::runtime_error("inconsistent representation during the walk");

  for (int i = 0; i < IDELEMS(basis); ++i)
  {
    if (basis->m[i] == NULL)
      throw std::runtime_error("zero polynomial in a marked basis");
    normalizeMarkedPolynomial(basis->m[i], marks[i], representation, i + 1,
                              r);
  }

  for (int i = 0; i < IDELEMS(basis); ++i)
  {
    std::vector<poly> divisors;
    divisors.reserve(IDELEMS(basis));
    for (int j = 0; j < IDELEMS(basis); ++j)
      divisors.push_back(markedTerm(basis->m[j], marks[j], r));

    bool reduced = false;
    while (!reduced)
    {
      reduced = true;
      for (poly term = basis->m[i]; term != NULL && reduced; pIter(term))
      {
        if (hasExponent(term, marks[i], r))
          continue;

        for (int j = 0; j < IDELEMS(basis); ++j)
        {
          if (i == j)
            continue;
          poly divisor = divisors[j];
          if (!p_LmDivisibleByNoComp(divisor, term, r))
            continue;

          poly factor = p_DivideM(p_Head(term, r),
                                  p_Head(divisor, r), r);
          basis->m[i] = p_Minus_mm_Mult_qq(basis->m[i], factor,
                                           basis->m[j], r);
          for (int row = 1; row <= MATROWS(representation); ++row)
            MATELEM(representation, row, i + 1)
              = p_Minus_mm_Mult_qq(MATELEM(representation, row, i + 1),
                                   factor,
                                   MATELEM(representation, row, j + 1), r);
          p_Delete(&factor, r);
          reduced = false;
          break;
        }
      }
    }
  }
}

static bool equivalentFacets(const gfan::ZVector& u,
                             const gfan::ZVector& v,
                             const gfan::ZMatrix& sourceOrder,
                             const gfan::ZMatrix& targetOrder)
{
  return !facetLess(u, v, sourceOrder, targetOrder)
      && !facetLess(v, u, sourceOrder, targetOrder);
}

static bool nextFacet(const ideal basis,
                      const std::vector<gfan::ZVector>& marks,
                      const bool haveLast,
                      const gfan::ZVector& last,
                      const gfan::ZMatrix& sourceOrder,
                      const gfan::ZMatrix& targetOrder,
                      const ring r,
                      gfan::ZVector& result)
{
  bool found = false;
  for (int i = 0; i < IDELEMS(basis); ++i)
  {
    for (poly term = basis->m[i]; term != NULL; pIter(term))
    {
      const gfan::ZVector difference = marks[i] - exponentVector(term, r);
      if ((orderSign(difference, sourceOrder) <= 0)
          || (orderSign(difference, targetOrder) >= 0)
          || (haveLast && !facetLess(last, difference,
                                     sourceOrder, targetOrder)))
        continue;
      if (!found || facetLess(difference, result, sourceOrder, targetOrder))
      {
        result = difference;
        found = true;
      }
    }
  }
  return found;
}

static ideal markedInitialForms(const ideal basis,
                                const std::vector<gfan::ZVector>& marks,
                                const gfan::ZVector& facet,
                                const gfan::ZMatrix& sourceOrder,
                                const gfan::ZMatrix& targetOrder,
                                const ring r)
{
  ideal result = idInit(IDELEMS(basis), basis->rank);
  for (int i = 0; i < IDELEMS(basis); ++i)
  {
    poly initialForm = NULL;
    for (poly term = basis->m[i]; term != NULL; pIter(term))
    {
      const gfan::ZVector difference = marks[i] - exponentVector(term, r);
      if ((difference == gfan::ZVector(difference.size()))
          || equivalentFacets(difference, facet, sourceOrder, targetOrder))
        initialForm = p_Add_q(initialForm, p_Head(term, r), r);
    }
    result->m[i] = initialForm;
  }
  return result;
}

static ideal walkToTarget(const ideal inputInTarget, const ring source,
                          const ring target, matrix* resultRepresentation)
{
  const gfan::ZMatrix sourceOrder = orderMatrix(source);
  const gfan::ZMatrix targetOrder = orderMatrix(target);
  ideal sourceBasis = copyIdealToRing(inputInTarget, target, source);
  idSkipZeroes(sourceBasis);
  ideal current = id_Copy(inputInTarget, target);
  idSkipZeroes(current);
  matrix representation=mpNew(IDELEMS(current),IDELEMS(current));
  for (int i=1;i<=IDELEMS(current);++i)
    MATELEM(representation,i,i)=p_One(target);
  if ((IDELEMS(sourceBasis) == 1) && (sourceBasis->m[0] == NULL))
  {
    id_Delete(&sourceBasis, source);
    if (resultRepresentation!=NULL)
      *resultRepresentation=representation;
    else
      id_Delete((ideal*)&representation,target);
    return current;
  }
  if (IDELEMS(sourceBasis) != IDELEMS(current))
  {
    id_Delete(&sourceBasis, source);
    id_Delete(&current, target);
    id_Delete((ideal*)&representation,target);
    throw std::runtime_error("source basis changed while mapping rings");
  }

  std::vector<gfan::ZVector> marks;
  marks.reserve(IDELEMS(sourceBasis));
  for (int i = 0; i < IDELEMS(sourceBasis); ++i)
  {
    if (sourceBasis->m[i] == NULL)
    {
      id_Delete(&sourceBasis, source);
      id_Delete(&current, target);
      id_Delete((ideal*)&representation,target);
      throw std::runtime_error("zero polynomial in the source basis");
    }
    marks.push_back(exponentVector(sourceBasis->m[i], source));
  }
  id_Delete(&sourceBasis, source);

  gfan::ZVector last(rVar(target));
  bool haveLast = false;

  WalkOptionGuard optionGuard;
  si_opt_1 |= Sy_bit(OPT_REDSB) | Sy_bit(OPT_REDTAIL);
  rChangeCurrRing(target);

  const int maximumSteps = 100000;
  int step = 0;
  for (; step < maximumSteps; ++step)
  {
    gfan::ZVector facet(rVar(target));
    if (!nextFacet(current, marks, haveLast, last,
                   sourceOrder, targetOrder, target, facet))
      break;

    ideal initialForms = markedInitialForms(current, marks, facet,
                                            sourceOrder, targetOrder, target);
    matrix transformation = NULL;
    ideal initialBasis = idLiftStd(initialForms, &transformation);
    matrix nextMatrix = mp_Mult((matrix)current, transformation, target);
    matrix nextRepresentation=mp_Mult(representation,transformation,target);

    std::vector<gfan::ZVector> nextMarks;
    nextMarks.reserve(IDELEMS(initialBasis));
    for (int i = 0; i < IDELEMS(initialBasis); ++i)
    {
      if (initialBasis->m[i] == NULL)
      {
        id_Delete(&initialForms, target);
        id_Delete(&initialBasis, target);
        id_Delete((ideal*)&transformation, target);
        id_Delete((ideal*)&nextMatrix, target);
        id_Delete((ideal*)&nextRepresentation, target);
        id_Delete(&current, target);
        id_Delete((ideal*)&representation, target);
        throw std::runtime_error("zero polynomial in an intermediate basis");
      }
      nextMarks.push_back(exponentVector(initialBasis->m[i], target));
    }

    id_Delete(&initialForms, target);
    id_Delete(&initialBasis, target);
    id_Delete((ideal*)&transformation, target);
    id_Delete(&current, target);
    id_Delete((ideal*)&representation, target);
    current = (ideal)nextMatrix;
    representation=nextRepresentation;
    marks.swap(nextMarks);
    markedAutoreduce(current, marks, representation, target);
    last = facet;
    haveLast = true;

    if (printlevel > 0)
      Print("// generic Groebner walk: step %d, basis size %d\n",
            step + 1, IDELEMS(current));
  }

  if (step == maximumSteps)
  {
    id_Delete(&current, target);
    id_Delete((ideal*)&representation,target);
    throw std::runtime_error("generic Groebner walk exceeded its step limit");
  }

  for (int i=0;i<IDELEMS(current);++i)
    if (!hasExponent(current->m[i],marks[i],target))
    {
      id_Delete(&current,target);
      id_Delete((ideal*)&representation,target);
      throw std::runtime_error("walk ended before reaching the target order");
    }

  if (resultRepresentation!=NULL)
    *resultRepresentation=representation;
  else
    id_Delete((ideal*)&representation,target);
  return current;
}

static bool walkArguments(leftv args, ring& source, ring& target)
{
  if ((args == NULL) || (args->Typ() != IDEAL_CMD)
      || (args->next == NULL) || (args->next->Typ() != RING_CMD)
      || (args->next->next != NULL))
  {
    WerrorS("groebnerWalk: expected a mapped source basis and its source ring");
    return false;
  }

  target = currRing;
  source = (ring)args->next->Data();
  return compatibleWalkRings(source,target);
}

BOOLEAN genericGroebnerWalk(leftv result, leftv args)
{
  ring source;
  ring target;
  if (!walkArguments(args,source,target))
    return TRUE;

  try
  {
    ideal walked = walkToTarget((ideal)args->Data(),source,target,NULL);
    rChangeCurrRing(target);
    result->rtyp = IDEAL_CMD;
    result->data = walked;
    setFlag(result, FLAG_STD);
    return FALSE;
  }
  catch (const std::exception& exception)
  {
    rChangeCurrRing(target);
    Werror("groebnerWalk: %s", exception.what());
    return TRUE;
  }
}

BOOLEAN genericGroebnerWalkLift(leftv result, leftv args)
{
  ring source;
  ring target;
  if (!walkArguments(args,source,target))
    return TRUE;

  try
  {
    matrix representation=NULL;
    ideal walked=walkToTarget((ideal)args->Data(),source,target,
                              &representation);
    rChangeCurrRing(target);

    lists output=(lists)omAllocBin(slists_bin);
    output->Init(2);
    output->m[0].rtyp=IDEAL_CMD;
    output->m[0].data=walked;
    setFlag(&output->m[0],FLAG_STD);
    output->m[1].rtyp=MATRIX_CMD;
    output->m[1].data=representation;
    result->rtyp=LIST_CMD;
    result->data=output;
    return FALSE;
  }
  catch (const std::exception& exception)
  {
    rChangeCurrRing(target);
    Werror("groebnerWalk: %s",exception.what());
    return TRUE;
  }
}

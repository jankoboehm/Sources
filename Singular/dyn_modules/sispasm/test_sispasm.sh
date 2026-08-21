#!/bin/sh

result=$("$SINGULAR_BIN_DIR/Singular" -q -c '
ring r=32003,(x,y,z),dp;
int spasmAdvertised=system("with","spasm");
LIB "sheafcoh.lib";
// Also support a developer-tree module built with explicit SpaSM flags while
// the main executable still reflects an older configure result.
if (!defined(spasm_first_kernel_vector))
{
  load("sispasm.so","try");
}
if (!defined(spasm_first_kernel_vector))
{
  if (spasmAdvertised) { print("SPASM_TEST_FAIL"); }
  else { print("SPASM_TEST_SKIP"); }
}
else
{
  int ok=spasm_supports_current_ring();
  matrix A[2][3]=1,2,3,2,4,6;
  module K=spasm_first_kernel_vector(module(A));
  if (size(K)==0) { ok=0; }
  if (size(module(A*matrix(K)))!=0) { ok=0; }
  matrix B[3][2]=1,0,0,1,1,1;
  module L=spasm_first_kernel_vector(module(B));
  if (size(L)!=0) { ok=0; }
  if (nrows(matrix(L))!=2) { ok=0; }
  matrix C[3][2]=1,0,0,1,0,0;
  spasm sparseC=module(C);
  sparseC=sparseC;
  matrix roundTripC=to_matrix(sparseC);
  if ((nrows(roundTripC)!=3) || (ncols(roundTripC)!=2)) { ok=0; }
  module P=-x*gen(1)+gen(2);
  attrib(P,"isHomog",intvec(-1,0));
  SectionSpace V=rankOneSheafSectionBasisLinear(P,0,ideal(0));
  SectionSpace W=lineBundleSectionBasisLinear(P,0,ideal(0));
  if ((size(V)!=3) || (size(W)!=3)) { ok=0; }
  ring r2=2,(x,y,z),dp;
  if (spasm_supports_current_ring()) { ok=0; }
  module P2=-x*gen(1)+gen(2);
  attrib(P2,"isHomog",intvec(-1,0));
  SectionSpace V2=rankOneSheafSectionBasisLinear(P2,0,ideal(0));
  if (size(V2)!=3) { ok=0; }
  if (ok) { print("SPASM_TEST_OK"); }
  else { print("SPASM_TEST_FAIL"); }
}
quit;
')

case "$result" in
  *SPASM_TEST_SKIP*) exit 77 ;;
  *SPASM_TEST_OK*) exit 0 ;;
  *) echo "$result"; exit 1 ;;
esac

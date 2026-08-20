#!/bin/sh

result=$("$SINGULAR_BIN_DIR/Singular" -q -c '
ring r=32003,(x),dp;
int spasmAdvertised=system("with","spasm");
LIB "sispasm.so";
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
  ring r2=2,(x),dp;
  if (spasm_supports_current_ring()) { ok=0; }
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

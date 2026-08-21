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
  SectionSpace V=rankOneSheafSectionBasisSpaSM(P,0,ideal(0));
  SectionSpace W=lineBundleSectionBasisSpaSM(P,0,ideal(0));
  SectionSpace G=rankOneSheafSectionBasisLinear(P,0,ideal(0));
  if ((size(V)!=3) || (size(W)!=3) || (size(G)!=3)) { ok=0; }
  ideal VG=V.basis*G.denom;
  ideal GV=G.basis*V.denom;
  if (size(NF(VG,std(GV)))!=0) { ok=0; }
  if (size(NF(GV,std(VG)))!=0) { ok=0; }
  SectionSpace BGGSpace=rankOneSheafSectionBasisBGGSpaSM(P,0,ideal(0),1,x);
  if (size(BGGSpace)!=3) { ok=0; }
  ring r2=2,(x,y,z),dp;
  if (spasm_supports_current_ring()) { ok=0; }
  module P2=-x*gen(1)+gen(2);
  attrib(P2,"isHomog",intvec(-1,0));
  // The explicit generic command remains available, independently of SpaSM.
  SectionSpace V2=rankOneSheafSectionBasisLinear(P2,0,ideal(0));
  if (size(V2)!=3) { ok=0; }
  if (ok) { print("SPASM_TEST_OK"); }
  else { print("SPASM_TEST_FAIL"); }
}
quit;
')

case "$result" in
  *SPASM_TEST_SKIP*)
    unavailable=$("$SINGULAR_BIN_DIR/Singular" -q -c '
ring r=32003,(x,y,z),dp;
LIB "sheafcoh.lib";
module O=0;
attrib(O,"isHomog",intvec(0));
rankOneTrivializationSpaSM(O,ideal(0));
quit;
' 2>&1)
    case "$unavailable" in
      *"SpaSM kernel requested, but the sispasm module is not available"*) exit 77 ;;
      *) echo "$unavailable"; exit 1 ;;
    esac
    ;;
  *SPASM_TEST_OK*) ;;
  *) echo "$result"; exit 1 ;;
esac

# A strict SpaSM request must fail before even the free-module shortcut when
# the current coefficient field is unsupported.
unsupported=$("$SINGULAR_BIN_DIR/Singular" -q -c '
ring r=2,(x,y,z),dp;
LIB "sheafcoh.lib";
module O=0;
attrib(O,"isHomog",intvec(0));
rankOneTrivializationSpaSM(O,ideal(0));
quit;
' 2>&1)

case "$unsupported" in
  *"SpaSM kernel requested, but the current coefficient field is unsupported"*) exit 0 ;;
  *) echo "$unsupported"; exit 1 ;;
esac

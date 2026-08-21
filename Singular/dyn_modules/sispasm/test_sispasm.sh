#!/bin/sh

result=$("$SINGULAR_BIN_DIR/Singular" -q -c '
ring r=32003,(x,y,z),dp;
int spasmAdvertised=system("with","spasm");
LIB "sheafcoh.lib";
LIB "kodaira_surface_classifier.lib";
// The automatic classifier must itself load a compatible developer-tree
// module even when the main executable reflects an older configure result.
ring automaticRing=32003,(u0,u1,u2,u3),dp;
ideal automaticCubic=u0^3+u1^3+u2^3+u3^3;
list automaticAdjunction=KSCadjunctionPrepass(automaticCubic);
setring r;
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
  ring r4=32003,(x0,x1,x2,x3),dp;
  ideal quintic=x0^5+x1^5+x2^5+x3^5;
  int phiLinear=KSCphiDim(quintic,1);
  int phiSpaSM=KSCphiDimSpaSM(quintic,1);
  int phiExactSpaSM=KSCphiDimExactSpaSM(quintic,1);
  if ((phiLinear!=2) || (phiSpaSM!=2) || (phiExactSpaSM!=2)) { ok=0; }
  if (find(automaticAdjunction[4],"SpaSM")==0) { ok=0; }
  // Exercise the automatic exact |5K| dispatcher on a small, deterministic,
  // non-subcanonical surface rather than only the adjunction selector.
  system("--random",12345678);
  ring r5=31991,(v0,v1,v2,v3,v4),dp;
  ideal automaticLinearForms=randomid(maxideal(1),4,3);
  ideal automaticCubicForms=randomid(maxideal(3),2,3);
  matrix automaticMatrix[2][3]=
    automaticLinearForms[1],automaticLinearForms[2],automaticCubicForms[1],
    automaticLinearForms[3],automaticLinearForms[4],automaticCubicForms[2];
  ideal automaticSurface=minor(automaticMatrix,2);
  def automaticClassification=KSCclassify(automaticSurface);
  if (automaticClassification.subcanonical!=0) { ok=0; }
  if (automaticClassification.phi5Dimension!=1) { ok=0; }
  if (find(automaticClassification.certificate,"SpaSM")==0) { ok=0; }
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

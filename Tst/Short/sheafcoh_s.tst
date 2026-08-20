LIB "tst.lib";
tst_init();

 LIB "sheafcoh.lib";

// Kohomologie der Strukturgarbe von P^5:
//----------------------------------------
ring r=0,x(1..6),dp;
module M=0;
def A=sheafCoh(M,-10,5);
displayCohom(A,-10,5,5);
A=sheafCoh(M,-10,5,"sres");
displayCohom(A,-10,5,5);
def B=sheafCohBGG(M,-10,5);
displayCohom(A,-10,5,5);
displayCohom(B,-10,5,5);
// Kohomologie der getwisteten Strukturgarbe von P^5:
//----------------------------------------------------
attrib(M,"isHomog",intvec(-2));
A=sheafCoh(M,-10,3);
displayCohom(A,-10,3,5);
A=sheafCoh(M,-10,3,"sres");
displayCohom(A,-10,3,5);
B=sheafCohBGG(M,-10,3);
displayCohom(B,-10,3,5);
// Kohomologie direkter Summen getwisteter Strukturgarben von P^5:
//----------------------------------------------------------------
matrix MM[3][1];
M=MM;
attrib(M,"isHomog",intvec(-1,0,2));
A=sheafCoh(M,-9,5);
displayCohom(A,-9,5,5);
A=sheafCoh(M,-9,4,"sres");
displayCohom(A,-9,4,5);
B=sheafCohBGG(M,-8,3);
displayCohom(B,-8,3,5);
// Kohomologie von O(-2)+O(-1)+(O/x(1))(1) = O_5(-2)+o_5(-1)+O_4(1):
//-------------------------------------------------------------------
MM=0,x(1),0;
M=MM;
attrib(M,"isHomog",intvec(-2,1,-1));
A=sheafCoh(M,-8,4);
displayCohom(A,-8,4,5);
A=sheafCoh(M,-8,4,"sres");
displayCohom(A,-8,4,5);
B=sheafCohBGG(M,-8,3);
displayCohom(B,-8,3,5);
kill r;

// Kohomologie der Idealgarbe der Veronese Flaeche in $\P^3$:
//------------------------------------------------------------
 ring S = 32003, x(0..4), dp;
 module MI=maxideal(1);
 attrib(MI,"isHomog",intvec(-1));
 resolution kos = nres(MI,0);
 print(betti(kos),"betti");
 matrix alpha0 = random(32002,10,3);
 module pres = module(alpha0)+kos[3];
 attrib(pres,"isHomog",intvec(1,1,1,1,1,1,1,1,1,1));
 resolution fcokernel = mres(pres,0);
 print(betti(fcokernel),"betti");
 module dir = transpose(pres);
 attrib(dir,"isHomog",intvec(-1,-1,-1,-2,-2,-2,
                             -2,-2,-2,-2,-2,-2,-2));
 resolution fdir = mres(dir,2);
 print(betti(fdir),"betti");
 ideal I = groebner(flatten(fdir[2]));
 resolution FI = mres(I,0);
 print(betti(FI),"betti");
 module F=FI[2];
 A=sheafCoh(F,-4,4);
 displayCohom(A,-4,4,4);
 A=sheafCoh(F,-4,4,"sres");
 displayCohom(A,-4,4,4);
 B=sheafCohBGG(F,-4,2);
 displayCohom(B,-4,2,4);

 dimH(3,F,-4);
 dimH(1,F,1);

 A=sheafCoh(F,-1,1);
 displayCohom(A,-1,1,4);
 kill S;

// --------------------------------------------------
// Test of truncate:
   ring R=0,(x,y,z),dp;
   module M=x2,y3,z4;
   homog(M);
   // compute presentation matrix for truncated module (R/<x2,y3,z4>)_(>=2)
   module M2=truncate(M,2);
   print(M2);
   dimGradedPart(M2,1);
   dimGradedPart(M,1);
   dimGradedPart(M2,2);
   // this should coincide with:
   dimGradedPart(M,2);
   dimGradedPart(M,3);
   // shift grading by -1:
   intvec v=-1;
   attrib(M,"isHomog",v);
   M2=truncate(M,2);
   print(M2);
   dimGradedPart(M2,2);

// Representatives for H^0 from the regular multiplication tail:
//---------------------------------------------------------------
   kill R;
   ring R=0,(x,y,z),dp;
   module O=0;
   attrib(O,"isHomog",intvec(0));
   list SB=sheafSectionBasis(O,2,2);
   size(SB[1]);
   SB[1];
   SB[2];
   SB[3];

// Mixed shifts of a free module must contribute their maximum to regularity;
// this is also a regression for the projective-dimension BGG window.
   matrix FreePresentation[3][1];
   module MixedFree=FreePresentation;
   attrib(MixedFree,"isHomog",intvec(-2,0,3));
   CM_regularity(MixedFree);
   list MixedFreeSections=sheafSectionBasis(MixedFree,0);
   size(MixedFreeSections[1]);
   SectionSpace EmptySections=lineBundleSectionBasis(O,-1,ideal(0));
   typeof(EmptySections);
   size(EmptySections);
   // Direct irrelevant saturation gives the same typed interface, including
   // the negative-degree empty space:
   SectionSpace DirectO1=lineBundleSectionBasisDirect(O,1,ideal(0));
   size(DirectO1);
   DirectO1.basis;
   DirectO1.denom;
   DirectO1.tailDegree;
   SectionSpace DirectEmpty=lineBundleSectionBasisDirect(O,-1,ideal(0));
   size(DirectEmpty);
   DirectEmpty.denom;
   DirectEmpty.tailDegree;
   SB=sheafSectionBasis(O,0,2,x2,1);
   SB[1];
   SB[2];
   SB[3];

// Finite-length torsion at the regularity boundary must disappear:
//-----------------------------------------------------------------
   module T=x*gen(2),y*gen(2),z*gen(2);
   attrib(T,"isHomog",intvec(0,0));
   SB=sheafSectionBasis(T,0);
   size(SB[1]);
   SB[1];
   SB[3];

// Verification is on by default and rejects an explicitly unstable tail:
//-------------------------------------------------------------------------
   poly unitDenominator=1;
   // This is also the eager-boolean regression: with v=0 the deliberately
   // unstable dimension must not cause sectionBasisBGGDimension to run.
   SB=sheafSectionBasis(T,0,0,unitDenominator,0);
   size(SB[1]);
   SB=sheafSectionBasis(T,0,0,unitDenominator);

// Scalarization of a presented rank-one module:
//------------------------------------------------
   module P=-x*gen(1)+gen(2);
   attrib(P,"isHomog",intvec(-1,0));
   list ST=trivializedSectionBasis(P,0,ideal(1,x),1,ideal(0));
   ST[1];
   ST[2];
   ST[3];
   list DirectST=trivializedSectionBasisDirect(P,0,ideal(1,x),1,ideal(0));
   DirectST[1];
   DirectST[2];
   DirectST[3];
   // The same frame may be supplied with a nonconstant common denominator.
   list DirectScaled=trivializedSectionBasisDirect(P,0,
                                                   ideal(z,x*z),z,ideal(0));
   DirectScaled[1];
   DirectScaled[2];
   DirectScaled[3];
   SectionSpace DirectP=rankOneSheafSectionBasisDirect(P,0,ideal(0));
   size(DirectP);
   DirectP.basis;
   DirectP.denom;
   sectionNumerator(DirectP[1]);
   sectionDenominator(DirectP[1]);
   SectionSpace LB=lineBundleSectionBasis(P,0,ideal(0),0,1,1);
   typeof(LB);
   size(LB);
   LB.basis;
   LB.denom;
   LB.trivializationImages;
   LB.trivializationDenom;
   LB.twist;
   LB.trivializationShift;
   LB.tailDegree;
   Section firstSection=LB[1];
   typeof(firstSection);
   sectionNumerator(firstSection);
   sectionDenominator(firstSection);
   list LBasis=sectionBasis(LB);
   size(LBasis);
   rationalMapFromSections(LB);
   rationalMapFromSections(list(LB[1],LB[3]));
   rationalMapFromSections(ST);
   rationalMapFromSections(list(ST[1],1,ST[3]));
   rationalMapFromSections(ST[1]);
   rationalMapFromSections(list(y,z,x));
   ideal SlotMap=rationalMapFromSections(list(0,x,0));
   ncols(matrix(SlotMap));
   SlotMap;

// The rational functional can also be chosen from the graded dual:
//-----------------------------------------------------------------
   list RT=rankOneTrivialization(P,ideal(0));
   RT[1];
   RT[2];
   RT[3];
   SectionSpace RS=rankOneSheafSectionBasis(P,0,ideal(0),0,1,1);
   RS.basis;
   RS.denom;
   RS.tailDegree;

// Sections from different frames or graded sheaves cannot be mixed:
//-----------------------------------------------------------------
   ideal Iframes=x*y;
   module FrameA=y*gen(1),x*gen(2);
   attrib(FrameA,"isHomog",intvec(0,0));
   SectionSpace SpaceA=rankOneSheafSectionBasis(FrameA,0,Iframes,2,z2,0);
   // This is the same relation submodule, but has a different rational frame.
   module FrameB=y*gen(1),y*gen(1)+x*gen(2);
   attrib(FrameB,"isHomog",intvec(0,0));
   SectionSpace SpaceB=rankOneSheafSectionBasis(FrameB,0,Iframes,2,z2,0);
   rationalMapFromSections(list(SpaceA[1],SpaceB[2]));
   // This has the same relation submodule and frame degree, but another grading.
   module GradedB=y*gen(1),x*gen(2);
   attrib(GradedB,"isHomog",intvec(1,0));
   SectionSpace SpaceC=rankOneSheafSectionBasis(GradedB,0,Iframes,2,z2,0);
   rationalMapFromSections(list(SpaceA[2],SpaceC[1]));

// Dual generators which vanish on the support must not raise the shift:
//-----------------------------------------------------------------------
   ideal IXredundant=x;
   module Redundant=x*gen(1),gen(2);
   attrib(Redundant,"isHomog",intvec(0,-5));
   RT=rankOneTrivialization(Redundant,IXredundant);
   RT[1];
   RT[2];
   RT[3];

// Support is a sheaf condition, so irrelevant torsion is saturated away:
//-----------------------------------------------------------------------
   module SaturatedSupport=x2*gen(1),x*y*gen(1),x*z*gen(1);
   attrib(SaturatedSupport,"isHomog",intvec(0));
   RT=rankOneTrivialization(SaturatedSupport,ideal(x));
   RT[1];
   RT[2];
   RT[3];

// A presentation generator may have zero image under a trivialization:
//---------------------------------------------------------------------
   module Z=gen(2);
   attrib(Z,"isHomog",intvec(0,0));
   ST=trivializedSectionBasis(Z,0,ideal(1,0),1,ideal(0),0,1,1);
   size(ST[1]);
   ST[1];
   ST[2];
   ST[3];

// The regularity boundary itself need not yet give the stable Hom tail:
//-----------------------------------------------------------------------
   module L=(x+y)*gen(1);
   attrib(L,"isHomog",intvec(0));
   SB=sheafSectionBasis(L,-1);
   size(SB[1]);
   SB[3];

// A syzygy presentation of m^2 sheafifies to the structure sheaf:
//-----------------------------------------------------------------
   ideal J=maxideal(2);
   module MJ=syz(J);
   attrib(MJ,"isHomog",intvec(2,2,2,2,2,2));
   ST=trivializedSectionBasis(MJ,0,J,1,ideal(0));
   size(ST[1]);
   ST[1];
   ST[2];
   ST[3];

// Reducible support needs a denominator regular on every component:
//------------------------------------------------------------------
   kill R;
   ring Rtail=0,(u,w),dp;
   module XY=u*w*gen(1);
   attrib(XY,"isHomog",intvec(0));
   list SBTail=sheafSectionBasis(XY,0);
   size(SBTail[1]);
   SBTail[1];
   SBTail[2];
   SBTail[3];

// The same computation accepts a module directly over a qring:
//--------------------------------------------------------------
   ideal I=u*w;
   // Neither dual generator alone covers both components; their sum does.
   module Split=w*gen(1),u*gen(2);
   attrib(Split,"isHomog",intvec(0,0));
   list RTSplit=rankOneTrivialization(Split,I);
   RTSplit[1];
   RTSplit[2];
   RTSplit[3];
   SectionSpace STSplit=rankOneSheafSectionBasis(Split,0,I);
   STSplit.basis;
   STSplit.denom;
   STSplit.tailDegree;
   rationalMapFromSections(STSplit);
   // Direct saturation must not replace this non-locally-free sheaf by a
   // purification or reflexive hull:
   SectionSpace DirectSplit=rankOneSheafSectionBasisDirect(Split,0,I);
   size(DirectSplit);
   DirectSplit.basis;
   DirectSplit.denom;
   rationalMapFromSections(DirectSplit);
   qring Qtail=std(I);
   module SplitQ=w*gen(1),u*gen(2);
   attrib(SplitQ,"isHomog",intvec(0,0));
   SectionSpace DirectSplitQ=rankOneSheafSectionBasisDirect(SplitQ,0,
                                                            ideal(0));
   size(DirectSplitQ);
   DirectSplitQ.basis;
   DirectSplitQ.denom;
   module OQ=0;
   attrib(OQ,"isHomog",intvec(0));
   list SBQ=sheafSectionBasis(OQ,0);
   size(SBQ[1]);
   SBQ[1];
   SBQ[2];
   SBQ[3];
   SectionSpace LQ=lineBundleSectionBasis(OQ,0,ideal(0));
   size(LQ);
   LQ.basis;
   LQ.denom;
   rationalMapFromSections(LQ);

// Qring lifting also preserves twists and stabilization:
//--------------------------------------------------------
   ring Rlinear=0,(x,y,z),dp;
   ideal K=x+y;
   qring Qlinear=std(K);
   module OH=0;
   attrib(OH,"isHomog",intvec(0));
   SectionSpace DirectQLine=lineBundleSectionBasisDirect(OH,1,ideal(0));
   size(DirectQLine);
   DirectQLine.basis;
   DirectQLine.denom;
   DirectQLine.tailDegree;
   list SBLinear=sheafSectionBasis(OH,-1);
   size(SBLinear[1]);
   SBLinear[3];

// The verification default and explicit opt-out survive qring lifting:
//---------------------------------------------------------------------
   ring Rverify=0,(x,y,z),dp;
   qring Qverify=std(z);
   module Tverify=x*gen(2),y*gen(2);
   attrib(Tverify,"isHomog",intvec(0,0));
   poly qUnitDenominator=1;
   list SBVerify=sheafSectionBasis(Tverify,0,0,qUnitDenominator,0);
   size(SBVerify[1]);
   SBVerify=sheafSectionBasis(Tverify,0,0,qUnitDenominator);

// On P^0, constructing T^d needs one output column to the right:
//----------------------------------------------------------------
   ring RP0=0,t,dp;
   module OP0=0;
   attrib(OP0,"isHomog",intvec(0));
   list P0Sections=sheafSectionBasis(OP0,4);
   size(P0Sections[1]);
   module ZP0=t;
   attrib(ZP0,"isHomog",intvec(0));
   list P0ZeroSections=sheafSectionBasis(ZP0,1);
   size(P0ZeroSections[1]);

tst_status(1);$

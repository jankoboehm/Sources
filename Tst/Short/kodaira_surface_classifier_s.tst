LIB "tst.lib";
tst_init();

LIB "kodaira_surface_classifier.lib";

ring R=0,(x0,x1,x2,x3),dp;

ideal cubic=x0^3+x1^3+x2^3+x3^3;
list C=KSCsurfaceData(cubic);
C[2..4];
KSCsubcanonicalIndex(cubic);
def AC=KSCautoEconomical(cubic);
AC.classification;
AC.kodairaDimension;

ideal quartic=x0^4+x1^4+x2^4+x3^4;
list Q=KSCsurfaceData(quartic);
Q[2..4];
KSCsubcanonicalIndex(quartic);
intvec PQ=KSCplurigenera(quartic,3);
PQ;
def AK=KSCautoEconomical(quartic);
AK.classification;
AK.kodairaDimension;
AK.keepData;
def AKkeep=KSCautoEconomical(quartic,3,0,1);
AKkeep.keepData;
size(string(AKkeep.inputIdeal));
list SQ=KSCcheckSurface(quartic);
SQ[5];

ideal quintic=x0^5+x1^5+x2^5+x3^5;
KSCsubcanonicalIndex(quintic);
def AQ=KSCautoEconomical(quintic);
AQ.classification;
AQ.kodairaDimension;

// Exercise dimH-certified scalar sections and both the estimated and exact map
// paths, including their empty, one-section, and surface-image branches.
KSCphiDim(cubic,1);
KSCphiDim(quartic,1);
KSCphiDim(quintic,1);
KSCphiDimExact(cubic,1);
KSCphiDimExact(quartic,1);
KSCphiDimExact(quintic,1);
KSCphiDimExactOriginal(cubic,1);
KSCphiDimExactOriginal(quartic,1);
KSCphiDimExactOriginal(quintic,1);
list Adj=KSCadjunctionPrepass(cubic);
Adj[1..3];
find(Adj[4],"original classifier")>0;

// Automatic classifier-level backend selection must use the original path
// whenever SpaSM cannot support the coefficient field.  The strict public
// SpaSM section commands themselves are unchanged.
ring R2=2,(z0,z1,z2,z3),dp;
ideal cubic2=z0^3+z1^3+z2^3+z3^3;
list Adj2=KSCadjunctionPrepass(cubic2);
Adj2[1..3];
find(Adj2[4],"original classifier")>0;

ring Ra=(0,a),(u0,u1,u2,u3),dp;
minpoly=a2+1;
ideal quinticA=u0^5+u1^5+u2^5+u3^5;
KSCphiDimExactOriginal(quinticA,1);

// The classifier computes Ext over the ambient polynomial ring S.  Reject a
// quotient-ring encoding instead of silently computing Ext over S/(f).
ring Rq=0,(q0,q1,q2,q3),dp;
ideal quarticQ=q0^4+q1^4+q2^4+q3^4;
qring Qq=std(quarticQ);
ideal zeroIdeal=0;
KSCplurigenera(zeroIdeal,3);

ring S=0,(y0,y1),dp;
ideal notsurface=0;
def P12bad=KSCp12Certificate(notsurface);
P12bad.classification;
P12bad.algorithm;
setring R;

tst_status(1);$

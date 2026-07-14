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

tst_status(1);$

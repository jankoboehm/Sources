LIB "tst.lib";
tst_init();

LIB "kodaira_surface_classifier.lib";

// A non-subcanonical determinantal surface with a multi-row canonical module.
// This reaches the classifier's cached W5/frame path and compares it with the
// independent one-shot exact construction of the same pluricanonical map.
system("--random",12345678);
ring R=31991,(x0,x1,x2,x3,x4),dp;
ideal linearForms=randomid(maxideal(1),2,3);
ideal quadraticForms=randomid(maxideal(2),4,3);
matrix M[2][3]=linearForms[1],quadraticForms[1],quadraticForms[2],
                 linearForms[2],quadraticForms[3],quadraticForms[4];
ideal X=minor(M,2);

def A=KSCclassify(X);
A.plurigenera;
A.classification;
A.kodairaDimension;
A.phi5Dimension;
KSCphiDimExact(X,5);

tst_status(1);$

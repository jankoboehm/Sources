LIB "tst.lib";
tst_init();
// Oscar Issue #4833
ring r = 0,(x,y,z),dp;
ideal I = x2-yz;
qring s = std(I);
setring s;
vector v = [1];
module J = v, 0*v;
J;
matrix T;
module G=liftstd(J,T);
rank(G);
T;
print(matrix(J)*T-matrix(G));
//--------------------------------------
J = 0*v,v;
J;
G=liftstd(J,T);
G;
T;
print(matrix(J)*T-matrix(G));
//--------------------------------------
J = v,[x2-yz];
J;
G=liftstd(J,T);
G;
T;
print(matrix(J)*T-matrix(G));
kill r,s;
tst_status(1);$

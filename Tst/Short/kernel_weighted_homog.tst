LIB "tst.lib";
tst_init();

int n = 7;
ring R = 0,(x(1..3)(1..n)), dp;
matrix M[3][n] = x(1..3)(1..n);
ideal I = minor(M,3);
int kk = ncols(I);
ring S = 0,(y(1..kk)), dp;
setring R;
map f = S, I;
setring S;
ideal J = kernel(R,f);
tst_status();

"kernel_size";
size(J);
"leading_size";
size(lead(J));

setring R;
ideal imageJ = f(J);
"substitution_image_size";
size(imageJ);
"substitution_is_zero";
size(imageJ) == 0;

tst_status(1);$

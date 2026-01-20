LIB "tst.lib";
tst_init();

ring R = 0, (c11, c21, c22, H, h), wp(1, 1, 2, 1, 1);
option(redSB);   // force the computation of a reduced SB
ideal J = -H+h, h^4, H^4, -c11*c22+4*H^3, -c11*c21-c22+6*H^2, -c11-c21+4*H;
J = std(J);
ring S = 0,  (c11, c21, c22, H, h), (wp(1, 1, 2, 1), dp);
ideal JJ = fglm(R,J);
ideal JJJ = std(fetch(R,J));
NF(JJJ,JJ);
NF(JJ, JJJ);

tst_status(1);$

LIB "tst.lib";
tst_init();

LIB "sheafcoh.lib";

ring S = 0,x(0..4),dp;
matrix f[1][5] = x(0),x(1),x(2),x(3),x(4);
matrix I[1][1] = x(0)^5 + x(1)^5 + x(2)^5 + x(3)^5 + x(4)^5;
intvec v = 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 5;

matrix J = jacob(I);
module N = modulo(f, I);
matrix A = tensor(I, freemodule(5));
matrix B = concat(transpose(J), A);
module OmegaX = modulo(N, B);
attrib(OmegaX,"isHomog",v);

dimH(2, OmegaX, 0);  // ← This causes a crash

tst_status(1);$

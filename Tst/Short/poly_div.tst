LIB "tst.lib";
tst_init();

ring r=ZZ,x,lp;
poly a=x^2 + 3x + 1;
poly b= 2x + 4;
(a*b)/a;
tst_status(1);$

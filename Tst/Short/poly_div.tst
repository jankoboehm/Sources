LIB "tst.lib";
tst_init();

ring r0=ZZ,x,lp;
poly a=x^2 + 3x + 1;
poly b= 2x + 4;
(a*b)/a;

ring r1=QQ,x,lp;
poly a=x^2 + 3x + 1;
poly b= 2x + 4;
(a*b)/a;

ring r2=(QQ,t),x,lp;
poly a=x^2 + 3x + 1;
poly b= 2x + 4;
(a*b)/a;

ring r21=(QQ,t),x,lp;
poly a=(1/t)*x^2 + 3x + 1;
poly b= 2x + 4/t;
(a*b)/a;

ring r3=(QQ,t),x,lp;
minpoly=t2+1;
poly a=x^2 + 3x + 1;
poly b= 2x + 4;
(a*b)/a;

// Issue #1269
ring r = 0,x,dp;
ring s = r,(u,v),dp;
poly d = u - 1;
poly f = 1 / x * d;
f / d;

tst_status(1);$

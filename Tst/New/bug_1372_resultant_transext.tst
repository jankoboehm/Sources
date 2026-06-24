LIB "tst.lib"; tst_init();

// issue #1372: resultant() over a transcendental coefficient field
// QQ(a,b,...) printed "conversion error: denominator!= 1" and then
// SIGSEGV.  A coefficient with a reducible multi-term denominator
// (e.g. (a+b)(a+b+1)/(a+b), left un-normalized by lazy cancellation)
// reached convSingTrPFactoryP, which rejected it instead of
// normalizing it first.  The result below must be (a+b)^2/(a+b+1)^2*p3^2.
ring R = (0, a, b), (p1, p3), lp;
poly pp = (a+b)/(a+b+1)^2*p1 + (a+b)/(a+b+1)*p3;
poly qq = p1^2;
poly r = resultant(pp, qq, p1);
r;
ASSUME(0, r == (a+b)^2/(a+b+1)^2*p3^2);

tst_status(1);$

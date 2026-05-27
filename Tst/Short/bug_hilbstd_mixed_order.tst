LIB "tst.lib";
tst_init();

// Fix for hilbert driven regression introduced in f565c92bc19a2b5c49a0d6c2b3d48012001c0d99 and 15ad165c6b4f18bddaf2a520e00e0bc5cc6643c2.
ring PR = 0, (t, u, v, e(1), e(2), c(1..7)),
          (M(1,2,6,0,-2,-6,0,-1,0), ip(2), dp(7), C);
qring Q = std(ideal(e(1)^2, e(1)*e(2), e(2)^2));

ideal PRHS =
    t*u^2*e(2)*c(6), t*u^2*e(2)*c(3), t*u^3*e(1)*c(3),
    t*v*e(2)*c(5) + t*v*e(2)*c(6), t*u^4*e(2),
    t*u*v*e(1)*c(5), t*u*v*e(1)*c(3), t*u*v*e(2),
    12*t*u^5*e(1)*c(5) + 5*t*u^5*e(1)*c(6),
    t*u^2*v*e(1)*c(7), t*u^6*e(1), t*u^3*v*e(1),
    t*v^2*e(1), t*v^2*e(2),
    c(4), c(2), c(1), c(6);

option(redTail);
option(redSB);
ideal G = groebner(PRHS);
"ncols(G) = " + string(ncols(G));

ideal R = reduce(PRHS, G);
int i;
int nz = 0;
for (i = 1; i <= ncols(R); i++)
{
  if (R[i] != 0)
  {
    nz = nz + 1;
    "PRHS[" + string(i) + "] = " + string(PRHS[i]);
    "  NF mod G = " + string(R[i]);
  }
}
"Total non-zero reductions: " + string(nz);
if (nz != 0)
{
  ERROR("groebner returned a basis not containing the input ideal");
}

tst_status(1);$

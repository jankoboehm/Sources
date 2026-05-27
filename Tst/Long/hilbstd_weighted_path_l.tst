LIB "tst.lib";
tst_init();

ring r=32003,(x(1..5)),(wp(1,2),dp(3),C);
intvec W=1,2,1,1,1;
ideal mons;

proc enumMonoms(int pos, int rem, poly m)
{
  if (pos > nvars(basering))
  {
    if (rem == 0)
    {
      mons[size(mons)+1] = m;
    }
    return();
  }
  int wi = W[pos];
  int e;
  for (e = 0; e <= rem div wi; e++)
  {
    enumMonoms(pos+1, rem-e*wi, m*var(pos)^e);
  }
  return();
}

proc whpoly(int D, int density, int coeffmax)
{
  mons = 0;
  enumMonoms(1,D,1);
  poly f = 0;
  int i;
  int c;
  for (i = 1; i <= size(mons); i++)
  {
    if (random(1,100) <= density)
    {
      c = random(1,coeffmax);
      f = f + c*mons[i];
    }
  }
  return(f);
}

system("--random",1234567);
ideal I =
  whpoly(5,45,32000),
  whpoly(5,45,32000),
  whpoly(6,45,32000),
  whpoly(7,45,32000);

option(redSB);
option(redTail);
ideal G = std(I);
"ncols(G) = " + string(ncols(G));

ideal R = reduce(I, G);
int i;
int nz = 0;
for (i = 1; i <= ncols(R); i++)
{
  if (R[i] != 0)
  {
    nz = nz + 1;
    "I[" + string(i) + "] = " + string(I[i]);
    "  NF mod G = " + string(R[i]);
  }
}
"Total non-zero reductions: " + string(nz);
if (nz != 0)
{
  ERROR("std returned a basis not containing the input ideal");
}

tst_status(1);
$

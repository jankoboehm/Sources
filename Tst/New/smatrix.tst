LIB "tst.lib"; tst_init();

ring r;
matrix m[2][2]=x,y,z,1;
smatrix M=m;
newstruct ("aa","smatrix m");
aa b;
b.m=M;
list l=b,x;
ring rr;
fetch(r,M);
typeof(_);
fetch(r,b);
fetch(r,l);

tst_status(1);$

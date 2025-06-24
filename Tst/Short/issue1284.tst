LIB "tst.lib";
tst_init();

ring r = ZZ,x,(dp,c);
matrix i[1][2]=2,x+1;
ring s=2,dummy,dp;
map m=r,1;
m(i);
m;
tst_status(1);$


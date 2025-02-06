LIB "tst.lib";
tst_init();

LIB"primdec.lib";
ideal i=x2+y2;
primdecGTZ(i);
ring r=(0,t),(x,y),dp;
minpoly=t2+1;
ideal i=x2+y2;
primdecGTZ(i);
primdecSY(i);

tst_status(1);$

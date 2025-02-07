LIB "tst.lib";
tst_init();

LIB"primdec.lib";
LIB"primdecint.lib";
ideal i=x2+y2;
primdecGTZ(i);
ring r=(0,t),(x,y),dp;
minpoly=t2+1;
ideal i=x2+y2;
primdecGTZ(i);
primdecSY(i);

ring r3=(0,t),(x,y,z),dp;
minpoly=t3-7;
ideal i=x, y*z^2;
list L=primdecGTZ(i);L;
primdecSY(i);
radical(L[1][1]);L[1][2];
radical(L[2][1]);L[2][2];

ring r2=ZZ,(a,b,c,d),dp;
ideal i=9, (a+3)*(b+3);
primdecZ(i);


setring r3;
ideal i2=(z^2+1)*(z^3+2)^2, y-z^2;
minAssGTZ(i2);

tst_status(1);$

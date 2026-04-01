LIB "tst.lib"; tst_init();
ring r=(integer,5),(x,y),dp;
factorize(x+y,1);
resultant(x+y,x-y,y);
(x2-y2)/(x-y);
tst_status(1);$

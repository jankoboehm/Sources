LIB "tst.lib";
tst_init();

LIB "paraplanecurves.lib";
ring R=0,(x,y,z),dp;

poly f=x*(y^5+z^5)-x^4*y*z+(x*y*z)^2-2*(y*z)^3;
ideal actual=adjointIdeal(f,1);
ideal expected=
  x^2*y-x*y^2-2*y^3+x^2*z-y^2*z+2*x*z^2-y*z^2+z^3,
  x*y^2+y^3-x*z^2-z^3,
  y^3-x^2*z-x*z^2+y*z^2,
  x^2*z-y*z^2;

int equal=tst_stdEqual(std(actual),std(expected));
ASSUME(0,equal);
equal;

tst_status(1);$

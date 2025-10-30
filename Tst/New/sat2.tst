LIB "tst.lib"; tst_init();

ring P =0,  (a, b, x, y, z), dp;
ideal I = x^3 + x*y^2 - z^2, a*y - b*z, b*x - y, a*x - z, -a*z + x^2 + y^2, -a^2 + b*y + x, -a^3 + b^2*z + z, -a^2*b + b^2*y + y;
qring A=std(I);
vector s1 = [0,0,0,3*a*z - 2*y^2,2*x*y,-2*z,0,0];
vector s2 = [0,0,0,0,3*a*z - 2*y^2,0,2*x*y,-2*z];
vector s3 = [-6*a*z^2 + 4*y^2*z,-4*x*y*z,4*z^2,-6*x*z,-4*y*z,3*a*z - 2*y^2,-2*x*z, 2*x*y];
vector s4 = [0,0, 0,6*x*y^2 - 9*z^2,2*y^3,6*x*z,4*x*y^2,-4*y*z];
vector s5 = [0,0,0,-3*a*z + 2*y^2,-2*x*y,2*z,0,0];
vector s6 = [0,0,0,0,-2*x*y^2 + 3*z^2,0,2*b*z^2 - 2*y^3,-2*x*z];
vector s7 = [4*x*y^2*z - 6*z^3,-4*b*z^3 + 4*y^3*z,4*x*z^2,-6*a*z^2 + 6*y^2*z,-4*x*y*z,-2*x*y^2 + 3*z^2,-2*a*z^2 + 2*y^2*z,2*b*z^2 - 2*y^3];
vector s8 = [0,0,0,-6*x*y^2 + 9*z^2,-2*y^3,-6*x*z,-4*x*y^2,4*y*z];
module m = s1,s2,s3,s4,s5,s6,s7,s8;
ideal J = x;
module Q = quotient(m, J);
Q;
lift(Q, m[1]);

tst_status(1);$

LIB "tst.lib";

ring R = (0,v1),z(1..3),ws(1..3);
ideal I = z(1)^2-z(2)+(-v1)*z(3)+(2*v1^2)*z(1)*z(3)+(-v1^3)*z(2)*z(3),
    z(2)^2-2*z(1)*z(3)+(v1)*z(2)*z(3),
    z(3)^2;
I = std(I);
reduce(2*z(1)^2*z(3)+(v1)*z(1)*z(2)*z(3),I);

tst_status(1);$

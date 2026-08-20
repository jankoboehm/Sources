//divisors_s.tst
//short tests for divisors.lib
//---------------------------
LIB "tst.lib";
tst_init();
LIB "divisors.lib";
example makeDivisor;
example divisorplus;
example multdivisor;
example isEqualDivisor;
example globalSectionsIdeal;
example globalSections;
example globalSectionsBGG;
example degreeDivisor;
example linearlyEquivalent;
example effective;
example makeFormalDivisor;
example evaluateFormalDivisor;
example formaldivisorplus;
example multformaldivisor;
example degreeFormalDivisor;

// The divisor bridge has to lift a qring module to its polynomial ambient:
ring r=31991,(x,y,z),dp;
ideal I=y2*z-x*(x-z)*(x+3z);
qring Q=std(I);
divisor P=makeDivisor(ideal(x,z),ideal(1));
list B=globalSectionsBGG(multdivisor(4,P),0);
size(B[1]);
B[3];

tst_status(1);$

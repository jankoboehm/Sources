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

// The direct degree slice must not retain the qring equation as a zero
// "basis element" (this occurred for 8P before reducing modulo I):
list A=globalSections(multdivisor(8,P));
size(A[1]);
size(minbase(A[1]));
int hasZero;
int j;
for (j=1;j<=size(A[1]);j++)
{
  if (reduce(A[1][j],std(ideal(0)))==0) { hasZero=1; }
}
hasZero;
B=globalSectionsBGG(multdivisor(8,P),0);
size(B[1]);
ideal directCoordinates=A[1]*B[2];
ideal tailCoordinates=B[1]*A[2];
size(NF(directCoordinates,std(tailCoordinates)));
size(NF(tailCoordinates,std(directCoordinates)));

// Reduction alone is insufficient: quotient relations can also make the
// retained degree slice linearly dependent.  On this smooth conic Q_2 has
// dimension 5.
ring S=0,(x,y,z),dp;
ideal conicEquation=x2-y2-yz;
qring conic=std(conicEquation);
divisor principalConicDivisor=makeDivisor(ideal(z2),ideal(1));
list conicDirect=globalSections(principalConicDivisor);
size(conicDirect[1]);
size(minbase(conicDirect[1]));
list conicTail=globalSectionsBGG(principalConicDivisor,0);
size(conicTail[1]);
ideal conicDirectCoordinates=conicDirect[1]*conicTail[2];
ideal conicTailCoordinates=conicTail[1]*conicDirect[2];
size(NF(conicDirectCoordinates,std(conicTailCoordinates)));
size(NF(conicTailCoordinates,std(conicDirectCoordinates)));

tst_status(1);$

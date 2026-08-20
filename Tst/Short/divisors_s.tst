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
example globalSectionsMultTable;
example degreeDivisor;
example linearlyEquivalent;
example effective;
example makeFormalDivisor;
example evaluateFormalDivisor;
example formaldivisorplus;
example multformaldivisor;
example degreeFormalDivisor;

// The private trusted-frame shortcut has the same section span for automatic,
// explicit-tail, and fully explicit multiplication-table calls:
ring trustedRing=0,(x,y,z),dp;
divisor trustedDivisor=makeDivisor(ideal(x2),ideal(y));
list trustedDirect=globalSections(trustedDivisor);
list trustedAutomatic=globalSectionsMultTable(trustedDivisor,0);
list trustedTail=globalSectionsMultTable(trustedDivisor,0,0);
list trustedFixed=globalSectionsMultTable(trustedDivisor,0,0,poly(1),0);
size(trustedAutomatic[1]);
size(trustedTail[1]);
size(trustedFixed[1]);
ideal trustedDirectCoordinates=trustedDirect[1]*trustedAutomatic[2];
ideal trustedAutomaticCoordinates=trustedAutomatic[1]*trustedDirect[2];
size(NF(trustedDirectCoordinates,std(trustedAutomaticCoordinates)));
size(NF(trustedAutomaticCoordinates,std(trustedDirectCoordinates)));
ideal trustedTailCoordinates=trustedTail[1]*trustedFixed[2];
ideal trustedFixedCoordinates=trustedFixed[1]*trustedTail[2];
size(NF(trustedTailCoordinates,std(trustedFixedCoordinates)));
size(NF(trustedFixedCoordinates,std(trustedTailCoordinates)));

// The divisor bridge has to lift a qring module to its polynomial ambient:
ring r=31991,(x,y,z),dp;
ideal I=y2*z-x*(x-z)*(x+3z);
qring Q=std(I);
divisor P=makeDivisor(ideal(x,z),ideal(1));
// Here the canonical fractional ideal has generators in two degrees, while
// H^0(P) uses only the first module row. Trusted scalarization must pad the
// dropped trailing zero row before its kernel matrix multiplication.
list trailingRowBasis=globalSectionsMultTable(P,0);
size(trailingRowBasis[1]);
list B=globalSectionsMultTable(multdivisor(4,P),0);
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
B=globalSectionsMultTable(multdivisor(8,P),0);
size(B[1]);
ideal directCoordinates=A[1]*B[2];
ideal multTableCoordinates=B[1]*A[2];
size(NF(directCoordinates,std(multTableCoordinates)));
size(NF(multTableCoordinates,std(directCoordinates)));

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
list conicMultTable=globalSectionsMultTable(principalConicDivisor,0);
size(conicMultTable[1]);
ideal conicDirectCoordinates=conicDirect[1]*conicMultTable[2];
ideal conicMultTableCoordinates=conicMultTable[1]*conicDirect[2];
size(NF(conicDirectCoordinates,std(conicMultTableCoordinates)));
size(NF(conicMultTableCoordinates,std(conicDirectCoordinates)));

tst_status(1);$

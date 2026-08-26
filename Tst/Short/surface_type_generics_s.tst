LIB "tst.lib";
tst_init();

LIB "surface_type_generics.lib";
system("--random",12345678);

ring r=31991,(dummy),dp;

size(STGsurfaceTypes());
STG_catalogueType("k3_d12_pi14");
STG_catalogueType("elliptic_d12_pi14_ss_0");
STG_catalogueType("unknown_label");
size(STG_catalogueNames());

list S=STG_cubic_scroll(3);
S[3];
setring S[1];
nvars(basering);
size(S[2]);
dim(std(S[2]));

ring r2=31991,(dummy),dp;
list V=STG_projected_veronese(3);
V[3];
setring V[1];
nvars(basering);
size(V[2]);
dim(std(V[2]));

ring r3=31991,(dummy),dp;
list K=STG_K3(3);
K[3];
setring K[1];
nvars(basering);
size(K[2]);
dim(std(K[2]));

ring r4=31991,(dummy),dp;
list A=STG_abelian_product(2,5);
A[3];
setring A[1];
nvars(basering);
size(A[2]);
dim(std(A[2]));

ring r5=31991,(dummy),dp;
list R=STG_elliptic_ruled(2);
R[3];
setring R[1];
nvars(basering);
size(R[2]);
dim(std(R[2]));

ring r6=31991,(dummy),dp;
list E=STG_elliptic_surface(2,3);
E[3];
setring E[1];
nvars(basering);
size(E[2]);
dim(std(E[2]));

ring r7=31991,(dummy),dp;
list C=STG_Enriques_cover(3);
C[3];
setring C[1];
nvars(basering);
size(C[2]);
dim(std(C[2]));

ring r8=31991,(dummy),dp;
list Q=STG_Enriques_quotient_image(3);
Q[3];
setring Q[1];
nvars(basering);
size(Q[2]);
dim(std(Q[2]));

ring r9=31991,(dummy),dp;
list B=STG_bielliptic_cover_data(2,5);
B[3];
setring B[1];
nvars(basering);
size(B[2]);
dim(std(B[2]));

// Stored P4 catalogue: fields, generators, fingerprints and ring lifetime.
LIB "nonGeneralTypeSurfacesP4.lib";
proc STG_testFixed(string name)
{
  def fixedRing=nonGeneralTypeSurfaceP4(name);
  setring fixedRing;
  intvec degrees;
  int termCount;
  int j;
  for(j=1;j<=size(surfaceIdeal);j=j+1)
  {
    degrees[j]=deg(surfaceIdeal[j]);
    termCount=termCount+size(surfaceIdeal[j]);
  }
  print(name+"|"+string(char(basering))+"|"+string(nvars(basering))+
        "|"+string(size(surfaceIdeal))+"|"+string(degrees)+"|"+string(termCount));
  print(attrib(surfaceIdeal,"catalogueName")+"|"+attrib(surfaceIdeal,"catalogueType")+
        "|"+attrib(surfaceIdeal,"sourceSHA256"));
  map evaluate=basering,2,3,5,7,11;
  print(string(evaluate(surfaceIdeal)));
}
list fixedNames=nonGeneralTypeSurfaceP4Names();
int fixedIndex;
for(fixedIndex=1;fixedIndex<=size(fixedNames);fixedIndex=fixedIndex+1)
{
  STG_testFixed(fixedNames[fixedIndex]);
}

ring fixedCaller=0,(dummy),dp;
poly callerObject=dummy^2+1;
system("--random",314159);
int nextWithoutLoad=random(1,1000000);
system("--random",314159);
def firstFixed=nonGeneralTypeSurfaceP4("bordiga");
int nextAfterLoad=random(1,1000000);
nextWithoutLoad==nextAfterLoad;
char(basering)==0;
callerObject==dummy^2+1;
setring firstFixed;
ideal firstFixedIdeal=surfaceIdeal;
def repeatedFixed=nonGeneralTypeSurfaceP4("bordiga");
setring repeatedFixed;
ideal mappedFirst=imap(firstFixed,firstFixedIdeal);
int generatorsAgree=1;
for(fixedIndex=1;fixedIndex<=size(surfaceIdeal);fixedIndex=fixedIndex+1)
{
  if(surfaceIdeal[fixedIndex]!=mappedFirst[fixedIndex])
  {
    generatorsAgree=0;
  }
}
generatorsAgree;
proc STG_testFixedWrapper(string name)
{
  return(nonGeneralTypeSurfaceP4(name));
}
def wrappedFixed=STG_testFixedWrapper("enriques_d11_pi10");
setring wrappedFixed;
char(basering)==43;
attrib(surfaceIdeal,"catalogueName")=="enriques_d11_pi10";
setring firstFixed;
surfaceIdeal[1]==firstFixedIdeal[1];
setring fixedCaller;
callerObject==dummy^2+1;

tst_status(1);$

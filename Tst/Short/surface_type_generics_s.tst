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

tst_status(1);$

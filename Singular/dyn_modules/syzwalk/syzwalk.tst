LIB "tst.lib";
tst_init();

LIB "syzwalk.lib";
ring r=0,(x,y,z),dp;
ideal I=x2+y2+z2,xy+z2,y2+xz;
list L=liftstdSyz(I);
ideal G=L[1];
matrix T=L[2];
module S=L[3];

size(module(matrix(G)-matrix(I)*T));
size(module(matrix(I)*matrix(S)));

matrix Tfull;
module Sfull;
ideal Gfull=liftstd(I,Tfull,Sfull);
size(reduce(S,std(Sfull)));
size(reduce(Sfull,std(S)));

module M=[x,y],[x2,z],[y,z2];
list LM=liftstdSyz(M);
module GM=LM[1];
matrix TM=LM[2];
module SM=LM[3];

size(module(matrix(GM)-matrix(M)*TM));
size(module(matrix(M)*matrix(SM)));

matrix TMfull;
module SMfull;
module GMfull=liftstd(M,TMfull,SMfull);
size(reduce(SM,std(SMfull)));
size(reduce(SMfull,std(SM)));

if (system("with","gfanlib"))
{
  ring walkSource=0,(a,b,c,d),dp;
  ideal J=a2+b*c+d2,b2+a*c+a*d,c2+a*b+b*d,d2+a*c+b*c;
  option(redSB);
  ideal Js=std(J);

  ring walkTarget=0,(a,b,c,d),(lp(2),dp(2));
  ideal mappedJs=imap(walkSource,Js);
  ideal mappedJ=imap(walkSource,J);
  list W=syzWalk(mappedJs,walkSource);
  ideal Jw=W[1];
  matrix A=W[2];
  module Sw=W[3];
  ideal Jdirect=std(mappedJ);

  size(reduce(Jw,Jdirect));
  size(reduce(Jdirect,Jw));
  size(module(matrix(Jw)-matrix(mappedJs)*A));
  size(module(matrix(Jw)*matrix(Sw)));

  ring expSource=0,(u,v),(L(50000),dp);
  ideal expI=u^40000+v^50000;
  ideal expG=std(expI);
  ring expTarget=0,(u,v),(L(50000),lp);
  ideal expMapped=imap(expSource,expG);
  list expW=groebnerWalkLift(expMapped,expSource);
  ideal expDirect=std(imap(expSource,expI));
  size(reduce(expW[1],expDirect));
  size(reduce(expDirect,expW[1]));
  size(module(matrix(expW[1])-matrix(expMapped)*expW[2]));
}
else
{
  0;
  0;
  0;
  0;
  0;
  0;
  0;
}

tst_status(1);$

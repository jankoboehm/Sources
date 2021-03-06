LIB "tst.lib"; tst_init();
  newstruct("nt","int a,poly b,string c");
  nt A;
  nt B;
  A.a=3;
  A.c=string(A.a);
  B=A;
  newstruct("t2","nt","string c");
  t2 C; C.c="t2-c";
  A=C;
  typeof(A);
  A;
  // a motivating example ------------------------------------------
  newstruct("IDEAL","ideal I,proc prettyprint");
  newstruct("HOMOGENEOUS_IDEAL","IDEAL","intvec weights,proc prettyprint");
  proc IDEAL_pretty_print(IDEAL I)
  {
    "ideal generated by";
    I.I;
  }
  proc H_IDEAL_pretty_print(HOMOGENEOUS_IDEAL I)
  {
    "homogeneous ideal generated by";
    I.I;
    "with weights";
    I.weights;
  }
  proc p_print(IDEAL I) { I.prettyprint(I); }
  ring r;
  IDEAL I;
  I.I=ideal(x+y2,z);
  I.prettyprint=IDEAL_pretty_print;
  HOMOGENEOUS_IDEAL H;
  H.I=ideal(x,y,z);
  H.prettyprint=H_IDEAL_pretty_print;
  H.weights=intvec(1,1,1);
  p_print(I);
  p_print(H);
tst_status(1);$

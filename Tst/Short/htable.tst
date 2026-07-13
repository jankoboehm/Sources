LIB "tst.lib";
tst_init();

htable H = htable("a" -> 1, "b" -> 2);
typeof(H);
typeOfValue(H, "a");
parentOfValue(H, "a");
getValue(H, "a");
size(H);
H["a"];
H("b");

htable I = htable("c" -> 3);
htable J = H + I + ("d" -> 4);
size(J);
J["c"];
J["d"];

htable K = htable(key -> 7);
K["key"];

list pairs = list("e" -> 5, "f" -> intvec(1,2,3));
htable L = htable(pairs);
size(L);
L["e"];
L["f"];

apply(list(1,2), x->{x+1});

htable D = htable("a" -> 1, "a" -> 2);

ring r = 0, (x,y), dp;
poly p = x+y;
htable P = htable("p" -> p, "n" -> 3);
typeOfValue(P, "p");
typeof(parentOfValue(P, "p"));
varstr(parentOfValue(P, "p"));
typeOfValue(P, "n");
parentOfValue(P, "n");
typeof(basering);
P["p"];

ring s = 0, (a), dp;
setring s;
P["p"];
getValue(P, "p");
varstr(basering);
setring s;
getValue(P, "n");
varstr(basering);

setring r;
P["p"];

tst_status(1);$

/****************************************
*  Computer Algebra System SINGULAR     *
****************************************/
/*
* ABSTRACT: finite fields with a none-prime number of elements (via tables)
*/





#include <omalloc/omalloc.h>

#include <misc/auxiliary.h>
#include <misc/mylimits.h>
#include <misc/sirandom.h>

#include <reporter/reporter.h>

#include <coeffs/coeffs.h>
#include <coeffs/numbers.h>
#include <coeffs/ffields.h>
#include <coeffs/longrat.h>

#include <string.h>
#include <math.h>
#include <errno.h>

BOOLEAN nfGreaterZero (number k, const coeffs r);
number  nfMult        (number a, number b, const coeffs r);
number  nfInit        (long i, const coeffs r);
number  nfParameter   (int i, const coeffs r);
int     nfInt         (number &n, const coeffs r);
number  nfAdd         (number a, number b, const coeffs r);
number  nfSub         (number a, number b, const coeffs r);
void    nfPower       (number a, int i, number * result, const coeffs r);
BOOLEAN nfIsZero      (number a, const coeffs r);
BOOLEAN nfIsOne       (number a, const coeffs r);
BOOLEAN nfIsMOne      (number a, const coeffs r);
number  nfDiv         (number a, number b, const coeffs r);
number  nfNeg         (number c, const coeffs r);
number  nfInvers      (number c, const coeffs r);
BOOLEAN nfGreater     (number a, number b, const coeffs r);
BOOLEAN nfEqual       (number a, number b, const coeffs r);
const char *  nfRead  (const char *s, number *a, const coeffs r);
#ifdef LDEBUG
BOOLEAN nfDBTest      (number a, const char *f, const int l, const coeffs r);
#endif
//void    nfSetChar     (const coeffs r);

nMapFunc nfSetMap     (const coeffs src, const coeffs dst);
char *  nfName        (number n, const coeffs r);
void    nfReadTable   (const int c, const coeffs r);

void    nfCoeffWrite(const coeffs r, BOOLEAN details);
void    nfShowMipo(const coeffs r);



/// Our Type!
static const n_coeffType ID = n_GF;

//unsigned short *nfPlus1Table=NULL; /* the table i=log(z^i) -> log(z^i+1) */

const double sixteenlog2= 11.09035489;
/* the q's from the table 'fftable' */
unsigned short fftable[]={
    4,  8, 16, 32, 64, 128, 256, 512,1024,2048,4096,8192,16384, 32768,
/*2^2 2^3 2^4 2^5 2^6  2^7  2^8  2^9 2^10 2^11 2^12 2^13  2^14  2^15*/
    9, 27, 81,243,729,2187, 6561,19683,59049,
/*3^2 3^3 3^4 3^5 3^6  3^7  3^8   3^9  3^10*/
   25,125,625,3125,15625,
/*5^2 5^3 5^4 5^5  5^6*/
   49,343,2401,16807,
/*7^2 7^3  7^4 7^5*/
   121,1331, 14641,
/*11^2 11^3  11^4*/
  169, 2197, 28561,
/*13^2 13^3  13^4*/
  289, 4913,
/*17^2 17^3*/
  361, 6859,
/*19^2 19^3*/
  529, 12167,
/*23^2 23^3*/
  841, 24389,
/*29^2 29^3*/
  961, 29791,
/*31^2 31^3*/
  1369, 50653,
/*37^2  37^3*/
  1681, /*41^2*/
  1849, /*43^2*/
  2209, /*47^2*/
  2809, /*53^2*/
  3481, /*59^2*/
  3721, /*61^2*/
  4489, /*67^2*/
  5041, /*71^2*/
  5329, /*73^2*/
  6241, /*79^2*/
  6889, /*83^2*/
  7921, /*89^2*/
  9409, /*97^2*/
  10201, /*101^2*/
  10609, /*103^2*/
  11449, /*107^2*/
  11881, /*109^2*/
  12769, /*113^2*/
  16129, /*127^2*/
  17161, /*131^2*/
  18769, /*137^2*/
  19321, /*139^2*/
  22201, /*149^2*/
  22801, /*151^2*/
  24649, /*157^2*/
  26569, /*163^2*/
  27889, /*167^2*/
  29929, /*173^2*/
  32041, /*179^2*/
  32761, /*181^2*/
  36481, /*191^2*/
  37249, /*193^2*/
  38809, /*197^2*/
  39601, /*199^2*/
  49729, /*223^2*/
  44521, /*211^2*/
  51529, /*227^2*/
  52441, /*229^2*/
  54289, /*233^2*/
  57121, /*239^2*/
  58081, /*241^2*/
  63001, /*251^2*/
  0 };

/*1
* numbers in GF(p^n):
* let nfCharQ=q=nfCharP^n=p^n
* GF(q)\{0} will be generated by powers of an element Z
* Z^i will be represented by the int i, 1 by the int 0, 0 by the int q=nfChar
*/

#ifdef LDEBUG
/*2
* debugging: is a a valid representation of a number ?
*/
BOOLEAN nfDBTest (number a, const char *f, const int l, const coeffs r)
{
  assume( r->m_nfPlus1Table != NULL );
  if (((long)a<0L) || ((long)a>(long)r->m_nfCharQ))
  {
    Print("wrong %d in %s:%d\n",(int)((long)a),f,l);
    return FALSE;
  }
  int i=0;
  do
  {
    if (r->m_nfPlus1Table[i]>r->m_nfCharQ)
    {
      Print("wrong table %d=%d in %s:%d\n",i,r->m_nfPlus1Table[i],f,l);
      return FALSE;
    }
    i++;
  } while (i<r->m_nfCharQ);
  return TRUE;
}
#define nfTest(N, R) nfDBTest(N,__FILE__,__LINE__, R)
#endif

/*2
* k >= 0 ?
*/
BOOLEAN nfGreaterZero (number k, const coeffs r)
{
#ifdef LDEBUG
  nfTest(k, r);
#endif
  return !nfIsZero(k, r) && !nfIsMOne(k, r);
}

/*2
* a*b
*/
number nfMult (number a,number b, const coeffs r)
{
#ifdef LDEBUG
  nfTest(a, r);
  nfTest(b, r);
#endif
  if (((long)a == (long)r->m_nfCharQ) || ((long)b == (long)r->m_nfCharQ))
    return (number)(long)r->m_nfCharQ;
  /*else*/
  int i=(int)((long)a+(long)b);
  if (i>=r->m_nfCharQ1) i-=r->m_nfCharQ1;
#ifdef LDEBUG
  nfTest((number)(long)i, r);
#endif
  return (number)(long)i;
}

/*2
* int -> number
*/
number nfInit (long i, const coeffs r)
{
  assume( r->m_nfPlus1Table != NULL );
  // Hmm .. this is just to prevent initialization
  // from nfInitChar to go into an infinite loop
  if (i==0) return (number)(long)r->m_nfCharQ;
  while (i <  0)    i += r->m_nfCharP;
  while (i >= r->m_nfCharP) i -= r->m_nfCharP;
  if (i==0) return (number)(long)r->m_nfCharQ;
  unsigned short c=0;
  while (i>1)
  {
    c=r->m_nfPlus1Table[c];
    i--;
  }
#ifdef LDEBUG
  nfTest((number)(long)c, r);
#endif
  return (number)(long)c;
}

/*
* the generating element `z`
*/
number nfParameter (int i, const coeffs)
{
  assume(i==1);

  if( i == 1 )
    return (number)1;

  return NULL;
}

/*2
* the degree of the "alg. number"
*/
static int nfParDeg(number n, const coeffs r)
{
#ifdef LDEBUG
  nfTest(n, r);
#endif
  if((long)r->m_nfCharQ == (long)n) return -1;
  return (int)((long)n);
}

/*2
* number -> int
*/
int nfInt (number &, const coeffs )
{
  return 0;
}

/*2
* a + b
*/
number nfAdd (number a, number b, const coeffs R)
{
/*4 z^a+z^b=z^b*(z^(a-b)+1), if a>=b; *
*          =z^a*(z^(b-a)+1)  if a<b  */
#ifdef LDEBUG
  nfTest(a, R);
  nfTest(b, R);
#endif
  if ((long)R->m_nfCharQ == (long)a) return b;
  if ((long)R->m_nfCharQ == (long)b) return a;
  long zb,zab,r;
  if ((long)a >= (long)b)
  {
    zb = (long)b;
    zab = (long)a-(long)b;
  }
  else
  {
    zb = (long)a;
    zab = (long)b-(long)a;
  }
#ifdef LDEBUG
  nfTest((number)zab, R);
#endif
  if (R->m_nfPlus1Table[zab]==R->m_nfCharQ) r=(long)R->m_nfCharQ; /*if z^(a-b)+1 =0*/
  else
  {
    r= zb+(long)R->m_nfPlus1Table[zab];
    if(r>=(long)R->m_nfCharQ1) r-=(long)R->m_nfCharQ1;
  }
#ifdef LDEBUG
  nfTest((number)r, R);
#endif
  return (number)r;
}

/*2
* a - b
*/
number nfSub (number a, number b, const coeffs r)
{
  number mb = nfNeg(b, r);
  return nfAdd(a,mb,r);
}

/*2
* a == 0 ?
*/
BOOLEAN nfIsZero (number  a, const coeffs r)
{
#ifdef LDEBUG
  nfTest(a, r);
#endif
  return (long)r->m_nfCharQ == (long)a;
}

/*2
* a == 1 ?
*/
BOOLEAN nfIsOne (number a, const coeffs r)
{
#ifdef LDEBUG
  nfTest(a, r);
#endif
  return 0L == (long)a;
}

/*2
* a == -1 ?
*/
BOOLEAN nfIsMOne (number a, const coeffs r)
{
#ifdef LDEBUG
  nfTest(a, r);
#endif
  if (0L == (long)a) return FALSE; /* special handling of char 2*/
  return (long)r->m_nfM1 == (long)a;
}

/*2
* a / b
*/
number nfDiv (number a,number b, const coeffs r)
{
#ifdef LDEBUG
  nfTest(b, r);
#endif
  if ((long)b==(long)r->m_nfCharQ)
  {
    WerrorS(nDivBy0);
    return (number)((long)r->m_nfCharQ);
  }
#ifdef LDEBUG
  nfTest(a, r);
#endif
  if ((long)a==(long)r->m_nfCharQ)
    return (number)((long)r->m_nfCharQ);
  /*else*/
  long s = (long)a - (long)b;
  if (s < 0L)
    s += (long)r->m_nfCharQ1;
#ifdef LDEBUG
  nfTest((number)s, r);
#endif
  return (number)s;
}

/*2
* 1 / c
*/
number  nfInvers (number c, const coeffs r)
{
#ifdef LDEBUG
  nfTest(c, r);
#endif
  if ((long)c==(long)r->m_nfCharQ)
  {
    WerrorS(nDivBy0);
    return (number)((long)r->m_nfCharQ);
  }
#ifdef LDEBUG
  nfTest(((number)((long)r->m_nfCharQ1-(long)c)), r);
#endif
  return (number)((long)r->m_nfCharQ1-(long)c);
}

/*2
* -c
*/
number nfNeg (number c, const coeffs r)
{
/*4 -z^c=z^c*(-1)=z^c*nfM1*/
#ifdef LDEBUG
  nfTest(c, r);
#endif
  if ((long)r->m_nfCharQ == (long)c) return c;
  long i=(long)c+(long)r->m_nfM1;
  if (i>=(long)r->m_nfCharQ1) i-=(long)r->m_nfCharQ1;
#ifdef LDEBUG
  nfTest((number)i, r);
#endif
  return (number)i;
}

/*2
* a > b ?
*/
BOOLEAN nfGreater (number a,number b, const coeffs r)
{
#ifdef LDEBUG
  nfTest(a, r);
  nfTest(b, r);
#endif
  return (long)a != (long)b;
}

/*2
* a == b ?
*/
BOOLEAN nfEqual (number a,number b, const coeffs r)
{
#ifdef LDEBUG
  nfTest(a, r);
  nfTest(b, r);
#endif
  return (long)a == (long)b;
}

/*2
* write via StringAppend
*/
static void nfWriteLong (number &a, const coeffs r)
{
#ifdef LDEBUG
  nfTest(a, r);
#endif
  if ((long)a==(long)r->m_nfCharQ)  StringAppendS("0");
  else if ((long)a==0L)   StringAppendS("1");
  else if (nfIsMOne(a, r))   StringAppendS("-1");
  else
  {
    StringAppendS(n_ParameterNames(r)[0]);
    if ((long)a!=1L)
    {
      StringAppend("^%d",(int)((long)a)); // long output!
    }
  }
}


/*2
* write (shortert output) via StringAppend
*/
static void nfWriteShort (number &a, const coeffs r)
{
#ifdef LDEBUG
  nfTest(a, r);
#endif
  if ((long)a==(long)r->m_nfCharQ)  StringAppendS("0");
  else if ((long)a==0L)   StringAppendS("1");
  else if (nfIsMOne(a, r))   StringAppendS("-1");
  else
  {
    StringAppendS(n_ParameterNames(r)[0]);
    if ((long)a!=1L)
    {
      StringAppend("%d",(int)((long)a));
    }
  }
}

/*2
*
*/
char * nfName(number a, const coeffs r)
{
#ifdef LDEBUG
  nfTest(a, r);
#endif
  char *s;
  const char * const nf_Parameter=n_ParameterNames(r)[0];
  if (((long)a==(long)r->m_nfCharQ) || ((long)a==0L)) return NULL;
  else if ((long)a==1L)
  {
    return omStrDup(nf_Parameter);
  }
  else
  {
    s=(char *)omAlloc(4+strlen(nf_Parameter));
    sprintf(s,"%s%d",nf_Parameter,(int)((long)a));
  }
  return s;
}
/*2
* c ^ i with i>=0
*/
void nfPower (number a, int i, number * result, const coeffs r)
{
#ifdef LDEBUG
  nfTest(a, r);
#endif
  if (i==0)
  {
    *result = (number)0L;
  }
  else if (i==1)
  {
    *result = a;
  }
  else
  {
    long rl;
    if ((long)a == (long)r->m_nfCharQ) rl=(long)r->m_nfCharQ;
    else rl=((long)a*(long)i) % (long)r->m_nfCharQ1;
    *result = (number)rl;
  }
#ifdef LDEBUG
  nfTest(*result, r);
#endif
}

/*4
* read an integer (with reduction mod p)
*/
static const char* nfEati(const char *s, int *i, const coeffs r)
{
  if (*s >= '0' && *s <= '9')
  {
    *i = 0;
    do
    {
      *i *= 10;
      *i += *s++ - '0';
      if (*i > (MAX_INT_VAL / 10)) *i = *i % r->m_nfCharP;
    }
    while (*s >= '0' && *s <= '9');
    if (*i >= r->m_nfCharP) *i = *i % r->m_nfCharP;
  }
  else *i = 1;
  return s;
}

/*2
* read a number
*/
const char * nfRead (const char *s, number *a, const coeffs r)
{
  int i;
  number z;
  number n;

  s = nfEati(s, &i, r);
  z=nfInit(i, r);
  *a=z;
  if (*s == '/')
  {
    s++;
    s = nfEati(s, &i, r);
    n=nfInit(i, r);
    *a = nfDiv(z,n,r);
  }
  const char * const nf_Parameter = n_ParameterNames(r)[0];
  const int N = strlen(nf_Parameter);
  if (strncmp(s,nf_Parameter, N)==0)
  {
    s += N;
    if ((*s >= '0') && (*s <= '9'))
    {
      s=eati(s,&i);
      while (i>=r->m_nfCharQ1) i-=r->m_nfCharQ1;
    }
    else
      i=1;
    z=(number)(long)i;
    *a=nfMult(*a,z,r);
  }
#ifdef LDEBUG
  nfTest(*a, r);
#endif
  return s;
}

int gf_tab_numdigits62 ( int q );
int convertback62 ( char * p, int n );

int nfMinPoly[16];

void nfShowMipo(const coeffs r)
{
  int i=nfMinPoly[0];
  int j=0;
  loop
  {
    j++;
    if (nfMinPoly[j]!=0)
      StringAppend("%d*%s^%d",nfMinPoly[j],n_ParameterNames(r)[0],i);
    i--;
    if(i<0) break;
    if (nfMinPoly[j]!=0)
      StringAppendS("+");
  }
}

static void nfReadMipo(char *s)
{
  const char *l=strchr(s,';')+1;
  char *n;
  int i=strtol(l,&n,10);
  l=n;
  int j=1;
  nfMinPoly[0]=i;
  while(i>=0)
  {
    nfMinPoly[j]=strtol(l,&n,10);
    if (l==n) break;
    l=n;
    j++;
    i--;
  }
  if (i>=0)
  {
    WerrorS("error in reading minpoly from gftables");
  }
}

/*2
* init global variables from files 'gftables/%d'
*/
void nfReadTable(const int c, const coeffs r)
{
  //Print("GF(%d)\n",c);
  if ((c==r->m_nfCharQ)||(c==-r->m_nfCharQ))
    /*this field is already set*/  return;
  int i=0;

  while ((fftable[i]!=c) && (fftable[i]!=0))
    i++;

  if (fftable[i]==0)
  {
#ifndef SING_NDEBUG
    Warn("illegal GF-table size: %d", c);
#endif
    return;
  }

  if (r->m_nfCharQ > 1)
  {
    omFreeSize( (ADDRESS)r->m_nfPlus1Table,r->m_nfCharQ*sizeof(unsigned short) );
    r->m_nfPlus1Table=NULL;
  }
  if ((c>1) || (c<0))
  {
    if (c>1) r->m_nfCharQ = c;
    else     r->m_nfCharQ = -c;
    char buf[100];
    sprintf(buf,"gftables/%d",r->m_nfCharQ);
    FILE * fp = feFopen(buf,"r",NULL,TRUE);
    if (fp==NULL)
    {
      return;
    }
    if(!fgets( buf, sizeof(buf), fp)) return;
    if(strcmp(buf,"@@ factory GF(q) table @@\n")!=0)
    {
      goto err;
    }
    if(!fgets( buf, sizeof(buf), fp))
    {
      goto err;
    }
    int q;
    int res = -1;
    do
    {
      res = sscanf(buf,"%d %d",&r->m_nfCharP,&q);
    }
    while((res < 0) and (errno == EINTR));

    nfReadMipo(buf);
    r->m_nfCharQ1=r->m_nfCharQ-1;
    //Print("nfCharQ=%d,nfCharQ1=%d,mipo=>>%s<<\n",nfCharQ,nfCharQ1,buf);
    r->m_nfPlus1Table= (unsigned short *)omAlloc( (r->m_nfCharQ)*sizeof(unsigned short) );
    int digs = gf_tab_numdigits62( r->m_nfCharQ );
    char * bufptr;
    int i = 1;
    int k;
    while ( i < r->m_nfCharQ )
    {
      (void)fgets( buf, sizeof(buf), fp);
      //( strlen( buffer ) == (size_t)digs * 30, "illegal table" );
      bufptr = buf;
      k = 0;
      while ( (i < r->m_nfCharQ) && (k < 30) )
      {
        r->m_nfPlus1Table[i] = convertback62( bufptr, digs );
        if(r->m_nfPlus1Table[i]>r->m_nfCharQ)
        {
          Print("wrong entry %d: %d(%c%c%c)\n",i,r->m_nfPlus1Table[i],bufptr[0],bufptr[1],bufptr[2]);
        }
        bufptr += digs;
        if (r->m_nfPlus1Table[i]==r->m_nfCharQ)
        {
          if(i==r->m_nfCharQ1)
          {
            r->m_nfM1=0;
          }
          else
          {
            r->m_nfM1=i;
          }
        }
        i++; k++;
      }
    }
    r->m_nfPlus1Table[0]=r->m_nfPlus1Table[r->m_nfCharQ1];
  }
  else
    r->m_nfCharQ=0;
#ifdef LDEBUG
  nfTest((number)0, r);
#endif
  return;
err:
  Werror("illegal GF-table %d",r->m_nfCharQ);
}

/*2
* map Z/p -> GF(p,n)
*/
number nfMapP(number c, const coeffs, const coeffs dst)
{
  return nfInit((int)((long)c), dst);
}

/*2
* map GF(p,n1) -> GF(p,n2), n1 < n2, n1 | n2
*/
int nfMapGG_factor;
number nfMapGG(number c, const coeffs src, const coeffs)
{
  int i=(long)c;
  i*= nfMapGG_factor;
  while (i >src->m_nfCharQ1) i-=src->m_nfCharQ1;
  return (number)((long)i);
}
/*2
* map GF(p,n1) -> GF(p,n2), n1 > n2, n2 | n1
*/
number nfMapGGrev(number c, const coeffs src, const coeffs)
{
  int ex=(int)((long)c);
  if ((ex % nfMapGG_factor)==0)
    return (number)(((long)ex) / ((long)nfMapGG_factor));
  else
    return (number)(long)src->m_nfCharQ; /* 0 */
}

/*2
* set map function nMap ... -> GF(p,n)
*/
nMapFunc nfSetMap(const coeffs src, const coeffs dst)
{
  if (nCoeff_is_GF(src,src->m_nfCharQ))
  {
    return ndCopyMap;   /* GF(p,n) -> GF(p,n) */
  }
  if (nCoeff_is_GF(src))
  {
    const coeffs r = dst;
    int q=src->ch;
    if ((src->m_nfCharQ % q)==0) /* GF(p,n1) -> GF(p,n2), n2 > n1 */
    {
      // check if n2 is a multiple of n1
      int n1=1;
      int qq=r->m_nfCharP;
      while(qq!=q) { qq *= r->m_nfCharP; n1++; }
      int n2=1;
      qq=r->m_nfCharP;
      while(qq!=src->m_nfCharQ) { qq *= r->m_nfCharP; n2++; }
      //Print("map %d^%d -> %d^%d\n",r->m_nfCharP,n1,r->m_nfCharP,n2);
      if ((n2 % n1)==0)
      {
        int save_ch=r->m_nfCharQ;
        nfReadTable(src->m_nfCharQ, r);
        int nn=r->m_nfPlus1Table[0];
        nfReadTable(save_ch, r);
        nfMapGG_factor= r->m_nfPlus1Table[0] / nn;
        //Print("nfMapGG_factor=%d (%d / %d)\n",nfMapGG_factor, r->m_nfPlus1Table[0], nn);
        return nfMapGG;
      }
      else if ((n1 % n2)==0)
      {
        nfMapGG_factor= (n1/n2);
        return nfMapGGrev;
      }
      else
        return NULL;
    }
  }
  if ((src->rep==n_rep_int) && nCoeff_is_Zp(src,dst->m_nfCharP))
  {
    return nfMapP;    /* Z/p -> GF(p,n) */
  }
  if (src->rep==n_rep_gap_rat) /*Q, Z */
    return nlModP;
  return NULL;     /* default */
}

static BOOLEAN nfCoeffIsEqual(const coeffs, n_coeffType, void*);

static void nfKillChar(coeffs r)
{
  char** p = (char**)n_ParameterNames(r);

  const int P = n_NumberOfParameters(r);

  for( int i = 1; i <= P; i++ )
    if (p[i-1] != NULL)
      omFree( (ADDRESS)p[i-1] );

  omFreeSize((ADDRESS)p, P * sizeof(char*));
}

static char* nfCoeffString(const coeffs r)
{
  const char *p=n_ParameterNames(r)[0];
  char *s=(char*)omAlloc(11+1+strlen(p));
  sprintf(s,"%d,%s",r->m_nfCharQ,p);
  return s;
}

BOOLEAN nfInitChar(coeffs r,  void * parameter)
{
  r->is_field=TRUE;
  r->is_domain=TRUE;
  r->rep=n_rep_gf;
  //r->cfInitChar=npInitChar;
  r->cfKillChar=nfKillChar;
  r->nCoeffIsEqual=nfCoeffIsEqual;
  r->cfCoeffString=nfCoeffString;

  r->cfMult  = nfMult;
  r->cfSub   = nfSub;
  r->cfAdd   = nfAdd;
  r->cfDiv   = nfDiv;
  //r->cfIntMod= ndIntMod;
  r->cfExactDiv= nfDiv;
  r->cfInit = nfInit;
  //r->cfSize  = ndSize;
  r->cfInt  = nfInt;
  #ifdef HAVE_RINGS
  //r->cfDivComp = NULL; // only for ring stuff
  //r->cfIsUnit = NULL; // only for ring stuff
  //r->cfGetUnit = NULL; // only for ring stuff
  //r->cfExtGcd = NULL; // only for ring stuff
  // r->cfDivBy = NULL; // only for ring stuff
  #endif
  r->cfInpNeg   = nfNeg;
  r->cfInvers= nfInvers;
  //r->cfCopy  = ndCopy;
  //r->cfRePart = ndCopy;
  //r->cfImPart = ndReturn0;

  r->cfWriteLong = nfWriteLong;
  r->cfRead = nfRead;
  //r->cfNormalize=ndNormalize;
  r->cfGreater = nfGreater;
  r->cfEqual = nfEqual;
  r->cfIsZero = nfIsZero;
  r->cfIsOne = nfIsOne;
  r->cfIsMOne = nfIsMOne;
  r->cfGreaterZero = nfGreaterZero;
  r->cfPower = nfPower;
  //r->cfGcd  = ndGcd;
  //r->cfLcm  = ndGcd;
  //r->cfDelete= ndDelete;
  r->cfSetMap = nfSetMap;
  //r->cfName = ndName;
  // debug stuff
  r->cfCoeffWrite=nfCoeffWrite;

  r->cfParDeg = nfParDeg;

#ifdef LDEBUG
  r->cfDBTest=nfDBTest;
#endif

  // the variables:
  r->nNULL = (number)0;
  assume( getCoeffType(r) == n_GF );

  GFInfo* p = (GFInfo *)(parameter);
  assume (p->GFChar > 0);
  assume (p->GFDegree > 0);

  const char * name = p->GFPar_name;

  r->m_nfCharQ = 0;
  r->m_nfCharP = p->GFChar;
  r->m_nfCharQ1 = 0;

  r->iNumberOfParameters = 1;
  r->cfParameter = nfParameter;

  char ** pParameterNames = (char **) omAlloc0(sizeof(char *));
  pParameterNames[0] = omStrDup(name); //TODO use omAlloc for allocating memory and use strcpy?

  assume( pParameterNames != NULL );
  assume( pParameterNames[0] != NULL );

  r->pParameterNames = (const char**)pParameterNames;
  // NOTE: r->m_nfParameter was replaced by n_ParameterNames(r)[0]

  // TODO: nfKillChar MUST destroy r->pParameterNames[0] (0-term. string) && r->pParameterNames (array of size 1)

  r->m_nfPlus1Table= NULL;

  if (strlen(name) > 1)
    r->cfWriteShort = nfWriteLong;
  else
    r->cfWriteShort = nfWriteShort;

  r->has_simple_Alloc=TRUE;
  r->has_simple_Inverse=TRUE;

  if(p->GFChar > (2<<15))
  {
#ifndef SING_NDEBUG
    Warn("illegal characteristic");
#endif
    return TRUE;
  }

  const double check= log ((double) (p->GFChar));

  if( (p->GFDegree * check) > sixteenlog2 )
  {
#ifndef SING_NDEBUG
    Warn("Sorry: illegal size: %u ^ %u", p->GFChar, p->GFDegree );
#endif
    return TRUE;
  }

  int c = pow (p->GFChar, p->GFDegree);

  nfReadTable(c, r);

  if( r->m_nfPlus1Table == NULL )
  {
#ifndef SING_NDEBUG
    Warn("Sorry: cannot init lookup table!");
#endif
    return TRUE;
  }


  assume (r -> m_nfCharQ > 0);

  r->ch = r->m_nfCharP;
  assume( r->m_nfPlus1Table != NULL );

  return FALSE;

}

void    nfCoeffWrite  (const coeffs r, BOOLEAN details)
{
  // m_nfCharQ = p^k where p is the characteristic (r->CharP) and k is GFDegree
  Print("//   # ground field : %d\n",r->m_nfCharQ);
  Print("//   primitive element : %s\n", n_ParameterNames(r)[0]);
  if ( details )
  {
    StringSetS("//   minpoly        : ");
    nfShowMipo(r);
    StringAppendS("\n");
    char *s=StringEndS(); PrintS(s); omFree(s);
  }
  else PrintS("//   minpoly        : ...\n");
}

static BOOLEAN nfCoeffIsEqual (const coeffs r, n_coeffType n, void * parameter)
{
  if (n==n_GF) {
    GFInfo* p = (GFInfo *)(parameter);
    int c = pow (p->GFChar, p->GFDegree);
    if ((c == r->m_nfCharQ) && (strcmp(n_ParameterNames(r)[0], p->GFPar_name) == 0))
      return TRUE;
  }
  return FALSE;
}

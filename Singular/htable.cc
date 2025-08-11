/****************************************
*  Computer Algebra System SINGULAR     *
****************************************/

#include "kernel/mod2.h"

#include "resources/hash_me.h"
#include "reporter/reporter.h"
#include "Singular/htable.h"

stablerec* t_createTable(int s)
{
  stablerec* t=(stablerec*)omAlloc(sizeof(stablerec));
  t->max=s;
  t->t=(telem*)omAlloc0(s*sizeof(telem));
  t->ref=1;
  return t;
}

void t_destroyTable(stablerec* t)
{
  t->ref--;
  if (t->ref<=0)
  {
    for(int i=t->max-1;i>=0;i--)
    {
      telem p=t->t[i];
      while(p!=NULL)
      {
        omFree(p->key);
        p->val.CleanUp();
        telem pp=p;
        p=p->next;
        omFreeSize(pp,sizeof(stelem));
      }
    }
  }
}

stablerec* copyTable(stablerec* t)
{
  t->ref++;
  return t;
}

char* stringTable(stablerec* t)
{
  StringSetS("table:\n");
  for(int i=t->max-1;i>=0;i--)
  {
    telem p=t->t[i];
    while(p!=NULL)
    {
        StringAppendS(p->key);
        StringAppendS("->");
        StringAppendS(p->val.String());
        StringAppendS("\n");
        telem pp=p;
        p=p->next;
    }
    return StringEndS();
  }
}

/// find the entry to key s
telem t_findTable(stablerec* t,const char *s)
{
  uint32_t h=hashlittle(s,strlen(s));
  h=h%t->max;
  telem p=t->t[h];
  while(p!=NULL)
  {
    if (strcmp(s,p->key)==0) return p;
    p=p->next;
  }
  return NULL;
}

/// find the data to key s
leftv t_findTabelVal(stablerec* t,const char *s)
{
  telem p=t_findTable(t,s);
  if (p==NULL) return NULL;
  return &(p->val);
}

/// add a new entry (key s, data v) to table t
void t_addTable(stablerec* t,const char *s, leftv v)
{
  uint32_t h=hashlittle(s,strlen(s));
  telem p=(telem)omAlloc(sizeof(stelem));
  p->next=NULL;
  p->key=omStrDup(s);
  p->val.Copy(v);
  p->hash=h;
  h=h%t->max;
  p->next=t->t[h];
  t->t[h]=p;
}

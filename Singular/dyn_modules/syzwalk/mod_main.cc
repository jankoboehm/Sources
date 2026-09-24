/****************************************
*  Computer Algebra System SINGULAR     *
****************************************/
/*
 * Fast relation bookkeeping for standard-basis computations.
 */

#include "Singular/libsingular.h"
#include "Singular/lists.h"
#include "Singular/mod_lib.h"

static BOOLEAN liftstdSyzInternal(leftv res, leftv args)
{
  if ((args==NULL)
      || ((args->Typ()!=IDEAL_CMD) && (args->Typ()!=MODUL_CMD))
      || (args->next!=NULL))
  {
    WerrorS("liftstdSyz: expected one ideal or module");
    return TRUE;
  }

  const int inputType=args->Typ();
  matrix transformation=NULL;
  ideal relations=NULL;
  ideal basis=idLiftStdSyz((ideal)args->Data(),&transformation,&relations);

  if ((basis==NULL) || errorreported)
  {
    idDelete((ideal*)&transformation);
    idDelete(&relations);
    return TRUE;
  }

  lists result=(lists)omAllocBin(slists_bin);
  result->Init(3);
  result->m[0].rtyp=inputType;
  result->m[0].data=basis;
  setFlag(&result->m[0],FLAG_STD);
  result->m[1].rtyp=MATRIX_CMD;
  result->m[1].data=transformation;
  result->m[2].rtyp=MODUL_CMD;
  result->m[2].data=relations;

  res->rtyp=LIST_CMD;
  res->data=result;
  args->CleanUp();
  return FALSE;
}

extern "C" int SI_MOD_INIT(syzwalk)(SModulFunctions* p)
{
  p->iiAddCproc("syzwalk.lib","liftstdSyzInternal",FALSE,
                liftstdSyzInternal);
  return MAX_TOK;
}

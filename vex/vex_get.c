#include <stdio.h>

#include "vex.h"
#include "y.tab.h"

#define TRUE 1
#define FALSE 0

extern FILE * yyin;
extern struct vex *vex_ptr;

/*---------------------------------------------------------------------------*/
int vex_open(char *name, struct vex **vex)
{
  *vex=NULL;
  yyin=fopen(name,"r");
  if(yyin==NULL)
    return -1;
  if(yyparse())
    return -2;

  *vex=vex_ptr;
  close(yyin);
  return 0;
}
/*---------------------------------------------------------------------------*/
void *
get_scan_start(Llist *lowls)
{
  lowls=find_lowl(lowls,T_START);
  if(lowls==NULL)
    return NULL;

  return ((Lowl *)lowls->ptr)->item;

}
/*---------------------------------------------------------------------------*/
void *
get_scan_mode(Llist *lowls)
{
  lowls=find_lowl(lowls,T_MODE);
  if(lowls==NULL)
    return NULL;

  return ((Lowl *)lowls->ptr)->item;

}
/*---------------------------------------------------------------------------*/
void *
get_scan_source_next()
{
  return get_scan_source(NULL);
}
/*---------------------------------------------------------------------------*/
void *
get_scan_source(Llist *lowls_scan_in)
{
  Llist *lowls_this;

  static Llist *lowls;

  static int state=FALSE;

  if(lowls_scan_in==NULL && !state)
     return NULL;

  if(lowls_scan_in!=NULL) {
    lowls=lowls_scan_in;
    state=FALSE;
  }

lstate:
  lowls=find_lowl(lowls,T_SOURCE);
  if(lowls==NULL)
    goto ldone;

  state=TRUE;

  lowls_this=lowls;
  lowls=lowls->next;
  return ((Lowl *)lowls_this->ptr)->item;

ldone:
  state=FALSE;
  return NULL;
}
/*---------------------------------------------------------------------------*/
void *
get_scan_station_next(Llist **lowls_scan)
{
  return get_scan_station(lowls_scan,NULL,NULL);
}
/*---------------------------------------------------------------------------*/
void *
get_scan_station(Llist **lowls_scan, char *station_in,
		 struct vex *vex_in)
{

  static Llist *lowls;
  static Llist *defs;

  Llist *blocks;
  Llist *lowls_this;

  static char *station;
  static struct vex *vex;

  static int state=FALSE;

  if(station_in==NULL && !state)
     return NULL;

  if(station_in!=NULL) {
    station=station_in;
    vex=vex_in;
    state=FALSE;
  }

  if(state)
    goto lstate;
 
  /* find $SCHED block */

  blocks=find_block(B_SCHED, vex);
  if(blocks==NULL)
    goto ldone;

  defs=((struct block *)blocks->ptr)->items; 

lstart:
  /* find a def */

  defs=find_next_scan(defs);

  if (defs==NULL)
    goto ldone;

  *lowls_scan=((Def *)((Lowl *)defs->ptr)->item)->refs;

  lowls=*lowls_scan;

lstate:
  lowls=find_lowl(lowls,T_STATION);
  if(lowls==NULL)
    goto lend;

  if(0!=strcmp(((struct station *)((Lowl *)lowls->ptr)->item)->key,station)) {
    lowls=lowls->next;
    goto lstate;
  }
  
  state=TRUE;

  lowls_this=lowls;
  lowls=lowls->next;
  return ((Lowl *)lowls_this->ptr)->item;

lend:
  defs=defs->next;
    goto lstart;

ldone:
    state=FALSE;
    return NULL;
}
/*---------------------------------------------------------------------------*/
char *
get_source_def_next()
{
  return get_source_def(NULL);
}
/*---------------------------------------------------------------------------*/
char *
get_source_def(struct vex *vex_in)
{
  static Llist *defs;

  Llist *blocks, *defs_this;
  
  static struct vex *vex;
  static int state=0;

  if(vex_in==NULL && !state)
     return NULL;

  if(vex_in!=NULL) {
    vex=vex_in;
    state=0;
  }
  if(state)
    goto lstate;

  /* find $SOURCE block */

  blocks=find_block(B_SOURCE, vex);
  if(blocks==NULL)
    return NULL;

  defs=((struct block *)blocks->ptr)->items;
 
  /* find a station */

  state=TRUE;

lstate:
  defs=find_next_def(defs);

  if(defs==NULL) {
    state=FALSE;
    return NULL;
  }

  defs_this=defs;
  defs=defs->next;

  return ((Def *)((Lowl *)defs_this->ptr)->item)->name;  
}
/*---------------------------------------------------------------------------*/
char *
get_mode_def_next()
{
  return get_mode_def(NULL);
}
/*---------------------------------------------------------------------------*/
char *
get_mode_def(struct vex *vex_in)
{
  static Llist *defs;

  Llist *blocks, *defs_this;
  
  static struct vex *vex;
  static int state=0;

  if(vex_in==NULL && !state)
     return NULL;

  if(vex_in!=NULL) {
    vex=vex_in;
    state=0;
  }
  if(state)
    goto lstate;

  /* find $MODE block */

  blocks=find_block(B_MODE, vex);
  if(blocks==NULL)
    return NULL;

  defs=((struct block *)blocks->ptr)->items;
 
  /* find a station */

  state=TRUE;

lstate:
  defs=find_next_def(defs);

  if(defs==NULL) {
    state=FALSE;
    return NULL;
  }

  defs_this=defs;
  defs=defs->next;

  return ((Def *)((Lowl *)defs_this->ptr)->item)->name;  
}
/*---------------------------------------------------------------------------*/
char *
get_station_def_next()
{
  return get_station_def(NULL);
}
/*---------------------------------------------------------------------------*/
char *
get_station_def(struct vex *vex_in)
{
  static Llist *defs;

  Llist *blocks, *defs_this;
  
  static struct vex *vex;
  static int state=0;

  if(vex_in==NULL && !state)
     return NULL;

  if(vex_in!=NULL) {
    vex=vex_in;
    state=0;
  }
  if(state)
    goto lstate;

  /* find $STATION block */

  blocks=find_block(B_STATION, vex);
  if(blocks==NULL)
    return NULL;

  defs=((struct block *)blocks->ptr)->items;
 
  /* find a station */

  state=TRUE;

lstate:
  defs=find_next_def(defs);

  if(defs==NULL) {
    state=FALSE;
    return NULL;
  }

  defs_this=defs;
  defs=defs->next;

  return ((Def *)((Lowl *)defs_this->ptr)->item)->name;  
}
/*---------------------------------------------------------------------------*/
void *
get_all_lowl_next()
{
  return get_all_lowl(NULL,NULL,0,0,NULL);
}
/*---------------------------------------------------------------------------*/
void *
get_all_lowl(char *station_in, char *mode_in,
	     int statement_in, int primitive_in, struct vex *vex_in)
{
  void *ptr;

  static char *station, *mode;
  static struct vex *vex;
  static int primitive,statement;

  static int state=0;

  if(vex_in==NULL && !state)
     return NULL;

  if(vex_in!=NULL) {
    station=station_in;
    mode=mode_in;
    vex=vex_in;
    primitive=primitive_in;
    statement=statement_in;
    state=0;
  }

  switch(state) {
  case 1:
    goto mode_next;
  case 2:
    goto station_next;
  case 3:
    goto global_next;
  case 4:
    goto done;
  default:
  }

  if (mode==NULL && station==NULL)
    goto global;
  else if(mode==NULL)
    goto station;
  
  state=1;
  ptr=get_mode_lowl(station, mode, statement, primitive, vex);
  if(ptr!=NULL)
    return ptr;
  
mode_next:

  ptr=get_mode_lowl_next();
  if(ptr!=NULL)
    return ptr;

station:
  state=2;
  ptr=get_station_lowl(station, statement, primitive, vex);
  if(ptr!=NULL)
    return ptr;

station_next:

  ptr=get_station_lowl_next();
  if(ptr!=NULL)
    return ptr;

global:
  state=3;
  ptr=get_global_lowl(statement, primitive, vex);

  if(ptr!=NULL)
    return ptr;

global_next:

  ptr=get_global_lowl_next();
  if(ptr!=NULL)
    return ptr;

done:
  state=4;
  return NULL;
}
/*---------------------------------------------------------------------------*/
void *
get_mode_lowl_next()
{
  return get_mode_lowl(NULL,NULL,0,0,NULL);
}
/*---------------------------------------------------------------------------*/
void *
get_mode_lowl(char *station_in, char *mode_in,
	      int statement_in, int primitive_in, struct vex *vex_in)
{

  static Llist *blocks;
  static Llist *refs;
  static Llist *lowls;

  Llist *qualifiers, *lowls_this;
  Llist *defs;
  char *def;

  static char *station, *mode;
  static struct vex *vex;
  static int primitive,statement;

  static int state=FALSE;

  if((station_in==NULL || mode_in==NULL || vex_in==NULL) && !state)
     return NULL;

  if(station_in!=NULL || mode_in!=NULL || vex_in!=NULL) {
    station=station_in;
    mode=mode_in;
    vex=vex_in;
    primitive=primitive_in;
    statement=statement_in;
    state=FALSE;
  }

  if(state)
    goto lstate;
 
  /* find $MODE block */

  blocks=find_block(B_MODE, vex);
  if(blocks==NULL)
    goto ldone;

  defs=((struct block *)blocks->ptr)->items;
 
  /* find this mode */

  defs=find_def(defs,mode);
  if (defs==NULL)
    goto ldone;

  refs=((Def *)((Lowl *)defs->ptr)->item)->refs;

  /* find primitive block */

  blocks=find_block(primitive, vex);
  if(blocks==NULL)
    goto ldone;

  /* now search through the refs for one that applies to this station */  

lstart:
    if(refs==NULL || refs->ptr==NULL)
      goto ldone;

    if(((Qref *)((Lowl *)refs->ptr)->item)->primitive
       !=primitive)
      goto lend;

    qualifiers=((Qref *)((Lowl *)refs->ptr)->item)->qualifiers;

    while(qualifiers!=NULL && qualifiers->ptr != NULL
	  && 0!=strcmp((char *)qualifiers->ptr,station))
      qualifiers=qualifiers->next;

    if(qualifiers != NULL && qualifiers->ptr == NULL)
      goto lend;
	
    if (qualifiers==NULL
	&& NULL!=((Qref *)((Lowl *)refs->ptr)->item)->qualifiers)
      goto lend;
	
    def=((Qref *)((Lowl *)refs->ptr)->item)->name;

    defs=((struct block *)blocks->ptr)->items;
 
    /* find this def */

    defs=find_def(defs,def);
    if (defs==NULL)
      goto lend;

    lowls=((Def *)((Lowl *)defs->ptr)->item)->refs;

lstate:
    lowls=find_lowl(lowls,statement);
    if(lowls==NULL)
      goto lend;

    state=TRUE;

    lowls_this=lowls;
    lowls=lowls->next;
    return ((Lowl *)lowls_this->ptr)->item;

lend:
    refs=refs->next;
    goto lstart;

ldone:
    state=FALSE;
    return NULL;
}
/*---------------------------------------------------------------------------*/
void *
get_station_lowl_next()
{
  return get_station_lowl(NULL,0,0,NULL);
}
/*---------------------------------------------------------------------------*/
void *
get_station_lowl(char *station_in,
		 int statement_in, int primitive_in, struct vex *vex_in)
{

  static Llist *blocks;
  static Llist *refs;
  static Llist *lowls;

  Llist *qualifiers, *lowls_this;
  Llist *defs;
  char *def;

  static char *station;
  static struct vex *vex;
  static int primitive,statement;

  static int state=FALSE;

  if(station_in==NULL && !state)
     return NULL;

  if(station_in!=NULL) {
    station=station_in;
    vex=vex_in;
    primitive=primitive_in;
    statement=statement_in;
    state=FALSE;
  }

  if(state)
    goto lstate;
 
  /* find $STATION block */

  blocks=find_block(B_STATION, vex);
  if(blocks==NULL)
    goto ldone;

  defs=((struct block *)blocks->ptr)->items;
 
  /* find this station */

  defs=find_def(defs,station);
  if (defs==NULL)
    goto ldone;

  refs=((Def *)((Lowl *)defs->ptr)->item)->refs;

  /* find primitive block */

  blocks=find_block(primitive, vex);
  if(blocks==NULL)
    goto ldone;

  /* now search through the refs for one that applies to this station */  

lstart:
    if(refs==NULL || refs->ptr==NULL)
      goto ldone;

    if(((Qref *)((Lowl *)refs->ptr)->item)->primitive!=primitive)
      goto lend;

    def=((Qref *)((Lowl *)refs->ptr)->item)->name;

    defs=((struct block *)blocks->ptr)->items;
 
    /* find this def */

    defs=find_def(defs,def);
    if (defs==NULL)
      goto lend;

    lowls=((Def *)((Lowl *)defs->ptr)->item)->refs;

lstate:
    lowls=find_lowl(lowls,statement);
    if(lowls==NULL)
      goto lend;

    state=TRUE;

    lowls_this=lowls;
    lowls=lowls->next;
    return ((Lowl *)lowls_this->ptr)->item;

lend:
    refs=refs->next;
    goto lstart;

ldone:
    state=FALSE;
    return NULL;
}
/*---------------------------------------------------------------------------*/
void *
get_source_lowl_next()
{
  return get_source_lowl(NULL,0,NULL);
}
/*---------------------------------------------------------------------------*/
void *
get_source_lowl(char *source_in, int statement_in, struct vex *vex_in)
{

  static Llist *blocks;
  static Llist *lowls;

  Llist *lowls_this;
  Llist *defs;
  char *def;

  static char *source;
  static struct vex *vex;
  static int statement;

  static int state=FALSE;

  if(source_in==NULL && !state)
     return NULL;

  if(source_in!=NULL) {
    source=source_in;
    vex=vex_in;
    statement=statement_in;
    state=FALSE;
  }

  if(state)
    goto lstate;
 
  /* find $SOURCE block */

  blocks=find_block(B_SOURCE, vex);
  if(blocks==NULL)
    goto ldone;

  defs=((struct block *)blocks->ptr)->items;
 
  /* find this def */

  defs=find_def(defs,source);
  if (defs==NULL)
    goto ldone;

  lowls=((Def *)((Lowl *)defs->ptr)->item)->refs;

lstart:

lstate:
  lowls=find_lowl(lowls,statement);
  if(lowls==NULL)
    goto lend;

  state=TRUE;

  lowls_this=lowls;
  lowls=lowls->next;
  return ((Lowl *)lowls_this->ptr)->item;

lend:

ldone:
  state=FALSE;
  return NULL;
}
/*---------------------------------------------------------------------------*/
void *
get_global_lowl_next()
{
  return get_global_lowl(0,0,NULL);
}
/*---------------------------------------------------------------------------*/
void *
get_global_lowl(int statement_in,
	      int primitive_in, struct vex *vex_in)
{

  static Llist *blocks;
  static Llist *refs;
  static Llist *lowls;

  Llist *defs;
  Llist *qualifiers, *lowls_this;
  char *def;

  static struct vex *vex;
  static int primitive,statement;
  static int state=FALSE;

  if(vex_in==NULL && !state)
     return NULL;

  if(vex_in!=NULL) {
    vex=vex_in;
    primitive=primitive_in;
    statement=statement_in;
    state=FALSE;
  }

  if(state)
    goto lstate;
 
  /* find $GLOBAL block */

  blocks=find_block(B_GLOBAL, vex);
  if(blocks==NULL)
    goto ldone;

  refs=((struct block *)blocks->ptr)->items;
 
  /* find primitive block */

  blocks=find_block(primitive, vex);
  if(blocks==NULL)
    goto ldone;

  /* now search through the refs for one that applies to this station */  

lstart:
    if(refs==NULL || refs->ptr==NULL)
      goto ldone;

    if(((Qref *)((Lowl *)refs->ptr)->item)->primitive!=primitive)
      goto lend;

    def=((Qref *)((Lowl *)refs->ptr)->item)->name;

    defs=((struct block *)blocks->ptr)->items;
 
    /* find this def */

    defs=find_def(defs,def);
    if (defs==NULL)
      goto lend;

    lowls=((Def *)((Lowl *)defs->ptr)->item)->refs;

lstate:
    lowls=find_lowl(lowls,statement);
    if(lowls==NULL)
      goto lend;

    state=TRUE;

    lowls_this=lowls;
    lowls=lowls->next;
    return ((Lowl *)lowls_this->ptr)->item;

lend:
    refs=refs->next;
    goto lstart;

ldone:
    state=FALSE;
    return NULL;
}
/*---------------------------------------------------------------------------*/
Llist *
find_block(int block,struct vex *vex)
{
  Llist *blocks;

  blocks=vex->blocks;

  while(blocks!=NULL && blocks->ptr!=NULL
	&& ((struct block *)blocks->ptr)->block!=block)
    blocks=blocks->next;

  if(blocks!=NULL && blocks->ptr == NULL) {
    fprintf(stderr,"mislinkage in find_block\n");
    exit(1);
  }

  return blocks;
}
/*---------------------------------------------------------------------------*/
Llist *
find_def(Llist *defs,char *mode)
{
  while(defs!=NULL && defs->ptr!=NULL
	&& (((Lowl *)defs->ptr)->statement != T_DEF
	    || strcmp(((Def *)((Lowl *)defs->ptr)->item)->name, mode)!=0))
    defs=defs->next;

  if(defs!=NULL && defs->ptr==NULL) {
    fprintf(stderr,"mislinkage in find_def\n");
    exit(1);
  }

   return defs;
}
/*---------------------------------------------------------------------------*/
Llist *
find_lowl(Llist *lowls,int statement)
{
  while(lowls!=NULL && lowls->ptr!=NULL
	&& ((Lowl *)lowls->ptr)->statement!=statement)
    lowls=lowls->next;
  
  if(lowls!=NULL && lowls->ptr==NULL) {
    fprintf(stderr,"mislinkage in find_lowl\n");
    exit(1);
  }
  return lowls;
}
/*---------------------------------------------------------------------------*/
Llist *
find_next_def(Llist *defs)
{
  while(defs!=NULL && defs->ptr!=NULL
	&& ((Lowl *)defs->ptr)->statement != T_DEF)
    defs=defs->next;

  if(defs!=NULL && defs->ptr==NULL) {
    fprintf(stderr,"mislinkage in find_next_def\n");
    exit(1);
  }

   return defs;
}
/*---------------------------------------------------------------------------*/
Llist *
find_next_scan(Llist *defs)
{
  while(defs!=NULL && defs->ptr!=NULL
	&& ((Lowl *)defs->ptr)->statement != T_SCAN)
    defs=defs->next;

  if(defs!=NULL && defs->ptr==NULL) {
    fprintf(stderr,"mislinkage in find_next_scan\n");
    exit(1);
  }

   return defs;
}

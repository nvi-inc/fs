#include <stdio.h>
#include <string.h>

#include "vex.h"
#include "y.tab.h"

void print_vex(struct vex *vex)
{
  print_lowl(vex->version);

  print_vex_blocks(vex->blocks);
  printf("\n");
}
void print_vex_blocks(struct llist *blocks)
{
  char *ptr;

  while (blocks!=NULL) {
    struct block *this=(struct block *)blocks->ptr;
    switch (this->block) {
    case B_GLOBAL:
      printf("\n$GLOBAL;");
      print_qref_block(this->items);
      break;
    case B_STATION:
      printf("\n$STATION;");
      print_def_block(this->items,print_qref_block);
      break;
    case B_MODE:
      printf("\n$MODE;");
      print_def_block(this->items,print_qref_block);
      break;
    case T_COMMENT:
      print_comment((char *)this->items);
      break;
    case T_COMMENT_TRAILING:
      print_comment_trailing((char *)this->items);
      break;
    default:
      printf("\n");
      print_block_name(this->block);
      printf(";");
      print_def_block(this->items,print_lowl);
      break;
    }
    blocks=blocks->next;
  }
}
void print_def_block(struct llist *items,void func())
{
  while (items!=NULL) {
    struct lowl *this=(struct lowl *)items->ptr;
    switch(this->statement) {
    case T_DEF:
      {struct def *def=(struct def *)this->item;

      printf("\n  def ");
      print_svalue(def->name);
      printf(";");

      func(def->refs);

      printf("\n  enddef;");
      }
      break;
    case T_COMMENT:
      print_comment((char *)this->item);
      break;
    case T_COMMENT_TRAILING:
      print_comment_trailing((char *)this->item);
      break;
    default:
      fprintf(stderr,"Unknown def_lowl %d",this->statement);
      exit(1);
    }
    items=items->next;
  }
}
void print_qref_block(struct llist *items)
{
  while (items!=NULL) {
    struct lowl *this=(struct lowl *)items->ptr;
    switch(this->statement) {
    case T_REF:
      {struct qref *qref=(struct qref *)this->item;
      printf("\n    ref ");
      print_block_name(qref->primitive);
      printf(" = ");
      print_svalue(qref->name);
      print_qualifiers(qref->qualifiers);
      printf(";");
      }
      break;
    case T_COMMENT:
      print_comment((char *)this->item);
      break;
    case T_COMMENT_TRAILING:
      print_comment_trailing((char *)this->item);
      break;
    default:
      fprintf(stderr,"Unknown def_lowl %d",this->statement);
      exit(1);
    }
    items=items->next;
  }
}
void print_block_name(int block)
{
  char *ptr;

  ptr=int2block(block);
  if(ptr==NULL) {
    fprintf(stderr,"unknown block in print_block_name %d\n",block);
    exit(1);
  }
  printf("$%s",ptr);
}
void print_qualifiers(struct llist *items)
{
  while (items!=NULL) {
    char *this=(char *)items->ptr;
    printf(":");
    print_svalue(this);
    items=items->next;
  }
}
void print_lowl(struct llist *items)
{
  while (items!=NULL) {
    struct lowl *this=(struct lowl *)items->ptr;
    switch (this->statement) {
    case T_LITERAL:
      print_literal_list((struct llist *) this->item);
      break;
    case T_REF:
      print_external((struct external *) this->item);
      break;
    case T_COMMENT:
      print_comment((char *) this->item);
      break;
    case T_COMMENT_TRAILING:
      print_comment_trailing((char *) this->item);
      break;
    default:
      print_lowl_st(this->statement,this->item);
    }
    items=items->next;
  }
}
void print_lowl_st(int statement, void *ptr)
{
  char *value, *units;
  int link, name, i, ierr;

  ierr=0;
  for (i=0;ierr==0;i++) {
    ierr=vex_field(statement,ptr,i,&link,&name,&value,&units);
    if(ierr!=0)
      continue;
    if(i==0) {
      if(statement!=T_VEX_REV)
	printf("\n   ");
    } else if(i==1)
      printf(" =");
    else
      printf(" :");
    if(value!=NULL && *value!='\0') {
      if(statement!=T_VEX_REV || i !=0)
	printf(" ");
      if(link)
	printf("&");
      if(name)
	print_svalue(value);
      else
	printf("%s",value);
      if(units!=NULL && *units!='\0') {
	printf(" ");
	printf("%s",units);
      }
    }
  }
  if(ierr==-1) {
    fprintf(stderr,"Unknown lowl %d",statement);
    exit(1);
  } else if(ierr!=0 && ierr != -2) {
      fprintf(stderr,"Unknown error in print_lowl_st %d\n",ierr);
      exit(1);
  }
  printf(";");
}
void print_external(struct external *this)
{
  printf("\n    ref ");
  print_svalue(this->file);

  printf(":");
  print_block_name(this->primitive);

  printf(" = ");
  print_svalue(this->name);
  printf(";");

}
void print_svalue(char *svalue)
{
  char *ptr;
  static char quotec[]={" \t\n;:=&*$\""};
  int quote=0;
  int outch;

  if(svalue==NULL || *svalue == '\0')
    return;

  for(ptr=svalue;*ptr!=0;ptr++) {
    if((!isgraph(*ptr)) || NULL!=strchr(quotec,*ptr)) {
      quote=1;
      break;
    }
  }
  
  if(!quote) {       
    printf("%s",svalue);
    return;
  }

  printf("\"");
  for(ptr=svalue;*ptr!=0;ptr++) {
    if(isprint(*ptr) && '"'!=*ptr) {
      printf("%c",*ptr);
    } else {
      printf("\\");
      switch (*ptr) {
      case '\b':
	outch='b';
	break;
      case '\t':
	outch='t';
	break;
      case '\n':
	outch='n';
	break;
      case '\v':
	outch='v';
	break;
      case '\f':
	outch='f';
	break;
      case '\r':
	outch='r';
	break;
      case '"':
	outch='"';
	break;
      outch:
      default:
	printf("x%02x",*ptr);
	outch='\0';
      }
      if(outch!='\0') {
	printf("%c",outch);
      }
    }
  }
  printf("\"");
  
}

void print_literal_list(struct llist *literals)
{
  char *text=(char *) literals->ptr;

  printf("\nstart_literal(");
  printf("%s",text);
  printf(");");

  literals=literals->next;
  while (literals!=NULL) {
    printf("\n%s",(char *) literals->ptr);
    literals=literals->next;
  }
  printf("\nend_literal(");
  printf("%s",text);
  printf(");");

}
void print_comment(char *comment)
{
  printf("\n%s",comment);
}
void print_comment_trailing(char *comment_trailing)
{
  printf(" %s",comment_trailing);
}

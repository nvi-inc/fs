#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#ifdef DOS
# include <conio.h>
#endif DOS
#include <ctype.h>
#include <assert.h>

#include "main.h"
#include "lib.h"

#include "softkey.h"

/*
 * Syntax description, parsing, and softkey routines.
 * Warning: Programs which call these routines should have a nice large stack,
 *          because of fairly deep recursive calls.
 *
 * Special parameter codes:
 *
 * NUM    -- a non-negative integer of arbitrary length
 * NUMS   -- a signed integer of arbitrary length
 * NUMF   -- a floating point number of arbitrary length
 * NNN    -- a non-negative integer of exactly 3 digits
 * STR    -- a character string of arbitrary length. May not contain delimiters
 *             such as comma or space.
 * STRA   -- a character string of arbitrary length. This kind of string always
 *             extends to the end of the line, so it may contain any characters.
 * STRU   -- a character string of arbitrary length containing no lower-case
 *             characters, only upper case and non-alpha. Like STR it may not
 *             contain delimiters such as comma or space.
 * STR16  -- a character string of length at most 16. May not contain delimiters
 *             such as comma or space.
 * STRA99 -- a character string of length at most 99. May contain any 
 *             characters.
 * SSSS   -- a character string of length exactly 4.
 */


stree_ent* stree_getent(void)
{
   stree_ent* result;

   result=malloc(sizeof(stree_ent));
   if (result==NULL)
      malloc_out_of_space("stree_getent()",1);
   result->next=NULL;
   result->child=NULL;
   return(result);
}

stree_ent* stree_build(const cmd_t commands[], int num_cmds) 
{
   int i;
   int pos;
   stree_ent* entry;
   stree_ent* h_entry;
   stree_ent* l_entry;

   h_entry=NULL;
   l_entry=NULL;
   for (i=0; i<num_cmds; i++)  {
      pos=0;
      entry=stree_build2(commands[i].syntax,&pos);
      if (h_entry==NULL)
         h_entry=entry;
      if (l_entry!=NULL)
         l_entry->next=entry;
      l_entry=entry;
   }
   return(h_entry);
}

stree_ent* stree_build2(const char* format, int* pos) 
/*
 * 'pos' ... pass address of 'pos'!
 */
{
   int i;
   int l;
   char c;
   stree_ent* entry;          /* current entry */
   stree_ent* h_entry;        /* head (initial) entry */
   stree_ent* l_entry;        /* last (previous) entry */
   stree_ent* t_entry;        /* temporary holder */
   char digstr[20];

   h_entry=NULL;
   l_entry=NULL;

   while (TRUE)  {            /* loop until 'return' */
      entry=NULL;
      c=format[*pos];
      if (skeyword_char(c))  {
         entry=stree_getent();
         i=0;
         entry->value[i++]=c;
         c=format[++(*pos)];
         while (skeyword_char(c))  {
            entry->value[i++]=c;
            c=format[++(*pos)];
         }
         entry->value[i]=(char)NULL;
         entry->type=ST_KEY;
         entry->maxsize=i;
         entry->desc[0]=(char)NULL;
      }
      else if (c=='N')  {
         entry=stree_getent();
         i=0;
         while (isupper(c))  {
            entry->value[i++]=c;
            c=format[++(*pos)];
         }
         entry->value[i]=(char)NULL;
         entry->type=ST_NUM;

         if (i>=3 && entry->value[1]=='U')
            entry->maxsize=MAXSTRLEN;
         else
            entry->maxsize=i;

         entry->desc[0]=(char)NULL;
      }
      else if (c=='S')  {
         entry=stree_getent();
         i=0;
         while (isupper(c))  {
            entry->value[i++]=c;
            c=format[++(*pos)];
         }
         entry->value[i]=(char)NULL;
         entry->type=ST_STR;

         l=0;
         while (isdigit(c))  {
            digstr[l++]=c;
            c=format[++(*pos)];
         }
         digstr[l]=(char)NULL;

         if (l>0)
            entry->maxsize=(int)str_to_int(digstr);
         else if (i>=3 && entry->value[1]=='T')
            entry->maxsize=MAXSTRLEN;
         else
            entry->maxsize=i;

         entry->desc[0]=(char)NULL;
      }
      else if (c=='[')  {
         (*pos)++;
         entry=stree_build2(format,pos);
         t_entry=entry;               /* prepend 'NULL' entry */
         entry=stree_getent();
         entry->type=ST_NULL;
         entry->next=t_entry;
      }
      else if (c=='|')  {
         /* chain onto current head */
         assert(h_entry!=NULL);
         /* find last alternative */
         t_entry=h_entry;     
         while (t_entry->next!=NULL)
            t_entry=t_entry->next;
         (*pos)++;
         t_entry->next=stree_build2(format,pos);
         (*pos)--;                      /* re-get last delimiter */
      }
      else if (c=='{')  {
         (*pos)++;
         entry=stree_build2(format,pos);
      }
      else if (c=='}' || c==']' || c==(char)NULL)  {
         (*pos)++;
         assert(h_entry!=NULL);
         return(h_entry);
      }
      else if (c=='<')  {
         assert(l_entry!=NULL);
         i=0;
         while (c!='>')  {
            l_entry->desc[i++]=c;
            c=format[++(*pos)];
         }
         l_entry->desc[i++]=c;
         l_entry->desc[i]=(char)NULL;
         (*pos)++;
      }
      else if (c==' ')  {
         (*pos)++;
      }
      else  {
         /* illegal character in syntax specification (***) handle better */
         fprintf(stderr,"Illegal character at pos %d in syntax description:\n%s\n",*pos,format);
         assert(FALSE);
      }

      if (entry!=NULL)  {
         if (h_entry==NULL)
            h_entry=entry;
         /* add new level below current level */
         if (l_entry!=NULL)  {
            stree_leaves_set(l_entry,entry);
         }
         l_entry=entry;
      }
   }
}

ibool skeyword_char(char c)
/*
 * Checks if character 'c' is a valid keyword character. 
 * Keywords may contain only those characters accepted by this routine.
 * We allow:
 *   lower-case characters (a-z) & underscores
 *   digits (0-9)
 *   small roman numerals (I & V, for RadioAstron mode strings)
 *   special characters listed in SPECIAL_CHARS  (signs & colons for times)
 * Note that some of the characters accepted above have not been put in
 * SPECIAL_CHARS because characters in SPECIAL_CHARS are treated differently
 * wrt spacing by readln_cmd().
 */
{
   return(islower(c) || isdigit(c) || c=='_' || c=='I' || c=='V' 
            || one_of(c,SPECIAL_CHARS));
}

void stree_leaves_set(stree_ent* head, stree_ent* target)
/*
 * Sets the child pointers of all leaves of the syntax tree below 'head' to
 * point at 'target'. Important note: since we don't have a true tree, but
 * rather a more general form of graph, it is possible to reach the same 
 * leaf by two different paths from 'head'. Hence we would try to attach
 * 'target' twice, and actually perform a recursive attachment of 'target'
 * to its own leaves. This is nasty, and causes many hours of senseless bug
 * hunting(!), so we check below whether we are traversing into 'target',
 * and stop if so.
 */
{
   stree_ent* tpos;

   tpos=head;
   while (tpos!=NULL)  {
      if (tpos->child!=NULL)  {
         if (tpos->child!=target)                  /* don't traverse target! */
            stree_leaves_set(tpos->child,target);
      }
      else  {
         tpos->child=target;
      }

      tpos=tpos->next;  
   }
}

void stree_print(const stree_ent* head, char* pos)
{
   char newpos[MAXSTRLEN];

   while (head!=NULL)  {
      strcpy(newpos,pos);
      if (head->type!=ST_NULL)  {
         strcat(newpos," ");
         strcat(newpos,head->value);
      }
      if (head->child==NULL)  {
         printf("%s\n",newpos);
      }
      else  {
         stree_print(head->child,newpos);
      }
      head=head->next;
   }
}

int stree_parse(const char* cmd, int l, const stree_ent* head, 
                soft_key soft_labels, int* nlab, ibool* good_parse)
/* 
 * 'cmd' is the command to parse.
 * 'l' is the current (effective) length of 'cmd', not necessarily strlen(cmd).
 *     The value -1 is equivalent to the actual string length.
 * 'head' is a pointer to the head of the syntax tree to use for parsing.
 * 'soft_labels' returns the soft-key labels representing the current 
 *               alternatives.
 * Return value is error code.
 */
{
   int err;

   if (l<0)
      l=strlen(cmd);

   *nlab=0;

   /* handle comments as a special case */
   if (cmd[0]==COMMENT_DELIM)  {
      *good_parse=TRUE;
      return(ERR_NONE);
   }

   *good_parse=FALSE;
   err=stree_parse2(cmd,0,l,head,soft_labels,nlab,good_parse);
   if (err!=ERR_NONE)
      return(err);

   return(ERR_NONE);
}

int stree_parse2(const char* cmd, int pos, int l, const stree_ent* tpos, 
                soft_key soft_labels, int* nlab, ibool* good_parse)
/* 
 * Syntax-directed parse. Auxiliary routine for stree_parse(), needed for
 * proper recursion.
 * 'cmd' is the command to parse.
 * 'pos' is the parse position in 'cmd'.
 * 'l' is the current (effective) length of 'cmd', not necessarily strlen(cmd).
 * 'tpos' is the current position in the syntax tree.
 * 'soft_labels' is an array of strings which returns the soft-key labels 
 *               representing the current alternatives.
 * 'nlab' returns the number of labels in 'soft_labels'.
 * 'good_parse' returns TRUE iff at least one "successful" parse was obtained.
 * Return value is error code (currently no errors defined).
 */
{
   int err;
   int i;
   char c,lc;
   const stree_ent* entry;
   char parm[MAXSTRLEN];
   ibool float_allowed;
   ibool sign_allowed;
   ibool all_allowed;
   ibool no_lowcase;
   ibool is_hex;            /* TRUE if currently parsing a hex number */
   int delim_count;
   
   /* Skip delimiters. Like nextparm() we allow the first delimiter in
        PARM_DELIM to appear many times, but the others only once */
   delim_count=0;
   while (pos<l && one_of(cmd[pos],PARM_DELIM))  {
      if (cmd[pos]!=PARM_DELIM[0])  {
         if (++delim_count>1)
            break;
      }
      pos++;
   }

   if (tpos==NULL)  {
      if (pos==l)  {
         /* show that we have successfully parsed (at least once) */
         *good_parse=TRUE;
      }
      return(ERR_NONE);
   }

   if (pos<l)  {
      /* Check keyword/special parm ST_KEY (loop through alternatives) */
      entry=tpos;
      while (entry!=NULL)  {
         /* Check if entry is keyword and it's not too long. 'maxsize'
            here gives actual length of keyword. */
         if (entry->type==ST_KEY)  {
            if (entry->maxsize<=l-pos)  {
               if (strncmp(cmd+pos,entry->value,entry->maxsize)==0)  {
                  /* Keyword matches command string. */
                  if (pos+entry->maxsize>=l)    /* (won't ever be greater) */
                     c=(char)NULL; /* don't rely on 'cmd' to have NULL at EOS */
                  else
                     c=cmd[pos+entry->maxsize];
                  /* Check after match portion for alphanum (must be none) */
                  if (!isalnum(entry->value[0]) || !isalnum(c))  {
                     /* success */
                     err=stree_parse2(cmd,pos+entry->maxsize,l,entry->child, 
                                     soft_labels,nlab,good_parse);
                     if (err!=ERR_NONE)
                        return(err);
                  }
               }
            }
            else if (strncmp(cmd+pos,entry->value,l-pos)==0)  {
               /* Partial entry at end of line matches initial substring of 
                    keyword */
               add_one_label(entry,soft_labels,nlab);
            }
         }
         entry=entry->next;
      }

      /* Check numeric parm ST_NUM. We allow signed integers or floating point
           where indicated. We always allow regular integers and hexadecimal
           (indicated by "$" or "0x"). */
      entry=tpos;
      if (isdigit(cmd[pos]) || one_of(cmd[pos],".+-$"))  {
         while (entry!=NULL)  {
            if (entry->type==ST_NUM)  {
               i=0;
               c=cmd[pos];
               lc=(char)NULL;
               float_allowed=streq(entry->value,"NUMF");
               sign_allowed=streq(entry->value,"NUMS");
               is_hex=(cmd[pos]=='$' || (cmd[pos+1]=='x' && cmd[pos]=='0'));
               while (i<entry->maxsize && pos+i<l && 
                        (isdigit(c)
                           || (float_allowed && !is_hex && one_of(c,".Ee+-"))
                           || (sign_allowed && one_of(c,"+-"))
                           || (cmd[pos]=='$' && (i==0 || isxdigit(c)))
                           || (cmd[pos+1]=='x' && cmd[pos]=='0'
                                && (i<=1 || isxdigit(c)))))  {
                  /* ensure +/- is at start or follows e/E */
                  if (one_of(c,"+-") && !(one_of(lc,"eE") || lc==(char)NULL))
                     break;
                  parm[i++]=c;
                  lc=c;
                  if (pos+i>=l)  /* (won't ever be greater) */
                     c=(char)NULL; /* don't rely on 'cmd' to have NULL at EOS */
                  else
                     c=cmd[pos+i];
               }
               parm[i]=(char)NULL;    /* terminate string */
               /* Must be exact length or NUM[FS] (we check only the 'U').
                    Also, can't stop right after sign,E,$ etc. (E only for fp)*/
               if (i>0 && (entry->maxsize==i
                            || (entry->value[1]=='U' 
                                  && !one_of(lc,(is_hex ? "+-$x" : "+-Ee"))))) {
                  /* Check after match portion for alphanum (must be none) */
                  if (!isalnum(c))  {
                     /* success */
                     err=stree_parse2(cmd,pos+i,l,entry->child,soft_labels,nlab,
                                      good_parse);
                     if (err!=ERR_NONE)
                        return(err);
                  }
               }
               else if (pos+i==l && entry->maxsize>i)  {
/* Was:  else if (pos+i==l && entry->maxsize<MAXSTRLEN && entry->maxsize>i) */
                  /* Partial entry (at end of line) */
                  add_one_label(entry,soft_labels,nlab);
               }
            }
            entry=entry->next;
         }
      }

      /* Check string parm ST_STR */
      entry=tpos;
      while (entry!=NULL)  {
         if (entry->type==ST_STR)  {
            i=0;
            all_allowed=streq(entry->value,"STRA");
            no_lowcase=streq(entry->value,"STRU");
            c=cmd[pos];
            while (i<entry->maxsize && pos+i<l
                              && (!one_of(c,PARM_DELIM) || all_allowed)
                              && (!no_lowcase || !islower(c)))  {
               parm[i++]=c;
               if (pos+i>=l)  /* (won't ever be greater) */
                  c=(char)NULL;   /* don't rely on 'cmd' to have NULL at EOS */
               else
                  c=cmd[pos+i];
            }
            parm[i]=(char)NULL;    /* terminate string */
            /* Must be exact length or STR (we check only the 'T') */
            if (i>0 && (entry->maxsize==i || entry->value[1]=='T'))  {
               /* success */
               err=stree_parse2(cmd,pos+i,l,entry->child,soft_labels,nlab,
                                good_parse);
               if (err!=ERR_NONE)
                  return(err);
            }
            else if (pos+i==l && entry->maxsize>i)  {
/* was:  else if (pos+i==l && entry->maxsize<MAXSTRLEN && entry->maxsize>i) */
               /* Partial match (at end of line) */
               add_one_label(entry,soft_labels,nlab);
            }
         }
         entry=entry->next;
      }
   }
   else  {
      /* pos is greater than or equal to effective length 'l', so finish up */
      add_labels(tpos,soft_labels,nlab);
   }

   /* Make recursive calls for ST_NULL entries  */
   entry=tpos;
   while (entry!=NULL)  {
      if (entry->type==ST_NULL)  {
         /* success */
         err=stree_parse2(cmd,pos,l,entry->child,soft_labels,nlab,good_parse);
         if (err!=ERR_NONE)
            return(err);
      }
      entry=entry->next;
   }

   return(ERR_NONE);
}

void add_labels(const stree_ent* entry, soft_key soft_labels, int* nlab)
/*
 * Fill in soft-key labels
 */
{
   const stree_ent* tpos;

   tpos=entry;
   while (tpos!=NULL)  {
      if (tpos->type!=ST_NULL)  {
         add_one_label(tpos,soft_labels,nlab);
      }
      tpos=tpos->next;
   }
}

void add_one_label(const stree_ent* entry, soft_key soft_labels, int* nlab)
/*
 * Add one soft-key label.
 */
{
   /* ensure the number of labels does not exceed maximum limit */
   assert(*nlab<MAXSOFTLABELS);

   strcpy(soft_labels[*nlab],entry->value);

   if (strneq(entry->value,"STR",3) || strneq(entry->value,"NUM",3))
      soft_labels[*nlab][3]=(char)NULL;           /* truncate to 3 chars */

   if (entry->desc[0]!=(char)NULL)
      strcat(soft_labels[*nlab],entry->desc);
   (*nlab)++;
}

int verify_syntax(const char* cmd, const stree_ent* stree_head)
/*
 * Simplified call interface for stree_parse() when a simple "boolean"
 * response is needed, i.e. command syntax OK, yes or no?
 * 'cmd' is the command to check.
 * 'expert' TRUE means allow all commands/options, FALSE means don't allow
 *          commands/options tagged as "expert" with '!' in syntax.
 * 'stree_head' is a pointer to the head of the syntax tree to use.
 * Return value is error code:
 *   ERR_NONE     -- syntax OK
 *   ERR_OPFAIL   -- no valid parse
 */
{
   int err;
   soft_key soft_labels;   /* soft-key labels from stree_parse(), not used */
   int nlab;               /* number of soft-key labels above, not used */
   ibool good_parse;        /* flag from stree_parse(), syntax OK */

   err=stree_parse(cmd,strlen(cmd),stree_head,soft_labels,&nlab,&good_parse);
   if (err!=ERR_NONE)
      return(err);

   if (!good_parse)
      return(ERR_OPFAIL);

   return(ERR_NONE);
}

void display_softkeys(soft_key soft_labels, int nlab, int first,
                      int left_trunc)
/*
 * 'first' is first label to print, normally 0 (no offset).
 * 'left_trunc' indicates how many characters should be omitted at the start of
 *              labels that don't fit in the display.
 */
{
   int k;
   int l;
   int last_key;
   int x,y;                       /* screen position save */
   char label[MAXSOFTKEYSIZE];
   int offs;

   x=wherex();        /* save cursor position to restore when we return */
   y=wherey();

   /* clear top two lines */
   gotoxy(1,1);
   printf("[       ] [       ] [       ] [       ] [       ] [       ] [       ] [       ]");
   clreol();
   gotoxy(1,2);
   clreol();

   last_key=nlab-first;
   if (nlab>SKEY_NUM)  {
      if (last_key>=SKEY_NUM)
         last_key=SKEY_NUM-1;
      gotoxy(last_key*SKEY_SPACING+SKEY_OFFSET,SKEY_Y);
      printf(SKEY_ETC);
   }

   for (k=0; k<last_key; k++)  {
      /* calculate left-truncation amount 'offs', if any */
      l=strlen(soft_labels[k+first]);
      if (l>SKEY_SIZE)  {
         offs=left_trunc;
         if (offs+SKEY_SIZE>l)
            offs=l-SKEY_SIZE;
      }
      else  {
         offs=0;
      }
      /* copy & truncate */
      strncpy(label,soft_labels[k+first]+offs,SKEY_SIZE);
      if (offs>0)
         label[0]='*';                     /* '*' indicates left-truncated */
      label[SKEY_SIZE]=(char)NULL;         /* ensure null terminated */
      l=strlen(label);
      while (l<SKEY_SIZE)
         label[l++]=' ';                   /* pad out to SKEY_SIZE chars */

      gotoxy(k*SKEY_SPACING+SKEY_OFFSET,SKEY_Y);
      printf("%s",label);
   }

   /* make empty label */
   label[SKEY_SIZE]=(char)NULL;
   l=0;
   while (l<SKEY_SIZE)
      label[l++]=' ';
   for (k=last_key; k<SKEY_NUM-(nlab>SKEY_NUM); k++)  {
      gotoxy(k*SKEY_SPACING+SKEY_OFFSET,SKEY_Y);
      printf("%s",label);
   }

   gotoxy(x,y);
}

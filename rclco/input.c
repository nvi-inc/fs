#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <assert.h>
#ifdef DOS
# include <conio.h>
# include <dos.h>
#endif
#ifdef UNIX
# include <curses.h>
# undef bool          /* defined by curses.h, nasty! */
#endif UNIX

#include "main.h"
#include "lib.h"
#include "rcl_sys.h"

#include "input.h"


#define NUM_HIST     100
#define MAX_HIST_LEN 256


void bell(void)
{
   fprintf(stderr,"");    /* (Unix: bypass curses) */
   fflush(stdout);
}

void belln(int n)
{
   int i;

   if (n==1)  {
      bell();        /* don't need all the fuss below if only ringing once */
      return;
   }
         
   if (n>10)         /* let's be reasonable! */
      n=10; 

   for (i=0; i<n; i++)  {
      bell();
      rcl_delay(150);
   }
}

void wcurup(void)
{
   int x = wherex();
   int y = wherey();

   gotoxy(x,y-1);
}

void wcurdown(void) 
{
   int x = wherex();
   int y = wherey();

   if (y >= MAXY)  {
      printf("\n");     /* make screen scroll */
      y--;
   }
   gotoxy(x,y+1);
}

void wcurleft(void) 
{
   int x = wherex();
   int y = wherey();

   if (x<=1)  {
      x=MAXX;
      gotoxy(x,y);
      wcurup();
   }
   else  {
      gotoxy(x-1,y);
   }
}

void wcurright(void) 
{
   int x = wherex();
   int y = wherey();

   if (x==MAXX)  {
      x=1;
      gotoxy(x,y);
      wcurdown();
   }
   else  {
      gotoxy(x+1,y);
   }
}

static int common_prefix_len(soft_key soft_labels, int nlab)
/*
 * Returns length of common prefix of all 'nlab' labels in 'soft_labels'.
 * Result is 0 if no common prefix.
 * Returns -1 if not all softkey labels are keywords.
 */
{
   int i,j;        /* loop indices */

   if (nlab<1)     /* need at least one label! */
      return(-1);

   /* check each softkey to ensure it represents a keyword */
   for (j=0; j<nlab; j++)  {
      if (!skeyword_char(soft_labels[j][0]))
         return(-1);
   }

   for (i=0; i<MAXSOFTKEYSIZE; i++)  {       /* for each character */
      for (j=1; j<nlab; j++)  {         /* for each softkey */
         if (soft_labels[j][i]!=soft_labels[j-1][i])
            break;
      }
      if (j<nlab)        /* test if just did 'break' above */
         break;
      if (soft_labels[0][i]==(char)NULL)
         i=MAXSOFTKEYSIZE-1;    /* exit with value MAXSOFTKEYSIZE */
   }

   return(i);
}

void readln(char* line, int maxsize)
/*
 * Reads one line from the standard input, terminated by a newline.
 * Editing and cursor controls are allowed. 
 * The global variable 'ReadLnInsert' controls the setting of insert mode.
 * 'line' returns the line read.
 * 'maxsize' is the maximum number of characters to accept. 'line' should
 *           be declared at least one larger than this to allow for null 
 *           termination.
 */
{
   readln_cmd(NULL,line,maxsize);
}

void readln_cmd(const stree_ent* stree, char* line, int maxsize)
/*
 * Reads one line from the standard input, terminated by a newline.
 * Displays soft-keys on the top line of the screen.
 * Editing and cursor controls are allowed.
 * The global variable 'ReadLnInsert' controls the setting of insert mode.
 * 'stree' is the syntax tree to use for displaying soft-keys. Pass NULL if
 *         no soft-keys should be displayed. This also inhibits the use of
 *         command history.
 * 'line' initializes/returns the line read.
 * 'maxsize' is the maximum number of characters to accept. 'line' should
 *           be declared at least one larger than this to allow for null 
 *           termination.
 */
{
/* escape codes (indices into kn[])
   Note: SKEY_NUM is defined in softkey.h. */
#define C_KU  (SKEY_NUM+0)          /* cursor up */
#define C_KD  (SKEY_NUM+1)          /* cursor down */
#define C_KR  (SKEY_NUM+2)          /* cursor right */
#define C_KL  (SKEY_NUM+3)          /* cursor left */
#define C_DELC (SKEY_NUM+4)         /* delete character (cursor stays put) */
#define C_DELW (SKEY_NUM+5)         /* delete word */
#define C_DISR (SKEY_NUM+6)         /* move softkey display to the right */
#define NUM_ESC  (SKEY_NUM+7)       /* number of recognized escape sequences */

   static char history[NUM_HIST][MAX_HIST_LEN];   /* history fifo */
   static int hist_w=0;    /* history fifo write pointer */
   static int hist_r=0;    /* history fifo read pointer */
   int hist_c;             /* current history position */
   int hist_n;             /* new history position */
   int err;                /* error return */
   int j;                  /* loop index */
   int c;                  /* character from getch */
   int i;                  /* current cursor position */
   int l;                  /* current line length */
   int y,x;                /* screen cursor position holders */
   char kn[NUM_ESC];       /* scan codes for special keys */
   soft_key soft_labels;   /* soft-key labels from stree_parse() */
   int nlab;               /* number of soft-key labels above */
   ibool good_parse;       /* flag from stree_parse() */
   int first;              /* first soft-key to display, for --ETC-- key */
   int esc_code;           /* decoded escape sequence code (index into kn[]) */
   char* label;            /* softkey label being inserted into line */
   char labeltxt[MAXSOFTKEYSIZE];  /* text to insert into line */
   int llen;               /* length of above text */
   ibool is_special;       /* true if 'label' is a special char (":","-" etc) */
   char histmatch[MAXSTRLEN]; /* string prefix to match in history up/down */
   ibool noset_match;      /* flag to suppress setting of histmatch string */
   ibool word_done;        /* flag for delete-word */
   int left_trunc;         /* amount to cut off at left of softkeys, for DISR */
   int compref;            /* length of common prefix portion of keyword, for
                                tab expansion (MAXSOFTKEYSIZE==perfect match) */


   /* Set scan codes for DOS. In unix the function and cursor keys simply
        don't work! Use alternate control codes for cursor keys. */
   for (j=0; j<SKEY_NUM; j++)  {
      kn[j]=0x3b+j;               /* function keys 1 through 8 */
   }
   kn[C_KU]=0x48;     /* cursor up */
   kn[C_KD]=0x50;     /* cursor down */
   kn[C_KR]=0x4d;     /* cursor right */
   kn[C_KL]=0x4b;     /* cursor left */
   kn[C_DELC]=0x53;   /* delete character (cursor stays put) */
   kn[C_DELW]=0x43;   /* delete-word (F9) */
   kn[C_DISR]=0x44;   /* move ahead in softkey display (F10) */

   first=0;
   left_trunc=0;

   hist_c=hist_w;
   l = strlen(line);
   i = l;
   if (l!=0)  {
      printf("%s",line);
      for ( ; i>0; i--)  {
         wcurleft();
      }
   }

   histmatch[0]=(char)NULL;
   noset_match=TRUE;

   while(TRUE)  {           /* Main loop, go until break. */

      if (!noset_match)
         strcpy(histmatch,line);
      else
         noset_match=FALSE;

      if (stree!=NULL)  {
         err=stree_parse(line,i,stree,soft_labels,&nlab,&good_parse);
         if (err!=ERR_NONE)  {
            /* internal error */
            strcpy(soft_labels[0],"?!?!?!?");
            nlab=1;
         }
         else  {
            /* successful parse */
            if (good_parse)  {
               strcpy(soft_labels[nlab],SKEY_DONE);
               nlab++;
            }
            else if (nlab==0)  {
               /* no successful parse and no more alternatives, so parse err */
               strcpy(soft_labels[0],SKEY_ERR);
               nlab=1;
            }
         }
         display_softkeys(soft_labels,nlab,first,left_trunc);
      }

      /* get a character from the console without echoing */
#ifdef DOS
      c=getch();
#else
      c=getchar();
#endif 

      if (c==(char)NULL)  {   /* NULL indicates special char in DOS, scan code
                             follows */
         /* Decode cursor and function keys k1-k8 and ku, kd, kr, kl. */
         esc_code=-1;
#ifdef DOS
         c=getch();
#else
         c=getchar();
#endif 

         for (j=0; j<NUM_ESC; j++)  {
            /* check for match */
            if (kn[j]==c)  {
               esc_code=j;
               break;
            }
         }

         if (esc_code!=-1)  {
            /* Recognized a valid escape sequence. */

            /* check function keys 1-8 (esc_code values 0-7) */
            if (esc_code<SKEY_NUM)  {
               if (stree==NULL)  {
                  /* no syntax tree, so no action */
                  bell();
                  noset_match=TRUE;
                  continue;           /* restart main while(TRUE) loop */
               }

               /* Check for --ETC-- */
               if (esc_code==SKEY_NUM-1 && nlab>SKEY_NUM)  {
                  if (nlab-first>=SKEY_NUM)
                     first+=SKEY_NUM-1;
                  else
                     first=0;
                  noset_match=TRUE;
                  left_trunc=0;
                  continue;           /* restart main while(TRUE) loop */
               }  
               compref=MAXSOFTKEYSIZE;

complete_cmd:
               if (esc_code>=nlab-first)  {
                  /* softkey is empty, so no action */
                  bell();
                  noset_match=TRUE;
                  continue;           /* restart main while(TRUE) loop */
               }

               /* Check for -DONE- */
               label=soft_labels[esc_code+first];   /* easier working handle */
               if (streq(label,SKEY_DONE))  {
                  c='\n';
                  /* falls through to regular character processing */
               }  
               else if (skeyword_char(label[0]))  {
                  /* softkey label is valid keyword (not STR or NUM), so 
                       insert into line. */
                  j=i;
                  while (j>0)  {
                     /* find start of previously typed keyword */
                     /* was: if (!islower(line[j-1]) && !isdigit(line[j-1])) */
                     if (one_of(line[j-1],PARM_DELIM))
                        break;
                     j--;
                  }

                  is_special=(strlen(label)==1) && 
                             one_of(label[0],SPECIAL_CHARS);
                  
                  /* check if keyword already partially typed */
                  labeltxt[0]=(char)NULL;
                  if (j<i && skeyword_char(line[j]) /* must not be upper case */
                          && (i-j)<strlen(label)
                          && strneq(line+j,label,i-j))  {
                     strncat(labeltxt,label+(i-j),compref-(i-j));
                  }
                  else  {
                     if (i>0 && line[i-1]!=' ' && !is_special)
                        strcat(labeltxt," ");    /* add extra leading space */
                     strncat(labeltxt,label,compref);
                  }
                  if (!is_special && compref==MAXSOFTKEYSIZE)
                     strcat(labeltxt," ");       /* add extra trailing space */

                  llen=strlen(labeltxt);
                  if (l+llen>maxsize)  {
                     /* too long for available space in line */
                     bell();
                     continue;           /* restart main while(TRUE) loop */
                  }

                  /* expand line to create gap */
                  for (j=l; j>=i; j--)  {
                     line[j+llen]=line[j];
                  }
                  l+=llen;

                  /* fill in softkey label */
                  strncpy(line+i,labeltxt,llen);
                  i+=llen;

                  /* write to screen */
                  printf("%s",labeltxt);
                  if (i!=l)  {
                     y=wherey();
                     x=wherex();
                     printf("%s",line+i);    /* re-print part after cursor */
                     /* check for wrap-around, compensate if screen scrolled */
                     if (wherex()<x && y==MAXY)
                        y--;
                     gotoxy(x,y);
                  }
                  if (compref<MAXSOFTKEYSIZE)
                     bell();          /* didn't expand whole word, so ring */
                  first=0;            /* don't forget! */
                  continue;           /* restart main while(TRUE) loop */
               }
               else  {
                  /* softkey not a keyword, so no action */
                  bell();
                  noset_match=TRUE;
                  continue;           /* restart main while(TRUE) loop */
               }
            }
            else  {
               /* Turn cursor codes into single-char escape codes and fall
                    through. */
               switch (esc_code)  {
   
               case C_KU:
                  c='';
                  break;

               case C_KD:
                  c=''; 
                  break;

               case C_KR:
                  c='';
                  break;

               case C_KL:
                  c=''; 
                  break;

               case C_DELC:
                  c=''; 
                  break;

               case C_DELW:
                  c=''; 
                  break;

               case C_DISR:
                  c=''; 
                  break;

               default:
                  assert(FALSE);   /* should not get here */
               }
               /* falls through to regular character processing */
            }
         }
         else  {
            /* unrecognized escape code */
            bell();
            noset_match=TRUE;
            continue;           /* restart main while(TRUE) loop */
         }
      }

      if (c==EOF)  {
         printf("Unexpected end-of-file or error in readln_cmd()!\n");
         clearerr(stdin);   /* clear error condition, or else latched! */
         break;             /* exit main while(TRUE) loop */
      }
      else if (c=='\n' || c=='\r')  {
         /* always allow null lines even though they may not parse */
         if (stree!=NULL && l>0)  {
            if (i<l)  {
               /* re-parse with cursor at end of line */
               stree_parse(line,l,stree,soft_labels,&nlab,&good_parse);
            }
            if (!good_parse)  {
               /* don't allow return if not 'done' */
               bell();
               noset_match=TRUE;
               continue;           /* restart main while(TRUE) loop */
            }
         }

         for (j=i; j<l; j++)
            wcurright();

         printf("\n");

         if (line[0]!=(char)NULL && stree!=NULL)  {
            /* add line to history */
            strncpy(history[hist_w],line,MAX_HIST_LEN);
            hist_w=(hist_w+1) % NUM_HIST;
            if (hist_w==hist_r)
               hist_r=(hist_r+1) % NUM_HIST;
         }

         break;       /* exit main while(TRUE) loop */
      }
      else if (c=='	')  {      /* tab (command completion) */
         if (stree!=NULL)  {
            compref=common_prefix_len(soft_labels,nlab-good_parse);
            if (compref>0)  {
               /* emulate pressing of function key 1 (code 0), with label
                    effectively shortened if compref<MAXSOFTKEYSIZE */
               esc_code=0;
               first=0;
               goto complete_cmd;
            }
         }

         bell();
         noset_match=TRUE;
         continue;           /* restart main while(TRUE) loop */
      }
      else if (c=='' || c=='')  {   /* backspace or del */
         if (i>0)  {
            i--;
            for (j=i; j<l; j++)  {   /* copy-left, including trailing NULL */
               line[j]=line[j+1];
            }
            wcurleft();      /* back cursor */
            printf("%s ",line+i);
            j=i;
            for (i=l; i>j; i--)  {
               wcurleft();
            }
            l--;
         }
         else  {
            bell();
            noset_match=TRUE;
            continue;           /* restart main while(TRUE) loop */
         }
      }
      else if (c=='')  {      /* delete character (cursor stays put) */
         if (i<l)  {
            for (j=i; j<l; j++)  {   /* copy-left, including trailing NULL */
               line[j]=line[j+1];
            }
            printf("%s ",line+i);
            j=i;
            for (i=l; i>j; i--)  {
               wcurleft();
            }
            l--;
         }
         else  {
            bell();
            noset_match=TRUE;
            continue;           /* restart main while(TRUE) loop */
         }
      }
      else if (c=='')  {      /* delete word */
         if (i>0)  {
            word_done=FALSE;
            while (i>0 && (!word_done || line[i-1]!=' '))  {
               i--;
               if (line[i]!=' ')
                  word_done=TRUE;
               for (j=i; j<l; j++)  {   /* copy-left, including trailing NULL */
                  line[j]=line[j+1];
               }
               wcurleft();      /* back cursor */
               printf("%s ",line+i);
               j=i;
               for (i=l; i>j; i--)  {
                  wcurleft();
               }
               l--;
            }
         }
         else  {
            bell();
            noset_match=TRUE;
            continue;           /* restart main while(TRUE) loop */
         }
      }
      else if (c=='')  {       /* left-cursor */
         noset_match=TRUE;
         if (i>0)  {
            wcurleft();
            i--;
         }
         else  {
            bell();
            continue;           /* restart main while(TRUE) loop */
         }
      }
      else if (c=='')  {      /* right-cursor */
         noset_match=TRUE;
         if (i<l)  {
            wcurright();
            i++;
         }
         else  {
            bell();
            continue;           /* restart main while(TRUE) loop */
         }
      }
      else if (c=='')  {       /* up-cursor */
         noset_match=TRUE;
         if (i<l && i>=MAXX)  {
            wcurup();
            i-=MAXX;
         }
         else  {
            if (stree!=NULL)  {
               if (hist_c==hist_w)
                  strncpy(history[hist_w],line,MAX_HIST_LEN);

               hist_n=hist_c;
repeatup:
               if (hist_n==hist_r)  {   /* at top of history list? */
                  bell();
                  continue;           /* restart main while(TRUE) loop */
               }
               hist_n=(hist_n+NUM_HIST-1) % NUM_HIST;  /* subtract 1 */
               if (strlen(history[hist_n])>maxsize)  {
                  bell();
                  continue;           /* restart main while(TRUE) loop */
               }
               if (strnne(history[hist_n],histmatch,strlen(histmatch)))
                  goto repeatup;

               hist_c=hist_n;
dispnewline:
               strcpy(line,history[hist_c]);
               for ( ; i>0; i--)  {
                  wcurleft();
               }
               for (j=i; j<l; j++)  
                  printf(" ");
               for (j=i; j<l; j++)  
                  wcurleft();
               l = strlen(line);
               i = l;
               printf("%s",line);
            }
            else  {
               bell();
               continue;           /* restart main while(TRUE) loop */
            }
         }
      }
      else if (c=='')  {       /* down-cursor */
         noset_match=TRUE;
         if (i+MAXX<=l)  {
            wcurdown();
            i+=MAXX;
         }
         else  {
            if (stree!=NULL)  {
               hist_n=hist_c;
repeatdown:
               if (hist_n==hist_w)  {   /* at bottom of history list? */
                  bell();
                  continue;           /* restart main while(TRUE) loop */
               }
               hist_n=(hist_n+1) % NUM_HIST;  /* add 1 */
               if (strlen(history[hist_n])>maxsize)  {
                  bell();
                  continue;           /* restart main while(TRUE) loop */
               }
               if (strnne(history[hist_n],histmatch,strlen(histmatch)))
                  goto repeatdown;

               hist_c=hist_n;
               goto dispnewline;
            }
            else  {
               bell();
               continue;           /* restart main while(TRUE) loop */
            }
         }
      }
      else if (c=='')  {       /* move to end of line */
         noset_match=TRUE;
         for ( ; i<l; i++)  {
            wcurright();
         }
      }
      else if (c=='')  {       /* move to start of line */
         noset_match=TRUE;
         for ( ; i>0; i--)  {
            wcurleft();
         }
      }
      else if (c=='' || c=='')  {     /* delete to start of/whole line */
         if (c=='')  {
            /* move to end of line, like cntl-E: */
            for ( ; i<l; i++)  {
               wcurright();
            }
         }
         if (i>0)  {
            for (j=i; j>0; j--)  {
               wcurleft();
            }

            for (j=0; j<=l-i; j++)  {    /* copy left by i, including NULL */
               line[j]=line[j+i];
            }
            l-=i;
            x=wherex();
            y=wherey();
            printf("%s",line);
            for (j=0; j<i; j++)
               printf(" ");
            gotoxy(x,y);
            i=0;
         }
         else  {
            bell();
            continue;           /* restart main while(TRUE) loop */
         }
      }
      else if (c=='')  {      /* toggle insert mode */
         noset_match=TRUE;
         if (ReadLnInsert)
            ReadLnInsert=FALSE;
         else
            ReadLnInsert=TRUE;
      }
#ifdef UNIX
      else if (c=='')  {      /* refresh the entire screen in case garbled */
         noset_match=TRUE;
         wrefresh(curscr);
      }
#endif UNIX
      else if (c=='')  {      /* move ahead in softkey display */
         for (j=first; j<nlab && j<first+SKEY_NUM-(nlab>SKEY_NUM)/*ETC*/; j++) {
            if (strlen(soft_labels[j])>SKEY_SIZE+left_trunc)  {
               left_trunc+=1;
               goto disrbrk;
            }
         }
         bell();           
disrbrk:
         noset_match=TRUE;
         continue;           /* restart main while(TRUE) loop */
      }
      else if (c<' ')  {     /* ignore control characters */
         bell();
         noset_match=TRUE;
         continue;           /* restart main while(TRUE) loop */
      }
      else  {
         /* make space bar complete command if applicable */
         if (c==' ' && stree!=NULL && !good_parse)  {
            compref=common_prefix_len(soft_labels,nlab);
            if (compref>0)  {
               /* emulate pressing of function key 1 (code 0), with label
                    effectively shortened if compref<MAXSOFTKEYSIZE */
               esc_code=0;
               goto complete_cmd;
            }
            /* fall through if compref<=0 (space treated like normal char) */
         }
         if (ReadLnInsert || i==l)  {
            if (l>=maxsize)  {
               bell();
               continue;           /* restart main while(TRUE) loop */
            }
            l++;
            line[l]=(char)NULL;          /* maintain null-termination */
         }
         if (ReadLnInsert)  {
            for (j=l-1; j>=i; j--)  {
               line[j+1]=line[j];
            }
         }
         line[i] = c;
         i++;
         printf("%c",c);
         if (ReadLnInsert && i!=l)  {
            x=wherex();
            y=wherey();
            printf("%s",line+i);
            /* check for wrap-around, compensate if screen scrolled */
            if (wherex()<x && y==MAXY)
               y--;
            gotoxy(x,y);
         }
      }

      /* force softkey display to reset to start. Remember to do this when
           using 'continue' (if needed) */
      first=0;
      left_trunc=0;

   }    /* end of main while(TRUE) loop */

   if (l>0)
      display_softkeys(soft_labels,0,0,0);  /* erase softkeys */

   ReadLnInsert=TRUE;        /* always return to default mode (insert) */
}

int nextparm(const char* cmd, char* result, int* pos, const char* delim)
/*
 * Extracts the next parameter from 'cmd'. This is done by copying characters
 * from 'cmd' into 'result', starting at 'pos'. Copying stops when any
 * delimiter character in 'delim' is encountered. 'pos' is left one past
 * the delimiter. As a special case, the first delimiter in the list 'delim'
 * is skipped no matter how often it occurs before and after the result
 * string. It still acts as a delimiter, however. This is usually used
 * to allow the space character to be interspersed with other delimiters,
 * i.e. if 'delim' is " ;" (space first!), then 
 *        mklnk link ; linkto
 * is parsed properly. If space were treated like any other delimiter then
 * the above would be equivalent to 
 *        mklnk link;;;linkto
 * which has two null parameters between "link" and "linkto".
 * 'cmd' is the string being parsed.
 * 'result' returns the parameter extracted.
 * 'pos' is the current parse position and returns the new parse position.
 *       It returns LAST_PARM *with* the last valid parm and whenever EOF is
 *       returned.
 * Function return value is EOF when no more parameters available (*after* last
 * valid parm), ~EOF otherwise.
 * Note: 'result' is null string ("") iff EOF is returned.
 */
{
   int respos;
   char firstdelim;           /* first delimiter in list, treated specially */

   if (*pos<0 || *pos>=strlen(cmd))  {
      *pos=LAST_PARM;
      result[0]=(char)NULL;
      return(EOF);
   }
   firstdelim=delim[0];
   respos=0;
   while (cmd[*pos]!=(char)NULL && cmd[*pos]==firstdelim)
      (*pos)++;
   while (cmd[*pos]!=(char)NULL && !one_of(cmd[*pos],delim))
      result[respos++]=cmd[(*pos)++];

   result[respos]=(char)NULL;
   while (cmd[*pos]!=(char)NULL && cmd[*pos]==firstdelim)
      (*pos)++;
   if (one_of(cmd[*pos],delim))
      (*pos)++;              /* skip delimiter */
   if (cmd[*pos]==(char)NULL)  {
      *pos=LAST_PARM;
      if (respos==0)
         return(EOF);
   }
   return(~EOF);            /* "not" EOF */
}

char delimiter(const char* cmd, int pos, const char* delim)
/*
 * Returns the first delimiter in 'cmd' before position 'pos' that is in
 * the list of delimiters 'delim'. This is useful immediately following
 * nextparm() to determine which delimiter was encountered.
 * Returns NULL if no valid delimiter precedes 'pos'.
 */
{
   char result;

   result=(char)NULL;

   if (pos==LAST_PARM)
      pos=strlen(cmd);

   while (pos>0)  {
      pos--;
      if (one_of(cmd[pos],delim))  {
         result=cmd[pos];
         if (result!=delim[0])   /* treat first delim specially (continue) */
            break;
      }
      else
         break;
   }

   return(result);
}

int scan_cmd(char* cmdwd, const cmd_t commands[], const int num_cmds)
/*
 * Scans through list of commands 'commands' to find command word 'cmdwd'.
 * Abbreviations to the shortest unique prefix are allowed. If an abbreviation
 * is used, cmdwd gets expanded and returns the full command word.
 * The abbreviation capability of this routine is not actually needed in ROS
 * because of its soft-key parsing routines, but is being kept in for future
 * reference.
 * Return value is command number ('num' field) or error code:
 *    ERR_OPFAIL: Unknown command or non-unique command abbreviation.
 */
{
   register int i;
   int len;
   int match;
   int index;

   len=strlen(cmdwd);
   if (len<1) 
      return(ERR_OPFAIL);            /* command word is null! */

   match=0;
   for (i=0; i<num_cmds; i++)  {
      if (strncmp(cmdwd,commands[i].name,len)==0)  {
         /* check for perfect match */
         if (commands[i].name[len]==' ' || commands[i].name[len]==(char)NULL)  {
            return(commands[i].num);
         }
         if (len>=2)  {           /* abbreviation must be 2 chars or more */
            index=i;
            match++;
         }
      }
   }
   if (match<1) 
      return(ERR_OPFAIL);   /* no match */
   else if (match>1) 
      return(ERR_OPFAIL);   /* non-unique abbreviation */

   while (commands[index].name[len]!=' ')  {      /* expand abbr. cmd word */
      cmdwd[len]=commands[index].name[len];
      len++;
   }
   cmdwd[len]=(char)NULL;
   return(commands[index].num);
}

ibool are_you_sure(void)
/*
 * Confirmation prompt & input.
 */
{
   char buf[4];

   printf("Are you sure (yes/no)? ");
   buf[0]=(char)NULL;
   readln(buf,3);

   if (strcmp(buf,"yes")==0)
      return(TRUE);

   printf("Not confirmed.\n");
   return(FALSE);
}


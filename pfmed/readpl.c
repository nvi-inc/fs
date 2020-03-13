/*
 * Copyright (c) 2020 NVI, Inc.
 *
 * This file is part of VLBI Field System
 * (see http://github.com/nvi-inc/fs).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
/* 
 readpl - contains the interface to gnu 'readline' for pfmed.
 Entry points at readpl and initrdln available to Fortran. 
 
   PB 010730 v0.0 return a gnu 'readline' line for pfmed 
   PB 010823 v1.0 tidy-up; fix exit; aliases.
   PB 010831 v1.1 add declarations; change 11->12
   PB 010903 v1.2 add emacs,vi,ex,qu completion;
   PB 010917 v1.3 add JQ mods; help command; tidy. 
*/

#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <stdlib.h>
#ifdef READLINE
#include "../oprin/readline-2.0/readline.h"
#include "../oprin/readline-2.0/history.h"
#else
#include <readline/readline.h>
#include <readline/history.h>
#endif

/* The names of functions that actually do the manipulation. */
int com_thru (),com_help();

char *cmdstr = NULL;
static char *wkdir = "/usr2/proc"; 
static char *sortb;
int nproc;

typedef struct {
 char *name;                   /* User printable name of the function. */
 Function *func;               /* Function to call to do the job. */  
 char *doc;                    /* Documentation for this function.  */
} COMMAND;
      
COMMAND commands[] = {

  { "?",com_help,    "?                   Same as help"},
  { "??",com_help,   "??                  Same as help"},
  { "::",com_thru,   "::                  End pfmed"},
  { "dl",com_thru,   "dl                  Display procedures in active library"},
  { "ds",com_thru,   "ds                  Display procedures, sorted"},
  { "ed",com_thru,   "ed[,proc]           Edit proc with program in EDITOR variable"},
  { "edit",com_thru, "edit,[,proc]        Same as ed"},
  { "emacs",com_thru,"emacs[,proc]        emacs editor"},
  { "ex",com_thru,   "ex                  End pfmed"},
  { "exit",com_thru, "exit                End pfmed"},
  { "he",com_help,   "he                  Same as help" },
  { "help",com_help, "help                Display this help text, same as: ?, ??, he"},
  { "li",com_thru,   "li,proc             List a procedure"},    

  { "pf",com_thru,   "pf,lib              Set active procedure library"},
  { "pfcr",com_thru, "pfcr,lib            Create procedure library"},
  { "pfdl",com_thru, "pfdl                Display procedure libraries "}, 
  { "pfpu",com_thru, "pfpu,lib            Delete procedure library"},
  { "pfrn",com_thru, "pfrn,old,new        Rename procedure library"},
  { "pfst",com_thru, "pfst,old,new        Create procedure library"},
  { "pu", com_thru,  "pu,proc             Delete a procedure"},
  { "qu",com_thru,   "qu                  End pfmed"},
  { "quit",com_thru, "quit                End pfmed"},
  { "rn", com_thru,  "rn,old,new          Rename a procedure"},
  { "st",com_thru,   "st,old[::lib],new   Copy a procedure"},  
  { "vi",com_thru,   "vi[,proc]           vi editor"},
  
  { (char *)NULL, (Function *)NULL, (char *)NULL}

}; /* end command list */

char *stripwhite();
COMMAND *find_command();
void readpl();
void initrdln();

/* Return a dynamically-allocated copy of string 's': */

char * 
dupstr( char *s)
{
  char *r;
       
  if ((r = (char *)malloc(strlen(s)+1)) == NULL) {
    fprintf(stdout,"dupstr - Out of Memory Error \n"); 
    exit(1);
  }
  strcpy (r, s);
  return (r);   
}

/* initrdln_ is a calling wrapper for the Fortran main: */

void initrdln_()
{
 initialize_readline();
}              

              
/* Readln actually calls gnu 'readline' and passes it back 
   to the (Fortran) calling program: PB 010810*/
   
void readpl_(outbuf,prmpt,isort,nprc,noutbuf,nprmpt,nisort)
char *outbuf,prmpt[1];
char *isort;
int *nprc;                              
int noutbuf; /* char length for outbuf */
int nprmpt; /* char length for prmpt */
int nisort; /* char length for isort */

{
int i,nchar;
char *tmp;

    nproc = *nprc;
    sortb = isort;

    if(cmdstr!=NULL) free(cmdstr);
    cmdstr = readline(prmpt);
    if (cmdstr == NULL) cmdstr = "ex"; 
    
/*    printf("Readlnd cmdstr: %s ln: %d\n",cmdstr,strlen(cmdstr)); */

/* Save line in history if it's not blank */
    
    if (cmdstr && *cmdstr)
      add_history(cmdstr);

/* Fill up the return buffer with spaces for Foortran,
   then copy the returned command line over it: */

     for (i=0;i<102;i++) outbuf[i] = 0x20;
     nchar = strlen(cmdstr);
           
     memcpy(outbuf,cmdstr,nchar);
     
     execute_line(cmdstr);     /* Local command handler */

    return;
    
} /* end readpl */


/* Execute a command line if it exists locally,
   otherwise just do a dummy return & pass back. */

int execute_line (line)
     char *line;
{
  register int i;
  COMMAND *command;
  char *word;

  /* Isolate the command word. Include ',' */
  
  i = 0;
  while (line[i] && whitespace (line[i]))
    i++;
  word = line + i;

  while (line[i] && !whitespace(line[i]) && (line[i]!=','))
    i++;

  if (line[i])
    line[i++] = '\0';

  command = find_command (word);

  if (!command)
    {
      fprintf (stdout, "%s: No such command for Pfmed.\n", word);
      return (-1);
    }

  /* Get argument to command, if any. */
  
  while (whitespace (line[i])&&(line[i]!=','))
    i++;

  word = line + i;
  /* printf ("word = %s\n",word);*/

  /* Call the function. */
  return ((*(command->func)) (word));
}

/* Look up NAME as the name of a command, and return a pointer to that
   command.  Return a NULL pointer if NAME isn't a command name. */
COMMAND *
find_command (name)
     char *name;
{
  register int i;

  for (i = 0; commands[i].name; i++)
    if (strcmp (name, commands[i].name) == 0)
      return (&commands[i]);

  return ((COMMAND *)NULL);
}

/* Strip whitespace from the start and end of STRING.  Return a pointer
   into STRING. */
char *
stripwhite (string)
     char *string;
{
  register char *s, *t;

  for (s = string; whitespace (*s); s++)
    ;
    
  if (*s == 0)
    return (s);

  t = s + strlen (s) - 1;
  while (t > s && whitespace (*t))
    t--;
  *++t = '\0';

  return s;
}




/* **************************************************************** */
/*                                                                  */
/*                  Interface to Readline Completion                */
/*                                                                  */
/* **************************************************************** */

char *command_generator ();
char *procname_generator();
static void ignore_all();
char **pfmed_completion ();

/* Tell the GNU Readline library how to complete.  We want to try to complete
   on command names if this is the first word in the line, or on filenames
   if not. */
   
initialize_readline()
{
  /* Allow conditional parsing of the ~/.inputrc file. */
  rl_readline_name = "pfmed";

  /* Tell the completer that we want a crack first. */
  rl_attempted_completion_function = (CPPFunction *)pfmed_completion;
  
  /* But we want comma to be included in word break characters. */
    rl_basic_word_break_characters = " ,\t\n\"\\'`@$><=;|&{(";
    
}/*initialize_readline */


/* Attempt to complete on the contents of TEXT.  START and END are
   indices in rl_line_buffer saying what the boundaries of TEXT are.
   TEXT contains the word to complete.  We can use the entire
   line rl_line_buffer in case we want to do some simple parsing.
   Return the array of matches, or NULL if there aren't any. */

char **
pfmed_completion (text, start, end)
     char *text;
     int start, end;
{
  char **matches;
  int  no_args;
  
  matches = (char **)NULL;
  rl_completion_append_character = ' ';
  rl_completion_entry_function =
#ifdef READLINE
    (Function *)
#else
    (rl_compentry_func_t *)
#endif
    ignore_all;

  /* If this word is at the start of the line, then it is a command
     to complete.  Otherwise it is either a procedure name or the 
     name of a file in the current directory. 
     Fiddle the current directory to be /usr2/proc: */
     
  if (chdir(wkdir) == -1) 
    printf ("Error changing to Procedure Directory.\n");
       
  /* Calculate no of arguments required: */
  no_args = 1;
  if ((strncmp(rl_line_buffer,"dl",2) == 0) ||
      (strncmp(rl_line_buffer,"ds",2) == 0) ||
      (strncmp(rl_line_buffer,"::",1) == 0) ||
      (strncmp(rl_line_buffer,"ex",2) == 0) ||
      (strncmp(rl_line_buffer,"qu",2) == 0) ||
      (strncmp(rl_line_buffer,"pfdl",3) == 0))
    {
    no_args = 0;
    }
  if ((strncmp(rl_line_buffer,"rn",2) == 0) ||      
      (strncmp(rl_line_buffer,"st",2) == 0) ||
      (strncmp(rl_line_buffer,"pfrn",4) == 0) ||
      (strncmp(rl_line_buffer,"pfst",4) == 0))
    {
    no_args = 2;
    }

  if (start == 0) { /* It's a command: */
    matches =
#ifdef READLINE
      completion_matches
#else
      rl_completion_matches
#endif
      (text, command_generator);
    if (no_args > 0) rl_completion_append_character = ',';
    } 

  else if (((no_args > 0) && (start == strcspn(rl_line_buffer,rl_basic_word_break_characters)+1))||
           ((no_args > 1) && (start == strcspn(rl_line_buffer+strcspn(rl_line_buffer,rl_basic_word_break_characters)+1,rl_basic_word_break_characters)+strcspn(rl_line_buffer,rl_basic_word_break_characters)+2)))
    {
    if (strncmp(rl_line_buffer,"pf",2) == 0) { /* proc filename arguments: */
      rl_completion_entry_function =
#ifdef READLINE
	(Function *) filename_completion_function; /*restores default*/
#else
	(rl_compentry_func_t *) rl_filename_completion_function; /*restores default*/

#endif

      }

    else { /* procname arguments: */
      matches =
#ifdef READLINE
      completion_matches
#else
      rl_completion_matches
#endif
      (text, procname_generator);
      } 

    if ((no_args > 1) && (start == strcspn(rl_line_buffer,rl_basic_word_break_characters)+1))
      rl_completion_append_character = ',';

    }
  return (matches);
}

static int return_zero(name)
char *name;
{
 return 0;
}

static void
ignore_names(names,name_func)
char ** names;
Function *name_func;
{
 if ((*name_func)(names[0]) ==0)
  return; 
}

static void
ignore_all (text)
char **text; 
{
 ignore_names(text,return_zero);
}

/* Generator function for command completion.  STATE lets us know whether
   to start from scratch; without any state (i.e. STATE == 0), then we
   start at the top of the list. */
char *
command_generator (text, state)
     char *text;
     int state;
{
  static int list_index, len;
  char *name;

  /* If this is a new word to complete, initialize now.  This includes
     saving the length of TEXT for efficiency, and initializing the index
     variable to 0. */
  if (!state)
    {
      list_index = 0;
      len = strlen (text);
    }

  /* Return the next name which partially matches from the command list. */
  while (name = commands[list_index].name)
    {
      list_index++;

      if (strncmp (name, text, len) == 0)
        return (dupstr(name));
    }

  /* If no names matched, then return NULL. */
  return ((char *)NULL);
  
}/*command_generator*/


/* Generator function for procname completion.  STATE lets us know whether
   to start from scratch; without any state (i.e. STATE == 0), then we
   start at the top of the list. */
   
char *
procname_generator (text, state)
     char *text;
     int state;
{
  static int list_index,i,j,len;
  char name[13];

  /* If this is a new word to complete, initialize now.  This includes
     saving the length of TEXT for efficiency, and initializing the index
     variable to 0. */
     
  if (!state)
    {
      i = 0;
      list_index = 0;
      len = strlen (text);
    }

  /* Return the next name which partially matches from the procedure list. */

     while ( i< nproc) {
     
     strncpy((char * )name,sortb+list_index,12);
     
     j= 0;
     while((name[j] != 32) && (j<12)) j++ ;  
     name[j] = 0;
/*     printf("name: %s\n",name); */
          
     list_index = list_index+12;
     i++;
     
      if (strncmp ((char *) name, text, len) == 0) {
/*      printf ("\n Matched.. %s ,Ln %d\n",name,strlen(name)); */
      return (dupstr(name));
      }
     }
     
  /* If no names matched, then return NULL. */
  
  return ((char *)NULL);
  
}/*procname_generator*/


/* Implement some  commands here for execute_line.
   Presently only thru and help do anything. */

/* Pass back a command line to pfmed: */

com_thru()
{
 /* printf("thru: %s\n",cmdstr); */
 return;
}

/* Print out help for ARG, or for all of the commands if ARG is
   not present. */
com_help (arg)
     char *arg;
{
  register int i;
  int printed = 0;

  for (i = 0; commands[i].name; i++)
    {
      if (!*arg || (strcmp (arg, commands[i].name) == 0))
        {
          printf ("%s.\n", commands[i].doc);
          printed++;
        }
    }

  if (!printed)
    {
      printf ("No commands match `%s'.  Possibilties are:\n", arg);

      for (i = 0; commands[i].name; i++)
        {
          /* Print in six columns. */
          if (printed == 6)
            {
              printed = 0;
              printf ("\n");
            }

          printf ("%s\t", commands[i].name);
          printed++;
        }

      if (printed)
        printf ("\n");
    }
  return (0);
}

/* ============= End of readpl.c ============= */

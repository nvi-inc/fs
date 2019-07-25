/* fs/oprin/oprin.c -- UFS operator input.
 * $Id$

 * Copyright (C) 1992 NASA GSFC, Ed Himwich. (weh@vega.gsfc.nasa.gov)
 * Copyright (C) 1995 Ari Mujunen. (amn@nfra.nl, Ari.Mujunen@hut.fi)

 * This is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License.
 * See the file 'COPYING' for details.

 * $Log$
 */

#include <stdio.h>
#include <sys/types.h>

/* For tolower. */
#include <ctype.h>

/* For assert. */
#include <assert.h>

/* For open, stat, read, close, isatty. */
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>

/* For malloc, free. */
#include <stdlib.h>

/* For GNU Readline. */
#include <readline/readline.h>
#include <readline/history.h>

/* fs params */
#include "../include/params.h"

/* our external prototypes */
#include "readl.h"

/* GNU Readline-related completion functions. */

/* Return an allocated duplicate of a given string S. */
char *
dupstr(char *s)
{
  char *r;

  if ((r = malloc(strlen(s)+1)) == NULL) {
    fprintf(stderr, "dupstr: out of memory when duplicating string '%s'\n", s);
    exit(1);
  }
  strcpy(r, s);
  return (r);
}


/* The dynamically allocated SNAP command table. */

/* Command characters as read from the 'fscmd.ctl' file. */
static char *commands = NULL;
static size_t commands_size = 0;

/* Pointers to the start of each command in the previous 'commands'. */
static char **command_table = NULL;


/* Load the file containing commands. */
static void
load_snap_commands(char *filename, int file_must_exist)
{
  int fd;
  struct stat stat_buff;
  size_t size;
  int bytes_read;

  /* Must not load new files if command pointers have already been
     calculated by 'prepare_command_pointer_table'. */
  assert(command_table == NULL);

  if ((fd = open(filename, O_RDONLY)) < 0) {
    if (file_must_exist) {
      perror(filename);
      exit(1);
    } else {
      return;
    }
  }

  /* Find out how long the file is. */
  (void)fstat(fd, &stat_buff);
  size = (size_t)stat_buff.st_size;

  /* Read it all into memory by appending to char buffer 'commands'. */
  commands_size += size;
  if ((commands = realloc(commands, commands_size)) == NULL) {
    fprintf(stderr, "load_snap_commands: out of memory when allocating SNAP command table '%s' (%d bytes more)\n", filename, (int)size);
    exit(1);
  }
  if ((bytes_read = read(fd, (commands + commands_size - size), size)) < 0) {
    perror(filename); 
    exit(1);
  }
  if (bytes_read != size) {
    fprintf(stderr, "load_snap_commands: read only %d bytes from SNAP command table '%s' (%d bytes)\n", (int)bytes_read, filename, (int)size);
  }

  (void)close(fd);
}  /* load_snap_commands */


/* Prepare a table of pointers to the individual commands.
   There is one command per line, so count '\n's
   resulting in the max number of command pointers needed
   and at the same time, force everything into lowercase. */
static void
prepare_command_pointer_table(void)
{
  int num_of_commands;
  int i;
  int start_of_command;

  /* Safeguard against not having any command characters. */
  if (commands == NULL) {
    return;
  }

  /* Count newlines & tolower. */
  num_of_commands = 0;
  for (i=0; i < commands_size; i++) {
    commands[i] = tolower(commands[i]);
    if (commands[i] == '\n') {
      num_of_commands++;
    }
  }

  /* Allocate pointer table (pointer to start of each SNAP command word. */
  if ((command_table = malloc(num_of_commands*sizeof(char *))) == NULL) {
    fprintf(stderr, "prepare_command_pointer_table: out of memory when allocating SNAP command pointer table (%d bytes)\n", (int)(num_of_commands*sizeof(char *)));
    exit(1);
  }

  /* Scan thru command characters storing pointers to SNAP words. */
  num_of_commands = 0;
  start_of_command = 1;
  for (i=0; i < commands_size; i++) {
    if (start_of_command) {
      if (commands[i] == '*') {
	;  /* ignore '*' comment lines */
      } else if (commands[i] == '\n') {
	;  /* ignore empty lines */
      } else if (commands[i] == ' ') {
	;  /* ignore lines starting with a space */
      } else {
        command_table[num_of_commands] = &(commands[i]);
        num_of_commands++;
      }
      start_of_command = 0;
    }
    if (commands[i] == ' ') {
      /* One could have auto-'=' after commands that _always_ require it. */
      /* commands[i++] = '='; */
      commands[i] = '\0';
    }
    if (commands[i] == '\n') {
      start_of_command = 1;
    }
  }  /* for */

  /* Mark the end of pointer table. */
  command_table[num_of_commands] = NULL;
}  /* prepare_command_pointer_table */


/* Generator function for command completion.  STATE lets us know whether
   to start from scratch; without any state (i.e. STATE == 0), then we
   start at the top of the list. */
static char *
snap_command_generator(char *text, int state)
{
  static int list_index, len;
  char *name;

  /* If this is a new word to complete, initialize now.  This includes
     saving the length of TEXT for efficiency, and initializing the index
     variable to 0. */
  if (state == 0) {
    list_index = 0;
    len = strlen(text);
  }

  /* Return the next name which partially matches from the command list. */
  while ((command_table) && (name = command_table[list_index])) {
    list_index++;

    if (strncmp(name, text, len) == 0)
      return (dupstr(name));
  }

  /* If no names matched, then return NULL. */
  return ((char *)NULL);
}  /* snap_command_generator */


/* Attempt to complete on the contents of TEXT.  START and END show the
   region of rl_line_buffer (where TEXT came from) that contains the word 
   to complete.  We can use the entire line in case we want to do 
   some simple parsing, and we check for help command '?='.
   Return the array of matches, or NULL if there aren't any. */
static char **
oprin_completion(char *text, int start, int end)
{
  char **matches;

  /* If this word is at the start of the line, then it is a command
     to complete.  Otherwise it is the name of a file in the current
     directory. */
  if ((start == 0)  /* at start of line... */
      || ((start == 2)  /* ...or '?='...*/
	  && (strncmp(rl_line_buffer, "?=", 2) == 0))
      || ((start == 5)  /* ...or 'help='. */
	  && (strncmp(rl_line_buffer, "help=", 5) == 0))
      )
    {
#if AUTO_EQUALS_AFTER_COMPLETED_INITIAL_SNAP_COMMAND
    /* SNAP commands at the start of a line completed with '='. */
    if ((start == 0) {
      rl_completion_append_character = '=';
    } else {
      rl_completion_append_character = '\0';
    }
#else
    rl_completion_append_character = '\0';
#endif

    matches = completion_matches (text, snap_command_generator);

  } else {
#if AUTO_TRAILING_COMMA_AFTER_COMPLETED_FILENAME
    /* SNAP parameters (actually filename pars only) completed with ','. */
    rl_completion_append_character = ',';
#else
    rl_completion_append_character = '\0';
#endif
    matches = NULL;
  }

  return (matches);
}  /* oprin_completion */


/* Tell the GNU Readline library how to complete.  We want to try to complete
   on command names if this is the first word in the line, or on filenames
   if not. */
void
initialize_readline(void)
{
  /* Gee, I didn't know before that one can concatenate constant strings
     by just putting them one after another. */
  static char stcmd_name[] = FS_ROOT "/control/stcmd.ctl";
  static char fscmd_name[] = FS_ROOT "/fs/control/fscmd.ctl";

  /* Allow conditional parsing of the ~/.inputrc file. */
  rl_readline_name = "oprin";

  /* Load SNAP command tables for our completion function. */
  load_snap_commands(stcmd_name, /*file_must_exist=>*/0);
  load_snap_commands(fscmd_name, 1);
  prepare_command_pointer_table();

  /* Tell the completer that we want a crack first. */
  rl_attempted_completion_function = (CPPFunction *)oprin_completion;

  /* We don't want an added space after a completed SNAP command. */
  rl_completion_append_character = '\0';

/* But we want comma to be included in word break characters. */
  rl_basic_word_break_characters = " ,\t\n\"\\'`@$><=;|&{(";
}  /* initialize_readline */

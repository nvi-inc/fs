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

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"

#include "readl.h"

/* External FS variables. */
extern struct fscom *shm_addr;

/* External FS functions, perhaps these should eventually go into a '.h'? */
extern void setup_ids(void);
extern void sig_ignore(void);
extern void cls_snd(long *class,
		    char *buffer,
		    int length,
		    int parm3,
		    int parm4);
extern void skd_run(char name[5], char w, long ip[5]);

static long ipr[5] = { 0, 0, 0, 0, 0};

/* Our prompt at the beginning of a line. */
static char prompt[] = ">";

/* SNAP command that
    - gets recommended to a user who presses ctrl-D (EOF) at the beginning
      of input line to "logout" ie. quit */
static char termination_command[] = "terminate";


/* The dynamically allocated SNAP command table. */

/* 'oprin' main. */

int
main(int argc, char **argv)
{
  char *input;
  char *previous_input;
  int length;

  setup_ids();
  sig_ignore();

  initialize_readline();

  previous_input = NULL;
  while (1) {

    input = readline(prompt);

    /* After a user has completed a new input line,
       get rid of the previous one (if it exists). */
    if (previous_input) {
      free(previous_input);
      previous_input = NULL;
    }

    if (input == NULL) {
      /* We have EOF ie. ctrl-D at the beginning of a line. */

      /* If file input, we give up and pretend we have got a
         termination command. */
      if (!isatty(STDIN_FILENO)){
	input = dupstr(termination_command);
      }
    }
    if (input == NULL) {
      /* EOF-warning at interactive terminals only. */
      if (isatty(STDERR_FILENO)) {
        fprintf(stderr, "Use '%s' to stop the field system.\n", termination_command);
      }
      continue;  /* no further actions (ie. 'free()') required */
    }

    /* Now we have got something that's not EOF,
       perhaps an empty line or a real command. */

    if ((length = strlen(input))) {
         /* 'readline()' removes the terminating newline. */

      /* We have at least one character. Let's add the line to the history. */

      add_history(input);

      /* Execute this SNAP command via "boss". */
      cls_snd( &(shm_addr->iclopr), input, length, 0, 0);
      skd_run("boss ",'n',ipr);

    }  /* if have at least one character */

    /* Instead of 'free()'ing the input line buffer straight away,
       we store it to be freed _after_ the user has completed
       the next input line.  In this way "boss" (et al) can safely
       access the previous buffer.  (Might be unnecessary, since
       'cls_snd()' apparently makes a copy of the command line.) */
    previous_input = input;
  }  /* while forever */

  return (0);  /* ok termination, actually never reached */
  /* Command tables actually never get deallocated,
     but they'll vanish when the 'oprin' process vanishes. */
}  /* main of oprin */

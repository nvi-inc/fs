/*
 * Copyright (c) 2020, 2022, 2023 NVI, Inc.
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
/* erchk.c
 *
 *       The error message to be processed is transmitted by ddout and
 *       retrieved with the get_err() call.
 *
 * VERY IMPORTANT:
 *
 *   It is mandatory that this program _not_ use the FS class-I/O system,
 *   particularly cls_snd() and any other calls that use it, including the
 *   logit*() family of calls. Not following this rule could cause a
 *   deadlock situation.
 *
 *   If this program encounters any error internally, it should use its
 *   own independent error reporting system and not report via the FS.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <errno.h>

#include "../include/params.h" /* FS parameters            */
#include "../include/fs_types.h" /* FS header files        */
#include "../include/fscom.h"  /* FS shared mem. structure */
#include "../include/shm_addr.h" /* FS shared mem. pointer */

#include "erchk.h"

#define MAX_LEN 256+1

#define SLEEP_TIME      500
#define NSEM_NAME       "fs   "

struct fscom *fs;

/* Subroutines called */

void setup_ids();
void skd_wait();
void get_err();
void display_it();
int read_ctl();

// I always forget which end of the pipe is which
#define READ_END 0
#define WRITE_END 1

int read_ssub() {
  int pipefd[2];
  if (pipe(pipefd) < 0) {
    perror("erchk: error creating pipe");
    exit(EXIT_FAILURE);
  }

  pid_t pid = fork();
  if (pid < 0) {
    perror("erchk: error forking");
    exit(EXIT_FAILURE);
  }

  if (pid == 0) {
    close(pipefd[WRITE_END]);
    return pipefd[READ_END];
  }

  close(pipefd[READ_END]);
  dup2(pipefd[WRITE_END], STDOUT_FILENO);
  execlp("ssub", "ssub", "-w", "-s", FS_SERVER_URL_BASE "/windows/fs/pub", FS_SERVER_URL_BASE "/windows/fs/rep", NULL);
  perror("erchk: error starting ssub");
  exit(EXIT_FAILURE);

}

int read_skd() {
  int ip[5];
  char buffer[MAX_LEN] = {0};

  int pipefd[2];
  if (pipe(pipefd) < 0) {
    perror("erchk: error creating pipe");
    exit(EXIT_FAILURE);
  }

  pid_t pid = fork();
  if (pid < 0) {
    perror("erchk: error forking");
    exit(EXIT_FAILURE);
  }

  if (pid == 0) {
    close(pipefd[WRITE_END]);
    return pipefd[READ_END]; 
  }
  close(pipefd[READ_END]);
  dup2(pipefd[WRITE_END], STDOUT_FILENO);

  /* Initialize:
   *
   * set up IDs for shared memory
   * copy pointer to fs for readability
   * set erchk variable
   */

  setup_ids();
  char *serve_env_var = getenv("FS_DISPLAY_SERVER");
  if (serve_env_var && 0==strcmp(serve_env_var,"off")) { /* off */
    if (nsem_test(NSEM_NAME) != 1) {
      fprintf(stderr,"Field System not running - erchk aborting\n");
      rte_sleep(SLEEP_TIME);
      exit(0);
    }
    if ( 1 == nsem_take("erchk",1)) {
      fprintf( stderr,"erchk already running\n");
      rte_sleep(SLEEP_TIME);
      exit(0);
    }
  }

  fs = shm_addr;
  fs->erchk = -1;
  for (;;) {
    skd_wait("erchk", ip, (unsigned)0); /* waiting */
    get_err(buffer, MAX_LEN, ip);       /* retrieve error */
    printf("%s\n", buffer);
  }
}

int main()
{
  int i,irow,icol,fd;
  char control_file[80];
  char working[MAX_LEN];
  size_t n;
  char *buffer = NULL;
  struct errlist *start;
  struct errlist *item;
  int iret=0;
  char *ptr, *code, *num, *prefix, *attrib;
  int match;

  strcpy(control_file,FS_ROOT);
  strcat(control_file,"/control/erchk.ctl");

  FILE *fp = fopen(control_file, "r");
  if(fp == NULL) {
      fprintf(stderr,"Unable to open '%s': %s\n",control_file,strerror(errno));
      if(errno==ENOENT) {
          fprintf(stderr,"  You can install the default example file with:\n");
          fprintf(stderr,"    cp /usr2/fs/st.default/control/erchk.ctl /usr2/control\n");
      }
      fprintf(stderr,"  Press <return> (or close this window) to exit and try again.\n");
      getchar();
      exit(-1);
  }

  iret=read_ctl(fp,&start);
  if(EOF==fclose(fp)) {
    perror("Closing file");
    fprintf(stderr,"  Internal program error at line %d of control file, send error to developer.\n",iret);
    fprintf(stderr,"  Was trying to close '%s'\n",control_file);
    fprintf(stderr,"  Press <return> (or close this window) to exit.\n");
    getchar();
    exit(-1);
  }

  //  int count=0;
  //  item=start;
  //  while(NULL != item) {
  //    count++;
  //    printf(" count %d",count);
  //    if(item->code!=NULL)
  //      printf(" code '%s'",item->code);
  //    if(item->num!=NULL)
  //      printf(" num  '%s'",item->num);
  //    if(item->attrib!=NULL)
  //      printf(" attrib  '%s'",item->attrib);
  //    if(item->prefix!=NULL)
  //      printf(" prefix  '%s'",item->prefix);
  //    printf("\n");
  //    item=item->next;
  //  }

  if(iret<0) {
    fprintf(stderr,"  Correct the errors reported above and try again.\n");
    fprintf(stderr,"  Was trying to parse '%s'\n",control_file);
    fprintf(stderr,"  See '/usr2/fs/st.default/control/erchk.ctl' for the format.\n");
    fprintf(stderr,"  You can run 'erchk' by itself in a window to debug these errors.\n");
    fprintf(stderr,"  When you get no errors, use Control-C to quit.\n");
    fprintf(stderr,"  For now, press <return> (or close this window) to exit and try again.\n");
    getchar();
    exit(-1);
  } else if (iret>0) {
    fprintf(stderr,"  Internal program error at line %d of control file, send error to developer.\n",iret);
    fprintf(stderr,"  Was trying to read '%s'\n",control_file);
    fprintf(stderr,"  Press <return> (or close this window) to exit.\n");
    getchar();
    exit(-1);
  }

  char *serve_env_var = getenv("FS_DISPLAY_SERVER");
  if (!serve_env_var || 0!=strcmp(serve_env_var,"off")) /* not off */
    fd = read_ssub();
  else
    fd = read_skd();

  FILE* pipe = fdopen(fd, "r");


/* Now loop waiting for errors */
  i=0;
  irow=0;
  icol=0;

  while (getline(&buffer, &n, pipe) >= 0 &&  n > 0) { /* retrieve error from the pipe */
    if (!strstr(buffer, "?ERROR "))
      continue;

    strcpy(working,buffer);
    ptr=strtok(working," ");
    code=strtok(NULL," ");
    num=strtok(NULL," (");
    if(NULL==code||NULL==num)
      continue;
    //      printf(" ptr '%s' code '%s' num '%s'\n",ptr,code,num);
    item=start;
    match=0;
    while(NULL != item && !match) {
      //        printf(" code '%s' num '%s'\n",item->code,item->num);
      if(!strcmp("any",item->code)) {
        prefix=item->prefix;
        attrib=item->attrib;
        match=1;
      } else if(!strcmp(code,item->code) &&
          (!strcmp("any",item->num)||!strcmp(num,item->num))) {
        prefix=item->prefix;
        attrib=item->attrib;
        match=1;
      }
      item=item->next;
    }
    if(match && NULL!=attrib) {
      if(0!= strlen(prefix))
        printf("%s ",prefix);
      display_it(irow,icol,attrib,buffer);
    }
  }
  if (buffer)
    free(buffer);
  return 0;
}
/************************************************************************
examples:
display_it(0, 4, "Y5", string);
display_it(1, 4, "R5", string);
display_it(2, 4, "C", STRING);
display_it(2, 4, "Y", STING);
display_it(2, 40, "", string);
display_it(2, 105, "Y", "BAD ");
display_it(2,105,"", "GOOD");
display_it(2, 4, "B", "VAC  MKIII     STOP  ????????");
************************************************************************/
/* Function declarations:
 *   Row - Screen row position
 *   Col - Screen column position
 *   Attrib - Modifiying attributes (blink, underline, red, blue...)
 *   InLine - The text to print
 */
void
display_it(int Row, int Col, char *Attrib, char *InLine)
{
  int i;

  /* Check for attribute modifiers */
  if (strstr(Attrib, "R")){
    (void)printf("%c[1;31m", 27);
  }
  else if (strstr(Attrib, "G"))
    (void)printf("%c[1;32m", 27);
  else if (strstr(Attrib, "Y"))
    (void)printf("%c[1;33m", 27);
  else if (strstr(Attrib, "B")) {
    (void)printf("%c[1;34m", 27);
  }
  else if (strstr(Attrib, "M"))
    (void)printf("%c[1;35m", 27);
  else if (strstr(Attrib, "C"))
    (void)printf("%c[1;36m", 27);
  else if (strstr(Attrib, "W"))
    (void)printf("%c[1;37m", 27);
  else if (strstr(Attrib, "X"))
    (void)printf("%c[1;30m", 27);
  
  if (strstr(Attrib, "7"))
    (void)printf("%c[7m", 27);
  if (strstr(Attrib, "5"))
    (void)printf("%c[5m", 27);
  if (strstr(Attrib, "4"))
    (void)printf("%c[4m", 27);
  if (strstr(Attrib, "1"))
    (void)printf("%c[1m", 27);
  if (strstr(Attrib, "0"))
    (void)printf("%c[0m", 27);
  
/* Position the cursor and print the text. If Row and Col are 0, just print */
  if (Row== 0 && Col== 0)
    (void)printf("%s", InLine);
  else
    (void)printf("%c[%d;%dH%s", 27, Row, Col, InLine);
  
/* Reset the video attributes. Don't send anything if we don't have to */
  if (*Attrib!= '\0')
    (void)printf("%c[0m", 27);
  
}

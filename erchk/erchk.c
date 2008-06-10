/* erchk.c
 */

#include <stdio.h>
#include <string.h>

#include "../include/params.h" /* FS parameters            */
#include "../include/fs_types.h" /* FS header files        */
#include "../include/fscom.h"  /* FS shared mem. structure */
#include "../include/shm_addr.h" /* FS shared mem. pointer */

#define MAX_LEN 256+1

struct fscom *fs;

/* Subroutines called */

void setup_ids();
void skd_wait();
void get_err();
void display_it();

main()
{
  int i,irow,icol;
  long ip[5];
  char buffer[MAX_LEN];
  char chk_message[MAX_LEN];

/* Initialize:
 *
 * set up IDs for shared memory
 * copy pointer to fs for readability
 * set erchk variable
 */

  setup_ids();
  fs = shm_addr;

  fs->erchk = -1;

/* Now loop waiting for errors */
  i=0;
  irow=0;
  icol=0;
Loop:
  skd_wait("erchk",ip,(unsigned)0);     /* waiting */
  get_err(buffer,MAX_LEN,ip);           /* retrieve error */
  if(strcmp(chk_message,buffer)) {
    strcpy(chk_message,buffer);
    if(strstr(buffer," bo ") ||
       strstr(buffer," ch ") ||
       strstr(buffer," ma ")) {
      printf("**** ");
      display_it(irow,icol,"M",buffer);
      printf("\n");
    } else if(strstr(buffer," m5 ") ||
	      strstr(buffer," 5m ") ||
	      strstr(buffer," mc ") ||
	      strstr(buffer," an ")){
      printf("*** ");
      display_it(irow,icol,"R",buffer);
      printf("\n");
    } else if(strstr(buffer," fm ")) {
      printf("** ");
      display_it(irow,icol,"Y",buffer);
      printf("\n");
    } else if(strstr(buffer," sp ")) {
    } else {
      printf("* ");
      display_it(irow,icol,"B",buffer);
      printf("\n");
    }
  }
  goto Loop;
  /* we never exit, the field system program 'fs' will kill us if the 
   * operator terminates.
   */
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

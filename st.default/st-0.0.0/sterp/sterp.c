/* sterp.c
 *
 * This is the stub version of sterp (STation ERror Program). 
 *
 * You can test this this program after making it as part of
 * your station software by putting the following line in your
 * stpgm.ctl file: "sterp n xterm -g +75+75 -e sterp &"
 *
 * Input:
 *       The error message to be processed is transmitted by ddout and
 *       retrieved with the get_err() call.
 *
 * Output: None 
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

#include "../../fs/include/params.h" /* FS parameters            */
#include "../../fs/include/fs_types.h" /* FS header files        */
#include "../../fs/include/fscom.h"  /* FS shared mem. structure */
#include "../../fs/include/shm_addr.h" /* FS shared mem. pointer */

#define MAX_LEN 256+1

struct fscom *fs;

/* Subroutines called */

void setup_ids();
void skd_wait();
void get_err();

main()
{
  long ip[5];
  char buffer[MAX_LEN];

/* Initialize:
 *
 * set up IDs for shared memory
 * copy pointer to fs for readability
 * set sterp variable
 */

  setup_ids();
  fs = shm_addr;

  fs->sterp = -1;

/* Now loop waiting for errors */

Loop:
  skd_wait("sterp",ip,(unsigned)0);     /* waiting */
  get_err(buffer,MAX_LEN,ip);           /* retrieve error */
  printf("%s\n",buffer);                /* process it */
  goto Loop;

/* we never exit, the field system program 'fs' will kill us if the operator
 * terminates
 */
}

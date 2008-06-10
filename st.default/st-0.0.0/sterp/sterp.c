/* sterp.c
 *
 * This is the stub version of sterp (STation ERror Program). 
 *
 * You can test this this program after making it as part of
 * your station software by putting the following line in your
 * stpgm.ctl file: "sterp n xterm -g +75+75 -e sterp &"
 *
 * Input:
 *       IP(0) = class number to retrieve message from
 *
 * Output: None 
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

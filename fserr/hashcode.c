#include <memory.h>
#include <stdio.h>

#include "fserr.h"

/*                                                                 */
/*  HASHCODE is the hash code to find the potential position in    */
/*  the array. Potential position because this code does not look  */
/*  for a conflict, it is just the hash code.                      */
/*                                                                 */

/*                                                                 */
/*  HISTORY:                                                       */
/*  WHO  WHEN    WHAT                                              */
/*  gag  920917  Created.                                          */
/*                                                                 */

struct entrystruc{
  char buf[2];
  int off;
};

void hashcode(entry, hash)
struct entrystruc *entry;
long *hash;

{
  int i;
  int itemp;
  char dig[3];

/*                                                                 */
/*  Use the uppercase mnemonic characters of the error message as  */
/*  a starting point for the hash. Then use the error numbers to   */
/*  get an offset to the starting point.                           */
/*                                                                 */

  *hash=((abs((*entry).buf[0]-65))/2)*100;
  *hash+=(abs((*entry).buf[1]-65))*10;
  *hash+= abs((*entry).off);
  if (*hash >= MAXERRORS) *hash=*hash%MAXERRORS;

}

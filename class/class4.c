#include <sys/types.h>
#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

main()
{
  int i;

  setup_ids();
  printf(" class_count %d\n",shm_addr->class_count);

  printf(" iclbox %d iclopr %d \n",shm_addr->iclbox,shm_addr->iclopr);

  for (i=0;i<MAX_CLS;i++)
     if(shm_addr->nums[i]!=0)
     printf(" class %d nums %d\n",i+1,shm_addr->nums[i]);

}

#include <sys/types.h>
#include <sys/ipc.h>
#include <signal.h>

#include "../../fs/include/pmodel.h"

#include "../include/stparams.h"
#include "../include/stcom.h"

void setup_st()
{
    void stm_att();

    stm_att( STM_KEY);
}

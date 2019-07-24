/* general fs parameter header */

#ifndef TRUE
#define TRUE        1
#define FALSE       0
#endif

#define SHM_KEY     1
#define SHM_SIZE    10240
#define C_RES       5120

#define CLS_KEY     1
#define CLS_SIZE    20480
#define MAX_CLS     40

#define SKD_KEY     2
#define SKD_SIZE    4096

#define BRK_KEY     3
#define BRK_SIZE    1024

#define MAX_SEM_LIST 20
#define SEM_SEM     MAX_SEM_LIST+0
#define SEM_CLS     MAX_SEM_LIST+1

#define SEM_KEY     1
#define SEM_NUM     MAX_SEM_LIST+2

#define MAX_PTS     3

#ifndef TRUE
#define TRUE        1
#define FALSE       0
#endif

#define BAD_ADDR    (char *)(-1)

#define FSPGM_CTL "/usr2/fs/control/fspgm.ctl"
#define STPGM_CTL "/usr2/control/stpgm.ctl"

#define ADDR      "addr"              
#define TEST      "test"
#define REBOOT    "reboot"
#define BAD_VALUE "BAD_VALUE"

#define MAX_VC     15
#define MAX_BBC    15
#define MAX_DIST   2
#define MAX_DET    34

#define DEV_VRC     "rc"
#define DEV_VFM     "fm"
#define DEV_VIA     "ia"
#define DEV_VIC     "ic"

#define MAX_HOR   30
#define MAX_RXCODES   40

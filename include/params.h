/* general fs parameter header */

#ifndef TRUE
#define TRUE        1
#define FALSE       0
#endif

#define WORD_BIT    32
#define PAGE_SIZE   4096

#define SHM_KEY     1
#define C_RES       6*PAGE_SIZE /* reserves bytes for Fscom     */
#define SHM_SIZE    C_RES+2*PAGE_SIZE /* should be a multiple of 4096 */

#define CLS_KEY     1
#define CLS_SIZE    20480
#define MAX_CLS     40

#define SKD_KEY     2
#define SKD_SIZE    4096

#define BRK_KEY     3
#define BRK_SIZE    1024

#define SEM_GO       0
#define SEM_SEM      1
#define SEM_CLS      2

#define SEM_KEY     1
#define NSEM_KEY    2
#define GO_KEY      3

#define SEM_NUM     32

#define MAX_PTS     3

#ifndef TRUE
#define TRUE        1
#define FALSE       0
#endif

#define BAD_ADDR    (char *)(-1)

#define FSPGM_CTL "/usr2/fs/control/fspgm.ctl"
#define STPGM_CTL "/usr2/control/stpgm.ctl"

#define ADDR_ST   "addr"              
#define TEST      "test"
#define REBOOT    "reboot"
#define BAD_VALUE "BAD_VALUE"

#define MAX_VC     15
#define MAX_BBC    14
#define MAX_DIST   2
#define MAX_DET    32

#define DEV_VRC     "rc"
#define DEV_VFM     "fm"
#define DEV_VIA     "ia"
#define DEV_VIC     "ic"

#define MAX_HOR   30
#define MAX_RXCODES   40

/* rack/drive */

#define K4MK4       0x40
#define K4          0x20
#define VLBA4       0x10
#define S2          0x08
#define MK4         0x04
#define VLBA        0x02
#define MK3         0x01

/* rack/drive _types */

#define VLBAG       0x100
#define VLBA2       0x200
#define MK3B        0x400
#define K41         0x800
#define K41U        0x1000
#define K42         0x2000
#define K42A        0x4000
#define K42BU       0x8000
#define K41K3       0x10000
#define K41UK3      0x20000
#define K42K3       0x40000
#define K42AK3      0x80000
#define K42BUK3     0x100000
#define K41MK4      0x200000
#define K41UMK4     0x400000
#define K42MK4      0x800000
#define K42AMK4     0x1000000
#define K42BUMK4    0x2000000

#define FS_ROOT     "/usr2"

#define CH_PRIOR    -4
#define CL_PRIOR    -8
#define FS_PRIOR   -12
#define AN_PRIOR   -16



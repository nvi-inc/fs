/* general fs parameter header */

#ifndef TRUE
#define TRUE        1
#define FALSE       0
#endif

#define WORD_BIT    32
#define PAGE_SIZE   4096

#define C_RES       35*PAGE_SIZE /* reserves bytes for Fscom     */
#define SHM_SIZE    C_RES+2*PAGE_SIZE /* should be a multiple of 4096 */

#define CLS_SIZE    20480
#define MAX_CLS     40

#define SKD_SIZE    4096

#define BRK_SIZE    1024

#define SEM_GO       0
#define SEM_SEM      1
#define SEM_CLS      2

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
#define MAX_USER_DEV  6
#define MAX_ONOFF_DET MAX_DET+MAX_USER_DEV

#define DEV_VFM     "fm"
#define DEV_VIA     "ia"
#define DEV_VIC     "ic"

#define MAX_HOR   30
#define MAX_RXCODES   40

/* rack/drive */

#define MK5         0x400
#define LBA4        0x200	/* Temporary: LBA with Mark4 */
#define LBA         0x100
#define K4K3        0x080
#define K4MK4       0x040
#define K4          0x020
#define VLBA4       0x010
#define S2          0x008
#define MK4         0x004
#define VLBA        0x002
#define MK3         0x001

/* rack/drive _types */

#define VLBAG       0x1000
#define VLBA2       0x2000
#define MK4B        0x4000
#define K41         0x8000
#define K41U        0x10000
#define K42         0x20000
#define K42A        0x40000
#define K42BU       0x80000
#define VLBAB       0x100000
#define K41DMS      0x200000
#define K42DMS      0x400000
#define K42B        0x800000
#define K42C        0x1000000
#define VLBA42      0x2000000
#define MK5A        0x4000000
#define MK5A_BS     0x8000000
/*
 * The number of DAS allowed must be less than 8, currently we allow 2
 *   - also add additional SNAP commands in fs/control/fscmd.ctl
 *     and creates equivalent help file soft-links in fs/help
 *   - the value in fs/include/param.i should also be updated
 */
#define MAX_DAS		2	/* Max no of DAS allowed */
#define DAS_TEMP_MAX	45	/* DAS module temperature limit (C) */
#define DAS_V_TOLER	5.0	/* DAS supply voltage tolerance (%) */

/* Weather type of hardware wx_met */
#define MET3        0x1 /* MET Sensor */

#define FS_ROOT     "/usr2"

#define CH_PRIOR    -4
#define CL_PRIOR    -8
#define FS_PRIOR   -12
#define AN_PRIOR   -16

#define MAX_RXGAIN 20
#define MAX_FLUX   50

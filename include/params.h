/* general fs parameter header */

#ifndef TRUE
#define TRUE        1
#define FALSE       0
#endif

#define WORD_BIT    32
#define PAGE_SIZE   4096

#define C_RES       136*PAGE_SIZE /* reserves bytes for Fscom     */
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

#define FS_DISPLAY_PUBADDR "tcp://127.0.0.1:7083"
#define FS_DISPLAY_REPADDR "tcp://127.0.0.1:7084"
#define FS_DISPLAY_SCROLLBACK_LEN "1024"

#define ADDR_ST   "addr"              
#define TEST      "test"
#define REBOOT    "reboot"
#define BAD_VALUE "BAD_VALUE"

#define MAX_VC         15
#define MAX_BBC        16
#define MAX_VLBA_BBC   14
#define MAX_VLBA_DIST   2
#define MAX_IF          4
#define MAX_VLBA_IF     (2*MAX_VLBA_DIST)
#define MAX_DET         (MAX_BBC*2+MAX_IF)
#define MAX_RDBE_DET    (MAX_RDBE_CH*MAX_RDBE_IF*MAX_RDBE)
#define MAX_USER_DEV    6
//#define MAX_ONOFF_DET    (MAX_DET+MAX_USER_DEV)
#define MAX_ONOFF_DET    (MAX_RDBE_DET+MAX_USER_DEV)

#define MAX_DBBC_BBC   16
#define MAX_DBBC_IF     4
#define MAX_DBBC_DET    (2*MAX_DBBC_BBC+MAX_DBBC_IF)

#define DEV_VFM     "fm"
#define DEV_VIA     "ia"
#define DEV_VIC     "ic"

#define MAX_HOR   30
#define MAX_RXCODES   40

/* rack/drive, some are also _types.
   Hierarchy: rack/drive, then rack_type/drive_type
   "*_type" must be unique within each "equip" */ 
#define RDBE        0x2000
  /* rack_types: RDBE, drive_types: none  */
#define MK6        0x1000
  /* rack_types: none, drive_types: MK6  */
#define DBBC        0x800
  /* rack_types: DBBC, drive_types: none  */
#define MK5         0x400
  /* rack_types: none, drive_types: MK5A, MK5A_BS, MK5B, MK5_BS  */
#define LBA4        0x200	/* Temporary: LBA with Mark4 */
  /* rack_types: LBA4, drive_types: none  */
#define LBA         0x100
  /* rack_types: LBA, drive_types: none  */
#define K4K3        0x080
   /* rack_types:  K41, K41U, K42, K42A, K42BU,
      drive_types: none */
#define K4MK4       0x040
   /* rack_types:  K41, K41U, K42, K42A, K42B, K42BU, K42C,
      drive_types: none */
#define K4          0x020
  /* rack_types:  K41, K41U, K42, K42A, K42B, K42BU, K42C,
     drive_types: K41, K42, K41DMS, K42DMS */
#define VLBA4       0x010
  /* rack_types: VLBA4, VLBA45, drive_types: VLBA4, VLBA42  */
#define S2          0x008
  /* rack_types: S2, drive_types: S2  */
#define MK4         0x004
  /* rack_types: MK4, MK45  drive_types: MK4, MK4B  */
#define VLBA        0x002
/* rack_types: VLBA, VLBAG, drive_types: VLBA, VLBA2, VLBAB */
#define MK3         0x001
  /* rack_types: MK3, drive_types: MK3  */

/* other rack/drive _types */

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
#define MK45        0x10000000
#define VLBA45      0x20000000

/* Mark 5 drive_types */

#define MK5A        0x4000000
#define MK5A_BS     0x8000000
#define MK5B        0x40000000
#define MK5B_BS     0x10000000

#define MK5C        0x1
#define MK5C_BS     0x2

/*
 * The number of DAS allowed must be less than 8, currently we allow 2
 *   - also add additional SNAP commands in fs/control/fscmd.ctl
 *     and creates equivalent help file soft-links in fs/help
 *   - the value in fs/include/param.i should also be updated
 */
#define MAX_DAS		2	/* Max no of DAS allowed */
#define DAS_TEMP_MAX	45	/* DAS module temperature limit (C) */
#define DAS_V_TOLER	5.0	/* DAS supply voltage tolerance (%) */

#define FS_ROOT     "/usr2"

#define CH_PRIOR    -4
#define CL_PRIOR    -8
#define FS_PRIOR   -12
#define AN_PRIOR   -16

#define MAX_RXGAIN 20
#define MAX_FLUX   100

#define MAX_EPHEM 14400

#define MAX_DBBCNN 16
#define MAX_DBBCIFX 4

#define MAX_MK6    2

#define MAX_RDBE    4
#define MAX_RDBE_CH  16
#define MAX_RDBE_IF   2

#define MAX_LO     (MAX_RDBE*MAX_RDBE_IF)

/*
 * Copyright (c) 2020, 2022, 2023, 2025 NVI, Inc.
 *
 * This file is part of VLBI Field System
 * (see http://github.com/nvi-inc/fs).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
/* general fs parameter header */

#ifndef TRUE
#define TRUE        1
#define FALSE       0
#endif

#define WORD_BIT    32
#define PAGE_SIZE   4096

#define C_RES       189*PAGE_SIZE /* reserves bytes for Fscom     */
/* for C_RES */
/* take 'x' size from " setup_ids: Fscom C structure too large: x bytes */
/* divide by PAGE_SIZE, round up to next integer */
/* must be for 64 bit system to work for both 32 and 64 */
#define SHM_SIZE    C_RES+4*PAGE_SIZE /* should be a multiple of 4096 */

#define CLS_SIZE    20480
#define MAX_CLS     40
#define MAX_CLS_MSG_BYTES  1024 /* not used anywhere yet, parallel to
				   FORTRAN parameter */

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
#define CLPGM_CTL "/usr2/control/clpgm.ctl"

#define FS_SERVER_URL_BASE "ws://127.0.0.1:7083"

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
#define MAX_DBBC_BBC   16
#define MAX_DBBC_IF     4
#define MAX_DBBC_DET    (2*MAX_DBBC_BBC+MAX_DBBC_IF)
#define MAX_DBBC_PFB    64
#define MAX_DBBC_PFB_DET  (MAX_DBBC_PFB+MAX_DBBC_IF)

#define MAX_DBBC3_BBC   128
#define MAX_DBBC3_IF    8     
#define MAX_DBBC3_DET    (2*MAX_DBBC3_BBC+MAX_DBBC3_IF)

/* must be the largest number of detectors possible */
#define MAX_GLOBAL_DET    MAX_DBBC3_DET
#define MAX_ONOFF_DET   (MAX_GLOBAL_DET+MAX_USER_DEV)


#define DEV_VFM     "fm"
#define DEV_VIA     "ia"
#define DEV_VIC     "ic"

#define MAX_HOR   30
#define MAX_RXCODES   40

/* rack/drive, some are also _types.
   Hierarchy: rack/drive, then rack_type/drive_type
   "*_type" must be unqiue within each specific rack or drive */ 
#define DBBC3       0x4000
  /* rack_types: DDCU, DDCV , drive_types: none  */
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
#define DBBC_DDC_FILA10G     0x40000000
#define DBBC_DDC    0x1
#define DBBC_PFB_FILA10G    0x2
#define DBBC_PFB    0x4
#define DBBC3_DDCU  0x1
#define DBBC3_DDCV  0x2
#define DBBC3_DDCE  0x4

/*sub types of VLBA4 rack, like VLBA45 */

#define VLBA4C        0x1
#define VLBA4CDAS     0x2

/* Mark 5 drive_types */

#define MK5A        0x4000000
#define MK5A_BS     0x8000000
#define MK5B        0x40000000
#define MK5B_BS     0x10000000

#define MK5C        0x1
#define MK5C_BS     0x2
#define FLEXBUFF    0x4


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

#define MAX_SKD  18

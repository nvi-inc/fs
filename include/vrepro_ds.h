/* header file for vlba reproduce function data structures */

struct vrepro_cmd {      /* command parameters */
                         /* indices run over channels a(0) and b(1) */
     int mode[2];        /* mode read(0) or byp(1) */
     int track[2];       /* track # 0-35 */
     int head[2];        /* head # 1 or 2 */
     int equalizer[2];   /* equalizer std(0), alt1(1), alt2(2) */
     int bitsynch;       /* 0...5 = 16, 8, 4, 2, 1, 0.5 Mbit/sec */
     };

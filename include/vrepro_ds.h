/* header file for vlba reproduce function data structures */

struct vrepro_cmd {      /* command parameters */
                         /* indices run over channels a(0) and b(1) */
     int mode[2];        /* mode read(0) or byp(1) */
     int track[2];       /* m3 track # 1-28 */
     int equalizer[2];   /* equalizer std(0), alt1(1), alt2(2) */
     };

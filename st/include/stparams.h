/* stparams.h

   This file contains parameters needed by several
   station programs.

   NRV 920311
*/
#define DEBUG 1

#define STM_KEY    2
#define STM_SIZE    8192
#define MAX_PTS   3

#define RUNINT   1   /* run interval for trakl, seconds   */

#define MAX_MODEL_PARAM  20
#define NLINE 5  /* number of model parameters per line */

#define MIN(a,b) ((a < b) ? a : b)
#define MAX(a,b) ((a > b) ? a : b)
#define ATAN2Z(a,b) ((a==0.0 && b==0.0) ? 0.0 : atan2(a,b))

#define NULLPTR (char *) 0

#define ELMIN  9.9   /* Minimum "safe" elevation, degrees */
#define ELPLUS 2.3   /* Additional el or az for safe motion, degrees */

#define PTOL  0.012  /* pointing tolerance, degrees       */
#define TDEGC  0.0   /* default surface temp, degrees C   */
#define RHUM   50.0  /* default surface humidity, %       */
#define BARMB  975.0 /* default pressure, mbars           */

#define SERVICEX 80.0
#define SERVICEY  0.0
#define STOWX     0.021
#define STOWY     0.260

/* header file for holog data structures */

struct satellite_cmd {
  char name[25];        /* name */
  char tlefile[65];     /* tle file name in /usr2/control/tle_files */
  int mode;             /* pointing mode, 0=track, 1=radec, 2=azel */
  int wrap;             /* cable wrap, 0=neutral, 1=ccw, 2=cw */
  int satellite;        /* 1=satellite, 0=source */
  char tle0[25];        /* common name of suucessfully processed satellite */
  char tle1[70];        /* TLE1 of suucessfully processed satellite */
  char tle2[70];        /* TLE2 of suucessfully processed satellite */
};

struct satoff_cmd {
  double seconds;         /* along track offset, in seconds of time */
  double cross;           /* cross track offset, radians */
  int hold;               /* 0=track, 1=hold*/
};

struct satellite_ephem {
  int t;             /* unix time of position, seconds resolution */
  double az;          /* azimuth */
  double el;          /* elevation */
};

struct tle_cmd {
  char tle0[25];      /* common name */
  char tle1[70];      /* TLE Line 1 */
  char tle2[70];      /* TLE Line 1 */
  int catnum[3];     /* catalog number for each line */
};

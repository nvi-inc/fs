
/*  A Bison parser, made from vex.y with Bison version GNU Bison version 1.22
  */

#define YYBISON 1  /* Identify Bison output.  */

#define	T_VEX_REV	258
#define	T_REF	259
#define	T_DEF	260
#define	T_ENDDEF	261
#define	T_CHAN_DEF	262
#define	T_SAMPLE_RATE	263
#define	T_BITS_PER_SAMPLE	264
#define	T_SWITCHING_CYCLE	265
#define	T_START	266
#define	T_SOURCE	267
#define	T_MODE	268
#define	T_STATION	269
#define	T_ANT_DIAM	270
#define	T_AXIS_OFFSET	271
#define	T_ANT_MOTION	272
#define	T_POINTING_SECTOR	273
#define	T_AXIS_TYPE	274
#define	T_BBC_ASSIGN	275
#define	T_CLOCK_EARLY	276
#define	T_CLOCK_EARLY_EPOCH	277
#define	T_CLOCK_RATE	278
#define	T_RECORD_TRANSPORT	279
#define	T_ELECTRONICS_RACK	280
#define	T_NUMBER_DRIVES	281
#define	T_HEADSTACK	282
#define	T_DATA_SOURCE	283
#define	T_RECORD_DENSITY	284
#define	T_TAPE_LENGTH	285
#define	T_RECORDING_SYSTEM_ID	286
#define	T_TAPE_MOTION	287
#define	T_TAPE_CONTROL	288
#define	T_TAI_UTC	289
#define	T_A1_TAI	290
#define	T_EOP_REF_EPOCH	291
#define	T_NUM_EOP_POINTS	292
#define	T_EOP_INTERVAL	293
#define	T_UT1_UTC	294
#define	T_X_WOBBLE	295
#define	T_Y_WOBBLE	296
#define	T_EXPER_NUM	297
#define	T_EXPER_NAME	298
#define	T_EXPER_NOMINAL_START	299
#define	T_EXPER_NOMINAL_STOP	300
#define	T_PI_NAME	301
#define	T_PI_EMAIL	302
#define	T_CONTACT_NAME	303
#define	T_CONTACT_EMAIL	304
#define	T_SCHEDULER_NAME	305
#define	T_SCHEDULER_EMAIL	306
#define	T_TARGET_CORRELATOR	307
#define	T_HEADSTACK_POS	308
#define	T_IF_DEF	309
#define	T_PASS_ORDER	310
#define	T_PCAL_FREQ	311
#define	T_TAPE_CHANGE	312
#define	T_NEW_SOURCE_COMMAND	313
#define	T_NEW_TAPE_SETUP	314
#define	T_SETUP_ALWAYS	315
#define	T_PARITY_CHECK	316
#define	T_TAPE_PREPASS	317
#define	T_PREOB_CAL	318
#define	T_MIDOB_CAL	319
#define	T_POSTOB_CAL	320
#define	T_HEADSTK_MOTION	321
#define	T_REINIT_PERIOD	322
#define	T_INC_PERIOD	323
#define	T_ROLL	324
#define	T_SEFD_MODEL	325
#define	T_SEFD	326
#define	T_SITE_TYPE	327
#define	T_SITE_NAME	328
#define	T_SITE_ID	329
#define	T_SITE_POSITION	330
#define	T_HORIZON_MAP_AZ	331
#define	T_HORIZON_MAP_EL	332
#define	T_ZEN_ATMOS	333
#define	T_OCEAN_LOAD_VERT	334
#define	T_OCEAN_LOAD_HORIZ	335
#define	T_OCCUPATION_CODE	336
#define	T_INCLINATION	337
#define	T_ECCENTRICITY	338
#define	T_ARG_PERIGEE	339
#define	T_ASCENDING_NODE	340
#define	T_MEAN_ANOMALY	341
#define	T_SEMI_MAJOR_AXIS	342
#define	T_MEAN_MOTION	343
#define	T_ORBIT_EPOCH	344
#define	T_SOURCE_TYPE	345
#define	T_SOURCE_NAME	346
#define	T_IAU_NAME	347
#define	T_RA	348
#define	T_DEC	349
#define	T_EPOCH	350
#define	T_SOURCE_POS_REF	351
#define	T_RA_RATE	352
#define	T_DEC_RATE	353
#define	T_VELOCITY_WRT_LSR	354
#define	T_SOURCE_MODEL	355
#define	T_VSN	356
#define	T_FANIN_DEF	357
#define	T_FANOUT_DEF	358
#define	T_TRACK_FRAME_FORMAT	359
#define	T_DATA_MODULATE	360
#define	T_VLBA_FRMTR_SYS_TRK	361
#define	T_VLBA_TRNSPRT_SYS_TRAK	362
#define	T_S2_DATA_DEF	363
#define	B_GLOBAL	364
#define	B_STATION	365
#define	B_MODE	366
#define	B_SCHED	367
#define	B_EXPER	368
#define	B_SCHEDULING_PARMS	369
#define	B_PROC_TIMING	370
#define	B_EOP	371
#define	B_FREQ	372
#define	B_CLOCK	373
#define	B_ANTENNA	374
#define	B_BBC	375
#define	B_CORR	376
#define	B_DAS	377
#define	B_HEAD_POS	378
#define	B_PASS_ORDER	379
#define	B_PHASE_CAL	380
#define	B_ROLL	381
#define	B_IF	382
#define	B_SEFD	383
#define	B_SITE	384
#define	B_SOURCE	385
#define	B_TRACKS	386
#define	B_TAPELOG_OBS	387
#define	T_LITERAL	388
#define	T_NAME	389
#define	T_LINK	390
#define	T_DATE	391
#define	T_DOUBLE	392
#define	T_TIME	393
#define	T_ANGLE	394
#define	T_COMMENT	395
#define	T_COMMENT_TRAILING	396
#define	T_FREQ_UNITS	397
#define	T_SAMPLE_RATE_UNITS	398
#define	T_TIME_UNITS	399
#define	T_LENGTH_UNITS	400
#define	T_VELOCITY_UNITS	401
#define	T_ANGLE_RATE_UNITS	402
#define	T_ANGLE_UNITS	403
#define	T_FLUX_UNITS	404

#line 1 "vex.y"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "vex.h"

#define YYDEBUG 1

/* globals */

struct vex *vex_ptr=NULL;
extern int lines;

#line 16 "vex.y"
typedef union
{
int                     ival;
char                   *sval;
struct llist           *llptr;
struct qref            *qrptr;
struct def             *dfptr;
struct block           *blptr;
struct lowl            *lwptr;
struct dvalue          *dvptr;
struct external        *exptr;

struct chan_def        *cdptr;
struct switching_cycle *scptr;

struct station         *snptr;

struct axis_type       *atptr;
struct ant_motion      *amptr;
struct pointing_sector *psptr;

struct bbc_assign      *baptr;

struct headstack       *hsptr;

struct data_source     *dsptr;
struct tape_motion     *tmptr;

struct headstack_pos   *hpptr;

struct if_def          *ifptr;

struct pcal_freq       *pfptr;

struct setup_always    *saptr;
struct parity_check    *pcptr;
struct tape_prepass    *tpptr;
struct preob_cal       *prptr;
struct midob_cal       *miptr;
struct postob_cal      *poptr;

struct sefd            *septr;

struct site_position   *spptr;
struct ocean_load_vert *ovptr;
struct ocean_load_horiz *ohptr;

struct source_model    *smptr;

struct vsn             *vsptr;

struct fanin_def	*fiptr;
struct fanout_def	*foptr;
struct vlba_frmtr_sys_trk	*fsptr;
struct s2_data_def		*sdptr;

} YYSTYPE;

#ifndef YYLTYPE
typedef
  struct yyltype
    {
      int timestamp;
      int first_line;
      int first_column;
      int last_line;
      int last_column;
      char *text;
   }
  yyltype;

#define YYLTYPE yyltype
#endif

#include <stdio.h>

#ifndef __cplusplus
#ifndef __STDC__
#define const
#endif
#endif



#define	YYFINAL		1337
#define	YYFLAG		-32768
#define	YYNTBASE	153

#define YYTRANSLATE(x) ((unsigned)(x) <= 404 ? yytranslate[x] : 432)

static const short yytranslate[] = {     0,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,   152,   151,     2,
   150,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     1,     2,     3,     4,     5,
     6,     7,     8,     9,    10,    11,    12,    13,    14,    15,
    16,    17,    18,    19,    20,    21,    22,    23,    24,    25,
    26,    27,    28,    29,    30,    31,    32,    33,    34,    35,
    36,    37,    38,    39,    40,    41,    42,    43,    44,    45,
    46,    47,    48,    49,    50,    51,    52,    53,    54,    55,
    56,    57,    58,    59,    60,    61,    62,    63,    64,    65,
    66,    67,    68,    69,    70,    71,    72,    73,    74,    75,
    76,    77,    78,    79,    80,    81,    82,    83,    84,    85,
    86,    87,    88,    89,    90,    91,    92,    93,    94,    95,
    96,    97,    98,    99,   100,   101,   102,   103,   104,   105,
   106,   107,   108,   109,   110,   111,   112,   113,   114,   115,
   116,   117,   118,   119,   120,   121,   122,   123,   124,   125,
   126,   127,   128,   129,   130,   131,   132,   133,   134,   135,
   136,   137,   138,   139,   140,   141,   142,   143,   144,   145,
   146,   147,   148,   149
};

#if YYDEBUG != 0
static const short yyprhs[] = {     0,
     0,     3,     5,     8,    10,    12,    14,    16,    21,    24,
    26,    28,    30,    32,    34,    36,    38,    40,    42,    44,
    46,    48,    50,    52,    54,    56,    58,    60,    62,    64,
    66,    68,    70,    72,    76,    79,    83,    86,    89,    91,
    93,    95,    97,   104,   110,   114,   117,   120,   122,   124,
   126,   128,   135,   141,   144,   146,   148,   150,   152,   158,
   160,   162,   164,   166,   168,   170,   172,   174,   176,   178,
   180,   182,   184,   186,   188,   190,   192,   194,   196,   198,
   205,   206,   209,   212,   214,   216,   218,   220,   227,   233,
   237,   240,   244,   247,   250,   252,   254,   256,   258,   265,
   271,   274,   276,   278,   280,   282,   284,   286,   288,   293,
   298,   303,   320,   321,   323,   324,   326,   327,   329,   330,
   332,   336,   340,   343,   346,   348,   350,   352,   354,   361,
   367,   370,   372,   374,   376,   378,   380,   382,   384,   386,
   388,   393,   400,   405,   414,   431,   435,   438,   441,   443,
   445,   447,   449,   456,   462,   465,   467,   469,   471,   473,
   475,   484,   488,   491,   494,   496,   498,   500,   502,   509,
   515,   518,   520,   522,   524,   526,   528,   530,   532,   537,
   542,   547,   551,   554,   557,   559,   561,   563,   565,   572,
   578,   581,   583,   585,   587,   589,   591,   593,   595,   597,
   599,   601,   603,   605,   607,   609,   614,   619,   624,   633,
   654,   659,   664,   669,   675,   676,   679,   684,   688,   691,
   694,   696,   698,   700,   702,   709,   715,   718,   720,   722,
   724,   726,   728,   730,   732,   734,   736,   738,   740,   742,
   747,   752,   757,   762,   767,   772,   776,   781,   785,   790,
   794,   798,   801,   804,   806,   808,   810,   812,   819,   825,
   828,   830,   832,   834,   836,   838,   840,   842,   844,   846,
   848,   850,   852,   854,   856,   858,   863,   868,   873,   878,
   883,   888,   893,   898,   903,   908,   913,   917,   920,   923,
   925,   927,   929,   931,   938,   944,   947,   949,   951,   953,
   955,   957,   959,   961,   963,   982,  1002,  1020,  1039,  1042,
  1044,  1047,  1052,  1057,  1064,  1068,  1071,  1074,  1076,  1078,
  1080,  1082,  1089,  1095,  1098,  1100,  1102,  1104,  1106,  1108,
  1115,  1119,  1122,  1125,  1127,  1129,  1131,  1133,  1140,  1146,
  1149,  1151,  1153,  1155,  1157,  1159,  1168,  1172,  1175,  1178,
  1180,  1182,  1184,  1186,  1193,  1199,  1202,  1204,  1206,  1208,
  1210,  1212,  1217,  1221,  1224,  1227,  1229,  1231,  1233,  1235,
  1242,  1248,  1251,  1253,  1255,  1257,  1259,  1261,  1272,  1279,
  1283,  1286,  1289,  1291,  1293,  1295,  1297,  1304,  1310,  1313,
  1315,  1317,  1319,  1321,  1323,  1325,  1327,  1329,  1331,  1333,
  1335,  1337,  1339,  1341,  1346,  1351,  1356,  1361,  1368,  1375,
  1382,  1391,  1400,  1409,  1413,  1416,  1419,  1421,  1423,  1425,
  1427,  1434,  1440,  1443,  1445,  1447,  1449,  1451,  1453,  1455,
  1457,  1462,  1467,  1472,  1476,  1479,  1482,  1484,  1486,  1488,
  1490,  1497,  1503,  1506,  1508,  1510,  1512,  1514,  1516,  1520,
  1523,  1526,  1528,  1530,  1532,  1534,  1541,  1547,  1550,  1552,
  1554,  1556,  1558,  1560,  1562,  1567,  1576,  1580,  1583,  1586,
  1588,  1590,  1592,  1594,  1601,  1607,  1610,  1612,  1614,  1616,
  1618,  1620,  1622,  1624,  1626,  1628,  1630,  1632,  1634,  1636,
  1638,  1640,  1642,  1644,  1646,  1648,  1650,  1652,  1654,  1659,
  1664,  1669,  1682,  1687,  1692,  1697,  1704,  1711,  1716,  1721,
  1726,  1731,  1736,  1741,  1746,  1751,  1756,  1760,  1763,  1766,
  1768,  1770,  1772,  1774,  1781,  1787,  1790,  1792,  1794,  1796,
  1798,  1800,  1802,  1804,  1806,  1808,  1810,  1812,  1814,  1816,
  1818,  1820,  1822,  1824,  1826,  1828,  1830,  1832,  1834,  1836,
  1841,  1848,  1853,  1858,  1863,  1868,  1873,  1878,  1883,  1888,
  1893,  1912,  1916,  1919,  1922,  1924,  1926,  1928,  1930,  1937,
  1943,  1946,  1948,  1950,  1952,  1954,  1956,  1967,  1971,  1974,
  1977,  1979,  1981,  1983,  1985,  1992,  1998,  2001,  2003,  2005,
  2007,  2009,  2011,  2013,  2015,  2017,  2019,  2021,  2023,  2034,
  2045,  2050,  2055,  2066,  2075,  2082,  2089,  2095,  2099,  2103,
  2111,  2119,  2122,  2126,  2128,  2132,  2134,  2136,  2138,  2141,
  2145,  2147,  2151,  2153,  2155,  2157,  2160,  2164,  2166,  2170,
  2172,  2174,  2176,  2179,  2183,  2185,  2187,  2190,  2194,  2196,
  2198,  2201,  2204,  2207
};

static const short yyrhs[] = {   154,
   157,     0,   154,     0,   154,   155,     0,   155,     0,   156,
     0,   140,     0,   141,     0,     3,   150,   427,   151,     0,
   157,   158,     0,   158,     0,   159,     0,   160,     0,   164,
     0,   267,     0,   178,     0,   192,     0,   203,     0,   210,
     0,   219,     0,   236,     0,   250,     0,   279,     0,   286,
     0,   293,     0,   300,     0,   307,     0,   323,     0,   332,
     0,   338,     0,   346,     0,   370,     0,   387,     0,   394,
     0,   109,   151,   168,     0,   109,   151,     0,   110,   151,
   161,     0,   110,   151,     0,   161,   162,     0,   162,     0,
   163,     0,   140,     0,   141,     0,     5,   134,   151,   168,
     6,   151,     0,     5,   134,   151,     6,   151,     0,   111,
   151,   165,     0,   111,   151,     0,   165,   166,     0,   166,
     0,   167,     0,   140,     0,   141,     0,     5,   134,   151,
   174,     6,   151,     0,     5,   134,   151,     6,   151,     0,
   168,   169,     0,   169,     0,   170,     0,   140,     0,   141,
     0,     4,   171,   150,   134,   151,     0,   172,     0,   113,
     0,   114,     0,   115,     0,   116,     0,   117,     0,   119,
     0,   120,     0,   121,     0,   122,     0,   123,     0,   124,
     0,   125,     0,   126,     0,   127,     0,   128,     0,   129,
     0,   130,     0,   131,     0,   132,     0,     4,   118,   150,
   134,   173,   151,     0,     0,   152,   134,     0,   174,   175,
     0,   175,     0,   176,     0,   140,     0,   141,     0,     4,
   171,   150,   134,   177,   151,     0,     4,   171,   150,   134,
   151,     0,   177,   152,   134,     0,   152,   134,     0,   112,
   151,   179,     0,   112,   151,     0,   179,   180,     0,   180,
     0,   181,     0,   140,     0,   141,     0,     5,   134,   151,
   182,     6,   151,     0,     5,   134,   151,     6,   151,     0,
   182,   183,     0,   183,     0,   184,     0,   185,     0,   186,
     0,   187,     0,   140,     0,   141,     0,    11,   150,   136,
   151,     0,    13,   150,   134,   151,     0,    12,   150,   134,
   151,     0,    14,   150,   134,   152,   414,   152,   414,   152,
   188,   152,   189,   152,   190,   152,   191,   151,     0,     0,
   422,     0,     0,   134,     0,     0,   135,     0,     0,   427,
     0,   427,   152,   427,     0,   119,   151,   193,     0,   119,
   151,     0,   193,   194,     0,   194,     0,   195,     0,   140,
     0,   141,     0,     5,   134,   151,   196,     6,   151,     0,
     5,   134,   151,     6,   151,     0,   196,   197,     0,   197,
     0,   198,     0,   199,     0,   200,     0,   201,     0,   202,
     0,   409,     0,   140,     0,   141,     0,    15,   150,   422,
   151,     0,    19,   150,   134,   152,   134,   151,     0,    16,
   150,   422,   151,     0,    17,   150,   134,   152,   429,   152,
   414,   151,     0,    18,   150,   135,   152,   134,   152,   418,
   152,   418,   152,   134,   152,   418,   152,   418,   151,     0,
   120,   151,   204,     0,   120,   151,     0,   204,   205,     0,
   205,     0,   206,     0,   140,     0,   141,     0,     5,   134,
   151,   207,     6,   151,     0,     5,   134,   151,     6,   151,
     0,   207,   208,     0,   208,     0,   209,     0,   409,     0,
   140,     0,   141,     0,    20,   150,   135,   152,   427,   152,
   135,   151,     0,   118,   151,   211,     0,   118,   151,     0,
   211,   212,     0,   212,     0,   213,     0,   140,     0,   141,
     0,     5,   134,   151,   214,     6,   151,     0,     5,   134,
   151,     6,   151,     0,   214,   215,     0,   215,     0,   216,
     0,   217,     0,   218,     0,   409,     0,   140,     0,   141,
     0,    21,   150,   414,   151,     0,    22,   150,   136,   151,
     0,    23,   150,   427,   151,     0,   122,   151,   220,     0,
   122,   151,     0,   220,   221,     0,   221,     0,   222,     0,
   140,     0,   141,     0,     5,   134,   151,   223,     6,   151,
     0,     5,   134,   151,     6,   151,     0,   223,   224,     0,
   224,     0,   225,     0,   226,     0,   227,     0,   228,     0,
   229,     0,   230,     0,   231,     0,   232,     0,   233,     0,
   235,     0,   409,     0,   140,     0,   141,     0,    24,   150,
   134,   151,     0,    25,   150,   134,   151,     0,    26,   150,
   427,   151,     0,    27,   150,   427,   152,   134,   152,   135,
   151,     0,    28,   150,   134,   152,   134,   152,   134,   152,
   134,   152,   134,   152,   134,   152,   134,   152,   134,   152,
   134,   151,     0,    29,   150,   427,   151,     0,    30,   150,
   422,   151,     0,    31,   150,   427,   151,     0,    32,   150,
   134,   234,   151,     0,     0,   152,   414,     0,    33,   150,
   134,   151,     0,   116,   151,   237,     0,   116,   151,     0,
   237,   238,     0,   238,     0,   239,     0,   140,     0,   141,
     0,     5,   134,   151,   240,     6,   151,     0,     5,   134,
   151,     6,   151,     0,   240,   241,     0,   241,     0,   242,
     0,   243,     0,   244,     0,   245,     0,   246,     0,   247,
     0,   248,     0,   249,     0,   409,     0,   140,     0,   141,
     0,    34,   150,   414,   151,     0,    35,   150,   414,   151,
     0,    36,   150,   136,   151,     0,    37,   150,   427,   151,
     0,    38,   150,   414,   151,     0,    39,   150,   411,   151,
     0,    39,   150,   151,     0,    40,   150,   415,   151,     0,
    40,   150,   151,     0,    41,   150,   415,   151,     0,    41,
   150,   151,     0,   113,   151,   251,     0,   113,   151,     0,
   251,   252,     0,   252,     0,   253,     0,   140,     0,   141,
     0,     5,   134,   151,   254,     6,   151,     0,     5,   134,
   151,     6,   151,     0,   254,   255,     0,   255,     0,   256,
     0,   257,     0,   258,     0,   259,     0,   260,     0,   261,
     0,   262,     0,   263,     0,   264,     0,   265,     0,   266,
     0,   409,     0,   140,     0,   141,     0,    42,   150,   427,
   151,     0,    43,   150,   134,   151,     0,    44,   150,   136,
   151,     0,    45,   150,   136,   151,     0,    46,   150,   134,
   151,     0,    47,   150,   134,   151,     0,    48,   150,   134,
   151,     0,    49,   150,   134,   151,     0,    50,   150,   134,
   151,     0,    51,   150,   134,   151,     0,    52,   150,   134,
   151,     0,   117,   151,   268,     0,   117,   151,     0,   268,
   269,     0,   269,     0,   270,     0,   140,     0,   141,     0,
     5,   134,   151,   271,     6,   151,     0,     5,   134,   151,
     6,   151,     0,   271,   272,     0,   272,     0,   273,     0,
   276,     0,   277,     0,   278,     0,   409,     0,   140,     0,
   141,     0,     7,   150,   135,   152,   134,   152,   425,   152,
   134,   152,   425,   152,   135,   152,   135,   152,   135,   151,
     0,     7,   150,   135,   152,   134,   152,   425,   152,   134,
   152,   425,   152,   135,   152,   135,   152,   135,   274,   151,
     0,     7,   150,   152,   134,   152,   425,   152,   134,   152,
   425,   152,   135,   152,   135,   152,   135,   151,     0,     7,
   150,   152,   134,   152,   425,   152,   134,   152,   425,   152,
   135,   152,   135,   152,   135,   274,   151,     0,   274,   275,
     0,   275,     0,   152,   427,     0,     8,   150,   430,   151,
     0,     9,   150,   427,   151,     0,    10,   150,   134,   152,
   411,   151,     0,   123,   151,   280,     0,   123,   151,     0,
   280,   281,     0,   281,     0,   282,     0,   140,     0,   141,
     0,     5,   134,   151,   283,     6,   151,     0,     5,   134,
   151,     6,   151,     0,   283,   284,     0,   284,     0,   285,
     0,   409,     0,   140,     0,   141,     0,    53,   150,   427,
   152,   419,   151,     0,   127,   151,   287,     0,   127,   151,
     0,   287,   288,     0,   288,     0,   289,     0,   140,     0,
   141,     0,     5,   134,   151,   290,     6,   151,     0,     5,
   134,   151,     6,   151,     0,   290,   291,     0,   291,     0,
   292,     0,   409,     0,   140,     0,   141,     0,    54,   150,
   135,   152,   425,   152,   134,   151,     0,   124,   151,   294,
     0,   124,   151,     0,   294,   295,     0,   295,     0,   296,
     0,   140,     0,   141,     0,     5,   134,   151,   297,     6,
   151,     0,     5,   134,   151,     6,   151,     0,   297,   298,
     0,   298,     0,   299,     0,   409,     0,   140,     0,   141,
     0,    55,   150,   423,   151,     0,   125,   151,   301,     0,
   125,   151,     0,   301,   302,     0,   302,     0,   303,     0,
   140,     0,   141,     0,     5,   134,   151,   304,     6,   151,
     0,     5,   134,   151,     6,   151,     0,   304,   305,     0,
   305,     0,   306,     0,   409,     0,   140,     0,   141,     0,
    56,   150,   135,   152,   134,   152,   425,   152,   425,   151,
     0,    56,   150,   135,   152,   134,   151,     0,   115,   151,
   308,     0,   115,   151,     0,   308,   309,     0,   309,     0,
   310,     0,   140,     0,   141,     0,     5,   134,   151,   311,
     6,   151,     0,     5,   134,   151,     6,   151,     0,   311,
   312,     0,   312,     0,   313,     0,   314,     0,   315,     0,
   316,     0,   317,     0,   318,     0,   319,     0,   320,     0,
   321,     0,   322,     0,   409,     0,   140,     0,   141,     0,
    57,   150,   414,   151,     0,    66,   150,   414,   151,     0,
    58,   150,   414,   151,     0,    59,   150,   414,   151,     0,
    60,   150,   424,   152,   414,   151,     0,    61,   150,   424,
   152,   414,   151,     0,    62,   150,   424,   152,   414,   151,
     0,    63,   150,   424,   152,   414,   152,   424,   151,     0,
    64,   150,   424,   152,   414,   152,   424,   151,     0,    65,
   150,   424,   152,   414,   152,   424,   151,     0,   126,   151,
   324,     0,   126,   151,     0,   324,   325,     0,   325,     0,
   326,     0,   140,     0,   141,     0,     5,   134,   151,   327,
     6,   151,     0,     5,   134,   151,     6,   151,     0,   327,
   328,     0,   328,     0,   329,     0,   330,     0,   331,     0,
   409,     0,   140,     0,   141,     0,    67,   150,   414,   151,
     0,    68,   150,   427,   151,     0,    69,   150,   426,   151,
     0,   114,   151,   333,     0,   114,   151,     0,   333,   334,
     0,   334,     0,   335,     0,   140,     0,   141,     0,     5,
   134,   151,   336,     6,   151,     0,     5,   134,   151,     6,
   151,     0,   336,   337,     0,   337,     0,   409,     0,   410,
     0,   140,     0,   141,     0,   128,   151,   339,     0,   128,
   151,     0,   339,   340,     0,   340,     0,   341,     0,   140,
     0,   141,     0,     5,   134,   151,   342,     6,   151,     0,
     5,   134,   151,     6,   151,     0,   342,   343,     0,   343,
     0,   344,     0,   345,     0,   409,     0,   140,     0,   141,
     0,    70,   150,   134,   151,     0,    71,   150,   135,   152,
   428,   152,   426,   151,     0,   129,   151,   347,     0,   129,
   151,     0,   347,   348,     0,   348,     0,   349,     0,   140,
     0,   141,     0,     5,   134,   151,   350,     6,   151,     0,
     5,   134,   151,     6,   151,     0,   350,   351,     0,   351,
     0,   352,     0,   353,     0,   354,     0,   355,     0,   356,
     0,   357,     0,   358,     0,   359,     0,   360,     0,   361,
     0,   362,     0,   363,     0,   364,     0,   365,     0,   366,
     0,   367,     0,   368,     0,   369,     0,   409,     0,   140,
     0,   141,     0,    72,   150,   134,   151,     0,    73,   150,
   134,   151,     0,    74,   150,   134,   151,     0,    75,   150,
   422,   152,   422,   152,   422,   152,   427,   152,   134,   151,
     0,    76,   150,   415,   151,     0,    77,   150,   415,   151,
     0,    78,   150,   414,   151,     0,    79,   150,   422,   152,
   418,   151,     0,    80,   150,   422,   152,   418,   151,     0,
    81,   150,   424,   151,     0,    82,   150,   418,   151,     0,
    83,   150,   427,   151,     0,    84,   150,   418,   151,     0,
    85,   150,   418,   151,     0,    86,   150,   418,   151,     0,
    87,   150,   422,   151,     0,    88,   150,   427,   151,     0,
    89,   150,   136,   151,     0,   130,   151,   371,     0,   130,
   151,     0,   371,   372,     0,   372,     0,   373,     0,   140,
     0,   141,     0,     5,   134,   151,   374,     6,   151,     0,
     5,   134,   151,     6,   151,     0,   374,   375,     0,   375,
     0,   376,     0,   377,     0,   378,     0,   379,     0,   380,
     0,   381,     0,   382,     0,   383,     0,   384,     0,   385,
     0,   386,     0,   362,     0,   363,     0,   364,     0,   365,
     0,   366,     0,   367,     0,   368,     0,   369,     0,   409,
     0,   140,     0,   141,     0,    90,   150,   134,   151,     0,
    90,   150,   134,   152,   134,   151,     0,    91,   150,   134,
   151,     0,    92,   150,   134,   151,     0,    93,   150,   138,
   151,     0,    94,   150,   139,   151,     0,    95,   150,   134,
   151,     0,    96,   150,   134,   151,     0,    97,   150,   429,
   151,     0,    98,   150,   429,   151,     0,    99,   150,   431,
   151,     0,   100,   150,   427,   152,   135,   152,   428,   152,
   418,   152,   427,   152,   418,   152,   418,   152,   418,   151,
     0,   132,   151,   388,     0,   132,   151,     0,   388,   389,
     0,   389,     0,   390,     0,   140,     0,   141,     0,     5,
   134,   151,   391,     6,   151,     0,     5,   134,   151,     6,
   151,     0,   391,   392,     0,   392,     0,   393,     0,   409,
     0,   140,     0,   141,     0,   101,   150,   427,   152,   134,
   152,   136,   152,   136,   151,     0,   131,   151,   395,     0,
   131,   151,     0,   395,   396,     0,   396,     0,   397,     0,
   140,     0,   141,     0,     5,   134,   151,   398,     6,   151,
     0,     5,   134,   151,     6,   151,     0,   398,   399,     0,
   399,     0,   400,     0,   401,     0,   402,     0,   403,     0,
   404,     0,   405,     0,   406,     0,   409,     0,   140,     0,
   141,     0,   102,   150,   134,   152,   427,   152,   427,   152,
   407,   151,     0,   103,   150,   134,   152,   407,   152,   427,
   152,   426,   151,     0,   104,   150,   134,   151,     0,   105,
   150,   134,   151,     0,   106,   150,   427,   152,   134,   152,
   427,   152,   427,   151,     0,   106,   150,   427,   152,   134,
   152,   427,   151,     0,   107,   150,   427,   152,   427,   151,
     0,   108,   150,   408,   152,   134,   151,     0,   407,   152,
   135,   152,   134,     0,   135,   152,   134,     0,   135,   152,
   134,     0,     4,   134,   152,   171,   150,   134,   151,     0,
     4,   134,   152,   118,   150,   134,   151,     0,   133,   151,
     0,   414,   152,   412,     0,   414,     0,   412,   152,   413,
     0,   413,     0,   414,     0,   427,     0,   137,   144,     0,
   418,   152,   416,     0,   418,     0,   416,   152,   417,     0,
   417,     0,   418,     0,   427,     0,   137,   148,     0,   422,
   152,   420,     0,   422,     0,   420,   152,   421,     0,   421,
     0,   422,     0,   427,     0,   137,   145,     0,   423,   152,
   424,     0,   424,     0,   134,     0,   137,   142,     0,   426,
   152,   427,     0,   427,     0,   137,     0,   137,   149,     0,
   137,   147,     0,   137,   143,     0,   137,   146,     0
};

#endif

#if YYDEBUG != 0
static const short yyrline[] = { 0,
   323,   324,   326,   327,   329,   330,   331,   335,   340,   341,
   343,   344,   345,   346,   347,   348,   349,   350,   351,   352,
   353,   354,   355,   356,   357,   358,   359,   360,   362,   363,
   364,   365,   366,   370,   371,   375,   376,   378,   379,   381,
   382,   383,   385,   386,   390,   391,   393,   394,   396,   397,
   398,   400,   401,   406,   407,   409,   410,   411,   413,   414,
   416,   417,   418,   419,   420,   421,   422,   423,   424,   425,
   426,   427,   428,   429,   430,   431,   432,   433,   434,   436,
   438,   439,   441,   442,   444,   445,   446,   448,   449,   451,
   452,   456,   457,   459,   460,   462,   463,   464,   466,   468,
   470,   471,   473,   474,   475,   476,   477,   478,   480,   482,
   484,   486,   495,   496,   498,   499,   501,   502,   504,   505,
   506,   510,   511,   513,   514,   516,   517,   518,   520,   522,
   524,   525,   527,   528,   529,   530,   531,   532,   533,   534,
   536,   538,   541,   543,   548,   559,   560,   562,   563,   565,
   566,   567,   569,   570,   573,   574,   576,   577,   578,   579,
   581,   586,   587,   589,   590,   592,   593,   594,   596,   598,
   601,   602,   604,   605,   607,   608,   609,   610,   612,   614,
   616,   620,   621,   623,   624,   626,   627,   628,   630,   631,
   634,   635,   637,   638,   639,   640,   641,   642,   643,   644,
   646,   647,   648,   649,   650,   652,   654,   656,   658,   661,
   665,   667,   669,   671,   674,   675,   677,   681,   682,   684,
   685,   687,   688,   689,   691,   692,   695,   696,   698,   699,
   700,   701,   702,   703,   704,   705,   706,   707,   708,   710,
   712,   714,   716,   718,   720,   721,   723,   724,   726,   727,
   731,   732,   734,   735,   737,   738,   739,   741,   743,   745,
   746,   748,   749,   750,   752,   754,   755,   756,   757,   758,
   759,   760,   762,   763,   764,   766,   768,   770,   772,   774,
   776,   778,   780,   782,   784,   786,   790,   791,   793,   794,
   796,   797,   798,   800,   801,   804,   805,   807,   808,   809,
   810,   811,   812,   813,   815,   824,   833,   842,   852,   853,
   855,   857,   859,   861,   866,   867,   869,   870,   872,   873,
   874,   876,   878,   881,   882,   884,   885,   886,   887,   889,
   894,   895,   897,   898,   900,   901,   902,   904,   905,   908,
   909,   911,   912,   913,   914,   916,   921,   922,   924,   925,
   928,   929,   930,   932,   934,   937,   939,   941,   942,   943,
   944,   946,   950,   951,   953,   954,   956,   957,   958,   960,
   962,   964,   965,   967,   968,   969,   970,   972,   975,   980,
   981,   983,   985,   987,   988,   989,   991,   993,   996,   998,
  1000,  1002,  1004,  1006,  1008,  1010,  1012,  1014,  1016,  1018,
  1020,  1021,  1022,  1024,  1026,  1028,  1030,  1032,  1035,  1038,
  1041,  1044,  1047,  1052,  1053,  1055,  1056,  1058,  1059,  1060,
  1062,  1064,  1067,  1068,  1070,  1071,  1072,  1073,  1074,  1075,
  1077,  1079,  1081,  1085,  1087,  1089,  1091,  1094,  1095,  1096,
  1098,  1100,  1103,  1105,  1108,  1109,  1110,  1111,  1115,  1116,
  1118,  1119,  1121,  1122,  1123,  1125,  1127,  1130,  1131,  1133,
  1134,  1135,  1136,  1137,  1139,  1141,  1146,  1147,  1149,  1150,
  1152,  1153,  1154,  1156,  1158,  1160,  1161,  1163,  1164,  1165,
  1166,  1167,  1168,  1169,  1170,  1171,  1172,  1173,  1174,  1175,
  1176,  1177,  1178,  1179,  1180,  1181,  1182,  1183,  1185,  1187,
  1189,  1191,  1195,  1197,  1199,  1201,  1205,  1209,  1211,  1213,
  1215,  1217,  1219,  1221,  1223,  1225,  1229,  1230,  1232,  1233,
  1235,  1236,  1237,  1239,  1241,  1244,  1245,  1247,  1248,  1249,
  1250,  1251,  1252,  1253,  1254,  1255,  1256,  1257,  1258,  1259,
  1260,  1261,  1262,  1263,  1264,  1265,  1266,  1267,  1268,  1270,
  1271,  1274,  1276,  1278,  1280,  1282,  1284,  1286,  1288,  1290,
  1293,  1305,  1306,  1308,  1310,  1312,  1313,  1314,  1317,  1319,
  1322,  1324,  1326,  1327,  1328,  1329,  1332,  1337,  1338,  1340,
  1341,  1343,  1344,  1345,  1347,  1349,  1352,  1353,  1355,  1356,
  1357,  1359,  1360,  1362,  1364,  1365,  1366,  1367,  1369,  1372,
  1376,  1378,  1380,  1383,  1387,  1390,  1393,  1395,  1398,  1402,
  1404,  1407,  1409,  1410,  1412,  1413,  1415,  1416,  1418,  1420,
  1421,  1423,  1424,  1426,  1427,  1429,  1432,  1433,  1435,  1436,
  1438,  1439,  1441,  1443,  1444,  1446,  1448,  1450,  1451,  1453,
  1455,  1457,  1460,  1462
};

static const char * const yytname[] = {   "$","error","$illegal.","T_VEX_REV",
"T_REF","T_DEF","T_ENDDEF","T_CHAN_DEF","T_SAMPLE_RATE","T_BITS_PER_SAMPLE",
"T_SWITCHING_CYCLE","T_START","T_SOURCE","T_MODE","T_STATION","T_ANT_DIAM","T_AXIS_OFFSET",
"T_ANT_MOTION","T_POINTING_SECTOR","T_AXIS_TYPE","T_BBC_ASSIGN","T_CLOCK_EARLY",
"T_CLOCK_EARLY_EPOCH","T_CLOCK_RATE","T_RECORD_TRANSPORT","T_ELECTRONICS_RACK",
"T_NUMBER_DRIVES","T_HEADSTACK","T_DATA_SOURCE","T_RECORD_DENSITY","T_TAPE_LENGTH",
"T_RECORDING_SYSTEM_ID","T_TAPE_MOTION","T_TAPE_CONTROL","T_TAI_UTC","T_A1_TAI",
"T_EOP_REF_EPOCH","T_NUM_EOP_POINTS","T_EOP_INTERVAL","T_UT1_UTC","T_X_WOBBLE",
"T_Y_WOBBLE","T_EXPER_NUM","T_EXPER_NAME","T_EXPER_NOMINAL_START","T_EXPER_NOMINAL_STOP",
"T_PI_NAME","T_PI_EMAIL","T_CONTACT_NAME","T_CONTACT_EMAIL","T_SCHEDULER_NAME",
"T_SCHEDULER_EMAIL","T_TARGET_CORRELATOR","T_HEADSTACK_POS","T_IF_DEF","T_PASS_ORDER",
"T_PCAL_FREQ","T_TAPE_CHANGE","T_NEW_SOURCE_COMMAND","T_NEW_TAPE_SETUP","T_SETUP_ALWAYS",
"T_PARITY_CHECK","T_TAPE_PREPASS","T_PREOB_CAL","T_MIDOB_CAL","T_POSTOB_CAL",
"T_HEADSTK_MOTION","T_REINIT_PERIOD","T_INC_PERIOD","T_ROLL","T_SEFD_MODEL",
"T_SEFD","T_SITE_TYPE","T_SITE_NAME","T_SITE_ID","T_SITE_POSITION","T_HORIZON_MAP_AZ",
"T_HORIZON_MAP_EL","T_ZEN_ATMOS","T_OCEAN_LOAD_VERT","T_OCEAN_LOAD_HORIZ","T_OCCUPATION_CODE",
"T_INCLINATION","T_ECCENTRICITY","T_ARG_PERIGEE","T_ASCENDING_NODE","T_MEAN_ANOMALY",
"T_SEMI_MAJOR_AXIS","T_MEAN_MOTION","T_ORBIT_EPOCH","T_SOURCE_TYPE","T_SOURCE_NAME",
"T_IAU_NAME","T_RA","T_DEC","T_EPOCH","T_SOURCE_POS_REF","T_RA_RATE","T_DEC_RATE",
"T_VELOCITY_WRT_LSR","T_SOURCE_MODEL","T_VSN","T_FANIN_DEF","T_FANOUT_DEF","T_TRACK_FRAME_FORMAT",
"T_DATA_MODULATE","T_VLBA_FRMTR_SYS_TRK","T_VLBA_TRNSPRT_SYS_TRAK","T_S2_DATA_DEF",
"B_GLOBAL","B_STATION","B_MODE","B_SCHED","B_EXPER","B_SCHEDULING_PARMS","B_PROC_TIMING",
"B_EOP","B_FREQ","B_CLOCK","B_ANTENNA","B_BBC","B_CORR","B_DAS","B_HEAD_POS",
"B_PASS_ORDER","B_PHASE_CAL","B_ROLL","B_IF","B_SEFD","B_SITE","B_SOURCE","B_TRACKS",
"B_TAPELOG_OBS","T_LITERAL","T_NAME","T_LINK","T_DATE","T_DOUBLE","T_TIME","T_ANGLE",
"T_COMMENT","T_COMMENT_TRAILING","T_FREQ_UNITS","T_SAMPLE_RATE_UNITS","T_TIME_UNITS",
"T_LENGTH_UNITS","T_VELOCITY_UNITS","T_ANGLE_RATE_UNITS","T_ANGLE_UNITS","T_FLUX_UNITS",
"'='","';'","':'","vex","version_lowls","version_lowl","version","blocks","block",
"global_block","station_block","station_defs","station_defx","station_def","mode_block",
"mode_defs","mode_defx","mode_def","refs","refx","ref","primitive","cref","date",
"qrefs","qrefx","qref","qualifiers","sched_block","sched_defs","sched_defx",
"sched_def","sched_lowls","sched_lowl","start","mode","source","station","start_position",
"pass","sector","drives","antenna_block","antenna_defs","antenna_defx","antenna_def",
"antenna_lowls","antenna_lowl","ant_diam","axis_type","axis_offset","ant_motion",
"pointing_sector","bbc_block","bbc_defs","bbc_defx","bbc_def","bbc_lowls","bbc_lowl",
"bbc_assign","clock_block","clock_defs","clock_defx","clock_def","clock_lowls",
"clock_lowl","clock_early","clock_early_epoch","clock_rate","das_block","das_defs",
"das_defx","das_def","das_lowls","das_lowl","record_transport","electronics_rack",
"number_drives","headstack","data_source","record_density","tape_length","recording_system_id",
"tape_motion","early_start","tape_control","eop_block","eop_defs","eop_defx",
"eop_def","eop_lowls","eop_lowl","tai_utc","a1_tai","eop_ref_epoch","num_eop_points",
"eop_interval","ut1_utc","x_wobble","y_wobble","exper_block","exper_defs","exper_defx",
"exper_def","exper_lowls","exper_lowl","exper_num","exper_name","exper_nominal_start",
"exper_nominal_stop","pi_name","pi_email","contact_name","contact_email","scheduler_name",
"scheduler_email","target_correlator","freq_block","freq_defs","freq_defx","freq_def",
"freq_lowls","freq_lowl","chan_def","switch_states","switch_state","sample_rate",
"bits_per_sample","switching_cycle","head_pos_block","head_pos_defs","head_pos_defx",
"head_pos_def","head_pos_lowls","head_pos_lowl","headstack_pos","if_block","if_defs",
"if_defx","if_def","if_lowls","if_lowl","if_def_st","pass_order_block","pass_order_defs",
"pass_order_defx","pass_order_def","pass_order_lowls","pass_order_lowl","pass_order",
"phase_cal_block","phase_cal_defs","phase_cal_defx","phase_cal_def","phase_cal_lowls",
"phase_cal_lowl","pcal_freq","proc_timing_block","proc_timing_defs","proc_timing_defx",
"proc_timing_def","proc_timing_lowls","proc_timing_lowl","tape_change","headstk_motion",
"new_source_command","new_tape_setup","setup_always","parity_check","tape_prepass",
"preob_cal","midob_cal","postob_cal","roll_block","roll_defs","roll_defx","roll_def",
"roll_lowls","roll_lowl","reinit_period","inc_period","roll","scheduling_parms_block",
"scheduling_parms_defs","scheduling_parms_defx","scheduling_parms_def","scheduling_parms_lowls",
"scheduling_parms_lowl","sefd_block","sefd_defs","sefd_defx","sefd_def","sefd_lowls",
"sefd_lowl","sefd_model","sefd","site_block","site_defs","site_defx","site_def",
"site_lowls","site_lowl","site_type","site_name","site_id","site_position","horizon_map_az",
"horizon_map_el","zen_atmos","ocean_load_vert","ocean_load_horiz","occupation_code",
"inclination","eccentricity","arg_perigee","ascending_node","mean_anomaly","semi_major_axis",
"mean_motion","orbit_epoch","source_block","source_defs","source_defx","source_def",
"source_lowls","source_lowl","source_type","source_name","iau_name","ra","dec",
"epoch","source_pos_ref","ra_rate","dec_rate","velocity_wrt_lsr","source_model",
"tapelog_obs_block","tapelog_obs_defs","tapelog_obs_defx","tapelog_obs_def",
"tapelog_obs_lowls","tapelog_obs_lowl","vsn","tracks_block","tracks_defs","tracks_defx",
"tracks_def","tracks_lowls","tracks_lowl","fanin_def","fanout_def","track_frame_format",
"data_modulate","vlba_frmtr_sys_trk","vlba_trnsprt_sys_trak","s2_data_def","bit_stream_list",
"bit_stream","external_ref","literal","time_list","time_more","time_option",
"time_value","angle_list","angle_more","angle_option","angle_value","length_list",
"length_more","length_option","length_value","name_list","name_value","freq_value",
"value_list","value","flux_value","angle_rate_value","sample_rate_value","velocity_value",
""
};
#endif

static const short yyr1[] = {     0,
   153,   153,   154,   154,   155,   155,   155,   156,   157,   157,
   158,   158,   158,   158,   158,   158,   158,   158,   158,   158,
   158,   158,   158,   158,   158,   158,   158,   158,   158,   158,
   158,   158,   158,   159,   159,   160,   160,   161,   161,   162,
   162,   162,   163,   163,   164,   164,   165,   165,   166,   166,
   166,   167,   167,   168,   168,   169,   169,   169,   170,   170,
   171,   171,   171,   171,   171,   171,   171,   171,   171,   171,
   171,   171,   171,   171,   171,   171,   171,   171,   171,   172,
   173,   173,   174,   174,   175,   175,   175,   176,   176,   177,
   177,   178,   178,   179,   179,   180,   180,   180,   181,   181,
   182,   182,   183,   183,   183,   183,   183,   183,   184,   185,
   186,   187,   188,   188,   189,   189,   190,   190,   191,   191,
   191,   192,   192,   193,   193,   194,   194,   194,   195,   195,
   196,   196,   197,   197,   197,   197,   197,   197,   197,   197,
   198,   199,   200,   201,   202,   203,   203,   204,   204,   205,
   205,   205,   206,   206,   207,   207,   208,   208,   208,   208,
   209,   210,   210,   211,   211,   212,   212,   212,   213,   213,
   214,   214,   215,   215,   215,   215,   215,   215,   216,   217,
   218,   219,   219,   220,   220,   221,   221,   221,   222,   222,
   223,   223,   224,   224,   224,   224,   224,   224,   224,   224,
   224,   224,   224,   224,   224,   225,   226,   227,   228,   229,
   230,   231,   232,   233,   234,   234,   235,   236,   236,   237,
   237,   238,   238,   238,   239,   239,   240,   240,   241,   241,
   241,   241,   241,   241,   241,   241,   241,   241,   241,   242,
   243,   244,   245,   246,   247,   247,   248,   248,   249,   249,
   250,   250,   251,   251,   252,   252,   252,   253,   253,   254,
   254,   255,   255,   255,   255,   255,   255,   255,   255,   255,
   255,   255,   255,   255,   255,   256,   257,   258,   259,   260,
   261,   262,   263,   264,   265,   266,   267,   267,   268,   268,
   269,   269,   269,   270,   270,   271,   271,   272,   272,   272,
   272,   272,   272,   272,   273,   273,   273,   273,   274,   274,
   275,   276,   277,   278,   279,   279,   280,   280,   281,   281,
   281,   282,   282,   283,   283,   284,   284,   284,   284,   285,
   286,   286,   287,   287,   288,   288,   288,   289,   289,   290,
   290,   291,   291,   291,   291,   292,   293,   293,   294,   294,
   295,   295,   295,   296,   296,   297,   297,   298,   298,   298,
   298,   299,   300,   300,   301,   301,   302,   302,   302,   303,
   303,   304,   304,   305,   305,   305,   305,   306,   306,   307,
   307,   308,   308,   309,   309,   309,   310,   310,   311,   311,
   312,   312,   312,   312,   312,   312,   312,   312,   312,   312,
   312,   312,   312,   313,   314,   315,   316,   317,   318,   319,
   320,   321,   322,   323,   323,   324,   324,   325,   325,   325,
   326,   326,   327,   327,   328,   328,   328,   328,   328,   328,
   329,   330,   331,   332,   332,   333,   333,   334,   334,   334,
   335,   335,   336,   336,   337,   337,   337,   337,   338,   338,
   339,   339,   340,   340,   340,   341,   341,   342,   342,   343,
   343,   343,   343,   343,   344,   345,   346,   346,   347,   347,
   348,   348,   348,   349,   349,   350,   350,   351,   351,   351,
   351,   351,   351,   351,   351,   351,   351,   351,   351,   351,
   351,   351,   351,   351,   351,   351,   351,   351,   352,   353,
   354,   355,   356,   357,   358,   359,   360,   361,   362,   363,
   364,   365,   366,   367,   368,   369,   370,   370,   371,   371,
   372,   372,   372,   373,   373,   374,   374,   375,   375,   375,
   375,   375,   375,   375,   375,   375,   375,   375,   375,   375,
   375,   375,   375,   375,   375,   375,   375,   375,   375,   376,
   376,   377,   378,   379,   380,   381,   382,   383,   384,   385,
   386,   387,   387,   388,   388,   389,   389,   389,   390,   390,
   391,   391,   392,   392,   392,   392,   393,   394,   394,   395,
   395,   396,   396,   396,   397,   397,   398,   398,   399,   399,
   399,   399,   399,   399,   399,   399,   399,   399,   400,   401,
   402,   403,   404,   404,   405,   406,   407,   407,   408,   409,
   409,   410,   411,   411,   412,   412,   413,   413,   414,   415,
   415,   416,   416,   417,   417,   418,   419,   419,   420,   420,
   421,   421,   422,   423,   423,   424,   425,   426,   426,   427,
   428,   429,   430,   431
};

static const short yyr2[] = {     0,
     2,     1,     2,     1,     1,     1,     1,     4,     2,     1,
     1,     1,     1,     1,     1,     1,     1,     1,     1,     1,
     1,     1,     1,     1,     1,     1,     1,     1,     1,     1,
     1,     1,     1,     3,     2,     3,     2,     2,     1,     1,
     1,     1,     6,     5,     3,     2,     2,     1,     1,     1,
     1,     6,     5,     2,     1,     1,     1,     1,     5,     1,
     1,     1,     1,     1,     1,     1,     1,     1,     1,     1,
     1,     1,     1,     1,     1,     1,     1,     1,     1,     6,
     0,     2,     2,     1,     1,     1,     1,     6,     5,     3,
     2,     3,     2,     2,     1,     1,     1,     1,     6,     5,
     2,     1,     1,     1,     1,     1,     1,     1,     4,     4,
     4,    16,     0,     1,     0,     1,     0,     1,     0,     1,
     3,     3,     2,     2,     1,     1,     1,     1,     6,     5,
     2,     1,     1,     1,     1,     1,     1,     1,     1,     1,
     4,     6,     4,     8,    16,     3,     2,     2,     1,     1,
     1,     1,     6,     5,     2,     1,     1,     1,     1,     1,
     8,     3,     2,     2,     1,     1,     1,     1,     6,     5,
     2,     1,     1,     1,     1,     1,     1,     1,     4,     4,
     4,     3,     2,     2,     1,     1,     1,     1,     6,     5,
     2,     1,     1,     1,     1,     1,     1,     1,     1,     1,
     1,     1,     1,     1,     1,     4,     4,     4,     8,    20,
     4,     4,     4,     5,     0,     2,     4,     3,     2,     2,
     1,     1,     1,     1,     6,     5,     2,     1,     1,     1,
     1,     1,     1,     1,     1,     1,     1,     1,     1,     4,
     4,     4,     4,     4,     4,     3,     4,     3,     4,     3,
     3,     2,     2,     1,     1,     1,     1,     6,     5,     2,
     1,     1,     1,     1,     1,     1,     1,     1,     1,     1,
     1,     1,     1,     1,     1,     4,     4,     4,     4,     4,
     4,     4,     4,     4,     4,     4,     3,     2,     2,     1,
     1,     1,     1,     6,     5,     2,     1,     1,     1,     1,
     1,     1,     1,     1,    18,    19,    17,    18,     2,     1,
     2,     4,     4,     6,     3,     2,     2,     1,     1,     1,
     1,     6,     5,     2,     1,     1,     1,     1,     1,     6,
     3,     2,     2,     1,     1,     1,     1,     6,     5,     2,
     1,     1,     1,     1,     1,     8,     3,     2,     2,     1,
     1,     1,     1,     6,     5,     2,     1,     1,     1,     1,
     1,     4,     3,     2,     2,     1,     1,     1,     1,     6,
     5,     2,     1,     1,     1,     1,     1,    10,     6,     3,
     2,     2,     1,     1,     1,     1,     6,     5,     2,     1,
     1,     1,     1,     1,     1,     1,     1,     1,     1,     1,
     1,     1,     1,     4,     4,     4,     4,     6,     6,     6,
     8,     8,     8,     3,     2,     2,     1,     1,     1,     1,
     6,     5,     2,     1,     1,     1,     1,     1,     1,     1,
     4,     4,     4,     3,     2,     2,     1,     1,     1,     1,
     6,     5,     2,     1,     1,     1,     1,     1,     3,     2,
     2,     1,     1,     1,     1,     6,     5,     2,     1,     1,
     1,     1,     1,     1,     4,     8,     3,     2,     2,     1,
     1,     1,     1,     6,     5,     2,     1,     1,     1,     1,
     1,     1,     1,     1,     1,     1,     1,     1,     1,     1,
     1,     1,     1,     1,     1,     1,     1,     1,     4,     4,
     4,    12,     4,     4,     4,     6,     6,     4,     4,     4,
     4,     4,     4,     4,     4,     4,     3,     2,     2,     1,
     1,     1,     1,     6,     5,     2,     1,     1,     1,     1,
     1,     1,     1,     1,     1,     1,     1,     1,     1,     1,
     1,     1,     1,     1,     1,     1,     1,     1,     1,     4,
     6,     4,     4,     4,     4,     4,     4,     4,     4,     4,
    18,     3,     2,     2,     1,     1,     1,     1,     6,     5,
     2,     1,     1,     1,     1,     1,    10,     3,     2,     2,
     1,     1,     1,     1,     6,     5,     2,     1,     1,     1,
     1,     1,     1,     1,     1,     1,     1,     1,    10,    10,
     4,     4,    10,     8,     6,     6,     5,     3,     3,     7,
     7,     2,     3,     1,     3,     1,     1,     1,     2,     3,
     1,     3,     1,     1,     1,     2,     3,     1,     3,     1,
     1,     1,     2,     3,     1,     1,     2,     3,     1,     1,
     2,     2,     2,     2
};

static const short yydefact[] = {     0,
     0,     6,     7,     2,     4,     5,     0,     0,     0,     0,
     0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
     0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
     3,     1,    10,    11,    12,    13,    15,    16,    17,    18,
    19,    20,    21,    14,    22,    23,    24,    25,    26,    27,
    28,    29,    30,    31,    32,    33,   640,     0,    35,    37,
    46,    93,   252,   435,   381,   219,   288,   163,   123,   147,
   183,   316,   348,   364,   415,   332,   450,   468,   518,   579,
   563,     9,     8,     0,    57,    58,    34,    55,    56,    60,
     0,    41,    42,    36,    39,    40,     0,    50,    51,    45,
    48,    49,     0,    97,    98,    92,    95,    96,     0,   256,
   257,   251,   254,   255,     0,   439,   440,   434,   437,   438,
     0,   385,   386,   380,   383,   384,     0,   223,   224,   218,
   221,   222,     0,   292,   293,   287,   290,   291,     0,   167,
   168,   162,   165,   166,     0,   127,   128,   122,   125,   126,
     0,   151,   152,   146,   149,   150,     0,   187,   188,   182,
   185,   186,     0,   320,   321,   315,   318,   319,     0,   352,
   353,   347,   350,   351,     0,   368,   369,   363,   366,   367,
     0,   419,   420,   414,   417,   418,     0,   336,   337,   331,
   334,   335,     0,   454,   455,   449,   452,   453,     0,   472,
   473,   467,   470,   471,     0,   522,   523,   517,   520,   521,
     0,   583,   584,   578,   581,   582,     0,   567,   568,   562,
   565,   566,    61,    62,    63,    64,    65,     0,    66,    67,
    68,    69,    70,    71,    72,    73,    74,    75,    76,    77,
    78,    79,     0,    54,     0,    38,     0,    47,     0,    94,
     0,   253,     0,   436,     0,   382,     0,   220,     0,   289,
     0,   164,     0,   124,     0,   148,     0,   184,     0,   317,
     0,   349,     0,   365,     0,   416,     0,   333,     0,   451,
     0,   469,     0,   519,     0,   580,     0,   564,     0,     0,
     0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
     0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
     0,     0,    81,     0,     0,     0,     0,     0,    86,    87,
     0,    84,    85,     0,     0,     0,     0,     0,   107,   108,
     0,   102,   103,   104,   105,   106,     0,     0,     0,     0,
     0,     0,     0,     0,     0,     0,     0,     0,     0,   274,
   275,     0,   261,   262,   263,   264,   265,   266,   267,   268,
   269,   270,   271,   272,   273,     0,     0,   447,   448,     0,
   444,   445,   446,     0,     0,     0,     0,     0,     0,     0,
     0,     0,     0,     0,   402,   403,     0,   390,   391,   392,
   393,   394,   395,   396,   397,   398,   399,   400,   401,     0,
     0,     0,     0,     0,     0,     0,     0,     0,   238,   239,
     0,   228,   229,   230,   231,   232,   233,   234,   235,   236,
   237,     0,     0,     0,     0,     0,   303,   304,     0,   297,
   298,   299,   300,   301,   302,     0,     0,     0,     0,   177,
   178,     0,   172,   173,   174,   175,   176,     0,     0,     0,
     0,     0,     0,   139,   140,     0,   132,   133,   134,   135,
   136,   137,   138,     0,     0,   159,   160,     0,   156,   157,
   158,     0,     0,     0,     0,     0,     0,     0,     0,     0,
     0,     0,   204,   205,     0,   192,   193,   194,   195,   196,
   197,   198,   199,   200,   201,   202,   203,     0,     0,   328,
   329,     0,   325,   326,   327,     0,     0,   360,   361,     0,
   357,   358,   359,     0,     0,   376,   377,     0,   373,   374,
   375,     0,     0,     0,     0,   429,   430,     0,   424,   425,
   426,   427,   428,     0,     0,   344,   345,     0,   341,   342,
   343,     0,     0,     0,   463,   464,     0,   459,   460,   461,
   462,     0,     0,     0,     0,     0,     0,     0,     0,     0,
     0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
   497,   498,     0,   477,   478,   479,   480,   481,   482,   483,
   484,   485,   486,   487,   488,   489,   490,   491,   492,   493,
   494,   495,   496,     0,     0,     0,     0,     0,     0,     0,
     0,     0,     0,     0,     0,   548,   549,   539,   540,   541,
   542,   543,   544,   545,   546,     0,   527,   528,   529,   530,
   531,   532,   533,   534,   535,   536,   537,   538,   547,     0,
     0,     0,     0,     0,     0,     0,     0,   597,   598,     0,
   588,   589,   590,   591,   592,   593,   594,   595,   596,     0,
     0,   575,   576,     0,   572,   573,   574,     0,     0,    59,
    44,     0,     0,    53,     0,    83,   100,     0,     0,     0,
     0,     0,   101,     0,   259,     0,     0,     0,     0,     0,
     0,     0,     0,     0,     0,     0,     0,   260,   442,   612,
     0,   443,   388,     0,     0,     0,     0,     0,     0,     0,
     0,     0,     0,     0,   389,   226,     0,     0,     0,     0,
     0,     0,     0,     0,     0,   227,   295,     0,     0,     0,
     0,     0,   296,   170,     0,     0,     0,     0,   171,   130,
     0,     0,     0,     0,     0,     0,   131,   154,     0,     0,
   155,   190,     0,     0,     0,     0,     0,     0,     0,     0,
     0,     0,     0,   191,   323,     0,     0,   324,   355,     0,
     0,   356,   371,     0,     0,   372,   422,     0,     0,     0,
     0,   423,   339,     0,     0,   340,   457,     0,     0,     0,
   458,   475,     0,     0,     0,     0,     0,     0,     0,     0,
     0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
     0,   476,   525,     0,     0,     0,     0,     0,     0,     0,
     0,     0,     0,     0,     0,   526,   586,     0,     0,     0,
     0,     0,     0,     0,     0,   587,   570,     0,     0,   571,
    82,    80,    43,     0,    52,     0,     0,     0,     0,    99,
     0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
     0,     0,   258,   441,     0,     0,     0,     0,   636,     0,
     0,     0,     0,     0,     0,     0,   387,     0,     0,     0,
     0,     0,   246,     0,   614,     0,   248,     0,   621,   250,
     0,   225,     0,     0,     0,     0,     0,     0,   294,     0,
     0,     0,   169,     0,     0,     0,     0,     0,     0,   129,
     0,   153,     0,     0,     0,     0,     0,     0,     0,     0,
   215,     0,   189,     0,   322,     0,   635,   354,     0,   370,
     0,     0,     0,   639,   421,     0,   338,     0,     0,   456,
     0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
     0,     0,     0,     0,     0,     0,     0,     0,   474,     0,
     0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
     0,     0,   524,     0,     0,     0,     0,     0,     0,     0,
     0,   585,     0,   569,     0,   109,   111,   110,     0,     0,
     0,   276,   277,   278,   279,   280,   281,   282,   283,   284,
   285,   286,   619,   404,   406,   407,     0,     0,     0,     0,
     0,     0,   405,   240,   241,   242,   243,   244,   245,     0,
   626,   247,     0,   249,     0,     0,   643,   312,   313,     0,
   179,   180,   181,   633,   141,   143,     0,     0,     0,     0,
   206,   207,   208,     0,     0,   211,   212,   213,     0,     0,
   217,     0,   362,     0,     0,   431,   432,   433,     0,     0,
   465,     0,   499,   500,   501,     0,   503,   504,   505,     0,
     0,   508,   509,   510,   511,   512,   513,   514,   515,   516,
   550,     0,   552,   553,   554,   555,   556,   557,   642,   558,
   559,   644,   560,     0,     0,     0,   601,   602,     0,     0,
     0,     0,     0,    89,     0,     0,     0,     0,     0,     0,
     0,     0,     0,     0,     0,   640,   613,   616,   617,   618,
   640,   620,   623,   624,   625,     0,     0,     0,     0,     0,
     0,     0,     0,     0,   216,   214,     0,   628,   634,     0,
   638,     0,     0,     0,     0,     0,     0,     0,     0,     0,
     0,     0,     0,     0,     0,   609,     0,     0,    91,    88,
     0,     0,     0,     0,   408,   409,   410,     0,     0,     0,
     0,     0,     0,     0,   314,     0,     0,   142,     0,     0,
     0,   330,     0,   379,     0,   637,     0,   641,     0,     0,
   506,   507,   551,     0,     0,     0,     0,     0,   605,   606,
     0,    90,     0,   611,   610,     0,     0,     0,   615,   622,
     0,     0,     0,     0,     0,     0,     0,   640,   627,   630,
   631,   632,     0,     0,     0,     0,     0,     0,   608,     0,
     0,     0,     0,   113,   411,   412,   413,     0,     0,   144,
     0,   161,   209,     0,     0,     0,   346,   466,     0,     0,
     0,     0,     0,   604,     0,     0,     0,   114,     0,     0,
     0,     0,   629,     0,     0,     0,     0,   607,     0,     0,
     0,   115,     0,     0,     0,     0,   378,     0,     0,   599,
     0,   600,   603,   577,   116,     0,     0,     0,     0,     0,
     0,     0,   117,     0,     0,     0,     0,   502,     0,   118,
     0,     0,     0,     0,     0,     0,   119,     0,     0,     0,
     0,     0,     0,   120,     0,     0,     0,     0,     0,   112,
     0,     0,     0,   145,     0,     0,   121,     0,   307,     0,
     0,   310,     0,     0,   305,     0,   311,   308,   309,     0,
   561,   306,     0,   210,     0,     0,     0
};

static const short yydefgoto[] = {  1335,
     4,     5,     6,    32,    33,    34,    35,    94,    95,    96,
    36,   100,   101,   102,    87,    88,    89,   243,    90,   659,
   321,   322,   323,  1096,    37,   106,   107,   108,   331,   332,
   333,   334,   335,   336,  1247,  1276,  1291,  1303,    38,   148,
   149,   150,   456,   457,   458,   459,   460,   461,   462,    39,
   154,   155,   156,   468,   469,   470,    40,   142,   143,   144,
   442,   443,   444,   445,   446,    41,   160,   161,   162,   485,
   486,   487,   488,   489,   490,   491,   492,   493,   494,   495,
  1040,   496,    42,   130,   131,   132,   411,   412,   413,   414,
   415,   416,   417,   418,   419,   420,    43,   112,   113,   114,
   352,   353,   354,   355,   356,   357,   358,   359,   360,   361,
   362,   363,   364,    44,   136,   137,   138,   429,   430,   431,
  1321,  1322,   432,   433,   434,    45,   166,   167,   168,   502,
   503,   504,    46,   190,   191,   192,   538,   539,   540,    47,
   172,   173,   174,   510,   511,   512,    48,   178,   179,   180,
   518,   519,   520,    49,   124,   125,   126,   387,   388,   389,
   390,   391,   392,   393,   394,   395,   396,   397,   398,    50,
   184,   185,   186,   528,   529,   530,   531,   532,    51,   118,
   119,   120,   370,   371,    52,   196,   197,   198,   547,   548,
   549,   550,    53,   202,   203,   204,   573,   574,   575,   576,
   577,   578,   579,   580,   581,   582,   583,   584,   585,   586,
   587,   588,   589,   590,   591,   592,    54,   208,   209,   210,
   616,   617,   618,   619,   620,   621,   622,   623,   624,   625,
   626,   627,   628,    55,   220,   221,   222,   654,   655,   656,
    56,   214,   215,   216,   640,   641,   642,   643,   644,   645,
   646,   647,   648,  1143,   971,   365,   373,   874,  1107,  1108,
   875,   878,  1112,  1113,   879,  1127,  1209,  1210,  1211,   916,
   860,  1133,   923,   924,  1135,   958,   886,   961
};

static const short yypact[] = {    22,
  -115,-32768,-32768,    68,-32768,-32768,  -100,   -89,   -78,   -69,
   -62,   -45,   -35,   -32,   -30,     1,     4,    10,    16,    69,
    74,    77,    80,    93,   101,   113,   116,   121,   179,   181,
-32768,   713,-32768,-32768,-32768,-32768,-32768,-32768,-32768,-32768,
-32768,-32768,-32768,-32768,-32768,-32768,-32768,-32768,-32768,-32768,
-32768,-32768,-32768,-32768,-32768,-32768,-32768,   203,    61,    28,
    64,    96,   110,   133,   146,   152,   235,   248,   254,   258,
   264,   307,   351,   564,   589,   611,   617,   665,   668,   670,
   672,-32768,-32768,   739,-32768,-32768,    61,-32768,-32768,-32768,
   -54,-32768,-32768,    28,-32768,-32768,    39,-32768,-32768,    64,
-32768,-32768,    78,-32768,-32768,    96,-32768,-32768,   127,-32768,
-32768,   110,-32768,-32768,   225,-32768,-32768,   133,-32768,-32768,
   228,-32768,-32768,   146,-32768,-32768,   244,-32768,-32768,   152,
-32768,-32768,   247,-32768,-32768,   235,-32768,-32768,   257,-32768,
-32768,   248,-32768,-32768,   266,-32768,-32768,   254,-32768,-32768,
   272,-32768,-32768,   258,-32768,-32768,   296,-32768,-32768,   264,
-32768,-32768,   298,-32768,-32768,   307,-32768,-32768,   301,-32768,
-32768,   351,-32768,-32768,   315,-32768,-32768,   564,-32768,-32768,
   324,-32768,-32768,   589,-32768,-32768,   326,-32768,-32768,   611,
-32768,-32768,   330,-32768,-32768,   617,-32768,-32768,   333,-32768,
-32768,   665,-32768,-32768,   342,-32768,-32768,   668,-32768,-32768,
   345,-32768,-32768,   670,-32768,-32768,   360,-32768,-32768,   672,
-32768,-32768,-32768,-32768,-32768,-32768,-32768,    97,-32768,-32768,
-32768,-32768,-32768,-32768,-32768,-32768,-32768,-32768,-32768,-32768,
-32768,-32768,   236,-32768,   346,-32768,   394,-32768,   414,-32768,
   422,-32768,   426,-32768,   428,-32768,   431,-32768,   447,-32768,
   450,-32768,   452,-32768,   453,-32768,   454,-32768,   456,-32768,
   462,-32768,   469,-32768,   481,-32768,   492,-32768,   499,-32768,
   503,-32768,   507,-32768,   510,-32768,   513,-32768,   368,   472,
   653,   656,   710,    81,   220,    34,    73,   430,   114,   427,
    66,   489,   256,   568,   596,   150,   574,   505,   455,   252,
   262,    70,   238,   516,   520,   659,   783,   521,-32768,-32768,
   662,-32768,-32768,   523,   475,   506,   526,   528,-32768,-32768,
   734,-32768,-32768,-32768,-32768,-32768,   545,   530,   532,   533,
   534,   535,   536,   537,   538,   539,   541,   542,   543,-32768,
-32768,    98,-32768,-32768,-32768,-32768,-32768,-32768,-32768,-32768,
-32768,-32768,-32768,-32768,-32768,   544,   546,-32768,-32768,   494,
-32768,-32768,-32768,   547,   552,   556,   557,   561,   562,   569,
   575,   576,   578,   581,-32768,-32768,   239,-32768,-32768,-32768,
-32768,-32768,-32768,-32768,-32768,-32768,-32768,-32768,-32768,   559,
   582,   585,   592,   594,   603,   604,   609,   613,-32768,-32768,
   242,-32768,-32768,-32768,-32768,-32768,-32768,-32768,-32768,-32768,
-32768,   614,   616,   619,   621,   622,-32768,-32768,   477,-32768,
-32768,-32768,-32768,-32768,-32768,   623,   630,   631,   632,-32768,
-32768,   615,-32768,-32768,-32768,-32768,-32768,   626,   633,   634,
   641,   648,   651,-32768,-32768,   593,-32768,-32768,-32768,-32768,
-32768,-32768,-32768,   637,   654,-32768,-32768,   620,-32768,-32768,
-32768,   644,   664,   667,   669,   684,   696,   697,   698,   699,
   722,   723,-32768,-32768,   560,-32768,-32768,-32768,-32768,-32768,
-32768,-32768,-32768,-32768,-32768,-32768,-32768,   750,   766,-32768,
-32768,   627,-32768,-32768,-32768,   767,   769,-32768,-32768,   635,
-32768,-32768,-32768,   770,   772,-32768,-32768,   638,-32768,-32768,
-32768,   773,   775,   776,   777,-32768,-32768,   166,-32768,-32768,
-32768,-32768,-32768,   778,   780,-32768,-32768,   645,-32768,-32768,
-32768,   781,   784,   785,-32768,-32768,   577,-32768,-32768,-32768,
-32768,   782,   786,   787,   788,   789,   790,   791,   792,   793,
   794,   795,   796,   797,   798,   799,   800,   801,   802,   803,
-32768,-32768,   474,-32768,-32768,-32768,-32768,-32768,-32768,-32768,
-32768,-32768,-32768,-32768,-32768,-32768,-32768,-32768,-32768,-32768,
-32768,-32768,-32768,   804,   806,   807,   808,   809,   810,   811,
   812,   813,   814,   815,   816,-32768,-32768,-32768,-32768,-32768,
-32768,-32768,-32768,-32768,-32768,   325,-32768,-32768,-32768,-32768,
-32768,-32768,-32768,-32768,-32768,-32768,-32768,-32768,-32768,   817,
   819,   820,   821,   822,   823,   824,   825,-32768,-32768,   367,
-32768,-32768,-32768,-32768,-32768,-32768,-32768,-32768,-32768,   826,
   828,-32768,-32768,   649,-32768,-32768,-32768,   636,   829,-32768,
-32768,   830,   832,-32768,   833,-32768,-32768,   591,   639,   686,
   842,   834,-32768,   612,-32768,  -100,   845,   682,   818,   849,
   852,   853,   854,   855,   856,   857,   841,-32768,-32768,-32768,
   843,-32768,-32768,   858,   858,   858,   859,   859,   859,   859,
   859,   859,   858,   846,-32768,-32768,   858,   858,   831,  -100,
   858,    79,    90,   174,   847,-32768,-32768,   -71,   862,  -100,
   866,   850,-32768,-32768,   858,   860,  -100,   851,-32768,-32768,
   867,   867,   871,   872,   874,   861,-32768,-32768,   875,   863,
-32768,-32768,   877,   879,  -100,  -100,   881,  -100,   867,  -100,
   882,   883,   868,-32768,-32768,  -100,   869,-32768,-32768,   859,
   870,-32768,-32768,   887,   873,-32768,-32768,   858,  -100,  -100,
   876,-32768,-32768,   890,   878,-32768,-32768,   884,   891,   880,
-32768,-32768,   894,   896,   898,   867,   897,   897,   858,   867,
   867,   859,   897,  -100,   897,   897,   897,   867,  -100,   899,
   885,-32768,-32768,   903,   904,   905,   558,   901,   907,   909,
   908,   908,   910,  -100,   893,-32768,-32768,   912,   914,   915,
   916,  -100,  -100,   917,   900,-32768,-32768,  -100,   902,-32768,
-32768,-32768,-32768,   920,-32768,   906,   911,   913,   765,-32768,
   763,   918,   919,   921,   922,   923,   924,   925,   926,   928,
   929,   930,-32768,-32768,   779,   931,   933,   934,-32768,   768,
   935,   936,   937,   938,   939,   941,-32768,   942,   943,   944,
   945,   946,-32768,   947,   948,   951,-32768,   950,   952,-32768,
   954,-32768,   955,   927,   959,   957,   958,   960,-32768,   962,
   963,   964,-32768,   864,   965,   966,   967,   968,   969,-32768,
   970,-32768,   972,   973,   974,   975,   976,   978,   979,   980,
   981,   983,-32768,   984,-32768,   -91,-32768,-32768,   985,-32768,
   987,   988,     8,-32768,-32768,   989,-32768,   991,   992,-32768,
   994,   995,   996,   997,   999,  1000,  1001,  1004,  1005,  1002,
  1007,  1008,  1009,  1010,  1011,  1012,  1013,  1014,-32768,    13,
  1016,  1017,  1018,  1019,  1020,  1021,   886,  1022,  1023,   940,
  1024,  1025,-32768,  1027,  1030,  1032,  1033,  1034,  1035,  1036,
  1037,-32768,  1038,-32768,   137,-32768,-32768,-32768,   858,   953,
   956,-32768,-32768,-32768,-32768,-32768,-32768,-32768,-32768,-32768,
-32768,-32768,-32768,-32768,-32768,-32768,   858,   858,   858,   858,
   858,   858,-32768,-32768,-32768,-32768,-32768,-32768,-32768,   998,
-32768,-32768,  1003,-32768,   932,  1039,-32768,-32768,-32768,   858,
-32768,-32768,-32768,-32768,-32768,-32768,   908,   977,  1042,  -100,
-32768,-32768,-32768,  1051,  1058,-32768,-32768,-32768,   858,  1043,
-32768,   867,-32768,   859,  1059,-32768,-32768,-32768,  -100,  1006,
-32768,  1060,-32768,-32768,-32768,   867,-32768,-32768,-32768,   897,
   897,-32768,-32768,-32768,-32768,-32768,-32768,-32768,-32768,-32768,
-32768,  1061,-32768,-32768,-32768,-32768,-32768,-32768,-32768,-32768,
-32768,-32768,-32768,  1063,  -100,  1064,-32768,-32768,  1062,  -100,
  1066,  1067,  1068,-32768,  1069,   233,  1052,  1071,  1072,  1056,
  1057,  1065,  1070,  1073,  1074,   779,  1075,-32768,-32768,-32768,
   951,  1077,-32768,-32768,-32768,  1078,  1006,  1080,  1081,  1082,
  1084,  1085,  1087,  1088,-32768,-32768,  1090,  1091,-32768,   275,
-32768,   990,  1092,   961,  1093,  1094,  1096,  1097,  1098,  1099,
  1100,  1101,  1102,  1103,  1105,-32768,  1106,  1107,-32768,-32768,
  1076,   858,  1109,  1110,-32768,-32768,-32768,   859,   859,   859,
   998,  1003,  1006,  1111,-32768,   858,   897,-32768,  1079,  1083,
  1086,-32768,  1113,-32768,  1006,-32768,  1089,-32768,  -100,   867,
-32768,-32768,-32768,  1060,  -100,  1108,  -101,  -100,-32768,-32768,
   982,-32768,  1112,-32768,-32768,  1114,  1115,  1116,-32768,-32768,
  1117,  1124,  1119,  1120,  1122,  1123,  1125,   864,  1126,-32768,
-32768,-32768,  1127,  1129,   277,  1130,  1131,  1132,-32768,  1133,
  1134,   300,  1135,   867,-32768,-32768,-32768,  1137,  1136,-32768,
   897,-32768,-32768,  1141,  1113,  1006,-32768,-32768,  -100,   897,
  1064,  1142,  -100,-32768,  -100,  1145,  1139,-32768,  1140,  1006,
  1143,  1144,-32768,  1138,  1146,  1147,   302,-32768,   304,  1149,
  1150,  1159,  1006,  1151,  1160,  1163,-32768,  1168,  -100,-32768,
  1170,-32768,-32768,-32768,-32768,  1154,  1155,  1173,  1157,  1158,
  1161,  1162,  1176,  1180,  1164,   897,  1183,-32768,   897,-32768,
  1166,  1167,  1185,  1169,  1171,  1172,  -100,  1187,  1174,   897,
  1191,   897,  1177,  1175,  1178,  1194,  1181,  1179,  1182,-32768,
  -100,  1198,   311,-32768,  1201,   897,-32768,   352,-32768,  -100,
   354,-32768,  1184,  1186,-32768,   372,-32768,-32768,-32768,  1204,
-32768,-32768,  1188,-32768,  1055,  1148,-32768
};

static const short yypgoto[] = {-32768,
-32768,  1054,-32768,-32768,  1028,-32768,-32768,-32768,   837,-32768,
-32768,-32768,   971,-32768,   774,   -74,-32768,  -316,-32768,-32768,
-32768,   607,-32768,-32768,-32768,-32768,  1118,-32768,-32768,   725,
-32768,-32768,-32768,-32768,-32768,-32768,-32768,-32768,-32768,-32768,
  1192,-32768,-32768,   753,-32768,-32768,-32768,-32768,-32768,-32768,
-32768,  1189,-32768,-32768,   595,-32768,-32768,-32768,  1199,-32768,
-32768,   625,-32768,-32768,-32768,-32768,-32768,  1053,-32768,-32768,
   583,-32768,-32768,-32768,-32768,-32768,-32768,-32768,-32768,-32768,
-32768,-32768,-32768,-32768,  1212,-32768,-32768,   715,-32768,-32768,
-32768,-32768,-32768,-32768,-32768,-32768,-32768,-32768,  1156,-32768,
-32768,   707,-32768,-32768,-32768,-32768,-32768,-32768,-32768,-32768,
-32768,-32768,-32768,-32768,-32768,  1208,-32768,-32768,   949,-32768,
  -107, -1238,-32768,-32768,-32768,-32768,-32768,  1046,-32768,-32768,
   717,-32768,-32768,-32768,  1031,-32768,-32768,   677,-32768,-32768,
-32768,  1045,-32768,-32768,   726,-32768,-32768,-32768,  1190,-32768,
-32768,   827,-32768,-32768,-32768,  1222,-32768,-32768,   986,-32768,
-32768,-32768,-32768,-32768,-32768,-32768,-32768,-32768,-32768,-32768,
-32768,  1165,-32768,-32768,   835,-32768,-32768,-32768,-32768,-32768,
  1229,-32768,-32768,  1015,-32768,-32768,  1152,-32768,-32768,   805,
-32768,-32768,-32768,-32768,  1153,-32768,-32768,   836,-32768,-32768,
-32768,-32768,-32768,-32768,-32768,-32768,-32768,-32768,  -308,  -306,
  -295,  -294,  -293,  -292,  -289,  -288,-32768,-32768,  1193,-32768,
-32768,   735,-32768,-32768,-32768,-32768,-32768,-32768,-32768,-32768,
-32768,-32768,-32768,-32768,-32768,  1195,-32768,-32768,   700,-32768,
-32768,-32768,  1196,-32768,-32768,   716,-32768,-32768,-32768,-32768,
-32768,-32768,-32768,   109,-32768,  -253,-32768,   337,-32768,   192,
  -684,  -430,-32768,   196,  -790,-32768,-32768,   124,  -723,-32768,
  -670, -1097, -1140,    -7,   176,  -798,-32768,-32768
};


#define	YYLAST		1415


static const short yytable[] = {    58,
   663,   608,   941,   609,   943,   944,   945,   895,   896,   856,
   857,   858,   244,   959,   610,   611,   612,   613,   866,  1164,
   614,   615,   868,   869,     1,   909,   872,   861,   862,   863,
   864,   865,    91,  1220,     7,    57,    57,   337,  1215,   374,
   890,   372,   399,   421,   435,   447,   463,   471,   497,   505,
   513,   521,   533,   541,   551,   593,   629,   649,   657,  1043,
  1044,    59,   934,   883,    84,  1201,   938,   939,    97,   337,
     1,   464,    60,   337,   946,   650,   337,  1213,   400,   245,
   884,    61,  1329,   921,   337,   465,   338,  1329,    62,   917,
   375,   376,   377,   378,   379,   380,   381,   382,   383,   384,
   103,   337,  1259,   687,   937,    63,   401,   402,   403,   404,
   405,   406,   407,   408,   109,    64,   372,   337,    65,   436,
    66,   940,   339,   340,   341,   342,   343,   344,   345,   346,
   347,   348,   349,   399,   437,   438,   439,   115,  1254,   339,
   340,   341,   342,   343,   344,   345,   346,   347,   348,   349,
   121,    67,  1264,   337,    68,   522,   127,   421,  1048,  1049,
    69,     2,     3,  1071,  1072,  1277,    70,    92,    93,   337,
   651,   771,   247,   385,   386,   435,     8,     9,    10,    11,
    12,    13,    14,    15,    16,    17,    18,    19,   447,    20,
    21,    22,    23,    24,    25,    26,    27,    28,    29,    30,
    85,    86,   463,    98,    99,   466,   467,     2,     3,   652,
   653,   249,   409,   410,   471,   855,   523,   524,   525,    71,
   350,   351,  1114,   337,    72,   366,   876,    73,  1119,   873,
    74,   497,   523,   524,   525,   104,   105,   350,   351,   133,
   877,   244,   337,    75,   704,   337,   289,   715,   505,   110,
   111,    76,   139,   440,   441,   337,   513,   594,   145,   337,
   251,   498,   151,    77,   521,   337,    78,   630,   157,  1137,
  1138,    79,   116,   117,   533,   401,   402,   403,   404,   405,
   406,   407,   408,   881,   541,   122,   123,  1094,  1095,   526,
   527,   128,   129,   551,  1097,   375,   376,   377,   378,   379,
   380,   381,   382,   383,   384,   526,   527,   608,   499,   609,
   876,   163,  1100,  1101,  1102,  1103,  1104,  1105,  1128,   593,
   610,   611,   612,   613,   880,  1109,   614,   615,   337,    80,
   815,    81,  1136,   563,   564,   565,   566,   567,   568,   569,
   570,   595,   596,   597,   598,   599,   600,   601,   602,   603,
   604,   605,   367,    83,  1125,   169,   935,   936,   253,   368,
   369,   255,   629,   631,   632,   633,   634,   635,   636,   637,
   337,  1114,   825,  1129,   134,   135,  1204,   257,   385,   386,
   259,   409,   410,  1150,  1151,   290,   649,   140,   141,   658,
   261,   606,   607,   146,   147,   500,   501,   152,   153,   263,
   657,   638,   639,   158,   159,   265,   563,   564,   565,   566,
   567,   568,   569,   570,   595,   596,   597,   598,   599,   600,
   601,   602,   603,   604,   605,  1174,  1175,  1238,  1049,   267,
   337,   269,   448,   337,   271,   422,   423,   424,   425,   426,
  1251,   449,   450,   451,   452,   453,   164,   165,   273,  1256,
  1244,  1245,  1270,  1271,  1272,  1049,  1216,   275,   337,   277,
   552,  1319,  1320,   279,   606,   607,   281,  1193,   631,   632,
   633,   634,   635,   636,   637,   283,  1109,   337,   285,   801,
   337,  1203,   722,   423,   424,   425,   426,  1196,  1197,  1198,
   170,   171,   337,   287,   472,  1294,   291,   337,  1296,   691,
  1248,   313,  1325,  1320,  1328,  1320,   638,   639,   337,  1307,
   542,  1309,   473,   474,   475,   476,   477,   478,   479,   480,
   481,   482,  1332,  1320,   981,  1324,   553,   554,   555,   556,
   557,   558,   559,   560,   561,   562,   563,   564,   565,   566,
   567,   568,   569,   570,   292,   553,   554,   555,   556,   557,
   558,   559,   560,   561,   562,   563,   564,   565,   566,   567,
   568,   569,   570,   337,   293,   753,   454,   455,   175,   427,
   428,   337,   294,   506,   543,   544,   295,   337,   296,   534,
   337,   297,   780,   473,   474,   475,   476,   477,   478,   479,
   480,   481,   482,   181,   571,   572,   337,   298,   736,   337,
   299,   514,   300,   301,   302,   314,   303,   449,   450,   451,
   452,   453,   304,   571,   572,   187,   427,   428,   337,   305,
   728,   193,   507,   337,   668,   740,   367,   535,   483,   484,
   337,   306,   757,   368,   369,   437,   438,   439,   337,   465,
   761,   337,   307,   765,   545,   546,   543,   544,   337,   308,
   775,   515,   337,   309,   829,   669,    84,   310,   315,   317,
   311,   318,    84,   312,   662,   317,   660,   665,   842,   199,
   661,   664,   205,   667,   211,   670,   217,   671,   674,   499,
   675,   676,   677,   678,   679,   680,   681,   682,   683,   507,
   684,   685,   686,   515,   689,   953,   690,   693,   535,   483,
   484,   694,   871,   176,   177,   695,   696,   508,   509,   706,
   697,   698,   887,   536,   537,   324,   545,   546,   699,   892,
   325,   326,   327,   328,   700,   701,   836,   702,   182,   183,
   703,   707,   454,   455,   708,   516,   517,   905,   906,   672,
   908,   709,   910,   710,   325,   326,   327,   328,   914,   651,
   188,   189,   711,   712,   440,   441,   194,   195,   713,   466,
   467,   922,   714,   841,   717,   718,   500,   501,   719,   831,
   720,   721,   837,   724,   508,   509,   730,   516,   517,   725,
   726,   727,   731,   732,   536,   537,   942,   738,   652,   653,
   733,   947,    85,    86,   742,   319,   320,   734,    85,    86,
   735,   319,   320,   739,   200,   201,   962,   206,   207,   212,
   213,   218,   219,   743,   968,   969,   744,   844,   745,   838,
   973,     8,     9,    10,    11,    12,    13,    14,    15,    16,
    17,    18,    19,   746,    20,    21,    22,    23,    24,    25,
    26,    27,    28,    29,    30,   747,   748,   749,   750,   329,
   330,   223,   224,   225,   226,   227,   228,   229,   230,   231,
   232,   233,   234,   235,   236,   237,   238,   239,   240,   241,
   242,   751,   752,   329,   330,   223,   224,   225,   226,   227,
   980,   229,   230,   231,   232,   233,   234,   235,   236,   237,
   238,   239,   240,   241,   242,   223,   224,   225,   226,   227,
   755,   229,   230,   231,   232,   233,   234,   235,   236,   237,
   238,   239,   240,   241,   242,   756,   979,   759,   760,   997,
   763,   764,   993,   767,   768,   769,   770,   666,   773,   774,
   246,   777,   782,   778,   779,   783,   784,   785,   786,   787,
   788,   789,   790,   791,   792,   793,   794,   795,   796,   797,
   798,   799,   800,   845,   803,   804,   805,   806,   807,   808,
   809,   810,   811,   812,   813,   814,   870,   817,   818,   819,
   820,   821,   822,   823,   824,   839,   827,   828,   843,   832,
   833,   834,   846,   835,   840,   847,   848,   849,   850,   851,
   852,   853,   859,   854,   855,   891,   867,   882,   885,   888,
   889,   893,  1110,   894,   897,  1115,   898,   899,  1024,   901,
   903,   900,   904,   902,   907,   911,   912,   928,   913,   915,
   918,   919,  1122,   920,   926,   929,   925,   931,   927,   932,
   930,   933,  1079,   876,   948,   949,   950,   951,   952,   954,
   955,  1131,   956,   963,   957,   964,   960,   965,   966,   967,
   972,   970,   974,   975,  1336,   673,   976,    31,   688,    82,
  1016,   977,   741,   978,   316,  1116,   729,   754,   982,   983,
   248,   984,   985,   986,   987,   988,   989,  1141,   990,   991,
   992,   994,  1145,   995,   996,  1082,   998,   999,  1000,  1001,
  1002,  1003,  1004,  1005,  1006,  1007,  1008,  1009,  1011,  1010,
  1012,  1017,  1098,  1013,  1014,  1099,  1015,  1018,  1019,  1178,
  1120,  1020,  1021,  1022,  1023,  1025,  1026,  1223,  1027,  1028,
  1029,  1030,  1031,  1032,  1033,   716,  1034,  1035,  1036,  1037,
  1038,  1176,  1039,  1041,  1106,  1042,  1045,  1046,  1047,  1111,
  1050,  1051,  1132,  1052,  1053,  1054,  1055,  1337,  1056,  1057,
  1058,  1059,  1062,  1110,  1115,  1060,  1061,  1063,  1064,  1065,
  1066,  1067,  1068,  1069,  1070,  1212,  1073,  1074,  1075,  1076,
  1077,  1078,  1080,  1081,  1083,  1121,  1084,  1218,  1085,  1221,
  1222,  1086,  1087,  1088,  1123,  1089,  1090,  1091,  1092,  1093,
  1117,  1124,  1130,  1126,  1139,  1144,  1134,  1140,  1142,  1146,
  1147,  1148,  1149,  1152,  1153,  1154,  1155,  1156,   737,  1192,
  1326,   270,   268,  1205,   776,  1157,   272,  1206,   758,  1207,
   278,  1158,  1214,   250,  1159,  1160,  1161,  1212,  1162,  1163,
  1165,  1255,  1166,  1167,  1168,   762,  1169,  1260,  1170,  1171,
  1172,  1219,  1173,  1177,  1179,  1180,  1181,  1182,  1183,  1208,
  1184,  1185,  1186,  1187,  1188,  1189,  1190,  1229,  1191,  1194,
  1195,  1282,  1202,  1224,  1225,  1226,  1227,   252,  1228,  1230,
  1249,  1231,  1232,  1233,  1252,  1258,  1234,  1235,  1236,  1237,
  1261,  1239,  1240,  1241,  1242,  1243,  1246,  1250,  1267,  1304,
  1262,  1263,  1275,  1279,  1265,  1266,  1280,  1268,  1269,  1273,
  1274,  1281,  1278,  1317,  1220,  1283,  1284,  1285,  1286,  1287,
  1290,  1288,  1327,  1289,  1292,  1293,  1295,  1297,  1298,  1299,
  1300,  1305,  1301,  1302,  1308,  1306,  1311,  1310,  1313,  1312,
  1315,  1314,  1318,  1316,  1323,  1330,  1331,  1333,  1334,   264,
   262,   258,   266,   260,   766,   256,   254,   280,   276,  1257,
   816,   781,  1199,   830,   282,   826,  1118,  1200,  1253,  1217,
     0,     0,   772,     0,     0,     0,     0,   274,     0,     0,
     0,     0,   705,     0,     0,     0,     0,   723,     0,     0,
     0,     0,     0,     0,   692,     0,     0,     0,     0,     0,
     0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
   284,     0,     0,     0,     0,     0,     0,     0,   802,   286,
     0,     0,     0,     0,   288
};

static const short yycheck[] = {     7,
   317,   310,   793,   310,   795,   796,   797,   731,   732,   694,
   695,   696,    87,   812,   310,   310,   310,   310,   703,  1117,
   310,   310,   707,   708,     3,   749,   711,   698,   699,   700,
   701,   702,     5,   135,   150,   137,   137,     4,  1179,     6,
   725,   295,   296,   297,   298,   299,   300,   301,   302,   303,
   304,   305,   306,   307,   308,   309,   310,   311,   312,   151,
   152,   151,   786,   135,     4,  1163,   790,   791,     5,     4,
     3,     6,   151,     4,   798,     6,     4,  1175,     6,   134,
   152,   151,  1321,   768,     4,    20,     6,  1326,   151,   760,
    57,    58,    59,    60,    61,    62,    63,    64,    65,    66,
     5,     4,  1243,     6,   789,   151,    34,    35,    36,    37,
    38,    39,    40,    41,     5,   151,   370,     4,   151,     6,
   151,   792,    42,    43,    44,    45,    46,    47,    48,    49,
    50,    51,    52,   387,    21,    22,    23,     5,  1236,    42,
    43,    44,    45,    46,    47,    48,    49,    50,    51,    52,
     5,   151,  1250,     4,   151,     6,     5,   411,   151,   152,
   151,   140,   141,   151,   152,  1263,   151,   140,   141,     4,
   101,     6,   134,   140,   141,   429,   109,   110,   111,   112,
   113,   114,   115,   116,   117,   118,   119,   120,   442,   122,
   123,   124,   125,   126,   127,   128,   129,   130,   131,   132,
   140,   141,   456,   140,   141,   140,   141,   140,   141,   140,
   141,   134,   140,   141,   468,   137,    67,    68,    69,   151,
   140,   141,  1013,     4,   151,     6,   137,   151,  1027,   151,
   151,   485,    67,    68,    69,   140,   141,   140,   141,     5,
   151,   316,     4,   151,     6,     4,   150,     6,   502,   140,
   141,   151,     5,   140,   141,     4,   510,     6,     5,     4,
   134,     6,     5,   151,   518,     4,   151,     6,     5,  1060,
  1061,   151,   140,   141,   528,    34,    35,    36,    37,    38,
    39,    40,    41,   714,   538,   140,   141,   151,   152,   140,
   141,   140,   141,   547,   979,    57,    58,    59,    60,    61,
    62,    63,    64,    65,    66,   140,   141,   616,    53,   616,
   137,     5,   997,   998,   999,  1000,  1001,  1002,  1042,   573,
   616,   616,   616,   616,   151,  1010,   616,   616,     4,   151,
     6,   151,  1056,    82,    83,    84,    85,    86,    87,    88,
    89,    90,    91,    92,    93,    94,    95,    96,    97,    98,
    99,   100,   133,   151,  1039,     5,   787,   788,   134,   140,
   141,   134,   616,   102,   103,   104,   105,   106,   107,   108,
     4,  1162,     6,  1044,   140,   141,  1167,   134,   140,   141,
   134,   140,   141,   151,   152,   150,   640,   140,   141,   152,
   134,   140,   141,   140,   141,   140,   141,   140,   141,   134,
   654,   140,   141,   140,   141,   134,    82,    83,    84,    85,
    86,    87,    88,    89,    90,    91,    92,    93,    94,    95,
    96,    97,    98,    99,   100,   151,   152,   151,   152,   134,
     4,   134,     6,     4,   134,     6,     7,     8,     9,    10,
  1231,    15,    16,    17,    18,    19,   140,   141,   134,  1240,
   151,   152,   151,   152,   151,   152,  1180,   134,     4,   134,
     6,   151,   152,   134,   140,   141,   134,  1152,   102,   103,
   104,   105,   106,   107,   108,   134,  1161,     4,   134,     6,
     4,  1166,     6,     7,     8,     9,    10,  1158,  1159,  1160,
   140,   141,     4,   134,     6,  1286,   151,     4,  1289,     6,
  1224,   134,   151,   152,   151,   152,   140,   141,     4,  1300,
     6,  1302,    24,    25,    26,    27,    28,    29,    30,    31,
    32,    33,   151,   152,   841,  1316,    72,    73,    74,    75,
    76,    77,    78,    79,    80,    81,    82,    83,    84,    85,
    86,    87,    88,    89,   151,    72,    73,    74,    75,    76,
    77,    78,    79,    80,    81,    82,    83,    84,    85,    86,
    87,    88,    89,     4,   151,     6,   140,   141,     5,   140,
   141,     4,   151,     6,    70,    71,   151,     4,   151,     6,
     4,   151,     6,    24,    25,    26,    27,    28,    29,    30,
    31,    32,    33,     5,   140,   141,     4,   151,     6,     4,
   151,     6,   151,   151,   151,   134,   151,    15,    16,    17,
    18,    19,   151,   140,   141,     5,   140,   141,     4,   151,
     6,     5,    55,     4,   150,     6,   133,    54,   140,   141,
     4,   151,     6,   140,   141,    21,    22,    23,     4,    20,
     6,     4,   151,     6,   140,   141,    70,    71,     4,   151,
     6,    56,     4,   151,     6,   150,     4,   151,     6,     4,
   151,     6,     4,   151,     6,     4,   151,     6,   676,     5,
   151,   151,     5,   151,     5,   150,     5,   150,   134,    53,
   151,   150,   150,   150,   150,   150,   150,   150,   150,    55,
   150,   150,   150,    56,   151,   138,   151,   151,    54,   140,
   141,   150,   710,   140,   141,   150,   150,   140,   141,   151,
   150,   150,   720,   140,   141,     6,   140,   141,   150,   727,
    11,    12,    13,    14,   150,   150,   136,   150,   140,   141,
   150,   150,   140,   141,   150,   140,   141,   745,   746,     6,
   748,   150,   750,   150,    11,    12,    13,    14,   756,   101,
   140,   141,   150,   150,   140,   141,   140,   141,   150,   140,
   141,   769,   150,   152,   151,   150,   140,   141,   150,   134,
   150,   150,   134,   151,   140,   141,   151,   140,   141,   150,
   150,   150,   150,   150,   140,   141,   794,   151,   140,   141,
   150,   799,   140,   141,   151,   140,   141,   150,   140,   141,
   150,   140,   141,   150,   140,   141,   814,   140,   141,   140,
   141,   140,   141,   150,   822,   823,   150,   136,   150,   134,
   828,   109,   110,   111,   112,   113,   114,   115,   116,   117,
   118,   119,   120,   150,   122,   123,   124,   125,   126,   127,
   128,   129,   130,   131,   132,   150,   150,   150,   150,   140,
   141,   113,   114,   115,   116,   117,   118,   119,   120,   121,
   122,   123,   124,   125,   126,   127,   128,   129,   130,   131,
   132,   150,   150,   140,   141,   113,   114,   115,   116,   117,
   118,   119,   120,   121,   122,   123,   124,   125,   126,   127,
   128,   129,   130,   131,   132,   113,   114,   115,   116,   117,
   151,   119,   120,   121,   122,   123,   124,   125,   126,   127,
   128,   129,   130,   131,   132,   150,   152,   151,   150,   152,
   151,   150,   144,   151,   150,   150,   150,   321,   151,   150,
    94,   151,   151,   150,   150,   150,   150,   150,   150,   150,
   150,   150,   150,   150,   150,   150,   150,   150,   150,   150,
   150,   150,   150,   136,   151,   150,   150,   150,   150,   150,
   150,   150,   150,   150,   150,   150,   136,   151,   150,   150,
   150,   150,   150,   150,   150,   134,   151,   150,   134,   151,
   151,   150,   134,   151,   151,   134,   134,   134,   134,   134,
   134,   151,   134,   151,   137,   136,   151,   151,   137,   134,
   151,   151,  1010,   137,   134,  1013,   135,   134,   145,   135,
   134,   151,   134,   151,   134,   134,   134,   134,   151,   151,
   151,   135,  1030,   151,   135,   135,   151,   134,   151,   134,
   151,   134,   147,   137,   136,   151,   134,   134,   134,   139,
   134,  1049,   134,   151,   137,   134,   137,   134,   134,   134,
   151,   135,   151,   134,     0,   331,   151,     4,   352,    32,
   134,   151,   468,   151,   291,   134,   442,   485,   151,   151,
   100,   151,   151,   151,   151,   151,   151,  1085,   151,   151,
   151,   151,  1090,   151,   151,   146,   152,   152,   152,   152,
   152,   151,   151,   151,   151,   151,   151,   151,   148,   152,
   151,   143,   150,   152,   151,   150,   152,   151,   151,   149,
   134,   152,   151,   151,   151,   151,   151,   136,   152,   152,
   152,   152,   151,   151,   151,   411,   152,   152,   151,   151,
   151,   142,   152,   151,   137,   152,   152,   151,   151,   137,
   152,   151,   137,   152,   151,   151,   151,     0,   152,   151,
   151,   151,   151,  1161,  1162,   152,   152,   151,   151,   151,
   151,   151,   151,   151,   151,  1173,   151,   151,   151,   151,
   151,   151,   151,   151,   151,   134,   152,  1185,   152,  1187,
  1188,   152,   151,   151,   134,   152,   152,   152,   152,   152,
   152,   134,   134,   151,   134,   134,   137,   135,   135,   134,
   134,   134,   134,   152,   134,   134,   151,   151,   456,   134,
  1318,   166,   160,   135,   538,   151,   172,   135,   502,   134,
   190,   152,   134,   106,   152,   152,   152,  1235,   152,   152,
   151,  1239,   152,   152,   151,   510,   152,  1245,   152,   152,
   151,   134,   152,   152,   152,   152,   151,   151,   151,   137,
   152,   152,   152,   152,   152,   151,   151,   134,   152,   151,
   151,  1269,   152,   152,   151,   151,   151,   112,   152,   151,
   134,   152,   151,   151,   134,   134,   152,   152,   152,   151,
   136,   152,   152,   152,   152,   152,   152,   152,   151,  1297,
   152,   152,   134,   134,   152,   152,   134,   152,   152,   151,
   151,   134,   152,  1311,   135,   152,   152,   135,   152,   152,
   135,   151,  1320,   152,   135,   152,   134,   152,   152,   135,
   152,   135,   152,   152,   134,   152,   152,   151,   135,   152,
   152,   151,   135,   152,   134,   152,   151,   134,   151,   148,
   142,   130,   154,   136,   518,   124,   118,   196,   184,  1241,
   616,   547,  1161,   654,   202,   640,  1020,  1162,  1235,  1184,
    -1,    -1,   528,    -1,    -1,    -1,    -1,   178,    -1,    -1,
    -1,    -1,   387,    -1,    -1,    -1,    -1,   429,    -1,    -1,
    -1,    -1,    -1,    -1,   370,    -1,    -1,    -1,    -1,    -1,
    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
   208,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   573,   214,
    -1,    -1,    -1,    -1,   220
};
/* -*-C-*-  Note some compilers choke on comments on `#line' lines.  */
#line 3 "/usr/lib/bison.simple"

/* Skeleton output parser for bison,
   Copyright (C) 1984, 1989, 1990 Bob Corbett and Richard Stallman

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 1, or (at your option)
   any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.  */


#ifndef alloca
#ifdef __GNUC__
#define alloca __builtin_alloca
#else /* not GNU C.  */
#if (!defined (__STDC__) && defined (sparc)) || defined (__sparc__) || defined (__sparc) || defined (__sgi)
#include <alloca.h>
#else /* not sparc */
#if defined (MSDOS) && !defined (__TURBOC__)
#include <malloc.h>
#else /* not MSDOS, or __TURBOC__ */
#if defined(_AIX)
#include <malloc.h>
 #pragma alloca
#else /* not MSDOS, __TURBOC__, or _AIX */
#ifdef __hpux
#ifdef __cplusplus
extern "C" {
void *alloca (unsigned int);
};
#else /* not __cplusplus */
void *alloca ();
#endif /* not __cplusplus */
#endif /* __hpux */
#endif /* not _AIX */
#endif /* not MSDOS, or __TURBOC__ */
#endif /* not sparc.  */
#endif /* not GNU C.  */
#endif /* alloca not defined.  */

/* This is the parser code that is written into each bison parser
  when the %semantic_parser declaration is not specified in the grammar.
  It was written by Richard Stallman by simplifying the hairy parser
  used when %semantic_parser is specified.  */

/* Note: there must be only one dollar sign in this file.
   It is replaced by the list of actions, each action
   as one case of the switch.  */

#define yyerrok		(yyerrstatus = 0)
#define yyclearin	(yychar = YYEMPTY)
#define YYEMPTY		-2
#define YYEOF		0
#define YYACCEPT	return(0)
#define YYABORT 	return(1)
#define YYERROR		goto yyerrlab1
/* Like YYERROR except do call yyerror.
   This remains here temporarily to ease the
   transition to the new meaning of YYERROR, for GCC.
   Once GCC version 2 has supplanted version 1, this can go.  */
#define YYFAIL		goto yyerrlab
#define YYRECOVERING()  (!!yyerrstatus)
#define YYBACKUP(token, value) \
do								\
  if (yychar == YYEMPTY && yylen == 1)				\
    { yychar = (token), yylval = (value);			\
      yychar1 = YYTRANSLATE (yychar);				\
      YYPOPSTACK;						\
      goto yybackup;						\
    }								\
  else								\
    { yyerror ("syntax error: cannot back up"); YYERROR; }	\
while (0)

#define YYTERROR	1
#define YYERRCODE	256

#ifndef YYPURE
#define YYLEX		yylex()
#endif

#ifdef YYPURE
#ifdef YYLSP_NEEDED
#define YYLEX		yylex(&yylval, &yylloc)
#else
#define YYLEX		yylex(&yylval)
#endif
#endif

/* If nonreentrant, generate the variables here */

#ifndef YYPURE

int	yychar;			/*  the lookahead symbol		*/
YYSTYPE	yylval;			/*  the semantic value of the		*/
				/*  lookahead symbol			*/

#ifdef YYLSP_NEEDED
YYLTYPE yylloc;			/*  location data for the lookahead	*/
				/*  symbol				*/
#endif

int yynerrs;			/*  number of parse errors so far       */
#endif  /* not YYPURE */

#if YYDEBUG != 0
int yydebug;			/*  nonzero means print parse trace	*/
/* Since this is uninitialized, it does not stop multiple parsers
   from coexisting.  */
#endif

/*  YYINITDEPTH indicates the initial size of the parser's stacks	*/

#ifndef	YYINITDEPTH
#define YYINITDEPTH 200
#endif

/*  YYMAXDEPTH is the maximum size the stacks can grow to
    (effective only if the built-in stack extension method is used).  */

#if YYMAXDEPTH == 0
#undef YYMAXDEPTH
#endif

#ifndef YYMAXDEPTH
#define YYMAXDEPTH 10000
#endif

/* Prevent warning if -Wstrict-prototypes.  */
#ifdef __GNUC__
int yyparse (void);
#endif

#if __GNUC__ > 1		/* GNU C and GNU C++ define this.  */
#define __yy_bcopy(FROM,TO,COUNT)	__builtin_memcpy(TO,FROM,COUNT)
#else				/* not GNU C or C++ */
#ifndef __cplusplus

/* This is the most reliable way to avoid incompatibilities
   in available built-in functions on various systems.  */
static void
__yy_bcopy (from, to, count)
     char *from;
     char *to;
     int count;
{
  register char *f = from;
  register char *t = to;
  register int i = count;

  while (i-- > 0)
    *t++ = *f++;
}

#else /* __cplusplus */

/* This is the most reliable way to avoid incompatibilities
   in available built-in functions on various systems.  */
static void
__yy_bcopy (char *from, char *to, int count)
{
  register char *f = from;
  register char *t = to;
  register int i = count;

  while (i-- > 0)
    *t++ = *f++;
}

#endif
#endif

#line 184 "/usr/lib/bison.simple"
int
yyparse()
{
  register int yystate;
  register int yyn;
  register short *yyssp;
  register YYSTYPE *yyvsp;
  int yyerrstatus;	/*  number of tokens to shift before error messages enabled */
  int yychar1 = 0;		/*  lookahead token as an internal (translated) token number */

  short	yyssa[YYINITDEPTH];	/*  the state stack			*/
  YYSTYPE yyvsa[YYINITDEPTH];	/*  the semantic value stack		*/

  short *yyss = yyssa;		/*  refer to the stacks thru separate pointers */
  YYSTYPE *yyvs = yyvsa;	/*  to allow yyoverflow to reallocate them elsewhere */

#ifdef YYLSP_NEEDED
  YYLTYPE yylsa[YYINITDEPTH];	/*  the location stack			*/
  YYLTYPE *yyls = yylsa;
  YYLTYPE *yylsp;

#define YYPOPSTACK   (yyvsp--, yyssp--, yylsp--)
#else
#define YYPOPSTACK   (yyvsp--, yyssp--)
#endif

  int yystacksize = YYINITDEPTH;

#ifdef YYPURE
  int yychar;
  YYSTYPE yylval;
  int yynerrs;
#ifdef YYLSP_NEEDED
  YYLTYPE yylloc;
#endif
#endif

  YYSTYPE yyval;		/*  the variable used to return		*/
				/*  semantic values from the action	*/
				/*  routines				*/

  int yylen;

#if YYDEBUG != 0
  if (yydebug)
    fprintf(stderr, "Starting parse\n");
#endif

  yystate = 0;
  yyerrstatus = 0;
  yynerrs = 0;
  yychar = YYEMPTY;		/* Cause a token to be read.  */

  /* Initialize stack pointers.
     Waste one element of value and location stack
     so that they stay on the same level as the state stack.
     The wasted elements are never initialized.  */

  yyssp = yyss - 1;
  yyvsp = yyvs;
#ifdef YYLSP_NEEDED
  yylsp = yyls;
#endif

/* Push a new state, which is found in  yystate  .  */
/* In all cases, when you get here, the value and location stacks
   have just been pushed. so pushing a state here evens the stacks.  */
yynewstate:

  *++yyssp = yystate;

  if (yyssp >= yyss + yystacksize - 1)
    {
      /* Give user a chance to reallocate the stack */
      /* Use copies of these so that the &'s don't force the real ones into memory. */
      YYSTYPE *yyvs1 = yyvs;
      short *yyss1 = yyss;
#ifdef YYLSP_NEEDED
      YYLTYPE *yyls1 = yyls;
#endif

      /* Get the current used size of the three stacks, in elements.  */
      int size = yyssp - yyss + 1;

#ifdef yyoverflow
      /* Each stack pointer address is followed by the size of
	 the data in use in that stack, in bytes.  */
#ifdef YYLSP_NEEDED
      /* This used to be a conditional around just the two extra args,
	 but that might be undefined if yyoverflow is a macro.  */
      yyoverflow("parser stack overflow",
		 &yyss1, size * sizeof (*yyssp),
		 &yyvs1, size * sizeof (*yyvsp),
		 &yyls1, size * sizeof (*yylsp),
		 &yystacksize);
#else
      yyoverflow("parser stack overflow",
		 &yyss1, size * sizeof (*yyssp),
		 &yyvs1, size * sizeof (*yyvsp),
		 &yystacksize);
#endif

      yyss = yyss1; yyvs = yyvs1;
#ifdef YYLSP_NEEDED
      yyls = yyls1;
#endif
#else /* no yyoverflow */
      /* Extend the stack our own way.  */
      if (yystacksize >= YYMAXDEPTH)
	{
	  yyerror("parser stack overflow");
	  return 2;
	}
      yystacksize *= 2;
      if (yystacksize > YYMAXDEPTH)
	yystacksize = YYMAXDEPTH;
      yyss = (short *) alloca (yystacksize * sizeof (*yyssp));
      __yy_bcopy ((char *)yyss1, (char *)yyss, size * sizeof (*yyssp));
      yyvs = (YYSTYPE *) alloca (yystacksize * sizeof (*yyvsp));
      __yy_bcopy ((char *)yyvs1, (char *)yyvs, size * sizeof (*yyvsp));
#ifdef YYLSP_NEEDED
      yyls = (YYLTYPE *) alloca (yystacksize * sizeof (*yylsp));
      __yy_bcopy ((char *)yyls1, (char *)yyls, size * sizeof (*yylsp));
#endif
#endif /* no yyoverflow */

      yyssp = yyss + size - 1;
      yyvsp = yyvs + size - 1;
#ifdef YYLSP_NEEDED
      yylsp = yyls + size - 1;
#endif

#if YYDEBUG != 0
      if (yydebug)
	fprintf(stderr, "Stack size increased to %d\n", yystacksize);
#endif

      if (yyssp >= yyss + yystacksize - 1)
	YYABORT;
    }

#if YYDEBUG != 0
  if (yydebug)
    fprintf(stderr, "Entering state %d\n", yystate);
#endif

  goto yybackup;
 yybackup:

/* Do appropriate processing given the current state.  */
/* Read a lookahead token if we need one and don't already have one.  */
/* yyresume: */

  /* First try to decide what to do without reference to lookahead token.  */

  yyn = yypact[yystate];
  if (yyn == YYFLAG)
    goto yydefault;

  /* Not known => get a lookahead token if don't already have one.  */

  /* yychar is either YYEMPTY or YYEOF
     or a valid token in external form.  */

  if (yychar == YYEMPTY)
    {
#if YYDEBUG != 0
      if (yydebug)
	fprintf(stderr, "Reading a token: ");
#endif
      yychar = YYLEX;
    }

  /* Convert token to internal form (in yychar1) for indexing tables with */

  if (yychar <= 0)		/* This means end of input. */
    {
      yychar1 = 0;
      yychar = YYEOF;		/* Don't call YYLEX any more */

#if YYDEBUG != 0
      if (yydebug)
	fprintf(stderr, "Now at end of input.\n");
#endif
    }
  else
    {
      yychar1 = YYTRANSLATE(yychar);

#if YYDEBUG != 0
      if (yydebug)
	{
	  fprintf (stderr, "Next token is %d (%s", yychar, yytname[yychar1]);
	  /* Give the individual parser a way to print the precise meaning
	     of a token, for further debugging info.  */
#ifdef YYPRINT
	  YYPRINT (stderr, yychar, yylval);
#endif
	  fprintf (stderr, ")\n");
	}
#endif
    }

  yyn += yychar1;
  if (yyn < 0 || yyn > YYLAST || yycheck[yyn] != yychar1)
    goto yydefault;

  yyn = yytable[yyn];

  /* yyn is what to do for this token type in this state.
     Negative => reduce, -yyn is rule number.
     Positive => shift, yyn is new state.
       New state is final state => don't bother to shift,
       just return success.
     0, or most negative number => error.  */

  if (yyn < 0)
    {
      if (yyn == YYFLAG)
	goto yyerrlab;
      yyn = -yyn;
      goto yyreduce;
    }
  else if (yyn == 0)
    goto yyerrlab;

  if (yyn == YYFINAL)
    YYACCEPT;

  /* Shift the lookahead token.  */

#if YYDEBUG != 0
  if (yydebug)
    fprintf(stderr, "Shifting token %d (%s), ", yychar, yytname[yychar1]);
#endif

  /* Discard the token being shifted unless it is eof.  */
  if (yychar != YYEOF)
    yychar = YYEMPTY;

  *++yyvsp = yylval;
#ifdef YYLSP_NEEDED
  *++yylsp = yylloc;
#endif

  /* count tokens shifted since error; after three, turn off error status.  */
  if (yyerrstatus) yyerrstatus--;

  yystate = yyn;
  goto yynewstate;

/* Do the default action for the current state.  */
yydefault:

  yyn = yydefact[yystate];
  if (yyn == 0)
    goto yyerrlab;

/* Do a reduction.  yyn is the number of a rule to reduce with.  */
yyreduce:
  yylen = yyr2[yyn];
  if (yylen > 0)
    yyval = yyvsp[1-yylen]; /* implement default value of the action */

#if YYDEBUG != 0
  if (yydebug)
    {
      int i;

      fprintf (stderr, "Reducing via rule %d (line %d), ",
	       yyn, yyrline[yyn]);

      /* Print the symbols being reduced, and their result.  */
      for (i = yyprhs[yyn]; yyrhs[i] > 0; i++)
	fprintf (stderr, "%s ", yytname[yyrhs[i]]);
      fprintf (stderr, " -> %s\n", yytname[yyr1[yyn]]);
    }
#endif


  switch (yyn) {

case 1:
#line 323 "vex.y"
{vex_ptr=make_vex(yyvsp[-1].llptr,yyvsp[0].llptr);;
    break;}
case 2:
#line 324 "vex.y"
{vex_ptr=make_vex(yyvsp[0].llptr,NULL);;
    break;}
case 3:
#line 326 "vex.y"
{yyval.llptr=add_list(yyvsp[-1].llptr,yyvsp[0].lwptr);;
    break;}
case 4:
#line 327 "vex.y"
{yyval.llptr=add_list(NULL,yyvsp[0].lwptr);;
    break;}
case 5:
#line 329 "vex.y"
{yyval.lwptr=make_lowl(T_VEX_REV,yyvsp[0].dvptr);;
    break;}
case 6:
#line 330 "vex.y"
{yyval.lwptr=make_lowl(T_COMMENT,yyvsp[0].sval);;
    break;}
case 7:
#line 331 "vex.y"
{yyval.lwptr=make_lowl(T_COMMENT_TRAILING,yyvsp[0].sval);;
    break;}
case 8:
#line 335 "vex.y"
{yyval.dvptr=yyvsp[-1].dvptr;;
    break;}
case 9:
#line 340 "vex.y"
{yyval.llptr=add_list(yyvsp[-1].llptr,yyvsp[0].blptr);;
    break;}
case 10:
#line 341 "vex.y"
{yyval.llptr=add_list(NULL,yyvsp[0].blptr);;
    break;}
case 11:
#line 343 "vex.y"
{yyval.blptr=make_block(B_GLOBAL,yyvsp[0].llptr);;
    break;}
case 12:
#line 344 "vex.y"
{yyval.blptr=make_block(B_STATION,yyvsp[0].llptr);;
    break;}
case 13:
#line 345 "vex.y"
{yyval.blptr=make_block(B_MODE,yyvsp[0].llptr);;
    break;}
case 14:
#line 346 "vex.y"
{yyval.blptr=make_block(B_FREQ,yyvsp[0].llptr);;
    break;}
case 15:
#line 347 "vex.y"
{yyval.blptr=make_block(B_SCHED,yyvsp[0].llptr);;
    break;}
case 16:
#line 348 "vex.y"
{yyval.blptr=make_block(B_ANTENNA,yyvsp[0].llptr);;
    break;}
case 17:
#line 349 "vex.y"
{yyval.blptr=make_block(B_BBC,yyvsp[0].llptr);;
    break;}
case 18:
#line 350 "vex.y"
{yyval.blptr=make_block(B_CLOCK,yyvsp[0].llptr);;
    break;}
case 19:
#line 351 "vex.y"
{yyval.blptr=make_block(B_DAS,yyvsp[0].llptr);;
    break;}
case 20:
#line 352 "vex.y"
{yyval.blptr=make_block(B_EOP,yyvsp[0].llptr);;
    break;}
case 21:
#line 353 "vex.y"
{yyval.blptr=make_block(B_EXPER,yyvsp[0].llptr);;
    break;}
case 22:
#line 354 "vex.y"
{yyval.blptr=make_block(B_HEAD_POS,yyvsp[0].llptr);;
    break;}
case 23:
#line 355 "vex.y"
{yyval.blptr=make_block(B_IF,yyvsp[0].llptr);;
    break;}
case 24:
#line 356 "vex.y"
{yyval.blptr=make_block(B_PASS_ORDER,yyvsp[0].llptr);;
    break;}
case 25:
#line 357 "vex.y"
{yyval.blptr=make_block(B_PHASE_CAL,yyvsp[0].llptr);;
    break;}
case 26:
#line 358 "vex.y"
{yyval.blptr=make_block(B_PROC_TIMING,yyvsp[0].llptr);;
    break;}
case 27:
#line 359 "vex.y"
{yyval.blptr=make_block(B_ROLL,yyvsp[0].llptr);;
    break;}
case 28:
#line 361 "vex.y"
{yyval.blptr=make_block(B_SCHEDULING_PARMS,yyvsp[0].llptr);;
    break;}
case 29:
#line 362 "vex.y"
{yyval.blptr=make_block(B_SEFD,yyvsp[0].llptr);;
    break;}
case 30:
#line 363 "vex.y"
{yyval.blptr=make_block(B_SITE,yyvsp[0].llptr);;
    break;}
case 31:
#line 364 "vex.y"
{yyval.blptr=make_block(B_SOURCE,yyvsp[0].llptr);;
    break;}
case 32:
#line 365 "vex.y"
{yyval.blptr=make_block(B_TAPELOG_OBS,yyvsp[0].llptr);;
    break;}
case 33:
#line 366 "vex.y"
{yyval.blptr=make_block(B_TRACKS,yyvsp[0].llptr);;
    break;}
case 34:
#line 370 "vex.y"
{yyval.llptr=yyvsp[0].llptr;
    break;}
case 35:
#line 371 "vex.y"
{yyval.llptr=NULL;;
    break;}
case 36:
#line 375 "vex.y"
{yyval.llptr=yyvsp[0].llptr;
    break;}
case 37:
#line 376 "vex.y"
{yyval.llptr=NULL;
    break;}
case 38:
#line 378 "vex.y"
{yyval.llptr=add_list(yyvsp[-1].llptr,yyvsp[0].lwptr);;
    break;}
case 39:
#line 379 "vex.y"
{yyval.llptr=add_list(NULL,yyvsp[0].lwptr);;
    break;}
case 40:
#line 381 "vex.y"
{yyval.lwptr=make_lowl(T_DEF,yyvsp[0].dfptr);;
    break;}
case 41:
#line 382 "vex.y"
{yyval.lwptr=make_lowl(T_COMMENT,yyvsp[0].sval);;
    break;}
case 42:
#line 383 "vex.y"
{yyval.lwptr=make_lowl(T_COMMENT_TRAILING,yyvsp[0].sval);;
    break;}
case 43:
#line 385 "vex.y"
{yyval.dfptr=make_def(yyvsp[-4].sval,yyvsp[-2].llptr);
    break;}
case 44:
#line 386 "vex.y"
{yyval.dfptr=make_def(yyvsp[-3].sval,NULL);
    break;}
case 45:
#line 390 "vex.y"
{yyval.llptr=yyvsp[0].llptr;
    break;}
case 46:
#line 391 "vex.y"
{yyval.llptr=NULL;;
    break;}
case 47:
#line 393 "vex.y"
{yyval.llptr=add_list(yyvsp[-1].llptr,yyvsp[0].lwptr);
    break;}
case 48:
#line 394 "vex.y"
{yyval.llptr=add_list(NULL,yyvsp[0].lwptr);
    break;}
case 49:
#line 396 "vex.y"
{yyval.lwptr=make_lowl(T_DEF,yyvsp[0].dfptr);;
    break;}
case 50:
#line 397 "vex.y"
{yyval.lwptr=make_lowl(T_COMMENT,yyvsp[0].sval);;
    break;}
case 51:
#line 398 "vex.y"
{yyval.lwptr=make_lowl(T_COMMENT_TRAILING,yyvsp[0].sval);;
    break;}
case 52:
#line 400 "vex.y"
{yyval.dfptr=make_def(yyvsp[-4].sval,yyvsp[-2].llptr);;
    break;}
case 53:
#line 402 "vex.y"
{yyval.dfptr=make_def(yyvsp[-3].sval,NULL);;
    break;}
case 54:
#line 406 "vex.y"
{yyval.llptr=add_list(yyvsp[-1].llptr,yyvsp[0].lwptr);
    break;}
case 55:
#line 407 "vex.y"
{yyval.llptr=add_list(NULL,yyvsp[0].lwptr);
    break;}
case 56:
#line 409 "vex.y"
{yyval.lwptr=make_lowl(T_REF,yyvsp[0].qrptr);;
    break;}
case 57:
#line 410 "vex.y"
{yyval.lwptr=make_lowl(T_COMMENT,yyvsp[0].sval);;
    break;}
case 58:
#line 411 "vex.y"
{yyval.lwptr=make_lowl(T_COMMENT_TRAILING,yyvsp[0].sval);;
    break;}
case 59:
#line 413 "vex.y"
{yyval.qrptr=make_qref(yyvsp[-3].ival,yyvsp[-1].sval,NULL);;
    break;}
case 60:
#line 414 "vex.y"
{yyval.qrptr=yyvsp[0].qrptr;;
    break;}
case 61:
#line 416 "vex.y"
{yyval.ival=B_EXPER;;
    break;}
case 62:
#line 417 "vex.y"
{yyval.ival=B_SCHEDULING_PARMS;;
    break;}
case 63:
#line 418 "vex.y"
{yyval.ival=B_PROC_TIMING;;
    break;}
case 64:
#line 419 "vex.y"
{yyval.ival=B_EOP;;
    break;}
case 65:
#line 420 "vex.y"
{yyval.ival=B_FREQ;;
    break;}
case 66:
#line 421 "vex.y"
{yyval.ival=B_ANTENNA;;
    break;}
case 67:
#line 422 "vex.y"
{yyval.ival=B_BBC;;
    break;}
case 68:
#line 423 "vex.y"
{yyval.ival=B_CORR;;
    break;}
case 69:
#line 424 "vex.y"
{yyval.ival=B_DAS;;
    break;}
case 70:
#line 425 "vex.y"
{yyval.ival=B_HEAD_POS;;
    break;}
case 71:
#line 426 "vex.y"
{yyval.ival=B_PASS_ORDER;;
    break;}
case 72:
#line 427 "vex.y"
{yyval.ival=B_PHASE_CAL;;
    break;}
case 73:
#line 428 "vex.y"
{yyval.ival=B_ROLL;;
    break;}
case 74:
#line 429 "vex.y"
{yyval.ival=B_IF;;
    break;}
case 75:
#line 430 "vex.y"
{yyval.ival=B_SEFD;;
    break;}
case 76:
#line 431 "vex.y"
{yyval.ival=B_SITE;;
    break;}
case 77:
#line 432 "vex.y"
{yyval.ival=B_SOURCE;;
    break;}
case 78:
#line 433 "vex.y"
{yyval.ival=B_TRACKS;;
    break;}
case 79:
#line 434 "vex.y"
{yyval.ival=B_TAPELOG_OBS;;
    break;}
case 80:
#line 436 "vex.y"
{yyval.qrptr=make_qref(B_CLOCK,yyvsp[-2].sval,yyvsp[-1].llptr);;
    break;}
case 81:
#line 438 "vex.y"
{yyval.llptr=NULL;;
    break;}
case 82:
#line 439 "vex.y"
{yyval.llptr=add_list(NULL,yyvsp[0].sval);;
    break;}
case 83:
#line 441 "vex.y"
{yyval.llptr=add_list(yyvsp[-1].llptr,yyvsp[0].lwptr);;
    break;}
case 84:
#line 442 "vex.y"
{yyval.llptr=add_list(NULL,yyvsp[0].lwptr);;
    break;}
case 85:
#line 444 "vex.y"
{yyval.lwptr=make_lowl(T_REF,yyvsp[0].qrptr);;
    break;}
case 86:
#line 445 "vex.y"
{yyval.lwptr=make_lowl(T_COMMENT,yyvsp[0].sval);;
    break;}
case 87:
#line 446 "vex.y"
{yyval.lwptr=make_lowl(T_COMMENT_TRAILING,yyvsp[0].sval);;
    break;}
case 88:
#line 448 "vex.y"
{yyval.qrptr=make_qref(yyvsp[-4].ival,yyvsp[-2].sval,yyvsp[-1].llptr);;
    break;}
case 89:
#line 449 "vex.y"
{yyval.qrptr=make_qref(yyvsp[-3].ival,yyvsp[-1].sval,NULL);;
    break;}
case 90:
#line 451 "vex.y"
{yyval.llptr=add_list(yyvsp[-2].llptr,yyvsp[0].sval);;
    break;}
case 91:
#line 452 "vex.y"
{yyval.llptr=add_list(NULL,yyvsp[0].sval);;
    break;}
case 92:
#line 456 "vex.y"
{yyval.llptr=yyvsp[0].llptr;
    break;}
case 93:
#line 457 "vex.y"
{yyval.llptr=NULL;;
    break;}
case 94:
#line 459 "vex.y"
{yyval.llptr=add_list(yyvsp[-1].llptr,yyvsp[0].lwptr);;
    break;}
case 95:
#line 460 "vex.y"
{yyval.llptr=add_list(NULL,yyvsp[0].lwptr);;
    break;}
case 96:
#line 462 "vex.y"
{yyval.lwptr=make_lowl(T_DEF,yyvsp[0].dfptr);;
    break;}
case 97:
#line 463 "vex.y"
{yyval.lwptr=make_lowl(T_COMMENT,yyvsp[0].sval);;
    break;}
case 98:
#line 464 "vex.y"
{yyval.lwptr=make_lowl(T_COMMENT_TRAILING,yyvsp[0].sval);;
    break;}
case 99:
#line 467 "vex.y"
{yyval.dfptr=make_def(yyvsp[-4].sval,yyvsp[-2].llptr);;
    break;}
case 100:
#line 468 "vex.y"
{yyval.dfptr=make_def(yyvsp[-3].sval,NULL);;
    break;}
case 101:
#line 470 "vex.y"
{yyval.llptr=add_list(yyvsp[-1].llptr,yyvsp[0].lwptr);;
    break;}
case 102:
#line 471 "vex.y"
{yyval.llptr=add_list(NULL,yyvsp[0].lwptr);;
    break;}
case 103:
#line 473 "vex.y"
{yyval.lwptr=make_lowl(T_START,yyvsp[0].sval);;
    break;}
case 104:
#line 474 "vex.y"
{yyval.lwptr=make_lowl(T_MODE,yyvsp[0].sval);;
    break;}
case 105:
#line 475 "vex.y"
{yyval.lwptr=make_lowl(T_SOURCE,yyvsp[0].sval);;
    break;}
case 106:
#line 476 "vex.y"
{yyval.lwptr=make_lowl(T_STATION,yyvsp[0].snptr);;
    break;}
case 107:
#line 477 "vex.y"
{yyval.lwptr=make_lowl(T_COMMENT,yyvsp[0].sval);;
    break;}
case 108:
#line 478 "vex.y"
{yyval.lwptr=make_lowl(T_COMMENT_TRAILING,yyvsp[0].sval);;
    break;}
case 109:
#line 480 "vex.y"
{yyval.sval=yyvsp[-1].sval;;
    break;}
case 110:
#line 482 "vex.y"
{yyval.sval=yyvsp[-1].sval;;
    break;}
case 111:
#line 484 "vex.y"
{yyval.sval=yyvsp[-1].sval;;
    break;}
case 112:
#line 493 "vex.y"
{yyval.snptr=make_station(yyvsp[-13].sval,yyvsp[-11].dvptr,yyvsp[-9].dvptr,yyvsp[-7].dvptr,yyvsp[-5].sval,yyvsp[-3].sval,yyvsp[-1].llptr);;
    break;}
case 113:
#line 495 "vex.y"
{yyval.dvptr=NULL;;
    break;}
case 114:
#line 496 "vex.y"
{yyval.dvptr=yyvsp[0].dvptr;;
    break;}
case 115:
#line 498 "vex.y"
{yyval.sval=NULL;;
    break;}
case 116:
#line 499 "vex.y"
{yyval.sval=yyvsp[0].sval;;
    break;}
case 117:
#line 501 "vex.y"
{yyval.sval=NULL;;
    break;}
case 118:
#line 502 "vex.y"
{yyval.sval=yyvsp[0].sval;;
    break;}
case 119:
#line 504 "vex.y"
{yyval.llptr=NULL;;
    break;}
case 120:
#line 505 "vex.y"
{yyval.llptr=add_list(NULL,yyvsp[0].dvptr);;
    break;}
case 121:
#line 506 "vex.y"
{yyval.llptr=add_list(add_list(NULL,yyvsp[-2].dvptr),yyvsp[0].dvptr);;
    break;}
case 122:
#line 510 "vex.y"
{yyval.llptr=yyvsp[0].llptr;
    break;}
case 123:
#line 511 "vex.y"
{yyval.llptr=NULL;;
    break;}
case 124:
#line 513 "vex.y"
{yyval.llptr=add_list(yyvsp[-1].llptr,yyvsp[0].lwptr);;
    break;}
case 125:
#line 514 "vex.y"
{yyval.llptr=add_list(NULL,yyvsp[0].lwptr);;
    break;}
case 126:
#line 516 "vex.y"
{yyval.lwptr=make_lowl(T_DEF,yyvsp[0].dfptr);;
    break;}
case 127:
#line 517 "vex.y"
{yyval.lwptr=make_lowl(T_COMMENT,yyvsp[0].sval);;
    break;}
case 128:
#line 518 "vex.y"
{yyval.lwptr=make_lowl(T_COMMENT_TRAILING,yyvsp[0].sval);;
    break;}
case 129:
#line 521 "vex.y"
{yyval.dfptr=make_def(yyvsp[-4].sval,yyvsp[-2].llptr);;
    break;}
case 130:
#line 522 "vex.y"
{yyval.dfptr=make_def(yyvsp[-3].sval,NULL);;
    break;}
case 131:
#line 524 "vex.y"
{yyval.llptr=add_list(yyvsp[-1].llptr,yyvsp[0].lwptr);;
    break;}
case 132:
#line 525 "vex.y"
{yyval.llptr=add_list(NULL,yyvsp[0].lwptr);;
    break;}
case 133:
#line 527 "vex.y"
{yyval.lwptr=make_lowl(T_ANT_DIAM,yyvsp[0].dvptr);;
    break;}
case 134:
#line 528 "vex.y"
{yyval.lwptr=make_lowl(T_AXIS_TYPE,yyvsp[0].atptr);;
    break;}
case 135:
#line 529 "vex.y"
{yyval.lwptr=make_lowl(T_AXIS_OFFSET,yyvsp[0].dvptr);;
    break;}
case 136:
#line 530 "vex.y"
{yyval.lwptr=make_lowl(T_ANT_MOTION,yyvsp[0].amptr);;
    break;}
case 137:
#line 531 "vex.y"
{yyval.lwptr=make_lowl(T_POINTING_SECTOR,yyvsp[0].psptr);;
    break;}
case 138:
#line 532 "vex.y"
{yyval.lwptr=make_lowl(T_REF,yyvsp[0].exptr);;
    break;}
case 139:
#line 533 "vex.y"
{yyval.lwptr=make_lowl(T_COMMENT,yyvsp[0].sval);;
    break;}
case 140:
#line 534 "vex.y"
{yyval.lwptr=make_lowl(T_COMMENT_TRAILING,yyvsp[0].sval);;
    break;}
case 141:
#line 536 "vex.y"
{yyval.dvptr=yyvsp[-1].dvptr;;
    break;}
case 142:
#line 539 "vex.y"
{yyval.atptr=make_axis_type(yyvsp[-3].sval,yyvsp[-1].sval);;
    break;}
case 143:
#line 541 "vex.y"
{yyval.dvptr=yyvsp[-1].dvptr;;
    break;}
case 144:
#line 546 "vex.y"
{yyval.amptr=make_ant_motion(yyvsp[-5].sval,yyvsp[-3].dvptr,yyvsp[-1].dvptr);;
    break;}
case 145:
#line 555 "vex.y"
{yyval.psptr=make_pointing_sector(yyvsp[-13].sval,yyvsp[-11].sval,yyvsp[-9].dvptr,yyvsp[-7].dvptr,yyvsp[-5].sval,yyvsp[-3].dvptr,yyvsp[-1].dvptr);;
    break;}
case 146:
#line 559 "vex.y"
{yyval.llptr=yyvsp[0].llptr;
    break;}
case 147:
#line 560 "vex.y"
{yyval.llptr=NULL;;
    break;}
case 148:
#line 562 "vex.y"
{yyval.llptr=add_list(yyvsp[-1].llptr,yyvsp[0].lwptr);;
    break;}
case 149:
#line 563 "vex.y"
{yyval.llptr=add_list(NULL,yyvsp[0].lwptr);;
    break;}
case 150:
#line 565 "vex.y"
{yyval.lwptr=make_lowl(T_DEF,yyvsp[0].dfptr);;
    break;}
case 151:
#line 566 "vex.y"
{yyval.lwptr=make_lowl(T_COMMENT,yyvsp[0].sval);;
    break;}
case 152:
#line 567 "vex.y"
{yyval.lwptr=make_lowl(T_COMMENT_TRAILING,yyvsp[0].sval);;
    break;}
case 153:
#line 569 "vex.y"
{yyval.dfptr=make_def(yyvsp[-4].sval,yyvsp[-2].llptr);;
    break;}
case 154:
#line 571 "vex.y"
{yyval.dfptr=make_def(yyvsp[-3].sval,NULL);;
    break;}
case 155:
#line 573 "vex.y"
{yyval.llptr=add_list(yyvsp[-1].llptr,yyvsp[0].lwptr);;
    break;}
case 156:
#line 574 "vex.y"
{yyval.llptr=add_list(NULL,yyvsp[0].lwptr);;
    break;}
case 157:
#line 576 "vex.y"
{yyval.lwptr=make_lowl(T_BBC_ASSIGN,yyvsp[0].baptr);;
    break;}
case 158:
#line 577 "vex.y"
{yyval.lwptr=make_lowl(T_REF,yyvsp[0].exptr);;
    break;}
case 159:
#line 578 "vex.y"
{yyval.lwptr=make_lowl(T_COMMENT,yyvsp[0].sval);;
    break;}
case 160:
#line 579 "vex.y"
{yyval.lwptr=make_lowl(T_COMMENT_TRAILING,yyvsp[0].sval);;
    break;}
case 161:
#line 582 "vex.y"
{yyval.baptr=make_bbc_assign(yyvsp[-5].sval,yyvsp[-3].dvptr,yyvsp[-1].sval);;
    break;}
case 162:
#line 586 "vex.y"
{yyval.llptr=yyvsp[0].llptr;
    break;}
case 163:
#line 587 "vex.y"
{yyval.llptr=NULL;;
    break;}
case 164:
#line 589 "vex.y"
{yyval.llptr=add_list(yyvsp[-1].llptr,yyvsp[0].lwptr);;
    break;}
case 165:
#line 590 "vex.y"
{yyval.llptr=add_list(NULL,yyvsp[0].lwptr);;
    break;}
case 166:
#line 592 "vex.y"
{yyval.lwptr=make_lowl(T_DEF,yyvsp[0].dfptr);;
    break;}
case 167:
#line 593 "vex.y"
{yyval.lwptr=make_lowl(T_COMMENT,yyvsp[0].sval);;
    break;}
case 168:
#line 594 "vex.y"
{yyval.lwptr=make_lowl(T_COMMENT_TRAILING,yyvsp[0].sval);;
    break;}
case 169:
#line 597 "vex.y"
{yyval.dfptr=make_def(yyvsp[-4].sval,yyvsp[-2].llptr);;
    break;}
case 170:
#line 599 "vex.y"
{yyval.dfptr=make_def(yyvsp[-3].sval,NULL);;
    break;}
case 171:
#line 601 "vex.y"
{yyval.llptr=add_list(yyvsp[-1].llptr,yyvsp[0].lwptr);;
    break;}
case 172:
#line 602 "vex.y"
{yyval.llptr=add_list(NULL,yyvsp[0].lwptr);;
    break;}
case 173:
#line 604 "vex.y"
{yyval.lwptr=make_lowl(T_CLOCK_EARLY,yyvsp[0].dvptr);;
    break;}
case 174:
#line 606 "vex.y"
{yyval.lwptr=make_lowl(T_CLOCK_EARLY_EPOCH,yyvsp[0].sval);;
    break;}
case 175:
#line 607 "vex.y"
{yyval.lwptr=make_lowl(T_CLOCK_RATE,yyvsp[0].dvptr);;
    break;}
case 176:
#line 608 "vex.y"
{yyval.lwptr=make_lowl(T_REF,yyvsp[0].exptr);;
    break;}
case 177:
#line 609 "vex.y"
{yyval.lwptr=make_lowl(T_COMMENT,yyvsp[0].sval);;
    break;}
case 178:
#line 610 "vex.y"
{yyval.lwptr=make_lowl(T_COMMENT_TRAILING,yyvsp[0].sval);;
    break;}
case 179:
#line 612 "vex.y"
{yyval.dvptr=yyvsp[-1].dvptr;;
    break;}
case 180:
#line 614 "vex.y"
{yyval.sval=yyvsp[-1].sval;;
    break;}
case 181:
#line 616 "vex.y"
{yyval.dvptr=yyvsp[-1].dvptr;;
    break;}
case 182:
#line 620 "vex.y"
{yyval.llptr=yyvsp[0].llptr;
    break;}
case 183:
#line 621 "vex.y"
{yyval.llptr=NULL;;
    break;}
case 184:
#line 623 "vex.y"
{yyval.llptr=add_list(yyvsp[-1].llptr,yyvsp[0].lwptr);;
    break;}
case 185:
#line 624 "vex.y"
{yyval.llptr=add_list(NULL,yyvsp[0].lwptr);;
    break;}
case 186:
#line 626 "vex.y"
{yyval.lwptr=make_lowl(T_DEF,yyvsp[0].dfptr);;
    break;}
case 187:
#line 627 "vex.y"
{yyval.lwptr=make_lowl(T_COMMENT,yyvsp[0].sval);;
    break;}
case 188:
#line 628 "vex.y"
{yyval.lwptr=make_lowl(T_COMMENT_TRAILING,yyvsp[0].sval);;
    break;}
case 189:
#line 630 "vex.y"
{yyval.dfptr=make_def(yyvsp[-4].sval,yyvsp[-2].llptr);;
    break;}
case 190:
#line 632 "vex.y"
{yyval.dfptr=make_def(yyvsp[-3].sval,NULL);;
    break;}
case 191:
#line 634 "vex.y"
{yyval.llptr=add_list(yyvsp[-1].llptr,yyvsp[0].lwptr);;
    break;}
case 192:
#line 635 "vex.y"
{yyval.llptr=add_list(NULL,yyvsp[0].lwptr);;
    break;}
case 193:
#line 637 "vex.y"
{yyval.lwptr=make_lowl(T_RECORD_TRANSPORT,yyvsp[0].sval);;
    break;}
case 194:
#line 638 "vex.y"
{yyval.lwptr=make_lowl(T_ELECTRONICS_RACK,yyvsp[0].sval);;
    break;}
case 195:
#line 639 "vex.y"
{yyval.lwptr=make_lowl(T_NUMBER_DRIVES,yyvsp[0].dvptr);;
    break;}
case 196:
#line 640 "vex.y"
{yyval.lwptr=make_lowl(T_HEADSTACK,yyvsp[0].hsptr);;
    break;}
case 197:
#line 641 "vex.y"
{yyval.lwptr=make_lowl(T_DATA_SOURCE,yyvsp[0].dsptr);;
    break;}
case 198:
#line 642 "vex.y"
{yyval.lwptr=make_lowl(T_RECORD_DENSITY,yyvsp[0].dvptr);;
    break;}
case 199:
#line 643 "vex.y"
{yyval.lwptr=make_lowl(T_TAPE_LENGTH,yyvsp[0].dvptr);;
    break;}
case 200:
#line 645 "vex.y"
{yyval.lwptr=make_lowl(T_RECORDING_SYSTEM_ID,yyvsp[0].dvptr);;
    break;}
case 201:
#line 646 "vex.y"
{yyval.lwptr=make_lowl(T_TAPE_MOTION,yyvsp[0].tmptr);;
    break;}
case 202:
#line 647 "vex.y"
{yyval.lwptr=make_lowl(T_TAPE_CONTROL,yyvsp[0].sval);;
    break;}
case 203:
#line 648 "vex.y"
{yyval.lwptr=make_lowl(T_REF,yyvsp[0].exptr);;
    break;}
case 204:
#line 649 "vex.y"
{yyval.lwptr=make_lowl(T_COMMENT,yyvsp[0].sval);;
    break;}
case 205:
#line 650 "vex.y"
{yyval.lwptr=make_lowl(T_COMMENT_TRAILING,yyvsp[0].sval);;
    break;}
case 206:
#line 652 "vex.y"
{yyval.sval=yyvsp[-1].sval;
    break;}
case 207:
#line 654 "vex.y"
{yyval.sval=yyvsp[-1].sval;
    break;}
case 208:
#line 656 "vex.y"
{yyval.dvptr=yyvsp[-1].dvptr;;
    break;}
case 209:
#line 659 "vex.y"
{yyval.hsptr=make_headstack(yyvsp[-5].dvptr,yyvsp[-3].sval,yyvsp[-1].sval);;
    break;}
case 210:
#line 663 "vex.y"
{yyval.dsptr=make_data_source(yyvsp[-17].sval,yyvsp[-15].sval,yyvsp[-13].sval,yyvsp[-11].sval,yyvsp[-9].sval,yyvsp[-7].sval,yyvsp[-5].sval,yyvsp[-3].sval,yyvsp[-1].sval);;
    break;}
case 211:
#line 665 "vex.y"
{yyval.dvptr=yyvsp[-1].dvptr;;
    break;}
case 212:
#line 667 "vex.y"
{yyval.dvptr=yyvsp[-1].dvptr;;
    break;}
case 213:
#line 669 "vex.y"
{yyval.dvptr=yyvsp[-1].dvptr;;
    break;}
case 214:
#line 672 "vex.y"
{yyval.tmptr=make_tape_motion(yyvsp[-2].sval,yyvsp[-1].dvptr);;
    break;}
case 215:
#line 674 "vex.y"
{yyval.dvptr=NULL;;
    break;}
case 216:
#line 675 "vex.y"
{yyval.dvptr=yyvsp[0].dvptr;;
    break;}
case 217:
#line 677 "vex.y"
{yyval.sval=yyvsp[-1].sval;;
    break;}
case 218:
#line 681 "vex.y"
{yyval.llptr=yyvsp[0].llptr;
    break;}
case 219:
#line 682 "vex.y"
{yyval.llptr=NULL;;
    break;}
case 220:
#line 684 "vex.y"
{yyval.llptr=add_list(yyvsp[-1].llptr,yyvsp[0].lwptr);;
    break;}
case 221:
#line 685 "vex.y"
{yyval.llptr=add_list(NULL,yyvsp[0].lwptr);;
    break;}
case 222:
#line 687 "vex.y"
{yyval.lwptr=make_lowl(T_DEF,yyvsp[0].dfptr);;
    break;}
case 223:
#line 688 "vex.y"
{yyval.lwptr=make_lowl(T_COMMENT,yyvsp[0].sval);;
    break;}
case 224:
#line 689 "vex.y"
{yyval.lwptr=make_lowl(T_COMMENT_TRAILING,yyvsp[0].sval);;
    break;}
case 225:
#line 691 "vex.y"
{yyval.dfptr=make_def(yyvsp[-4].sval,yyvsp[-2].llptr);;
    break;}
case 226:
#line 693 "vex.y"
{yyval.dfptr=make_def(yyvsp[-3].sval,NULL);;
    break;}
case 227:
#line 695 "vex.y"
{yyval.llptr=add_list(yyvsp[-1].llptr,yyvsp[0].lwptr);;
    break;}
case 228:
#line 696 "vex.y"
{yyval.llptr=add_list(NULL,yyvsp[0].lwptr);;
    break;}
case 229:
#line 698 "vex.y"
{yyval.lwptr=make_lowl(T_TAI_UTC,yyvsp[0].dvptr);;
    break;}
case 230:
#line 699 "vex.y"
{yyval.lwptr=make_lowl(T_A1_TAI,yyvsp[0].dvptr);;
    break;}
case 231:
#line 700 "vex.y"
{yyval.lwptr=make_lowl(T_EOP_REF_EPOCH,yyvsp[0].sval);;
    break;}
case 232:
#line 701 "vex.y"
{yyval.lwptr=make_lowl(T_NUM_EOP_POINTS,yyvsp[0].dvptr);;
    break;}
case 233:
#line 702 "vex.y"
{yyval.lwptr=make_lowl(T_EOP_INTERVAL,yyvsp[0].dvptr);;
    break;}
case 234:
#line 703 "vex.y"
{yyval.lwptr=make_lowl(T_UT1_UTC,yyvsp[0].llptr);;
    break;}
case 235:
#line 704 "vex.y"
{yyval.lwptr=make_lowl(T_X_WOBBLE,yyvsp[0].llptr);;
    break;}
case 236:
#line 705 "vex.y"
{yyval.lwptr=make_lowl(T_Y_WOBBLE,yyvsp[0].llptr);;
    break;}
case 237:
#line 706 "vex.y"
{yyval.lwptr=make_lowl(T_REF,yyvsp[0].exptr);;
    break;}
case 238:
#line 707 "vex.y"
{yyval.lwptr=make_lowl(T_COMMENT,yyvsp[0].sval);;
    break;}
case 239:
#line 708 "vex.y"
{yyval.lwptr=make_lowl(T_COMMENT_TRAILING,yyvsp[0].sval);;
    break;}
case 240:
#line 710 "vex.y"
{yyval.dvptr=yyvsp[-1].dvptr;;
    break;}
case 241:
#line 712 "vex.y"
{yyval.dvptr=yyvsp[-1].dvptr;;
    break;}
case 242:
#line 714 "vex.y"
{yyval.sval=yyvsp[-1].sval;
    break;}
case 243:
#line 716 "vex.y"
{yyval.dvptr=yyvsp[-1].dvptr;;
    break;}
case 244:
#line 718 "vex.y"
{yyval.dvptr=yyvsp[-1].dvptr;;
    break;}
case 245:
#line 720 "vex.y"
{yyval.llptr=yyvsp[-1].llptr;;
    break;}
case 246:
#line 721 "vex.y"
{yyval.llptr=NULL;;
    break;}
case 247:
#line 723 "vex.y"
{yyval.llptr=yyvsp[-1].llptr;;
    break;}
case 248:
#line 724 "vex.y"
{yyval.llptr=NULL;;
    break;}
case 249:
#line 726 "vex.y"
{yyval.llptr=yyvsp[-1].llptr;;
    break;}
case 250:
#line 727 "vex.y"
{yyval.llptr=NULL;;
    break;}
case 251:
#line 731 "vex.y"
{yyval.llptr=yyvsp[0].llptr;
    break;}
case 252:
#line 732 "vex.y"
{yyval.llptr=NULL;;
    break;}
case 253:
#line 734 "vex.y"
{yyval.llptr=add_list(yyvsp[-1].llptr,yyvsp[0].lwptr);;
    break;}
case 254:
#line 735 "vex.y"
{yyval.llptr=add_list(NULL,yyvsp[0].lwptr);;
    break;}
case 255:
#line 737 "vex.y"
{yyval.lwptr=make_lowl(T_DEF,yyvsp[0].dfptr);;
    break;}
case 256:
#line 738 "vex.y"
{yyval.lwptr=make_lowl(T_COMMENT,yyvsp[0].sval);;
    break;}
case 257:
#line 739 "vex.y"
{yyval.lwptr=make_lowl(T_COMMENT_TRAILING,yyvsp[0].sval);;
    break;}
case 258:
#line 742 "vex.y"
{yyval.dfptr=make_def(yyvsp[-4].sval,yyvsp[-2].llptr);;
    break;}
case 259:
#line 743 "vex.y"
{yyval.dfptr=make_def(yyvsp[-3].sval,NULL);;
    break;}
case 260:
#line 745 "vex.y"
{yyval.llptr=add_list(yyvsp[-1].llptr,yyvsp[0].lwptr);;
    break;}
case 261:
#line 746 "vex.y"
{yyval.llptr=add_list(NULL,yyvsp[0].lwptr);;
    break;}
case 262:
#line 748 "vex.y"
{yyval.lwptr=make_lowl(T_EXPER_NUM,yyvsp[0].dvptr);;
    break;}
case 263:
#line 749 "vex.y"
{yyval.lwptr=make_lowl(T_EXPER_NAME,yyvsp[0].sval);;
    break;}
case 264:
#line 751 "vex.y"
{yyval.lwptr=make_lowl(T_EXPER_NOMINAL_START,yyvsp[0].sval);;
    break;}
case 265:
#line 753 "vex.y"
{yyval.lwptr=make_lowl(T_EXPER_NOMINAL_STOP,yyvsp[0].sval);;
    break;}
case 266:
#line 754 "vex.y"
{yyval.lwptr=make_lowl(T_PI_NAME,yyvsp[0].sval);;
    break;}
case 267:
#line 755 "vex.y"
{yyval.lwptr=make_lowl(T_PI_EMAIL,yyvsp[0].sval);;
    break;}
case 268:
#line 756 "vex.y"
{yyval.lwptr=make_lowl(T_CONTACT_NAME,yyvsp[0].sval);;
    break;}
case 269:
#line 757 "vex.y"
{yyval.lwptr=make_lowl(T_CONTACT_EMAIL,yyvsp[0].sval);;
    break;}
case 270:
#line 758 "vex.y"
{yyval.lwptr=make_lowl(T_SCHEDULER_NAME,yyvsp[0].sval);;
    break;}
case 271:
#line 759 "vex.y"
{yyval.lwptr=make_lowl(T_SCHEDULER_EMAIL,yyvsp[0].sval);;
    break;}
case 272:
#line 761 "vex.y"
{yyval.lwptr=make_lowl(T_TARGET_CORRELATOR,yyvsp[0].sval);;
    break;}
case 273:
#line 762 "vex.y"
{yyval.lwptr=make_lowl(T_REF,yyvsp[0].exptr);;
    break;}
case 274:
#line 763 "vex.y"
{yyval.lwptr=make_lowl(T_COMMENT,yyvsp[0].sval);;
    break;}
case 275:
#line 764 "vex.y"
{yyval.lwptr=make_lowl(T_COMMENT_TRAILING,yyvsp[0].sval);;
    break;}
case 276:
#line 766 "vex.y"
{yyval.dvptr=yyvsp[-1].dvptr;;
    break;}
case 277:
#line 768 "vex.y"
{yyval.sval=yyvsp[-1].sval;;
    break;}
case 278:
#line 770 "vex.y"
{yyval.sval=yyvsp[-1].sval;;
    break;}
case 279:
#line 772 "vex.y"
{yyval.sval=yyvsp[-1].sval;;
    break;}
case 280:
#line 774 "vex.y"
{yyval.sval=yyvsp[-1].sval;;
    break;}
case 281:
#line 776 "vex.y"
{yyval.sval=yyvsp[-1].sval;;
    break;}
case 282:
#line 778 "vex.y"
{yyval.sval=yyvsp[-1].sval;;
    break;}
case 283:
#line 780 "vex.y"
{yyval.sval=yyvsp[-1].sval;;
    break;}
case 284:
#line 782 "vex.y"
{yyval.sval=yyvsp[-1].sval;;
    break;}
case 285:
#line 784 "vex.y"
{yyval.sval=yyvsp[-1].sval;;
    break;}
case 286:
#line 786 "vex.y"
{yyval.sval=yyvsp[-1].sval;;
    break;}
case 287:
#line 790 "vex.y"
{yyval.llptr=yyvsp[0].llptr;
    break;}
case 288:
#line 791 "vex.y"
{yyval.llptr=NULL;;
    break;}
case 289:
#line 793 "vex.y"
{yyval.llptr=add_list(yyvsp[-1].llptr,yyvsp[0].lwptr);;
    break;}
case 290:
#line 794 "vex.y"
{yyval.llptr=add_list(NULL,yyvsp[0].lwptr);;
    break;}
case 291:
#line 796 "vex.y"
{yyval.lwptr=make_lowl(T_DEF,yyvsp[0].dfptr);;
    break;}
case 292:
#line 797 "vex.y"
{yyval.lwptr=make_lowl(T_COMMENT,yyvsp[0].sval);;
    break;}
case 293:
#line 798 "vex.y"
{yyval.lwptr=make_lowl(T_COMMENT_TRAILING,yyvsp[0].sval);;
    break;}
case 294:
#line 800 "vex.y"
{yyval.dfptr=make_def(yyvsp[-4].sval,yyvsp[-2].llptr);;
    break;}
case 295:
#line 802 "vex.y"
{yyval.dfptr=make_def(yyvsp[-3].sval,NULL);;
    break;}
case 296:
#line 804 "vex.y"
{yyval.llptr=add_list(yyvsp[-1].llptr,yyvsp[0].lwptr);;
    break;}
case 297:
#line 805 "vex.y"
{yyval.llptr=add_list(NULL,yyvsp[0].lwptr);;
    break;}
case 298:
#line 807 "vex.y"
{yyval.lwptr=make_lowl(T_CHAN_DEF,yyvsp[0].cdptr);;
    break;}
case 299:
#line 808 "vex.y"
{yyval.lwptr=make_lowl(T_SAMPLE_RATE,yyvsp[0].dvptr);;
    break;}
case 300:
#line 809 "vex.y"
{yyval.lwptr=make_lowl(T_BITS_PER_SAMPLE,yyvsp[0].dvptr);;
    break;}
case 301:
#line 810 "vex.y"
{yyval.lwptr=make_lowl(T_SWITCHING_CYCLE,yyvsp[0].scptr);;
    break;}
case 302:
#line 811 "vex.y"
{yyval.lwptr=make_lowl(T_REF,yyvsp[0].exptr);;
    break;}
case 303:
#line 812 "vex.y"
{yyval.lwptr=make_lowl(T_COMMENT,yyvsp[0].sval);;
    break;}
case 304:
#line 813 "vex.y"
{yyval.lwptr=make_lowl(T_COMMENT_TRAILING,yyvsp[0].sval);;
    break;}
case 305:
#line 823 "vex.y"
{yyval.cdptr=make_chan_def(yyvsp[-15].sval,yyvsp[-13].sval,yyvsp[-11].dvptr,yyvsp[-9].sval,yyvsp[-7].dvptr,yyvsp[-5].sval,yyvsp[-3].sval,yyvsp[-1].sval,NULL);;
    break;}
case 306:
#line 832 "vex.y"
{yyval.cdptr=make_chan_def(yyvsp[-16].sval,yyvsp[-14].sval,yyvsp[-12].dvptr,yyvsp[-10].sval,yyvsp[-8].dvptr,yyvsp[-6].sval,yyvsp[-4].sval,yyvsp[-2].sval,yyvsp[-1].llptr);;
    break;}
case 307:
#line 841 "vex.y"
{yyval.cdptr=make_chan_def(NULL,yyvsp[-13].sval,yyvsp[-11].dvptr,yyvsp[-9].sval,yyvsp[-7].dvptr,yyvsp[-5].sval,yyvsp[-3].sval,yyvsp[-1].sval,NULL);;
    break;}
case 308:
#line 850 "vex.y"
{yyval.cdptr=make_chan_def(NULL,yyvsp[-14].sval,yyvsp[-12].dvptr,yyvsp[-10].sval,yyvsp[-8].dvptr,yyvsp[-6].sval,yyvsp[-4].sval,yyvsp[-2].sval,yyvsp[-1].llptr);;
    break;}
case 309:
#line 852 "vex.y"
{yyval.llptr=add_list(yyvsp[-1].llptr,yyvsp[0].dvptr);
    break;}
case 310:
#line 853 "vex.y"
{yyval.llptr=add_list(NULL,yyvsp[0].dvptr);;
    break;}
case 311:
#line 855 "vex.y"
{yyval.dvptr=yyvsp[0].dvptr;;
    break;}
case 312:
#line 857 "vex.y"
{yyval.dvptr=yyvsp[-1].dvptr;;
    break;}
case 313:
#line 859 "vex.y"
{yyval.dvptr=yyvsp[-1].dvptr;;
    break;}
case 314:
#line 862 "vex.y"
{yyval.scptr=make_switching_cycle(yyvsp[-3].sval,yyvsp[-1].llptr);;
    break;}
case 315:
#line 866 "vex.y"
{yyval.llptr=yyvsp[0].llptr;
    break;}
case 316:
#line 867 "vex.y"
{yyval.llptr=NULL;;
    break;}
case 317:
#line 869 "vex.y"
{yyval.llptr=add_list(yyvsp[-1].llptr,yyvsp[0].lwptr);;
    break;}
case 318:
#line 870 "vex.y"
{yyval.llptr=add_list(NULL,yyvsp[0].lwptr);;
    break;}
case 319:
#line 872 "vex.y"
{yyval.lwptr=make_lowl(T_DEF,yyvsp[0].dfptr);;
    break;}
case 320:
#line 873 "vex.y"
{yyval.lwptr=make_lowl(T_COMMENT,yyvsp[0].sval);;
    break;}
case 321:
#line 874 "vex.y"
{yyval.lwptr=make_lowl(T_COMMENT_TRAILING,yyvsp[0].sval);;
    break;}
case 322:
#line 877 "vex.y"
{yyval.dfptr=make_def(yyvsp[-4].sval,yyvsp[-2].llptr);;
    break;}
case 323:
#line 879 "vex.y"
{yyval.dfptr=make_def(yyvsp[-3].sval,NULL);;
    break;}
case 324:
#line 881 "vex.y"
{yyval.llptr=add_list(yyvsp[-1].llptr,yyvsp[0].lwptr);;
    break;}
case 325:
#line 882 "vex.y"
{yyval.llptr=add_list(NULL,yyvsp[0].lwptr);;
    break;}
case 326:
#line 884 "vex.y"
{yyval.lwptr=make_lowl(T_HEADSTACK_POS,yyvsp[0].hpptr);;
    break;}
case 327:
#line 885 "vex.y"
{yyval.lwptr=make_lowl(T_REF,yyvsp[0].exptr);;
    break;}
case 328:
#line 886 "vex.y"
{yyval.lwptr=make_lowl(T_COMMENT,yyvsp[0].sval);;
    break;}
case 329:
#line 887 "vex.y"
{yyval.lwptr=make_lowl(T_COMMENT_TRAILING,yyvsp[0].sval);;
    break;}
case 330:
#line 890 "vex.y"
{yyval.hpptr=make_headstack_pos(yyvsp[-3].dvptr,yyvsp[-1].llptr);;
    break;}
case 331:
#line 894 "vex.y"
{yyval.llptr=yyvsp[0].llptr;
    break;}
case 332:
#line 895 "vex.y"
{yyval.llptr=NULL;;
    break;}
case 333:
#line 897 "vex.y"
{yyval.llptr=add_list(yyvsp[-1].llptr,yyvsp[0].lwptr);;
    break;}
case 334:
#line 898 "vex.y"
{yyval.llptr=add_list(NULL,yyvsp[0].lwptr);;
    break;}
case 335:
#line 900 "vex.y"
{yyval.lwptr=make_lowl(T_DEF,yyvsp[0].dfptr);;
    break;}
case 336:
#line 901 "vex.y"
{yyval.lwptr=make_lowl(T_COMMENT,yyvsp[0].sval);;
    break;}
case 337:
#line 902 "vex.y"
{yyval.lwptr=make_lowl(T_COMMENT_TRAILING,yyvsp[0].sval);;
    break;}
case 338:
#line 904 "vex.y"
{yyval.dfptr=make_def(yyvsp[-4].sval,yyvsp[-2].llptr);;
    break;}
case 339:
#line 906 "vex.y"
{yyval.dfptr=make_def(yyvsp[-3].sval,NULL);;
    break;}
case 340:
#line 908 "vex.y"
{yyval.llptr=add_list(yyvsp[-1].llptr,yyvsp[0].lwptr);;
    break;}
case 341:
#line 909 "vex.y"
{yyval.llptr=add_list(NULL,yyvsp[0].lwptr);;
    break;}
case 342:
#line 911 "vex.y"
{yyval.lwptr=make_lowl(T_IF_DEF,yyvsp[0].ifptr);;
    break;}
case 343:
#line 912 "vex.y"
{yyval.lwptr=make_lowl(T_REF,yyvsp[0].exptr);;
    break;}
case 344:
#line 913 "vex.y"
{yyval.lwptr=make_lowl(T_COMMENT,yyvsp[0].sval);;
    break;}
case 345:
#line 914 "vex.y"
{yyval.lwptr=make_lowl(T_COMMENT_TRAILING,yyvsp[0].sval);;
    break;}
case 346:
#line 917 "vex.y"
{yyval.ifptr=make_if_def(yyvsp[-5].sval,yyvsp[-3].dvptr,yyvsp[-1].sval);;
    break;}
case 347:
#line 921 "vex.y"
{yyval.llptr=yyvsp[0].llptr;
    break;}
case 348:
#line 922 "vex.y"
{yyval.llptr=NULL;;
    break;}
case 349:
#line 924 "vex.y"
{yyval.llptr=add_list(yyvsp[-1].llptr,yyvsp[0].lwptr);;
    break;}
case 350:
#line 926 "vex.y"
{yyval.llptr=add_list(NULL,yyvsp[0].lwptr);;
    break;}
case 351:
#line 928 "vex.y"
{yyval.lwptr=make_lowl(T_DEF,yyvsp[0].dfptr);;
    break;}
case 352:
#line 929 "vex.y"
{yyval.lwptr=make_lowl(T_COMMENT,yyvsp[0].sval);;
    break;}
case 353:
#line 930 "vex.y"
{yyval.lwptr=make_lowl(T_COMMENT_TRAILING,yyvsp[0].sval);;
    break;}
case 354:
#line 933 "vex.y"
{yyval.dfptr=make_def(yyvsp[-4].sval,yyvsp[-2].llptr);;
    break;}
case 355:
#line 935 "vex.y"
{yyval.dfptr=make_def(yyvsp[-3].sval,NULL);;
    break;}
case 356:
#line 938 "vex.y"
{yyval.llptr=add_list(yyvsp[-1].llptr,yyvsp[0].lwptr);;
    break;}
case 357:
#line 939 "vex.y"
{yyval.llptr=add_list(NULL,yyvsp[0].lwptr);;
    break;}
case 358:
#line 941 "vex.y"
{yyval.lwptr=make_lowl(T_PASS_ORDER,yyvsp[0].llptr);;
    break;}
case 359:
#line 942 "vex.y"
{yyval.lwptr=make_lowl(T_REF,yyvsp[0].exptr);;
    break;}
case 360:
#line 943 "vex.y"
{yyval.lwptr=make_lowl(T_COMMENT,yyvsp[0].sval);;
    break;}
case 361:
#line 944 "vex.y"
{yyval.lwptr=make_lowl(T_COMMENT_TRAILING,yyvsp[0].sval);;
    break;}
case 362:
#line 946 "vex.y"
{yyval.llptr=yyvsp[-1].llptr;;
    break;}
case 363:
#line 950 "vex.y"
{yyval.llptr=yyvsp[0].llptr;
    break;}
case 364:
#line 951 "vex.y"
{yyval.llptr=NULL;;
    break;}
case 365:
#line 953 "vex.y"
{yyval.llptr=add_list(yyvsp[-1].llptr,yyvsp[0].lwptr);;
    break;}
case 366:
#line 954 "vex.y"
{yyval.llptr=add_list(NULL,yyvsp[0].lwptr);;
    break;}
case 367:
#line 956 "vex.y"
{yyval.lwptr=make_lowl(T_DEF,yyvsp[0].dfptr);;
    break;}
case 368:
#line 957 "vex.y"
{yyval.lwptr=make_lowl(T_COMMENT,yyvsp[0].sval);;
    break;}
case 369:
#line 958 "vex.y"
{yyval.lwptr=make_lowl(T_COMMENT_TRAILING,yyvsp[0].sval);;
    break;}
case 370:
#line 961 "vex.y"
{yyval.dfptr=make_def(yyvsp[-4].sval,yyvsp[-2].llptr);;
    break;}
case 371:
#line 962 "vex.y"
{yyval.dfptr=make_def(yyvsp[-3].sval,NULL);;
    break;}
case 372:
#line 964 "vex.y"
{yyval.llptr=add_list(yyvsp[-1].llptr,yyvsp[0].lwptr);;
    break;}
case 373:
#line 965 "vex.y"
{yyval.llptr=add_list(NULL,yyvsp[0].lwptr);;
    break;}
case 374:
#line 967 "vex.y"
{yyval.lwptr=make_lowl(T_PCAL_FREQ,yyvsp[0].pfptr);;
    break;}
case 375:
#line 968 "vex.y"
{yyval.lwptr=make_lowl(T_REF,yyvsp[0].exptr);;
    break;}
case 376:
#line 969 "vex.y"
{yyval.lwptr=make_lowl(T_COMMENT,yyvsp[0].sval);;
    break;}
case 377:
#line 970 "vex.y"
{yyval.lwptr=make_lowl(T_COMMENT_TRAILING,yyvsp[0].sval);;
    break;}
case 378:
#line 974 "vex.y"
{yyval.pfptr=make_pcal_freq(yyvsp[-7].sval,yyvsp[-5].sval,yyvsp[-3].dvptr,yyvsp[-1].dvptr);;
    break;}
case 379:
#line 976 "vex.y"
{yyval.pfptr=make_pcal_freq(yyvsp[-3].sval,yyvsp[-1].sval,NULL,NULL);;
    break;}
case 380:
#line 980 "vex.y"
{yyval.llptr=yyvsp[0].llptr;
    break;}
case 381:
#line 981 "vex.y"
{yyval.llptr=NULL;;
    break;}
case 382:
#line 984 "vex.y"
{yyval.llptr=add_list(yyvsp[-1].llptr,yyvsp[0].lwptr);;
    break;}
case 383:
#line 985 "vex.y"
{yyval.llptr=add_list(NULL,yyvsp[0].lwptr);;
    break;}
case 384:
#line 987 "vex.y"
{yyval.lwptr=make_lowl(T_DEF,yyvsp[0].dfptr);;
    break;}
case 385:
#line 988 "vex.y"
{yyval.lwptr=make_lowl(T_COMMENT,yyvsp[0].sval);;
    break;}
case 386:
#line 989 "vex.y"
{yyval.lwptr=make_lowl(T_COMMENT_TRAILING,yyvsp[0].sval);;
    break;}
case 387:
#line 992 "vex.y"
{yyval.dfptr=make_def(yyvsp[-4].sval,yyvsp[-2].llptr);;
    break;}
case 388:
#line 994 "vex.y"
{yyval.dfptr=make_def(yyvsp[-3].sval,NULL);;
    break;}
case 389:
#line 997 "vex.y"
{yyval.llptr=add_list(yyvsp[-1].llptr,yyvsp[0].lwptr);;
    break;}
case 390:
#line 998 "vex.y"
{yyval.llptr=add_list(NULL,yyvsp[0].lwptr);;
    break;}
case 391:
#line 1001 "vex.y"
{yyval.lwptr=make_lowl(T_TAPE_CHANGE,yyvsp[0].dvptr);;
    break;}
case 392:
#line 1003 "vex.y"
{yyval.lwptr=make_lowl(T_HEADSTK_MOTION,yyvsp[0].dvptr);;
    break;}
case 393:
#line 1005 "vex.y"
{yyval.lwptr=make_lowl(T_NEW_SOURCE_COMMAND,yyvsp[0].dvptr);;
    break;}
case 394:
#line 1007 "vex.y"
{yyval.lwptr=make_lowl(T_NEW_TAPE_SETUP,yyvsp[0].dvptr);;
    break;}
case 395:
#line 1009 "vex.y"
{yyval.lwptr=make_lowl(T_SETUP_ALWAYS,yyvsp[0].saptr);;
    break;}
case 396:
#line 1011 "vex.y"
{yyval.lwptr=make_lowl(T_PARITY_CHECK,yyvsp[0].pcptr);;
    break;}
case 397:
#line 1013 "vex.y"
{yyval.lwptr=make_lowl(T_TAPE_PREPASS,yyvsp[0].tpptr);;
    break;}
case 398:
#line 1015 "vex.y"
{yyval.lwptr=make_lowl(T_PREOB_CAL,yyvsp[0].prptr);;
    break;}
case 399:
#line 1017 "vex.y"
{yyval.lwptr=make_lowl(T_MIDOB_CAL,yyvsp[0].miptr);;
    break;}
case 400:
#line 1019 "vex.y"
{yyval.lwptr=make_lowl(T_POSTOB_CAL,yyvsp[0].poptr);;
    break;}
case 401:
#line 1020 "vex.y"
{yyval.lwptr=make_lowl(T_REF,yyvsp[0].exptr);;
    break;}
case 402:
#line 1021 "vex.y"
{yyval.lwptr=make_lowl(T_COMMENT,yyvsp[0].sval);;
    break;}
case 403:
#line 1022 "vex.y"
{yyval.lwptr=make_lowl(T_COMMENT_TRAILING,yyvsp[0].sval);;
    break;}
case 404:
#line 1024 "vex.y"
{yyval.dvptr=yyvsp[-1].dvptr;;
    break;}
case 405:
#line 1026 "vex.y"
{yyval.dvptr=yyvsp[-1].dvptr;;
    break;}
case 406:
#line 1028 "vex.y"
{yyval.dvptr=yyvsp[-1].dvptr;;
    break;}
case 407:
#line 1030 "vex.y"
{yyval.dvptr=yyvsp[-1].dvptr;;
    break;}
case 408:
#line 1033 "vex.y"
{yyval.saptr=make_setup_always(yyvsp[-3].sval,yyvsp[-1].dvptr);;
    break;}
case 409:
#line 1036 "vex.y"
{yyval.pcptr=make_parity_check(yyvsp[-3].sval,yyvsp[-1].dvptr);;
    break;}
case 410:
#line 1039 "vex.y"
{yyval.tpptr=make_tape_prepass(yyvsp[-3].sval,yyvsp[-1].dvptr);;
    break;}
case 411:
#line 1042 "vex.y"
{yyval.prptr=make_preob_cal(yyvsp[-5].sval,yyvsp[-3].dvptr,yyvsp[-1].sval);;
    break;}
case 412:
#line 1045 "vex.y"
{yyval.miptr=make_midob_cal(yyvsp[-5].sval,yyvsp[-3].dvptr,yyvsp[-1].sval);;
    break;}
case 413:
#line 1048 "vex.y"
{yyval.poptr=make_postob_cal(yyvsp[-5].sval,yyvsp[-3].dvptr,yyvsp[-1].sval);;
    break;}
case 414:
#line 1052 "vex.y"
{yyval.llptr=yyvsp[0].llptr;
    break;}
case 415:
#line 1053 "vex.y"
{yyval.llptr=NULL;;
    break;}
case 416:
#line 1055 "vex.y"
{yyval.llptr=add_list(yyvsp[-1].llptr,yyvsp[0].lwptr);;
    break;}
case 417:
#line 1056 "vex.y"
{yyval.llptr=add_list(NULL,yyvsp[0].lwptr);;
    break;}
case 418:
#line 1058 "vex.y"
{yyval.lwptr=make_lowl(T_DEF,yyvsp[0].dfptr);;
    break;}
case 419:
#line 1059 "vex.y"
{yyval.lwptr=make_lowl(T_COMMENT,yyvsp[0].sval);;
    break;}
case 420:
#line 1060 "vex.y"
{yyval.lwptr=make_lowl(T_COMMENT_TRAILING,yyvsp[0].sval);;
    break;}
case 421:
#line 1063 "vex.y"
{yyval.dfptr=make_def(yyvsp[-4].sval,yyvsp[-2].llptr);;
    break;}
case 422:
#line 1065 "vex.y"
{yyval.dfptr=make_def(yyvsp[-3].sval,NULL);;
    break;}
case 423:
#line 1067 "vex.y"
{yyval.llptr=add_list(yyvsp[-1].llptr,yyvsp[0].lwptr);;
    break;}
case 424:
#line 1068 "vex.y"
{yyval.llptr=add_list(NULL,yyvsp[0].lwptr);;
    break;}
case 425:
#line 1070 "vex.y"
{yyval.lwptr=make_lowl(T_REINIT_PERIOD,yyvsp[0].dvptr);;
    break;}
case 426:
#line 1071 "vex.y"
{yyval.lwptr=make_lowl(T_INC_PERIOD,yyvsp[0].dvptr);;
    break;}
case 427:
#line 1072 "vex.y"
{yyval.lwptr=make_lowl(T_ROLL,yyvsp[0].llptr);;
    break;}
case 428:
#line 1073 "vex.y"
{yyval.lwptr=make_lowl(T_REF,yyvsp[0].exptr);;
    break;}
case 429:
#line 1074 "vex.y"
{yyval.lwptr=make_lowl(T_COMMENT,yyvsp[0].sval);;
    break;}
case 430:
#line 1075 "vex.y"
{yyval.lwptr=make_lowl(T_COMMENT_TRAILING,yyvsp[0].sval);;
    break;}
case 431:
#line 1077 "vex.y"
{yyval.dvptr=yyvsp[-1].dvptr;;
    break;}
case 432:
#line 1079 "vex.y"
{yyval.dvptr=yyvsp[-1].dvptr;;
    break;}
case 433:
#line 1081 "vex.y"
{yyval.llptr=yyvsp[-1].llptr;;
    break;}
case 434:
#line 1086 "vex.y"
{yyval.llptr=yyvsp[0].llptr;
    break;}
case 435:
#line 1087 "vex.y"
{yyval.llptr=NULL;;
    break;}
case 436:
#line 1090 "vex.y"
{yyval.llptr=add_list(yyvsp[-1].llptr,yyvsp[0].lwptr);;
    break;}
case 437:
#line 1092 "vex.y"
{yyval.llptr=add_list(NULL,yyvsp[0].lwptr);;
    break;}
case 438:
#line 1094 "vex.y"
{yyval.lwptr=make_lowl(T_DEF,yyvsp[0].dfptr);;
    break;}
case 439:
#line 1095 "vex.y"
{yyval.lwptr=make_lowl(T_COMMENT,yyvsp[0].sval);;
    break;}
case 440:
#line 1096 "vex.y"
{yyval.lwptr=make_lowl(T_COMMENT_TRAILING,yyvsp[0].sval);;
    break;}
case 441:
#line 1099 "vex.y"
{yyval.dfptr=make_def(yyvsp[-4].sval,yyvsp[-2].llptr);;
    break;}
case 442:
#line 1101 "vex.y"
{yyval.dfptr=make_def(yyvsp[-3].sval,NULL);;
    break;}
case 443:
#line 1104 "vex.y"
{yyval.llptr=add_list(yyvsp[-1].llptr,yyvsp[0].lwptr);;
    break;}
case 444:
#line 1106 "vex.y"
{yyval.llptr=add_list(NULL,yyvsp[0].lwptr);;
    break;}
case 445:
#line 1108 "vex.y"
{yyval.lwptr=make_lowl(T_REF,yyvsp[0].exptr);;
    break;}
case 446:
#line 1109 "vex.y"
{yyval.lwptr=make_lowl(T_LITERAL,yyvsp[0].llptr);;
    break;}
case 447:
#line 1110 "vex.y"
{yyval.lwptr=make_lowl(T_COMMENT,yyvsp[0].sval);;
    break;}
case 448:
#line 1111 "vex.y"
{yyval.lwptr=make_lowl(T_COMMENT_TRAILING,yyvsp[0].sval);;
    break;}
case 449:
#line 1115 "vex.y"
{yyval.llptr=yyvsp[0].llptr;
    break;}
case 450:
#line 1116 "vex.y"
{yyval.llptr=NULL;;
    break;}
case 451:
#line 1118 "vex.y"
{yyval.llptr=add_list(yyvsp[-1].llptr,yyvsp[0].lwptr);;
    break;}
case 452:
#line 1119 "vex.y"
{yyval.llptr=add_list(NULL,yyvsp[0].lwptr);;
    break;}
case 453:
#line 1121 "vex.y"
{yyval.lwptr=make_lowl(T_DEF,yyvsp[0].dfptr);;
    break;}
case 454:
#line 1122 "vex.y"
{yyval.lwptr=make_lowl(T_COMMENT,yyvsp[0].sval);;
    break;}
case 455:
#line 1123 "vex.y"
{yyval.lwptr=make_lowl(T_COMMENT_TRAILING,yyvsp[0].sval);;
    break;}
case 456:
#line 1126 "vex.y"
{yyval.dfptr=make_def(yyvsp[-4].sval,yyvsp[-2].llptr);;
    break;}
case 457:
#line 1128 "vex.y"
{yyval.dfptr=make_def(yyvsp[-3].sval,NULL);;
    break;}
case 458:
#line 1130 "vex.y"
{yyval.llptr=add_list(yyvsp[-1].llptr,yyvsp[0].lwptr);;
    break;}
case 459:
#line 1131 "vex.y"
{yyval.llptr=add_list(NULL,yyvsp[0].lwptr);;
    break;}
case 460:
#line 1133 "vex.y"
{yyval.lwptr=make_lowl(T_SEFD_MODEL,yyvsp[0].sval);;
    break;}
case 461:
#line 1134 "vex.y"
{yyval.lwptr=make_lowl(T_SEFD,yyvsp[0].septr);;
    break;}
case 462:
#line 1135 "vex.y"
{yyval.lwptr=make_lowl(T_REF,yyvsp[0].exptr);;
    break;}
case 463:
#line 1136 "vex.y"
{yyval.lwptr=make_lowl(T_COMMENT,yyvsp[0].sval);;
    break;}
case 464:
#line 1137 "vex.y"
{yyval.lwptr=make_lowl(T_COMMENT_TRAILING,yyvsp[0].sval);;
    break;}
case 465:
#line 1139 "vex.y"
{yyval.sval=yyvsp[-1].sval;;
    break;}
case 466:
#line 1142 "vex.y"
{yyval.septr=make_sefd(yyvsp[-5].sval,yyvsp[-3].dvptr,yyvsp[-1].llptr);;
    break;}
case 467:
#line 1146 "vex.y"
{yyval.llptr=yyvsp[0].llptr;
    break;}
case 468:
#line 1147 "vex.y"
{yyval.llptr=NULL;;
    break;}
case 469:
#line 1149 "vex.y"
{yyval.llptr=add_list(yyvsp[-1].llptr,yyvsp[0].lwptr);;
    break;}
case 470:
#line 1150 "vex.y"
{yyval.llptr=add_list(NULL,yyvsp[0].lwptr);;
    break;}
case 471:
#line 1152 "vex.y"
{yyval.lwptr=make_lowl(T_DEF,yyvsp[0].dfptr);;
    break;}
case 472:
#line 1153 "vex.y"
{yyval.lwptr=make_lowl(T_COMMENT,yyvsp[0].sval);;
    break;}
case 473:
#line 1154 "vex.y"
{yyval.lwptr=make_lowl(T_COMMENT_TRAILING,yyvsp[0].sval);;
    break;}
case 474:
#line 1157 "vex.y"
{yyval.dfptr=make_def(yyvsp[-4].sval,yyvsp[-2].llptr);;
    break;}
case 475:
#line 1158 "vex.y"
{yyval.dfptr=make_def(yyvsp[-3].sval,NULL);;
    break;}
case 476:
#line 1160 "vex.y"
{yyval.llptr=add_list(yyvsp[-1].llptr,yyvsp[0].lwptr);;
    break;}
case 477:
#line 1161 "vex.y"
{yyval.llptr=add_list(NULL,yyvsp[0].lwptr);;
    break;}
case 478:
#line 1163 "vex.y"
{yyval.lwptr=make_lowl(T_SITE_TYPE,yyvsp[0].sval);;
    break;}
case 479:
#line 1164 "vex.y"
{yyval.lwptr=make_lowl(T_SITE_NAME,yyvsp[0].sval);;
    break;}
case 480:
#line 1165 "vex.y"
{yyval.lwptr=make_lowl(T_SITE_ID,yyvsp[0].sval);;
    break;}
case 481:
#line 1166 "vex.y"
{yyval.lwptr=make_lowl(T_SITE_POSITION,yyvsp[0].spptr);;
    break;}
case 482:
#line 1167 "vex.y"
{yyval.lwptr=make_lowl(T_HORIZON_MAP_AZ,yyvsp[0].llptr);;
    break;}
case 483:
#line 1168 "vex.y"
{yyval.lwptr=make_lowl(T_HORIZON_MAP_EL,yyvsp[0].llptr);;
    break;}
case 484:
#line 1169 "vex.y"
{yyval.lwptr=make_lowl(T_ZEN_ATMOS,yyvsp[0].dvptr);;
    break;}
case 485:
#line 1170 "vex.y"
{yyval.lwptr=make_lowl(T_OCEAN_LOAD_VERT,yyvsp[0].ovptr);;
    break;}
case 486:
#line 1171 "vex.y"
{yyval.lwptr=make_lowl(T_OCEAN_LOAD_HORIZ,yyvsp[0].ohptr);;
    break;}
case 487:
#line 1172 "vex.y"
{yyval.lwptr=make_lowl(T_OCCUPATION_CODE,yyvsp[0].sval);;
    break;}
case 488:
#line 1173 "vex.y"
{yyval.lwptr=make_lowl(T_INCLINATION,yyvsp[0].dvptr);;
    break;}
case 489:
#line 1174 "vex.y"
{yyval.lwptr=make_lowl(T_ECCENTRICITY,yyvsp[0].dvptr);;
    break;}
case 490:
#line 1175 "vex.y"
{yyval.lwptr=make_lowl(T_ARG_PERIGEE,yyvsp[0].dvptr);;
    break;}
case 491:
#line 1176 "vex.y"
{yyval.lwptr=make_lowl(T_ASCENDING_NODE,yyvsp[0].dvptr);;
    break;}
case 492:
#line 1177 "vex.y"
{yyval.lwptr=make_lowl(T_MEAN_ANOMALY,yyvsp[0].dvptr);;
    break;}
case 493:
#line 1178 "vex.y"
{yyval.lwptr=make_lowl(T_SEMI_MAJOR_AXIS,yyvsp[0].dvptr);;
    break;}
case 494:
#line 1179 "vex.y"
{yyval.lwptr=make_lowl(T_MEAN_MOTION,yyvsp[0].dvptr);;
    break;}
case 495:
#line 1180 "vex.y"
{yyval.lwptr=make_lowl(T_ORBIT_EPOCH,yyvsp[0].sval);;
    break;}
case 496:
#line 1181 "vex.y"
{yyval.lwptr=make_lowl(T_REF,yyvsp[0].exptr);;
    break;}
case 497:
#line 1182 "vex.y"
{yyval.lwptr=make_lowl(T_COMMENT,yyvsp[0].sval);;
    break;}
case 498:
#line 1183 "vex.y"
{yyval.lwptr=make_lowl(T_COMMENT_TRAILING,yyvsp[0].sval);;
    break;}
case 499:
#line 1185 "vex.y"
{yyval.sval=yyvsp[-1].sval;;
    break;}
case 500:
#line 1187 "vex.y"
{yyval.sval=yyvsp[-1].sval;;
    break;}
case 501:
#line 1189 "vex.y"
{yyval.sval=yyvsp[-1].sval;;
    break;}
case 502:
#line 1193 "vex.y"
{yyval.spptr=make_site_position(yyvsp[-9].dvptr,yyvsp[-7].dvptr,yyvsp[-5].dvptr,yyvsp[-3].dvptr,yyvsp[-1].sval);;
    break;}
case 503:
#line 1195 "vex.y"
{yyval.llptr=yyvsp[-1].llptr;;
    break;}
case 504:
#line 1197 "vex.y"
{yyval.llptr=yyvsp[-1].llptr;;
    break;}
case 505:
#line 1199 "vex.y"
{yyval.dvptr=yyvsp[-1].dvptr;;
    break;}
case 506:
#line 1203 "vex.y"
{yyval.ovptr=make_ocean_load_vert(yyvsp[-3].dvptr,yyvsp[-1].dvptr);;
    break;}
case 507:
#line 1207 "vex.y"
{yyval.ohptr=make_ocean_load_horiz(yyvsp[-3].dvptr,yyvsp[-1].dvptr);;
    break;}
case 508:
#line 1209 "vex.y"
{yyval.sval=yyvsp[-1].sval;;
    break;}
case 509:
#line 1211 "vex.y"
{yyval.dvptr=yyvsp[-1].dvptr;;
    break;}
case 510:
#line 1213 "vex.y"
{yyval.dvptr=yyvsp[-1].dvptr;;
    break;}
case 511:
#line 1215 "vex.y"
{yyval.dvptr=yyvsp[-1].dvptr;;
    break;}
case 512:
#line 1217 "vex.y"
{yyval.dvptr=yyvsp[-1].dvptr;;
    break;}
case 513:
#line 1219 "vex.y"
{yyval.dvptr=yyvsp[-1].dvptr;;
    break;}
case 514:
#line 1221 "vex.y"
{yyval.dvptr=yyvsp[-1].dvptr;;
    break;}
case 515:
#line 1223 "vex.y"
{yyval.dvptr=yyvsp[-1].dvptr;;
    break;}
case 516:
#line 1225 "vex.y"
{yyval.sval=yyvsp[-1].sval;;
    break;}
case 517:
#line 1229 "vex.y"
{yyval.llptr=yyvsp[0].llptr;
    break;}
case 518:
#line 1230 "vex.y"
{yyval.llptr=NULL;;
    break;}
case 519:
#line 1232 "vex.y"
{yyval.llptr=add_list(yyvsp[-1].llptr,yyvsp[0].lwptr);;
    break;}
case 520:
#line 1233 "vex.y"
{yyval.llptr=add_list(NULL,yyvsp[0].lwptr);;
    break;}
case 521:
#line 1235 "vex.y"
{yyval.lwptr=make_lowl(T_DEF,yyvsp[0].dfptr);;
    break;}
case 522:
#line 1236 "vex.y"
{yyval.lwptr=make_lowl(T_COMMENT,yyvsp[0].sval);;
    break;}
case 523:
#line 1237 "vex.y"
{yyval.lwptr=make_lowl(T_COMMENT_TRAILING,yyvsp[0].sval);;
    break;}
case 524:
#line 1240 "vex.y"
{yyval.dfptr=make_def(yyvsp[-4].sval,yyvsp[-2].llptr);;
    break;}
case 525:
#line 1242 "vex.y"
{yyval.dfptr=make_def(yyvsp[-3].sval,NULL);;
    break;}
case 526:
#line 1244 "vex.y"
{yyval.llptr=add_list(yyvsp[-1].llptr,yyvsp[0].lwptr);;
    break;}
case 527:
#line 1245 "vex.y"
{yyval.llptr=add_list(NULL,yyvsp[0].lwptr);;
    break;}
case 528:
#line 1247 "vex.y"
{yyval.lwptr=make_lowl(T_SOURCE_TYPE,yyvsp[0].llptr);;
    break;}
case 529:
#line 1248 "vex.y"
{yyval.lwptr=make_lowl(T_SOURCE_NAME,yyvsp[0].sval);;
    break;}
case 530:
#line 1249 "vex.y"
{yyval.lwptr=make_lowl(T_IAU_NAME,yyvsp[0].sval);;
    break;}
case 531:
#line 1250 "vex.y"
{yyval.lwptr=make_lowl(T_RA,yyvsp[0].sval);;
    break;}
case 532:
#line 1251 "vex.y"
{yyval.lwptr=make_lowl(T_DEC,yyvsp[0].sval);;
    break;}
case 533:
#line 1252 "vex.y"
{yyval.lwptr=make_lowl(T_EPOCH,yyvsp[0].sval);;
    break;}
case 534:
#line 1253 "vex.y"
{yyval.lwptr=make_lowl(T_SOURCE_POS_REF,yyvsp[0].sval);;
    break;}
case 535:
#line 1254 "vex.y"
{yyval.lwptr=make_lowl(T_RA_RATE,yyvsp[0].dvptr);;
    break;}
case 536:
#line 1255 "vex.y"
{yyval.lwptr=make_lowl(T_DEC_RATE,yyvsp[0].dvptr);;
    break;}
case 537:
#line 1256 "vex.y"
{yyval.lwptr=make_lowl(T_VELOCITY_WRT_LSR,yyvsp[0].dvptr);;
    break;}
case 538:
#line 1257 "vex.y"
{yyval.lwptr=make_lowl(T_SOURCE_MODEL,yyvsp[0].smptr);;
    break;}
case 539:
#line 1258 "vex.y"
{yyval.lwptr=make_lowl(T_INCLINATION,yyvsp[0].dvptr);;
    break;}
case 540:
#line 1259 "vex.y"
{yyval.lwptr=make_lowl(T_ECCENTRICITY,yyvsp[0].dvptr);;
    break;}
case 541:
#line 1260 "vex.y"
{yyval.lwptr=make_lowl(T_ARG_PERIGEE,yyvsp[0].dvptr);;
    break;}
case 542:
#line 1261 "vex.y"
{yyval.lwptr=make_lowl(T_ASCENDING_NODE,yyvsp[0].dvptr);;
    break;}
case 543:
#line 1262 "vex.y"
{yyval.lwptr=make_lowl(T_MEAN_ANOMALY,yyvsp[0].dvptr);;
    break;}
case 544:
#line 1263 "vex.y"
{yyval.lwptr=make_lowl(T_SEMI_MAJOR_AXIS,yyvsp[0].dvptr);;
    break;}
case 545:
#line 1264 "vex.y"
{yyval.lwptr=make_lowl(T_MEAN_MOTION,yyvsp[0].dvptr);;
    break;}
case 546:
#line 1265 "vex.y"
{yyval.lwptr=make_lowl(T_ORBIT_EPOCH,yyvsp[0].sval);;
    break;}
case 547:
#line 1266 "vex.y"
{yyval.lwptr=make_lowl(T_REF,yyvsp[0].exptr);;
    break;}
case 548:
#line 1267 "vex.y"
{yyval.lwptr=make_lowl(T_COMMENT,yyvsp[0].sval);;
    break;}
case 549:
#line 1268 "vex.y"
{yyval.lwptr=make_lowl(T_COMMENT_TRAILING,yyvsp[0].sval);;
    break;}
case 550:
#line 1270 "vex.y"
{yyval.llptr=add_list(NULL,yyvsp[-1].sval);;
    break;}
case 551:
#line 1272 "vex.y"
{yyval.llptr=add_list(add_list(NULL,yyvsp[-3].sval),yyvsp[-1].sval);;
    break;}
case 552:
#line 1274 "vex.y"
{yyval.sval=yyvsp[-1].sval;;
    break;}
case 553:
#line 1276 "vex.y"
{yyval.sval=yyvsp[-1].sval;;
    break;}
case 554:
#line 1278 "vex.y"
{yyval.sval=yyvsp[-1].sval;;
    break;}
case 555:
#line 1280 "vex.y"
{yyval.sval=yyvsp[-1].sval;;
    break;}
case 556:
#line 1282 "vex.y"
{yyval.sval=yyvsp[-1].sval;;
    break;}
case 557:
#line 1284 "vex.y"
{yyval.sval=yyvsp[-1].sval;;
    break;}
case 558:
#line 1286 "vex.y"
{yyval.dvptr=yyvsp[-1].dvptr;;
    break;}
case 559:
#line 1288 "vex.y"
{yyval.dvptr=yyvsp[-1].dvptr;;
    break;}
case 560:
#line 1291 "vex.y"
{yyval.dvptr=yyvsp[-1].dvptr;;
    break;}
case 561:
#line 1301 "vex.y"
{yyval.smptr=make_source_model(yyvsp[-15].dvptr,yyvsp[-13].sval,yyvsp[-11].dvptr,yyvsp[-9].dvptr,yyvsp[-7].dvptr,yyvsp[-5].dvptr,yyvsp[-3].dvptr,yyvsp[-1].dvptr);;
    break;}
case 562:
#line 1305 "vex.y"
{yyval.llptr=yyvsp[0].llptr;
    break;}
case 563:
#line 1306 "vex.y"
{yyval.llptr=NULL;;
    break;}
case 564:
#line 1309 "vex.y"
{yyval.llptr=add_list(yyvsp[-1].llptr,yyvsp[0].lwptr);;
    break;}
case 565:
#line 1310 "vex.y"
{yyval.llptr=add_list(NULL,yyvsp[0].lwptr);;
    break;}
case 566:
#line 1312 "vex.y"
{yyval.lwptr=make_lowl(T_DEF,yyvsp[0].dfptr);;
    break;}
case 567:
#line 1313 "vex.y"
{yyval.lwptr=make_lowl(T_COMMENT,yyvsp[0].sval);;
    break;}
case 568:
#line 1314 "vex.y"
{yyval.lwptr=make_lowl(T_COMMENT_TRAILING,yyvsp[0].sval);;
    break;}
case 569:
#line 1318 "vex.y"
{yyval.dfptr=make_def(yyvsp[-4].sval,yyvsp[-2].llptr);;
    break;}
case 570:
#line 1320 "vex.y"
{yyval.dfptr=make_def(yyvsp[-3].sval,NULL);;
    break;}
case 571:
#line 1323 "vex.y"
{yyval.llptr=add_list(yyvsp[-1].llptr,yyvsp[0].lwptr);;
    break;}
case 572:
#line 1324 "vex.y"
{yyval.llptr=add_list(NULL,yyvsp[0].lwptr);;
    break;}
case 573:
#line 1326 "vex.y"
{yyval.lwptr=make_lowl(T_VSN,yyvsp[0].vsptr);;
    break;}
case 574:
#line 1327 "vex.y"
{yyval.lwptr=make_lowl(T_REF,yyvsp[0].exptr);;
    break;}
case 575:
#line 1328 "vex.y"
{yyval.lwptr=make_lowl(T_COMMENT,yyvsp[0].sval);;
    break;}
case 576:
#line 1330 "vex.y"
{yyval.lwptr=make_lowl(T_COMMENT_TRAILING,yyvsp[0].sval);;
    break;}
case 577:
#line 1333 "vex.y"
{yyval.vsptr=make_vsn(yyvsp[-7].dvptr,yyvsp[-5].sval,yyvsp[-3].sval,yyvsp[-1].sval);;
    break;}
case 578:
#line 1337 "vex.y"
{yyval.llptr=yyvsp[0].llptr;
    break;}
case 579:
#line 1338 "vex.y"
{yyval.llptr=NULL;;
    break;}
case 580:
#line 1340 "vex.y"
{yyval.llptr=add_list(yyvsp[-1].llptr,yyvsp[0].lwptr);;
    break;}
case 581:
#line 1341 "vex.y"
{yyval.llptr=add_list(NULL,yyvsp[0].lwptr);;
    break;}
case 582:
#line 1343 "vex.y"
{yyval.lwptr=make_lowl(T_DEF,yyvsp[0].dfptr);;
    break;}
case 583:
#line 1344 "vex.y"
{yyval.lwptr=make_lowl(T_COMMENT,yyvsp[0].sval);;
    break;}
case 584:
#line 1345 "vex.y"
{yyval.lwptr=make_lowl(T_COMMENT_TRAILING,yyvsp[0].sval);;
    break;}
case 585:
#line 1348 "vex.y"
{yyval.dfptr=make_def(yyvsp[-4].sval,yyvsp[-2].llptr);;
    break;}
case 586:
#line 1350 "vex.y"
{yyval.dfptr=make_def(yyvsp[-3].sval,NULL);;
    break;}
case 587:
#line 1352 "vex.y"
{yyval.llptr=add_list(yyvsp[-1].llptr,yyvsp[0].lwptr);;
    break;}
case 588:
#line 1353 "vex.y"
{yyval.llptr=add_list(NULL,yyvsp[0].lwptr);;
    break;}
case 589:
#line 1355 "vex.y"
{yyval.lwptr=make_lowl(T_FANIN_DEF,yyvsp[0].fiptr);;
    break;}
case 590:
#line 1356 "vex.y"
{yyval.lwptr=make_lowl(T_FANOUT_DEF,yyvsp[0].foptr);;
    break;}
case 591:
#line 1358 "vex.y"
{yyval.lwptr=make_lowl(T_TRACK_FRAME_FORMAT,yyvsp[0].sval);;
    break;}
case 592:
#line 1359 "vex.y"
{yyval.lwptr=make_lowl(T_DATA_MODULATE,yyvsp[0].sval);;
    break;}
case 593:
#line 1361 "vex.y"
{yyval.lwptr=make_lowl(T_VLBA_FRMTR_SYS_TRK,yyvsp[0].fsptr);;
    break;}
case 594:
#line 1363 "vex.y"
{yyval.lwptr=make_lowl(T_VLBA_TRNSPRT_SYS_TRAK,yyvsp[0].llptr);;
    break;}
case 595:
#line 1364 "vex.y"
{yyval.lwptr=make_lowl(T_S2_DATA_DEF,yyvsp[0].sdptr);;
    break;}
case 596:
#line 1365 "vex.y"
{yyval.lwptr=make_lowl(T_REF,yyvsp[0].exptr);;
    break;}
case 597:
#line 1366 "vex.y"
{yyval.lwptr=make_lowl(T_COMMENT,yyvsp[0].sval);;
    break;}
case 598:
#line 1367 "vex.y"
{yyval.lwptr=make_lowl(T_COMMENT_TRAILING,yyvsp[0].sval);;
    break;}
case 599:
#line 1370 "vex.y"
{yyval.fiptr=make_fanin_def(yyvsp[-7].sval,yyvsp[-5].dvptr,yyvsp[-3].dvptr,yyvsp[-1].llptr);;
    break;}
case 600:
#line 1374 "vex.y"
{yyval.foptr=make_fanout_def(yyvsp[-7].sval,yyvsp[-5].llptr,yyvsp[-3].dvptr,yyvsp[-1].llptr);;
    break;}
case 601:
#line 1376 "vex.y"
{yyval.sval=yyvsp[-1].sval;;
    break;}
case 602:
#line 1378 "vex.y"
{yyval.sval=yyvsp[-1].sval;;
    break;}
case 603:
#line 1382 "vex.y"
{yyval.fsptr=make_vlba_frmtr_sys_trk(yyvsp[-7].dvptr,yyvsp[-5].sval,yyvsp[-3].dvptr,yyvsp[-1].dvptr);;
    break;}
case 604:
#line 1385 "vex.y"
{yyval.fsptr=make_vlba_frmtr_sys_trk(yyvsp[-5].dvptr,yyvsp[-3].sval,yyvsp[-1].dvptr,NULL);;
    break;}
case 605:
#line 1388 "vex.y"
{yyval.llptr=add_list(add_list(NULL,yyvsp[-3].dvptr),yyvsp[-1].dvptr);;
    break;}
case 606:
#line 1391 "vex.y"
{yyval.sdptr=make_s2_data_def(yyvsp[-3].llptr,yyvsp[-1].sval);;
    break;}
case 607:
#line 1394 "vex.y"
{yyval.llptr=add_list(add_list(yyvsp[-4].llptr,yyvsp[-2].sval),yyvsp[0].sval);;
    break;}
case 608:
#line 1396 "vex.y"
{yyval.llptr=add_list(add_list(NULL,yyvsp[-2].sval),yyvsp[0].sval);;
    break;}
case 609:
#line 1398 "vex.y"
{yyval.llptr=add_list(add_list(NULL,yyvsp[-2].sval),yyvsp[0].sval);;
    break;}
case 610:
#line 1403 "vex.y"
{yyval.exptr=make_external(yyvsp[-5].sval,yyvsp[-3].ival,yyvsp[-1].sval);;
    break;}
case 611:
#line 1405 "vex.y"
{yyval.exptr=make_external(yyvsp[-5].sval,B_CLOCK,yyvsp[-1].sval);;
    break;}
case 612:
#line 1407 "vex.y"
{yyval.llptr=yyvsp[-1].llptr;;
    break;}
case 613:
#line 1409 "vex.y"
{yyval.llptr=ins_list(yyvsp[-2].dvptr,yyvsp[0].llptr);;
    break;}
case 614:
#line 1410 "vex.y"
{yyval.llptr=add_list(NULL,yyvsp[0].dvptr);;
    break;}
case 615:
#line 1412 "vex.y"
{yyval.llptr=add_list(yyvsp[-2].llptr,yyvsp[0].dvptr);;
    break;}
case 616:
#line 1413 "vex.y"
{yyval.llptr=add_list(NULL,yyvsp[0].dvptr);;
    break;}
case 617:
#line 1415 "vex.y"
{yyval.dvptr=yyvsp[0].dvptr;;
    break;}
case 618:
#line 1416 "vex.y"
{yyval.dvptr=yyvsp[0].dvptr;;
    break;}
case 619:
#line 1418 "vex.y"
{yyval.dvptr=make_dvalue(yyvsp[-1].sval,yyvsp[0].sval);;
    break;}
case 620:
#line 1420 "vex.y"
{yyval.llptr=ins_list(yyvsp[-2].dvptr,yyvsp[0].llptr);;
    break;}
case 621:
#line 1421 "vex.y"
{yyval.llptr=add_list(NULL,yyvsp[0].dvptr);;
    break;}
case 622:
#line 1423 "vex.y"
{yyval.llptr=add_list(yyvsp[-2].llptr,yyvsp[0].dvptr);;
    break;}
case 623:
#line 1424 "vex.y"
{yyval.llptr=add_list(NULL,yyvsp[0].dvptr);;
    break;}
case 624:
#line 1426 "vex.y"
{yyval.dvptr=yyvsp[0].dvptr;;
    break;}
case 625:
#line 1427 "vex.y"
{yyval.dvptr=yyvsp[0].dvptr;;
    break;}
case 626:
#line 1429 "vex.y"
{yyval.dvptr=make_dvalue(yyvsp[-1].sval,yyvsp[0].sval);;
    break;}
case 627:
#line 1432 "vex.y"
{yyval.llptr=ins_list(yyvsp[-2].dvptr,yyvsp[0].llptr);;
    break;}
case 628:
#line 1433 "vex.y"
{yyval.llptr=add_list(NULL,yyvsp[0].dvptr);;
    break;}
case 629:
#line 1435 "vex.y"
{yyval.llptr=add_list(yyvsp[-2].llptr,yyvsp[0].dvptr);;
    break;}
case 630:
#line 1436 "vex.y"
{yyval.llptr=add_list(NULL,yyvsp[0].dvptr);;
    break;}
case 631:
#line 1438 "vex.y"
{yyval.dvptr=yyvsp[0].dvptr;;
    break;}
case 632:
#line 1439 "vex.y"
{yyval.dvptr=yyvsp[0].dvptr;;
    break;}
case 633:
#line 1441 "vex.y"
{yyval.dvptr=make_dvalue(yyvsp[-1].sval,yyvsp[0].sval);;
    break;}
case 634:
#line 1443 "vex.y"
{yyval.llptr=add_list(yyvsp[-2].llptr,yyvsp[0].sval);;
    break;}
case 635:
#line 1444 "vex.y"
{yyval.llptr=add_list(NULL,yyvsp[0].sval);;
    break;}
case 636:
#line 1446 "vex.y"
{yyval.sval=yyvsp[0].sval;;
    break;}
case 637:
#line 1448 "vex.y"
{yyval.dvptr=make_dvalue(yyvsp[-1].sval,yyvsp[0].sval);;
    break;}
case 638:
#line 1450 "vex.y"
{yyval.llptr=add_list(yyvsp[-2].llptr,yyvsp[0].dvptr);;
    break;}
case 639:
#line 1451 "vex.y"
{yyval.llptr=add_list(NULL,yyvsp[0].dvptr);;
    break;}
case 640:
#line 1453 "vex.y"
{yyval.dvptr=make_dvalue(yyvsp[0].sval,NULL);;
    break;}
case 641:
#line 1455 "vex.y"
{yyval.dvptr=make_dvalue(yyvsp[-1].sval,yyvsp[0].sval);;
    break;}
case 642:
#line 1458 "vex.y"
{yyval.dvptr=make_dvalue(yyvsp[-1].sval,yyvsp[0].sval);;
    break;}
case 643:
#line 1461 "vex.y"
{yyval.dvptr=make_dvalue(yyvsp[-1].sval,yyvsp[0].sval);;
    break;}
case 644:
#line 1463 "vex.y"
{yyval.dvptr=make_dvalue(yyvsp[-1].sval,yyvsp[0].sval);;
    break;}
}
   /* the action file gets copied in in place of this dollarsign */
#line 465 "/usr/lib/bison.simple"

  yyvsp -= yylen;
  yyssp -= yylen;
#ifdef YYLSP_NEEDED
  yylsp -= yylen;
#endif

#if YYDEBUG != 0
  if (yydebug)
    {
      short *ssp1 = yyss - 1;
      fprintf (stderr, "state stack now");
      while (ssp1 != yyssp)
	fprintf (stderr, " %d", *++ssp1);
      fprintf (stderr, "\n");
    }
#endif

  *++yyvsp = yyval;

#ifdef YYLSP_NEEDED
  yylsp++;
  if (yylen == 0)
    {
      yylsp->first_line = yylloc.first_line;
      yylsp->first_column = yylloc.first_column;
      yylsp->last_line = (yylsp-1)->last_line;
      yylsp->last_column = (yylsp-1)->last_column;
      yylsp->text = 0;
    }
  else
    {
      yylsp->last_line = (yylsp+yylen-1)->last_line;
      yylsp->last_column = (yylsp+yylen-1)->last_column;
    }
#endif

  /* Now "shift" the result of the reduction.
     Determine what state that goes to,
     based on the state we popped back to
     and the rule number reduced by.  */

  yyn = yyr1[yyn];

  yystate = yypgoto[yyn - YYNTBASE] + *yyssp;
  if (yystate >= 0 && yystate <= YYLAST && yycheck[yystate] == *yyssp)
    yystate = yytable[yystate];
  else
    yystate = yydefgoto[yyn - YYNTBASE];

  goto yynewstate;

yyerrlab:   /* here on detecting error */

  if (! yyerrstatus)
    /* If not already recovering from an error, report this error.  */
    {
      ++yynerrs;

#ifdef YYERROR_VERBOSE
      yyn = yypact[yystate];

      if (yyn > YYFLAG && yyn < YYLAST)
	{
	  int size = 0;
	  char *msg;
	  int x, count;

	  count = 0;
	  /* Start X at -yyn if nec to avoid negative indexes in yycheck.  */
	  for (x = (yyn < 0 ? -yyn : 0);
	       x < (sizeof(yytname) / sizeof(char *)); x++)
	    if (yycheck[x + yyn] == x)
	      size += strlen(yytname[x]) + 15, count++;
	  msg = (char *) malloc(size + 15);
	  if (msg != 0)
	    {
	      strcpy(msg, "parse error");

	      if (count < 5)
		{
		  count = 0;
		  for (x = (yyn < 0 ? -yyn : 0);
		       x < (sizeof(yytname) / sizeof(char *)); x++)
		    if (yycheck[x + yyn] == x)
		      {
			strcat(msg, count == 0 ? ", expecting `" : " or `");
			strcat(msg, yytname[x]);
			strcat(msg, "'");
			count++;
		      }
		}
	      yyerror(msg);
	      free(msg);
	    }
	  else
	    yyerror ("parse error; also virtual memory exceeded");
	}
      else
#endif /* YYERROR_VERBOSE */
	yyerror("parse error");
    }

  goto yyerrlab1;
yyerrlab1:   /* here on error raised explicitly by an action */

  if (yyerrstatus == 3)
    {
      /* if just tried and failed to reuse lookahead token after an error, discard it.  */

      /* return failure if at end of input */
      if (yychar == YYEOF)
	YYABORT;

#if YYDEBUG != 0
      if (yydebug)
	fprintf(stderr, "Discarding token %d (%s).\n", yychar, yytname[yychar1]);
#endif

      yychar = YYEMPTY;
    }

  /* Else will try to reuse lookahead token
     after shifting the error token.  */

  yyerrstatus = 3;		/* Each real token shifted decrements this */

  goto yyerrhandle;

yyerrdefault:  /* current state does not do anything special for the error token. */

#if 0
  /* This is wrong; only states that explicitly want error tokens
     should shift them.  */
  yyn = yydefact[yystate];  /* If its default is to accept any token, ok.  Otherwise pop it.*/
  if (yyn) goto yydefault;
#endif

yyerrpop:   /* pop the current state because it cannot handle the error token */

  if (yyssp == yyss) YYABORT;
  yyvsp--;
  yystate = *--yyssp;
#ifdef YYLSP_NEEDED
  yylsp--;
#endif

#if YYDEBUG != 0
  if (yydebug)
    {
      short *ssp1 = yyss - 1;
      fprintf (stderr, "Error: state stack now");
      while (ssp1 != yyssp)
	fprintf (stderr, " %d", *++ssp1);
      fprintf (stderr, "\n");
    }
#endif

yyerrhandle:

  yyn = yypact[yystate];
  if (yyn == YYFLAG)
    goto yyerrdefault;

  yyn += YYTERROR;
  if (yyn < 0 || yyn > YYLAST || yycheck[yyn] != YYTERROR)
    goto yyerrdefault;

  yyn = yytable[yyn];
  if (yyn < 0)
    {
      if (yyn == YYFLAG)
	goto yyerrpop;
      yyn = -yyn;
      goto yyreduce;
    }
  else if (yyn == 0)
    goto yyerrpop;

  if (yyn == YYFINAL)
    YYACCEPT;

#if YYDEBUG != 0
  if (yydebug)
    fprintf(stderr, "Shifting error token, ");
#endif

  *++yyvsp = yylval;
#ifdef YYLSP_NEEDED
  *++yylsp = yylloc;
#endif

  yystate = yyn;
  goto yynewstate;
}
#line 1465 "vex.y"


yyerror(s)
char *s;
{
  fprintf(stderr,"%s at line %d\n",s,lines);
  exit(1);
}



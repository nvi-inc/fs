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


extern YYSTYPE yylval;

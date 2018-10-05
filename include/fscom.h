/* shared memory (fscom C data structure) layout */

typedef struct fscom {
        long iclbox;
        long iclopr;
        long nums[MAX_CLS];
	float AZOFF;
	float DECOFF;
	float ELOFF;
        int ibmat;
        int ibmcb;
	int ICAPTP[2];
	int IRDYTP[2];
	int IRENVC;
	int ILOKVC;
	int ITRAKA[2];
	int ITRAKB[2];
	unsigned long TPIVC[15];
	float ISTPTP[2];
	float ITACTP[2];
	int KHALT;
	int KECHO;
        int KENASTK[2][2];
	int INEXT[3];
	float RAOFF;
	float XOFF;
	float YOFF;
        char LLOG[8];
	char LNEWPR[8];
	char LNEWSK[8];
	char LPRC[8];
	char LSTP[8];
	char LSKD[8];
        char LEXPER[8];
        char LFEET_FS[2][6];
        short lgen[2][2];
        int ICHK[23];
	float tempwx;
	float humiwx;
	float preswx;
        float speedwx;
        int directionwx;
	float ep1950;
        float epoch;
	float cablev;
        float height;
	double ra50;
	double dec50;
        double radat;
        double decdat;
        double alat;
        double wlong;
	float systmp[MAX_TSYS_DET];
        int ldsign;
	char lfreqv[90];
        char lnaant[8];
	char lsorna[10];
        char idevant[64];
        char idevgpib[64];
        char idevlog[64][5];
        long ndevlog;
	int imodfm;
        int ipashd[2][2];
	int iratfm;
	int ispeed[2];
	int idirtp[2];
	long cips[2];
        int bit_density[2];
	int ienatp[2];
	int inp1if;
	int inp2if;
	int ionsor;
        int imaxtpsd[2];
        int iskdtpsd[2];
        float motorv[2];
        float inscint[2];
        float inscsl[2];
        float outscint[2];
        float outscsl[2];
        int itpthick[2];
        float wrvolt[2];
        int capstan[2];
	struct {
	    int allocated;
	    char name[SEM_NUM][5];
	  } go;
        struct {
            int allocated;
            char name[SEM_NUM][5];
        } sem;
        struct {
	  int bbc[ MAX_BBC];
	  long bbc_time[ MAX_BBC];
	  int dist[ MAX_VLBA_DIST];
	  int vform;
	  long fm_cn_tm;
	  int rec[2];
	  int vkrepro[2];
	  int vkenable[2];
	  int vkmove[2];
	  int systracks[2];
	  long rc_mv_tm[2];
	  int vklowtape[2];
	  int vkload[2];
	  long rc_ld_tm[2];
	  struct s2rec_check s2rec;
	  struct k4rec_check k4rec;
	  int ifp[2*MAX_DAS];
	  long ifp_time[2*MAX_DAS];
        } check;
        char stcnm[4][2];
        int  stchk[4];

        struct dist_cmd dist[ MAX_VLBA_DIST];

        struct bbc_cmd bbc[ MAX_BBC];

        long tpi[ MAX_TSYS_DET];
        long tpical[ MAX_TSYS_DET];
        long tpizero[ MAX_TSYS_DET];

        struct {
           int rack;
           int drive[2];
	   int drive_type[2];
	   int rack_type;
	   int wx_met;
	   char wx_host[65];
	  int mk4sync_dflt;
        } equip; 

        int klvdt_fs[2];
        struct vrepro_cmd vrepro[2];
        struct vform_cmd vform;
        struct venable_cmd venable[2];
	struct systracks_cmd systracks[2];
        struct dqa_cmd dqa;
        struct user_info_cmd user_info;
        struct s2st_cmd s2st;
        int s2_rec_state;
        struct rec_mode_cmd rec_mode;
        struct data_valid_cmd data_valid[2];
        struct s2label_cmd s2label;
	struct form4_cmd form4;
        float diaman;
        float slew1;
        float slew2;
        float lolim1;
        float lolim2;
        float uplim1;
        float uplim2;
        float refreq;
        int i70kch;
        int i20kch;
        struct {
          float rate[2];
          long offset[2];
          long epoch[2];
          long span[2];
          long secs_off;
          int index;
	  int icomputer[2];
          char model;
	  long unsigned ticks_off;
	  long usecs_off;
	  int init_error;
	  int init_errno;
        } time;
	float posnhd[2][2];
        int class_count;
        float horaz[MAX_HOR];
        float horel[MAX_HOR];
        char mcb_dev[64];
        unsigned char hwid;
        int iw_motion;
        int lowtp[2];
        int form_version;
        int sterp;
	int wrhd_fs[2];
	int vfm_xpnt;
	struct {
	  struct {
	    int rstate;
	    int rstate_valid;
	    long int position;
	    long int posvar;
	    int position_valid;
	  } s2rec[2];
	  int s2rec_inuse;
	} actual;
	float freqvc[15];
	int ibwvc[15];
	int ifp2vc[16];  
	char cwrap[8];
	int vacsw[2];
	float motorv2[2];
	int itpthick2[2];
	int thin[2];
	int vac4[2];
        float wrvolt2[2];
        float wrvolt4[2];
        float wrvolt42[2];
        char user_dev1_name[2];
	char user_dev2_name[2];
	double user_dev1_value;
	double user_dev2_value;
	struct rvac_cmd rvac[2];
	struct wvolt_cmd wvolt[2];
	struct lo_cmd lo;
	struct pcalform_cmd pcalform;
	struct pcald_cmd pcald;
	float extbwvc[15];
        long freqif3;
        int imixif3;
	struct pcalports_cmd pcalports;
	int k4_rec_state;
	struct k4st_cmd k4st;
	char k4tape_sqn[9];
        struct k4vclo_cmd k4vclo;
        struct k4vc_cmd k4vc;
        struct k4vcif_cmd k4vcif;
        struct k4vcbw_cmd k4vcbw;
        struct k3fm_cmd k3fm;
        int reccpu[2];
        struct k4label_cmd k4label;
        struct k4rec_mode_cmd k4rec_mode;
        struct k4recpatch_cmd k4recpatch;
        struct k4pcalports_cmd k4pcalports;
        int select;
	int rdhd_fs[2];
        int knewtape[2];
        int ihdmndel[2];
        struct scan_name_cmd scan_name;
        struct tacd_shm tacd;
/*        struct ifatt_shm ifatt; This will be used in the future.*/
        int iat1if;
        int iat2if;
        int iat3if;
        int erchk;
        int ifd_set;
        int if3_set;
        unsigned long bbc_tpi[MAX_BBC][2];
        unsigned long vifd_tpi[4];
        unsigned long mifd_tpi[3];
	float cablevl;
        float cablediff;
        int imk4fmv;
        struct tpicd_cmd tpicd;
        int ITPIVC[15];
        long tpigain[ MAX_TSYS_DET];
        int iapdflg;
        int k4rec_mode_stat; /* should be moved after k4rec_mode next chance */
        struct onoff_cmd onoff;
        struct rxgain_ds rxgain[20];
  int iswif3_fs[4];
  int ipcalif3;
  struct flux_ds flux[MAX_FLUX];

  long tpidiff[ MAX_TSYS_DET];
  long tpidiffgain[ MAX_TSYS_DET];
  float caltemps[ MAX_TSYS_DET];
  struct calrx_cmd calrx;

       int ibds;
       char ds_dev[64];
       unsigned char n_das;		/* No of installed LBA DAS */
       unsigned char lba_image_reject_filters;	/* Station default setting */
       enum bits lba_digital_input_format;	/* Station default setting */
       struct das das[MAX_DAS];	/* Up to MAX_DAS LBA DASs allowed */
       unsigned long ifp_tpi[2*MAX_DAS];
       unsigned char m_das;		/* Current DAS in Monit4 */

  char mk5vsn[33];
  long mk5vsn_logchg;
  long logchg;
  struct user_device_cmd user_device;
  struct disk_record_cmd disk_record;
  struct {
    int pong;
    struct monit5_ping {
      int active;
      struct {
	char vsn[33];
	double seconds;
	double gb;
	double percent;
	int itime[6];
      } bank[2];
    } ping[2];
  } monit5;

  struct disk2file_cmd disk2file;
  struct in2net_cmd in2net;

  struct {
    int normal_end;
    int other_error;
  } abend;

  struct s2bbc_data  s2bbc[4];
  struct s2das_check s2das;

  int ntp_synch_unknown;

  struct {
    char string[256];
    int ip2;
    char who[3];
  } last_check;

  char mk5host[129];

  struct mk5b_mode_cmd mk5b_mode;

  struct vsi4_cmd vsi4;

  struct holog_cmd holog;

  struct satellite_cmd satellite;

  struct satellite_ephem ephem[MAX_EPHEM];

  struct satoff_cmd satoff;

  struct tle_cmd tle;

  struct dbbcnn_cmd dbbcnn[ MAX_DBBCNN];
  struct dbbcifx_cmd dbbcifx[ MAX_DBBCIFX];
  struct dbbcform_cmd dbbcform;

  int dbbcddcv;
  int dbbcpfbv;
  int dbbc_cond_mods;

  struct dbbc_cont_cal_cmd dbbc_cont_cal;

  int dbbc_if_factors[MAX_DBBC_IF];

  struct dbbcgain_cmd dbbcgain;

  int m5b_crate;

  char dbbcddcvl[1];
  char dbbcddcvs[16];
  int  dbbcddcvc;

  int mk6_units[MAX_MK6];
  int mk6_active[MAX_MK6];

  struct mk6_record_cmd mk6_record[MAX_MK6+1];

  struct {
    char string[256];
    int ip2;
    char who[3];
    char what[3];
  } mk6_last_check[MAX_MK6];

  int rdbe_units[MAX_RDBE];
  int rdbe_active[MAX_RDBE];

  struct rdbe_tsys_data {
    struct rdbe_tsys_cycle {;
      char epoch[14];
      int epoch_vdif;
      float tsys[MAX_RDBE_CH+2][MAX_RDBE_IF];
      float pcal_amp[512];
      float pcal_phase[512];
      int pcal_ifx;
      float sigma;
      int raw_ifx;
      double dot2gps;
      double dot2pps;
      double pcaloff;
      double pcal_spacing;
    } data[2];
    int iping;
  } rdbe_tsys_data[MAX_RDBE];

  char rdbehost[MAX_RDBE][129];

  struct rdbe_atten_cmd  rdbe_atten[MAX_RDBE+1];

  struct rdtcn {
    struct rdtcn_control {
      int continuous;
      int cycle;
      int stop_request;
      struct data_valid_cmd data_valid;
    } control[2];
    int iping;
  } rdtcn [MAX_RDBE];

  struct fserr_cls {
    char buf[125];
    int nchars;
  } fserr_cls;

  int dbbc_defined;
  int dbbc2_defined;

  struct {
    float rms_t;
    float rms_min;
    float rms_max;
    char pcal_amp[1];
  } rdbe_equip;

  struct monit6 {
    int tsys[MAX_RDBE_IF][MAX_RDBE];
    int pcal[MAX_RDBE_IF][MAX_RDBE];
    int dot2pps_ns;
  } monit6;

  long rdbe_sync[MAX_RDBE];

  int  dbbc3_ddc_v;
  char dbbc3_ddc_vs[16];
  int  dbbc3_ddc_vc;
  int  dbbc3_ddc_bbcs_per_if;
  int  dbbc3_ddc_ifs;

  struct dbbc3_ifx_cmd dbbc3_ifx[ MAX_DBBC3_IF];

  struct dbbc3_bbcnn_cmd dbbc3_bbcnn[ MAX_DBBC3_BBC];

  struct dbbc3_cont_cal_cmd dbbc3_cont_cal;

} Fscom;

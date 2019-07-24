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
	int ICAPTP;
	int IRDYTP;
	int IRENVC;
	int ILOKVC;
	int ITRAKA;
	int ITRAKB;
	int TPIVC;
	float ISTPTP;
	float ITACTP;
	int KHALT;
	int KECHO;
        int KENASTK[2];
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
        int LFEET_FS[3];
        int lgen[2];
        int IREMTP;
        int ICHK[21];
	float tempwx;
	float humiwx;
	float preswx;
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
	float systmp[32];
        int ldsign;
	char lfreqv[90];
        char lnaant[8];
	char lsorna[10];
        char idevant[64];
        char idevgpib[64];
        char idevlog[64][5];
        long ndevlog;
	int imodfm;
        int ipashd[2];
	int iratfm;
	int ispeed;
	int idirtp;
	int ienatp;
	int inp1if;
	int inp2if;
	int ionsor;
        int imaxtpsd;
        int iskdtpsd;
        float motorv;
        float inscint;
        float inscsl;
        float outscint;
        float outscsl;
        int itpthick;
        float wrvolt;
        int capstan;
        struct {
            int allocated;
            char name[MAX_SEM_LIST][5];
        } sem;

        struct {
           int bbc[ MAX_BBC];
           int dist[ MAX_DIST];
           int vform;
           int rec;
           int vrepro;
           int venable;
        } check;
        char stcnm[4][2];
        int  stchk[4];

        struct dist_cmd dist[ MAX_DIST];

        struct bbc_cmd bbc[ MAX_BBC];

        unsigned tpi[ MAX_DET];
        unsigned tpical[ MAX_DET];
        unsigned tpizero[ MAX_DET];

        struct {
           int rack;
           int drive;
        } equip; 

        int klvdt_fs;
        struct vrepro_cmd vrepro;
        struct vform_cmd vform;
        struct venable_cmd venable;
        struct dqa_cmd dqa;
        float freqlo[4];
        float frequp[4];
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
        int iacttp;
        struct {
          float rate[2];
          long offset[2];
          long epoch[2];
          long span[2];
          long secs_off;
          int index;
          char model;
        } time;
        int class_count;
        float horaz[MAX_HOR];
        float horel[MAX_HOR];
        char mcb_dev[64];
        unsigned char hwid;
        int iw_motion;
        int lowtp;
        int form_version;
} Fscom;

/* IPC keys parameter header */

#ifdef NO_FTOK_FS
#define SHM_KEY     1
#define CLS_KEY     2
#define SKD_KEY     3
#define BRK_KEY     4
#define SEM_KEY     5
#define NSEM_KEY    6
#define GO_KEY      7
#else
#define SHM_KEY     ftok("/usr2/fs",1)
#define CLS_KEY     ftok("/usr2/fs",2)
#define SKD_KEY     ftok("/usr2/fs",3)
#define BRK_KEY     ftok("/usr2/fs",4)
#define SEM_KEY     ftok("/usr2/fs",5)
#define NSEM_KEY    ftok("/usr2/fs",6)
#define GO_KEY      ftok("/usr2/fs",7)
#endif


#ifndef LIB_DEFD
#define LIB_DEFD


void* malloc2(int size);

const char* strapp (const char* a, const char* b, const char* c);
const char* strapp5(const char* a, const char* b, const char* c,
                    const char* d, const char* e);

long int str_to_int(const char* a);
const char* int_to_str(long int a, int f);

double str_to_double(const char* a);
const char* double_to_str(double a);
const char* double_to_str2(double a, int f, int p);

ibool streq(const char* name1, const char* name2);
ibool strne(const char* name1, const char* name2);

ibool strneq(const char* name1, const char* name2, int n);
ibool strnne(const char* name1, const char* name2, int n);

const char* bool_to_onoff(ibool val);
const char* bool_to_enab(ibool val);
const char* bool_to_valid(ibool val);
const char* bool_to_yesno(ibool val);

ibool one_of(char a, const char* delim);

int intpow(int base, int power);
int intlog(int base, int arg);

void strip_trailing_spaces(char* str);

int count_bits(unsigned int arg);
int first_bit_set(int arg);

const char* chanset_to_str(int chans);

void malloc_out_of_space(char* routine, int code);

#ifdef UNIX
/* functions for compatibility with DOS */
#ifndef LIB      /* to handle conflicting definition in lib.c! */
int cprintf(const char* format, ...);
#endif !LIB

void clreol(void);

void gotoxy(int x, int y);
int wherex(void);
int wherey(void);

int kbhit(void);
#endif UNIX


#endif !LIB_DEFD


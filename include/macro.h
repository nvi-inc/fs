/* utility macros */

/* bits16on will turn on WORD_BIT least sig. bits, n > 16 not portable */
#define bits16on(n)  (n >= WORD_BIT ? (~0) : ~( (~0) << n ) )

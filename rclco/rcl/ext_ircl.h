/* Defines the macros EXTERN and INIT depending on the setting of RCL_MAIN. 
 * These macros allow global variables to be defined in exactly one header
 * file, for both the main definition and external references, even though
 * these have different syntax. For example, the variable FormBercOv would
 * be defined using:
 *    int FormBercOv = 0;
 * and referenced using:
 *    extern int FormBercOv;
 *
 * With the EXTERN/INIT macros, this becomes a single definition:
 *    EXTERN int FormBercOv INIT(0);
 * The macro RCL_MAIN should be defined in the .c file making the main
 * definition.
 *
 * In some cases the INIT macro cannot be used because the argument contains
 * commas. In this case we work around by checking RCL_MAIN directly:
 *    EXTERN const int FormAdcAddrs[4]
 *    #ifdef RCL_MAIN
 *                   = {FORM_ADC1, FORM_ADC2, FORM_ADC3, FORM_ADC4}
 *    #endif
 *                   ;
 */

#undef EXTERN
#undef INIT
#undef GLOBAL
#undef LOCAL

#define GLOBAL
#define LOCAL static

#ifdef RCL_MAIN
#   define EXTERN
#   define INIT(arg) = arg
#else
#   define EXTERN extern
#   define INIT(arg)
#endif



/* lba das ifp buffer parsing utilities */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/time.h>
#include <sys/types.h>
#include <unistd.h>
#include <limits.h>
#include <math.h>

#include "../include/macro.h"
#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

/* function prototypes */
void dscon_snd();
int dscon_rcv();
int run_dscon();
int arg_dble();
int arg_key_flt();
int arg_key();
void cls_clr();

/* global variables/definitions */
static char *bw_key[ ]={"0.0625","0.125","0.25","0.5","1","2","4","8","16","32","64"};
static char *md_key[ ]={"none","scb","dsb","acb","sc1","ds2","ds4","ds6","ac1"};
static char *fl_key[ ]={"nat","flip"};
static char *fm_key[ ]={"at","vlba"};
static char *lv_key[ ]={"4lvl","3lvl"};

#define NBW_KEY sizeof(bw_key)/sizeof( char *)
#define NMD_KEY sizeof(md_key)/sizeof( char *)
#define NFL_KEY sizeof(fl_key)/sizeof( char *)
#define NFM_KEY sizeof(fm_key)/sizeof( char *)
#define NLV_KEY sizeof(lv_key)/sizeof( char *)

unsigned short ifp_16bit_cache[MAX_DAS][2][32];	/* write through cache */

int lba_ifp_dec(lcl,count,ptr)
  struct ifp *lcl;
  int *count;
  char *ptr;
{
    int ierr;

    ierr=0;
    if(ptr == NULL) ptr="";
    switch (*count) {
      case 1:
          ierr=arg_dble(ptr,&lcl->frequency,0,FALSE);
        break;
      case 2:
          ierr=arg_key_flt(ptr,bw_key,NBW_KEY,&lcl->bandwidth,_2D000,TRUE);
        break;
      case 3:
          ierr=arg_key(ptr,md_key,NMD_KEY,&lcl->filter_mode,_DSB,TRUE);
          if (lcl->filter_mode <= _NONE) ierr = -200;
        break;
      case 4:
          ierr=arg_key(ptr,fl_key,NFL_KEY,&lcl->flip_usb,_NATURAL,TRUE);
        break;
      case 5:
          ierr=arg_key(ptr,fl_key,NFL_KEY,&lcl->flip_lsb,_NATURAL,TRUE);
        break;
      case 6:
          ierr=arg_key(ptr,fm_key,NFM_KEY,&lcl->format,_AT_2_BIT,TRUE);
        break;
      case 7:
          ierr=arg_key(ptr,lv_key,NLV_KEY,&lcl->magn_stats,_4_LVL,TRUE);
        break;
      default:
       *count=-1;
   }
   if(ierr!=0) ierr-=*count;
   if(*count>0) (*count)++;
   return ierr;
}

void lba_ifp_enc(output,count,lcl)
char *output;
int *count;
struct ifp *lcl;
{
    int ivalue;

    output=output+strlen(output);

    switch (*count) {
      case 1:
        sprintf(output,"%-.2f",lcl->frequency);
        break;
      case 2:
        ivalue = lcl->bandwidth;
        if (ivalue >=0 && ivalue <NBW_KEY)
          strcpy(output,bw_key[ivalue]);
        else
          strcpy(output,BAD_VALUE);
        break;
      case 3:
        ivalue = lcl->filter_mode;
        if (ivalue >=0 && ivalue <NMD_KEY)
          strcpy(output,md_key[ivalue]);
        else
          strcpy(output,BAD_VALUE);
        break;
      case 4:
        ivalue = lcl->flip_usb;
        if (ivalue >=0 && ivalue <NFL_KEY)
          strcpy(output,fl_key[ivalue]);
        else
          strcpy(output,BAD_VALUE);
        break;
      case 5:
        ivalue = lcl->flip_lsb;
        if (ivalue >=0 && ivalue <NFL_KEY)
          strcpy(output,fl_key[ivalue]);
        else
          strcpy(output,BAD_VALUE);
        break;
      case 6:
        ivalue = lcl->format;
        if (ivalue >=0 && ivalue <NFM_KEY)
          strcpy(output,fm_key[ivalue]);
        else
          strcpy(output,BAD_VALUE);
        break;
      case 7:
        ivalue = lcl->magn_stats;
        if (ivalue >=0 && ivalue <NLV_KEY)
          strcpy(output,lv_key[ivalue]);
        else
          strcpy(output,BAD_VALUE);
        break;
      default:
       *count=-1;
   }

   if(*count>0) *count++;
   return;
}

int lba_tpi_from_level(level)
unsigned short level;
{
   if ((level & 0x00FF) == 0x0000) return (65535);
   else if ((level & 0x00FF) == 0x00FF) return (0);
   else return((int)(16384*exp((128-(level & 0x00FF))*log(10.0)/220.0)));
}

void lba_ifp_mon(output,count,lcl)
char *output;
int *count;
struct ifp *lcl;
{
    int tpi;

    output=output+strlen(output);

    switch (*count) {
      case 1:
        if (!lcl->clk_err && !lcl->sync_err && !lcl->ref_err)
          strcpy(output,"sync");
        else
          strcpy(output,"err");
        break;
      case 2:
        if (lcl->processing)
          strcpy(output,"proc");
        else
          strcpy(output,"ntrdy");
        break;
      case 3:
      	  tpi = lba_tpi_from_level(lcl->bs.level.readout);
          sprintf(output,"%d",tpi);
        break;
      default:
        *count=-1;
   }
   if(*count > 0) *count++;
   return;
}

int lba_ifp_setup(lcl, n_ifp)
struct ifp *lcl;
int n_ifp;
{
   int alias, n_das, chan;
   double baseband, ft_centre, c_err;
   unsigned short exchange_s2_sideband;

   enum bsf {_B1_32,  _B1_16,  _B1_8, _B1_4,  _B1_2,  _B1_1,
                     _B1_16S, _B1_8S, _B1_4S, _B1_2S, _B1_1S,
                     _B2_16,  _B2_8,  _B2_4,  _B2_2,  _B2_1, 
                              _B4_8,
                              _B6_8,
             _B_NONE }	bs_filter;

   enum ftf {_F0_Bdiv1,
             _F1_Bdiv1,  _F1_Bdiv2,  _F1_Bdiv4,  _F1_Bdiv8,  _F1_Bdiv16,
             _F1_Bdiv1S, _F1_Bdiv2S, _F1_Bdiv4S, _F1_Bdiv8S, _F1_Bdiv16S,
                         _F2_Bdiv2,  _F2_Bdiv4,  _F2_Bdiv8,  _F2_Bdiv16,
             _F_NONE }	ft_filter;

   n_das = n_ifp/2;
   chan = n_ifp%2;

   if (lcl->frequency < 0.0) return(-201);

   /* For VLBI require an integral number of Hz */
   if (fabs(lcl->frequency - ((double) floor(lcl->frequency * 1.0e6) / 1.0e6)) > 1.0e-10)
	return(-201);

   /* First allow for aliasing of IF input due to 64MHz digital sampling */
   alias = floor(lcl->frequency / 64.0);
   baseband = lcl->frequency - alias * 64.0;

   /* The analog image reject filter can be used only for the second alias */
   if (alias == 2 && shm_addr->lba_image_reject_filters)
	lcl->bs.image_reject_filter = _IN;
   else lcl->bs.image_reject_filter = _OUT;

   /* Set input gain and offset servo loops into AUTO mode */
   lcl->bs.level.setting = lcl->bs.level.readout;
   lcl->bs.level.mode = _AUTO;
   lcl->bs.offset.setting = 128;
   lcl->bs.offset.mode = _AUTO;

   /* The digital input format is a station dependant parameter */
   lcl->bs.digital_format = shm_addr->lba_digital_input_format;

   /* Odd aliases are inverted by sampler, even aliases are not */
   lcl->bs.flip_input = lcl->bs.flip_64MHz_out = (alias%2);

   /* Filter Selection depends on bandwidth, filter_mode and frequency */
   switch (lcl->bandwidth) {

     case _64D00:
	/*
	   Only one possibility:- input 64MHz replicated directly to output
	   in a bypass fashion.  Equivalent to 32MHz case ( as we setup the
	   Band Splitter ready for Tsys monitoring ) exceptng the USB flip
	   control directly affects the 64 MHz output also in this case.
	 */
	if (lcl->flip_usb == _FLIPPED) 
		lcl->bs.flip_64MHz_out = (!lcl->bs.flip_64MHz_out) & 0x01;

     case _32D00:
	/*
	   Only one possiblity:- a fixed 32MHz smooth Centre Band filter in the
	   middle of the 64MHz input band (ie. centred on 32MHz) generated
	   in the Band Splitter.
	 */
	if (lcl->filter_mode != _SCB && lcl->filter_mode != _SC1)
		return(-203);			/* Only smooth Centre Band */

	if (baseband != 32.0) return(-201);	/* BS only ie. not tunable */

	/* Setup Band Splitter as 32MHz Center Band filter */
	bs_filter = _B1_32;
	lcl->bs.clock_decimation = 0;		/* FT only takes 16MHz */

	/* Centre Band: USB flipper flips the entire band */
	lcl->bs.flip_usb = lcl->flip_usb;
	lcl->bs.flip_lsb = _NATURAL;

	ft_centre = 32.0;

	/* Analog monitor set to AUTO to get full 32MHz Centre Band */
	lcl->bs.monitor.mode = _AUTO;

	/* Send undersampled "USB" through to Fine Tuner for Tsys monitoring */
	lcl->bs.digout.setting = _USB;
	lcl->bs.digout.mode = _MANUAL;
	lcl->bs.digout.tristate = _ENABLE;

	/* Full 64/32MHz output only available from Band Splitter */
	lcl->filter_output = _BS;
	ft_filter = _F_NONE;

	/* For Band Splitter only modes we are done, otherwise ... */
	if (lcl->filter_mode == _SCB) {
		/*
		   Setup Fine Tuner as 16MHz Smooth Centre Band Filter in the
		   middle of the 16 MHz USB output of the Band Splitter ie.
		   centred at 8MHZ which actually contains the whole 32MHz
		   band undersampled by a factor of two.
		 */
		ft_filter = _F1_Bdiv1S;
		lcl->ft.clock_decimation = 0;
		lcl->ft.flip_usb = lcl->ft.flip_lsb = _NATURAL;
	}
	break;

     case _16D00:
	/*
	   Three possible scenarios:
	    (1) Any of the fixed 16MHz Band Splitter possibilities, always
		centred on 32MHz.
	    (2) A 16MHz Centre Band filter centered on 24 or 40MHz generated
		as either flipped LSB or upright USB of a 16MHz DSB filter in
		the Band Splitter, tunable up to bw/32.
	    (3) A 16MHz Centre Band filter centred on 32MHz generated in the
		Band Splitter, tunable up to bw/32.
	 */
	if (lcl->filter_mode == _DS4 || lcl->filter_mode == _DS6)
		return(-203);			/* Only available at 8MHz */

	/* Case 1: Band Splitter generated modes, centred at 32MHz */
	if (lcl->filter_mode == _DSB || lcl->filter_mode == _DS2 ||
	    lcl->filter_mode == _SC1 || lcl->filter_mode == _AC1) {

		if (baseband != 32.0) return(-201);
	
		if (lcl->filter_mode == _DSB) bs_filter = _B2_16;
		if (lcl->filter_mode == _DS2) bs_filter = _B2_16;
		if (lcl->filter_mode == _SC1) bs_filter = _B1_16S;
		if (lcl->filter_mode == _AC1) bs_filter = _B1_16;
		lcl->bs.clock_decimation = 0;
	
		/* Flip individual sideband requests in Band Splitter */
		lcl->bs.flip_usb = lcl->flip_usb;
		if (lcl->filter_mode != _SC1 && lcl->filter_mode != _AC1)
			lcl->bs.flip_lsb = lcl->flip_lsb;
		/* ... Centre Band only needs USB flip to flip entire band */
		else	lcl->bs.flip_lsb = _NATURAL;

		ft_centre = 32.0;

		if (lcl->filter_mode == _DSB || lcl->filter_mode == _DS2) {
			/* Feed MON choice to Band Splitter analog monitor */
			lcl->bs.monitor.mode = _MANUAL;
			/* .. and FT choice to Fine Tuner for Tsys monitoring */
			lcl->bs.digout.mode = _MANUAL;
		} else {
			/* Feed Centre Band to Band Splitter analog monitor */
			lcl->bs.monitor.mode = _AUTO;
			/* .. and also to Fine Tuner for Tsys monitoring */
			lcl->bs.digout.mode = _AUTO;
		}
		lcl->bs.digout.tristate = _ENABLE;


	/* Case 2: Centre Band Filter centred on 24 or 40MHz */
	} else if (fabs(baseband-24.0) <= 1.0 || fabs(baseband-40.0) <= 1.0) {

		/* Generate as DSB in Band Splitter */
		bs_filter = _B2_16;
		lcl->bs.clock_decimation = 0;

		/* Always flip LSB so both bands upright */
		lcl->bs.flip_usb = _NATURAL;
		lcl->bs.flip_lsb = _FLIPPED;

		/* Feed appropriate sideband through to Fine Tuner */
		if (baseband < 32.0) {
			ft_centre = 24.0;
			lcl->bs.digout.setting = _LSB;
		} else {
			ft_centre = 40.0;
			lcl->bs.digout.setting = _USB;
		}
		/* .. and MON choice to Band Splitter analog monitor */
		lcl->bs.monitor.mode = lcl->bs.digout.mode = _MANUAL;
		lcl->bs.digout.tristate = _ENABLE;

	/* Case 3: Centre Band Filter centred on 32MHz */
	} else if (fabs(baseband-32.0) <= 1.0) {

		/* Use 16MHz smooth Centre Band filter in Band Splitter */
		bs_filter = _B1_16S;
		lcl->bs.clock_decimation = 0;

		/* Centre Band: Already upright */
		lcl->bs.flip_usb = lcl->bs.flip_lsb = _NATURAL;
	
		ft_centre = 32.0;

		/* Feed the Centre Band through */
		lcl->bs.monitor.mode = lcl->bs.digout.mode = _AUTO;
		lcl->bs.digout.tristate = _ENABLE;

	} else return(-201);	/* Bad frequency/mode combination */

	/* Output is primarily available from Band Splitter */
	lcl->filter_output = _BS;
	ft_filter = _F_NONE;

	/* For Band Splitter only modes we are done, otherwise ... */
	if (lcl->filter_mode == _DSB || lcl->filter_mode == _SCB
	                             || lcl->filter_mode == _ACB) {
		/*
		   Setup Fine Tuner as appropriate 16MHz Centre Band filter
		   in the middle of the selected 16 MHz output of the Band
		   Splitter ie. centred approximately at 8MHz.
		 */
		if (lcl->filter_mode == _DSB)		ft_filter = _F0_Bdiv1;
		else if (lcl->filter_mode == _ACB)	ft_filter = _F1_Bdiv1;
		else					ft_filter = _F1_Bdiv1S;
		lcl->ft.clock_decimation = 0;

		/* Flip Centre Bands as per request if not already done */
		if (lcl->filter_mode != _DSB)
			lcl->ft.flip_usb = lcl->flip_usb;
		else	lcl->ft.flip_usb = _NATURAL;
		lcl->ft.flip_lsb = _NATURAL;

		/* Excepting DSB, output is from Fine Tuner */
		if (lcl->filter_mode != _DSB) lcl->filter_output = _FT;
	}
	break;

     case _8D000:
	/*
	   Four possible scenarios:
	    (1) Any of the fixed 8MHz Band Splitter possibilities, centred
		on/about 32MHz.
	    (2) An 8MHz Centre Band Filter centred on either 12 or 52MHz
		generated as separated bands in the Band Splitter, tunable
		up to bw/32.
	    (3) An 8MHz Centre Band Filter centred anywhere from 20MHz through
		44 MHz generated as either 16MHz flipped LSB, Centre Band or
		USB in the Band Splitter, tunable up to bw/32 beyond.
	    (4) 8MHz Dual Sideband Filters centred on one of 24, 32 & 40MHz
		generated respectively as 16MHz flipped LSB, Centre Band or
		USB in the Band Splitter, tuneable up to bw/32.
	 */

	/* Case 1: Band Splitter only modes, centred at 32MHz */
	if (lcl->filter_mode == _SC1 || lcl->filter_mode == _DS2 ||
	    lcl->filter_mode == _DS4 || lcl->filter_mode == _DS6
	                             || lcl->filter_mode == _AC1) {

		if (baseband != 32.0) return(-201);
	
		if (lcl->filter_mode == _SC1) bs_filter = _B1_8S;
		if (lcl->filter_mode == _DS2) bs_filter = _B2_8;
		if (lcl->filter_mode == _DS4) bs_filter = _B4_8;
		if (lcl->filter_mode == _DS6) bs_filter = _B6_8;
		if (lcl->filter_mode == _AC1) bs_filter = _B1_8;
		lcl->bs.clock_decimation = 1;
	
		/* Flip individual sidebands to match request */
		lcl->bs.flip_usb = lcl->flip_usb;
		if (lcl->filter_mode != _SC1 && lcl->filter_mode != _AC1)
			lcl->bs.flip_lsb = lcl->flip_lsb;
		/* ... Centre Band only needs USB flip to flip entire band */
		else	lcl->bs.flip_lsb = _NATURAL;

		/* For DS4 filters both sidebands need an additional flip */
		if (lcl->filter_mode == _DS4) {
			lcl->bs.flip_usb = (!lcl->bs.flip_usb) & 0x01;
			lcl->bs.flip_lsb = (!lcl->bs.flip_lsb) & 0x01;
		}

		ft_centre = 32.0;

		if (lcl->filter_mode == _DSB || lcl->filter_mode == _DS2 ||
		    lcl->filter_mode == _DS4 || lcl->filter_mode == _DS6) {
			/* Feed MON choice to Band Splitter analog monitor */
			lcl->bs.monitor.mode = _MANUAL;
			/* .. and FT choice to Fine Tuner for Tsys monitoring */
			lcl->bs.digout.mode = _MANUAL;
		} else {
			/* Feed Centre Band to Band Splitter analog monitor */
			lcl->bs.monitor.mode = _AUTO;
			/* .. and on to Fine Tuner for Tsys monitoring */
			lcl->bs.digout.mode = _AUTO;
		}
		lcl->bs.digout.tristate = _ENABLE;

	/* Case 2: Centre Band filter centred on 12 or 52MHz */
	} else if (fabs(baseband-12.0) <= 0.5 || fabs(baseband-52.0) <= 0.5) {

		if (lcl->filter_mode == _DSB)
			return(-201);			/* only room for 8MHz */

		/* Use separated 8MHz filters in Band Splitter */
		bs_filter = _B6_8;
		lcl->bs.clock_decimation = 1;

		/* Always flip LSB so both bands upright */
		lcl->bs.flip_usb = _NATURAL;
		lcl->bs.flip_lsb = _FLIPPED;

		/* Feed appropriate sideband through to Fine Tuner */
		if (baseband < 32.0) {
			ft_centre = 12.0;
			lcl->bs.digout.setting = _LSB;
		} else {
			ft_centre = 52.0;
			lcl->bs.digout.setting = _USB;
		}
		/* .. and MON choice to Band Splitter analog monitor */
		lcl->bs.monitor.mode = lcl->bs.digout.mode = _MANUAL;
		lcl->bs.digout.tristate = _ENABLE;

	/* Case 3/4a: 8MHz Centre Band or DSB generated via 16MHz LSB or USB */
	} else if ((baseband >= 19.5 && baseband < 28.0) ||
		   (baseband > 36.0 && baseband <= 44.5)) {

		/* DSB has limited tuning range */
		if (lcl->filter_mode == _DSB && fabs(baseband-24.0) > 0.5
		                             && fabs(baseband-40.0) > 0.5)
			return(-201);

		/* Use 16MHz Double sideband filter in Band Splitter */
		bs_filter = _B2_16;
		lcl->bs.clock_decimation = 0;

		/* Always flip LSB so both bands upright */
		lcl->bs.flip_usb = _NATURAL;
		lcl->bs.flip_lsb = _FLIPPED;

		/* Feed appropriate sideband through to Fine Tuner */
		if (baseband < 32.0) {
			ft_centre = 24.0;
			lcl->bs.digout.setting = _LSB;
		} else {
			ft_centre = 40.0;
			lcl->bs.digout.setting = _USB;
		}
		/* .. and MON choice to Band Splitter analog monitor */
		lcl->bs.monitor.mode = lcl->bs.digout.mode = _MANUAL;
		lcl->bs.digout.tristate = _ENABLE;

	/* Case 3/4b: 8MHz Centre Band or DSB generated via 16MHz Centre Band */
	} else if (baseband >= 28.0 && baseband <= 36.0) {

		/* DSB has limited tuning */
		if (lcl->filter_mode == _DSB && fabs(baseband-32.0) > 0.5)
			return(-201);

		/* Use smooth 16MHz Centre Band filter in Band Splitter */
		bs_filter = _B1_16S;
		lcl->bs.clock_decimation = 0;

		/* Centre Band: Already upright */
		lcl->bs.flip_usb = lcl->bs.flip_lsb = _NATURAL;

		ft_centre = 32.0;

		/* Feed the Centre Band through */
		lcl->bs.monitor.mode = lcl->bs.digout.mode = _AUTO;
		lcl->bs.digout.tristate = _ENABLE;

	} else return(-201);	/* Bad frequency/mode combination */

	/* Output is primarily available from Band Splitter */
	lcl->filter_output = _BS;
	ft_filter = _F_NONE;

	/* For Band Splitter only modes we are done, otherwise ... */
	if (lcl->filter_mode == _DSB || lcl->filter_mode == _SCB
	                             || lcl->filter_mode == _ACB) {
		/*
		   Setup Fine Tuner for desired response relative to the
		   selected 8/16MHz output of the Band Splitter.
		 */
		if (lcl->filter_mode == _DSB)	ft_filter = _F2_Bdiv2;
		if (lcl->filter_mode == _SCB)	ft_filter = _F1_Bdiv2S;
		if (lcl->filter_mode == _ACB)	ft_filter = _F1_Bdiv2;
		lcl->ft.clock_decimation = 1;
		/* For B6_8 outer bands, already decimated in Band Splitter */
		if (fabs(baseband-12.0) <= 0.5 || fabs(baseband-52.0) <= 0.5) {
			if (lcl->filter_mode == _SCB)	ft_filter = _F1_Bdiv1S;
			else				ft_filter = _F1_Bdiv1;
			lcl->ft.clock_decimation = 0;
		}

		/* Flip individual sidebands to match request */
		lcl->ft.flip_usb = lcl->flip_usb;
		if (lcl->filter_mode == _DSB)
			lcl->ft.flip_lsb = lcl->flip_lsb;
		/* ... Centre Band only needs USB flip to flip entire band */
		else	lcl->ft.flip_lsb = _NATURAL;

		/* Outputs all available on Fine Tuner */
		lcl->filter_output = _FT;
	}
	break;

     case _4D000:
	/*
	   Three possible scenarios:
	    (1) Any of the fixed 4MHz Band Splitter possibilities, centred
		on 32MHz.
	    (2) A 4MHz Centre Band Filter centred anywhere from 18MHz through
		46MHz generated as either 16MHz flipped LSB, Centre Band or
		USB in the Band Splitter, tunable up to bw/32 beyond.
	    (3) 4MHz Dual Sideband Filters centred anywhere from 20MHz through
		44MHz generated as either 16MHz flipped LSB, Centre Band or
		USB in the Band Splitter, tuneable up to bw/32 beyond.
	 */
	if (lcl->filter_mode == _DS4 || lcl->filter_mode == _DS6)
		return(-203);			/* Only available at 8MHz */

	/* Case 1: Band Splitter only modes, centred at 32MHz */
	if (lcl->filter_mode == _SC1 || lcl->filter_mode == _DS2
	                             || lcl->filter_mode == _AC1) {

		if (baseband != 32.0) return(-201);
	
		if (lcl->filter_mode == _SC1) bs_filter = _B1_4S;
		if (lcl->filter_mode == _DS2) bs_filter = _B2_4;
		if (lcl->filter_mode == _AC1) bs_filter = _B1_4;
		lcl->bs.clock_decimation = 2;
	
		/* Flip individual sidebands to match request */
		lcl->bs.flip_usb = lcl->flip_usb;
		if (lcl->filter_mode != _SC1 && lcl->filter_mode != _AC1)
			lcl->bs.flip_lsb = lcl->flip_lsb;
		/* ... Centre Band only needs USB flip to flip entire band */
		else	lcl->bs.flip_lsb = _NATURAL;

		ft_centre = 32.0;

		if (lcl->filter_mode == _DSB || lcl->filter_mode == _DS2) {
			/* Feed MON choice  to Band Splitter analog monitor */
			lcl->bs.monitor.mode = _MANUAL;
			/* .. and FT choice to Fine Tuner for Tsys monitoring */
			lcl->bs.digout.mode = _MANUAL;
		} else {
			/* Feed Centre Band to Band Splitter analog monitor */
			lcl->bs.monitor.mode = _AUTO;
			/* .. and on to Fine Tuner for Tsys monitoring */
			lcl->bs.digout.mode = _AUTO;
		}
		lcl->bs.digout.tristate = _ENABLE;

	/* Case 2/3a: 4MHz Centre Band or DSB generated via 16MHz LSB or USB */
	} else if ((baseband >= 17.75 && baseband < 28.0) ||
		   (baseband > 36.0 && baseband <= 46.25)) {

		/* DSB has more limited tuning range */
		if (lcl->filter_mode == _DSB && 
		    (baseband < 19.75 || baseband > 44.25))
			return(-201);

		/* Use 16MHz Double sideband filter in Band Splitter */
		bs_filter = _B2_16;
		lcl->bs.clock_decimation = 0;

		/* Always flip LSB so both bands upright */
		lcl->bs.flip_usb = _NATURAL;
		lcl->bs.flip_lsb = _FLIPPED;

		/* Feed appropriate sideband through to Fine Tuner */
		if (baseband < 32.0) {
			ft_centre = 24.0;
			lcl->bs.digout.setting = _LSB;
		} else {
			ft_centre = 40.0;
			lcl->bs.digout.setting = _USB;
		}
		/* .. and MON choice to Band Splitter analog monitor */
		lcl->bs.monitor.mode = lcl->bs.digout.mode = _MANUAL;
		lcl->bs.digout.tristate = _ENABLE;

	/* Case 2/3b: 4MHz Centre Band or DSB generated via 16MHz Centre Band */
	} else if (baseband >= 28.0 && baseband <= 36.0) {

		/* Use smooth 16MHz Centre Band filter in Band Splitter */
		bs_filter = _B1_16S;
		lcl->bs.clock_decimation = 0;

		/* Centre Band: already upright */
		lcl->bs.flip_usb = lcl->bs.flip_lsb = _NATURAL;

		ft_centre = 32.0;

		/* Feed the Centre Band through */
		lcl->bs.monitor.mode = lcl->bs.digout.mode = _AUTO;
		lcl->bs.digout.tristate = _ENABLE;

	} else return(-201);	/* Bad frequency/mode combination */

	/* Output is primarily available from Band Splitter */
	lcl->filter_output = _BS;
	ft_filter = _F_NONE;

	/* For Band Splitter only modes we are done, otherwise ... */
	if (lcl->filter_mode == _DSB || lcl->filter_mode == _SCB
	                             || lcl->filter_mode == _ACB) {
		/*
		   Setup Fine Tuner for desired response relative to the
		   selected 16MHz output of the Band Splitter.
		 */
		if (lcl->filter_mode == _DSB)	ft_filter = _F2_Bdiv4;
		if (lcl->filter_mode == _SCB)	ft_filter = _F1_Bdiv4S;
		if (lcl->filter_mode == _ACB)	ft_filter = _F1_Bdiv4;
		lcl->ft.clock_decimation = 2;

		/* Flip individual sidebands to match request */
		lcl->ft.flip_usb = lcl->flip_usb;
		if (lcl->filter_mode == _DSB)
			lcl->ft.flip_lsb = lcl->flip_lsb;
		/* ... Centre Band only needs USB flip to flip entire band */
		else	lcl->ft.flip_lsb = _NATURAL;

		/* Outputs all available on Fine Tuner */
		lcl->filter_output = _FT;
	}
	break;

     case _2D000:
	/*
	   Three possible scenarios:
	    (1) Any of the fixed 2MHz Band Splitter possibilities, centred
		on 32MHz.
	    (2) A 2MHz Centre Band Filter centred anywhere from 17MHz through
		47MHz generated as either 16MHz flipped LSB, Centre Band or
		USB in the Band Splitter, tunable up to bw/32 beyond.
	    (3) 2MHz Dual Sideband Filters centred anywhere from 18MHz through
		46MHz generated as either 16MHz flipped LSB, Centre Band or
		USB in the Band Splitter, tuneable up to bw/32 beyond.
	 */
	if (lcl->filter_mode == _DS4 || lcl->filter_mode == _DS6)
		return(-203);			/* Only available at 8MHz */

	/* Case 1: Band Splitter only modes, centred at 32MHz */
	if (lcl->filter_mode == _SC1 || lcl->filter_mode == _DS2
	                             || lcl->filter_mode == _AC1) {

		if (baseband != 32.0) return(-201);
	
		if (lcl->filter_mode == _SC1) bs_filter = _B1_2S;
		if (lcl->filter_mode == _DS2) bs_filter = _B2_2;
		if (lcl->filter_mode == _AC1) bs_filter = _B1_2;
		lcl->bs.clock_decimation = 3;
	
		/* Flip individual sidebands to match request */
		lcl->bs.flip_usb = lcl->flip_usb;
		if (lcl->filter_mode != _SC1 && lcl->filter_mode != _AC1)
			lcl->bs.flip_lsb = lcl->flip_lsb;
		/* ... Centre Band only needs USB flip to flip entire band */
		else	lcl->bs.flip_lsb = _NATURAL;

		ft_centre = 32.0;

		if (lcl->filter_mode == _DSB || lcl->filter_mode == _DS2) {
			/* Feed MON choice to Band Splitter analog monitor */
			lcl->bs.monitor.mode = _MANUAL;
			/* .. and FT choice to Fine Tuner for Tsys monitoring */
			lcl->bs.digout.mode = _MANUAL;
		} else {
			/* Feed Centre Band to Band Splitter analog monitor */
			lcl->bs.monitor.mode = _AUTO;
			/* .. and on to Fine Tuner for Tsys monitoring */
			lcl->bs.digout.mode = _AUTO;
		}
		lcl->bs.digout.tristate = _ENABLE;

	/* Case 2/3a: 2MHz Centre Band or DSB generated via 16MHz LSB or USB */
	} else if ((baseband >= 16.875 && baseband < 27.0) ||
		   (baseband > 37.0 && baseband <= 47.125)) {

		/* DSB has more limited tuning range */
		if (lcl->filter_mode == _DSB && 
		    (baseband < 17.875 || baseband > 46.125))
			return(-201);

		/* Use 16MHz Double sideband filter in Band Splitter */
		bs_filter = _B2_16;
		lcl->bs.clock_decimation = 0;

		/* Always flip LSB so both bands upright */
		lcl->bs.flip_usb = _NATURAL;
		lcl->bs.flip_lsb = _FLIPPED;

		/* Feed appropriate sideband through to Fine Tuner */
		if (baseband < 32.0) {
			ft_centre = 24.0;
			lcl->bs.digout.setting = _LSB;
		} else {
			ft_centre = 40.0;
			lcl->bs.digout.setting = _USB;
		}
		/* .. and MON choice to Band Splitter analog monitor */
		lcl->bs.monitor.mode = lcl->bs.digout.mode = _MANUAL;
		lcl->bs.digout.tristate = _ENABLE;

	/* Case 2/3b: 2MHz Centre Band or DSB generated via 16MHz Centre Band */
	} else if (baseband >= 27.0 && baseband <= 37.0) {

		/* Use smooth 16MHz Centre Band filter in Band Splitter */
		bs_filter = _B1_16S;
		lcl->bs.clock_decimation = 0;

		/* Centre Band: already upright */
		lcl->bs.flip_usb = lcl->bs.flip_lsb = _NATURAL;

		ft_centre = 32.0;

		/* Feed the Centre Band through */
		lcl->bs.monitor.mode = lcl->bs.digout.mode = _AUTO;
		lcl->bs.digout.tristate = _ENABLE;

	} else return(-201);	/* Bad frequency/mode combination */

	/* Output is primarily available from Band Splitter */
	lcl->filter_output = _BS;
	ft_filter = _F_NONE;

	/* For Band Splitter only modes we are done, otherwise ... */
	if (lcl->filter_mode == _DSB || lcl->filter_mode == _SCB
	                             || lcl->filter_mode == _ACB) {
		/*
		   Setup Fine Tuner for desired response relative to the
		   selected 16MHz output of the Band Splitter.
		 */
		if (lcl->filter_mode == _DSB)	ft_filter = _F2_Bdiv8;
		if (lcl->filter_mode == _SCB)	ft_filter = _F1_Bdiv8S;
		if (lcl->filter_mode == _ACB)	ft_filter = _F1_Bdiv8;
		lcl->ft.clock_decimation = 3;

		/* Flip individual sidebands to match request */
		lcl->ft.flip_usb = lcl->flip_usb;
		if (lcl->filter_mode == _DSB)
			lcl->ft.flip_lsb = lcl->flip_lsb;
		/* ... Centre Band only needs USB flip to flip entire band */
		else	lcl->ft.flip_lsb = _NATURAL;

		/* Outputs all available on Fine Tuner */
		lcl->filter_output = _FT;
	}
	break;

     case _1D000:
	/*
	   Three possible scenarios:
	    (1) Any of the fixed 1MHz Band Splitter possibilities, centred
		on 32MHz.
	    (2) A 1MHz Centre Band Filter centred anywhere from 24.5MHz through
		39.5MHz generated as either 8MHz flipped LSB, Centre Band or
		USB in the Band Splitter, tunable up to bw/32 beyond.
	    (3) 1MHz Dual Sideband Filters centred anywhere from 25MHz through
		39MHz generated as either 8MHz flipped LSB, Centre Band or
		USB in the Band Splitter, tuneable up to bw/32 beyond.
	 */
	if (lcl->filter_mode == _DS4 || lcl->filter_mode == _DS6)
		return(-203);			/* Only available at 8MHz */

	/* Case 1: Band Splitter only modes, centred at 32MHz */
	if (lcl->filter_mode == _SC1 || lcl->filter_mode == _DS2
	                             || lcl->filter_mode == _AC1) {

		if (baseband != 32.0) return(-201);
	
		if (lcl->filter_mode == _SC1) bs_filter = _B1_1S;
		if (lcl->filter_mode == _DS2) bs_filter = _B2_1;
		if (lcl->filter_mode == _AC1) bs_filter = _B1_1;
		lcl->bs.clock_decimation = 4;
	
		/* Flip individual sidebands to match request */
		lcl->bs.flip_usb = lcl->flip_usb;
		if (lcl->filter_mode != _SC1 && lcl->filter_mode != _AC1)
			lcl->bs.flip_lsb = lcl->flip_lsb;
		/* ... Centre Band only needs USB flip to flip entire band */
		else	lcl->bs.flip_lsb = _NATURAL;

		ft_centre = 32.0;

		if (lcl->filter_mode == _DSB || lcl->filter_mode == _DS2) {
			/* Feed MON choice to Band Splitter analog monitor */
			lcl->bs.monitor.mode = _MANUAL;
			/* .. and FT choice to Fine Tuner for Tsys monitoring */
			lcl->bs.digout.mode = _MANUAL;
		} else {
			/* Feed Centre Band to Band Splitter analog monitor */
			lcl->bs.monitor.mode = _AUTO;
			/* .. and on to Fine Tuner for Tsys monitoring */
			lcl->bs.digout.mode = _AUTO;
		}
		lcl->bs.digout.tristate = _ENABLE;

	/* Case 2/3a: 1MHz Centre Band or DSB generated via 8MHz LSB or USB */
	} else if ((baseband >= 24.4375 && baseband < 29.5) ||
		   (baseband > 34.5 && baseband <= 39.5625)) {

		/* DSB has more limited tuning range */
		if (lcl->filter_mode == _DSB && 
		    (baseband < 24.9375 || baseband > 39.0625))
			return(-201);

		/* Use 8MHz Double sideband filter in Band Splitter */
		bs_filter = _B2_8;
		lcl->bs.clock_decimation = 1;

		/* Always flip LSB so both bands upright */
		lcl->bs.flip_usb = _NATURAL;
		lcl->bs.flip_lsb = _FLIPPED;

		/* Feed appropriate sideband through to Fine Tuner */
		if (baseband < 32.0) {
			ft_centre = 28.0;
			lcl->bs.digout.setting = _LSB;
		} else {
			ft_centre = 36.0;
			lcl->bs.digout.setting = _USB;
		}
		/* .. and MON choice to Band Splitter analog monitor */
		lcl->bs.monitor.mode = lcl->bs.digout.mode = _MANUAL;
		lcl->bs.digout.tristate = _ENABLE;

	/* Case 2/3b: 1MHz Centre Band or DSB generated via 8MHz Centre Band */
	} else if (baseband >= 29.5 && baseband <= 34.5) {

		/* Use smooth 8MHz Centre Band filter in Band Splitter */
		bs_filter = _B1_8S;
		lcl->bs.clock_decimation = 1;

		/* Centre Band: already upright */
		lcl->bs.flip_usb = lcl->bs.flip_lsb = _NATURAL;

		ft_centre = 32.0;

		/* Feed the Centre Band through */
		lcl->bs.monitor.mode = lcl->bs.digout.mode = _AUTO;
		lcl->bs.digout.tristate = _ENABLE;

	} else return(-201);	/* Bad frequency/mode combination */

	/* Output is primarily available from Band Splitter */
	lcl->filter_output = _BS;
	ft_filter = _F_NONE;

	/* For Band Splitter only modes we are done, otherwise ... */
	if (lcl->filter_mode == _DSB || lcl->filter_mode == _SCB
	                             || lcl->filter_mode == _ACB) {
		/*
		   Setup Fine Tuner for desired response relative to the
		   selected 8MHz output of the Band Splitter.
		 */
		if (lcl->filter_mode == _DSB)	ft_filter = _F2_Bdiv8;
		if (lcl->filter_mode == _SCB)	ft_filter = _F1_Bdiv8S;
		if (lcl->filter_mode == _ACB)	ft_filter = _F1_Bdiv8;
		lcl->ft.clock_decimation = 3;

		/* Flip individual sidebands to match request */
		lcl->ft.flip_usb = lcl->flip_usb;
		if (lcl->filter_mode == _DSB)
			lcl->ft.flip_lsb = lcl->flip_lsb;
		/* ... Centre Band only needs USB flip to flip entire band */
		else	lcl->ft.flip_lsb = _NATURAL;

		/* Outputs all available on Fine Tuner */
		lcl->filter_output = _FT;
	}
	break;

     case _0D500:
	/*
	   Two possible scenarios:
	    (1) A 0.5MHz Centre Band Filter centred anywhere from 28.25MHz
		through 35.75MHz generated as either 4MHz flipped LSB, Centre
		Band or USB in the Band Splitter, tunable up to bw/32 beyond.
	    (2) 0.5MHz Dual Sideband Filters centred anywhere from 28.5MHz
		through 35.5MHz generated as either 4MHz flipped LSB, Centre
		Band or USB in the Band Splitter, tuneable up to bw/32 beyond.
	 */
	if (lcl->filter_mode == _SC1 || lcl->filter_mode == _DS2 ||
	    lcl->filter_mode == _DS4 || lcl->filter_mode == _DS6 
	                             || lcl->filter_mode == _AC1)
		return(-203);			/* Only at 1MHz and above */

	/* Case 1/2a: 0.5MHz Centre Band or DSB generated via 4MHz LSB or USB */
	if ((baseband >= 28.21875 && baseband < 30.75) ||
	    (baseband > 33.25 && baseband <= 35.78125)) {

		/* DSB has more limited tuning range */
		if (lcl->filter_mode == _DSB && 
		    (baseband < 28.46875 || baseband > 35.53125))
			return(-201);

		/* Use 4MHz Double sideband filter in Band Splitter */
		bs_filter = _B2_4;
		lcl->bs.clock_decimation = 2;

		/* Always flip LSB so both bands upright */
		lcl->bs.flip_usb = _NATURAL;
		lcl->bs.flip_lsb = _FLIPPED;

		/* Feed appropriate sideband through to Fine Tuner */
		if (baseband < 32.0) {
			ft_centre = 30.0;
			lcl->bs.digout.setting = _LSB;
		} else {
			ft_centre = 34.0;
			lcl->bs.digout.setting = _USB;
		}
		/* .. and MON choice to Band Splitter analog monitor */
		lcl->bs.monitor.mode = lcl->bs.digout.mode = _MANUAL;
		lcl->bs.digout.tristate = _ENABLE;

	/* Case 1/2b: 0.5MHz Centre Band or DSB generated via 4MHz SCB */
	} else if (baseband >= 30.75 && baseband <= 33.25) {

		/* Use smooth 4MHz Centre Band filter in Band Splitter */
		bs_filter = _B1_4S;
		lcl->bs.clock_decimation = 2;

		/* Centre Band: already upright */
		lcl->bs.flip_usb = lcl->bs.flip_lsb = _NATURAL;

		ft_centre = 32.0;

		/* Feed the Centre Band through */
		lcl->bs.monitor.mode = lcl->bs.digout.mode = _AUTO;
		lcl->bs.digout.tristate = _ENABLE;

	} else return(-201);	/* Bad frequency/mode combination */

	/*
	   Setup Fine Tuner for desired response relative to the
	   selected 4MHz output of the Band Splitter.
	 */
	if (lcl->filter_mode == _DSB)	ft_filter = _F2_Bdiv8;
	if (lcl->filter_mode == _SCB)	ft_filter = _F1_Bdiv8S;
	if (lcl->filter_mode == _ACB)	ft_filter = _F1_Bdiv8;
	lcl->ft.clock_decimation = 3;

	/* Flip individual sidebands to match request */
	lcl->ft.flip_usb = lcl->flip_usb;
	if (lcl->filter_mode == _DSB)
		lcl->ft.flip_lsb = lcl->flip_lsb;
	/* ... Centre Band only needs USB flip to flip entire band */
	else	lcl->ft.flip_lsb = _NATURAL;

	/* Outputs always on Fine Tuner */
	lcl->filter_output = _FT;
	break;

     case _0D250:
	/*
	   Two possible scenarios:
	    (1) A 0.25MHz Centre Band Filter centred anywhere from 30.125MHz
		through 33.875MHz generated as either 2MHz flipped LSB, Centre
		Band or USB in the Band Splitter, tunable up to bw/32 beyond.
	    (2) 0.5MHz Dual Sideband Filters centred anywhere from 30.25MHz
		through 33.75MHz generated as either 2MHz flipped LSB, Centre
		Band or USB in the Band Splitter, tuneable up to bw/32 beyond.
	 */
	if (lcl->filter_mode == _SC1 || lcl->filter_mode == _DS2 ||
	    lcl->filter_mode == _DS4 || lcl->filter_mode == _DS6 
	                             || lcl->filter_mode == _AC1)
		return(-203);			/* Only at 1MHz and above */

	/* Case 1/2a: 0.25MHz Centre Band or DSB generated via 2MHz LSB/USB */
	if ((baseband >= 30.109375 && baseband < 31.375) ||
	    (baseband > 32.625 && baseband <= 33.890625)) {

		/* DSB has more limited tuning range */
		if (lcl->filter_mode == _DSB && 
		    (baseband < 30.234375 || baseband > 33.765625))
			return(-201);

		/* Use 2MHz Double sideband filter in Band Splitter */
		bs_filter = _B2_2;
		lcl->bs.clock_decimation = 3;

		/* Always flip LSB so both bands upright */
		lcl->bs.flip_usb = _NATURAL;
		lcl->bs.flip_lsb = _FLIPPED;

		/* Feed appropriate sideband through to Fine Tuner */
		if (baseband < 32.0) {
			ft_centre = 31.0;
			lcl->bs.digout.setting = _LSB;
		} else {
			ft_centre = 33.0;
			lcl->bs.digout.setting = _USB;
		}
		/* .. and MON choice to Band Splitter analog monitor */
		lcl->bs.monitor.mode = lcl->bs.digout.mode = _MANUAL;
		lcl->bs.digout.tristate = _ENABLE;

	/* Case 1/2b: 0.25MHz Centre Band or DSB generated via 2MHz SCB */
	} else if (baseband >= 31.375 && baseband <= 32.625) {

		/* Use smooth 2MHz Centre Band filter in Band Splitter */
		bs_filter = _B1_2S;
		lcl->bs.clock_decimation = 3;

		/* Centre Band: already upright */
		lcl->bs.flip_usb = lcl->bs.flip_lsb = _NATURAL;

		ft_centre = 32.0;

		/* Feed the Centre Band through */
		lcl->bs.monitor.mode = lcl->bs.digout.mode = _AUTO;
		lcl->bs.digout.tristate = _ENABLE;

	} else return(-201);	/* Bad frequency/mode combination */

	/*
	   Setup Fine Tuner for desired response relative to the
	   selected 2MHz output of the Band Splitter.
	 */
	if (lcl->filter_mode == _DSB)	ft_filter = _F2_Bdiv8;
	if (lcl->filter_mode == _SCB)	ft_filter = _F1_Bdiv8S;
	if (lcl->filter_mode == _ACB)	ft_filter = _F1_Bdiv8;
	lcl->ft.clock_decimation = 3;

	/* Flip individual sidebands to match request */
	lcl->ft.flip_usb = lcl->flip_usb;
	if (lcl->filter_mode == _DSB)
		lcl->ft.flip_lsb = lcl->flip_lsb;
	/* ... Centre Band only needs USB flip to flip entire band */
	else	lcl->ft.flip_lsb = _NATURAL;

	/* Outputs always on Fine Tuner */
	lcl->filter_output = _FT;
	break;

     case _0D125:
	/*
	   Two possible scenarios:
	    (1) A 0.125MHz Centre Band Filter centred anywhere from 31.0625MHz
		through 32.9375MHz generated as either 1MHz flipped LSB, Centre
		Band or USB in the Band Splitter, tunable up to bw/32 beyond.
	    (2) 0.125MHz Dual Sideband Filters centred anywhere from 31.125MHz
		through 32.875MHz generated as either 1MHz flipped LSB, Centre
		Band or USB in the Band Splitter, tuneable up to bw/32 beyond.
	 */
	if (lcl->filter_mode == _SC1 || lcl->filter_mode == _DS2 ||
	    lcl->filter_mode == _DS4 || lcl->filter_mode == _DS6 
	                             || lcl->filter_mode == _AC1)
		return(-203);			/* Only at 1MHz and above */

	/* Case 1/2a: 0.125MHz Centre Band or DSB generated via 1MHz LSB/USB */
	if ((baseband >= 31.0546875 && baseband < 31.6875) ||
	    (baseband > 32.3125 && baseband <= 32.9453125)) {

		/* DSB has more limited tuning range */
		if (lcl->filter_mode == _DSB && 
		    (baseband < 31.1171875 || baseband > 32.8828125))
			return(-201);

		/* Use 1MHz Double sideband filter in Band Splitter */
		bs_filter = _B2_1;
		lcl->bs.clock_decimation = 4;

		/* Always flip LSB so both bands upright */
		lcl->bs.flip_usb = _NATURAL;
		lcl->bs.flip_lsb = _FLIPPED;

		/* Feed appropriate sideband through to Fine Tuner */
		if (baseband < 32.0) {
			ft_centre = 31.5;
			lcl->bs.digout.setting = _LSB;
		} else {
			ft_centre = 32.5;
			lcl->bs.digout.setting = _USB;
		}
		/* .. and MON choice to Band Splitter analog monitor */
		lcl->bs.monitor.mode = lcl->bs.digout.mode = _MANUAL;
		lcl->bs.digout.tristate = _ENABLE;

	/* Case 1/2b: 0.125MHz Centre Band or DSB generated via 1MHz SCB */
	} else if (baseband >= 31.6875 && baseband <= 32.3125) {

		/* Use smooth 1MHz Centre Band filter in Band Splitter */
		bs_filter = _B1_1S;
		lcl->bs.clock_decimation = 4;

		/* Centre Band: already upright */
		lcl->bs.flip_usb = lcl->bs.flip_lsb = _NATURAL;

		ft_centre = 32.0;

		/* Feed the Centre Band through */
		lcl->bs.monitor.mode = lcl->bs.digout.mode = _AUTO;
		lcl->bs.digout.tristate = _ENABLE;

	} else return(-201);	/* Bad frequency/mode combination */

	/*
	   Setup Fine Tuner for desired response relative to the
	   selected 1MHz output of the Band Splitter.
	 */
	if (lcl->filter_mode == _DSB)	ft_filter = _F2_Bdiv8;
	if (lcl->filter_mode == _SCB)	ft_filter = _F1_Bdiv8S;
	if (lcl->filter_mode == _ACB)	ft_filter = _F1_Bdiv8;
	lcl->ft.clock_decimation = 3;

	/* Flip individual sidebands to match request */
	lcl->ft.flip_usb = lcl->flip_usb;
	if (lcl->filter_mode == _DSB)
		lcl->ft.flip_lsb = lcl->flip_lsb;
	/* ... Centre Band only needs USB flip to flip entire band */
	else	lcl->ft.flip_lsb = _NATURAL;

	/* Outputs always on Fine Tuner */
	lcl->filter_output = _FT;
	break;

     case _0D0625:
	/*
	   Two possible scenarios:
	    (1) A 0.0625MHz Centre Band Filter centred anywhere from 31.03125MHz
		through 32.96875MHz generated as either 1MHz flipped LSB, Centre
		Band or USB in the Band Splitter, tunable up to bw/32 beyond.
	    (2) 0.0625MHz Dual Sideband Filters centred anywhere from 31.0625MHz
		through 32.9375MHz generated as either 1MHz flipped LSB, Centre
		Band or USB in the Band Splitter, tuneable up to bw/32 beyond.
	 */
	if (lcl->filter_mode == _SC1 || lcl->filter_mode == _DS2 ||
	    lcl->filter_mode == _DS4 || lcl->filter_mode == _DS6 
	                             || lcl->filter_mode == _AC1)
		return(-203);			/* Only at 1MHz and above */

	/* Case 1/2a: 0.0625MHz Centre Band or DSB generated via 1MHz LSB/USB */
	if ((baseband >= 31.02734375 && baseband < 31.59375) ||
	    (baseband > 32.40625 && baseband <= 32.97265625)) {

		/* DSB has more limited tuning range */
		if (lcl->filter_mode == _DSB && 
		    (baseband < 31.05859375 || baseband > 32.94140625))
			return(-201);

		/* Use 1MHz Double sideband filter in Band Splitter */
		bs_filter = _B2_1;
		lcl->bs.clock_decimation = 4;

		/* Always flip LSB so both bands upright */
		lcl->bs.flip_usb = _NATURAL;
		lcl->bs.flip_lsb = _FLIPPED;

		/* Feed appropriate sideband through to Fine Tuner */
		if (baseband < 32.0) {
			ft_centre = 31.5;
			lcl->bs.digout.setting = _LSB;
		} else {
			ft_centre = 32.5;
			lcl->bs.digout.setting = _USB;
		}
		/* .. and MON choice to Band Splitter analog monitor */
		lcl->bs.monitor.mode = lcl->bs.digout.mode = _MANUAL;
		lcl->bs.digout.tristate = _ENABLE;

	/* Case 1/2b: 0.0625MHz Centre Band or DSB generated via 1MHz SCB */
	} else if (baseband >= 31.59375 && baseband <= 32.40625) {

		/* Use smooth 1MHz Centre Band filter in Band Splitter */
		bs_filter = _B1_1S;
		lcl->bs.clock_decimation = 4;

		/* Centre Band: already upright */
		lcl->bs.flip_usb = lcl->bs.flip_lsb = _NATURAL;

		ft_centre = 32.0;

		/* Feed the Centre Band through */
		lcl->bs.monitor.mode = lcl->bs.digout.mode = _AUTO;
		lcl->bs.digout.tristate = _ENABLE;

	} else return(-201);	/* Bad frequency/mode combination */

	/*
	   Setup Fine Tuner for desired response relative to the
	   selected 1MHz output of the Band Splitter.
	 */
	if (lcl->filter_mode == _DSB)	ft_filter = _F2_Bdiv16;
	if (lcl->filter_mode == _SCB)	ft_filter = _F1_Bdiv16S;
	if (lcl->filter_mode == _ACB)	ft_filter = _F1_Bdiv16;
	lcl->ft.clock_decimation = 4;

	/* Flip individual sidebands to match request */
	lcl->ft.flip_usb = lcl->flip_usb;
	if (lcl->filter_mode == _DSB)
		lcl->ft.flip_lsb = lcl->flip_lsb;
	/* ... Centre Band only needs USB flip to flip entire band */
	else	lcl->ft.flip_lsb = _NATURAL;

	/* Outputs always on Fine Tuner */
	lcl->filter_output = _FT;
	break;
   }

   /* Select Band Splitter Inner or Outer sub-band based on filter type */
   if (bs_filter < _B6_8) {
	lcl->bs.p_hilbert_no = lcl->bs.n_hilbert_no = 31;
	lcl->bs.sub_band = _INNER;
   } else {
	lcl->bs.p_hilbert_no = lcl->bs.n_hilbert_no = 32;
	lcl->bs.sub_band = _OUTER;
   }

   /* Fill in details of the Band Splitter Q & I filter nos */
   switch (bs_filter) {
     case _B1_32:
     case _B1_16:
     case _B1_8:
     case _B1_4:
     case _B1_2:
     case _B1_1:
	lcl->bs.q_fir_no = lcl->bs.i_fir_no = bs_filter - _B1_32 + 1;
	break;
     case _B1_16S:
     case _B1_8S:
     case _B1_4S:
     case _B1_2S:
     case _B1_1S:
	lcl->bs.q_fir_no = lcl->bs.i_fir_no = bs_filter - _B1_16S + 7;
	break;
     case _B2_16:
     case _B2_8:
     case _B2_4:
     case _B2_2:
     case _B2_1:
	lcl->bs.q_fir_no = bs_filter - _B2_16 + 12;
	lcl->bs.i_fir_no = bs_filter - _B2_16 + 22;
	break;
     case _B4_8:
     case _B6_8:
	lcl->bs.q_fir_no = 17;
	lcl->bs.i_fir_no = 27;
	break;
     case _B_NONE:
       break;
   }

   /* Set the Band Splitter Q / I adder/subtractor to AUTO mode */
   lcl->bs.add_sub.setting = _ON;
   lcl->bs.add_sub.mode = _AUTO;

   /* Set the Band Splitter USB / LSB multiplexor to AUTO mode */
   lcl->bs.usb_mux.setting = _USB;
   lcl->bs.usb_mux.mode = _AUTO;
   lcl->bs.lsb_mux.setting = _LSB;
   lcl->bs.lsb_mux.mode = _AUTO;

   /* Set the Band Splitter USB / LSB 2-bit servos to AUTO */
   lcl->bs.usb_servo.setting = lcl->bs.usb_servo.readout;
   lcl->bs.usb_servo.mode = _AUTO;
   lcl->bs.lsb_servo.setting = lcl->bs.lsb_servo.readout;
   lcl->bs.lsb_servo.mode = _AUTO;

   /* Setup Fine Tuner for cascade modes */
   if (ft_filter != _F_NONE) {

	if (ft_filter != _F0_Bdiv1)
		lcl->ft_lo = 8.0 + pow(2,lcl->bs.clock_decimation)*(baseband-ft_centre);
	else	lcl->ft_lo = 0.0;

	if (ft_filter <= _F0_Bdiv1) {
		lcl->ft.clock_decimation = 0;
		lcl->ft_filter_mode = _NONE;
	} else if (ft_filter <= _F1_Bdiv16) {
		lcl->ft.clock_decimation = ft_filter - _F1_Bdiv1;
		lcl->ft_filter_mode = _ACB;
	} else if (ft_filter <= _F1_Bdiv16S) {
		lcl->ft.clock_decimation = ft_filter - _F1_Bdiv1S;
		lcl->ft_filter_mode = _SCB;
	} else if (ft_filter <= _F2_Bdiv16) {
		lcl->ft.clock_decimation = ft_filter - _F2_Bdiv2 + 1;
		lcl->ft_filter_mode = _DSB;
	}

	/* No need to use NCO Frequency Offset */
	lcl->ft.nco_offset_value = 0.0;

	/* No need to use NCO Phase Offset */
	lcl->ft.nco_phase_value = 0.0;

	/* And generate a proper sine/cosine wave ! */
	lcl->ft.nco_test = _OFF;

   /* Otherwise use FTnn SNAP command values for Band Splitter only modes */
   } else {

	if (lcl->ft_filter_mode == _NONE) {
		ft_filter = _F0_Bdiv1;
	} else {
		if (lcl->ft_filter_mode == _DSB)
			ft_filter = _F2_Bdiv2 + lcl->ft.clock_decimation - 1;
		else if (lcl->ft_filter_mode == _SCB)
			ft_filter = _F1_Bdiv1S + lcl->ft.clock_decimation;
		else if (lcl->ft_filter_mode == _ACB)
			ft_filter = _F1_Bdiv1 + lcl->ft.clock_decimation;
		else	ft_filter = _F_NONE;
	}

	/* Test mode includes disabling Band Splitter output to Fine Tuner */
	if (lcl->ft.nco_test) lcl->bs.digout.tristate = _TRISTATE;
   }

   /* Feed correct band type through for Tsys/Analog monitoring */
   if (lcl->ft_filter_mode == _DSB)
	lcl->ft.monitor.mode = lcl->ft.digout.mode = _MANUAL;
   else	lcl->ft.monitor.mode = lcl->ft.digout.mode = _AUTO;
   lcl->ft.digout.tristate = _ENABLE;

   /* Set the Fine Tuner to synchronise to Band Splitter 1PPS */
   lcl->ft.sync = _SYNC;

   /* Set the Fine Tuner NCO Local Oscillator Frequency
      (currently the timer mechanism implicitly adds 1 to value) */
   lcl->ft.nco_centre_value = (unsigned int)
	floor(lcl->ft_lo * pow(2,32) / 32.0);

   /* Set the Fine Tuner NCO Local Oscillator Offset Frequency */
   lcl->ft.nco_offset_value = (unsigned int)
	floor(0.5 + lcl->ft_offs * pow(2,32) / 32.0);

   /* No need to use NCO Frequency Offset unless set */
   if (lcl->ft.nco_offset_value != 0)
	lcl->ft.nco_use_offset = _ON;
   else	lcl->ft.nco_use_offset = _OFF;

   /* Set the Fine Tuner NCO Local Oscillator Phase */
   lcl->ft.nco_phase_value = (unsigned int)
	floor(0.5 + lcl->ft_phase * pow(2,32) / 360.0);

   /* Need to resynchronise phase every 1PPS for VLBI !! */
   lcl->ft.nco_sync_reset = _ON;

   /* Calculate Frequency decrement time in seconds:
      - starts just above frequency and drops by 1 step
        to just below after c_err seconds (0 < c_err < 1) */
   c_err = (lcl->ft_lo * pow(2,32) / 32.0)
		- lcl->ft.nco_centre_value;

   /* Set Decrement Timer to corresponding frequency */
   if (c_err < pow(2,lcl->bs.clock_decimation)/32.0e6)  {
	lcl->ft.nco_timer_value = 0;
	lcl->ft.nco_use_timer = _OFF;
	/* Compensate for incorrect addition of 1 by timer mechanism */
	lcl->ft.nco_centre_value--;
   } else {
	lcl->ft.nco_timer_value = (unsigned int)
		floor(0.5 + (pow(2,32) * pow(2,lcl->bs.clock_decimation)
				/ 32.0e6 / c_err));
	lcl->ft.nco_use_timer = _ON;
   }

   /* Fill in details of the Fine Tuner filter nos */
   switch (ft_filter) {
     case _F0_Bdiv1:
	lcl->ft.q_fir_no = lcl->ft.i_fir_no = 21;
	break;
     case _F1_Bdiv1:
     case _F1_Bdiv2:
     case _F1_Bdiv4:
     case _F1_Bdiv8:
     case _F1_Bdiv16:
	lcl->ft.q_fir_no = lcl->ft.i_fir_no = ft_filter - _F1_Bdiv1 + 2;
	break;
     case _F1_Bdiv1S:
     case _F1_Bdiv2S:
     case _F1_Bdiv4S:
     case _F1_Bdiv8S:
     case _F1_Bdiv16S:
	lcl->ft.q_fir_no = lcl->ft.i_fir_no = ft_filter - _F1_Bdiv1S + 7;
	break;
     case _F2_Bdiv2:
     case _F2_Bdiv4:
     case _F2_Bdiv8:
     case _F2_Bdiv16:
	lcl->ft.q_fir_no = ft_filter - _F2_Bdiv2 + 13;
	lcl->ft.i_fir_no = ft_filter - _F2_Bdiv2 + 23;
	break;
     case _F_NONE:
       break;
   }

   /* Set the Fine Tuner Q / I adder/subtractor according to NCO test mode */
   if (lcl->ft.nco_test == _ON) {
	lcl->ft.add_sub.setting = _OFF;
	lcl->ft.add_sub.mode = _MANUAL;
   } else {
	lcl->ft.add_sub.setting = _ON;
	lcl->ft.add_sub.mode = _AUTO;
   }

   /* Set the Fine Tuner USB / LSB multiplexor to AUTO mode */
   lcl->ft.usb_mux.setting = _USB;
   lcl->ft.usb_mux.mode = _AUTO;
   lcl->ft.lsb_mux.setting = _LSB;
   lcl->ft.lsb_mux.mode = _AUTO;

   /* Set the Fine Tuner USB / LSB 2-bit servos to AUTO */
   lcl->ft.usb_servo.setting = lcl->ft.usb_servo.readout;
   lcl->ft.usb_servo.mode = _AUTO;
   lcl->ft.lsb_servo.setting = lcl->ft.lsb_servo.readout;
   lcl->ft.lsb_servo.mode = _AUTO;

   /* Set S2 recorder output format as requested */
   lcl->out.s2_lo.format = lcl->out.s2_hi.format = lcl->format;

   /* Implement TRACKFORM SNAP command ( as far as currently possible ) */
   exchange_s2_sideband = (lcl->track[0] != -1 && lcl->track[0]%4 == 2) ||
				(lcl->track[1] != -1 && lcl->track[1]%4 == 0);
   if (lcl->filter_output == _BS) {
	if (!exchange_s2_sideband) {
		lcl->out.s2_lo.source = _BS_LSB;
		lcl->out.s2_hi.source = _BS_USB;
	} else {
		lcl->out.s2_lo.source = _BS_USB;
		lcl->out.s2_hi.source = _BS_LSB;
	}
	if (lcl->bandwidth == _32D00) 
		lcl->out.s2_lo.source = lcl->out.s2_hi.source = _BS_32;
	if (lcl->bandwidth == _64D00)
		lcl->out.s2_lo.source = lcl->out.s2_hi.source = _AS_64;
   } else {
	if (!exchange_s2_sideband) {
		lcl->out.s2_lo.source = _FT_LSB;
		lcl->out.s2_hi.source = _FT_USB;
	} else {
		lcl->out.s2_lo.source = _FT_USB;
		lcl->out.s2_hi.source = _FT_LSB;
	}
   }
   /* Generate comments to operator w.r.t. S2 recorder cabling */
   if (exchange_s2_sideband && lcl->bandwidth > _16D00)
	printf("\7**WARNING: requested trackform not yet possible !\n");
   if (chan == 0 ) {
	if (lcl->track[0] > 3 || lcl->track[1] > 3)
		printf("\7**WARNING: requested trackform not yet possible !\n");
	else if (lcl->track[0] == 0 || lcl->track[1] == 0)
		printf("**NB: Connect S2 recorder to DAS %1d !!\n",n_das+1);
	if (lcl->track[0] > 1 || lcl->track[1] > 1)
		printf("**NB: Ensure buggary cable is _NOT_ inserted !!\n");
   } else {
	if ((lcl->track[0] != -1 && lcl->track[0] < 4 && lcl->track[1] != -1) ||
	    (lcl->track[1] != -1 && lcl->track[1] < 4 && lcl->track[0] != -1))
		printf("\7**WARNING: requested trackform not yet possible !\n");
	else if ((lcl->track[0] != -1 && lcl->track[0] < 4) ||
			 (lcl->track[1] != -1 && lcl->track[1] < 4))
		printf("**NB: Ensure buggary cable is _INSERTED_ !!\n");
	else if ((lcl->track[0] != -1 && lcl->track[0] > 3) ||
			 (lcl->track[1] != -1 && lcl->track[1] > 3))
		printf("**NB: Ensure buggary cable is _NOT_ inserted !!\n");
   }

   /* Implement CORnn SNAP command */
   if (lcl->corr_source[0] <= _C64)
	lcl->out.atmb_corr_source = lcl->corr_source[0];
   else if (lcl->bandwidth == _64D00)
	lcl->out.atmb_corr_source = _AS_64;
   else if (lcl->bandwidth == _32D00)
	lcl->out.atmb_corr_source = _BS_32;
   else if (lcl->filter_output == _BS)
	lcl->out.atmb_corr_source = _BS_USB + lcl->corr_source[0] - _A_U;
   else lcl->out.atmb_corr_source = _FT_USB + lcl->corr_source[0] - _A_U;
   if (lcl->corr_source[1] <= _C64)
	lcl->out.mb_corr_2_source = lcl->corr_source[1];
   else if (lcl->bandwidth == _64D00)
	lcl->out.mb_corr_2_source = _AS_64;
   else if (lcl->bandwidth == _32D00)
	lcl->out.mb_corr_2_source = _BS_32;
   else if (lcl->filter_output == _BS)
	lcl->out.mb_corr_2_source = _BS_USB + lcl->corr_source[1] - _A_U;
   else lcl->out.mb_corr_2_source = _FT_USB + lcl->corr_source[1] - _A_U;

   return(0);
}

int reset_err_flags(int n_ifp)
{
  unsigned char chan, n_das;
  struct ds_cmd lcl;
  struct ds_mon lclm;
  int ip[5];
  int i, ierr;

  n_das = n_ifp / 2;
  chan = n_ifp % 2;

  /* Queue 1 PPS / 5 MHz error reset commands */
  for (i=0; i<5; i++) ip[i]=0;
  lcl.type = DS_CMD;
  strcpy(lcl.mnem,shm_addr->das[n_das].ds_mnem);
  lcl.cmd = 224 + chan;
  lcl.data = 0xFFFF;
  dscon_snd(&lcl, ip);

  /* Transmit to DAS via DSCON dataset driver */
  run_dscon(ip);

  /* Check response for transmission failures */
  if ((ierr=dscon_rcv(&lclm,ip))) {
		if (shm_addr->das[n_das].ifp[0].initialised)
			shm_addr->das[n_das].ifp[0].initialised = -1;
		if (shm_addr->das[n_das].ifp[1].initialised)
			shm_addr->das[n_das].ifp[1].initialised = -1;
		cls_clr(ip[0]);
		return(ierr);
  }
  return(0);
}

int wait_for_sync(int n_ifp)
{
  unsigned char chan, n_das;
  struct ds_cmd lcl;
  struct ds_mon lclm;
  int ip[5];
  int i, ierr, timer, sync = 0;

  n_das = n_ifp / 2;
  chan = n_ifp % 2;

  for (timer=0; timer<110; timer++) {
	/* Queue Band Splitter Flags monitor request */
	for (i=0; i<5; i++) ip[i]=0;
	lcl.type = DS_MON;
	strcpy(lcl.mnem,shm_addr->das[n_das].ds_mnem);
	lcl.cmd = 160 + (chan * 32) + 30;
	dscon_snd(&lcl, ip);

	/* Transmit to DAS via DSCON dataset driver */
	run_dscon(ip);

	/* Collect response */
	if ((ierr=dscon_rcv(&lclm,ip))) {
		if (shm_addr->das[n_das].ifp[0].initialised)
			shm_addr->das[n_das].ifp[0].initialised = -1;
		if (shm_addr->das[n_das].ifp[1].initialised)
			shm_addr->das[n_das].ifp[1].initialised = -1;
		cls_clr(ip[0]);
		return(ierr);
	}
	
	if ((lclm.data.value & 0x02) == 0x02) {
		if (timer > 0 && !sync) {
			return(0);
		}
		sync = 1;
	} else {
		if (timer > 0 && sync) {
			return(0);
		}
		sync = 0;
	}

	rte_sleep((unsigned) 1);
  }
  return(-1);
}

int lba_ifp_write(int n_ifp)
{
  unsigned short ifp_16bit[32];
  unsigned char ft_filter_changed, bs_filter_changed;
  unsigned char chan, n_das;

  struct ds_cmd lcl;
  struct ds_mon lclm;
  int ip[5];
  int i, ierr;

  n_das = n_ifp / 2;
  chan = n_ifp % 2;

  /* Calculate the 16 bit register settings */

  /* Fine Tuner: NCO Centre Frequency [32bits] */
  ifp_16bit[0] = (int)
   ((shm_addr->das[n_das].ifp[chan].ft.nco_centre_value) & 0x0000FFFF);
  ifp_16bit[1] = (int)
   ((shm_addr->das[n_das].ifp[chan].ft.nco_centre_value) & 0xFFFF0000) >> 16;

  /* Fine Tuner: NCO Frequency Offset [32bits] */
  ifp_16bit[2] = (int)
   ((shm_addr->das[n_das].ifp[chan].ft.nco_offset_value) & 0x0000FFFF);
  ifp_16bit[3] = (int)
   ((shm_addr->das[n_das].ifp[chan].ft.nco_offset_value) & 0xFFFF0000) >> 16;

  /* Fine Tuner: NCO Frequency Shift Timer [32bits] */
  ifp_16bit[4] = (int)
   ((shm_addr->das[n_das].ifp[chan].ft.nco_timer_value) & 0x0000FFFF);
  ifp_16bit[5] = (int)
   ((shm_addr->das[n_das].ifp[chan].ft.nco_timer_value) & 0xFFFF0000) >> 16;

  /* Fine Tuner: NCO Phase Offset [32bits >> 16bits] */
  ifp_16bit[6] = (int)
   ((shm_addr->das[n_das].ifp[chan].ft.nco_phase_value) & 0xFFFF0000) >> 16;
  ifp_16bit[7] = 0;		/* reserved */

  /* Fine Tuner: USB and LSB threshold servo set points [16bits] */
  ifp_16bit[8] = (int)
   ((shm_addr->das[n_das].ifp[chan].ft.usb_servo.setting) & 0xFFFF);
  ifp_16bit[9] = (int)
   ((shm_addr->das[n_das].ifp[chan].ft.lsb_servo.setting) & 0xFFFF);

  /* Fine Tuner: NCO control bits */
  ifp_16bit[10] = 0;
  ifp_16bit[11] =
     ((0x0                                               <<  0) & 0x0001)
   | ((0x0                                               <<  1) & 0x0002)
   | ((shm_addr->das[n_das].ifp[chan].ft.nco_sync_reset  <<  2) & 0x0004)
   | ((shm_addr->das[n_das].ifp[chan].ft.nco_test        <<  3) & 0x0008)
   | ((shm_addr->das[n_das].ifp[chan].ft.nco_use_timer   <<  4) & 0x0010)
   | ((shm_addr->das[n_das].ifp[chan].ft.nco_use_offset  <<  5) & 0x0020);

  /* Fine Tuner: I and Q FIR filter numbers */
  ifp_16bit[12] = 
      ((shm_addr->das[n_das].ifp[chan].ft.i_fir_no - 1) & 0x003F)
   | (((shm_addr->das[n_das].ifp[chan].ft.q_fir_no - 1) & 0x003F) << 8);
  ifp_16bit[13] = 0;

  /* Fine Tuner: General control bits */
  ifp_16bit[14] =
     ((0x0                                               <<  0) & 0x0001)
   | ((0x0                                               <<  1) & 0x0002)
   | ((shm_addr->das[n_das].ifp[chan].ft.flip_usb        <<  2) & 0x0004)
   | ((shm_addr->das[n_das].ifp[chan].ft.flip_lsb        <<  3) & 0x0008)
   | ((0x0                                               <<  4) & 0x0010)
   | ((0x0                                               <<  5) & 0x0020)
   | ((0x0                                               <<  6) & 0x0040)
   | ((shm_addr->das[n_das].ifp[chan].magn_stats         <<  7) & 0x0080);
  ifp_16bit[15] =
     ((shm_addr->das[n_das].ifp[chan].ft.monitor.mode    <<  0) & 0x0001)
   | ((shm_addr->das[n_das].ifp[chan].ft.monitor.setting <<  1) & 0x0002)
   | ((shm_addr->das[n_das].ifp[chan].ft.digout.mode     <<  2) & 0x0004)
   | ((shm_addr->das[n_das].ifp[chan].ft.digout.setting  <<  3) & 0x0008)
   | ((shm_addr->das[n_das].ifp[chan].ft.usb_mux.mode    <<  4) & 0x0010)
   | ((shm_addr->das[n_das].ifp[chan].ft.usb_mux.setting <<  5) & 0x0020)
   | ((shm_addr->das[n_das].ifp[chan].ft.lsb_mux.mode    <<  6) & 0x0040)
   | ((shm_addr->das[n_das].ifp[chan].ft.lsb_mux.setting <<  7) & 0x0080)
   | ((shm_addr->das[n_das].ifp[chan].ft.add_sub.mode    <<  8) & 0x0100)
   | ((shm_addr->das[n_das].ifp[chan].ft.add_sub.setting <<  9) & 0x0200)
   | ((shm_addr->das[n_das].ifp[chan].ft.digout.tristate << 10) & 0x0400)
   | ((shm_addr->das[n_das].ifp[chan].ft.usb_servo.mode  << 11) & 0x0800);
	
  /* Detect Fine Tuner filter re-configurations */
  ft_filter_changed = (shm_addr->das[n_das].ifp[chan].initialised != 1)
  	|| (ifp_16bit[0]  != ifp_16bit_cache[n_das][chan][0])
  	|| (ifp_16bit[1]  != ifp_16bit_cache[n_das][chan][1])
  	|| (ifp_16bit[2]  != ifp_16bit_cache[n_das][chan][2])
  	|| (ifp_16bit[3]  != ifp_16bit_cache[n_das][chan][3])
  	|| (ifp_16bit[4]  != ifp_16bit_cache[n_das][chan][4])
  	|| (ifp_16bit[5]  != ifp_16bit_cache[n_das][chan][5])
  	|| (ifp_16bit[6]  != ifp_16bit_cache[n_das][chan][6])
  	|| (ifp_16bit[12] != ifp_16bit_cache[n_das][chan][12]);

  /* Band Splitter: Hilbert, I and Q FIR filter numbers */
  ifp_16bit[16] = 
      ((shm_addr->das[n_das].ifp[chan].bs.n_hilbert_no - 1) & 0x003F)
   | (((shm_addr->das[n_das].ifp[chan].bs.p_hilbert_no - 1) & 0x003F) << 8);
  ifp_16bit[17] = 
      ((shm_addr->das[n_das].ifp[chan].bs.i_fir_no - 1) & 0x003F)
   | (((shm_addr->das[n_das].ifp[chan].bs.q_fir_no - 1) & 0x003F) << 8);

  /* Band Splitter: AT/MB Correlator Port */
  if (shm_addr->das[n_das].ifp[chan].corr_type == _4_LVL) {
  	/* AT correlator single output */
  	ifp_16bit[18] =
  	 (shm_addr->das[n_das].ifp[chan].out.atmb_corr_source & 0x07)
        | ((shm_addr->das[n_das].ifp[chan].at_clock_delay  	& 0x03) << 3);
  } else if (shm_addr->das[n_das].ifp[chan].out.atmb_corr_source == _AS_64) {
  	/* MB correlator 64 MHz output */
  	ifp_16bit[18] = 0x0080 | 0x0040;
  } else if (shm_addr->das[n_das].ifp[chan].out.atmb_corr_source == _BS_32) {
  	/* MB correlator 32 MHz output */
  	ifp_16bit[18] = 0x0080 | 0x0020;
  } else {
  	/* MB correlator dual output */
  	ifp_16bit[18] = 0x0080
      |  (shm_addr->das[n_das].ifp[chan].out.atmb_corr_source & 0x03)
      | ((shm_addr->das[n_das].ifp[chan].out.mb_corr_2_source & 0x03) << 2);
  }

  /* Band Splitter: S2 Recorder Port */
  if (shm_addr->das[n_das].ifp[chan].out.s2_lo.source == _AS_64) {
  	/* 64 MHz sign only output */
  	ifp_16bit[19] = 
  	   ((0x00                                            << 0) & 0x03)
  	 | ((0x00                                            << 2) & 0x0C)
  	 | ((0x0                                             << 4) & 0x10)
  	 | ((0x0                                             << 5) & 0x20)
  	 | ((0x1                                             << 6) & 0x40)
  	 | ((0x0                                             << 7) & 0x80);
  } else if (shm_addr->das[n_das].ifp[chan].out.s2_lo.source == _BS_32) {
  	/* 32 MHz 2-bit single output */
  	ifp_16bit[19] = 
  	   ((0x00                                            << 0) & 0x03)
  	 | ((0x01                                            << 2) & 0x0C)
  	 | ((shm_addr->das[n_das].ifp[chan].out.s2_lo.format << 4) & 0x10)
  	 | ((shm_addr->das[n_das].ifp[chan].out.s2_lo.format << 5) & 0x20)
  	 | ((0x0                                             << 6) & 0x40)
  	 | ((0x0                                             << 7) & 0x80);
  } else {
  	/* Dual 2-bit outputs */
  	ifp_16bit[19] = 
  	   ((shm_addr->das[n_das].ifp[chan].out.s2_lo.source << 0) & 0x03)
  	 | ((shm_addr->das[n_das].ifp[chan].out.s2_hi.source << 2) & 0x0C)
  	 | ((shm_addr->das[n_das].ifp[chan].out.s2_lo.format << 4) & 0x10)
  	 | ((shm_addr->das[n_das].ifp[chan].out.s2_hi.format << 5) & 0x20)
  	 | ((0x0                                             << 6) & 0x40)
  	 | ((0x0                                             << 7) & 0x80);
  }

  /* Band Splitter: 64MHz output flipper */
  ifp_16bit[20] = 
  	  (shm_addr->das[n_das].ifp[chan].bs.flip_64MHz_out & 0x01);
  
  ifp_16bit[21] = 0;
  ifp_16bit[22] = 0;
  ifp_16bit[23] = 0;

  /* Band Splitter: USB and LSB threshold servo set points [16bits] */
  ifp_16bit[24] = (int)
   ((shm_addr->das[n_das].ifp[chan].bs.usb_servo.setting) & 0xFFFF);
  ifp_16bit[25] = (int)
   ((shm_addr->das[n_das].ifp[chan].bs.lsb_servo.setting) & 0xFFFF);

  ifp_16bit[26] = 0;
  ifp_16bit[27] = 0;

  /* Band Splitter: Input Offset and Level servo set points [16bits] */
  ifp_16bit[28] = (int)
   ((shm_addr->das[n_das].ifp[chan].bs.offset.setting) & 0xFFFF);
  ifp_16bit[29] = (int)
   ((shm_addr->das[n_das].ifp[chan].bs.level.setting) & 0xFFFF);

  /* Band Splitter: General control bits */
  ifp_16bit[30] =
     ((0x0                                               <<  0) & 0x0001)
   | ((0x0                                               <<  1) & 0x0002)
   | ((shm_addr->das[n_das].ifp[chan].bs.flip_usb        <<  2) & 0x0004)
   | ((shm_addr->das[n_das].ifp[chan].bs.flip_lsb        <<  3) & 0x0008)
   | ((shm_addr->das[n_das].ifp[chan].ft.sync            <<  4) & 0x0010)
   | ((shm_addr->das[n_das].ifp[chan].bs.offset.mode     <<  5) & 0x0020)
   | ((shm_addr->das[n_das].ifp[chan].bs.level.mode      <<  6) & 0x0040)
   | ((shm_addr->das[n_das].ifp[chan].magn_stats         <<  7) & 0x0080);
  ifp_16bit[31] =
     ((shm_addr->das[n_das].ifp[chan].bs.monitor.mode    <<  0) & 0x0001)
   | ((shm_addr->das[n_das].ifp[chan].bs.monitor.setting <<  1) & 0x0002)
   | ((shm_addr->das[n_das].ifp[chan].bs.digout.mode     <<  2) & 0x0004)
   | ((shm_addr->das[n_das].ifp[chan].bs.digout.setting  <<  3) & 0x0008)
   | ((shm_addr->das[n_das].ifp[chan].bs.usb_mux.mode    <<  4) & 0x0010)
   | ((shm_addr->das[n_das].ifp[chan].bs.usb_mux.setting <<  5) & 0x0020)
   | ((shm_addr->das[n_das].ifp[chan].bs.lsb_mux.mode    <<  6) & 0x0040)
   | ((shm_addr->das[n_das].ifp[chan].bs.lsb_mux.setting <<  7) & 0x0080)
   | ((shm_addr->das[n_das].ifp[chan].bs.add_sub.mode    <<  8) & 0x0100)
   | ((shm_addr->das[n_das].ifp[chan].bs.add_sub.setting <<  9) & 0x0200)
   | ((shm_addr->das[n_das].ifp[chan].bs.digout.tristate << 10) & 0x0400)
   | ((shm_addr->das[n_das].ifp[chan].bs.usb_servo.mode  << 11) & 0x0800)
   | ((shm_addr->das[n_das].ifp[chan].bs.digital_format  << 12) & 0x1000)
   | ((shm_addr->das[n_das].ifp[chan].magn_stats         << 13) & 0x2000)
   | ((shm_addr->das[n_das].ifp[chan].bs.flip_input      << 14) & 0x4000)
   | ((shm_addr->das[n_das].ifp[chan].bs.sub_band        << 15) & 0x8000);

  /* Detect Band Splitter filter re-configurations */
  bs_filter_changed = (shm_addr->das[n_das].ifp[chan].initialised != 1)
  	|| (ifp_16bit[16] != ifp_16bit_cache[n_das][chan][16])
  	|| (ifp_16bit[17] != ifp_16bit_cache[n_das][chan][17]);

  if ((shm_addr->das[n_das].ifp[chan].initialised != 1) && (ierr=reset_err_flags(n_ifp)))
	return(ierr);

  /* All commands are directed to common DAS dataset address */
  lcl.type = DS_CMD;
  strcpy(lcl.mnem,shm_addr->das[n_das].ds_mnem);

  /* Queue Band Splitter setup dataset commands */
  for (i=0; i<5; i++) ip[i]=0;
	/* Send analogue image reject filter setting */
  lcl.cmd = 64 + chan;
  lcl.data = (!shm_addr->das[n_das].ifp[chan].bs.image_reject_filter) & 0x01;
  dscon_snd(&lcl, ip);

  /* Send 16 bit setup data */
  for (i=16; i<32; i++) {
	lcl.cmd = 160 + (chan * 32) + i;
	lcl.data = ifp_16bit[i];
	if (bs_filter_changed
	    || (ifp_16bit_cache[n_das][chan][i] != ifp_16bit[i]))
		dscon_snd(&lcl, ip);
	ifp_16bit_cache[n_das][chan][i] = ifp_16bit[i];
  }

  /* Transmit to DAS via DSCON dataset driver */
  run_dscon(ip);

  /* Scan responses for transmission failures */
  for (i=0; i<ip[1]; i++) {
	if ((ierr=dscon_rcv(&lclm,ip))) {
		if (shm_addr->das[n_das].ifp[0].initialised)
			shm_addr->das[n_das].ifp[0].initialised = -1;
		if (shm_addr->das[n_das].ifp[1].initialised)
			shm_addr->das[n_das].ifp[1].initialised = -1;
		cls_clr(ip[0]);
		return(ierr);
	}
  }

  /* For BS major re-configurations wait for 1 PPS sync twice after ... */
  if (bs_filter_changed && (ierr=wait_for_sync(n_ifp))
                        && (ierr=wait_for_sync(n_ifp)))
	return(ierr);

  /* Queue Fine Tuner setup dataset commands */
  for (i=0; i<5; i++) ip[i]=0;
  /* Send 16 bit setup data */
  for (i=0; i<7; i++) {
	lcl.cmd = 160 + (chan * 32) + i;
	lcl.data = ifp_16bit[i];
	if (bs_filter_changed || ft_filter_changed
	    || (ifp_16bit_cache[n_das][chan][i] != ifp_16bit[i]))
		dscon_snd(&lcl, ip);
	ifp_16bit_cache[n_das][chan][i] = ifp_16bit[i];
  }
  /* ... skipping reserved address '8' */
  for (i=8; i<16; i++) {
	lcl.cmd = 160 + (chan * 32) + i;
	lcl.data = ifp_16bit[i];
	if (bs_filter_changed || ft_filter_changed
	    || (ifp_16bit_cache[n_das][chan][i] != ifp_16bit[i]))
		dscon_snd(&lcl, ip);
	ifp_16bit_cache[n_das][chan][i] = ifp_16bit[i];
  }

  /* Transmit to DAS via DSCON dataset driver */
  run_dscon(ip);

  /* Scan responses for transmission failures */
  for (i=0; i<ip[1]; i++) {
	if ((ierr=dscon_rcv(&lclm,ip))) {
		if (shm_addr->das[n_das].ifp[0].initialised)
			shm_addr->das[n_das].ifp[0].initialised = -1;
		if (shm_addr->das[n_das].ifp[1].initialised)
			shm_addr->das[n_das].ifp[1].initialised = -1;
		cls_clr(ip[0]);
		return(ierr);
	}
  }

  /* Waiting for 1 PPS sync after is no longer required */
	
  shm_addr->das[n_das].ifp[chan].initialised = 1;
  return(0);
}

int lba_ifp_read(int n_ifp, int chekr)
{
  unsigned char chan, n_das;
  struct ds_cmd lcl;
  struct ds_mon lclm;
  int ip[5];
  int i, ierr;

  n_das = n_ifp / 2;
  chan = n_ifp % 2;

  if (!shm_addr->das[n_das].ifp[chan].initialised)
	 return(-1);

  /* All requests are directed to common DAS dataset address */
  lcl.type = DS_MON;
  strcpy(lcl.mnem,shm_addr->das[n_das].ds_mnem);

  /* Queue required dataset monitor requests */
  for (i=0; i<5; i++) ip[i]=0;

  /* PLL Lock Detector, Temp (analog), Temp (digital) */
  for (i=0; i<3; i++) {
	lcl.cmd = 2 + (chan * 3) + i;
	dscon_snd(&lcl,ip);
  }
  /* PLL Voltage Control */
  lcl.cmd = 16 + (chan * 2);
  dscon_snd(&lcl,ip);
  /* 1 PPS and 5 MHz errors */
  for (i=0; i<2; i++) {
	lcl.cmd = 64 + (chan * 2) + i;
	dscon_snd(&lcl,ip);
  }
  /* Fine Tuner Thresholds and Threshold Counters */
  for (i=8; i<12; i++) {
	lcl.cmd = 160 + (chan * 32) + i;
	dscon_snd(&lcl,ip);
  }
  /* Fine Tuner Flags */
  lcl.cmd = 160 + (chan * 32) + 14;
  dscon_snd(&lcl,ip);
  /* Band Splitter Thresholds, Thres, Offset & Level Counters and Flags */
  for (i=24; i<31; i++) {
	lcl.cmd = 160 + (chan * 32) + i;
	dscon_snd(&lcl,ip);
  }
  
  /* Transmit to DAS via DSCON dataset driver */
  if (chekr) nsem_take("fsctl",0);
  run_dscon(ip);
  if (chekr) nsem_put("fsctl");

  /* Interpret response data */
  for (i=0; i<18; i++) {
	if ((ierr=dscon_rcv(&lclm,ip))) {
		if (shm_addr->das[n_das].ifp[0].initialised)
			shm_addr->das[n_das].ifp[0].initialised = -1;
		if (shm_addr->das[n_das].ifp[1].initialised)
			shm_addr->das[n_das].ifp[1].initialised = -1;
		cls_clr(ip[0]);
		return(ierr);
	}
	switch (i) {
	   case 0:
		shm_addr->das[n_das].ifp[chan].pll_ld =
		   ((float)(lclm.data.value - 2048) / 4096.0) * 10.0;
		break;
	   case 1:
		shm_addr->das[n_das].ifp[chan].temp_analog =
		   ((float)(lclm.data.value - 2048) / 4096.0) * 1000.0;
		break;
	   case 2:
		shm_addr->das[n_das].ifp[chan].temp_digital =
		   ((float)(lclm.data.value - 2048) / 4096.0) * 1000.0;
		break;
	   case 3:
		shm_addr->das[n_das].ifp[chan].pll_vc =
		   ((float)(lclm.data.value - 2048) / 4096.0) * 20.0;
		break;
	   case 4:
		shm_addr->das[n_das].ifp[chan].sync_err =
			(lclm.data.value & 0x01);
		break;
	   case 5:
		shm_addr->das[n_das].ifp[chan].ref_err =
			(lclm.data.value & 0x01);
		break;
	   case 6:
		shm_addr->das[n_das].ifp[chan].ft.usb_threshold =
			(lclm.data.value & 0x00FF);
		break;
	   case 7:
		shm_addr->das[n_das].ifp[chan].ft.lsb_threshold =
			(lclm.data.value & 0x00FF);
		break;
	   case 8:
		shm_addr->das[n_das].ifp[chan].ft.usb_servo.readout = 
			(lclm.data.value & 0x00FF);
		break;
	   case 9:
		shm_addr->das[n_das].ifp[chan].ft.lsb_servo.readout = 
			(lclm.data.value & 0x00FF);
		break;
	   case 10:
		shm_addr->das[n_das].ifp[chan].processing =
			(lclm.data.value & 0x01);
		break;
	   case 11:
		shm_addr->das[n_das].ifp[chan].bs.usb_threshold =
			(lclm.data.value & 0x00FF);
		break;
	   case 12:
		shm_addr->das[n_das].ifp[chan].bs.lsb_threshold =
			(lclm.data.value & 0x00FF);
		break;
	   case 13:
		shm_addr->das[n_das].ifp[chan].bs.usb_servo.readout = 
			(lclm.data.value & 0x00FF);
		break;
	   case 14:
		shm_addr->das[n_das].ifp[chan].bs.lsb_servo.readout = 
			(lclm.data.value & 0x00FF);
		break;
	   case 15:
		shm_addr->das[n_das].ifp[chan].bs.offset.readout = 
			(lclm.data.value & 0x00FF);
		break;
	   case 16:
		shm_addr->das[n_das].ifp[chan].bs.level.readout = 
			(lclm.data.value & 0x00FF);
		break;
	   case 17:
		shm_addr->das[n_das].ifp[chan].clk_err =
			((lclm.data.value & 0x10) == 0x10);
		shm_addr->das[n_das].ifp[chan].blank =
			((lclm.data.value & 0x08) == 0x08);
		shm_addr->das[n_das].ifp[chan].processing &=
			(lclm.data.value & 0x01);
		break;
	}
  }
  return(0);
}

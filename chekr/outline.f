C
      include '../include/fscom.i'
C 
C  INPUT: 
C 
C     RMPAR - NOT USED
C 
C  SUBROUTINES CALLED:
C 
C     MATCN - to get data from the modules
C     BOSS  - to report error messages
C     LOGIT - to log and display the error
C     MA2VC - decode the MATCN buffers for VC 
C     MA2IF - decode the MATCN buffers for IF 
C     MA2FM - decode the MATCN buffers for FM 
C     MA2RP - decode the first MATCN buffer for the tape
C     MA2EN - decode the second MATCN buffer for the tape 
C     MA2TP - decode the third MATCN buffer for the tape
C     MA2MV - decode the fourth MATCN buffer for the tape 
C     MA2RX - decode
C     RXVTOT- convert MAT voltage reading to temperature
C 
C  LOCAL VARIABLES: 
      integer get_buf,ichcm_ch
      parameter (iagain=20)      ! repeat period for chekr (seconds)
C 
C     TIMTOL - tolerance on comparison between formatter and HP 
C     IDAREF - reference day number, from HP, re-set every loop 
      logical kalarm
C      - true for alarm ON, i.e. NAK response from MAT
C     I - major loop counter for module number 1 to NMOD
      dimension ip(5)             ! - for RMPAR
      dimension poffx(2),pnow(2)
      real*4 scale,volt           ! - for Head Position Read-out
      integer*2 ibuf1(40),ibuf2(5),ibuf3(5),ibuf4(5)
      integer it1(13),itfm(6)
      integer*4 secs_before,secs_after,secs_fm
      integer*4 timtol,diff_before,diff_after,diff_both,timchk
      integer itbuf1(5)
      parameter (ibuf1len=40)
      parameter (ibuf2len=5)
C      - the buffers from MATCN
      integer*2 lmodna(18)
      dimension nbufs(18), icodes(4,18)
C      - MODule NAmes, 2-char codes
C      - Number of BUFfers for each module
C      - Integer CODES for MATCN for each buffer
      dimension inerr(15),icherr(169),ichecks(20)
C      - Arrays for recording identified error conditions
      integer*2 lwho       ! - mnemonic for CHEKR
      dimension it(28),lchgen(2)     ! - dummy arrays for checking
      integer*2 lfr(3)
      dimension ireg(2)
      integer fc_dad_pid
      equivalence (ireg(1),reg)
C
C  INITIALIZED:
C
      data timtol/100.0/
C                   Set time tolerance to 100 centi-seconds
      data lwho /2Hch/
      data lmodna /2Hv1,2Hv2,2Hv3,2Hv4,2Hv5,2Hv6,2Hv7,2Hv8,2Hv9,2Hva,
     /             2Hvb,2Hvc,2Hvd,2Hve,2Hvf,2Hif,2Hfm,2Htp/
      data nbufs/15*2,2,2,4/
      data icodes/-1,-2,0,0,  -1,-2,0,0, -1,-2,0,0,
     .            -1,-2,0,0,  -1,-2,0,0, -1,-2,0,0,
     .            -1,-2,0,0,  -1,-2,0,0, -1,-2,0,0,
     .            -1,-2,0,0,  -1,-2,0,0, -1,-2,0,0,
     .            -1,-2,0,0,  -1,-2,0,0, -1,-2,0,0,
     .            -1,-2,0,0, -53,-4,0,0, -1,-2,-3,-4/
      data nmod/18/
      data nverr,niferr,nfmerr,ntperr,maxerr /9,8,11,15,15/
      data ichecks/20*0/
      data icherr/169*0/

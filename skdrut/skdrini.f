      SUBROUTINE SKDRINI
C
C  SKDRINI initializes common variables used by SKED and DRUDG
C
      include '../skdrincl/skparm.ftni'
      include '../skdrincl/sourc.ftni'
      include '../skdrincl/statn.ftni'
      include '../skdrincl/freqs.ftni'
      include '../skdrincl/skobs.ftni'
C
C 990921 nrv New. Copied from skini. Code moved here from fdrudg.f
C            Generally these are variables that have fixed values
C            but can't be set in parameter statements.
C 991110 nrv Initialize lmode_cat to blank.
C 991118 nrv Initialize nominal start/end times.
C 991208 nrv Add 'unused' rec type.
C 000126 nrv Add initialization of ntrkn.
C 000607 nrv Initialize tape_allocation to SCHEDULED.
C 000913 nrv Initialize roll tables here.
C 010622 nrv Move roll table initialization to skini because only
C            sked needs these to write VEX files.
C
C LOCAL
      integer ic,ix,ib,is,j,iv,i,idum,ichmv_ch
C DATA
C     data roll_def/ 02,02,16,14,12,10,08,06,04,0,0,0,0,0,0,0,0,
C    .   04,04,02,16,14,12,10,08,06,0,0,0,0,0,0,0,0,
C    .   06,06,04,02,16,14,12,10,08,0,0,0,0,0,0,0,0,
C    .   08,08,06,04,02,16,14,12,10,0,0,0,0,0,0,0,0,
C    .   10,10,08,06,04,02,16,14,12,0,0,0,0,0,0,0,0,
C    .   12,12,10,08,06,04,02,16,14,0,0,0,0,0,0,0,0,
C    .   14,14,12,10,08,06,04,02,16,0,0,0,0,0,0,0,0,
C    .   16,16,14,12,10,08,06,04,02,0,0,0,0,0,0,0,0,
C    .   18,18,32,30,28,26,24,22,20,0,0,0,0,0,0,0,0,
C    .   20,20,18,32,30,28,26,24,22,0,0,0,0,0,0,0,0,
C    .   22,22,20,18,32,30,28,26,24,0,0,0,0,0,0,0,0,
C    .   24,24,22,20,18,32,30,28,26,0,0,0,0,0,0,0,0,
C    .   26,26,24,22,20,18,32,30,28,0,0,0,0,0,0,0,0,
C    .   28,28,26,24,22,20,18,32,30,0,0,0,0,0,0,0,0,
C    .   30,30,28,26,24,22,20,18,32,0,0,0,0,0,0,0,0,
C    .   32,32,30,28,26,24,22,20,18,0,0,0,0,0,0,0,0,
C    .   03,03,17,15,13,11,09,07,05,0,0,0,0,0,0,0,0,
C    .   05,05,03,17,15,13,11,09,07,0,0,0,0,0,0,0,0,
C    .   07,07,05,03,17,15,13,11,09,0,0,0,0,0,0,0,0,
C    .   09,09,07,05,03,17,15,13,11,0,0,0,0,0,0,0,0,
C    .   11,11,09,07,05,03,17,15,13,0,0,0,0,0,0,0,0,
C    .   13,13,11,09,07,05,03,17,15,0,0,0,0,0,0,0,0,
C    .   15,15,13,11,09,07,05,03,17,0,0,0,0,0,0,0,0,
C    .   17,17,15,13,11,09,07,05,03,0,0,0,0,0,0,0,0,
C    .   19,19,33,31,29,27,25,23,21,0,0,0,0,0,0,0,0,
C    .   21,21,19,33,31,29,27,25,23,0,0,0,0,0,0,0,0,
C    .   23,23,21,19,33,31,29,27,25,0,0,0,0,0,0,0,0,
C    .   25,25,23,21,19,33,31,29,27,0,0,0,0,0,0,0,0,
C    .   27,27,25,23,21,19,33,31,29,0,0,0,0,0,0,0,0,
C    .   29,29,27,25,23,21,19,33,31,0,0,0,0,0,0,0,0,
C    .   31,31,29,27,25,23,21,19,33,0,0,0,0,0,0,0,0,
C    .   33,33,31,29,27,25,23,21,19,0,0,0,0,0,0,0,0,
C    .   02,02,16,14,12,10,08,06,04,18,32,30,28,26,24,22,20,
C    .   04,04,02,16,14,12,10,08,06,20,18,32,30,28,26,24,22,
C    .   06,06,04,02,16,14,12,10,08,22,20,18,32,30,28,26,24,
C    .   08,08,06,04,02,16,14,12,10,24,22,20,18,32,30,28,26,
C    .   10,10,08,06,04,02,16,14,12,26,24,22,20,18,32,30,28,
C    .   12,12,10,08,06,04,02,16,14,28,26,24,22,20,18,32,30,
C    .   14,14,12,10,08,06,04,02,16,30,28,26,24,22,20,18,32,
C    .   16,16,14,12,10,08,06,04,02,32,30,28,26,24,22,20,18,
C    .   18,18,32,30,28,26,24,22,20,02,16,14,12,10,08,06,04,
C    .   20,20,18,32,30,28,26,24,22,04,02,16,14,12,10,08,06,
C    .   22,22,20,18,32,30,28,26,24,06,04,02,16,14,12,10,08,
C    .   24,24,22,20,18,32,30,28,26,08,06,04,02,16,14,12,10,
C    .   26,26,24,22,20,18,32,30,28,10,08,06,04,02,16,14,12,
C    .   28,28,26,24,22,20,18,32,30,12,10,08,06,04,02,16,14,
C    .   30,30,28,26,24,22,20,18,32,14,12,10,08,06,04,02,16,
C    .   32,32,30,28,26,24,22,20,18,16,14,12,10,08,06,04,02,
C    .   03,03,17,15,13,11,09,07,05,19,33,31,29,27,25,23,21,
C    .   05,05,03,17,15,13,11,09,07,21,19,33,31,29,27,25,23,
C    .   07,07,05,03,17,15,13,11,09,23,21,19,33,31,29,27,25,
C    .   09,09,07,05,03,17,15,13,11,25,23,21,19,33,31,29,27,
C    .   11,11,09,07,05,03,17,15,13,27,25,23,21,19,33,31,29,
C    .   13,13,11,09,07,05,03,17,15,29,27,25,23,21,19,33,31,
C    .   15,15,13,11,09,07,05,03,17,31,29,27,25,23,21,19,33,
C    .   17,17,15,13,11,09,07,05,03,33,31,29,27,25,23,21,19,
C    .   19,19,33,31,29,27,25,23,21,03,17,15,13,11,09,07,05,
C    .   21,21,19,33,31,29,27,25,23,05,03,17,15,13,11,09,07,
C    .   23,23,21,19,33,31,29,27,25,07,05,03,17,15,13,11,09,
C    .   25,25,23,21,19,33,31,29,27,09,07,05,03,17,15,13,11,
C    .   27,27,25,23,21,19,33,31,29,11,09,07,05,03,17,15,13,
C    .   29,29,27,25,23,21,19,33,31,13,11,09,07,05,03,17,15,
C    .   31,31,29,27,25,23,21,19,33,15,13,11,09,07,05,03,17,
C    .   33,33,31,29,27,25,23,21,19,17,15,13,11,09,07,05,03/

      vex_version = '' ! initialize to null
      CALL IFILL(LEXPER,1,8,oblank)
      cexperdes='tbd'
      cpiname='tbd'
      ccorname='tbd'
C
C  In skobs.ftni
      NOBS = 0
      ISETTM=0
      IPARTM=0
      ITAPTM=0
      ISORTM=0
      IHDTM=0
      iyr_start=0
      ida_start=0
      ihr_start=0
      imin_start=0
      isc_start=0
      iyr_end=0
      ida_end=0
      ihr_end=0
      imin_end=0
      isc_end=0
C  In statn.ftni
      DO  I=1,MAX_STN   ! Initialize current variables
        itearl(i)=0
        itlate(i)=0
        itgap(i)=0
        tape_motion_type(i)='START&STOP'
        tape_allocation(i)='SCHEDULED'
        tape_length(i)=0
        ibitden_save(i)=0.0
        do j=1,max_frq
          bitdens(i,j)=0.0
          tape_dens(i,j)=0.0
        enddo
        idum= ichmv_ch(LSTCOD(I),1,'  ')
        call ifill(lterna(1,i),1,8,oblank)
        call ifill(lantna(1,i),1,8,oblank)
      END DO  ! Initialize current variables
C  Number of selected sources, stations, codes
      NSOURC = 0
      NSTATN = 0
C  In freqs.ftni
      NCODES = 0
      do ic=1,max_frq
        call ifill(lmode_cat(1,ic),1,16,oblank)
        do is=1,max_stn
          do iv=1,max_chan
            ibbcx(iv,is,ic)=0
            freqrf(iv,is,ic)=0.d0
          enddo
          ntrakf(is,ic)=0
          do i=1,max_band
            trkn(i,is,ic)=0.0
            ntrkn(i,is,ic)=0
            nfreq(i,is,ic)=0
          enddo
        enddo
        lcode(ic)=0
        do ix=1,max_band
          do is=1,max_stn
            wavei(ix,is,ic) = 0.0
            bwrms(ix,is,ic) = 0.0
          enddo
        enddo
      enddo
      NCELES = 0
      NSATEL = 0
      nband = 0
      do ib=1,max_band
        do is=1,max_sor
          nflux(ib,is)=0
          cfltype(ib,is)=' '
          do j=1,max_flux
            flux(j,ib,is)=0.0
          enddo
        enddo
      enddo

      do i=1,max_rack_type
        rack_type(1) = 'none'
        rack_type(2) = 'Mark3A'
        rack_type(3) = 'VLBA'
        rack_type(4) = 'VLBAG'
        rack_type(5) = 'VLBA/8'
        rack_type(6) = 'VLBA4/8'
        rack_type(7) = 'Mark4'
        rack_type(8) = 'VLBA4'
        rack_type(9) = 'K4-1'
        rack_type(10) = 'K4-2'
        rack_type(11) = 'K4-1/K3'
        rack_type(12) = 'K4-2/K3'
        rack_type(13) = 'K4-1/M4'
        rack_type(14) = 'K4-2/M4'
      enddo
      do i=1,max_rec_type
        rec_type(1) = 'none'
        rec_type(2) = 'unused'
        rec_type(3) = 'Mark3A'
        rec_type(4) = 'VLBA'
        rec_type(5) = 'VLBA4'
        rec_type(6) = 'Mark4'
        rec_type(7) = 'S2'
        rec_type(8) = 'K4-1'
        rec_type(9) = 'K4-2'
      enddo

C
C def VLBA/8;    *standard 8-track 8-position VLBA barrel-roll
      roll_name(1) = 'ROLL8'
      roll_reinit_period(1) = 2   
      roll_inc_period(1) = 1
      nrolldefs(1) = 32
      nrollsteps(1) = 9 ! 8 plus home track
C def VLBA/16'   *standard 16-track 16-position VLBA barrel-roll
      roll_name(2) = 'ROLL16'
      roll_reinit_period(2) = 2 
      roll_inc_period(2) = 1       
      nrolldefs(2) = 32
      nrollsteps(2) = 17 ! 16 plus home track
  
      RETURN
      END

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
C 020111 nrv Move roll table initialization back here because drudg
C            needs them to read and check roll_defs from VEX files.
C            But remove the DATA statement which seems to balloon the
C            program size.
C 020713 nrv Add Mk5 recorder type
C 021111 jfq Add LBA rack type
C 2003Apr17  JMG   Added Mark5p
C 2003Jul23  JMG   Added Mk5PigW
! 2007May25  JMG   Added Mark5B recorder, MK4V and VLAB4V racks.
! 2007Jul02  JMG. Removed initializaiotn of fluxes. Done elsewhere.
! 2007Aug07  JMG. Moved rack, recorder type initialization to block data statement in
!                 "valid_hardware.f"
! 2019Aug22  JMG. Initialized lcode here and not in frinit. 
C
C LOCAL
      integer ix,ib,i,j,l,itx,ity,itz,idef,iy,ir
C DATA
C     data ((roll_def(i,j,1),j=1,32),i=1,17)/ 
C    .   02,02,16,14,12,10,08,06,04,0,0,0,0,0,0,0,0,
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
C    .   33,33,31,29,27,25,23,21,19,0,0,0,0,0,0,0,0/
C     data ((roll_def(i,j,2),j=1,32),i=1,17)/ 
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
      cexper=" "
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
          cnahdpos(i,j)=" "
          do l=1,max_bbc
             ibbc_present(l,i,j)=0
          end do
        enddo
        cstcod(i)=" "
        cterna(i)=" "
        cantna(i)=" "
      END DO  ! Initialize current variables



C  Number of selected sources, stations, codes
      NSOURC = 0
      NSTATN = 0
C  In freqs.ftni
      call freq_init
      NCELES = 0
      NSATEL = 0
      nband = 0

C Initialize canned roll defs
C
C def VLBA/8;    *standard 8-track 8-position VLBA barrel-roll
      ircan_reinit(1) = 2   
      ircan_inc(1) = 1
      nrcan_defs(1) = 32
      nrcan_steps(1) = 8
C def VLBA/16'   *standard 16-track 16-position VLBA barrel-roll
      ircan_reinit(2) = 2 
      ircan_inc(2) = 1       
      nrcan_defs(2) = 32
      nrcan_steps(2) = 16
C Initialize to zero
      do ix=1,2
        do iy=1,32
          do ib=1,18
            icantrk(ib,iy,ix)=0
          enddo
        enddo
      enddo
  
      do ir=1,2 ! two canned patterns for 8 and 16
        idef = 0
        do ity=2,32,2 ! each roll_def line, first set
          idef = idef + 1
          icantrk(1,idef,ir) = 1 ! headstack 1
          icantrk(2,idef,ir) = ity ! home track
          icantrk(3,idef,ir) = ity
          itz=ity
          do itx=1,7 ! next 7 tracks
            itz = itz-2
            if (itz.le. 0) itz=itz+16
            if (ity.gt.16.and.itz.le.16) itz=itz+16
            icantrk(3+itx,idef,ir) = itz
          enddo ! first 8 tracks
          if (ir.eq.2) then ! next 8 tracks
            itz=itz+16
            do itx=1,8 ! next 8 tracks
              itz=itz-2
              if (itz.le. 0) itz=itz+16
              if (itz.gt.32) itz=itz-32
              if (itz.eq.16.and.ity.le.16) itz=32
              if (itz.eq.32.and.ity.eq.32) itz=16
              icantrk(10+itx,idef,ir) = itz
            enddo 
          endif ! next 8 tracks
        enddo ! each roll_def line, first set
        do ity=3,33,2 ! each roll_def line, second set
          idef = idef + 1
          icantrk(1,idef,ir) = 1 ! headstack 1
          icantrk(2,idef,ir) = ity ! home track
          icantrk(3,idef,ir) = ity
          itz=ity
          do itx=1,7 
            itz=itz-2
            if (itz.le.1) itz=itz+16
            if (ity.gt.17.and.itz.le.17) itz=itz+16
            icantrk(itx+3,idef,ir) = itz
          enddo 
          if (ir.eq.2) then ! second half of line for '16:1'
            itz=itz+16
            do itx=1,8 
              itz=itz-2
              if (itz.le. 1) itz=itz+16
              if (itz.gt.32) itz=itz-32
              if (itz.eq.17.and.ity.le.17) itz=33
              if (itz.eq.1.and.ity.eq.33) itz=17
              icantrk(itx+10,idef,ir) = itz
            enddo 
          endif ! second half of line for '16:1'
        enddo ! each roll_def line, second set
      enddo ! two canned patterns for 8 and 16

C Initialize non-standard roll tables to -99.
      call init_iroll_def()

      do i=1,max_frq
        lcode(i)=0
        do j=1,max_stn
          iroll_inc_period(j,i) = 0
          iroll_reinit_period(j,i) = 0
          nrolldefs(j,i) = 0
          nrollsteps(j,i) = 0
        enddo
      enddo

      call valid_hardware_blk

      return
      end

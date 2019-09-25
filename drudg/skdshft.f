	SUBROUTINE SKDSHFT(IERR)

C   Shift a schedule

C 900112 PMR code extracted from SHFTR and ported to Unix
C 900628 GAG Structured (all GOTOs removed)
C 901108 NRV Informational messages added, Break added
C 901109 NRV Removed display of start times, added request for a time.
C 910826 NRV Always wrap by 1 day
c 930412 nrv implicit none
C 960223 nrv change permissions on output file
C 980831 nrv Mods for Y2000. Use IYR2 for 2-digit year, all other
C            year variables are fully specified.
C 990427 nrv Require 4-digit input year.
! 2006Oct3  JMG Completely rewritten.
! 2007Jan24 JMG. Input part modified.
! 2013Jul17 JMG. No longer need to find 'modular' or 'prepass' or 'cont'
! 2015Mar30 JMG. got rid of obsolete arg in drchmod
! 2019Jun10 JMG. Got rid of call to NR caldat. Replaced with gdate. 
      include '../skdrincl/skparm.ftni'
      include 'drcom.ftni'
      include '../skdrincl/skobs.ftni'

! functions
      integer trimlen
      double precision ctime2dmjd
      integer iday0
C Input: none
C Output:
      integer ierr

! local
      logical KFNDMD, KFNDCH, kfndpr
      logical kname,kdone
      integer nch
      integer ic1,ic2,ilen
      integer ifc,ilc
      character*20 ctemp
      character*9 cpre
      integer   itemp
      integer imodp,ichngp,iprep
      integer i
      integer num_obs_new

! shifted schedule
      integer iy_new                  !4 and 2 digit year of start of new schedule
      integer imon_new                !starting month
      integer id_new,idoy_new         !starting day, and starting DOY
      integer ih_new,im_new,is_new    !starting hour,minute,second
      integer num_hrs                 !length in hours.

      double precision tau_sid        !sidereal day in units of solar day.
      double precision tau_shift      !time to shift.
      integer Nsid_day                !number of sidereal days to shift.

      character*12 ctim_beg           !starting and ending time of original schedule
      character*12 ctim_end           !in sked format.
      character*12 ctim_skd

      integer iy_skd,idoy_skd,id_skd  !schedule time
      integer ih_skd,im_skd,is_skd,imon_skd

      double precision TimeExpBeg     !Jday of Start
      double precision TimeExpEnd     !Jday of End
      double precision TimeExpBeg_New !Jday of shifted experiment
      double precision TimeExpEnd_New !Jday of shifted experiment
      double precision TimeExpSkd     !Schedule time or shifted schedule time
      double precision TimeExpFnd     !Time in new experiment
      double precision dsecond        !Seconds part of day 

      integer iwrite_pos              !position to write time
      integer iobs                    !Counter over observations
      integer julian                  !Mjd date

! Initialization
      tau_sid=365.2422d0/366.2422d0

! Only shift schedules which are ~ 24 hours.

! get time of first obs and parse.
      call sktime(cskobs(1),ctim_beg)
      TimeExpBeg=ctime2dmjd(ctim_beg)
      iwrite_pos=index(cskobs(1),ctim_beg)  !Get the positin in the obs string to write the time.

! get time of last obs and parse.
      call sktime(cskobs(nobs),ctim_end)
      TimeExpEnd=ctime2dmjd(ctim_end)

      if(TimeExpEnd-TimeExpBeg .lt. 0.98) then
         write(*,*) "Experiment is too short. Must be 24 hours!"
         ierr=1
         return
      endif

! Continue
      nch = TRIMLEN(CINNAME)
      WRITE(LUSCN,'(" Shifting: ",a)')  CINNAME(1:nch)
      OPEN(LU_INFILE,FILE=CINNAME,STATUS='OLD',IOSTAT=IERR)
      REWIND(LU_INFILE)

      IF(IERR.NE.0) then
        WRITE(LUSCN,'(" SKDSHFT01 - ERROR ",I5," opening file: ",A)')
     >      IERR,CINNAME(1:nch)
        RETURN
      end if

! Write out stop, start times.
      do i=1,2
        if(i .eq. 1) then
          TimeExpSkd=TimeExpBeg
          cpre=" Starts: "
        else
          TimeExpSkd=TimeExpEnd
          cpre="Ends:   "
        endif
        Julian=Int(TimeExpSkd)                      !Get integer and fracitonal part
        TimeExpSkd=(TimeExpSkd-Julian)*86400.d0     !this is fractional part.
        call seconds2hms(TimeExpSkd,ih_skd,im_skd,is_skd)
        julian=julian+2440000
        call gdate(julian,iy_skd,imon_skd,id_skd)
        write(luscn,'(a,i4,2("/",i2.2)," ",i2.2,2(":",i2.2),"   ",$)')
     >       cpre, iy_skd,imon_skd,id_skd, ih_skd,im_skd,is_skd
      end do
! End writing sto start.
      write(luscn,'()')

C
C 1.0  Get output file name
      kdone = .false.
      kname = .false.
      do while (.not.kdone)
        do while (.not.kname)
          WRITE(LUSCN,'(" Enter name of output file (:: to quit): ",$)')
          READ(LUUSR,'(A)') COUTNAME
          IF (COUTNAME(1:2).EQ.'::') RETURN
          IF (CINNAME.EQ.COUTNAME) THEN
            WRITE(LUSCN,*) "Input and output must have different names!"
	  else
	    kname = .true.
	  ENDIF
	end do  ! kname
C
        call purge_file(coutname,luscn,luusr,kbatch,ierr)
        if(ierr .ne. 0) return
        kdone=.true.
      end do ! kdone

      OPEN(LU_OUTFILE,FILE=COUTNAME,STATUS='NEW',IOSTAT=IERR)
      IF(IERR.nE.0) then
        WRITE(LUSCN,'("SKDSHF ERROR ",i5, " opening file",a)')
     >      IERR,coutname
        return
      end if
C
C 2.0  Get target date and time.
C
      iy_new=-1
      imon_new=-1
      id_new=-1
      do while (iy_new.lt.0.or.imon_new.lt.0.or.id_new.lt.0)
        write(luscn,
     >  '(" Enter starting time (yyyy mm dd hh mm ss) (0,0,0 to quit): "
     >    ,$)')
        read(luusr,*,err=201) iy_new,imon_new,id_new,
     >      ih_new,im_new,is_new
        if (iy_new.eq.0) return
c       Require 4-digit year.
201     if ((iy_new.lt.1970).or.
     >      (imon_new.le.0.or.imon_new.gt.12).or.
     >      (id_new.le.0.or.id_new.gt.31).or.
     >      (ih_new.lt.0.or.ih_new.gt.24).or.
     >      (im_new.lt.0.or.im_new.gt.59).or.
     >      (is_new.lt.0.or.is_new.gt.59)) then
          write(luscn,'(" Invalid number for time, try again.")')
	  iy_new=-1
	endif
      enddo

      IDOY_new = IDAY0(IY_new,IMon_new) + ID_new

      write(luscn,9200) ' Requested start time of shifted schedule: ',
     >                     iy_new,idoy_new,ih_new,im_new,is_new
9200  format(a, i4,1x,i3,'-',i2.2,2(':',i2.2))

      write(ctim_skd,'(i2,i3.3,3i2.2)') iy_new-2000,idoy_new,
     >  ih_new,im_new,is_new
      TimeExpBeg_New=ctime2dmjd(ctim_skd)

C
C  2.6  Get desired length of schedule

      num_hrs=-1
      do while (num_hrs.lt.0)
        write(luscn,'(" Length of shifted schedule (0=quit) ? ",$)')
        read(luusr,*,err=261) num_hrs
261     if (num_hrs.eq.0) return
        if (num_hrs.lt.0) write(luscn,'(" Invalid length. Try again.")')
      enddo
      TimeExpEnd_New=TimeExpBeg_New+dble(num_hrs)/24.d0
C
C 3.0 Check for proper start of schedule.
C
      cbuf="* "
      do while (cbuf(1:1) .eq. "*")
        CALL readf_asc(LU_INFILE,IERR,IBUF,ISKLEN,iLEN)
        IF(IERR.NE.0) THEN
          WRITE(LUSCN,"(' SKDSHFT02 - READ ERROR ',I5)") ierr
          RETURN !
        ENDIF
      end do
C
      if(cbuf(1:6) .ne. "$EXPER") then
        WRITE(LUSCN,"(a)") ' Did not find $EXPER on first line.'
        RETURN
      ENDIF
C
C 4.0  Locate change, modular, and prepass parameters.
C
      cbuf="  "
      do while(cbuf(1:6) .ne. "$PARAM")
        CALL readf_asc(LU_INFILE,IERR,IBUF,ISKLEN,iLEN)
        IF(IERR.NE.0) THEN
          write(luscn,
     >       '("SKDSHFT03: Error found looking for $PARAM",i3)') ierr
          RETURN
        ENDIF
        IF(iLEN.EQ.-1) THEN
          WRITE(LUSCN,'("SKDSHFT04: EOF reached looking for $PARAM")')
          RETURN
        ENDIF
      end do
C     
      ichngp=1
      imodp=1
      iprep=1
       goto 9460

      do while ((.not.kfndmd).or.(.not.kfndch).or.(.not.kfndpr))
        CALL readf_asc(LU_INFILE,IERR,IBUF,ISKLEN,iLEN)
        IF(IERR.NE.0) THEN
          WRITE(LUSCN,9420) IERR
9420      FORMAT(' SKDSHFT05 - READ ERROR ',i5,' in $PARAM section')
          RETURN
        ENDIF
        IF(cbuf(1:1) .eq. "$") THEN
          WRITE(LUSCN,'(a)')' SKDSHFT06 - Did not find MODULAR and/or'
     >          //' CHANGE and/or PREPASS in $PARAM section.'
	  RETURN
       ENDIF
C
       IFC = 1
       ILC = iLEN*2
       CALL GTFLD(IBUF,IFC,ILC,IC1,IC2)
       do while (ic1.ne.0)
         ctemp=cbuf(ic1:ic2)
         if(ctemp .eq. "MODULAR" .or. ctemp .eq. "CHANGE" .or.
     >      ctemp .eq. "PREPASS") then
           CALL GTFLD(IBUF,IFC,ILC,IC1,IC2)
           if(ic1 .eq. 0) then
             WRITE(LUSCN,'(a)')'SKDSHFT: No value field after ', ctemp
             return
           endif
           read(cbuf(ic1:ic2),*) itemp
           if(ctemp .eq. "MODULAR") then
             kfndmd=.true.
             imodp=itemp
           else if(ctemp .eq. "CHANGE") then
             kfndch=.true.
             ichngp=itemp
           else if(ctemp .eq. "PREPASS") then
             kfndpr=.true.
             iprep=itemp
           endif
         endif
         CALL GTFLD(IBUF,IFC,ILC,IC1,IC2)
	end do !"while ic1 = 0"
      end do !"while not kfndch or kfndmd"

9460  continue
      write(luscn,9470) ichngp,imodp,iprep
9470  format(' Tape change time = ',i5,
     .       '.  Modular start time = ',i5,
     .       '.  Prepass time = ',i5,'.')
C
C 5.0  Copy file up to $SKED section.
C

      REWIND(LU_INFILE)
      write(luscn,"(a)")'Writing out file up to $SKED section.'

      do while (cbuf(1:5) .ne. '$SKED')
       CALL readf_asc(LU_INFILE,IERR,IBUF,ISKLEN,iLEN)
       IF(IERR.NE.0) THEN
         WRITE(LUSCN,9500) IERR
9500     FORMAT(' SKDSHFT09 - READ ERROR ',I5,' searching for $SKED')
         RETURN
       ENDIF
       IF(iLEN.EQ.-1) THEN
         WRITE(LUSCN,'(a)')' SKDSHFT10 - Did not find $SKED before EOF.'
         RETURN
       ENDIF
C
       write(lu_outfile,'(a)') cbuf(1:2*ilen)
      end do !"read until $SKED"
! Here is where we write out the shifted schedule.

      NSid_day=(TimeExpBeg_New-TimeExpBeg)/tau_sid

      if(TimeExpBeg .gt. TimeExpBeg_New) NSid_day=Nsid_day-1

      tau_shift=tau_sid*dble(Nsid_day)
! Now   TimeExpBeg_New-tau_shift should lie within experiment.

      do iobs=1,nobs
         call sktime(cskobs(iobs),ctim_skd)
         TimeExpSkd=ctime2dmjd(ctim_skd)+tau_shift
         if(TimeExpSkd .ge. TimeExpBeg_New) goto 200
      end do
      write(luscn,*) "Did not not find starting obs!"
      ierr=1
      return

! located first observation to shift.
200   continue
      TimeExpFnd=0
      num_obs_new=0 
      do while(TimeExpSkd .lt. TimeExpEnd_New)
        Julian=Int(TimeExpSkd)                   !Get integer and fractional part of the day. 
        dsecond=(TimeExpSkd-Julian)*86400.d0     !this is fractional part.
        call seconds2hms(dsecond,ih_skd,im_skd,is_skd)

        julian=julian+2440000
        call gdate(julian,iy_skd,imon_skd,id_skd)
        IDOY_skd = IDAY0(IY_skd,IMon_skd) + ID_skd
        iy_skd=iy_skd-2000
        cbuf=cskobs(iobs)
        write(cbuf(iwrite_pos:iwrite_pos+10),'(i2.2,i3.3,3i2.2)')
     >   iy_skd,idoy_skd,ih_skd,im_skd,is_skd
        write(lu_outfile,'(a)') cbuf(1:trimlen(cbuf))
        num_obs_new=num_obs_new+1
210     continue
        iobs=iobs+1                     !if we come to the end of original schedule.
        if(iobs .gt. nobs) then
          iobs=1
          Tau_shift=Tau_shift+Tau_sid
          TimeExpFnd=TimeExpSkd
          write(*,*) "Wrapping ", TimeExpFnd
        endif
        call sktime(cskobs(iobs),ctim_skd)
        TimeExpSkd=Ctime2dmjd(ctim_skd)+Tau_Shift
        i=i+1
!        write(*,'("Sked time ",i4,3f10.3)')
!     >   iobs,TimeExpSkd, TimeExpEnd_New,TimeExpFnd
!        if(i .eq. 100) stop
! When we go back to the beginning, make sure that shifted time is later than
! last time we have written out.
        if(TimeExpSkd .lt. TimeExpFnd) goto 210
      end do

! Done writing $SKED part of file.  Need to space to end of section and write rest of file.

C 10.0  Finish copying the rest of the file.
C
      write(luscn,'(a)')
     >   ' Copying rest of schedule file beyond $SKED section.'

! Skip over sked section in input.
      do while (cbuf(1:1).ne."$" .and. ilen .ne.-1) !read to next $
        call readf_asc(LU_INFILE,IERR,IBUF,ISKLEN,iLEN)
        IF(IERR.ne.0) THEN
          WRITE(LUSCN,8020) IERR
8020      FORMAT(' SKDSHFT33 - Error ',I5,' finding end of $SKED')
          RETURN
        ENDIF
      enddo !read to next $

      do while (ilen.ne.-1) !copy to end
        CALL writf_asc(LU_OUTFILE,IERR,IBUF,iLEN)
        IF(IERR.NE.0) THEN
          WRITE(LUSCN,'(" SKDSHFT30 - WRITE ERROR ",I5)') IERR
          RETURN
         ENDIF
   	 CALL readf_asc(LU_INFILE,IERR,IBUF,ISKLEN,iLEN)
 	 IF(IERR.ne.0) THEN
	    WRITE(LUSCN,'(" SKDSHFT31 - READ ERROR ",I5)') IERR
	    RETURN
	  ENDIF
      end do !copy to end

      write(luscn,'("Wrote:", a,a,i5,a)')
     >    coutname(1:trimlen(coutname))," with ",num_obs_new,    
     >     " observations." 

C
990   close(lu_outfile)
      call drchmod(coutname,ierr)
      RETURN
      END

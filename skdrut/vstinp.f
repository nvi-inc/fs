      SUBROUTINE VSTINP(ivexnum,lu,ierr)
C
C     This routine gets all the station information
C     and stores it in common.
C
      include '../skdrincl/skparm.ftni'
      include '../skdrincl/statn.ftni'
      include '../skdrincl/constants.ftni'
C
C History:
C 960517 nrv New.
C 960810 nrv Add tape motion to VUNPDAS call. Store LSTREC.
C 960817 nrv Add tape speed and number of tapes to VUNPDAS.
c 970123 nrv Add calls to ERRORMSG.
C 991103 nrv Initialize LSTREC2 to 'none', LFIRSTREC to 'A'.
C 991123 nrv Recorder 1 and 2, not a and b.
C 001114 nrv For two recorders save second type same as first.
C 010615 nrv Initialize lstrec2 to blanks.
C
C INPUT:
      integer ivexnum ! vex file number 
      integer lu ! unit for writing error messages
C
C OUTPUT:
      integer ierr ! error number, non-zero is bad

! functions
      integer ichmv_ch,ichcm_ch,ichmv ! functions
      integer ptr_ch,fget_station_def,fvex_len

C
C LOCAL:
      logical kline
      integer ierr1
      integer*2 lant(4),LAXIS(2),lter(4),lsit(4)
      real SLRATE(2),ANLIM1(2),ANLIM2(2)
      integer*2 LOCC(4),lrec(4),lrack(4),ls2sp(2)
      integer islcon(2),ns2tp
      real AZH(MAX_HOR),ELH(MAX_HOR)
      real DIAM
      real sefd(max_band),par(max_sefdpar,max_band)
      integer*2 lb(max_band)
      double precision POSXYZ(3),AOFF
      INTEGER J,nr,maxt,npar(max_band),idummy,nhz,i,idum
      integer*2 lidt(2),lid,ltlc
      character cstid(max_stn)
      double precision poslat,poslon
      integer nstack
      integer il,ite,itl,itg
      integer iret ! return from vex routines
      character*128 cout,ctapemo

C
C     1. First get all the def names 
C
      nstatn=0
      iret = fget_station_def(ptr_ch(cout),len(cout),ivexnum) ! get first one
      do while (iret.eq.0.and.fvex_len(cout).gt.0)
        IF  (nstatn.eq.MAX_STN) THEN  !
          write(lu,
     > '("VSTINP20 - Too many antennas.  Max is ",i3,".  Ignored: ",a)')
     >  MAX_STN,cout
        else
          nstatn=nstatn+1
          stndefnames(nstatn)=cout
          iret = fget_station_def(ptr_ch(cout),len(cout),0) ! get next one
        END IF 
      enddo

C     2. Now call routines to retrieve all the station information.

      ierr1= 0
      do i=1,nstatn ! get all station information

        il=fvex_len(stndefnames(i))
        CALL vunpant(stndefnames(i),ivexnum,iret,ierr,lu,
     .    lant,LAXIS,AOFF,SLRATE,ANLIM1,ANLIM2,DIAM,ISLCON)
        if (iret.ne.0.or.ierr.ne.0) then 
          write(lu,
     >    '(a, a,/,"iret=",i5," ierr=",i5)')
     >     "VSTINP01 - Error getting $ANTENNA information for ",
     >     stndefnames(i)(1:il),  iret,ierr
          call errormsg(iret,ierr,'ANTENNA',lu)
          ierr1=1
        endif
        CALL vunpsit(stndefnames(i),ivexnum,iret,IERR,lu,
     .    LID,lsit,POSXYZ,POSLAT,POSLON,LOCC,nhz,azh,elh)
        if (iret.ne.0.or.ierr.ne.0) then 
          write(lu,'(a,a,/,"iret=",i5," ierr=",i5)')
     >     "VSTINP02 - Error getting $SITE information for ",
     >      stndefnames(i)(1:il),  iret,ierr
          call errormsg(iret,ierr,'SITE',lu)
          ierr1=2
        endif
        CALL vunpdas(stndefnames(i),ivexnum,iret,IERR,lu,
     .    LIDT,lter,nstack,maxt,nr,lb,sefd,par,npar,
     .    lrec,lrack,ctapemo,ite,itl,itg,ls2sp,ns2tp,
     .    ltlc)
        if (iret.ne.0.or.ierr.ne.0) then 
          write(lu,'(a,a,/,"iret=",i5," ierr=",i5)')
     >    "VSTINP03 - Error getting $DAS information for ",
     >    stndefnames(i)(1:il),  iret,ierr
          call errormsg(iret,ierr,'DAS',lu)
          ierr1=3
        endif
C
C     2. Now decide what to do with this information.
C
C       2.1 Antenna information

        LSTCOD(I) = LID
        LPOCOD(I) = lstcod(i)
        call axtyp(laxis,iaxis(i),1)
        STNRAT(1,I) = SLRATE(1)
        STNRAT(2,I) = SLRATE(2)
        ISTCON(1,I) = ISLCON(1)
        ISTCON(2,I) = ISLCON(2)
        STNLIM(1,1,I) = ANLIM1(1)
        STNLIM(2,1,I) = ANLIM1(2)
        STNLIM(1,2,I) = ANLIM2(1)
        STNLIM(2,2,I) = ANLIM2(2)
        AXISOF(I)=AOFF
        DIAMAN(I)=DIAM
        idummy = ichmv(LTERID(1,I),1,LIDT,1,4)
        NHORZ(I) = 0
C       For VEX 1.3, antenna name is not there, so use site name
        if (ichcm_ch(lant,1,'        ').eq.0) then
          IDUMMY = ICHMV(LANTNA(1,I),1,lsit,1,8)
        else
          IDUMMY = ICHMV(LANTNA(1,I),1,lant,1,8)
        endif
C
C       2.2 Here we handle the position information.
C     It is not an error to have the occ. code or lat,lon missing.
C
        IDUMMY = ICHMV(LSTNNA(1,I),1,lsit,1,8)
        STNPOS(1,I) = POSLON*deg2rad
        STNPOS(2,I) = POSLAT*deg2rad
        stnxyz(1,i) = posxyz(1)
        stnxyz(2,i) = posxyz(2)
        stnxyz(3,i) = posxyz(3)
        idum=ichmv(loccup(1,i),1,locc,1,8)
C
C     2.4 Here we handle terminal information
C
        if (ichcm_ch(lter,1,'        ').eq.0) then
          IDUMMY = ICHMV(LTERNA(1,I),1,lsit,1,8)
        else
          IDUMMY = ICHMV(LTERNA(1,I),1,lter,1,8)
        endif
        idummy = ichmv(lstrack(1,i),1,lrack,1,8) ! rack type
        idummy = ichmv(lstrec(1,i),1,lrec,1,8) ! recorder 1
        call ifill(lstrec2(1,i),1,8,oblank)
        idummy = ichmv_ch(lstrec2(1,i),1,'none') ! default recorder 2
        if (nr.eq.2) then 
          idummy = ichmv(lstrec2(1,i),1,lrec,1,8) ! recorder 2 same as 1
        endif 
        idummy = ichmv_ch(lfirstrec(i),1,'1 ') ! first recorder
        nheadstack(i)=nstack ! number of headstacks
        maxtap(i) = maxt     ! tape length
        nrecst(i) = nr       ! number of recorders
        ns2tapes(i) = ns2tp  ! number of S2 tapes
        idummy = ichmv(ls2speed(1,i),1,ls2sp,1,4) ! rack type
        tape_motion_type(i)=ctapemo   ! tape motion
        itearl(i)=ite                 ! early start time
        itlate(i)=itl                 ! late stop time
        itgap(i)=itg                  ! gap time
C Skip SEFDs for now
C       do ib=1,2
C         idum = igtba(lb(ib),ii)
C         if (ii.ne.0) then 
C           sefdst(ii,i) = sefd(ib)
C           do j=1,npar(ii)
C             sefdpar(j,ii,i) = par(j,ii)
C           enddo
C           nsefdpar(ii,i) = npar(ii)
C           lbsefd(ib,i) = lb(ib)
C         else ! error
C         end if
C       enddo
C
C      2.5 Here we handle the horizon mask
C
        kline=.true.
C           write(lu,'("VSTINP252 - Horizon mask azimuths are out ",
C    .      "of order. Error in field ",i5)') -(ierr+200)
C           write(lu,'("VSTINP250 - Too many horizon mask az/el pairs. ",
C    .      "Max is ",i5)') max_hor 
C           write(lu,'("VSTINP251 - No matching el for last azimuth,",
C    .      " wraparound value used.")')
C           elh(nhz)=elh(1)
C           kline=.false.
C         if (kline) then
C           klineseg(i)=.true.
C           write(lu,'("VSTINP255 - Line segment horizon mask being ",
C    .      "used for ",4a2)') (lstnna(j,ii),j=1,4)
C         else
C           klineseg(i)=.false.
C           write(lu,'("VSTINP255 - Step function horizon mask being ",
C    .      "used for ",4a2)') (lstnna(j,ii),j=1,4)
C         endif
          NHORZ(I) = NHZ
          if (nhorz(i).gt.0) then
            DO J=1,NHORZ(I)
              AZHORZ(J,I) = AZH(J)
              ELHORZ(J,I) = ELH(J)
            END DO
          endif
C
C      2.6 Here we handle the coordinate mask
C

      enddo ! get all station information

C Check for duplicate 1-letter codes and change any necessary.

      do i=1,nstatn
        call hol2char(lstcod(i),1,1,cstid(i))
      enddo
      do i=2,nstatn
        call idchk(i,cstid,lu)
      enddo
      do i=1,nstatn
        idum=ichmv_ch(lstcod(i),1,'  ') ! blank it out
        idum=ichmv_ch(lstcod(i),1,cstid(i)) ! move in one char
      enddo

      ierr=ierr1
      RETURN
      END

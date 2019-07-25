	SUBROUTINE VPROCS  !WRITE VLBA PROC LIBRARY 
C PROCS writes procedure file for VLBA backends
C **NOTE** The LO information is insufficient to unambiguously
C          decide which LO belongs with which BBC. The IFd
C          procedure is not written out, and the BBC commands
C          assume the standard geodetic configuration.
C
	INCLUDE 'skparm.ftni'
C
C MODIFICATIONS:
C DATE    WHO  DESCRIPTION
C 930714  nrv  created,copied from procs
C 940308  nrv  Added a check for "NW" to make the correct BBC
C              IF input 
C 940620  nrv  In batch mode, always 'Y' for purging existing.
C
C COMMON BLOCKS USED:
	INCLUDE 'freqs.ftni'
	INCLUDE 'drcom.ftni'
	INCLUDE 'statn.ftni'

C LOCAL VARIABLES:
      integer*2 IBUF2(40)
C secondary buffer for writing files
      integer*2 LTRK(2),lg1,lg2,lg3,lg4
C temp holder for LTRAKS(*,pass,code)
	LOGICAL*4 KUS
C true if our station is listed for a procedure
	LOGICAL*4 KBIT
	integer IC,ierr,i,idummy,nch,ib,idum,
     .ipass,icode,it,ivcn,ilo,iband,
     .iv,ict,lhi,ilen,ich,ic1,ic2,ibuflen
      real*4 spdips
	CHARACTER UPPER
	CHARACTER*4 STAT
	CHARACTER*4 RESPONSE
	CHARACTER*9 ST
	integer*2 LNAMEP(6)
	logical*4 ex
        logical kdone
C name of individual procs
      real*8 DRF,DLO,DFVC
      real*4 fvc(14),rfvc  !VC frequencies
C temp. variables for determining I.F.
C video converter frequency
      integer*2 lpsx(7),lpwb(7)
      integer ir2as,ib2as,mcoma,trimlen,jchar,ichmv ! functions
      integer ichcm_ch, ichmv_ch
C
C INITIALIZED VARIABLES:
	integer*2 LVCN(14)
      logical kmatch
C ASCII codes for video converters
	integer Z20,HEB,Z4E,Z41,Z24,Z8000
	DATA Z20/Z'20'/, HEB/2HE /, Z4E/Z'4E'/, Z41/Z'41'/
	DATA Z24/Z'24'/, Z8000/Z'8000'/
	DATA ST/' ***^*** '/
	DATA LVCN /2H01,2H02,2H03,2H04,2H05,2H06,2H07,2H08,2H09,2H10,
     .           2H11,2H12,2H13,2H14/
        data ibuflen/80/
C
      call char2hol('aaaaaaaabbbbbb',lpsx,1,14)
      call char2hol('aaaaccccbbbbbb',lpwb,1,14)

C 0. If this is a VLBA station, don't need procedures.

      if (kvlba) then ! then there is a $VLBA section in the schedule
        kmatch = .false.
        do i=1,ncodes
          if (ivix(i,istn).ne.0) kmatch = .true.
        enddo
        if (kmatch) then
          write(luscn,9210) (lantna(I,ISTN),I=1,4)
9210      format(/4a2,' is a VLBA station, does not use Mark III ',
     .    'procedures.'/)
          return
        end if
      endif

C 1. Set up the loop over all frequency codes, and the
C inner loop over the number of passes.
C Generate the procedure name, then write into proc file.
      WRITE(LUSCN,9111)  (LSTNNA(I,ISTN),I=1,4)
9111  format('Procedures for ',4a2)
      stat='new'
      ic = trimlen(prcname)
C
      inquire(file=prcname,exist=ex,iostat=ierr)
      if (ex) then
        if (kbatch) then
          response = 'Y'
        else
          kdone = .false.
          do while (.not.kdone)
            write(luscn,9130) prcname(1:ic)
9130        format(' OK to purge existing file ',A,' (Y/N) ? ',$)
            read(luusr,'(A)') response
            response(1:1) = upper(response(1:1))
            if (response(1:1).eq.'N') then
              return
            else if (response(1:1).eq.'Y') then
              kdone = .true.
            end if
          end do
        endif
        open(lu_outfile,file=prcname)
        close(lu_outfile,status='delete')
      end if
C
      WRITE(LUSCN,9113) PRCNAME(1:IC), (LSTNNA(I,ISTN),I=1,4)
9113  FORMAT(' VLBA PROCEDURE LIBRARY FILE ',A,' FOR ',4A2)
      write(luscn,9114) 
9114  format(' **NOTE** These procedures are for stations using ',
     .'the PC Field System and a VLBA backend.')
      open(unit=LU_OUTFILE,file=PRCNAME,status=stat,iostat=IERR)
      IF (IERR.eq.0) THEN
        call initf(LU_OUTFILE,IERR)
        rewind(LU_OUTFILE)
      ELSE
        WRITE(LUSCN,9131) IERR,PRCNAME(1:IC)
9131    FORMAT(' SNAP02 - Error ',I6,' creating file ',A)
        return
      END IF
C
C Now create procedures

      DO ICODE=1,NCODES !loop on codes
	  DO IPASS=1,NPASSF(ICODE) !loop on number of passes
	    CALL IFILL(LNAMEP,1,12,Z20)
            IDUMMY = ICHMV(LNAMEP,1,LCODE(ICODE),1,2)
            NCH = 3
	    IF (JCHAR(LCODE(ICODE),2).EQ.Z20) NCH=2
            CALL M3INF(ICODE,SPDIPS,IB)
            NCH=ICHMV(LNAMEP,NCH,LB,IB,1)
            NCH=ICHMV(LNAMEP,NCH,LMODE(ICODE),1,1)
            NCH=ICHMV(LNAMEP,NCH,LPASS,IPASS,1)
            CALL CRPRC(LU_OUTFILE,LNAMEP)
            WRITE(LUSCN,9112) LNAMEP
9112        FORMAT(' PROCEDURE ',6A2)
C
C 2. Write out the following lines:

C  FORM=m,r   (m=mode,r=rate=2*b)
            call ifill(ibuf,1,ibuflen,z20)
	    nch = ichmv_ch(IBUF,1,'FORM=')
	    nch = ICHMV(IBUF,nch,lmode(icode),1,1)
	    nch = MCOMA(IBUF,nch)
	    nch = nch+IR2AS(VCBAND(ICODE)*2.0,IBUF,nch,5,3)
	    CALL writf_asc(LU_OUTFILE,IERR,IBUF,(nch+1)/2)
	    CALL INC(LU_OUTFILE,IERR)
C  !*
            call ifill(ibuf,1,ibuflen,z20)
            nch = ichmv_ch(ibuf,1,'!*')
	    CALL writf_asc(LU_OUTFILE,IERR,IBUF,(nch+1)/2)
	    CALL INC(LU_OUTFILE,IERR)
C  TAPEFORMm
            call ifill(ibuf,1,ibuflen,z20)
            nch = ichmv_ch(ibuf,1,'TAPEFORM')
	    nch = ICHMV(IBUF,nch,lmode(icode),1,1)
	    CALL writf_asc(LU_OUTFILE,IERR,IBUF,(nch+1)/2)
	    CALL INC(LU_OUTFILE,IERR)
C  PASS=$
            call ifill(ibuf,1,ibuflen,z20)
            IDUMMY = ichmv_ch(IBUF,1,'PASS=$')
            CALL writf_asc(LU_OUTFILE,IERR,IBUF,(12)/2)
            CALL INC(LU_OUTFILE,IERR)
C  BBCffb   
            call ifill(ibuf,1,ibuflen,z20)
	    nch = ichmv_ch(IBUF,1,'BBC')
            nch = ichmv(ibuf,nch,lcode(icode),1,2)
            iband=vcband(icode)
            nch = nch+ib2as(iband,ibuf,nch,1)
	    CALL writf_asc(LU_OUTFILE,IERR,IBUF,(nch+1)/2)
	    CALL INC(LU_OUTFILE,IERR)
C  IFDffb
            call ifill(ibuf,1,ibuflen,z20)
	    IDUMMY = ichmv_ch(IBUF,1,'IFD')
	    IDUMMY = ICHMV(IBUF,4,LCODE(ICODE),1,2)
	    CALL writf_asc(LU_OUTFILE,IERR,IBUF,(nch+1)/2)
	    CALL INC(LU_OUTFILE,IERR)
C  TAPE=LOW
            call ifill(ibuf,1,ibuflen,z20)
	    IDUMMY = ichmv_ch(IBUF,1,'TAPE=LOW')
	    CALL writf_asc(LU_OUTFILE,IERR,IBUF,(8)/2)
	    CALL INC(LU_OUTFILE,IERR)
C  ENABLE=tracks   (groups only)
            call ifill(ibuf,1,ibuflen,z20)
	    NCH = ichmv_ch(IBUF,1,'ENABLE=')
	    LTRK(1) = LTRAKS(1,IPASS,ICODE)
	    LTRK(2) = LTRAKS(2,IPASS,ICODE)
	    LG1 = 0
C
	    IF (KBIT(LTRK,1).AND.
     .        KBIT(LTRK,3).AND.
     .        KBIT(LTRK,5).AND.
     .        KBIT(LTRK,7).AND.
     .        KBIT(LTRK,9).AND.
     .        KBIT(LTRK,11).AND.
     .        KBIT(LTRK,13)) CALL CHAR2HOL('G1',LG1,1,2)
	    LG2 = 0
	    IF (KBIT(LTRK,2).AND.
     .        KBIT(LTRK,4).AND.
     .        KBIT(LTRK,6).AND.
     .        KBIT(LTRK,8).AND.
     .        KBIT(LTRK,10).AND.
     .        KBIT(LTRK,12).AND.
     .        KBIT(LTRK,14)) CALL CHAR2HOL('G2',LG2,1,2)
	    LG3 = 0
C
	    IF (KBIT(LTRK,15).AND.
     .        KBIT(LTRK,17).AND.
     .        KBIT(LTRK,19).AND.
     .        KBIT(LTRK,21).AND.
     .        KBIT(LTRK,23).AND.
     .        KBIT(LTRK,25).AND.
     .        KBIT(LTRK,27)) CALL CHAR2HOL('G3',LG3,1,2)
	    LG4 = 0
	    IF (KBIT(LTRK,16).AND.
     .        KBIT(LTRK,18).AND.
     .        KBIT(LTRK,20).AND.
     .        KBIT(LTRK,22).AND.
     .        KBIT(LTRK,24).AND.
     .        KBIT(LTRK,26).AND.
     .        KBIT(LTRK,28)) CALL CHAR2HOL('G4',LG4,1,2)
C
	    IF (LG1.NE.0) THEN
C THEN BEGIN "write group and turn off bits"
		NCH = ichmv_ch(IBUF,NCH,'G1,')
		DO IT=1,13,2
		  CALL SBIT(LTRK,IT,0)
		ENDDO
C ENDT "write group and turn off bits"
	    ENDIF
C
	    IF (LG2.NE.0) THEN
C THEN BEGIN "write group and turn off bits"
		NCH = ichmv_ch(IBUF,NCH,'G2,')
		DO IT=2,14,2
		  CALL SBIT(LTRK,IT,0)
		ENDDO
C ENDT "write group and turn off bits"
	    ENDIF
C
	    IF (LG3.NE.0) THEN
C THEN BEGIN "write group and turn off bits"
		NCH = ichmv_ch(IBUF,NCH,'G3,')
		DO IT=15,27,2
		  CALL SBIT(LTRK,IT,0)
		ENDDO
C           ENDT "write group and turn off bits"
	    ENDIF
C
	    IF (LG4.NE.0) THEN
C THEN BEGIN "write group and turn off bits"
		NCH = ichmv_ch(IBUF,NCH,'G4,')
		DO IT=16,28,2
		  CALL SBIT(LTRK,IT,0)
		ENDDO
C           ENDT "write group and turn off bits"
	    ENDIF
C
	    NCH = NCH-1
	    CALL IFILL(IBUF,NCH,1,Z20)
	    CALL writf_asc(LU_OUTFILE,IERR,IBUF,(NCH)/2)
	    CALL INC(LU_OUTFILE,IERR)
	    CALL writf_asc_ch(LU_OUTFILE,IERR,'ENDDEF')
	    CALL INC(LU_OUTFILE,IERR)
C ENDF "loop on number of passes"
	  ENDDO
C
C 3. Write out the baseband converter frequency procedure.
C Name is BBCffb      (ff=code,b=bandwidth)
C Contents: BBCnn=freq,band,band
	  CALL IFILL(LNAMEP,1,12,Z20)
	  nch = ichmv_ch(LNAMEP,1,'BBC')
	  nch = ICHMV(LNAMEP,nch,LCODE(ICODE),1,2)
          nch = nch+ib2as(iband,lnamep,nch,1)
	  CALL CRPRC(LU_OUTFILE,LNAMEP)
          WRITE(LUSCN,9112) LNAMEP
C
	  DO IVCN=1,14 !loop on BBCs
          IF (FREQRF(IVCN,ICODE).NE.0.0)  THEN
            call ifill(ibuf,1,ibuflen,z20)
		ILO = 1
		IF (JCHAR(LSGINP(2,ICODE),1).EQ.
     .          JCHAR(LSUBVC(IVCN,ICODE),1)) ILO=2
		DRF = FREQRF(IVCN,ICODE)
		DLO = FREQLO(ILO,ISTN,ICODE)
		IF (DLO.EQ.0.D0)  THEN
		  WRITE(LUSCN,9301) st,(lstnna(i,istn),i=1,4),st,
     .            st,(lnamep(i),i=1,3),st
9301          FORMAT(/A10,'LO INFO IS MISSING FROM $CODES SECTION',
     .          ' for ',4a2,a9/,
     .               A9,'PROCEDURE FILE DOES NOT CONTAIN '3a2,A9/)
		   CLOSE(LU_OUTFILE,IOSTAT=IERR)
		   RETURN
		ENDIF
C
		DFVC = DRF-DLO   ! BBCfreq = RFfreq - LOfreq
                if (dabs(dfvc).gt.1000.0) DFVC=DRF-freqlo(3,istn,icode)
		rFVC = DFVC
		rFVC = ABS(rFVC)
                nch = ichmv_ch(ibuf,1,'BBC')
		nch = ichmv(ibuf,nch,LVCN(IVCN),1,2)
		nch = ichmv_ch(IBUF,nch,'=')
		NCH = nch + IR2AS(rFVC,IBUF,nch,6,2)
		NCH = MCOMA(IBUF,NCH)
                if (ichcm_ch(lcode(icode),1,'WB').eq.0) then
                  nch = ichmv(ibuf,nch,lpwb,ivcn,1)
                else if (ichcm_ch(lcode(icode),1,'NW').eq.0) then
                  nch = ichmv(ibuf,nch,lpwb,ivcn,1)
                else if (ichcm_ch(lcode(icode),1,'SX').eq.0) then
                  nch = ichmv(ibuf,nch,lpsx,ivcn,1)
                else if (ichcm_ch(lcode(icode),1,'AS').eq.0) then
                  nch = ichmv(ibuf,nch,lpsx,ivcn,1)
                else
                  nch = ichmv(ibuf,nch,lpsx,ivcn,1)
                endif
		NCH = MCOMA(IBUF,NCH)
		NCH = NCH + IR2AS(VCBAND(ICODE),IBUF,NCH,5,3)
		NCH = MCOMA(IBUF,NCH)
		NCH = NCH + IR2AS(VCBAND(ICODE),IBUF,NCH,5,3)
		CALL writf_asc(LU_OUTFILE,IERR,IBUF,(NCH+1)/2)
		CALL INC(LU_OUTFILE,IERR)
	    ENDIF
C ENDF "loop on VCs"
	  ENDDO
C
C 4. Write out the IF distributor setup procedure.
C   IFD=0,0,nor,nor
C   LO=lo1,lo2,lo3
C **NOTE** Do not do this one now, LO info not sufficient.
	  CALL IFILL(LNAMEP,1,12,Z20)
	  IDUMMY = ichmv_ch(LNAMEP,1,'IFD')
	  IDUMMY = ICHMV(LNAMEP,4,LCODE(ICODE),1,2)
C         CALL CRPRC(LU_OUTFILE,LNAMEP)
C         WRITE(LUSCN,9112) LNAMEP
C
C
C ENDF "loop on codes"
	ENDDO
C
C 5. Finally, write out the procedures in the $PROC section.
C Read each line and if our station is mentioned, write out the proc.
      IF (IRECPR.NE.0)  THEN
C THEN BEGIN "procedures"
	  CALL READS(LU_INFILE,IERR,IBUF,ISKLEN,ILEN,2)
	  DO WHILE (IERR.GE.0.AND.ILEN.NE.-1.AND.JCHAR(IBUF,1).NE.Z24)
C DO BEGIN "read $PROC section"
          ICH = 1
          KUS=.FALSE.
          CALL GTFLD(IBUF,ICH,ILEN,IC1,IC2)
          DO I=IC1,IC2
            IF (JCHAR(IBUF,I).EQ.JCHAR(LSTCOD(ISTN),1)) KUS=.TRUE.
	    ENDDO
C
	    IF (KUS) THEN
C THEN BEGIN "a proc for us"
		CALL GTFLD(IBUF,ICH,ILEN,IC1,IC2)
		IF (IC1.NE.0) THEN
C THEN BEGIN "write proc file"
		  CALL IFILL(LNAMEP,1,12,Z20)
		  IDUMMY = ICHMV(LNAMEP,1,IBUF,IC1,MIN0(IC2-IC1+1,12))
		  CALL CRPRC(LU_OUTFILE,LNAMEP)
		  WRITE(LUSCN,9112) LNAMEP
		  CALL GTSNP(ICH,ILEN,IC1,IC2)
C
		  DO WHILE (IC1.NE.0)
C DO BEGIN "get and write commands"
		    NCH = ICHMV(IBUF2,1,IBUF,IC1,IC2-IC1+1)
		    CALL IFILL(IBUF2,NCH,1,Z20)
		    call writf_asc(LU_OUTFILE,IERR,IBUF2,(NCH)/2)
		    call inc(LU_OUTFILE,IERR)
		    CALL GTSNP(ICH,ILEN,IC1,IC2)
C ENDW "get and write commands"
		  ENDDO
C
		  CALL writf_asc_ch(LU_OUTFILE,IERR,'ENDDEF')
		  CALL INC(LU_OUTFILE,IERR)
C ENDT "write proc file"
		ENDIF
C ENDT "a proc for us"
	    ENDIF
          CALL READS(LU_INFILE,IERR,IBUF,ISKLEN,ILEN,2)
C         ENDW "read $PROC section"
	  ENDDO
C ENDT "procedures"
	ENDIF
	CLOSE(LU_OUTFILE,IOSTAT=IERR)
C
      RETURN
      END


	SUBROUTINE PROCS(iin)

C PROCS writes procedure file for the Field System.
C Version 9.0 is supported with this routine.

	INCLUDE 'skparm.ftni'
C
C History
C 930714  nrv  created,copied from procs
C 940308  nrv  Added a check for "NW" to make the correct BBC
C              IF input 
C 940620  nrv  In batch mode, always 'Y' for purging existing.
C 951213 nrv Modifications for new FS and new Mk4/VLBA setups.
C
C COMMON 
	INCLUDE 'freqs.ftni'
	INCLUDE 'drcom.ftni'
	INCLUDE 'statn.ftni'

C Input
      integer iin ! 1=mk3, 2=VLBA, 3=hybrid Mk3 rack+VLBA rec

C Called by: FDRUDG
C Calls: TRKALL

C LOCAL VARIABLES:
      integer*2 IBUF2(40) ! secondary buffer for writing files
      integer*2 lpmode(2) ! mode for procedure names
      integer*2 lfan(2) ! fan characters
      LOGICAL*4 KUS ! true if our station is listed for a procedure
      integer IC,ierr,i,idummy,nch,ipass,icode,it,ivcn,
     .iv,ict,ilen,ich,ic1,ic2,ibuflen,itrk(36),ig0,ig1,ig2,ig3,
     .npmode,itrk2(36),isb,ibit,ichan,ib,iden
      logical km3mode,kvlba,kmk3,khyb
      real*4 spdips
	CHARACTER UPPER
	CHARACTER*4 STAT
	CHARACTER*4 RESPONSE
	integer*2 LNAMEP(6)
	logical*4 ex
        logical kdone
      real*8 DRF,DLO,DFVC
      real*4 fvc(14),rfvc  !VC frequencies
      integer Z4000,Z100
      integer i1,i2,i3,i4
      integer ir2as,ib2as,mcoma,trimlen,jchar,ichmv ! functions
      integer ichcm_ch, ichmv_ch
      character*28 cpass,cvpass
      character*1 csb(2),cbit(2)
C
C INITIALIZED VARIABLES:
        data ibuflen/80/
      data Z4000/Z'4000'/,Z100/Z'100'/
      data cpass  /'123456789ABCDEFGHIJKLMNOPQRS'/
      data cvpass /'abcdefghijklmnopqrstuvwxyzAB'/
      data csb(1)/'u'/,csb(2)/'l'/,cbit(1)/'s'/,cbit(2)/'m'/
C
C  1. Create the file. Initialize

      if (kmissing) then
        write(luscn,9101)
9101    format(' PROCS00 - Missing or inconsistent head/track/pass',
     .  ' information.'/' Can''t make procedure library.')
        return
      endif
      kmk3=.false.
      kvlba=.false.
      khyb=.false.
      if (iin.eq.1) kmk3=.true.
      if (iin.eq.2) kvlba=.true.
      if (iin.eq.3) khyb=.true.

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
      if (kvlba) then
        WRITE(LUSCN,9113) PRCNAME(1:IC), (LSTNNA(I,ISTN),I=1,4)
9113    FORMAT(' VLBA PROCEDURE LIBRARY FILE ',A,' FOR ',4A2)
        write(luscn,9114) 
9114    format(' **NOTE** These procedures are for stations using '/
     .  ' the following software and backend equipment:'/
     .  '   >> PC Field System version 9.1 or above'/
     .  '   >> VLBA rack and recorder.')
      else if (kmk3) then
        WRITE(LUSCN,9115) PRCNAME(1:IC), (LSTNNA(I,ISTN),I=1,4)
9115    FORMAT(' Mark III PROCEDURE LIBRARY FILE ',A,' FOR ',4A2)
        write(luscn,9116) 
9116    format(' **NOTE** These procedures are for stations using '/
     .  ' the following software and backend equipment:'/
     .  '   >> PC Field System version 9.1 or above'/
     .  '   >> Mark III rack and recorder.')
      else if (khyb) then
        WRITE(LUSCN,9117) PRCNAME(1:IC), (LSTNNA(I,ISTN),I=1,4)
9117    FORMAT(' Mark III/VLBA PROCEDURE LIBRARY FILE ',A,' FOR ',4A2)
        write(luscn,9118) 
9118    format(' **NOTE** These procedures are for stations using '/
     .  ' the following software and backend equipment:'/
     .  '   >> PC Field System version 9.1 or above'/
     .  '   >> Mark III rack with a VLBA recorder.')
      endif

      open(unit=LU_OUTFILE,file=PRCNAME,status=stat,iostat=IERR)
      IF (IERR.eq.0) THEN
        call initf(LU_OUTFILE,IERR)
        rewind(LU_OUTFILE)
      ELSE
        WRITE(LUSCN,9131) IERR,PRCNAME(1:IC)
9131    FORMAT(' PROC02 - Error ',I6,' creating file ',A)
        return
      END IF
C
C 2. Set up the loop over all frequency codes, and the
C    inner loop over the number of passes.
C    Generate the procedure name, then write into proc file.
C    Get the track assignments first, and the mode name to use
C    for procedure names.

      DO ICODE=1,NCODES !loop on codes
        DO IPASS=1,NPASSF(istn,ICODE) !loop on number of sub passes

          call trkall(itras(1,1,1,ipass,istn,icode),lmode(1,istn,icode),
     .    itrk,lpmode,npmode,lfan)
          km3mode=jchar(lpmode,1).eq.ocapa.or.jchar(lpmode,1).eq.ocapb
     .        .or.jchar(lpmode,1).eq.ocapc.or.jchar(lpmode,1).eq.ocapd
     .        .or.jchar(lpmode,1).eq.ocape

          CALL IFILL(LNAMEP,1,12,oblank)
          IDUMMY = ICHMV(LNAMEP,1,LCODE(ICODE),1,2)
          NCH = 3 ! next character in the name
          IF (JCHAR(LCODE(ICODE),2).EQ.oblank) NCH=2
          CALL M3INF(ICODE,SPDIPS,IB)
C choices in LBNAME are D,8,4,2,1,H,Q,E
          NCH=ICHMV(LNAMEP,NCH,LBNAME,IB,1)
          NCH=ICHMV(LNAMEP,NCH,Lpmode,1,npmode)
C Convert pass index to integer or alpha
          if (jchar(lpmode,1).eq.ocapv) then
            NCH=ICHMV_ch(LNAMEP,NCH,cvPASS(IPASS:ipass))
          else
            NCH=ICHMV_ch(LNAMEP,NCH,cPASS(IPASS:ipass))
          endif      
          CALL CRPRC(LU_OUTFILE,LNAMEP)
          WRITE(LUSCN,9112) LNAMEP
9112      FORMAT(' PROCEDURE ',6A2)
C
C 3. Write out the following lines in the setup procedure:

C  TAPEFORMm
          call ifill(ibuf,1,ibuflen,oblank)
          nch = ichmv_ch(IBUF,1,'TAPEFORM')
          nch = ichmv(ibuf,nch,lpmode,1,npmode)
          call hol2lower(ibuf,(nch+1))
          CALL writf_asc(LU_OUTFILE,IERR,IBUF,(nch+1)/2)
C  PASS=$
          call ifill(ibuf,1,ibuflen,oblank)
          nch = ichmv_ch(IBUF,1,'PASS=$')
          if (kmk3) nch = ichmv_ch(ibuf,nch,',SAME') ! 2 heads on Mk3 recorders
          call hol2lower(ibuf,(nch+1))
          CALL writf_asc(LU_OUTFILE,IERR,IBUF,(nch+1)/2)
C  TRKFRMm
          if (kvlba.and..not.km3mode) then
            call ifill(ibuf,1,ibuflen,oblank)
            nch = ichmv_ch(IBUF,1,'TRKFRM')
            nch = ichmv(ibuf,nch,lpmode,1,npmode)
            call hol2lower(ibuf,(nch+1))
            CALL writf_asc(LU_OUTFILE,IERR,IBUF,(nch+1)/2)
          endif
C  TRACKS=tracks   
          if (kvlba.and..not.km3mode) then
            call ifill(ibuf,1,ibuflen,oblank)
            NCH = ichmv_ch(IBUF,1,'TRACKS=')
            ig0=0
            ig1=0
            ig2=0
            ig3=0
            if (itrk(2).eq.1.and.itrk(4).eq.1.and.itrk(6).eq.1.and.
     .          itrk(8).eq.1.and.itrk(10).eq.1.and.itrk(12).eq.1.and.
     .          itrk(14).eq.1.and.itrk(16).eq.1) ig0=1
            if (itrk(3).eq.1.and.itrk(5).eq.1.and.itrk(7).eq.1.and.
     .          itrk(9).eq.1.and.itrk(11).eq.1.and.itrk(13).eq.1.and.
     .          itrk(15).eq.1.and.itrk(17).eq.1) ig1=1
            if (itrk(18).eq.1.and.itrk(20).eq.1.and.itrk(22).eq.1.and.
     .          itrk(24).eq.1.and.itrk(26).eq.1.and.itrk(28).eq.1.and.
     .          itrk(30).eq.1.and.itrk(32).eq.1) ig2=1
            if (itrk(19).eq.1.and.itrk(21).eq.1.and.itrk(23).eq.1.and.
     .          itrk(25).eq.1.and.itrk(27).eq.1.and.itrk(29).eq.1.and.
     .          itrk(31).eq.1.and.itrk(33).eq.1) ig3=1
C         Write out the group names we have found. Zero out these
C         track names in a copy of the track table. Then list any
C         tracks still left in the table.
            do i=1,36
              itrk2(i)=itrk(i)
            enddo
            if (ig0.eq.1) then
              nch = ichmv_ch(ibuf,nch,'D0,')
              do i=2,16,2
                itrk2(i)=0
              enddo
            endif
            if (ig1.eq.1) then
              nch = ichmv_ch(ibuf,nch,'D1,')
              do i=3,17,2
                itrk2(i)=0
              enddo
            endif
            if (ig2.eq.1) then
              nch = ichmv_ch(ibuf,nch,'D2,')
              do i=18,32,2
                itrk2(i)=0
              enddo
            endif
            if (ig3.eq.1) then
              nch = ichmv_ch(ibuf,nch,'D3,')
              do i=19,33,2
                itrk2(i)=0
              enddo
            endif
            do i=2,33 ! pick up leftover tracks not in a whole group
              if (itrk2(i).eq.1) then
                nch = nch + ib2as(i,ibuf,nch,Z100+2)
                nch = MCOMA(IBUF,nch)
              endif
            enddo ! pick up leftover tracks
            NCH = NCH-1
            CALL IFILL(IBUF,NCH,1,oblank)
            call hol2lower(ibuf,(nch+1))
            CALL writf_asc(LU_OUTFILE,IERR,IBUF,(NCH+1)/2)
          endif
C  FORM=m,r,fan,barrel   (m=mode,r=rate=2*b)
          call ifill(ibuf,1,ibuflen,oblank)
          nch = ichmv_ch(IBUF,1,'FORM=')
	  IF (ichcm_ch(lmode(1,istn,icode),1,'E').eq.0) THEN 
C                  !MODE E = B ON ODD, C ON EVEN PASSES
            IF (MOD(IPASS,2).EQ.0) THEN
              nch = ichmv_ch(ibuf,nch,'C')
            ELSE
              nch = ichmv_ch(ibuf,nch,'B')
            ENDIF
          else ! not mode E
            nch = ICHMV(IBUF,nch,lmode(1,istn,icode),1,1)
	  ENDIF
          nch = MCOMA(IBUF,nch)
          nch = nch+IR2AS(VCBAND(1,istn,ICODE)*2.0,IBUF,nch,5,3)
          if (kvlba) then
            if (.not.(ichcm_ch(lfan,1,'    ').eq.0.and.
     .         (ichcm_ch(lbarrel,1,'    ').eq.0.or.
     .          ichcm_ch(lbarrel,1,'NONE').eq.0.or.
     .          ichcm_ch(lbarrel,1,'OFF ').eq.0))) then ! fan or barrel
            nch = MCOMA(IBUF,nch)
            if (ichcm_ch(lfan,1,'    ').ne.0) then ! a fan mode
              nch = ichmv(ibuf,nch,lfan,1,3)
            endif
            nch = MCOMA(IBUF,nch)
            if (.not.(ichcm_ch(lbarrel,1,'    ').eq.0.or.
     .          ichcm_ch(lbarrel,1,'NONE').eq.0.or.
     .          ichcm_ch(lbarrel,1,'OFF ').eq.0)) then ! a roll mode
              nch = ichmv(ibuf,nch,lbarrel,1,4)
            endif
            endif
          endif
          call hol2lower(ibuf,(nch+1))
          CALL writf_asc(LU_OUTFILE,IERR,IBUF,(nch+1)/2)
          if (kmk3.or.khyb) then ! form=reset
            call ifill(ibuf,1,ibuflen,oblank)
            nch = ichmv_ch(IBUF,1,'FORM=RESET')
            call hol2lower(ibuf,(nch+1))
            CALL writf_asc(LU_OUTFILE,IERR,IBUF,(nch+1)/2)
          endif
C  !*
          if (kvlba) then
            call ifill(ibuf,1,ibuflen,oblank)
            nch = ichmv_ch(ibuf,1,'!*')
            call hol2lower(ibuf,(nch+1))
            CALL writf_asc(LU_OUTFILE,IERR,IBUF,(nch+1)/2)
          endif
C  bit_density=<value>
          if (kvlba.or.khyb) then
            call ifill(ibuf,1,ibuflen,oblank)
            nch = ichmv_ch(IBUF,1,'bit_density=')
            if (bitdens(istn).gt.1000) then ! valid number
              iden=bitdens(istn)
              nch = nch + ib2as(iden,ibuf,nch,5)
            else ! use default
              nch = ichmv_ch(ibuf,nch,'33333')
            endif
            call hol2lower(ibuf,(nch+1))
            CALL writf_asc(LU_OUTFILE,IERR,IBUF,(nch+1)/2)
          endif
C  SYSTRACKS=0,1,34,35
          if (kvlba.or.khyb) then ! for all VLBA recorders
            call ifill(ibuf,1,ibuflen,oblank)
            nch = ichmv_ch(IBUF,1,'SYSTRACKS=')
            call hol2lower(ibuf,(nch+1))
            CALL writf_asc(LU_OUTFILE,IERR,IBUF,(nch+1)/2)
          endif
C  BBCffb   
          call ifill(ibuf,1,ibuflen,oblank)
          if (kvlba) nch = ichmv_ch(IBUF,1,'BBC')
          if (kmk3.or.khyb) nch = ichmv_ch(IBUF,1,'VC')
          nch = ichmv(ibuf,nch,lcode(icode),1,2)
          CALL M3INF(ICODE,SPDIPS,IB)
          NCH=ICHMV(ibuf,NCH,LBNAME,IB,1)
          call hol2lower(ibuf,(nch+1))
          CALL writf_asc(LU_OUTFILE,IERR,IBUF,(nch+1)/2)
C  IFDff
          call ifill(ibuf,1,ibuflen,oblank)
          nch = ichmv_ch(IBUF,1,'IFD')
          nch = ICHMV(IBUF,nch,LCODE(ICODE),1,2)
          call hol2lower(ibuf,(nch+1))
          CALL writf_asc(LU_OUTFILE,IERR,IBUF,(nch+1)/2)
C  TAPE=LOW
          call ifill(ibuf,1,ibuflen,oblank)
          nch = ichmv_ch(IBUF,1,'TAPE=LOW')
          call hol2lower(ibuf,(nch+1))
          CALL writf_asc(LU_OUTFILE,IERR,IBUF,(nch+1)/2)
C  ENABLE=tracks 
          call ifill(ibuf,1,ibuflen,oblank)
          NCH = ichmv_ch(IBUF,1,'ENABLE=')
          if (kvlba.or.khyb) then ! group-only enables for VLBA recorders
            if (itrk(2).eq.1.or.itrk(4).eq.1.or.itrk(6).eq.1.or.
     .          itrk(8).eq.1.or.itrk(10).eq.1.or.itrk(12).eq.1.or.
     .          itrk(14).eq.1.or.itrk(16).eq.1) then
              ig0=1
              nch = ichmv_ch(ibuf,nch,'G0')
              nch = MCOMA(IBUF,nch)
            endif
            if (itrk(3).eq.1.or.itrk(5).eq.1.or.itrk(7).eq.1.or.
     .          itrk(9).eq.1.or.itrk(11).eq.1.or.itrk(13).eq.1.or.
     .          itrk(15).eq.1.or.itrk(17).eq.1) then
              ig1=1
              nch = ichmv_ch(ibuf,nch,'G1')
              nch = MCOMA(IBUF,nch)
            endif
            if (itrk(18).eq.1.or.itrk(20).eq.1.or.itrk(22).eq.1.or.
     .          itrk(24).eq.1.or.itrk(26).eq.1.or.itrk(28).eq.1.or.
     .          itrk(30).eq.1.or.itrk(32).eq.1) then
              ig2=1
              nch = ichmv_ch(ibuf,nch,'G2')
              nch = MCOMA(IBUF,nch)
            endif
            if (itrk(19).eq.1.or.itrk(21).eq.1.or.itrk(23).eq.1.or.
     .          itrk(25).eq.1.or.itrk(27).eq.1.or.itrk(29).eq.1.or.
     .          itrk(31).eq.1.or.itrk(33).eq.1) then
              ig3=1
              nch = ichmv_ch(ibuf,nch,'G3')
              nch = MCOMA(IBUF,nch)
            endif
          else if (kmk3) then ! group enables plus leftovers
            if (itrk(4).eq.1.and.itrk(6).eq.1.and.itrk(8).eq.1.and.
     .          itrk(10).eq.1.and.itrk(12).eq.1.and.
     .          itrk(14).eq.1.and.itrk(16).eq.1) then
              ig0=1
              nch = ichmv_ch(ibuf,nch,'G1')
              nch = MCOMA(IBUF,nch)
            endif
            if (itrk(5).eq.1.and.itrk(7).eq.1.and.
     .          itrk(9).eq.1.and.itrk(11).eq.1.and.itrk(13).eq.1.and.
     .          itrk(15).eq.1.and.itrk(17).eq.1) then
              ig1=1
              nch = ichmv_ch(ibuf,nch,'G2')
              nch = MCOMA(IBUF,nch)
            endif
            if (itrk(18).eq.1.and.itrk(20).eq.1.and.itrk(22).eq.1.and.
     .          itrk(24).eq.1.and.itrk(26).eq.1.and.itrk(28).eq.1.and.
     .          itrk(30).eq.1) then
              ig2=1
              nch = ichmv_ch(ibuf,nch,'G3')
              nch = MCOMA(IBUF,nch)
            endif
            if (itrk(19).eq.1.and.itrk(21).eq.1.and.itrk(23).eq.1.and.
     .          itrk(25).eq.1.and.itrk(27).eq.1.and.itrk(29).eq.1.and.
     .          itrk(31).eq.1) then
              ig3=1
              nch = ichmv_ch(ibuf,nch,'G4')
              nch = MCOMA(IBUF,nch)
            endif
C         Write out the group names we have found. Zero out these
C         track names in a copy of the track table. Then list any
C         tracks still left in the table.
            do i=1,36
              itrk2(i)=itrk(i)
            enddo
            if (ig0.eq.1) then
              do i=4,16,2
                itrk2(i)=0
              enddo
            endif
            if (ig1.eq.1) then
              do i=5,17,2
                itrk2(i)=0
              enddo
            endif
            if (ig2.eq.1) then
              do i=18,30,2
                itrk2(i)=0
              enddo
            endif
            if (ig3.eq.1) then
              do i=19,31,2
                itrk2(i)=0
              enddo
            endif
            do i=4,31 ! pick up leftover tracks not in a whole group
              if (itrk2(i).eq.1) then ! Mark3 numbering
                nch = nch + ib2as(i-3,ibuf,nch,Z4000+2*Z100+2)
                nch = MCOMA(IBUF,nch)
              endif
            enddo ! pick up leftover tracks
          endif
          NCH = NCH-1
          CALL IFILL(IBUF,NCH,1,oblank)
          call hol2lower(ibuf,(nch+1))
          CALL writf_asc(LU_OUTFILE,IERR,IBUF,(NCH+1)/2)
C REPRO=byp,3,5
          IF ((kvlba.and.MOD(IPASS,2).EQ.0) .or.
     .        (kmk3 .and.MOD(IPASS,2).EQ.1)) THEN ! even pass
            call ifill(ibuf,1,ibuflen,oblank)
            nch = ichmv_ch(IBUF,1,'repro=byp,7,9')
            call hol2lower(ibuf,(nch+1))
            CALL writf_asc(LU_OUTFILE,IERR,IBUF,(nch+1)/2)
          else ! odd pass
            call ifill(ibuf,1,ibuflen,oblank)
            nch = ichmv_ch(IBUF,1,'repro=byp,6,8')
            call hol2lower(ibuf,(nch+1))
            CALL writf_asc(LU_OUTFILE,IERR,IBUF,(nch+1)/2)
          endif
C !*+8s
          if (kvlba) then
            call ifill(ibuf,1,ibuflen,oblank)
            nch = ichmv_ch(IBUF,1,'!*+8s')
            call hol2lower(ibuf,(nch+1))
            CALL writf_asc(LU_OUTFILE,IERR,IBUF,(nch+1)/2)
          endif
C ENDDEF
          CALL writf_asc_ch(LU_OUTFILE,IERR,'enddef')

        ENDDO ! loop on number of passes
C
C 3. Write out the baseband converter frequency procedure.
C Name is VCffb or BBCffb      (ff=code,b=bandwidth)
C Contents: VCnn=freq,bw or BBCnn=freq,if,bw,bw
        CALL IFILL(LNAMEP,1,12,oblank)
        if (kvlba) nch = ichmv_ch(LNAMEP,1,'BBC')
        if (kmk3.or.khyb) nch = ichmv_ch(LNAMEP,1,'VC')
        nch = ICHMV(LNAMEP,nch,LCODE(ICODE),1,2)
        CALL M3INF(ICODE,SPDIPS,IB)
        NCH=ICHMV(LNAMEP,NCH,LBNAME,IB,1)
	CALL CRPRC(LU_OUTFILE,LNAMEP)
        WRITE(LUSCN,9112) LNAMEP
C
        if (freqlo(1,istn,icode).lt.0.05) then ! missing LO
          write(luscn,9910)
9910      format(' PROC02 - WARNING! LO frequencies are missing!'/
     .    '   BBC or VC frequency procedure will ',
     .    'not be correct, nor will IFD procedure.') 
        endif
        DO IVCN=1,nvcs(istn,icode) !loop on channels
          call ifill(ibuf,1,ibuflen,oblank)
      	  DRF = FREQRF(IVCN,istn,ICODE)
          DLO = FREQLO(ivcn,ISTN,ICODE)
          DFVC = DRF-DLO   ! BBCfreq = RFfreq - LOfreq
          rFVC = DFVC
          rFVC = ABS(rFVC)
          fvc(ivcn) = rfvc
          if (kvlba) nch = ichmv_ch(ibuf,1,'BBC')
          if (kmk3.or.khyb) nch = ichmv_ch(ibuf,1,'VC')
          nch = nch + ib2as(ivcn,ibuf,nch,Z4000+2*Z100+2)
          nch = ichmv_ch(IBUF,nch,'=')
          NCH = nch + IR2AS(rFVC,IBUF,nch,6,2)
C         if (.not.(
C    .        (kmk3.and.(ichcm_ch(lifinp(ivcn,istn,icode),1,'1N').eq.0
C    .         .or.
C    .      ichcm_ch(lifinp(ivcn,istn,icode),1,'2N').eq.0.or.
C    .      ichcm_ch(lifinp(ivcn,istn,icode),1,'3N').eq.0.or.
C    .      ichcm_ch(lifinp(ivcn,istn,icode),1,'1A').eq.0.or.
C    .      ichcm_ch(lifinp(ivcn,istn,icode),1,'2A').eq.0.or.
C    .      ichcm_ch(lifinp(ivcn,istn,icode),1,'3A').eq.0))
C    .    or (kvlba.and.(ichcm_ch(lifinp(ivcn,istn,icode),1,'A').eq.0
C    .           .or.
C    .      ichcm_ch(lifinp(ivcn,istn,icode),1,'B').eq.0.or.
C    .      ichcm_ch(lifinp(ivcn,istn,icode),1,'C').eq.0.or.
C    .      ichcm_ch(lifinp(ivcn,istn,icode),1,'D').eq.0)))) then
C           write(luscn,9909) lifinp(i,istn,icode)
C909        format(' PROC04 - WARNING! IF input of ',a2,' is not',
C    .      ' consistent with these procedures.')
C         endif
          if (kvlba.and.(rfvc.lt.500.0.or.rfvc.gt.1000.0)) then
            write(luscn,9911) ivcn,rfvc
9911        format(' PROC03 - WARNING! BBC ',i2,' frequency '
     .      f7.2,' is out of range. Check LO frequencies.')
          else if ((kmk3.or.khyb).and.(rfvc.lt.0.0.or.rfvc.gt.500.0))
     .      then
            write(luscn,9912) ivcn,rfvc
9912        format(' PROC03 - WARNING! VC ',i2,' frequency '
     .      f7.2,' is out of range. Check LO frequencies.')
          endif
          if (kvlba) then
            NCH = MCOMA(IBUF,NCH)
            nch = ichmv(ibuf,nch,lifinp(ivcn,istn,icode),1,1)
          endif
          NCH = MCOMA(IBUF,NCH)
          NCH = NCH + IR2AS(VCBAND(ivcn,istn,ICODE),IBUF,NCH,5,3)
          if (kvlba) then
            NCH = MCOMA(IBUF,NCH)
            NCH = NCH + IR2AS(VCBAND(ivcn,istn,ICODE),IBUF,NCH,5,3)
          endif
          call hol2lower(ibuf,nch+1)
          CALL writf_asc(LU_OUTFILE,IERR,IBUF,(NCH+1)/2)
        ENDDO !loop on channels
        if (kmk3.or.khyb) then
          call ifill(ibuf,1,ibuflen,oblank)
          nch = ichmv_ch(ibuf,1,'!+1s')
          CALL writf_asc(LU_OUTFILE,IERR,IBUF,(NCH+1)/2)
          call ifill(ibuf,1,ibuflen,oblank)
          nch = ichmv_ch(ibuf,1,'valarm')
          CALL writf_asc(LU_OUTFILE,IERR,IBUF,(NCH+1)/2)
        endif
        CALL writf_asc_ch(LU_OUTFILE,IERR,'enddef')
C
C 4. Write out the IF distributor setup procedure.
C    for VLBA:  IFD=0,0,nor,nor
C               LO=lo1,lo2,lo3
C    for Mk3:   ifd=atn1,atn2,nor/alt,nor/alt
C               if3=atn3,out,1 (in for WB)
C               lo=lo1,lo2,lo3
C               patch=...
        CALL IFILL(LNAMEP,1,12,oblank)
        IDUMMY = ichmv_ch(LNAMEP,1,'IFD')
        IDUMMY = ICHMV(LNAMEP,4,LCODE(ICODE),1,2)
        CALL CRPRC(LU_OUTFILE,LNAMEP)
        WRITE(LUSCN,9112) LNAMEP
C
        if (kmk3.or.khyb) then
          call ifill(ibuf,1,ibuflen,oblank)
	  NCH = ichmv_ch(IBUF,1,'IFD=')
          i1=0
          i2=0
          i3=0
          do i=1,nvcs(istn,icode)
            if (i1.eq.0.and.ichcm_ch(lifinp(i,istn,icode),1,'1').eq.0) 
     .          i1=i
            if (i2.eq.0.and.ichcm_ch(lifinp(i,istn,icode),1,'2')
     .        .eq.0) i2=i
            if (i3.eq.0.and.ichcm_ch(lifinp(i,istn,icode),1,'3')
     .        .eq.0) i3=i
          enddo
          NCH = ichmv_ch(IBUF,NCH,'atn1,atn2,')
          if (i1.ne.0) then
	    IF (ichcm_ch(lifinp(i1,istn,ICODE),2,'N').EQ.0) then
              NCH = ichmv_ch(IBUF,NCH,'NOR,')
            ELSE
	      NCH = ichmv_ch(IBUF,NCH,'ALT,')
            ENDIF
          else
            nch = ichmv_ch(ibuf,nch,',')
          endif
          if (i2.ne.0) then
	    IF (ichcm_ch(lifinp(i2,istn,ICODE),2,'N').EQ.0)   THEN
	      NCH = ichmv_ch(IBUF,NCH,'NOR')
            ELSE
	      NCH = ichmv_ch(IBUF,NCH,'ALT')
	    ENDIF
          else
            nch = ichmv_ch(ibuf,nch,',')
          endif
          call hol2lower(ibuf,nch)
	  CALL writf_asc(LU_OUTFILE,IERR,IBUF,(NCH+1)/2)
          call ifill(ibuf,1,ibuflen,oblank)
	  NCH = ichmv_ch(IBUF,1,'IF3=atn3,')
          if (i3.ne.0) then
            nch=ichmv_ch(ibuf,nch,'IN,1')
          else
            nch=ichmv_ch(ibuf,nch,'OUT,1')
          endif
          call hol2lower(ibuf,nch)
	  CALL writf_asc(LU_OUTFILE,IERR,IBUF,(NCH+1)/2)
C
          call ifill(ibuf,1,ibuflen,oblank)
	  NCH = ichmv_ch(IBUF,1,'LO=')
          if (i1.gt.0) then
            NCH = NCH+IR2AS(FREQLO(i1,ISTN,ICODE),IBUF,NCH,8,2)
          endif
          if (i2.gt.0) then
            NCH = MCOMA(IBUF,NCH)
            NCH = NCH+IR2AS(FREQLO(i2,ISTN,ICODE),IBUF,NCH,8,2)
          endif
          if (i3.gt.0) then
            NCH = MCOMA(IBUF,NCH)
            NCH = NCH+IR2AS(FREQLO(i3,ISTN,ICODE),IBUF,NCH,8,2)
          endif
          call hol2lower(ibuf,nch)
	  CALL writf_asc(LU_OUTFILE,IERR,IBUF,(NCH+1)/2)
C
	  DO I=1,2 ! two IFs
            call ifill(ibuf,1,ibuflen,oblank)
            NCH = ichmv_ch(IBUF,1,'PATCH=LO')
            NCH = NCH + IB2AS(I,IBUF,NCH,1)
            DO IV = 1,nvcs(istn,icode)
              if ((ichcm_ch(lifinp(iv,istn,icode),1,'1').eq.0.
     .              and.i.eq.1).or.
     .              (ichcm_ch(lifinp(iv,istn,icode),1,'2').eq.0.
     .              and.i.eq.2)) then ! correct LO
                ict=1
                if (iv.ge.10) ict=2
                NCH = MCOMA(IBUF,NCH)
                NCH = nch+IB2AS(IV,IBUF,NCH,ict)
                if (fvc(iv).lt.220.0) then !low
                  nch=ichmv_ch(ibuf,nch,'L')
                else
                  nch=ichmv_ch(ibuf,nch,'H')
                endif
              endif ! correct LO
	    ENDDO
            call hol2lower(ibuf,nch)
            CALL writf_asc(LU_OUTFILE,IERR,IBUF,((NCH+1))/2)
            CALL INC(LU_OUTFILE,IERR)
	  ENDDO ! two IFs
        endif ! mk3 or hyb
        if (kvlba) then 
          CALL IFILL(IBUF,1,ibuflen,oblank)
	  NCH = ichmv_ch(IBUF,1,'IFDAB=0,0,NOR,NOR')
          call hol2lower(ibuf,nch)
          CALL writf_asc(LU_OUTFILE,IERR,IBUF,(NCH+1)/2)
          call ifill(ibuf,1,ibuflen,oblank)
          NCH = ichmv_ch(IBUF,1,'IFDCD=0,0,NOR,NOR')
          call hol2lower(ibuf,nch)
          CALL writf_asc(LU_OUTFILE,IERR,IBUF,(NCH+1)/2)
C
          i1=0
          i2=0
          i3=0
          i4=0
          do i=1,nvcs(istn,icode)
            if (i1.eq.0.and.ichcm_ch(lifinp(i,istn,icode),1,'A').eq.0) 
     .          i1=i
            if (i2.eq.0.and.ichcm_ch(lifinp(i,istn,icode),1,'B')
     .        .eq.0) i2=i
            if (i3.eq.0.and.ichcm_ch(lifinp(i,istn,icode),1,'C')
     .        .eq.0) i3=i
            if (i4.eq.0.and.ichcm_ch(lifinp(i,istn,icode),1,'D')
     .        .eq.0) i4=i
          enddo
C
          call ifill(ibuf,1,ibuflen,oblank)
	  NCH = ichmv_ch(IBUF,1,'LO=')
          if (i1.gt.0) then 
            NCH = NCH+IR2AS(FREQLO(i1,ISTN,ICODE),IBUF,NCH,8,2)
            NCH = MCOMA(IBUF,NCH)
          endif
          if (i2.gt.0) then
            NCH = NCH+IR2AS(FREQLO(i2,ISTN,ICODE),IBUF,NCH,8,2)
            NCH = MCOMA(IBUF,NCH)
          endif
          if (i3.gt.0) then
            NCH = NCH+IR2AS(FREQLO(i3,ISTN,ICODE),IBUF,NCH,8,2)
            NCH = MCOMA(IBUF,NCH)
          endif
          if (i4.gt.0) then
            NCH = NCH+IR2AS(FREQLO(i4,ISTN,ICODE),IBUF,NCH,8,2)
            NCH = MCOMA(IBUF,NCH)
          endif
          nch=nch-1
          CALL IFILL(IBUF,NCH,1,oblank)
          call hol2lower(ibuf,nch)
	  CALL writf_asc(LU_OUTFILE,IERR,IBUF,(NCH+1)/2)
         endif ! vlba
        CALL writf_asc_ch(LU_OUTFILE,IERR,'enddef')
C

C 5. Write TAPEFORM procedure.
C    TAPEFORM=index,offset lists

      CALL IFILL(LNAMEP,1,12,oblank)
      nch = ichmv_ch(LNAMEP,1,'TAPEFORM')
      nch = ICHMV(LNAMEP,nch,lpmode,1,npmode)
      cALL CRPRC(LU_OUTFILE,LNAMEP)
      WRITE(LUSCN,9112) LNAMEP

      call ifill(ibuf,1,ibuflen,oblank)
      nch = ichmv_ch(ibuf,1,'TAPEFORM=')
      do i=1,max_pass*4
        if (ihdpos(i,istn,icode).ne.9999) then 
          nch = nch + ib2as(i,ibuf,nch,3) ! pass number
          nch = mcoma(ibuf,nch)
          nch = nch + ib2as(ihdpos(i,istn,icode),ibuf,nch,4) ! offset
          nch = mcoma(ibuf,nch)
          ib=1
        endif
        if (ib.gt.0.and.nch.gt.60) then ! write a line
          nch=nch-1
          CALL IFILL(IBUF,NCH,1,oblank)
          call hol2lower(ibuf,nch)
          call writf_asc(lu_outfile,ierr,ibuf,(nch+1)/2)
          call ifill(ibuf,1,ibuflen,oblank)
          nch = ichmv_ch(ibuf,1,'TAPEFORM=')
          ib=0
        endif
      enddo
      if (ib.gt.0) then ! finish last line
        nch=nch-1
        CALL IFILL(IBUF,NCH,1,oblank)
        call hol2lower(ibuf,nch)
        call writf_asc(lu_outfile,ierr,ibuf,(nch+1)/2)
      endif
      CALL writf_asc_ch(LU_OUTFILE,IERR,'enddef')
C
C 6. Write TRKFRM procedures, one per pass.
C    trkform=track,BBC#-sb-bit

      if (kvlba.and..not.km3mode) then
        DO IPASS=1,NPASSF(istn,ICODE) !loop on sub passes
        call trkall(itras(1,1,1,ipass,istn,icode),lmode(1,istn,icode),
     .  itrk,lpmode,npmode,lfan)

        CALL IFILL(LNAMEP,1,12,oblank)
        nch = ichmv_ch(LNAMEP,1,'TRKFRM')
        nch = ICHMV(LNAMEP,nch,lpmode,1,npmode)
        if (jchar(lpmode,1).eq.ocapv) then
          NCH=ICHMV_ch(LNAMEP,NCH,cvPASS(IPASS:ipass))
        else
          NCH=ICHMV_ch(LNAMEP,NCH,cPASS(IPASS:ipass))
        endif      
        CALL CRPRC(LU_OUTFILE,LNAMEP)
        WRITE(LUSCN,9112) LNAMEP

        call ifill(ibuf,1,ibuflen,oblank)
        nch = ichmv_ch(ibuf,1,'TRACKFORM=')
        do isb=1,2
          do ibit=1,2
            do ichan=1,nvcs(istn,icode)
              it=itras(isb,ibit,ichan,ipass,istn,icode)
              if (it.ne.-99) then
                nch = nch + ib2as(it+3,ibuf,nch,2)
                nch = mcoma(ibuf,nch)
                nch = nch + ib2as(ichan,ibuf,nch,2)
                nch = ichmv_ch(ibuf,nch,csb(isb))
                nch = ichmv_ch(ibuf,nch,cbit(ibit))
                nch = mcoma(ibuf,nch)
                ib=1
              endif
              if (ib.ne.0.and.nch.gt.60) then ! write a line
                nch=nch-1
                CALL IFILL(IBUF,NCH,1,oblank)
                call hol2lower(ibuf,nch)
                call writf_asc(lu_outfile,ierr,ibuf,(nch+1)/2)
                call ifill(ibuf,1,ibuflen,oblank)
                nch = ichmv_ch(ibuf,1,'TRACKFORM=')
                ib=0
              endif
            enddo ! channels
          enddo ! bits
        enddo ! sidebands
        if (ib.ne.0) then ! final line
          nch=nch-1
          CALL IFILL(IBUF,NCH,1,oblank)
          call hol2lower(ibuf,nch)
          call writf_asc(lu_outfile,ierr,ibuf,(nch+1)/2)
        endif
        CALL writf_asc_ch(LU_OUTFILE,IERR,'enddef')
      enddo ! loop on sub-passes
      endif 

      ENDDO ! loop on codes

C 6. Finally, write out the procedures in the $PROC section.
C Read each line and if our station is mentioned, write out the proc.
      IF (IRECPR.NE.0)  THEN
C THEN BEGIN "procedures"
	  CALL READS(LU_INFILE,IERR,IBUF,ISKLEN,ILEN,2)
	  DO WHILE (IERR.GE.0.AND.ILEN.NE.-1.AND.JCHAR(IBUF,1).NE.odollar)
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
		  CALL IFILL(LNAMEP,1,12,oblank)
		  IDUMMY = ICHMV(LNAMEP,1,IBUF,IC1,MIN0(IC2-IC1+1,12))
		  CALL CRPRC(LU_OUTFILE,LNAMEP)
		  WRITE(LUSCN,9112) LNAMEP
		  CALL GTSNP(ICH,ILEN,IC1,IC2)
C
		  DO WHILE (IC1.NE.0)
C DO BEGIN "get and write commands"
		    NCH = ICHMV(IBUF2,1,IBUF,IC1,IC2-IC1+1)
		    CALL IFILL(IBUF2,NCH,1,oblank)
		    call writf_asc(LU_OUTFILE,IERR,IBUF2,(NCH)/2)
		    CALL GTSNP(ICH,ILEN,IC1,IC2)
C ENDW "get and write commands"
		  ENDDO
C
		  CALL writf_asc_ch(LU_OUTFILE,IERR,'ENDDEF')
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


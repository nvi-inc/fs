      SUBROUTINE SNAPINTR(IFUNC,IYR)
C
C This routine writes out the header information for snap files and
C vlba pointing files in the LU_OUTFILE.
C
      include '../skdrincl/skparm.ftni'
      include 'drcom.ftni'
      include '../skdrincl/statn.ftni'
      include '../skdrincl/sourc.ftni'
      include '../skdrincl/freqs.ftni'
      include '../skdrincl/skobs.ftni'
C
C  INPUT:
      integer ifunc,IYR ! ifunc=1 for " comments, ifunc=2 for !* comments
      logical kk4,ks2
C
C  LOCAL:
      integer*2 IBUF2(80)
C               - DCB, buffer for output
	character*16 cstring
	integer iblen
C     IYR - start time of obs.
      integer idummy,nch,kerr
      integer ichcm_ch,ichmv,ib2as,ir2as,ichmv_ch
C
C
C     WHO DATE   CHANGES
C     gag 901016 Created, copied out of snap file.
C     gag 901025 Added ! in front of the *.
C     nrv 930212 implicit none
C     nrv 940114 Write a line with EARLY.
C                Remove EARLY (LSTSUM can figure it out)
C 960227 nrv Change iterid to lterid
C 970214 nrv Write 2-letter code on first line
C 970311 nrv Write both codes on first line.
C 990325 nrv Add a drudg ID comment.
C 990401 nrv Add a FS ID comment.
C 990404 nrv Don't add FS ID for VLBA output files.
C 990628 nrv Add K4 or S2 equipment type as a comment.
C 990730 nrv Add any equipment type as a comment.
C 990803 nrv Merge drudg and FS lines and reformat.
C 991102 nrv Add recorder B.
C
C
      iblen = 128
      IF (ichcm_ch(LEXPER,1,'        ').EQ.0)  THEN
        IDUMMY = ichmv_ch(LEXPER,1,'XXX     ')
      END IF
      CALL IFILL(IBUF2,1,iblen,32)
      nch = 0
      IF (IFUNC.EQ.1) THEN
        NCH = ichmv_ch(IBUF2,1,'" ')
      ELSE IF (IFUNC.EQ.2) THEN
	NCH = ichmv_ch(IBUF2,1,'!* ')
      END IF
      NCH = ICHMV(IBUF2,NCH,LEXPER,1,8)   ! experiment name
      NCH = NCH + IB2AS(IYR,IBUF2,NCH+2,4)  ! current year
      NCH = ICHMV(IBUF2,NCH+3,LSTNNA(1,ISTN),1,8)  ! station name
      NCH = ICHMV(IBUF2,NCH+2,LstCOD(ISTN),1,2)  ! 1-letter code
      NCH = ICHMV(IBUF2,NCH+2,LPOCOD(ISTN),1,2)  ! 2-letter code
      NCH = ichmv_ch(IBUF2,NCH,' ')
      call writf_asc(LU_OUTFILE,KERR,IBUF2,(NCH)/2)
      call inc(LU_OUTFILE,KERR)
C
C     write antenna line
C     begin PAKVA
C
      CALL IFILL(IBUF2,1,iblen,32)
      NCH = 1
      IF (IFUNC.EQ.1) THEN
        NCH = ichmv_ch(IBUF2,1,'" ')
      ELSE IF (IFUNC.EQ.2) THEN
	NCH = ichmv_ch(IBUF2,1,'!* ')
      END IF
      NCH = ICHMV(IBUF2,NCH,LSTCOD(ISTN),1,2)
      NCH = ICHMV(IBUF2,NCH+1,LSTNNA(1,ISTN),1,8)

      if (iaxis(istn).eq.1) then
        NCH = ichmv_ch(IBUF2,NCH+1,'HADC')
      else if (iaxis(istn).eq.2) then
        NCH = ichmv_ch(IBUF2,NCH+1,'XYEW')
      else if (iaxis(istn).eq.3) then
        NCH = ichmv_ch(IBUF2,NCH+1,'AZEL')
      else if (iaxis(istn).eq.4) then
        NCH = ichmv_ch(IBUF2,NCH+1,'XYNS')
      else if (iaxis(istn).eq.5) then
        NCH = ichmv_ch(IBUF2,NCH+1,'RICH')
      else if (iaxis(istn).eq.6) then
	NCH = ichmv_ch(IBUF2,NCH+1,'SEST')
      else if (iaxis(istn).eq.7) then
	NCH = ichmv_ch(IBUF2,NCH+1,'ALGO')
      end if

      NCH = NCH + 1 + IR2AS(SNGL(AXISOF(ISTN)),IBUF2,NCH+1,7,4)
      NCH = NCH + 1 + IR2AS(SNGL(STNRAT(1,ISTN)*(180.0*60.0/PI)),
     .                  IBUF2,NCH+1,5,1)
      NCH = NCH + 1 + IB2AS(ISTCON(1,ISTN),IBUF2,NCH+1,5)

      NCH = NCH + 1 + IR2AS(SNGL(STNLIM(1,1,ISTN)*(180.0/PI)),
     .                  IBUF2,NCH+1,6,1)
      NCH = NCH + 1 + IR2AS(SNGL(STNLIM(2,1,ISTN)*(180.0/PI)),
     .                  IBUF2,NCH+1,6,1)
      NCH = NCH + 1 + IR2AS(SNGL(STNRAT(2,ISTN)*(180.0*60.0/PI)),
     .                  IBUF2,NCH+1,5,1)
      NCH = NCH + 1 + IB2AS(ISTCON(2,ISTN),IBUF2,NCH+1,5)

      NCH = NCH + 1 + IR2AS(SNGL(STNLIM(1,2,ISTN)*(180.0/PI)),
     .                  IBUF2,NCH+1,6,1)
      NCH = NCH + 1 + IR2AS(SNGL(STNLIM(2,2,ISTN)*(180.0/PI)),
     .                  IBUF2,NCH+1,6,1)

      NCH = NCH + 1 + IR2AS(DIAMAN(ISTN),IBUF2,NCH+1,5,1)
      NCH = ICHMV(IBUF2,NCH+1,LPOCOD(ISTN),1,2)
C
C     Terminal ID is now hollerith
      nch = ichmv(ibuf2,nch+1,lterid(1,istn),1,4)
      call writf_asc(LU_OUTFILE,KERR,IBUF2,(NCH+1)/2)
      call inc(LU_OUTFILE,KERR)
C
C     end PAKVA
C
C     write position line
C     begin PAKVP

      CALL IFILL(IBUF2,1,iblen,32)
      NCH = 1
      IF (IFUNC.EQ.1) THEN
        NCH = ichmv_ch(IBUF2,1,'" ')
      ELSE IF (IFUNC.EQ.2) THEN
	NCH = ichmv_ch(IBUF2,1,'!* ')
      END IF
      NCH = ICHMV(IBUF2,NCH,LPOCOD(ISTN),1,2)
      NCH = ICHMV(IBUF2,NCH+1,LSTNNA(1,ISTN),1,8)
      write(cstring,9133) stnxyz(1,istn)
9133  format(f14.5)
      call char2hol(cstring,ibuf2,nch+1,nch+15)
      nch = nch + 15
      write(cstring,9133) stnxyz(2,istn)
      call char2hol(cstring,ibuf2,nch+1,nch+15)
      nch = nch + 15
      write(cstring,9133) stnxyz(3,istn)
      call char2hol(cstring,ibuf2,nch+1,nch+15)
      nch = nch + 15
      NCH = ICHMV(IBUF2,NCH+1,LOCCUP(1,ISTN),1,8)
      call writf_asc(LU_OUTFILE,KERR,IBUF2,(NCH+1)/2)
      call inc(LU_OUTFILE,KERR)
C
C     end PAKVP
C
C     Write terminal line
C     begin PAKVT
C
      call ifill(ibuf2,1,iblen,32)
      IF (IFUNC.EQ.1) THEN
        nch=ichmv_ch(ibuf2,1,'" ')
	ELSE IF (IFUNC.EQ.2) then
	 NCH = ichmv_ch(IBUF2,1,'!* ')
      END IF
      nch=ichmv(ibuf2,nch+1,lterid(1,istn),1,4)
      nch=ichmv(ibuf2,nch+1,lterna(1,istn),1,8)
      nch=nch+ib2as(maxpas(istn),ibuf2,nch+1,2)
	nch=nch+1+ib2as(maxtap(istn),ibuf2,nch+1,5)
      call writf_asc(LU_OUTFILE,KERR,IBUF2,(NCH+1)/2)
      call inc(LU_OUTFILE,KERR)
C
C     end PAKVT

C  Write drudg version
      CALL IFILL(IBUF2,1,iblen,32)
      IF (IFUNC.EQ.1) THEN
        NCH = ichmv_ch(IBUF2,1,'" ')
      ELSE IF (IFUNC.EQ.2) THEN
	NCH = ichmv_ch(IBUF2,1,'!* ')
      END IF
      nch=ichmv_ch(ibuf2,nch,' drudg version ')
      nch=ichmv_ch(ibuf2,nch,cversion(1:6))
C     Write FS version
      nch=ichmv_ch(ibuf2,nch,' compiled under FS ')
      idummy=iVerMajor_FS
      nch = nch + ib2as(idummy,ibuf2,nch,o'100000'+5)
      nch = ichmv_ch(ibuf2,nch,'.')
      idummy=iVerMinor_FS
      nch = nch + ib2as(idummy,ibuf2,nch,o'100000'+5)
      nch = ichmv_ch(ibuf2,nch,'.')
      idummy=iVerPatch_FS
      nch = nch + ib2as(idummy,ibuf2,nch,o'100000'+5)
      call writf_asc(LU_OUTFILE,KERR,IBUF2,(NCH+1)/2)
      IF (IFUNC.EQ.1) THEN ! only for non-VLBA
C       Write equipment line
        CALL IFILL(IBUF2,1,iblen,32)
        nch = ichmv_ch(ibuf2,1,'" Rack=')
        nch = ichmv(ibuf2,nch,lstrack(1,istn),1,8)
        nch = ichmv_ch(ibuf2,nch,'  Recorder 1=')
        nch = ichmv(ibuf2,nch,lstrec(1,istn),1,8)
        nch = ichmv_ch(ibuf2,nch,'  Recorder 2=')
        nch = ichmv(ibuf2,nch,lstrec2(1,istn),1,8)
        call writf_asc(LU_OUTFILE,KERR,IBUF2,(NCH+1)/2)
      endif

      RETURN
      END


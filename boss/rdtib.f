      subroutine rdtib(idcb,ierr)
C
C 1.1.   RDTIB reads a table of names and addresses of HPIB devices
C
C     INPUT VARIABLES:
C
      dimension idcb(1)
C                   DCB for files
C
C     OUTPUT VARIABLES:
C
C     IERR - error return, 0 OK, <0 trouble
C
C     CALLED SUBROUTINES: FMP PACKAGE, IBCON
C
C 3.  LOCAL VARIABLES
C
      dimension ip(5)
C                   for RMPAR
      dimension ibuf(4)
C                   buffer to hold input records
      integer fmpread,ichcm_ch
      integer ibadread
C     ibadrd - max length of line in ibad.ctl to read
      data ibadrd /15/
C     ICLASS - class to send to IBCON
C     NREC   - number of records in class
C
C 4.  CONSTANTS USED
C
C 5.  INITIALIZED VARIABLES
C
C
C 6.  PROGRAMMER: NRV
C     LAST MODIFIED: 800224
C  WHO  WHEN    DESCRIPTION
C  GAG  901220  Restructured loop and added call to logit.
C
      include '../include/params.i'
c
C# LAST COMPC'ED  870115:04:18 #
C
C     PROGRAM STRUCTURE
C
C     1. Open up the file with the name/address correspondences.
C
      call fmpopen(idcb,FS_ROOT//'/control/ibad.ctl',ierr,'r',id)
      if (ierr.lt.0) return
      call ifill_ch(ibuf,1,8,' ')
      ilen = fmpread(idcb,ierr,ibuf,ibadrd)
      call lower(ibuf,ilen)
      iclass = 0
      nrec = 0
      do while (ilen.ge.0)
        if (ichcm_ch(ibuf,1,'  ').eq.0) goto 110
        if ((nrec+1).eq.256) then
          call logit7(0,0,0,1,-170,2hbo,256)
          goto 110
        end  if
        nrec = nrec + 1
        call put_buf(iclass,ibuf,-iflch(ibuf,ilen),0,0)
C                   Put record into class record
        call ifill_ch(ibuf,1,8,' ')
        ilen = fmpread(idcb,ierr,ibuf,ibadrd)
        call lower(ibuf,ilen)
      end do
  
110   call fmpclose(idcb,ierr)
C
C     2. Now schedule IBCON and wait until it's done.
C
200   call run_prog('ibcon','wait',iclass,nrec,ip(3),ip(4),ip(5))
      call rmpar(ip)
      ierr = ip(3)
      return
      end

      subroutine rdtma(idcb,ierr)
C
C 1.1.   RDTMA reads a table of names and addresses of ASCII transceivers
C
C     INPUT VARIABLES:
C
      dimension idcb(1)
C                   DCB for reading file
C
C     OUTPUT VARIABLES:
C
C     IERR - error return, 0 OK, <0 trouble
C
C     CALLED SUBROUTINES: FMP PACKAGE, MATCN
C
C 3.  LOCAL VARIABLES
C
      dimension ip(5)
C                   for RMPAR
      dimension ibuf(6)
C                   buffer to hold input records
      integer fmpread,ichcm_ch
C     ICLASS - class to send to MATCN
C     NREC   - number of records in class
C
C 4.  CONSTANTS USED
C
C 5.  INITIALIZED VARIABLES
C
C
C 6.  PROGRAMMER: NRV
C     LAST MODIFIED:800224
C  WHO  WHEN    DESCRIPTION
C  GAG  901220  Restructured while loop and added logit call.
C
      include '../include/params.i'
c
C# LAST COMPC'ED  870115:04:18 #
C
C     PROGRAM STRUCTURE
C
C     1. Open up the file with the name/address correspondences.
C
      call fmpopen(idcb,FS_ROOT//'/control/matad.ctl',ierr,'r',id)
      if (ierr.lt.0) return
      call ifill_ch(ibuf,1,12,' ')
      ilen = fmpread(idcb,ierr,ibuf,12)
      call lower(ibuf,ilen)
      iclass = 0
      nrec = 0
      do while (ilen.ge.0)
        if(ichcm_ch(ibuf,1,'*').ne.0) then
           if (ichcm_ch(ibuf,1,'  ').eq.0) goto 110
           if ((nrec+1).eq.256) then
C no more than 256 entries permitted from control file.
              call logit7ci(0,0,0,1,-169,'bo',256)
              goto 110
           end if
           nrec = nrec + 1
           call put_buf(iclass,ibuf,-iflch(ibuf,12),'  ','  ')
C                   Put record into class record
           call ifill_ch(ibuf,1,12,' ')
        endif
        ilen = fmpread(idcb,ierr,ibuf,12)
        call lower(ibuf,ilen)
      end do
110   call fmpclose(idcb,ierr)
C
C     2. Now schedule MATCN and wait until it's done.
C
200   continue
      call run_prog('matcn','wait',iclass,nrec,ip(3),ip(4),ip(5))
      call rmpar(ip)
      ierr = ip(3)

      return
      end

      subroutine run_matcn(iclass,nrec)

      implicit none
      integer iclass,nrec,idum
      data idum/0/
C
C  RUN_MATCN: run MATCN and clean up as necessary
C
C  INPUT:
C     ICLASS: class number containing messages, 0 if none
C     NREC: number of records in class
C
C  OUTPUT:
C
C      integer ifbrk
C
      call run_prog('matcn','wait',iclass,nrec,idum,idum,idum)
C
      return
      end

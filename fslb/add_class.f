      subroutine add_class(ibuf,nch,iclass,nrec)
      implicit none
      integer*2 ibuf(1)
      integer nch,iclass,nrec
C
C  ADD_CLASS: Increment Class # Buffers
C
C  INPUT:
C     IBUF: buffer to add to class number
C     NCH: number of characters in IBUF
C     ICLASS: class # to add buffer, 0 to allocate new class #
C     NREC: number of records in class so far
C
C  OUTPUT:
C     ICLASS: new class # if 0 on entry
C     NREC: input NREC incremented by 1, new number of class records
C
      call put_buf(iclass,ibuf,nch,'fs','  ')
      nrec = nrec+1
      return
      end

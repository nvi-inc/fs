C@LOCF

C      subroutine locf(rlu,err,rec,rb,off)
       subroutine locf(rlu,rec)
c
c      Check the current file pointer and save it in REC.
c
c      89006  PMR
C  910702 NRV Changed calling sequence to include only
C             lu and rec#
c
       implicit none
       integer ifptr
       common /position/ ifptr(256)

C      integer rlu,err,rec,rb,off
       integer rlu,rec

       rec = ifptr(rlu)

       return
       end


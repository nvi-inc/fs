       subroutine writf_asc (iunit,kerr,ibuf,ilc)
       implicit none
C  Hollerith only version of WRITF
C  Input:
       integer iunit
C        iunit : logical unit for writing
       integer ilc
C        ilc   : number of memory words to write
       integer*2 ibuf(*)
C        ibuf  : integer buffer for reading
C
C  Output:
       integer kerr
C        kerr  : variable to return error on output (nonzero if error)
C
       integer i
c
       write(iunit,'(128a2)',ERR=100) (ibuf(i),i=1,ilc)
       kerr=0
       return
c
 100   continue
       kerr=-1
       return
       end


       subroutine writf_asc_ch (iunit,kerr,cbuf)
       implicit none
C  Character only version of WRITF
C  Input:
       integer iunit
C        iunit : logical unit for writing
       character*(*) cbuf
C        cbuf  : character buffer for reading
C
C  Output:
       integer kerr
C        kerr  : variable to return error on output (nonzero if error)
C
       write(iunit,'(a)',ERR=100) cbuf
       kerr=0
       return
c
 100   continue
       kerr=-1
       return
       end


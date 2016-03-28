c@ldsrt.f 

      subroutine ldsrt(ibsrt,nprc,idcb3,ierr) 
C
C 010819 PB V1.0 - Load the pfmed sort buffer. 
C
C     DL - list procedures in active procedure file.

       implicit none

       character*12 ibsrt(1)
       character*80 ibcd
       character*74 ibc2

       integer ix,nprc,ierr,idcb3,nch,len
       integer scanp,trimlen
  
        ix=1
        nprc = 1
        call f_rewind(idcb3,ierr)

        if (ierr.ne.0) goto 990
        ibcd = ' '
        len = 0

        do while (len.ge.0)

          call f_readstring(idcb3,ierr,ibc2,len)
          if(ierr.lt.0.or.len.lt.0) go to 130

C     Check for DEFINE:

          if (ibc2(1:6).eq.'define') then

C     Move name to print buffer.

            ibcd(ix:ix+11) = ibc2(9:20)
            ix=ix+13
            if(ix.lt.79) go to 120

            nch = trimlen(ibcd)
            nprc = scanp(ibcd,ibsrt,nprc)
            ibcd = ' '
            ix=1
          endif
120     end do

C       Write last line.

130     if(ix.gt.1) then
          nch = trimlen(ibcd)
          nprc = scanp(ibcd,ibsrt,nprc)
         endif 

        call sortq(ibsrt,nprc)
cc        write (6,'("ldsrt: Loaded ",i3," procedures.")') nprc 
c
990   continue 
      return 

      end

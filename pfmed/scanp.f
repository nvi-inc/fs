c@scanp
       integer function scanp(ibcd,ibsrt,ix) 
C
c 010705 PB - V1.0. 
C
c Part of sorted 'dl' display for pfmed. 
c Copy a line's worth of procedure names into an array 'ibsrt'
c Update total index and return it. 
c
       implicit none
       include '../include/fscom.i'

       Character*(12) ibcd,ibsrt(1)
       integer ix,is,in,nch,jchar,ichmv 

       is = 1

100    continue 
        in = is 
        do while (jchar(ibcd,in).ne.32)
         in = in+1
        enddo
        nch = ichmv(ibsrt(ix),1,ibcd,is,is+12) 
        ix = ix+1
        if (ix.gt.MAX_PROC2) then
          write(6,'("pfmed: Exceeded maximum number of procedures")') 
          scanp = MAX_PROC2 
          return
        endif
        is = in 
        do while (jchar(ibcd,is).eq.32)
         is = is+1
        enddo
       if (is.lt.79) goto 100
 
cc       write (6,'("SCANP ix: ",i3)') ix      
       scanp = ix
       return
       end
 
      subroutine gtrsp(ibuf,iblen,luusr,nch)
C
C     get response from user c#870407:11:59# 
C 
      integer*2 ibuf(1) 
C 
      call ifill_ch(ibuf,1,iblen*2,' ')
      read(luusr,'(512a2)') (ibuf(i),i=1,iblen)
      ich = 1 
      call gtfld(ibuf,ich,iblen*2,ic1,ic2)
      nch = ic2-ic1+1 
      if (ic1.eq.0) then
        nch = 0 
        return
      endif
      call ichmv(ibuf,1,ibuf,ic1,nch) 
      call ifill_ch(ibuf,nch+1,iblen*2-nch,' ')

      return
      end 

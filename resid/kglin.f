      logical function kglin(lu,idcb,ierr,jbuf,il,len,iibuf)
C
      integer leng, ierrg
      integer*2 jbufg(100)
      logical kgot
      common/got/leng,ierrg,jbufg,kgot
C
      integer*2 jbuf(1)
      character*(*) iibuf
C
      logical kread
      integer fmpread, ichcm_ch
C
      kglin=.false.
      if (.not.kgot) goto 10
      kgot=.false.
      len=leng
      ierr=ierrg
      do i=1,min0(il,leng)
         jbuf(i)=jbufg(i)
      enddo
      continue
      return
C
10    continue
      call ifill_ch(jbuf,1,il*2,' ')
      len= fmpread(idcb,ierr,jbuf,il*2)
      call lower(jbuf,len)
      if (len.gt.0) then
        if (mod(len,2).eq.1) then
          len=len+1
          idum=ichmv(jbuf,len,2H  ,1,1)
        endif
        len=len/2
      endif
      if (len.lt.0) return
      kglin=kread(lu,ierr,iibuf)
      if (kglin) return
      ilc=len*2
      ifc=1
      call gtfld(jbuf,ifc,ilc,ic1,ic2)
      if (ic1.le.0) goto 10
      if (ichcm_ch(jbuf,1,'*').eq.0) goto 10
C
      return
      end

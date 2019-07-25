      logical function kgdat(lu,idcbi,idcbo,lst,kuse,ich,ic,in,jbuf,il,
     +                       iibuf,iobuf,lnofs,ltofs)
C
      logical kuse
      integer*2 jbuf(1)
      real lnofs,ltofs
      character*(*) iibuf,iobuf
      integer fmpread,ichcm_ch
C
      logical kfild,kread,kfound,kfmp,kdone,kpout
      real lnofr,ltofr,lonr,latr
C
      integer*2 lnfond(13)
C
      data lnfond /  24,2h$d,2hat,2ha ,2hse,2hct,2hio,2hn ,2hno,2ht ,
     /             2hfo,2hun,2hd_/
C          $data section not found
      data kfound/.false./,kdone/.false./
C
      kgdat=.false.
      ic=-1
C
      if (kfound.and..not.kdone) goto 100
50    continue
      call ifill_ch(jbuf,1,il*2,' ')
      len = fmpread(idcbi,ierr,jbuf,il*2)
      if (len.gt.0) then
        if (mod(len,2).eq.1) then
          len=len+1
          idum=ichmv_ch(jbuf,len,' ')
        endif
      endif
      if (len.lt.0) return
      kgdat=kread(lu,ierr,iibuf)
      if (kgdat) return
      if (len.ge.0) goto 55
      kgdat=kfmp(lu,0,lnfond(2),lnfond(1),iibuf,0,1)
      return
C
55    continue
      kgdat=kpout(lu,idcbo,jbuf,len,iobuf,lst)
      if (kgdat) return
      if (kdone) goto 50
      if (ichcm_ch(jbuf,1,'$data').ne.0) goto 50
      kfound=.true.
C
100   continue
      call ifill_ch(jbuf,1,il*2,' ')
      len = fmpread(idcbi,ierr,jbuf,il*2)
      if (len.gt.0) then
        if (mod(len,2).eq.1) then
          len=len+1
          idum=ichmv_ch(jbuf,len,' ')
        endif
      endif
      if (len.lt.0) return
      kgdat=kread(lu,ierr,iibuf)
      if (kgdat) return
      if (len.lt.0) return
      if (ichcm_ch(jbuf,1,'$').ne.0) goto 105
      kdone=.true.
      kgdat=kpout(lu,idcbo,jbuf,len,iobuf,lst)
      if (kgdat) return
      goto 50
C
105   continue
      if (ichcm_ch(jbuf,1,'*').ne.0) goto 110
      kgdat=kpout(lu,idcbo,jbuf,len,iobuf,lst)
      if (kgdat) return
      goto 100
C
110   continue
      ifc=1
      ilc=len
      ifield=0
      iferr=0
C
      kuse=igtbn(jbuf,ifc,ilc,ifield,iferr).eq.1
      ich=ifc-1
      lonr=gtrel(jbuf,ifc,ilc,ifield,iferr)
      latr=gtrel(jbuf,ifc,ilc,ifield,iferr)
      lnofr=gtrel(jbuf,ifc,ilc,ifield,iferr)
      ltofr=gtrel(jbuf,ifc,ilc,ifield,iferr)
      lnofs=gtrel(jbuf,ifc,ilc,ifield,iferr)
      ltofs=gtrel(jbuf,ifc,ilc,ifield,iferr)
      ic=ilc
C
      kgdat=kfild(lu,iferr,-iferr,in,iibuf)
C
      return
      end

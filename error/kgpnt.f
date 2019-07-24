      logical function kgpnt(lu,idcb,kuse,lonr,latr,lnofr,ltofr,wlnr,
     +  wltr,mc,len,inp,iibuf,jbuf,il)
C
      include '../include/dpi.i'
C
      double precision das2b
      character*(*) iibuf
      logical kuse
      real lonr,lnofr,latr,ltofr
      dimension idcb(1)
      integer*2 jbuf(il)
      integer ichcm_ch
C
      logical kfild,kglin,kfound,kfmp
C
      integer*2 lnfond(13)
C
      data lnfond /  24,2h$d,2hat,2ha ,2hse,2hct,2hio,2hn ,2hno,2ht ,
     /             2hfo,2hun,2hd_/
C          $data section not found
      data kfound/.false./
C
      kgpnt=.false.
C
      if (kfound) goto 100
50    continue
      kgpnt=kglin(lu,idcb,ierr,jbuf,il,len,iibuf) 
      if (kgpnt) return
      if (len.ge.0) goto 55 
      kgpnt=kfmp(lu,0,lnfond(2),lnfond(1),iibuf,0,1)
      return
C 
55    continue
      if (ichcm_ch(jbuf,1,'$data').ne.0) goto 50
      kfound=.true.
C
100   continue
      kgpnt=kglin(lu,idcb,ierr,jbuf,il,len,iibuf)
      if (kgpnt) return
      if (len.lt.0) return
      if (ichcm_ch(jbuf,1,'$').ne.0) goto 105
      call unget(jbuf,ierr,len)
      return
C
105   continue
      ifc=1
      ifield=0
      iferr=0
      ilc=len*2
C
      kuse=igtbn(jbuf,ifc,ilc,ifield,iferr).eq.1
      lonr=gtrel(jbuf,ifc,ilc,ifield,iferr)*deg2rad
      latr=gtrel(jbuf,ifc,ilc,ifield,iferr)*deg2rad
      lnofr=gtrel(jbuf,ifc,ilc,ifield,iferr)*deg2rad
      ltofr=gtrel(jbuf,ifc,ilc,ifield,iferr)*deg2rad
      wlnr=gtrel(jbuf,ifc,ilc,ifield,iferr)*deg2rad
      wltr=gtrel(jbuf,ifc,ilc,ifield,iferr)*deg2rad
C
      kgpnt=kfild(lu,iferr,-iferr,inp+1,iibuf)
C
      return
      end

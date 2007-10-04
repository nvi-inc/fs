      program testd
C 
      include '../../include/params.i'
      include '../../include/dpi.i'
C
      integer*2 laxis(2),lant(4),lsorna(5) 
      integer  idcbo(2)
      integer*2 jbuf(50)
      integer idoy,ihr,im 
      integer*2 lpaxis(2)
C
      integer il,ierr,len 
      integer igp
C 
      real tsel
      real ltsoff
      real lnsoff 
      real loncor,latcor,lonoff,latoff
C
      double precision lonsum,latsum,lonrms,latrms,dirms
      real slnavg,sltavg,slnrms,sltrms,sdirms
C
      character*64 iibuf,iobuf,ipbuf
C
      logical kinit,koutp,kpant,kobot
      logical kpout_ch
c
      integer ipar(MAX_MODEL_PARAM)
      double precision p(MAX_MODEL_PARAM),phi,flt1,fln1
C
c     integer*2 ldone(27)
C
c     data ldone  /  51,2hte,2hrm,2hin,2hat,2hin,2hg:,2h  ,2h  ,2h  ,   
c    /             2h  ,2hin,2hpu,2ht ,2hpo,2hin,2hts,2h  ,2h  ,2h  ,   
c    /             2h  ,2hgo,2hod,2h p,2hoi,2hnt,2hs /                  
C          terminating:         input points         good points
      data il/50/
C 
      data idcbos/144/
C
      if (kinit(lu,iibuf,iobuf,iapp,ipbuf,lst)) goto 10020
C
      call char2hol("testdata",lant,1,8)
      call char2hol("azel",lpaxis,1,4)
C
      if (koutp(lu,idcbo,idcbos,iapp,iobuf)) goto 10010
C
      if (kpout_ch(lu,idcbo,'$antenna',iobuf,lst)) goto 10000
C
      if (kpant(lu,idcbo,lant,lpaxis,jbuf,il,lst,iobuf)) goto 10000
C
      if (kpout_ch(lu,idcbo,'$data ',iobuf,lst)) goto 10000
C
      phi=90*DEG2RAD
      do i=1,MAX_MODEL_PARAM
         ipar(i)=0
         p(i)=0
      enddo
      do i=1,22
      ipar(i)=1
      p(i)=0.1*i
      enddo
      ipar(10)=0
      p(10)=0
C
      inp=0 
      igp=0 
      ibp=0 
      ibad=0
      call inism(lonsum,lonrms,latsum,latrms,dirms) 
c
      igp=igp+1 
      coslt=cos(latcor*RPI/180.) 
      distr=sqrt(lonoff*lonoff*coslt*coslt+latoff*latoff) 
      call incsm(lonsum,lonrms,lonoff,latsum,latrms,latoff,dirms, 
     +           distr,igp,lu)
150   continue
C 
      lnsoff=1.
      ltsoff=1.
      call char2hol("dummy",lsorna,1,10)
      idoy=1
      ihr=0
      im=0
      do iel=5,85,10
         latcor=iel
         tsel=latcor
         do jaz=5,355,30
            loncor=jaz
            lonoff=fln1(0,
     +           dble(loncor)*DEG2RAD,dble(latcor)*DEG2RAD,p,ipar,phi)
            latoff=flt1(0,
     +           dble(loncor)*DEG2RAD,dble(latcor)*DEG2RAD,p,ipar,phi)
            inp=inp+1
            igp=igp+1 
            coslt=cos(latcor*RPI/180.) 
            distr=sqrt(lonoff*lonoff*coslt*coslt+latoff*latoff) 
            call incsm(lonsum,lonrms,lonoff,latsum,latrms,latoff,dirms, 
     +           distr,igp,lu)
            
            if (kobot(lu,idcbo,ioerr,ibad,loncor,latcor,lonoff,latoff,
     +           lnsoff,
     +           ltsoff,lsorna,idoy,ihr,im,tsel,lst)) goto 10000 
            if (len.lt.0) goto 9000 
         enddo
      enddo
C 
9000  continue
      call rstat(lonsum,lonrms,latsum,latrms,dirms,igp,lu)
      slnavg=lonsum 
      sltavg=latsum 
      slnrms=lonrms
      sltrms=latrms
      sdirms=dirms
C
      if (kpout_ch(lu,idcbo,'$stats',iobuf,lst)) goto 10000
C
      call tpstb(lu,idcbo,slnavg,sltavg,slnrms,sltrms,sdirms,inp,igp,
     +         iobuf,lst,jbuf,il) 
C
10000 continue
      call fmpclose(idcbo,ierr)
C
10010 continue
C
10020 continue
C
      end

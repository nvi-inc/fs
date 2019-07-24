      program xtrac
C 
      integer getdp,ipt 
      integer*2 laxis(2),lant(4),lsaxis(2),lsorna(5) 
      integer idcb(2), idcbo(2)
      integer*2 jbuf(50)
      integer iyr,idoy,ihr,im,is 
      integer*2 lpaxis(2)
      integer imodel, ltfc, lnfc
      integer irrec(12)
      integer numlon(31),numlat(31),numlin(31)
C
      integer nrep,npts,intp,ldev 
      integer iayr,iadoy,iahr,iam,ias,iats
      integer iqlat,iqlon 
      integer nlin,ierlin,ndlin
      integer nlat,ierlat,ndlat
      integer nlon,ierlon,ndlon
      integer lut,idcbz,il,nrec,ierr,len,jerr 
      integer igp
C 
      real lontim(31),lonpos(31),lontmp(31)
      real lattim(31),latpos(31),lattmp(31)
      real lintim(31),linpos(31),lintmp(31)
C
      real ra,dec,epoch 
      real step,cal,freq
      real slon,slat,adiam,fpver,fsver
      real haoff,decoff,azoff,eloff,xoff,yoff 
      real tsaz,tsel,tsys 
      real anlon,anlat,erlon,erlat
      real prlon,prlat,praz,prel
      real ltoff,ltwid,ltpk,ltbas,ltslp 
      real ltsoff,ltswid,ltspk,ltsbas,ltsslp,ltrchi 
      real lnoff,lnwid,lnpk,lnbas,lnslp 
      real lnsoff,lnswid,lnspk,lnsbas,lnsslp,lnrchi 
      real loncor,latcor,lonoff,latoff
C
      double precision dpi,lonsum,latsum,lonrms,latrms,dirms
      real slnavg,sltavg,slnrms,sltrms,sdirms
C
      character*64 iibuf,iobuf,ipbuf
C
      logical kinit,kgetp,kopn,koutp,kread,kwrit,kd,kpant,kobot
      logical kpout
C
      integer*2 lingdp(23)
      integer*2 lbreak(8)
      integer*2 ldone(27)
C
      data lingdp /  43,2her,2hro,2hr ,2h  ,2h  ,2h  ,2hin,2hte,2hrn,
     /             2hal,2h i,2hnc,2hon,2hsi,2hst,2hen,2hcy,2h i,2hn ,
     /             2hge,2htd,2hp /                                      
C          error       internal inconsistency in getdp
      data lbreak /  14,2hbr,2hea,2hk ,2hde,2hte,2hct,2hed/             
C          break detected
      data ldone  /  51,2hte,2hrm,2hin,2hat,2hin,2hg:,2h  ,2h  ,2h  ,   
     /             2h  ,2hin,2hpu,2ht ,2hpo,2hin,2hts,2h  ,2h  ,2h  ,   
     /             2h  ,2hgo,2hod,2h p,2hoi,2hnt,2hs /                  
C          terminating:         input points         good points
      data ndlin/31/,ndlat/31/,ndlon/31/,il/50/,nrec/12/,idcbz/1552/
C 
      data dpi/3.141592653589d0/,idcbos/144/,aofer/.0001/ 
C
      pi=dpi
      if (kinit(lu,iibuf,iobuf,iapp,ipbuf,lst)) goto 10020
C
      if (kgetp(lu,idcb,idcbz,ipbuf,jbuf,il,iedit,widmin,widmax,pkrlim,
     + lpaxis,lant)) goto 10020
C
      call fmpopen(idcb,iibuf,ierr,'r+',id)
      if (kopn(lu,ierr,iibuf,0)) goto 10020
C
      if (koutp(lu,idcbo,idcbos,iapp,iobuf)) goto 10010
C
      if (kpout(lu,idcbo,8H$antenna,8,iobuf,lst)) goto 10000
C
      if (kpant(lu,idcbo,lant,lpaxis,jbuf,il,lst,iobuf)) goto 10000
C
      if (kpout(lu,idcbo,6H$data   ,6,iobuf,lst)) goto 10000
C
      inp=0 
      igp=0 
      ibp=0 
      call inism(lonsum,lonrms,latsum,latrms,dirms) 
10    continue
      ipt=getdp(lsorna,ra,dec,epoch,iyr,idoy,ihr,im,is, 
     + lant,slon,slat,adiam,lsaxis,imodel,fpver,fsver,
     + laxis,nrep,npts,step,intp,ldev,cal,freq, 
     + haoff,decoff,azoff,eloff,xoff,yoff,
     + tsaz,tsel,tsys,
     + iayr,iadoy,iahr,iam,ias,iats,anlon,anlat,erlon,erlat,
     + prlon,prlat,praz,prel, 
     + ltoff,ltwid,ltpk,ltbas,ltslp,ltfc, 
     + ltsoff,ltswid,ltspk,ltsbas,ltsslp,ltrchi,
     + lnoff,lnwid,lnpk,lnbas,lnslp,lnfc,
     + lnsoff,lnswid,lnspk,lnsbas,lnsslp,lnrchi,
     + loncor,latcor,lonoff,latoff,iqlon,iqlat,
     + numlin,lintim,linpos,lintmp,nlin,ierlin,ndlin,
     + numlat,lattim,latpos,lattmp,nlat,ierlat,ndlat,
     + numlon,lontim,lonpos,lontmp,nlon,ierlon,ndlon,
     + lut,idcb,idcbz,jbuf,il,irrec,nrec,ierr,len,jerr)
      if (ipt.ne.1.and.len.lt.0) goto 9000
      if (jerr.ne.0) goto 8950
cxx      if (ifbrk(idum).lt.0) goto 8970
C
      inp=inp+1
      ibad=0
      dihadc=sqrt(haoff*haoff+decoff*decoff)
      diazel=sqrt(azoff*azoff+eloff*eloff)
      dixy=sqrt(xoff*xoff+yoff*yoff)
C
      if (irrec(1).lt.0 .or. irrec(2).lt.0.or. irrec(3).lt.0 .or.
     +   irrec(4).lt.0 .or. irrec(5).lt.0.or. 
     +   irrec(8).ne.1 .or. irrec(9).ne.1.or. irrec(10).ne.1 .or. 
     +   irrec(11).ne.1.or. irrec(12).ne.1 .or. 
     +   iqlat.ne.1 .or. iqlon.ne.1 .or.
     +   ichcm(laxis,1,lpaxis,1,4).ne.0 .or.
     +   (ichcm_ch(laxis,1,'hadc').eq.0.and.diazel+dixy.gt.aofer) .or. 
     +   (ichcm_ch(laxis,1,'azel').eq.0.and.dihadc+dixy.gt.aofer) .or. 
     +   (ichcm_ch(laxis,1,'xy').eq.0.and.dihadc+diazel.gt.aofer)
     +   ) goto 200
C 
      if (iedit.eq.0) goto 145
      if (lnwid.gt.widmax .or. lnwid.lt.widmin .or.
     +   ltwid.gt.widmax .or. ltwid.lt.widmin .or.
     +   (ltpk/lnpk).gt.pkrlim .or. (ltpk/lnpk).lt.(1./pkrlim)
     +   ) goto 200
C
145   continue
      igp=igp+1 
      coslt=cos(latcor*pi/180.) 
      distr=sqrt(lonoff*lonoff*coslt*coslt+latoff*latoff) 
      call incsm(lonsum,lonrms,lonoff,latsum,latrms,latoff,dirms, 
     +           distr,igp,lu)
150   continue
C 
      if (kobot(lu,idcbo,ioerr,ibad,loncor,latcor,lonoff,latoff,lnsoff,
     +           ltsoff,lsorna,idoy,ihr,im,tsel,lst)) goto 10000 
      if (len.lt.0) goto 9000 
      if (kread(lu,ierr,iibuf)) goto 9000 
      goto 10
C 
200   continue
      ibad=1
      ibp=ibp+1 
      goto 150 
C 
8950  continue
      ic=ib2as(jerr,lingdp(2),7,5)
      call po_put_i(lingdp(2),lingdp(1))
      goto 10000 
C 
8970  continue
      call po_put_i(lbreak(2),lbreak(1))
      goto 9000
C 
9000  continue
      call rstat(lonsum,lonrms,latsum,latrms,dirms,igp,lu)
      slnavg=lonsum 
      sltavg=latsum 
      slnrms=lonrms
      sltrms=latrms
      sdirms=dirms
C
      if (kpout(lu,idcbo,6H$stats  ,6,iobuf,lst)) goto 10000
C
      call tpstb(lu,idcbo,slnavg,sltavg,slnrms,sltrms,sdirms,inp,igp,
     +         iobuf,lst,jbuf,il) 
C
10000 continue
      call fmpclose(idcbo,ierr)
C
10010 continue
      call fmpclose(idcb,ierr)
C
10020 continue
C
      end

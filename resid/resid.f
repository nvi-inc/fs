      program resid
C
      logical kinit,kgpnt,kopn,kif,koutp,kgant,kuse
      logical kxy,kazel,khadc
C
      real lat(500),lon(500),latoff(500),lonoff(500)
      real latr,lonr,ltofr,lnofr
      real xmin, ymin, xmax, ymax
C
      character*63 iobuf,iibuf
      dimension ireg(2),ldum(3),rotat(2,2)
      integer*2 jbuf(100),laxis(2),lant(4)
      integer*2 ilabel(40)
      integer*2 lstrng(40)
      integer idcbo(2)
      integer ichcm_ch
      integer*2 istr1(10),istr2(10),istr3(10),istr4(10)
C
      equivalence (ireg,reg)
C
      integer*2 l2mny(17)
      integer*2 lnopt(9)
C
      data l2mny  /  32,2hto,2ho ,2hma,2hn ,2hin,2hpu,2ht ,2hpo,2hin,
     /             2hts,2h, ,2hli,2hmi,2ht ,2his,2h _/
C          too man input poinhts, limit is
      data lnopt  /  15,2hno,2h i,2hnp,2hut,2h p,2hoi,2hnt,2hs /
C          no input points
      data il/100/,mpts/500/,iwds/3072/,idcbos/784/,is/40/
C
      ic=ib2as(mpts,ldum,1,o'100000'+6)
C
      if (kinit(lu,iibuf,iobuf,iapp,lstrng,is,ics,lst)) goto 10010
C
      call fmpopen(idcbo,iibuf,ierr,'r+',id)
      if (kopn(lu,ierr,iibuf,0)) goto 10010
C
      if (kgant(lu,idcbo,lant,laxis,iibuf,jbuf,il)) goto 10005
C
      inp=0
10    continue
      if (kgpnt(lu,idcbo,kuse,lonr,latr,lnofr,ltofr,ilen,inp,iibuf,jbuf,
     +         il,lstrng,ics)) goto 10005
      if (ilen.lt.0.or.ichcm_ch(jbuf,1,'$').eq.0) goto 20
      if (.not.kuse) goto 10
      if (kif(l2mny(2),l2mny(1),ldum,1,ic,inp.ge.mpts,lu)) goto 10005
      inp=inp+1
C
      lon(inp)=lonr
      lat(inp)=latr
      lonoff(inp)=lnofr
      latoff(inp)=ltofr
      goto 10
C
20    continue
      if (kif(lnopt(2),lnopt(1),idum,0,0,inp.eq.0,lu)) goto 10005
      call fmpclose(idcbo,ierr)
      if (koutp(lu,idcbo,idcbos,iapp,iobuf)) goto 10005
C
      rotat(1,1)= 1.0
      rotat(2,1)= 0.0
      rotat(1,2)= 0.0
      rotat(2,2)= 1.0
      call psetr(rotat)
      iwidx=78
      iwidy=30
      ixmin=02
      ixmax=79
      iymin=05
      iymax=28
C 
      inext=1 
      inext=ichmv(ilabel,inext,lant,1,8)
      inexts=ichmv_ch(ilabel,inext,' ') 
      kazel=ichcm_ch(laxis,1,'azel').eq.0
      kxy=ichcm_ch(laxis,1,'xy').eq.0
      khadc=ichcm_ch(laxis,1,'hadc').eq.0
C 
      if (.not.kazel) goto 55 
      listr1=ichmv_ch(istr1,1,'azimuth ')-1
      listr2=ichmv_ch(istr2,1,'elevation ')-1
      listr3=ichmv(istr3,1,istr1,1,listr1)
      listr4=ichmv(istr4,1,istr2,1,listr2)
      listr3=ichmv_ch(istr3,listr3,'offset')-1 
      listr4=ichmv_ch(istr4,listr4,'offset')-1 
      goto 95
C 
55    continue
      if (.not.kxy) goto 65 
      listr1=ichmv_ch(istr1,1,'x ')-1
      listr2=ichmv_ch(istr2,1,'y ')-1
      listr3=ichmv(istr3,1,istr1,1,listr1)
      listr4=ichmv(istr4,1,istr2,1,listr2)
      listr3=ichmv_ch(istr3,listr3,'offset')-1 
      listr4=ichmv_ch(istr4,listr4,'offset')-1 
      goto 95
C 
65    continue
      if (.not.khadc) goto 75 
      listr1=ichmv_ch(istr1,1,'hour angle ')-1
      listr2=ichmv_ch(istr2,1,'declination ')-1
      listr3=ichmv(istr3,1,istr1,1,listr1)
      listr4=ichmv(istr4,1,istr2,1,listr2)
      listr3=ichmv_ch(istr3,listr3,'offset')-1 
      listr4=ichmv_ch(istr4,listr4,'offset')-1 
      goto 95
C 
75    continue
      stop
C 
95    continue
      xmin=-90.0
      ymin=-90.0
      xmax=+90.0
      ymax=+90.0
      if (.not.kazel) goto 100
      xmin=0.0
      ymin=0.0
      xmax=360.0
      ymax=90.0 
100   continue
C 
      inext=ichmv(ilabel,inexts,istr2,1,listr2) 
      inext=ichmv_ch(ilabel,inext,' vs ')
      inext=ichmv(ilabel,inext,istr1,1,listr1)
      call pquik(iwds,lon,lat,inp,iwidx,iwidy, 
     +           ixmin,ixmax,iymin,iymax, 
     +           xmin,xmax,ymin,ymax, 
     +           idcbo,lut,iobuf,lst,ilabel,inext-1,
     +           istr1,listr1,istr2,listr2) 
C 
      xmin=-90.0
      ymin=0.0
      xmax=+90.0
      ymax=0.0
      if (.not.kazel) goto 200
      xmin=0.0
      xmax=360.0
200   continue
C 
      inext=ichmv(ilabel,inexts,istr3,1,listr3) 
      inext=ichmv_ch(ilabel,inext,' vs ')
      inext=ichmv(ilabel,inext,istr1,1,listr1)
      call pquik(iwds,lon,lonoff,inp,iwidx,iwidy,
     +           ixmin,ixmax,iymin,iymax, 
     +           xmin,xmax,ymin,ymax, 
     +           idcbo,lut,iobuf,lst,ilabel,inext-1,
     +           istr1,listr1,istr3,listr3) 
C 
      xmin=-90.0
      ymin=0.0
      xmax=+90.0
      ymax=0.0
      if (.not.kazel) goto 300
      xmin=0.0
      xmax=360.0
300   continue
C 
      inext=ichmv(ilabel,inexts,istr4,1,listr4) 
      inext=ichmv_ch(ilabel,inext,' vs ')
      inext=ichmv(ilabel,inext,istr1,1,listr1)
      call pquik(iwds,lon,latoff,inp,iwidx,iwidy,
     +           ixmin,ixmax,iymin,iymax, 
     +           xmin,xmax,ymin,ymax, 
     +           idcbo,lut,iobuf,lst,ilabel,inext-1,
     +           istr1,listr1,istr4,listr4) 
C 
      xmin=-90.0
      ymin=0.0
      xmax=+90.0
      ymax=0.0
      if (.not.kazel) goto 400
      xmin=0.0
      xmax=90.0 
400   continue
C 
      inext=ichmv(ilabel,inexts,istr3,1,listr3) 
      inext=ichmv_ch(ilabel,inext,' vs ')
      inext=ichmv(ilabel,inext,istr2,1,listr2)
      call pquik(iwds,lat,lonoff,inp,iwidx,iwidy,
     +           ixmin,ixmax,iymin,iymax, 
     +           xmin,xmax,ymin,ymax, 
     +           idcbo,lut,iobuf,lst,ilabel,inext-1,
     +           istr2,listr2,istr3,listr3) 
C 
      xmin=-90.0
      ymin=0.0
      xmax=+90.0
      ymax=0.0
      if (.not.kazel) goto 500
      xmin=0.0
      xmax=90.0 
500   continue
C 
      inext=ichmv(ilabel,inexts,istr4,1,listr4) 
      inext=ichmv_ch(ilabel,inext,' vs ')
      inext=ichmv(ilabel,inext,istr2,1,listr2)
      call pquik(iwds,lat,latoff,inp,iwidx,iwidy,
     +           ixmin,ixmax,iymin,iymax,
     +           xmin,xmax,ymin,ymax,
     +           idcbo,lut,iobuf,lst,ilabel,inext-1,
     +           istr2,listr2,istr4,listr4)
C
10005 continue
      call fmpclose(idcbo,ierr)
C
10010 continue
      end

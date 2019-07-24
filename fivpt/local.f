      subroutine local(lonpos,latpos,laxis,ierr)
      real lonpos,latpos
C 
C  GET LOCAL ANTENNA COORDINATES
C 
C  OUTPUT:
C 
C         LONPOS = CALCULATED LONGITUDE-LIKE COORDINATE 
C 
C         LATPOS = CALCULATED LATITUDE-LIKE COORDINATE
C 
C         IERR = 0 IF NO ERROR OCCURRED 
C 
       integer*2 laxis(2)
       double precision dlat,dlon,ra,dec,az,el,x,y,dha,refr 
       dimension it(6)
C 
      include '../include/fscom.i'
      include '../include/dpi.i'
C 
      integer ichcm_ch
C
C  THE FOLLOWING VARIABLES ARE READ FROM FSCOM: 
C 
C        XOFF, YOFF, AZOFF, ELOFF, RAOFF, DECOFF, LAXFP, RADAT, DECDAT
C 
C  CALCULATE THE POSITION IN THE LOCAL X/Y NS SYSTEM
C
      call fs_get_alat(alat)
      call fs_get_wlong(wlong)
      dlat=alat
      dlon=wlong
      call fc_rte_time(it,it(6))
C
      call fs_get_radat(radat)
      call fs_get_decdat(decdat)
      ra=radat
      dec=decdat
      call cnvrt(1,ra,dec,az,el,it,dlat,dlon)
      el=el+(DPI/180.0d0)*refr(el*(180.0d0/DPI))
      call cnvrt(5,az,el,x,y,it,dlat,dlon)
C
C  NOW CONVERT BACK TO WHAT WE WERE ASKED FOR
C
C  HA/DEC, NOT RA/DEC
C
      if (ichcm_ch(laxis,1,'hadc').ne.0) goto 200
      call cnvrt(6,x,y,dha,dec,it,dlat,dlon)
      lonpos=dha
      latpos=dec
      return
C
C  AZ/EL
C
200   continue
      if (ichcm_ch(laxis,1,'azel').ne.0) goto 400
      call cnvrt(4,x,y,az,el,it,dlat,dlon)
      lonpos=az
      latpos=el
      return
C
C  X/Y NS
C
400   continue
      if (ichcm_ch(laxis,1,'xyns').ne.0) goto 600
      lonpos=x
      latpos=y
      return
C 
C  X/Y EW 
C 
600   continue
C     if (ichcm_ch(laxis,1,'xyew').ne.0) goto 800
C 
C   WE DON'T SUPPORT THIS YET WEH 840728
C 
      goto 800 
C 
C UNKNOWN AXIS SYSTEM 
C 
800   continue
      ierr=-40

      return
      end 

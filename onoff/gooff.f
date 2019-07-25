      subroutine gooff(lonoff,latoff,caxis,nwait,ierr)
      character*(*) caxis
      real lonoff,latoff
C 
C  GO TO THE INDICATED OFFSET 
C 
C  INPUT: 
C 
C            NWAIT = NUMBER OF SECONDS TO WAIT FOR ONSOURCE 
C 
C  OUTPUT:
C 
C            LONOFF = LONIGITUDE AXIS OFFSET
C 
C            LATOFF = LATITUDE AXIS OFFSET
C 
C            IERR = 0 IF NO ERROR 
C 
      include '../include/fscom.i'
C 
C  LOCAL:
C
C  THE FOLLOWING VARIABLES ARE READ FROM FSCOM: 
C 
C        XOFF, YOFF, AZOFF, ELOFF, RAOFF, DECOFF, 
C 
C  HA/DEC, NOT RA/DEC 
C 
      if (caxis.ne.'hadc') goto 200
      raoff=-lonoff 
      call fs_set_raoff(raoff)
      decoff=latoff 
      call fs_set_decoff(decoff)
      goto 10000 
C 
C  AZ/EL
C 
200   continue
      if (caxis.ne.'azel') goto 400
      azoff=lonoff
      call fs_set_azoff(azoff)
      eloff=latoff
      call fs_set_eloff(eloff)
      goto 10000 
C 
C  X/Y NS 
C 
400   continue
      if (caxis.ne.'xyns') goto 600
      xoff=lonoff 
      call fs_set_xoff(xoff)
      yoff=latoff 
      call fs_set_yoff(yoff)
      goto 10000 
C 
C  X/Y EW 
C 
600   continue
      if (caxis.ne.'xyew') goto 80000
      xoff=lonoff 
      call fs_set_xoff(xoff)
      yoff=latoff 
      call fs_set_yoff(yoff)
      goto 10000 
C 
C  NOW DO THE OFF 
C 
10000 continue
      call antcn(2,ierr)
      if(ierr.ne.0) return
C 
C WAIT FOR ONSOURCE 
C 
      call onsor(nwait,ierr)
      return
C 
C UNKNOWN AXIS SYSTEM 
C 
80000 continue
      ierr=-60

      return
      end 

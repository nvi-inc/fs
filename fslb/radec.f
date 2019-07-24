      subroutine radec(ra,dec,ha,irah,iram,ras,ldsign,idecd,idecm,decs, 
     .lhsign,ihah,iham,has)
C 
C     RADEC returns the hms, dms, hms for ra, dec, and ha.
C
      include '../include/dpi.i'
C 
      double precision ra,dec                     !  lar  <910607.0551>
      integer*2 ldsign,lhsign
C 
C  INPUT: 
C 
C     RA, DEC, HA - in radians
C 
C 
C  OUTPUT:
C 
C     IRAH,IRAM,RAS - hms for ra
C     LDSIGN,IDECD,IDECM,DECS - sign, dms for dec 
C     LHSIGN,IHAH,IHAM,HAS - sign, hms for hour angle
C
      double precision h
C
C  CONSTANTS:
C
C
C
C     1. First convert the RA.
C
      h = ra*12.d0/dpi + 0.000001
      irah = h
      iram = (h-irah)*60.0
      ras = (h-irah-iram/60.0)*3600.0
C
C
C     2. Next the declination.
C
      d = abs(dec)*180.0/dpi + .00001
      idecd = d
      idecm = (d-idecd)*60.0
      decs = (d-idecd-idecm/60.0)*3600.0
      call char2hol('  ',ldsign,1,2)
      if (dec.lt.0) call char2hol('- ',ldsign,1,2)
C 
C 
C     3. Finally the hour angle.
C 
      h = abs(ha)*12.0/dpi + .000001
      ihah = h
      iham = (h-ihah)*60.0
      has = (h-ihah-iham/60.0)*3600.0 
      call char2hol('  ',lhsign,1,2)
      if (ha.lt.0) call char2hol('- ',lhsign,1,2)
      return
      end 

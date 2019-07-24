      subroutine poshd(ihd,ipass,pnowx,ip)

C   determine head position
C 
C  INPUT VARIABLES: 
C     IHD - head to be checked (1 or 2) 
C     IPASS - tape pass number (odd for forward passes, even for reverse)
      dimension ip(1)       !   the standard rmpar parameters
C         IP(1)= CLASS #, IP(2)= # OF RECORDS, IP(3)= ERROR PARAMETER
C
C  OUTPUT VARIABLE:
C     PNOWX - Current direction-calibrated LVDT position (microns)
C 
C  COMMON BLOCKS USED:
      include '../include/fscom.i'
C       CONTAINS:  FOROFF,REVOFF - direction-dependent offsets to PNOWX
C                  PSLOPE,RSLOPE - sign-dependent multiplicative factors
C 
C  LOCAL VARIABLES: 
      integer*2 ibuf(20)
      dimension ireg(2)
      integer get_buf
      equivalence (reg,ireg(1)) 
      data ilen /40/,tcoeff /0.0/,tcoref /0.0/  
C 
C   LAST MODIFIED:  LAR ADDED DIRECTION CALIBRATION   <880821.0120>
C 
C  1. First set up class buffers for MATCN
C 
      nrec = 0
      iclass = 0
      do i=1,2
        ibuf(1) = 0 
        call char2hol('hd',ibuf(2),1,2)
        call ichmv(ibuf,5,8H00000000,1,8) 
        n = ihd - 1 
        if (i.eq.2) n = n+2 
        call ib2as(n,ibuf,12,1) 
        call put_buf(iclass,0,ibuf,-12,2Hfs,0)
        ibuf(1) = -2
        call put_buf(iclass,0,ibuf,-4,2Hfs,0)
        nrec = nrec+2 
      enddo
C 
C  2. Now schedule MATCN
C 
      call run_matcn(iclass,nrec)
      call rmpar(ip)
C
C  3. Get and decode position and temperature responses from MATCN
C
      iclass = 0
      if (ip(3).lt.0) return
      iclass = ip(1)
      nrec = ip(2)
      if (nrec.ne.4) then
        ip(3) = -403
        goto 990
      endif
      ireg(2) = get_buf(iclass,ibuf,-ilen,idum,idum)
      ireg(2) = get_buf(iclass,ibuf,-ilen,idum,idum)
      nchar = min0(ireg(2),ilen)
C     IF (NCHAR.NE.8) THEN
C       IP(3) = -303
C       GOTO 990
C     ENDIF
cxx      call hexi(ibuf(4),ivlt,4,ierr)
      if (ierr.ne.0) then
        ip(3) = -303
        goto 990
      endif
      ireg(2) = get_buf(iclass,ibuf,-ilen,idum,idum)
      ireg(2) = get_buf(iclass,ibuf,-ilen,idum,idum)
      nchar = min0(ireg(2),ilen)
C     IF (NCHAR.NE.8) THEN
C       IP(3) = -303
C       GOTO 990
C     ENDIF
cxx      call hexi(ibuf(4),itvlt,4,ierr)
      if (ierr.ne.0) then
        ip(3) = -303
        goto 995
      endif
C 
C  4. Convert responses to voltages and compute position in um. 
C 
      pvlt = ivlt*.0048828d0
      tvlt = itvlt*.0048828d0 
      tvlt = tvlt*10. 
      if (pvlt.ge.0.) then
        slope = pslope(ihd)
      else
        slope = rslope(ihd)
      endif
      pnowx = slope*pvlt*(1.+tcoeff*(tvlt-tcoref)) - foroff(ihd)
C  Subtract ADDITIONAL (not alternate) offset if it's a reverse (even) pass
      if (ipass.eq.2*(ipass/2)) pnowx = pnowx - revoff(ihd)
C
      goto 995
C 
990   continue
      if(iclass.ne.0) call clrcl(iclass)
995   ip(1) = 0
      ip(2) = 0
      call char2hol('q>',ip(4),1,2)

      return
      end 

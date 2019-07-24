      integer function ipgst(name)

      dimension name(3)
C
C       This routine returns the status of program NAME where the
C       value will be the contents of the status field in the IDSEG
C       if it is present else -1 will be returned.
C
      ipgst=-1
C
C  GET IDSEG ADDRESS
C
c      idad=idget(name)
C
C  CHECK PROGRAM IS PRESENT
C
      if (idad.eq.0) goto 99999
C
C  GET PROGRAM STATUS
C
      istat = 0
c      ierr = idinfo(idad,name,istat,1,1)
      if (ierr.lt.0) goto 99999
C
      ipgst = istat
C
99999 continue
C
      return
      end

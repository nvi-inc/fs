      subroutine hdpos(i,ipass,ip)
C  position tape head
C
C  INPUT PARAMETERS:
C     I:  NUMBER OF HEAD TO BE POSITIONED (1=WRITE, 2=READ)
C     IPASS:  TAPE PASS NUMBER
C
C  OUTPUT PARAMETERS:
      dimension ip(5)     !  ip(3) is used to return error numbers to caller
C 
C  CALLED SUBROUTINES:  POSIT (FIND CURRENT POSITION), HMOVE (MOVE HEAD)
C
C  COMMON BLOCKS USED:  /FSCOM/
      include '../include/fscom.i'
C       VARIABLES:  FASTFW, SLOWFW, FASTRV, SLOWRV:   TAPE SPEEDS
C                   ITAPOF:   DESIRED HEAD POSITION FOR THIS PASS NUMBER
C 
C  LOCAL VARIABLES:
C     PNOWX:  CURRENT HEAD POSITION
C     POFFX:  DIFFERENCE BETWEEN CURRENT AND REQUESTED HEAD POSITIONS
C     IDIRCT:  DIRECTION IN WHICH TAPE IS TO BE MOVED (1=FORWARD, 0=REVERSE)
C     FASTSP, SLOWSP:  TAPE SPEEDS FOR DESIRED DIRECTION
C     IDSPD:  DESIRED SPEED (1=FAST, 0=SLOW)
C     TMOVE:  ESTIMATE OF TIME REQUIRED TO MOVE HEAD (UNITS OF 40 MICROSEC)
C     NTRIES:  NUMBER OF ITERATION IN PNOWX
C
C  LOCAL CONSTANTS:
      parameter (maxtry=20)     !  number of tries after which to give up
      parameter (ptoler=.5)     !  tolerance in posx
C
      logical new
C
C  LAST MODIFIED:  LAR GETS POSITION REQUESTS FROM COMMON  <880826.2357>
C HISTORY:
C  WHO  WHEN    WHAT
C  gag  920721  Added condition on ipass gt 100 for Mark IV.
C
C
      new=.true.
      do ntries=0,maxtry
        call posit(i,ipass,pnowx,ip,new)
        if (ip(3).lt.0) return         ! error in posit
        if (ipass.gt.100) then
          itens = MOD(ipass,100)
          ihunds = ipass/100
          poffx = pnowx - itapof4(itens,ihunds)
        else
          poffx = pnowx - itapof(ipass)
        endif
        if (abs(poffx).le.ptoler) return         ! successful termination
C
        if (poffx.le.0.) then
          fastsp = fastrv(i)
          slowsp = slowrv(i)
        else
          fastsp = fastfw(i)
          slowsp = slowfw(i)
        endif
C
        tmove=abs(poffx/slowsp)
        if (tmove.ge.1.) then
          ihspd = 1
          tmove = abs(poffx/fastsp) * 25000.
        else
          ihspd = 0
          tmove = abs(poffx/slowsp) * 25000.
        endif
C
        if (poffx.gt.0.) then
          idirct = 1
        else
          idirct = 0
        endif
C
        if (tmove.ge.24000.) then
          call hmove(i,ihspd,idirct,24000,ip)
          if (ip(3).lt.0) return         ! error in hmove
          call susp(2,1)
          call susp(1,5)
          ntries = ntries - 1
        else
          idur = tmove
          call hmove(i,ihspd,idirct,idur,ip)
          if (ip(3).lt.0) return         ! error in hmove
          iwait = tmove/250.
          iwait = iwait + 5
          call susp(1,iwait)
        endif
      enddo
C
      ierr = -300-i
      return
C
      end

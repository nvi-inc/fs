      SUBROUTINE SOINP(IBUF,ILEN,lu,IERR)
C
C     This routine reads and decodes a source entry
C     and puts the variables into the source common.
C
      include '../skdrincl/skparm.ftni'
      include '../skdrincl/constants.ftni'

      include '../skdrincl/sourc.ftni'
C
C  INPUT:
      integer*2 IBUF(*)
      integer ilen,lu
C      - buffer holding source entry
C     ILEN - length of IBUF in words
C
C  OUTPUT:
      integer ierr
C     IERR - error number
C     INUM - number of error message

! Functions
      integer iwhere_in_String_list
      integer julda             !julian day
C
C  LOCAL:
      LOGICAL KORBIT
C      -LNFCH routine, local variable for orbit identification
      integer*2 LIAU(max_sorlen/2),LCOM(max_sorlen/2)
      integer*2 LRA(8),LDC(7),lname(max_sorlen/2)

      character*(max_sorlen) ciau,cname,ccom,corbit
      equivalence (lname,cname), (ciau,liau),(lcom,ccom)

C      - temporary variables for unpacking
      double precision RA,RARAD,DEC,DECRAD,R,D
C        - temporary for unpacking
      double precision tjd ! for APSTAR
      double precision OINC,OECC,OPER,ONOD,OANM,OAXS,OMOT,OEDY
C        - temporary for unpacking

      integer iepy
C        - HOLDS THE ASCII VALUE 8HORBIT   /
      INTEGER   i,iep,J,irah,iram,idecd,idecm
      integer*2 lds
      real epoch
C
C  History:
C     WEH  830523  ADDED SATELLITES
C     MWH  840915  SUPPORT J2000 COORDINATES
C     MWH  850605  ALLOW EPOCHS OTHER THAN 1950 & 2000
C     NRV  880314  DE-COMPC'D
C     nrv  891110  Changed for new catalog system
C     NRV 891226 Changed MOVE to APSTAR
C     NRV  900130 Changed calling sequence to add LU and remove INUM
C     NRV  900423 Changed APSTAR to MPSTAR for non-1950 positions
C     nrv  930225 implicit none
C     nrv  931124 Add arguments to UNPSO to return orbital elements
C     nrv  940112 Keep common name internally for satellites, not ORBIT.
C     nrv  950321 Add error message for duplicate source names.
C 970114 nrv Change 4 to max_sorlen/2
C 990606 nrv Store IAU name
C 2003Dec09 JMGipson replace holleriths by characcters.
C
      DATA cORBIT/'ORBIT   '/
C
C     1. Call UNPSO to unpack the buffer we were passed.
C     Put all of the fields into temporary variables.
C
      J = 17
      CALL UNPSO(IBUF,ILEN,IERR,LIAU,LCOM,LRA,IRAH,IRAM,RA,RARAD,
     >  LDS,LDC,IDECD,IDECM,DEC,DECRAD,EPOCH,
     >  OINC,OECC,OPER,ONOD,OANM,OAXS,OMOT,IEPY,OEDY,j)
C
      IF  (IERR.NE.0) THEN  !
        write(lu,9100) ierr,(ibuf(i),i=1,ilen)
9100    format('SOINP01 - Error in field 'i5' of:'/40a2)
        RETURN
      END IF 

C
C     2. Decide which source name to use.  If there is a common
C     name, use that, otherwise use the IAU name. For satellites the
C     IAU name comes in as ORBIT as a flag. Save the actual satellite
C     name as the schedule name.
C     Then check for a duplicate name.  This should not happen
C     in the SKED environment but might as well check.
C     For celestial sources, make sure we have 1950 or J2000 coordinates.
C     (Until flexibility to handle others is built in.)
C
      Korbit=Ciau .eq. corbit
      cname=ciau
      if(ccom(1:1) .ne. "$") cname=ccom
C
      i=iwhere_in_string_list(csorna,nsourc,cname)

      IF  (I.ne.0) then ! duplicate source
        write(lu,9101) csorna(i)
9101    format('SOINP22 - Duplicate source name ',a,
     .  '. Using the position of the first one.')
        RETURN
      endif ! duplicate source
C
C     2. Now find out if we have too many sources already.
C     If not, move the new variables into place.
C
      IF  (.NOT.KORBIT) THEN  !"not an orbit"
        NCELES=NCELES+1
        IF  (NCELES.GT.MAX_CEL) THEN  !"celestial overflow"
          write(lu,9201) max_cel
9201      format('SOINP02 - Too many celestial sources.  Max is 'i3)
          RETURN
        ENDIF
      ELSE  !"an orbit"
        NSATEL=NSATEL+1
        IF  (NSATEL.GT.MAX_SAT) THEN  !"orbit overflow"
          write(lu,9202) max_sat
9202      format('SOINP03 - Too many satellites.  Max is 'i3)
          RETURN
        END IF  !"orbit overflow"
      END IF  !"an orbit"
C
      NSOURC = NSOURC + 1
      IF  (NSOURC.GT.MAX_SOR) THEN  !
        write(lu,9203) max_sor
9203    format('SOINP04 - Too many sources.  Max is 'i3)
        RETURN
      END IF  !
C
      IF  (.NOT.KORBIT) THEN  !"non-orbit"
         ciauna(nceles)= ciau
         csorna(nceles)= cname
        IF  (EPOCH.NE.2000.0) THEN  !"convert to J2000"
          IEP = EPOCH+.01 
          IF  (IEP.EQ.1950) THEN ! reference frame rotation
            call prefr(rarad,decrad,1950,r,d)
            RARAD = R
            DECRAD = D
          ELSE  ! full precession
            tjd=julda(1,1,iep-1900)+2440000.d0
            call mpstar_rad(tjd,rarad,decrad)
          END IF  !
        END IF  !"convert to J2000"
        SORP50(1,NCELES) = RARAD   !J2000 position
        SORP50(2,NCELES) = DECRAD  !J2000 position
        call ckiau(ciau,ccom,rarad,decrad,lu)
      ELSE  !"satellite"
C       IDUMMY = ICHMV(LSORNA(1,MAX_CEL+NSATEL),1,LIAU,1,max_sorlen)
!        IDUMMY = ICHMV(LSORNA(1,MAX_CEL+NSATEL),1,lname,1,max_sorlen)
        csorna(max_cel+nsatel)=cname
        SATP50(1,NSATEL) = OINC
        SATP50(2,NSATEL) = OECC
        SATP50(3,NSATEL) = OPER
        SATP50(4,NSATEL) = ONOD
        SATP50(5,NSATEL) = OANM
        SATP50(6,NSATEL) = OAXS
        SATP50(7,NSATEL) = OMOT
        ISATY(NSATEL)=IEPY 
        SATDY(NSATEL)=OEDY
      END IF  !"satellite"
C
      RETURN
      END

      SUBROUTINE VSOINP(ivexnum,lu,ierr)
C
C     This routine gets all the source information
C     and stores it in common.
C **NOTE** No satellite support yet.
C
      include '../skdrincl/skparm.ftni'
      include '../skdrincl/sourc.ftni'
C
C History:
C 960527 nrv New.
C 970114 nrv Change 8 to max_sorlen
C
C INPUT:
      integer ivexnum ! vex file number 
      integer lu ! unit for writing error messages
C
C OUTPUT:
      integer ierr ! error number, non-zero is bad
C
C LOCAL:
      integer iret ! return from vex routines
      double precision rah,decd,radh,decdd,tjd ! for APSTAR
      integer isor,ierr1,i,iep,j,il,idum
      character*128 cout
      integer julda,ichcm_ch,ichmv ! functions
      integer ptr_ch,fget_source_def,fvex_len
      LOGICAL KNAEQ,kblank
      integer*2 LIAU(max_sorlen/2),LCOM(max_sorlen/2),
     .lname(max_sorlen/2)
      double precision RARAD,DECRAD,r,d
C
C     1. First get all the def names 
C
      ierr1=0
      nsourc=0
      iret = fget_source_def(ptr_ch(cout),len(cout),ivexnum) ! get first one
      do while (iret.eq.0.and.fvex_len(cout).gt.0)
        IF  (nsourc.eq.MAX_SOR) THEN  !
          write(lu,'("VSOINP20 - Too many sources.  Max is ",
     .    i3,".  Ignored: ",a)') MAX_SOR,cout
        else
          nsourc=nsourc+1
          sordefnames(nsourc)=cout
          iret = fget_source_def(ptr_ch(cout),len(cout),0) ! get next one
        END IF 
      enddo

C     2. Now call routines to retrieve all the source information.

      nceles = 0
      nsatel = 0
      do isor=1,nsourc ! get each source information

        CALL vunpso(sordefnames(isor),ivexnum,iret,ierr,lu,
     .  liau,lcom,RARAD,DECRAD,iep)
        if (ierr.ne.0) then 
          il=fvex_len(sordefnames(isor))
          write(lu,'("VSOINP01 - Error getting $SOURCE information",
     .    " for ",a/"iret=",i5," ierr=",i5)') sordefnames(isor)(1:il),
     .    iret,ierr
          ierr1=1
        endif
C
C     3. Decide which source name to use.  If there is a common
C     name, use that, otherwise use the IAU name.  If IAU is blank,
C     then make both the same.
C
        if (ierr1.eq.0) then ! continue
        kblank=.true.
        do i=1,max_sorlen
          if (ichcm_ch(liau,i,' ').ne.0) kblank=.false.
        enddo
        if (kblank) then ! use common name
          IDUM = ICHMV(lname,1,lcom,1,max_sorlen)
        else
          IDUM = ICHMV(lname,1,LIAU,1,max_sorlen)
          IF (ichcm_ch(LCOM(1),1,'$ ').ne.0) 
     .              IDUM = ICHMV(lname,1,LCOM,1,max_sorlen)
        endif
C
C     Then check for a duplicate name.  This should not happen
C     in the SKED environment but might as well check.
C     Check up to those source names found so far (isor-1).
        j=1
        DO WHILE (j.le.isor-1.and..NOT.KNAEQ(lname,LSORNA(1,j),
     .  max_sorlen/2))
          j=j+1
        END DO
        IF  (j.Lt.isor) then ! duplicate source
          write(lu,9101) (lsorna(j,isor),j=1,max_sorlen/2)
9101      format('SOINP22 - Duplicate source name ',20a2,
     .    '. Using the position of the first one.')
        endif ! duplicate source
C
C     2. Move the new variables into place.
C
        NCELES=NCELES+1
        IF  (NCELES.GT.MAX_CEL) THEN  !"celestial overflow"
          write(lu,9201) max_cel
9201      format('SOINP02 - Too many celestial sources.  Max is 'i3)
          RETURN
        ENDIF
C
        IDUM = ICHMV(LSORNA(1,NCELES),1,lname,1,max_sorlen)
        IF  (iep.NE.2000) THEN  !"convert to J2000"
          IF  (IEP.EQ.1950) THEN ! reference frame rotation
            call prefr(rarad,decrad,1950,r,d)
            RARAD = R
            DECRAD = D
          ELSE  ! full precession
            tjd=julda(1,1,iep-1900)+2440000.d0
            rah = RARAD*12.d0/pi
            decd = DECRAD*180.d0/pi
            call mpstar(tjd,3,rah,decd,radh,decdd)
            RARAD=radh*pi/12.d0
            DECRAD=decdd*pi/180.d0
          END IF  !
        END IF  !"convert to J2000"
        SORP50(1,NCELES) = RARAD   !J2000 position
        SORP50(2,NCELES) = DECRAD  !J2000 position
        call ckiau(liau,lcom,rarad,decrad,lu)
        endif ! continue
C
      enddo ! get each source information

      ierr=ierr1
      RETURN
      END

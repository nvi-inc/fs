      SUBROUTINE SOINP(cbuf,lu,IERR)
! Parse source info contained in cbuf.
! 2007Jul03 JMG. Rewritten to use ASCII
! This can handle both sources and satellites (although we don't use satellites anywhere?)

! Typical source line looks like:
!  0008-264 $        00 11  1.24676914  -26 12 33.3762017 2000.0 0.0

      include '../skdrincl/skparm.ftni'
      include '../skdrincl/constants.ftni'
      include '../skdrincl/sourc.ftni'
C
C  INPUT:
      character*(*) cbuf              	!ascii string holding input
      integer lu                        !LU to write stuff to.
C  OUTPUT:
      integer ierr

! Functions
      integer iwhere_in_String_list
      integer julda             !julian day

! Local
! used to parse input line.
      logical ktoken,knospace,keof
      character*20 ltoken(20)   !need to be able to hold source name.
      integer numwant,numgot

! temporary name for sources.
      character*(max_sorlen) cname

      real*8 rha,  rha_min, rha_sec    !RHA
      real*8 rdec, rdec_min,rdec_sec   !declination
      real*8 dsign

      real*8 rarad,decrad,r,d           !ra,dec in radians

      integer i,j                      	!loop counters
      real*8  epoch                     !epoch of source position
      integer iep                       !expressed as integer
      real*8 tjd                        !Time in Julian days.

! Start of code.

! NEed to have at least enough space for names.
      if(max_sorlen .gt. 20) then
         writE(*,*) "Recompile soinp and increase token size"
      endif

      NumWant=12
      call splitNtokens(cbuf,ltoken,NumWant,NumGot)

      if(NumGot .lt. 9) then
         write(lu,*) "SOINP:  Not enough tokens in source line: ",NumGot
         write(lu,*) "    "//cbuf(1:80)
      endif

      call capitalize(ltoken(2))
      if(ltoken(2) .eq. "ORBIT") then
        NSATEL=NSATEL+1
        IF  (NSATEL.GT.MAX_CEL) THEN  !"celestial overflow"
          write(lu,"('SOINP02: Too many celestial sources! Max=',i3)")
     >       max_cel
          RETURN
        endif
        csorna(max_cel+nsatel)=ltoken(1)

        do j=1,7
          ierr=j+2
          read(ltoken(ierr),*, err=800) SATP50(j,NSATEL)
        end do
        ierr=10
        read(ltoken(ierr),*,err=800) isaty(nsatel)
        ierr=11
        read(ltoken(ierr),*,err=800) satdy(nsatel)
      else
! Get the source name(s)
        if(ltoken(2) .eq. "$") then
          cname=ltoken(1)
        else
          cname=ltoken(2)
        endif

        i=iwhere_in_string_list(csorna,nsourc,cname)

        IF  (I.ne.0) then ! duplicate source
          write(lu,9101) csorna(i)
9101       format('SOINP22: Duplicate source name ',a,
     .    '. Using the position of the first one.')
        RETURN
        endif ! duplicate source

        NCELES=NCELES+1
        IF  (NCELES.GT.MAX_CEL) THEN  !"celestial overflow"
          write(lu,"('SOINP03: Too many celestial sources! Max=',i3)")
     >       max_cel
          RETURN
        ENDIF
        ciauna(nceles)=ltoken(1)
        csorna(nceles)=cname

! Read in HA
        ierr=3
        read(ltoken(3),*,end=900) rha
        if(ltoken(3)(1:1) .eq. "-") then
          dsign=-1
          ltoken(3)(1:1)=" "
        else
          dsign=1
        endif
        read(ltoken(3),*,end=900) rha

        ierr=4
        read(ltoken(4),*,end=900) rha_min
        ierr=5
        read(ltoken(5),*,end=900) rha_sec
        rarad=dsign*(rha+(rha_min+rha_sec/60.d0)/60.d0)*HA2RAD

! Read in Declination
        ierr=6
        read(ltoken(6),*,end=900) rdec
        if(ltoken(6)(1:1) .eq. "-") then
          dsign=-1
          ltoken(6)(1:1) =" "
        else
          dsign=1
        endif
        read(ltoken(6),*,end=900) rdec

        ierr=7
        read(ltoken(7),*,end=900) rdec_min
        ierr=8
        read(ltoken(8),*,end=900) rdec_sec
        decrad=dsign*(rdec+(rdec_min+rdec_sec/60.d0)/60.d0)*deg2rad

! Read in the epoch.
        ierr=9
        read(ltoken(9),*,end=900) epoch
        
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

        call ckiau(ciauna(nceles),cname,rarad,decrad,lu)
      endif
      nsourc=nsourc+1

      
      ierr=0
      RETURN

! Error on reading in line.
800   continue
900   continue
      write(lu,'("Error in ",i4, " token of line ",/a)') ierr,
     >   cbuf(1:80)
      return
      end

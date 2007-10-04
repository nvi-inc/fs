      SUBROUTINE wrllines(cloifname,cfrcode,nfr,ierr)
C
C  WRLLINES writes the "L" lines for the $CODES section,
C  for one frequency code.
C
C   HISTORY:
C 951130 nrv New.
C 960121 nrv Do not write out switching or channel index.
C 960223 nrv Change call for UNPLOIF, remove bbc and lb from this call.
C 960515 nrv Add ICHANSAVE to call
! 2005May19 JMGipson. ic,ichansave removed from call. Never used.
! 2005Oct06 JMGipson. Got rid of all holleriths.
C
      include '../skdrincl/skparm.ftni'
      include 'skcom.ftni'
      include '../skdrincl/statn.ftni'
C
C Input:
      character*2 cfrcode
      integer nfr(max_stn) ! number of freq channels
      character*8 cloifname(max_stn)

C  OUTPUT:
      integer ierr ! if error writing scratch file
C
C   SUBROUTINES
C     CALLED BY: WRFRS
C     CALLED: UNPLOIF
C
C  LOCAL VARIABLES
! function
      integer trimlen
      integer ilen,is,nch
      integer iw

      logical lcont

      integer MaxToken
      integer NumToken
      parameter(MaxToken=8)
      character*8 ltoken(MaxToken)
      logical keof
      logical kfound

C
C  1. Open the catalog. 
 
      open(lucat,file=loif_cat,status='old',iostat=ierr)
      nch = trimlen(loif_cat)
      if (ierr.ne.0) then
        write(luscn,9011) ierr,loif_cat(1:nch)
9011    format('Error ',i5,' opening catalog ',a)
        close(lucat)
        close(lutmp)
        return
      endif
      write(luscn,9010) loif_cat(1:nch)
9010  format(A,':')
      iw=0

C  2. Loop over each station

      do is=1,nstatn ! all stations
        rewind(lucat,iostat=ierr)
        if (ierr.ne.0) return
        kfound=.false.
100     continue
        call skip_to_next_cat_group(keof)
        if(keof) goto 190

        call splitNtokens(cbuf,ltoken,Maxtoken,NumToken)
        if(ltoken(1)(1:8) .ne. cloifname(i)) goto 100

! Found a match
        WRITE(LUSCN,'(A,"(",a,") ",$)' cloifname(is),cantna(is)
        iw=iw+1
        if (iw.eq.4) then
          write(luscn,'()')
          iw=0
        endif

! Now write out the L lines.
        do while(.true.)
          call skip_to_next_non_comment(keof)
          if(keof) goto 190
          call splitNtokens(cbuf,ltoken,Maxtoken,NumToken)
          if(ltoken(1) .ne. "-") goto 190
! Token     1   2   3        4      5       6
!              ibbc lif     band    clo     csb
!           -   1   A        X    7600.1    U
! Write it out in a different order.
           write(lutmp,"('L ',7(a,1x))")
     >       cstcod(is),cfrcode,ltoken(4)(1:2),ltoken(3)(1:2),ltoken(5),
     >       ltoken(2)(1:2),ltoken(6)
         enddo ! get extension lines

        if (.not.kfound) then
          WRITE(LUSCN,9102) cloifname(is),cantna(is)
9102      format(/'WRLLINES01 - LO name ',a,' for ',a,
     .          ' not in catalog.')
        endif
      enddo ! all stations

      ierr=0
      write(luscn,'()')
      close(lucat)

      RETURN
      END

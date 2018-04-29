      subroutine wrsor(csname,irah,iram,ras,ldsign2,idecd,idecm,decs,lu)
! Write out VLBA source name in the format:
!     sname='1053+704'  ra=10h56m53.6s dec=+70d11'46"
C Write the line in the VLBA flies with the source name
C 970509 nrv New. Extracted from VLBAT.
C 980409 nrv Get rid of data statement to clean up output.
! 2006Sep26. Rewritten to use standard fortran write.

      include '../skdrincl/skparm.ftni'
      include 'drcom.ftni'
      include '../skdrincl/sourc.ftni'

! function
      integer trimlen

C Input
      character*8 csname
      integer irah,iram
      real ras
      integer*2 ldsign2
      integer idecd,idecm
      real decs
      integer lu
C Local
      character*2 ctemp
      integer*2 itemp
      equivalence (ctemp,itemp)
      character*1 lsq, ldq  !used to hold single and double quotes.

      character*11 lra      !used to hold RA
      character*10 ldec     !used to hold Dec strings.

      integer idecs
      lsq="'"   !single quote
      ldq='"'   !double quote

      IDECS = DECS+0.5
      if (idecs.ge.60) then
        idecs=idecs-60
        idecm=idecm+1
      endif
      if (idecm.ge.60) then
        idecm=idecm-60
        idecd=idecd+1
      endif

      write(lra,'(i2.2,"h",i2.2,"m",f4.1,"s")') irah,iram,ras
!        120h56m53.6s
!        123456789x12345
      if(lra(8:8)  .eq. " ") lra(8:8)="0"
      if(lra(7:7)  .eq. " ") lra(7:7)="0"

      itemp=ldsign2
      write(ldec,'(a1,i2.2,"d",i2.2,a1,i2.2,a1)')
     >   ctemp(1:1), idecd,idecm,lsq,idecs,ldq
!      if(ldec(1:1)  .eq. "+") ldec(1:1)=" "

      write(lu,'("sname=",a,"  ra=",a," dec=",a)')
     >       lsq//csname(1:trimlen(csname))//lsq, lra,ldec
      return
      end

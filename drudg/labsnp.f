      SUBROUTINE LABSNP(nlabpr,iyear,iin,fileptr)
C  Write tape labels from reading the SNAP file
C
C NRV 901206 New routine
C nrv 930412 implicit none
C 960814 nrv Allow upper/lower case in SNAP file
C 970122 nrv Add IIN, FILEPTR to call. Call make_pslabel.

      include '../skdrincl/skparm.ftni'
      include 'drcom.ftni'
      include '../skdrincl/statn.ftni'
      include '../skdrincl/skobs.ftni'
C
C Input:
      integer iyear ! year of the SNAP file
      integer fileptr ! pointer for PS file
      integer iin ! 1=laser/epson, 2=ps
c Output:
      integer nlabpr ! number of labels actually printed
C Local
      integer*2 lstnam(4),lco
      integer iy1(5),id1(5),ih1(5),im1(5),id2(5),ih2(5),im2(5)
      integer iy1900,ipsd1,ipsh1,ipsm1,ipsd2,ipsh2,ipsm2,ntape
      integer nout,newlab,idayr,ihr,imn,idayr2,ihr2,imn2,idum
      INTEGER   IERR
      character*128 cbuf,cbuf1
      character*9 cti
      integer ichmv

C
C 1.  Initialize variables

      nout = 0
      ntape = 0
      nlabpr = 0
      newlab = 1
      idum = ichmv(lstnam,1,lstnna(1,1),1,8)
      idum = ichmv(lco,1,lstcod(1),1,2)

C 2. Loop over SNAP records

      do while (.true.) ! read loop
        read(lu_infile,'(a)',err=990,end=901,iostat=IERR) cbuf1
          call c2upper(cbuf1,cbuf)
        if (cbuf(1:1).ne.'"') then !non-comment line
        if (index(cbuf,'UNLOD').ne.0) then
          if (nout.ge.nlab) then !print a row
            if (iin.eq.1) then ! laser or Epson
              call blabl(luprt,nout,lexper,lstnna(1,1),lstcod(1),
     .        iy1,id1,ih1,im1,id2,ih2,im2,ilabrow,cprttyp,cprport)
              nout = 0
              ilabrow = ilabrow + 1
              if (ilabrow.gt.8) ilabrow=ilabrow-8
            else ! postscript
              ntape=ntape+1
              iy1900=iy1(1)-1900
              ipsd1=id1(1)
              ipsh1=ih1(1)
              ipsm1=im1(1)
              ipsd2=id2(1)
              ipsh2=ih2(1)
              ipsm2=im2(1)
              call make_pslabel(fileptr,lstnam,lco,lexper,
     .        iy1900,ipsd1,ipsh1,ipsm1,ipsd2,ipsh2,ipsm2,ntape)
              NOUT = 0
            endif ! laser/Epson/ps
          endif
          newlab = 1
        else if (index(cbuf,'!').ne.0) then
          if (cbuf(2:2).ge.'0'.and.cbuf(2:2).le.'9') then ! valid day
            cti = cbuf(2:10)
          endif ! valid day
        else if (index(cbuf(1:2),'ST').ne.0) then
          read(cti,'(i3,3i2)') idayr,ihr,imn
          if (newlab.eq.1) then
            nout = nout + 1
            nlabpr = nlabpr + 1
            iy1(nout) = iyear
            id1(nout) = idayr
            ih1(nout) = ihr
            im1(nout) = imn
            newlab = 0
          endif
        else if (index(cbuf(1:2),'ET').ne.0) then
          read(cti,'(i3,3i2)') idayr2,ihr2,imn2
          id2(nout) = idayr2
          ih2(nout) = ihr2
          im2(nout) = imn2
        endif ! UNLOD
        endif !non=comment line
      enddo !read loop
901   if (iin.eq.1) then
        if (cprttyp.eq.'LASER'.or.cprttyp.eq.'FILE') 
     .  call blabl(luprt,nout,lexper,
     .  lstnna(1,1),lstcod(1),
     .  iy1,id1,ih1,im1,id2,ih2,im2,ilabrow,cprttyp,cprport)
      else
        iy1900=iy1(1)-1900
        ipsd1=id1(1)
        ipsh1=ih1(1)
        ipsm1=im1(1)
        ipsd2=id2(1)
        ipsh2=ih2(1)
        ipsm2=im2(1)
        call make_pslabel(fileptr,lstnam,lco,lexper,
     .  iy1900,ipsd1,ipsh1,ipsm1,ipsd2,ipsh2,ipsm2,ntape)
      endif

990   RETURN
      end

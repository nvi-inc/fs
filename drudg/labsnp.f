      SUBROUTINE LABSNP(nlabpr,iyear,inew)
C  Write tape labels from reading the SNAP file
C
C NRV 901206 New routine
C nrv 930412 implicit none
C 960814 nrv Allow upper/lower case in SNAP file
C 970122 nrv Add IIN, FILEPTR to call. Call make_pslabel.
C 970228 nrv Remove IIN and use clabtyp instead
C 970312 nrv Update clabtyp name checking for barcode cartridge
C 970827 nrv Add irow,icol,inewpage to make_pslabel call.
C 980916 nrv Read both kinds of SNAP files, with and without year.
! 2005Aug04 JMGipson.  Modifed make_pslabel to accept 8 character
!            tape_label ctape_num. This is so we can use this
!            for VSN#s.

      include '../skdrincl/skparm.ftni'
      include 'drcom.ftni'
      include '../skdrincl/statn.ftni'
      include '../skdrincl/skobs.ftni'
C
C Input:
      integer iyear ! year of the SNAP file
      integer inew ! 1=start new ps file
c Output:
      integer nlabpr ! number of labels actually printed
C Local
      integer iy1(5),id1(5),ih1(5),im1(5),iy2(5),id2(5),ih2(5),im2(5)
      integer ipsy1,ipsd1,ipsh1,ipsm1,ipsy2,ipsd2,ipsh2,ipsm2,ntape
      integer nout,newlab,idayr,ihr,imn,idayr2,ihr2,imn2
      INTEGER   IERR
      character*128 ctmp,ctmp1
      character*20 cti,ctiformat,cctiformat
      character*8 ctape_num

C
C 1.  Initialize variables

      nout = 0
      ntape = 0
      nlabpr = 0
      newlab = 1

C 2. Loop over SNAP records

      do while (.true.) ! read loop
        read(lu_infile,'(a)',err=990,end=901,iostat=IERR) ctmp1
          call c2upper(ctmp1,ctmp)
        if (ctmp(1:1).ne.'"') then !non-comment line
        if (index(ctmp,'UNLOD').ne.0) then
          if (nout.ge.nlab) then !print a row
            if (clabtyp.ne.'POSTSCRIPT' .and. clabtyp .ne. 'DYMO') then ! laser or Epson
              call blabl(luprt,nout,cexper,cstnna,cstcod,
     .        iy1,id1,ih1,im1,iy2,id2,ih2,im2,ilabrow,
     .        cprttyp,clabtyp,cprport)
              nout = 0
              ilabrow = ilabrow + 1
              if (ilabrow.gt.8) ilabrow=ilabrow-8
            else ! postscript
              ntape=ntape+1
              ipsy1=mod(iyear,100)
              ipsd1=id1(1)
              ipsh1=ih1(1)
              ipsm1=im1(1)
              ipsd2=id2(1)
              ipsh2=ih2(1)
              ipsm2=im2(1)
              write(ctape_num,'("Tape ",i2)') ntape
              call make_pslabel(fileptr,cstnna(istn),cstcod(istn),
     >           cexper,clabtyp,ctape_num,
     .        ipsy1,ipsd1,ipsh1,ipsm1,ipsy2,ipsd2,ipsh2,ipsm2,
     .        inew,rlabsize,ilabrow,ilabcol,inewpage)
              ilabcol=ilabcol+1
              if (ilabcol.gt.rlabsize(4)) then
                ilabcol=1
                ilabrow=ilabrow+1
                if (ilabrow.gt.rlabsize(3)) then
                  ilabrow=1
                  inewpage=1
                endif
              endif
              NOUT = 0
            endif ! laser/Epson/ps
          endif
          newlab = 1
        else if (index(ctmp,'!').ne.0) then
          call timin(ctmp,cti,ctiformat,cctiformat,iyear)
        else if (index(ctmp(1:2),'ST').ne.0) then
          read(cti,ctiformat) idayr,ihr,imn
          if (newlab.eq.1) then
            nout = nout + 1
            nlabpr = nlabpr + 1
            iy1(nout) = iyear
            id1(nout) = idayr
            ih1(nout) = ihr
            im1(nout) = imn
            newlab = 0
          endif
        else if (index(ctmp(1:2),'ET').ne.0) then
          read(cti,ctiformat) idayr2,ihr2,imn2
          iy2(nout) = iyear
          id2(nout) = idayr2
          ih2(nout) = ihr2
          im2(nout) = imn2
        endif ! UNLOD
        endif !non=comment line
      enddo !read loop
901   if (clabtyp.ne.'POSTSCRIPT'.and. clabtyp .ne. 'DYM0') then
        if (clabtyp.eq.'LASER+BARCODE_CARTRIDGE'.or.cprttyp.eq.'FILE') 
     .  call blabl(luprt,nout,cexper,cstnna,cstcod,
     .  iy1,id1,ih1,im1,iy2,id2,ih2,im2,ilabrow,cprttyp,clabtyp,cprport)
      else
        ipsy1=mod(iyear,100)
        ipsd1=id1(1)
        ipsh1=ih1(1)
        ipsm1=im1(1)
        ipsd2=id2(1)
        ipsh2=ih2(1)
        ipsm2=im2(1)
        write(ctape_num,'("Tape ",i2)') ntape
        call make_pslabel(fileptr,cstnna(istn),cstcod(istn),
     >           cexper,clabtyp,ctape_num,
     .  ipsy1,ipsd1,ipsh1,ipsm1,ipsy2,ipsd2,ipsh2,ipsm2,
     .        inew,rlabsize,ilabrow,ilabcol,inewpage)
      endif

990   RETURN
      end

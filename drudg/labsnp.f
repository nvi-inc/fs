	SUBROUTINE LABSNP(nlabpr,iyear)
C  Write tape labels from reading the SNAP file
C
C NRV 901206 New routine
C nrv 930412 implicit none

      include '../skdrincl/skparm.ftni'
      include 'drcom.ftni'
      include '../skdrincl/statn.ftni'
C
C Input:
	integer iyear ! year of the SNAP file
c Output:
	integer nlabpr ! number of labels actually printed
C Local
	integer iy1(5),id1(5),ih1(5),im1(5),id2(5),ih2(5),im2(5)
      integer nout,newlab,idayr,ihr,imn,idayr2,ihr2,imn2
      INTEGER   IERR
	character*128 cbuf
Cinteger*4 ifbrk
	character*9 cti

C
C 1.  Initialize variables

	nout = 0
	nlabpr = 0
	newlab = 1

C 2. Loop over SNAP records

	do while (.true.) ! read loop
C  if (ifbrk().lt.0) goto 990
	  read(lu_infile,'(a)',err=990,end=901,iostat=IERR) cbuf
	  if (cbuf(1:1).ne.'"') then !non-comment line
	  if (index(cbuf,'UNLOD').ne.0) then
	    if (nout.ge.nlab) then !print a row
		call blabl(luprt,nout,lexper,lstnna(1,1),lstcod(1),
     .      iy1,id1,ih1,im1,id2,ih2,im2,ilabrow,cprttyp,cprport)
		nout = 0
		ilabrow = ilabrow + 1
		if (ilabrow.gt.8) ilabrow=ilabrow-8
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
	  endif
	  endif !non=comment line
	enddo !read loop
901   if (cprttyp.eq.'LASER'.or.cprttyp.eq.'FILE') 
     .call blabl(luprt,nout,lexper,
     .lstnna(1,1),lstcod(1),
     .iy1,id1,ih1,im1,id2,ih2,im2,ilabrow,cprttyp,cprport)

990   RETURN
      end

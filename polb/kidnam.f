      logical function kidnam(ibuf,idbuf)

      character*(*) ibuf,idbuf
C
      character*63 dirpath,dirpathd,ds,dsd
      character*16 name,named
      character*4 typex,typexd,typexf
      character*40 qual,quald
      integer sc,scd,type,typed,size,sized,rl,rld
c
cxx      call fmpparsepath(ibuf,dirpath,name,typex,qual,sc,type,size,rl,ds)
cxx      call fmpparsepath(idbuf,dirpathd,named,typexd,quald,scd,typed,
cxx     &                  sized,rld,dsd)
c
      if (dirpath.eq.' ') dirpath=dirpathd
      if (name   .eq.' ') name   =named
      if (typex  .eq.' ') typex  =typexd
      if (qual   .eq.' ') qual   =quald
      if (sc     .eq.0  ) sc     =scd
      if (type   .eq.0  ) type   =typed
      if (size   .eq.0  ) size   =sized
      if (rl     .eq.0  ) rl     =rld
      if (ds     .eq.' ') ds     =dsd
c
      typexf=typex
cxx      call casefold(typexf)
      kidnam=name.ne.' '.and.typexf.ne.'dir'
c
cxx      call fmpbuildpath(ibuf,dirpath,name,typex,qual,sc,type,size,rl,ds)
C
      return
      end

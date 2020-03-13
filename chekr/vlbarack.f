*
* Copyright (c) 2020 NVI, Inc.
*
* This file is part of VLBI Field System
* (see http://github.com/nvi-inc/fs).
*
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program. If not, see <http://www.gnu.org/licenses/>.
*
      subroutine vlbarack(lwho)
C
      include '../include/fscom.i'
C 
C  INPUT: 
      integer*2 lwho
C 
C 
C  SUBROUTINES CALLED:
C 
C
C  LOCAL VARIABLES: 
      integer nbbc,ndist
      integer*2 lmodna(16)
      integer*2 ldistna(2)
      integer icherr(20)
      integer nbbcerr, niferr
C
C
C  INITIALIZED:
      data nbbc/14/,ndist/2/
      data nbbcerr/20/  !! number of possible bbc errors 
      data niferr/5/    !! number of possible if errors 
      data lmodna /2Hb1,2Hb2,2Hb3,2Hb4,2Hb5,2Hb6,2Hb7,2Hb8,2Hb9,2Hba,
     /             2Hbb,2Hbc,2Hbd,2Hbe,2Hbf,2Hbg/
      data ldistna /2Hia,2Hic/
C
C  First loop through the array checking the BaseBand Converters (BBC)
C
      do ibbc=1,nbbc
        do j=1,nbbcerr
          icherr(j)=0
        enddo
        call fs_get_ichvlba(ichvlba(ibbc),ibbc)
        ichecks=ichvlba(ibbc)
        if(ichvlba(ibbc).le.0) then
           bbc_tpi(1,ibbc)=65536
           bbc_tpi(2,ibbc)=65536
           call fs_set_bbc_tpi(bbc_tpi(1,ibbc),ibbc)
           goto 199
        endif
        ierr=0
        call bbchk(ibbc,icherr,ierr)
        if (ierr.ne.0) then
          call logit7(0,0,0,0,ierr,lwho,lmodna(ibbc))
          goto 199
        endif
        call fs_get_ichvlba(ichvlba(ibbc),ibbc)
        if(ichvlba(ibbc).le.0.or.ichecks.ne.ichvlba(ibbc))
     .     goto 199
        do j=1,nbbcerr
          if (icherr(j).ne.0) then
            call logit7(0,0,0,0,-201-j,lwho,lmodna(ibbc))
          endif
        enddo
199     continue
      enddo
C
C Check the if distributors
C
      do idist=1,ndist
        do j=1,niferr
          icherr(j)=0
        enddo
        call fs_get_ichvlba(ichvlba(nbbc+idist),nbbc+idist)
        ichecks=ichvlba(idist+nbbc)
        if(ichvlba(idist+nbbc).le.0) then
           vifd_tpi((idist-1)*2+1)=65536
           call fs_set_vifd_tpi(vifd_tpi,(idist-1)*2+1)
           vifd_tpi((idist-1)*2+2)=65536
           call fs_set_vifd_tpi(vifd_tpi,(idist-1)*2+2)
           goto 299
        endif
        ierr=0
        call distchk(idist,icherr,ierr)
        if (ierr.ne.0) then
          call logit7(0,0,0,0,ierr,lwho,ldistna(idist))
          return
        endif
        call fs_get_ichvlba(ichvlba(nbbc+idist),nbbc+idist)
        if(ichvlba(idist+nbbc).le.0.or.ichecks.ne.ichvlba(idist+nbbc))
     &     goto 299
        do j=1,niferr
          if (icherr(j).ne.0) then
            call logit7(0,0,0,0,-201-j-nbbcerr-(idist-1)*18,lwho,
     &            ldistna(idist))
          endif
        enddo
299     continue
      enddo
C
C Check the formatter
C
      do j=1,5
        icherr(j)=0
      enddo
      in=1+nbbc+ndist
      call fs_get_ichvlba(ichvlba(in),in)
      ichecks=ichvlba(in)
      if(ichvlba(in).le.0) goto 399
C
C it must have been at least 10 seconds since the last formatter configure
c
      call fs_get_ichfm_cn_tm(ichfm_cn_tm)
      call fc_rte_rawt(itime)
      if(ichfm_cn_tm+1000.gt.itime) goto 399
C
      ierr=0
      call vformchk(icherr,ierr)
      if (ierr.ne.0) then
        call logit7ic(0,0,0,0,ierr,lwho,'fm')
      endif
      call fs_get_ichvlba(ichvlba(in),in)
      if(ichvlba(in).le.0.or.ichecks.ne.ichvlba(in)) goto 399
      do j=1,5
        if (icherr(j).ne.0) then
          call logit7ic(0,0,0,0,-201-j-nbbcerr-niferr,lwho,'fm')
        endif
      enddo
C check the formatter time with the computer time
      ierr=0
      ierror=0
      call timechk(ierror,ierr)
      if (ierr.ne.0) then
        call logit7ic(0,0,0,0,ierr,lwho,'fm')
      endif
      if (ierror.ne.0) then
        call logit7ic(0,0,0,0,ierror,lwho,'fm')
      endif
399   continue
C
      return
      end

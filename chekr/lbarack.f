      subroutine lbarack(lwho,ichecks)
C
      include '../include/fscom.i'
C 
C  INPUT: 
      integer*2 lwho
      integer ichecks(1)
C 
C 
C  SUBROUTINES CALLED:
C 
C
C  LOCAL VARIABLES: 
      integer*2 lmodna(16)
      integer*2 ldasna(8)
      integer icherr(20)		! larger of nifperr and ndaserr
      integer nifperr, ndaserr
C
C
C  INITIALIZED:
      data nifperr/20/  !! number of possible ifp errors 
      data ndaserr /7/  !! number of possible das errors 
      data lmodna /2Hp1,2Hp2,2Hp3,2Hp4,2Hp5,2Hp6,2Hp7,2Hp8,2Hp9,2Hpa,
     /             2Hpb,2Hpc,2Hpd,2Hpe,2Hpf,2Hpg/
      data ldasna /2Hs1,2Hs2,2Hs3,2Hs4,2Hs5,2Hs6,2Hs7,2Hs8/
C
C  First loop through the array checking the IF Processors (IFP)
C
      call fs_get_ndas(ndas)
      do iifp=1,2*ndas
        do j=1,nifperr
          icherr(j)=0
        enddo
        call fs_get_ichlba(ichlba(iifp),iifp)
        if(ichlba(iifp).le.0) then
           ifp_tpi(iifp)=65536
           call fs_set_ifp_tpi(ifp_tpi(iifp),iifp)
           goto 199
        endif
        if(ichlba(iifp).le.0.or.ichecks(iifp).ne.ichlba(iifp))
     .     goto 199
        ierr=0
        call ifpchk(iifp,icherr,ierr)
        if (ierr.ne.0) then
          call logit7(0,0,0,0,ierr,lwho,lmodna(iifp))
          goto 199
        endif
        call fs_get_ichlba(ichlba(ifp),ifp)
        if(ichlba(iifp).le.0.or.ichecks(iifp).ne.ichlba(iifp))
     .     goto 199
        do j=1,nifperr
          if (icherr(j).ne.0) then
            call logit7(0,0,0,0,-700-j,lwho,lmodna(iifp))
          endif
        enddo
199     continue
      enddo
C
C Check the integrating hardware of each DAS
C
      do idas=1,ndas
        do j=1,ndaserr
          icherr(j)=0
        enddo
        call fs_get_ichlba(ichlba(2*idas-1),2*idas-1)
        call fs_get_ichlba(ichlba(2*idas),2*idas)
        if((ichlba(2*idas-1).le.0.and.ichlba(2*idas).le.0)
     &     .or.ichecks(2*idas-1).ne.ichlba(2*idas-1)
     &     .or.ichecks(2*idas).ne.ichlba(2*idas))
     &     goto 299
        ierr=0
        call daschk(idas,icherr,ierr)
        if (ierr.ne.0) then
          call logit7(0,0,0,0,ierr,lwho,ldasna(idas))
          return
        endif
        call fs_get_ichlba(ichlba(2*idas-1),2*idas-1)
        call fs_get_ichlba(ichlba(2*idas),2*idas)
        if((ichlba(2*idas-1).le.0.and.ichlba(2*idas).le.0)
     &     .or.ichecks(2*idas-1).ne.ichlba(2*idas-1)
     &     .or.ichecks(2*idas).ne.ichlba(2*idas))
     &     goto 299
        do j=1,ndaserr
          if (icherr(j).ne.0) then
            call logit7(0,0,0,0,-700-j-nifperr,lwho,ldasna(idas))
          endif
        enddo
299     continue
      enddo
C
      return
      end

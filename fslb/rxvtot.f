      subroutine rxvtot(ia,vadc,uadc)
C
C    CONVERT MAT VOLTAGE READINGS TO TEMPERATURES AND PRESSURES
C
C   INPUT PARAMETERS:
C       IA      TYPE OF READING (31,32=TEMPERATURE;  24=PRESSURE)
C       VADC    VOLTAGE
C
C   OUTPUT PARAMETERS:
C       UADC     CONVERTED TEMPERATURE (K) OR PRESSURE (mB)
C
C  INCLUDE FILES:
      include '../include/fscom.i'
C       CONTAINS VFAC :  VOLTAGE DIVIDE RATIOS
C
C  The temperatures and voltages are now read from the control
C  file RXDIODE.CTL in INCOM into the arrays TMPK_FS and PVOLT_FS
C  respectively.  These arrays are declared in the FSCOM.FTNI common
C  file.  The variable NRX_FS, also declared in common, holds the number
C  of values read from the control file.
C   - GAG 901206
C
      uadc = vadc  * vfac(ia)
C
C   LOOKUP AND INTERPOLATE
C
      if (ia.eq.31 .or. ia.eq.32) then         !  calculate temperature
        do il=2,nrx_fs
          if (uadc.ge.pvolt_fs(il) .or. il.eq.nrx_fs) then   !interpolate
            tdif = tmpk_fs(il)-tmpk_fs(il-1)
            vdif = pvolt_fs(il)-pvolt_fs(il-1)
            vmid = uadc-pvolt_fs(il-1)
            uadc = tmpk_fs(il-1)+vmid*tdif/vdif
            return
          endif
        enddo
      else if (ia.eq.24) then               !  calculate pressure
        pres = 62.*(5.0/uadc - 1.0)      ! ***check this equation!*** !
C       IF (PRES.LT.0.0) PRES = 0.0
        uadc = pres
      endif

      return
      end

      logical function kboss()
C
      include '../include/fscom.i'
C
      logical rn_test
C
C     This routine returns the status of BOSS based on the resource
C     allocation variable IRNBOSS_FS.
C
C  WHO  WHEN    DESCRIPTION
C  GAG  901226  Created.
C
      kboss=rn_test('fs   ')
C
      return
      end

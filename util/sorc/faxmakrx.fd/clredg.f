      SUBROUTINE CLREDG(FLDA,XINDEF,CLRLOL,CLRUPR,MKEY,IBIG,JBIG,IRTN)
C$$$  SUBPROGRAM DOCUMENTATION BLOCK
C                .      .    .                                       .
C SUBPROGRAM:    CLREDG      PLACE INDEFINATES AROUND EDGES OF FIELD
C   PRGMMR: KRISHNA KUMAR     ORG: W/NP12    DATE: 1999-08-01
C
C ABSTRACT: PLACE INDEFINATES AROUND THE EDGES OF FLDA.
C
C PROGRAM HISTORY LOG:
C   94-12-28  ORIGINAL AUTHOR HENRICHSEN
C 1999-08-01  KRISHNA KUMAR CONVERTED THIS CODE FROM CRAY TO IBM RS/6000.
C
C USAGE:    CALL CLREDG(FLDA,XINDEF,CLRLOL,CLRUPR,MKEY,IBIG,JBIG,IRTN)
C   INPUT ARGUMENT LIST:
C     FLDA     - REAL*4 UNPACKED DATA FIELD OF SIZE(IBIG,JBIG)
C     XINDEF   - REAL*4 VALUE TO PLACE IN EDGES OF FLDA.
C     CLRLOL   - INTEGER*4 TWO WORD ARRAY THAT CONTAINS THE I,J
C              - COORDINATES OF THE LOWER LEFT CORNER OF SUB FIELD.
C     CLRUPR   - INTEGER*4 TWO WORD ARRAY THAT CONTAINS THE I,J
C              - COORDINATES OF THE UPPER RIGHT CORNER OF SUB FIELD.
C     MKEY     - INTEGER*4 VALUE TO USE TO MULTIPLY CLRLOL AND CLRUPR
C              - BY TO OBTAIN SIZE OF SUB FIELD.
C     IBIG     - MAX SIZE I OF THE BIG FIELD.
C     JBIG     - MAX SIZE J OF THE BIG FIELD.
C
C   OUTPUT ARGUMENT LIST:
C     FLDA     - UNPACKED DATA FIELD WITH INDEFINATES AROUND EDGES.
C     IRTN     - RETURN CONDITION.
C              - = 0 FIELD CLEARED AROUND EDGES.
C              - = 1 MKEY OUT OF BOUNDS, FIELD NOT CLEARED.
C
C REMARKS: NONE
C
C ATTRIBUTES:
C   LANGUAGE: FORTRAN 90
C   MACHINE:  IBM
C
C$$$
      REAL       FLDA(IBIG,JBIG)
      REAL       XINDEF
C
      INTEGER    CLRLOL(2)
      INTEGER    CLRUPR(2)
      INTEGER    MKEY
C
      IF (MKEY .LE. 0 .OR. MKEY .GT. 2) THEN
C
        WRITE(6,FMT='('' CLREDG: ERROR, MKEY'',I2,''IS OUT OF'',
     2      '' BOUNDS! WILL  NOT CLEAR EDGES OF FIELD!'')')MKEY
             IRTN = 1
C
      ELSE
             IRTN = 0
C
C     ISML     - SMALL SIZE I OF THE FIELD.
C     JSML     - SMALL SIZE J OF THE FIELD.
C     ISIKP    - SKIP I OF THE FIELD.
C     JSIKP    - SKIP J OF THE FIELD.
C
C
               IF(MKEY.EQ.2)THEN
C
C               SETING UP TO CLEAR EDGES FOR SUB CNTOR
C               SINCE THE FIELD HAS BEEN FLIPPED UP SIDE DOWN THE
C               THE JSKIP IS CACULATED FROM THE TOP RATHER THAN THE
C               BOTTOM OF THE FIELD.
C
                ISML   = 2*(CLRUPR(1)-CLRLOL(1)+1)
                JSML   = 2*(CLRUPR(2)-CLRLOL(2)+1)
                ISKIP  = 2*CLRLOL(1)
                JSKIP  = 2*((JBIG+1)/2-CLRUPR(2)+1)
                IADD   = -4
                JADD   = -4
C
               ELSE
                ISML   = CLRUPR(1)-CLRLOL(1)+1
                JSML   = CLRUPR(2)-CLRLOL(2)+1
                ISKIP  = CLRLOL(1)
                JSKIP  = CLRLOL(2)
                IADD   = 0
                JADD   = 0
               ENDIF
C
        WRITE(6,FMT='('' CLREDG: MKEY='',I2,'' ISML='',I4,
     1   '' JSML='',I4,'' ISKIP='',I4,'' JSKIP='',I4,'' IBIG='',
     2      I4,'' JBIG='',I4)')
     3      MKEY,ISML,JSML,ISKIP,JSKIP,IBIG,JBIG
C
C       DO BOTTOM PART
C
          DO  J = 1 , JSKIP
             DO  I = 1 , IBIG
                 FLDA(I,J) = XINDEF
             ENDDO
          ENDDO
C
C       DO UPPER PART
C
      JSTART = JSKIP + JSML + JADD
      IF (JSTART .LE. JBIG) THEN
             DO  J=JSTART, JBIG
                DO  I= 1 , IBIG
                    FLDA(I,J) = XINDEF
                ENDDO
             ENDDO
      ENDIF
C
C       DO LEFT-SIDE PORTION
C
          DO  I = 1, ISKIP
             DO  J = 1, JBIG
                 FLDA(I,J) = XINDEF
             ENDDO
          ENDDO
C
C       DO RIGHT-SIDE PORTION
C
      ISTART = ISKIP + ISML + IADD
      IF (ISTART .LE. IBIG) THEN
          DO  I=ISTART, IBIG
             DO  J= 1 , JBIG
                 FLDA(I,J) = XINDEF
             ENDDO
          ENDDO
      ENDIF
      ENDIF
      RETURN
      END
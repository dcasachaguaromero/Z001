*&---------------------------------------------------------------------*
*& Report  ZAM_AJUSTA_TABAS                                            *
*&                                                                     *
*&---------------------------------------------------------------------*
*&                                                                     *
*&                                                                     *
*&---------------------------------------------------------------------*
REPORT ZAM_AJUSTA_TABAS  .
TABLES : ANLC,
         ANLP.

PARAMETERS : BUKRS  LIKE ANLC-BUKRS,
             ANLN1  LIKE ANLC-ANLN1,
             ANLN2  LIKE ANLC-ANLN2,
             GJAHR  LIKE ANLC-GJAHR,
             AFABE  LIKE ANLC-AFABE.


START-OF-SELECTION.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE * FROM ANLC WHERE BUKRS = BUKRS AND
*                                  ANLN1 = ANLN1 AND
*                                  ANLN2 = ANLN2 AND
*                                  GJAHR = GJAHR AND
*                                  AFABE = AFABE.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  FROM ANLC WHERE BUKRS = BUKRS AND
                                  ANLN1 = ANLN1 AND
                                  ANLN2 = ANLN2 AND
                                  GJAHR = GJAHR AND
                                  AFABE = AFABE ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
*
  IF SY-SUBRC = 0.
     move 0 to ANLC-AFBLPE.
     move 0 to ANLC-AFBANZ.
     move 0 to ANLC-NAFAG.
     Update ANLC.
  ENDIF.
*
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE * FROM ANLP WHERE BUKRS  = BUKRS AND
*                                  GJAHR  = GJAHR AND
*                                  ANLN1  = ANLN1 AND
*                                  ANLN2  = ANLN2 AND
*                                  AFABER = AFABE.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  FROM ANLP WHERE BUKRS  = BUKRS AND
                                  GJAHR  = GJAHR AND
                                  ANLN1  = ANLN1 AND
                                  ANLN2  = ANLN2 AND
                                  AFABER = AFABE ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
*
  IF SY-SUBRC = 0.
      Delete ANLP.
  ENDIF.



END-OF-SELECTION.

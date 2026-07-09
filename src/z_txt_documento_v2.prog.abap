*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES03 > *
*& Description: < ReSQ Correction > *
*& Date: <19-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Report  Z_TXT_DOCUMENTO_V2
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  Z_TXT_DOCUMENTO_V2.


TABLES: BSEG, ZLOGTXT.

TYPES: BEGIN OF WABSEF_TYPE,
         BUKRS LIKE BSEG-BUKRS,
         BELNR LIKE BSEG-BELNR,
         GJAHR LIKE BSEG-GJAHR,
         BUZEI LIKE BSEG-BUZEI,
         SGTXT LIKE BSEG-SGTXT,
         LIFNR LIKE BSEG-LIFNR,
       END OF WABSEF_TYPE.

SELECT-OPTIONS: P_BUKRS FOR BSEG-BUKRS.

PARAMETERS:  P_GJAHR LIKE BSEG-GJAHR.
*P_BUKRS LIKE BSEG-BUKRS ,
*            P_GJAHR LIKE BSEG-GJAHR.

* INCLUDE Z_TXT_DOCUMENTO_O01                     .  "  PBO-Modules
* INCLUDE Z_TXT_DOCUMENTO_I01                     .  " PAI-Modules
* INCLUDE Z_TXT_DOCUMENTO_F01                     .  " FORM-Routines
DATA: IT_BSEG TYPE STANDARD TABLE OF WABSEF_TYPE WITH HEADER LINE.
DATA: W_SGTXT LIKE BSEG-SGTXT.
DATA: secuencia(5) TYPE n.
SELECT-OPTIONS: S_BELNR  FOR BSEG-BELNR.

INITIALIZATION.
  AUTHORITY-CHECK OBJECT 'S_TCODE'
     ID 'TCD' FIELD sy-tcode.
  IF sy-subrc NE 0.
    MESSAGE e077(s#) WITH sy-tcode.
  ENDIF.

SELECT BUKRS BELNR GJAHR BUZEI LIFNR FROM BSEG
INTO CORRESPONDING FIELDS OF TABLE IT_BSEG
WHERE BUKRS IN P_BUKRS
AND GJAHR EQ P_GJAHR
AND BELNR IN S_BELNR
AND SGTXT EQ ' '
* AND BSCHL = '25'
AND KOART = 'K' " partida acreedora
*Begin of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 19/12/2019 EY_DES03 ECDK917080 *
*AND LIFNR <> ' '.
AND LIFNR <> ' ' ORDER BY PRIMARY KEY .
*End of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 19/12/2019 EY_DES03 ECDK917080 *

LOOP AT IT_BSEG.
  CLEAR W_SGTXT.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE NAME1 INTO W_SGTXT
*      FROM LFA1
*      WHERE LIFNR = IT_BSEG-LIFNR.
*
* NEW CODE
  SELECT NAME1
  UP TO 1 ROWS  INTO W_SGTXT
      FROM LFA1
      WHERE LIFNR = IT_BSEG-LIFNR ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
  MOVE W_SGTXT TO IT_BSEG-SGTXT.
  MODIFY IT_BSEG.
ENDLOOP.

LOOP AT IT_BSEG.
  UPDATE BSEG SET SGTXT = IT_BSEG-SGTXT
    WHERE BUKRS = IT_BSEG-BUKRS
          AND GJAHR = IT_BSEG-GJAHR
          AND BELNR = IT_BSEG-BELNR
          AND SGTXT EQ ' '.
*          AND BUZEI EQ IT_BSEG-BUZEI.



   SELECT MAX( zkey ) INTO (secuencia)  FROM ZLOGTXT WHERE bukrs  =  IT_BSEG-BUKRS
                               AND   gjahr     =   IT_BSEG-GJAHR
                               AND  BELNR      =  IT_BSEG-BELNR.
   ZLOGTXT-MANDT = SY-MANDT.
   ZLOGTXT-BUKRS = IT_BSEG-BUKRS.
    ZLOGTXT-gjahr = IT_BSEG-GJAHR.
    ZLOGTXT-BELNR = IT_BSEG-BELNR.
    ZLOGTXT-ZKEY = secuencia + 1.
    ZLOGTXT-SGTXT = IT_BSEG-SGTXT.
   ZLOGTXT-ZPROCES = 'ACREEDORES'.
    ZLOGTXT-cpudt = sy-datum.
    ZLOGTXT-cputm = sy-uzeit.
    ZLOGTXT-uname = sy-uname.
    INSERT ZLOGTXT.
ENDLOOP.

MESSAGE 'Los datos han sido actualizados' TYPE 'I'.
LEAVE PROGRAM.

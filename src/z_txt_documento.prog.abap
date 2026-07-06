*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES03 > *
*& Description: < ReSQ Correction > *
*& Date: <19-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Report  Z_TXT_DOCUMENTO
*&
*&---------------------------------------------------------------------*
*& BASADO EN PROGRAMA ZBANREP_001
*&
*&---------------------------------------------------------------------*

INCLUDE Z_TXT_DOCUMENTO_TOP                     .    "  global Data

* INCLUDE Z_TXT_DOCUMENTO_O01                     .  "  PBO-Modules
* INCLUDE Z_TXT_DOCUMENTO_I01                     .  " PAI-Modules
* INCLUDE Z_TXT_DOCUMENTO_F01                     .  " FORM-Routines

DATA: W_SGTXT LIKE BSEG-SGTXT.

SELECT BUKRS BELNR GJAHR BUZEI LIFNR FROM BSEG
INTO CORRESPONDING FIELDS OF TABLE IT_BSEG
WHERE BUKRS EQ P_BUKRS
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
  SELECT SINGLE NAME1 INTO W_SGTXT
      FROM LFA1
      WHERE LIFNR = IT_BSEG-LIFNR.
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
ENDLOOP.

MESSAGE 'Los datos han sido actualizados' TYPE 'I'.
LEAVE PROGRAM.

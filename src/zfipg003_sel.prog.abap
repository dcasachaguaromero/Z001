*&---------------------------------------------------------------------*
*&  Include           ZFIPG003_SEL
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
*                SELECTION-SCREEN
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK marco1 WITH FRAME TITLE TEXT-001.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN: COMMENT 1(20) text0.
SELECTION-SCREEN POSITION 33.
PARAMETERS: bukrs    LIKE bkpf-bukrs     VALUE CHECK  OBLIGATORY .
SELECTION-SCREEN: COMMENT 45(40) text1.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN: COMMENT 1(20) text2.
SELECTION-SCREEN POSITION 33.
PARAMETERS: zlsch    LIKE  bsik-zlsch  OBLIGATORY .
SELECTION-SCREEN: COMMENT 45(40) text3.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK marco1 .

*----------------------------------------------------------------------*
*                AT SELECTION-SCREEN
*----------------------------------------------------------------------*
AT SELECTION-SCREEN ON bukrs.

  AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
     ID 'BUKRS' FIELD bukrs.

  IF sy-subrc <> 0.
*   No authorization for company code
    MESSAGE e526(icc_tr) WITH bukrs.
  ENDIF.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE * FROM t001 WHERE bukrs = bukrs.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  FROM t001 WHERE bukrs = bukrs ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

*----------------------------------------------------------------------*
AT SELECTION-SCREEN ON zlsch.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE * FROM t042z WHERE land1 = 'CL'
*                             AND   zlsch = zlsch.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  FROM t042z WHERE land1 = 'CL'
                             AND   zlsch = zlsch ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

  IF sy-subrc <> 0 OR ( zlsch <> 'C' AND zlsch <> 'T' AND zlsch <> 'V' ).
    MESSAGE e004(zfi) WITH 'Via de Pago no Valida'.

  ENDIF.

  text3 = t042z-text1.

*----------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.

  text1 = t001-butxt.
  text3 = t042z-text1.

*----------------------------------------------------------------------*
*            INITIALIZATION
*----------------------------------------------------------------------*
INITIALIZATION.

  text0 = 'Sociedad'.
  text2 = 'Via de Pago'.

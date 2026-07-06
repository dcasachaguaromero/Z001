REPORT zfipg001
       NO STANDARD PAGE HEADING LINE-SIZE 255.


INCLUDE zfipg001_top.

*----------------------------------------------------------------------*
* Parametros
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK marco1 WITH FRAME TITLE text-001.

SELECTION-SCREEN BEGIN OF LINE.

SELECTION-SCREEN: COMMENT 1(20) text0.

selection-screen POSITION 33.

PARAMETER : bukrs    LIKE bkpf-bukrs     OBLIGATORY .

SELECTION-SCREEN: COMMENT 45(40) text1.

selection-screen END OF LINE.



SELECTION-SCREEN END OF BLOCK marco1 .

*---------------------------------------------------------------------------------

AT SELECTION-SCREEN ON bukrs.

  AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
     ID 'BUKRS' FIELD bukrs.

  IF sy-subrc <> 0.
*--------'No authorization for company code &'------------------------
    MESSAGE e526(icc_tr) WITH bukrs.
  ENDIF.

  SELECT SINGLE * FROM t001 WHERE bukrs = bukrs.


AT SELECTION-SCREEN OUTPUT.

  text1 = t001-butxt.

INITIALIZATION.

  text0 = 'Sociedad'.



START-OF-SELECTION.

  CALL SCREEN 100.


END-OF-SELECTION.

  INCLUDE zfipg001_100.
  INCLUDE zfipg001_200.

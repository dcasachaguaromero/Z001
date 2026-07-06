REPORT ZFIPG001
       NO STANDARD PAGE HEADING LINE-SIZE 255.

INCLUDE zmantenedor_zcb_iter_cc_top.

*----------------------------------------------------------------------*
* Parametros
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK marco1 WITH FRAME TITLE text-001.

PARAMETER : bukrs    LIKE bkpf-bukrs     OBLIGATORY .
PARAMETER : hbkid    LIKE reguh-hbkid     OBLIGATORY .
PARAMETER : hktid    LIKE reguh-hktid     OBLIGATORY .

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


INITIALIZATION.


START-OF-SELECTION.

  CALL SCREEN 100.


END-OF-SELECTION.

  INCLUDE zmantenedor_zcb_iter_cc_100.

  INCLUDE zmantenedor_zcb_iter_cc_200.

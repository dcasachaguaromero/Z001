*&---------------------------------------------------------------------*
*&  Include           ZAFTR0001_SEL
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK block1 WITH FRAME TITLE TEXT-001.

SELECT-OPTIONS : s_bukrs FOR wa_selecc-bukrs OBLIGATORY MEMORY ID buk,
                 s_anln1 FOR wa_selecc-anln1 ,
                 s_anln2 FOR wa_selecc-anln2 .
SELECTION-SCREEN SKIP.
SELECTION-SCREEN BEGIN OF BLOCK block2 WITH FRAME TITLE TEXT-002.
SELECT-OPTIONS : s_anlkl FOR wa_selecc-anlkl,
                 s_kostl FOR wa_selecc-kostl,
                 s_stort FOR wa_selecc-stort,
                 s_anlue FOR wa_selecc-anlue,
                 s_deakt FOR wa_selecc-deakt DEFAULT '00000000'
                                             NO-DISPLAY.
SELECTION-SCREEN END OF BLOCK block2.
*
SELECTION-SCREEN BEGIN OF BLOCK block3 WITH FRAME TITLE TEXT-003.
PARAMETERS     : p_fecha LIKE rbada-brdatu OBLIGATORY.
SELECT-OPTIONS : s_afabe FOR wa_selecc-afabe NO INTERVALS NO-EXTENSION.
SELECTION-SCREEN END OF BLOCK block3.
*
PARAMETERS     : p_vari TYPE disvariant-variant.
SELECTION-SCREEN END OF BLOCK block1.

INITIALIZATION.
  CALL FUNCTION 'LAST_DAY_IN_YEAR_GET'
    EXPORTING
      i_date         = sy-datum
      i_periv        = 'K4'
    IMPORTING
      e_date         = p_fecha
    EXCEPTIONS
      input_false    = 1
      t009_notfound  = 2
      t009b_notfound = 3
      OTHERS         = 4.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

* Process on value request
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_vari.
  PERFORM varianten_auswahl CHANGING p_vari.

AT SELECTION-SCREEN ON BLOCK block1.
  SELECT bukrs afabe waers INTO TABLE gt_t093b
         FROM t093b WHERE bukrs IN s_bukrs.

  LOOP AT gt_t093b INTO wa_t093b.
    AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
      ID 'BUKRS' FIELD wa_t093b-bukrs .
    IF sy-subrc <> 0.
      MESSAGE e899(fi) WITH text-e01 wa_t093b-bukrs.
    ENDIF.
  ENDLOOP.

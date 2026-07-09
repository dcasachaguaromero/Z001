*----------------------------------------------------------------------*
***INCLUDE LZUNID_PRODF01.
*----------------------------------------------------------------------*
FORM zunid_prod_event01.

  TYPES: BEGIN OF lty_total.
           INCLUDE STRUCTURE zunid_prod.
           INCLUDE STRUCTURE vimtbflags.
         TYPES: END OF lty_total.

  FIELD-SYMBOLS: <ls_total> TYPE lty_total.


  LOOP AT total ASSIGNING <ls_total> CASTING.
    IF <ls_total>-vim_action = neuer_eintrag OR
       <ls_total>-vim_action = aendern       OR
       <ls_total>-vim_action = vim_ds_loeschen.
      AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
        ID 'BUKRS' FIELD <ls_total>-bukrs
        ID 'ACTVT' FIELD '02'.
      IF sy-subrc <> 0.
*       Ud. carece de autorización para la sociedad &.
        MESSAGE e460(f5) WITH <ls_total>-bukrs.
      ENDIF.
    ENDIF.
  ENDLOOP.


ENDFORM.

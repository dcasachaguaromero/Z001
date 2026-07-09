*&---------------------------------------------------------------------*
*&  Include           ZFIMOD_EMIS4_F01
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
* Write A Protocol Item                                                *
*----------------------------------------------------------------------*
FORM protocol_output USING pline TYPE protocol_line.

  IF gv_intensified = space.
    FORMAT COLOR COL_NORMAL INTENSIFIED OFF.
    gv_intensified = 'X'.
  ELSE.
    FORMAT COLOR COL_NORMAL INTENSIFIED ON.
    gv_intensified = ' '.
  ENDIF.
  WRITE: /01 sy-vline NO-GAP,
             pline-bukrs      NO-GAP, 10 sy-vline NO-GAP,
             pline-gjahr      NO-GAP, 20 sy-vline NO-GAP,
             pline-belnr      NO-GAP, 34 sy-vline NO-GAP,
             pline-buzei      NO-GAP, 48 sy-vline NO-GAP,
             pline-zzmot_emis NO-GAP, 70 sy-vline NO-GAP.

ENDFORM.


*----------------------------------------------------------------------*
* Get The Data Dictionary Label Of A Table Field                       *
*----------------------------------------------------------------------*
FORM get_label USING    table_name TYPE ddobjname
                        label_type TYPE clike
                        field_name TYPE dfies-fieldname
               CHANGING label      TYPE clike.

  DATA: lt_dfies LIKE dfies OCCURS 0 WITH HEADER LINE.

  CALL FUNCTION 'DDIF_FIELDINFO_GET'
    EXPORTING
      tabname        = table_name
      fieldname      = field_name
      langu          = sy-langu
    TABLES
      dfies_tab      = lt_dfies
    EXCEPTIONS
      not_found      = 1
      internal_error = 2
      OTHERS         = 3.

  IF sy-subrc = 0.
    READ TABLE lt_dfies INDEX 1.
    CASE label_type.
      WHEN 'S'. label = lt_dfies-scrtext_s.
      WHEN 'M'. label = lt_dfies-scrtext_m.
      WHEN 'L'. label = lt_dfies-scrtext_l.
    ENDCASE.
  ENDIF.

ENDFORM.

*----------------------------------------------------------------------*
*  Form FIELDCAT_INIT
*----------------------------------------------------------------------*
FORM fieldcat_init USING rt_fieldcat TYPE slis_t_fieldcat_alv.

  DATA: ls_fieldcat TYPE slis_fieldcat_alv.
  DATA: pos TYPE i VALUE 1.

* Sociedad
  CLEAR ls_fieldcat.
  ls_fieldcat-col_pos       = pos.
  ls_fieldcat-fieldname     = 'BUKRS'.
  ls_fieldcat-ref_fieldname = 'BUKRS'.
  ls_fieldcat-ref_tabname   = 'BKPF'.
  ls_fieldcat-key           = 'X'.
  APPEND ls_fieldcat TO  rt_fieldcat.

* Nro. documento
  CLEAR ls_fieldcat.
  pos = pos + 1.
  ls_fieldcat-col_pos       = pos.
  ls_fieldcat-fieldname     = 'BELNR'.
  ls_fieldcat-ref_fieldname = 'BELNR'.
  ls_fieldcat-ref_tabname   = 'BKPF'.
  APPEND ls_fieldcat TO rt_fieldcat.

* Ejercicio
  CLEAR ls_fieldcat.
  pos = pos + 1.
  ls_fieldcat-col_pos       = pos.
  ls_fieldcat-fieldname     = 'GJAHR'.
  ls_fieldcat-ref_fieldname = 'GJAHR'.
  ls_fieldcat-ref_tabname   = 'BKPF'.
  APPEND ls_fieldcat TO rt_fieldcat.

* Documento ZP
  CLEAR ls_fieldcat.
  pos = pos + 1.
  ls_fieldcat-col_pos       = pos.
  ls_fieldcat-fieldname     = 'BELNR_ZP'.
  ls_fieldcat-ref_fieldname = 'BELNR'.
  ls_fieldcat-ref_tabname   = 'BKPF'.
  ls_fieldcat-seltext_s     = 'DocZP'.
  ls_fieldcat-seltext_m     = 'Docu. ZP'.
  ls_fieldcat-seltext_l     = 'Documento ZP'.
  ls_fieldcat-ddictxt       = 'M'.
  APPEND ls_fieldcat TO rt_fieldcat.

* Ejercicio ZP
  CLEAR ls_fieldcat.
  pos = pos + 1.
  ls_fieldcat-col_pos       = pos.
  ls_fieldcat-fieldname     = 'GJAHR_ZP'.
  ls_fieldcat-ref_fieldname = 'GJAHR'.
  ls_fieldcat-ref_tabname   = 'BKPF'.
  ls_fieldcat-seltext_s     = 'EjeZP'.
  ls_fieldcat-seltext_m     = 'Ejerc. ZP'.
  ls_fieldcat-seltext_s     = 'Ejercicio ZP'.
  ls_fieldcat-ddictxt       = 'S'.
  APPEND ls_fieldcat TO rt_fieldcat.

  CLEAR ls_fieldcat.
  pos = pos + 1.
  ls_fieldcat-col_pos       = pos.
  ls_fieldcat-fieldname     = 'ZZMOT_EMIS'.
  ls_fieldcat-ref_fieldname = 'ZZMOT_EMIS'.
  ls_fieldcat-ref_tabname   = 'BSEG'.
  APPEND ls_fieldcat TO rt_fieldcat.

  CLEAR ls_fieldcat.
  pos = pos + 1.
  ls_fieldcat-col_pos       = pos.
  ls_fieldcat-fieldname     = 'LOGTX'.
  ls_fieldcat-seltext_s     = 'Log'.
  ls_fieldcat-seltext_m     = 'Log ejecución'.
  ls_fieldcat-seltext_l     = 'Log de ejecución'.
  ls_fieldcat-ddictxt       = 'L'.
  ls_fieldcat-outputlen     = '50'.
  APPEND ls_fieldcat TO rt_fieldcat.


ENDFORM.   "fieldcat_init

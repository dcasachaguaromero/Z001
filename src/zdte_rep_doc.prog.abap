*&---------------------------------------------------------------------*
*& Report  ZDTE_REP_DOC
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  zdte_rep_doc.
TYPE-POOLS: slis.
TABLES zdte_tabla_doc.
*ZDTE_TABLA_DOC
DATA: BEGIN OF gt_datos OCCURS 0.
        INCLUDE STRUCTURE zdte_tabla_doc.
DATA: END OF gt_datos.

SELECTION-SCREEN BEGIN OF BLOCK a WITH FRAME TITLE text-000.
  SELECT-OPTIONS s_bukrs FOR zdte_tabla_doc-bukrs no INTERVALS no-EXTENSION MEMORY ID buk.

SELECTION-SCREEN END OF BLOCK a.


START-OF-SELECTION.
  "buscar datos.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_datos
*    FROM zdte_tabla_doc
*    WHERE bukrs IN s_bukrs.
*
* NEW CODE
  SELECT *
 INTO CORRESPONDING FIELDS OF TABLE gt_datos
    FROM zdte_tabla_doc
    WHERE bukrs IN s_bukrs ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03


  PERFORM show_alv.

*&---------------------------------------------------------------------*
*&      Form  show_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM show_alv .
  DATA: l_status TYPE slis_formname VALUE 'F_STATUS_ALV'.
  DATA: l_comm   TYPE slis_formname VALUE 'F_USER_COMMAND'.
  DATA: l_repid  TYPE sy-repid.
  DATA: l_layout TYPE slis_layout_alv.
  DATA: t_catalogo TYPE slis_t_fieldcat_alv.
  DATA: t_orden    TYPE slis_t_sortinfo_alv.

  PERFORM f_cargar_layout CHANGING l_layout.
  PERFORM f_cargar_catalogo TABLES t_catalogo.
  l_repid = sy-repid.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
     EXPORTING
        i_bypassing_buffer       = 'X'
        i_callback_program       = l_repid
*      i_callback_pf_status_set = l_status
*      i_callback_user_command  = l_comm
*      i_grid_title             = ''
        is_layout                = l_layout
        it_fieldcat              = t_catalogo
*      it_sort                  = i_orden
        i_save                   = 'X'
      TABLES
        t_outtab                 = gt_datos
      EXCEPTIONS
        program_error            = 1
        OTHERS                   = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    "show_ALV

*&---------------------------------------------------------------------*
*&      Form  f_cargar_layout
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->PS_L_LAYOUT  text
*----------------------------------------------------------------------*
FORM f_cargar_layout  CHANGING ps_l_layout TYPE slis_layout_alv.
  ps_l_layout-zebra = 'X'.
  ps_l_layout-colwidth_optimize = 'X'.
*  ps_l_layout-lights_condense   = 'X'.
*  ps_l_layout-info_fieldname = 'COLOR'.
*  ps_l_layout-coltab_fieldname = 'COLOR_C' .

ENDFORM.                    " F_CARGAR_LAYOUT

*&---------------------------------------------------------------------*
*&      Form  F_CARGAR_CATALOGO
*&---------------------------------------------------------------------*
*   Rutina para crear el catalogo del alv de selección y el de resultado
*----------------------------------------------------------------------*
FORM f_cargar_catalogo  TABLES ps_i_catalogo TYPE slis_t_fieldcat_alv.

  DATA: r_catalogo TYPE slis_fieldcat_alv.

  CLEAR r_catalogo.
  r_catalogo-fieldname     = 'BUKRS'.
  r_catalogo-seltext_m     = 'Sociedad'.
  r_catalogo-ref_tabname   = 'T001'.
  APPEND r_catalogo TO ps_i_catalogo.

    CLEAR r_catalogo.
  r_catalogo-fieldname     = 'BUTXT'.
  r_catalogo-seltext_m     = 'Nombre Sociedad'.
  r_catalogo-ref_tabname   = 'T001'.
  APPEND r_catalogo TO ps_i_catalogo.

  CLEAR r_catalogo.
  r_catalogo-fieldname     = 'RUTEMISOR'.
  r_catalogo-seltext_m     = 'Rut Emisor'.
*  r_catalogo-ref_tabname   = 'T001'.
  APPEND r_catalogo TO ps_i_catalogo.

    CLEAR r_catalogo.
  r_catalogo-fieldname     = 'NAME1'.
  r_catalogo-seltext_m     = 'Nombre Emisor'.
*  r_catalogo-ref_tabname   = 'T001'.
  APPEND r_catalogo TO ps_i_catalogo.

ENDFORM.                                                    " ALV1

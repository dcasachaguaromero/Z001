*&---------------------------------------------------------------------*
*& Report  ZDTE_REP_LB
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  zdte_rep_lb.
TYPE-POOLS: slis.
TABLES: zbmnc_listabcab , zbmnc_listabdet .
*ZDTE_TABLA_DOC
DATA: BEGIN OF gt_datos OCCURS 0.
DATA: bukrs     TYPE zbmnc_listabcab-sociedad      ,
      lifnr     TYPE zbmnc_listabcab-lifnr         ,
      ceco      TYPE zbmnc_listabcab-ceco          ,
      cliente   TYPE zbmnc_listabcab-numero_cliente,
      rutprov   TYPE zbmnc_listabcab-rut_proveedor ,
      porce1    TYPE zbmnc_listabcab-porcentaje    ,
      butxt     TYPE zbmnc_listabcab-butxt         ,
      name1     TYPE zbmnc_listabcab-name1         ,
      ort01     TYPE zbmnc_listabcab-ort01         ,
      codigoprod   TYPE zbmnc_listabdet-codigoprod_cont ,
      cta_contable TYPE zbmnc_listabdet-cta_contable    ,
      porce2       TYPE zbmnc_listabdet-porcentaje ,
      descr     TYPE zbmnc_listabdet-descripcion   .
DATA: END OF gt_datos.

SELECTION-SCREEN BEGIN OF BLOCK a WITH FRAME TITLE text-000.
SELECT-OPTIONS s_bukrs FOR zbmnc_listabcab-sociedad NO INTERVALS NO-EXTENSION MEMORY ID buk.

SELECTION-SCREEN END OF BLOCK a.


START-OF-SELECTION.
  "buscar datos.
  SELECT a~sociedad a~lifnr a~ceco a~numero_cliente a~rut_proveedor a~porcentaje a~butxt a~name1 a~ort01
         b~codigoprod_cont b~cta_contable b~porcentaje b~descripcion
    INTO TABLE gt_datos
    FROM zbmnc_listabcab AS a  INNER JOIN zbmnc_listabdet AS b
     ON a~sociedad  EQ b~sociedad
    AND a~lifnr     EQ b~lifnr
    AND a~ceco      EQ b~ceco
    AND a~numero_cliente EQ b~numero_cliente "CODIGOPROD_CONT
  WHERE a~sociedad IN s_bukrs.


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
  r_catalogo-fieldname     = 'CECO' .
  r_catalogo-seltext_m     = 'Ce.Coste'.
*  r_catalogo-ref_fieldname = 'KOSTL'.
  r_catalogo-ref_tabname   = 'ZBMNC_LISTABCAB'.
  APPEND r_catalogo TO ps_i_catalogo.

  CLEAR r_catalogo.
  r_catalogo-fieldname     = 'LIFNR' .
  r_catalogo-seltext_m     = 'Acreedor'.
  r_catalogo-ref_tabname   = 'LFA1'.
  APPEND r_catalogo TO ps_i_catalogo.

  CLEAR r_catalogo.
  r_catalogo-fieldname     = 'CLIENTE' .
  r_catalogo-seltext_m     = 'Nro.Cliente LB'.
  r_catalogo-ref_fieldname = 'NUMERO_CLIENTE'.
  r_catalogo-ref_tabname   = 'ZBMNC_LISTABCAB'.
  APPEND r_catalogo TO ps_i_catalogo.

   CLEAR r_catalogo.
  r_catalogo-fieldname     = 'RUTPROV' .
  r_catalogo-seltext_m     = 'Rut Emisor Doc.'.
  r_catalogo-ref_fieldname = 'RUT_PROVEEDOR'.
  r_catalogo-ref_tabname   = 'ZBMNC_LISTABCAB'.
  APPEND r_catalogo TO ps_i_catalogo.

  CLEAR r_catalogo.
  r_catalogo-fieldname     = 'PORCE1' .
  r_catalogo-seltext_m     = 'Porcentaje'.
  r_catalogo-ref_tabname   = ''.
  APPEND r_catalogo TO ps_i_catalogo.

*  CLEAR r_catalogo.
*  r_catalogo-fieldname     = 'BUTXT' .
*  r_catalogo-seltext_m     = 'Nombre de la Empresa'.
*  r_catalogo-ref_tabname   = ''.
*  APPEND r_catalogo TO ps_i_catalogo.
*
*  CLEAR r_catalogo.
*  r_catalogo-fieldname     = 'NAME1' .
*  r_catalogo-seltext_m     = 'Nombre1'.
*  r_catalogo-ref_tabname   = ''.
*  APPEND r_catalogo TO ps_i_catalogo.
*
*   CLEAR r_catalogo.
*  r_catalogo-fieldname     = 'ORT01' .
*  r_catalogo-seltext_m     = 'Población'.
*  r_catalogo-ref_tabname   = ''.
*  APPEND r_catalogo TO ps_i_catalogo.
*
  CLEAR r_catalogo.
  r_catalogo-fieldname     = 'CODIGOPROD' .
  r_catalogo-seltext_m     = 'Cod.Unidad y Cod.Producto'.
  r_catalogo-ref_fieldname = 'CODIGOPROD_CONT'.
  r_catalogo-ref_tabname   = 'ZBMNC_LISTABDET'.
  APPEND r_catalogo TO ps_i_catalogo.

  CLEAR r_catalogo.
  r_catalogo-fieldname     = 'CTA_CONTABLE' .
  r_catalogo-seltext_m     = 'Cta.Mayor'.
  r_catalogo-ref_tabname   = 'ZBMNC_LISTABDET'.
  APPEND r_catalogo TO ps_i_catalogo.

   CLEAR r_catalogo.
  r_catalogo-fieldname     = 'PORCE2' .
  r_catalogo-seltext_m     = 'Porcentaje Detalle'.
  r_catalogo-ref_tabname   = ''.
  APPEND r_catalogo TO ps_i_catalogo.

  CLEAR r_catalogo.
  r_catalogo-fieldname     = 'DESCR' .
  r_catalogo-seltext_m     = 'Descripción'.
  r_catalogo-ref_tabname   = ''.
  APPEND r_catalogo TO ps_i_catalogo.

ENDFORM.                                                    " ALV1

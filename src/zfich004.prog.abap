REPORT zfich004.


TABLES: zjdatos_edocheq,
        payr.

* Parametros para ALV
TYPE-POOLS: slis.

DATA:  sort          TYPE slis_t_sortinfo_alv WITH HEADER LINE,
       fieldcat      TYPE slis_t_fieldcat_alv WITH HEADER LINE,
       print         TYPE slis_print_alv,
       layout        TYPE slis_layout_alv.


DATA :   wa_titulo   TYPE lvc_title,
         tit01(10),
         zzmot_emis  LIKE bseg-zzmot_emis,
         name1       LIKE lfa1-name1,
         stcd1       LIKE lfa1-stcd1.

DATA : BEGIN OF tmotivo  OCCURS 1.
        INCLUDE STRUCTURE zfich002.
DATA   END OF tmotivo.

DATA: repid LIKE sy-repid.


DATA: BEGIN OF consulta OCCURS 100,
    bukrs              LIKE zfich001-bukrs,
    hbkid              LIKE zfich001-hbkid ,
    hktid              LIKE zfich001-hktid,
    chect              LIKE zfich001-chect,
    fecha_reg          LIKE zfich001-fecha_reg,
    hora_reg           LIKE zfich001-hora_reg,
    zaldt              LIKE payr-zaldt,
    lifnr              LIKE zfich001-lifnr,
    name1              LIKE lfa1-name1,
    stcd1              LIKE lfa1-stcd1,
    estado             LIKE zfich001-estado,
    belnr              LIKE zfich001-belnr,
    gjahr              LIKE zfich001-gjahr,
    hkont              LIKE zfich001-hkont,
    agencia            LIKE zfich001-agencia ,
    zzmot_emis         LIKE bseg-zzmot_emis,
    rwbtr              LIKE payr-rwbtr,
    usuario            LIKE zfich001-usuario,
    observacion(30)    TYPE c,
 END OF consulta.


DATA: BEGIN OF consulta1 OCCURS 100,
    bukrs              LIKE zfich001-bukrs,
    lifnr              LIKE zfich001-lifnr,
    hbkid              LIKE zfich001-hbkid ,
    hktid              LIKE zfich001-hktid,
    chect              LIKE zfich001-chect,
    fecha_reg          LIKE zfich001-fecha_reg,
    hora_reg           LIKE zfich001-hora_reg,
    zaldt              LIKE payr-zaldt,
    name1               LIKE lfa1-name1,
    stcd1              LIKE lfa1-stcd1,
    estado_d           LIKE zfich002-descri,
    belnr              LIKE zfich001-belnr,
    hkont              LIKE zfich001-hkont,
    agencia            LIKE zfich001-agencia ,
    zzmot_emis         LIKE bseg-zzmot_emis,
    rwbtr              LIKE payr-rwbtr,
    usuario            LIKE zfich001-usuario,
    hbkid_r            LIKE zfich001-hbkid,
    hktid_r            LIKE zfich001-hktid,
    chect_r            LIKE zfich001-chect,
    rwbtr_r            LIKE payr-rwbtr,
    observacion(30)    TYPE c,
    estado             LIKE zfich001-estado,
END OF consulta1.

DATA: BEGIN OF consulta2 OCCURS 100,
    bukrs              LIKE zfich001-bukrs,
    lifnr              LIKE zfich001-lifnr,
    hbkid              LIKE zfich001-hbkid ,
    hktid              LIKE zfich001-hktid,
    chect              LIKE zfich001-chect,
    fecha_reg          LIKE zfich001-fecha_reg,
    hora_reg           LIKE zfich001-hora_reg,
    zaldt              LIKE payr-zaldt,
    name1              LIKE lfa1-name1,
    stcd1              LIKE lfa1-stcd1,
    estado_d           LIKE zfich002-descri,
    belnr              LIKE zfich001-belnr,
    hkont              LIKE zfich001-hkont,
    agencia            LIKE zfich001-agencia ,
    zzmot_emis         LIKE bseg-zzmot_emis,
    rwbtr              LIKE payr-rwbtr,
    usuario            LIKE zfich001-usuario,
    hbkid_r            LIKE zfich001-hbkid,
    hktid_r            LIKE zfich001-hktid,
    chect_r            LIKE zfich001-chect,
    rwbtr_r            LIKE payr-rwbtr,
    observacion(30)    TYPE c,
END OF consulta2.

PARAMETER: bukrs LIKE  zfich001-bukrs    OBLIGATORY MEMORY ID buk.
PARAMETER: p_fecha LIKE  payr-zaldt      OBLIGATORY.
PARAMETER: p_estad LIKE  zfich001-estado OBLIGATORY MATCHCODE OBJECT zz_estadocheque.
PARAMETER: p_motiv LIKE  bseg-zzmot_emis MATCHCODE OBJECT zz_mot_emis.
SELECT-OPTIONS: p_hbkid FOR payr-hbkid.
SELECT-OPTIONS: p_fecemi FOR  payr-zaldt.

SELECT-OPTIONS: p_lifnr FOR  payr-lifnr.

PARAMETER: p_hist AS CHECKBOX.


START-OF-SELECTION.


  SELECT * FROM zjdatos_edocheq  WHERE   ( estado = 'E' ).


    PERFORM  busca_resultado.

  ENDSELECT.

  PERFORM lista.

END-OF-SELECTION.

*&---------------------------------------------------------------------*
*&      Form  busca_resultado
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM busca_resultado.

  SELECT SINGLE * FROM payr WHERE zbukr = zjdatos_edocheq-bukrs
                                AND   hbkid = zjdatos_edocheq-hbkid
                                AND   hktid = zjdatos_edocheq-hktid
                                AND   rzawe = 'C'
                                AND   chect = zjdatos_edocheq-chect.

  IF sy-subrc <> 0.
    SELECT SINGLE * FROM payr WHERE zbukr = zjdatos_edocheq-bukrs
                            AND   hbkid = zjdatos_edocheq-hbkid
                            AND   hktid = zjdatos_edocheq-hktid
                            AND   rzawe = ''
                            AND   chect = zjdatos_edocheq-chect.
  ENDIF.


    if sy-subrc <> 0.
       zjdatos_edocheq-OBSERVACION = 'Cheque no existe en PAYR'.
    endif.


  ENDFORM.                    "busca_resultado
*---------------------------------------------------------------------*
*      Form  lista tabla
*---------------------------------------------------------------------*
FORM lista.

  REFRESH: fieldcat.
  CLEAR: fieldcat, layout, print.

* ALV
* Definicion de parametros de layout
  layout-no_keyfix = ' '.
  layout-zebra = 'X'.
  layout-colwidth_optimize = 'X'.


  wa_titulo = 'Reporte Historial de Cheques'.


*  IF CLIENTE <> 'X'.
*
*    SORT-FIELDNAME = 'NAME_RSM'.
*    SORT-GROUP     = 'X'.
*    SORT-UP        = 'X'.
*    SORT-SUBTOT    = 'X'.
*    APPEND SORT.
*
*    SORT-FIELDNAME = 'NAME_ASM'.
*    SORT-GROUP     = 'X'.
*    SORT-UP        = 'X'.
*    SORT-SUBTOT    = 'X'.
*    APPEND SORT.
*
*    SORT-FIELDNAME = 'NAME_TERR'.
*    SORT-GROUP     = 'X'.
*    SORT-UP        = 'X'.
*    SORT-SUBTOT    = 'X'.
*    APPEND SORT.
*
*
*    SORT-FIELDNAME = 'VENDEDOR'.
*    SORT-GROUP     = 'X'.
*    SORT-UP        = 'X'.
*    SORT-SUBTOT    = 'X'.
*    APPEND SORT.
*
*  endif.

  tit01 = 'SOCI'.




  PERFORM f_monta_fieldcat USING:
    'BUKRS'      'CONSULTA2' ' ' ' '  '01' ' ' ' ' 'Sociedad' ' ' ' ' ' ' '04',
    'LIFNR'      'CONSULTA2' ' ' ' '  '02' ' ' ' ' 'Cliente'  ' ' ' ' ' ' '10',
    'NAME1'      'CONSULTA2' ' ' ' '  '03' ' ' ' ' 'Nombre'   ' ' ' ' ' ' '35',
    'STCD1'      'CONSULTA2' ' ' ' '  '04' ' ' ' ' 'Rut'      ' ' ' ' ' ' '35',
    'HBKID'      'CONSULTA2' ' ' ' '  '05' ' ' ' ' 'Banco'    ' ' ' ' ' ' '35',
    'HKTID'      'CONSULTA2' ' ' ' '  '06' ' ' ' ' 'Cuenta'   ' ' ' ' ' ' '35',
    'CHECT'      'CONSULTA2' ' ' ' '  '07' ' ' ' ' 'Nro.Cheque' ' ' ' ' ' ' '35',
    'FECHA_REG'  'CONSULTA2' ' ' ' '  '08' ' ' ' ' 'Fecha Registro' ' ' ' ' ' ' '35',
    'HORA_REG'   'CONSULTA2' ' ' ' '  '09' ' ' ' ' 'Hora Registro' ' ' ' ' ' ' '35',
    'ZALDT'      'CONSULTA2' ' ' ' '  '09' ' ' ' ' 'Fecha Emision' ' ' ' ' ' ' '35',
    'ESTADO_D'   'CONSULTA2' ' ' ' '  '10' ' ' ' ' 'Estado' ' ' ' ' ' ' '35',
    'BELNR'      'CONSULTA2' ' ' ' '  '11' ' ' ' ' 'Doc. Contable' ' ' ' ' ' ' '35',
    'HKONT'      'CONSULTA2' ' ' ' '  '12' ' ' ' ' 'Cta Contable' ' ' ' ' ' ' '35',
    'AGENCIA'    'CONSULTA2' ' ' ' '  '13' ' ' ' ' 'Agencia' ' ' ' ' ' ' '35',
    'ZZMOT_EMIS' 'CONSULTA2' ' ' ' '  '14' ' ' ' ' 'Motivo Emision' ' ' ' ' ' ' '35',
    'RWBTR'      'CONSULTA2' ' ' ' '  '15' ' ' ' ' 'Monto Cheque' ' ' ' ' ' ' '35',
    'HBKID_R'    'CONSULTA2' ' ' ' '  '16' ' ' ' ' 'Banco Nuevo'    ' ' ' ' ' ' '35',
    'HKTID_R'    'CONSULTA2' ' ' ' '  '17' ' ' ' ' 'Cuenta Nueva'   ' ' ' ' ' ' '35',
    'CHECT_R'    'CONSULTA2' ' ' ' '  '18' ' ' ' ' 'Nro.Cheque Nuevo' ' ' ' ' ' ' '35',
    'RWBTR_R'    'CONSULTA2' ' ' ' '  '19' ' ' ' ' 'Valor Nuevo' ' ' ' ' ' ' '35'.



  print-no_print_listinfos = 'X'.
  print-no_print_selinfos  = 'X'.

  repid = sy-repid.
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
         EXPORTING
              i_callback_program       = repid
              i_structure_name         = 'CONSULTA2'
              i_grid_title             =  wa_titulo
              is_layout                = layout
              it_fieldcat              = fieldcat[]
*              it_sort                  = sort[]
*              i_default                = 'X'
*               i_save                   = 'A'
*           is_variant               = variante
              is_print                 = print
         TABLES
              t_outtab                 = consulta2
         EXCEPTIONS
              program_error            = 1
              OTHERS                   = 2.

  IF sy-subrc <> 0.
*    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
ENDFORM.                    "lista
*---------------------------------------------------
* Monta el Fieldcat
*---------------------------------------------------
FORM f_monta_fieldcat USING  x_field
                             x_tab
                             x_ref
                             x_ref_f
                             x_col_pos
                             x_hotspot
                             x_checkbox
                             x_seltext_l
                             x_key
                             x_no_out
                             x_do_sum
                             x_largo.

  fieldcat-fieldname     = x_field.
  fieldcat-tabname       = x_tab.
  fieldcat-ref_tabname   = x_ref.
  fieldcat-ref_fieldname = x_ref_f.
  fieldcat-col_pos       = x_col_pos.
  fieldcat-hotspot       = x_hotspot.
  fieldcat-checkbox      = x_checkbox.
  fieldcat-seltext_l     = x_seltext_l.
  fieldcat-key           = x_key.
  fieldcat-no_out        = x_no_out.
  fieldcat-do_sum        = x_do_sum.
  fieldcat-outputlen     = x_largo.
  IF x_field = 'RWBTR' OR x_field = 'RWBTR_R'.
    fieldcat-currency      = 'CLP'.
  ENDIF.
  APPEND fieldcat.
  CLEAR fieldcat.

ENDFORM.                    " Total_NAME_RSM


*&---------------------------------------------------------------------*
*&      Form  busca_datos_bseg
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*

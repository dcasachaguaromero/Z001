*&---------------------------------------------------------------------*
*& Report  ZFITR012
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  zfitr012.

TABLES: t001,
        reguh.

* Parametros para ALV

TYPE-POOLS: slis.

DATA:  sort          TYPE slis_t_sortinfo_alv WITH HEADER LINE,
       fieldcat      TYPE slis_t_fieldcat_alv WITH HEADER LINE,
       print         TYPE slis_print_alv,
       layout        TYPE slis_layout_alv,
       wa_titulo     TYPE lvc_title,
       tit01(10),
       repid LIKE sy-repid,
       ls_fcat TYPE slis_t_fieldcat_alv,
       fieldcat1      TYPE slis_t_fieldcat_alv WITH HEADER LINE,
       print1         TYPE slis_print_alv,
       layout1        TYPE slis_layout_alv,
       wa_titulo1     TYPE lvc_title,
       detalle(30),
       tit011(10).


DATA: BEGIN OF consulta1 OCCURS 100,
      laufd          LIKE reguh-laufd,
      laufi          LIKE reguh-laufi,
      hbkid          LIKE reguh-hbkid,
      hktid          LIKE reguh-hktid,
      lifnr          LIKE reguh-lifnr,
      name1          LIKE reguh-name1,
      rwbtr          LIKE reguh-rwbtr,
      ausfd          LIKE reguh-ausfd,
      rzawe          LIKE reguh-rzawe,
      valut          LIKE reguh-valut,
      wdate          LIKE reguh-wdate,
      busab          LIKE reguh-busab,
      ubhkt          LIKE reguh-ubhkt,
      ubknt          LIKE reguh-ubknt,
      vblnr          LIKE reguh-vblnr,
      zbnkn          LIKE reguh-zbnkn,
      zbnkl          LIKE reguh-zbnkl,
      waers          LIKE reguh-waers,
      znme1          LIKE reguh-znme1,
      identif_pago   LIKE reguh-identif_pago,
      fecha_envio    LIKE reguh-fecha_envio,
      usuario_envio  LIKE reguh-usuario_envio,
      ind_custodia   LIKE reguh-ind_custodia,
      fecha_custodia LIKE reguh-fecha_custodia,
      ind_pago       LIKE reguh-ind_pago,
      fecha_pago     LIKE reguh-fecha_pago,
      ind_devuelto   LIKE reguh-ind_devuelto,
      fecha_devuelto LIKE reguh-fecha_devuelto,
      ind_rechazo    LIKE reguh-ind_rechazo,
      fecha_rechazo  LIKE reguh-fecha_rechazo,
      belnr_dev      LIKE reguh-belnr_dev,
      gjahr_dev      LIKE reguh-gjahr_dev,
END OF consulta1.

DATA: BEGIN OF consulta2 OCCURS 100,
    laufd              LIKE reguh-laufd,
    laufi              LIKE reguh-laufi,
    hbkid              LIKE reguh-hbkid,
    hktid              LIKE reguh-hktid,
    fecha_envio        LIKE reguh-fecha_envio,
    usuario_envio      LIKE reguh-usuario_envio,
    monto_op           LIKE reguh-rbetr,
    cantidad_op(6)     TYPE p decimals 0 ,
    monto_cu           LIKE reguh-rbetr,
    cantidad_cu(6)      TYPE p decimals 0,
    monto_pa           LIKE reguh-rbetr,
    cantidad_pa(6)      TYPE p decimals 0,
    monto_de           LIKE reguh-rbetr,
    cantidad_de(6)      TYPE p decimals 0,
    monto_re           LIKE reguh-rbetr,
    cantidad_re(6)      TYPE p decimals 0,

END OF consulta2.


DATA: BEGIN OF consulta3 OCCURS 100,
      lifnr          LIKE reguh-lifnr,
      name1          LIKE reguh-name1,
      rwbtr          LIKE reguh-rwbtr,
      ausfd          LIKE reguh-ausfd,
      rzawe          LIKE reguh-rzawe,
      hbkid          LIKE reguh-hbkid,
      hktid          LIKE reguh-hktid,
      valut          LIKE reguh-valut,
      wdate          LIKE reguh-wdate,
      busab          LIKE reguh-busab,
      ubhkt          LIKE reguh-ubhkt,
      ubknt          LIKE reguh-ubknt,
      vblnr          LIKE reguh-vblnr,
      zbnkn          LIKE reguh-zbnkn,
      zbnkl          LIKE reguh-zbnkl,
      waers          LIKE reguh-waers,
      znme1          LIKE reguh-znme1,
      identif_pago   LIKE reguh-identif_pago,
      fecha_envio    LIKE reguh-fecha_envio,
      usuario_envio  LIKE reguh-usuario_envio,
      ind_custodia   LIKE reguh-ind_custodia,
      fecha_custodia LIKE reguh-fecha_custodia,
      ind_pago       LIKE reguh-ind_pago,
      fecha_pago     LIKE reguh-fecha_pago,
      ind_devuelto   LIKE reguh-ind_devuelto,
      fecha_devuelto LIKE reguh-fecha_devuelto,
      ind_rechazo    LIKE reguh-ind_rechazo,
      fecha_rechazo  LIKE reguh-fecha_rechazo,
      belnr_dev      LIKE reguh-belnr_dev,
      gjahr_dev      LIKE reguh-gjahr_dev,
END OF consulta3.


SELECTION-SCREEN BEGIN OF BLOCK marco1 WITH FRAME TITLE text-001.

PARAMETER : bukrs    LIKE bkpf-bukrs     VALUE CHECK  OBLIGATORY .

SELECT-OPTIONS : v_fecha  FOR reguh-laufd.

SELECT-OPTIONS  : v_hbkid FOR reguh-hbkid.

SELECT-OPTIONS  : v_hktid FOR reguh-hktid.

SELECTION-SCREEN END OF BLOCK marco1 .

*---------------------------------------------------------------------------------

AT SELECTION-SCREEN ON bukrs.

  AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
     ID 'BUKRS' FIELD bukrs.

  IF sy-subrc <> 0.
*--------'No authorization for company code &'------------------------
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


START-OF-SELECTION.

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT *  FROM  reguh   INTO CORRESPONDING FIELDS OF TABLE consulta1
*    WHERE laufd IN  v_fecha
*                          AND   zbukr = bukrs
*                          AND   hbkid IN v_hbkid
*                          AND   hktid IN v_hktid
*                          AND   identif_pago <>''.
*
* NEW CODE
  SELECT *
  FROM  reguh   INTO CORRESPONDING FIELDS OF TABLE consulta1
    WHERE laufd IN  v_fecha
                          AND   zbukr = bukrs
                          AND   hbkid IN v_hbkid
                          AND   hktid IN v_hktid
                          AND   identif_pago <>'' ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03


  SORT consulta1 BY laufd laufi hbkid hktid.

  REFRESH consulta2.

  LOOP AT consulta1.
    consulta1-rwbtr = consulta1-rwbtr * -1.
    consulta2-fecha_envio = consulta1-fecha_envio.
    consulta2-usuario_envio = consulta1-usuario_envio.

    consulta2-monto_op = consulta2-monto_op +   consulta1-rwbtr.
    consulta2-cantidad_op = consulta2-cantidad_op + 1.

    IF consulta1-ind_pago = 'X'.
      consulta2-monto_pa = consulta2-monto_pa +   consulta1-rwbtr.
      consulta2-cantidad_pa = consulta2-cantidad_pa + 1.
    ELSEIF consulta1-ind_devuelto = 'X'.
      consulta2-monto_de = consulta2-monto_de +   consulta1-rwbtr.
      consulta2-cantidad_de = consulta2-cantidad_de + 1.
    ELSEIF consulta1-ind_rechazo = 'X'.
      consulta2-monto_re = consulta2-monto_re +   consulta1-rwbtr.
      consulta2-cantidad_re = consulta2-cantidad_re + 1.
    ELSEIF consulta1-ind_custodia = 'X'.
      consulta2-monto_cu = consulta2-monto_cu +   consulta1-rwbtr.
      consulta2-cantidad_cu = consulta2-cantidad_cu + 1.
    ENDIF.

   AT END OF hktid.
      consulta2-laufd  = consulta1-laufd.
      consulta2-laufi  = consulta1-laufi.
      consulta2-hbkid  = consulta1-hbkid.
      consulta2-hktid  = consulta1-hktid.

      APPEND consulta2.
      CLEAR consulta2.

    ENDAT.

  ENDLOOP.


  PERFORM lista.

END-OF-SELECTION.


*&---------------------------------------------------------------------*
*&      Form  lista
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM lista.

  REFRESH: fieldcat.
  CLEAR: fieldcat, layout, print.

* ALV
* Definicion de parametros de layout
  layout-no_keyfix = ' '.
  layout-zebra = 'X'.
  layout-colwidth_optimize = 'X'.

  wa_titulo = 'Resumen Pagos enviados BBVA'.

  tit01 = 'SOCI'.


  PERFORM f_monta_fieldcat USING:
    'LAUFD'         'CONSULTA2' ' ' ' '  '01' ' ' ' ' 'Fecha Ejecucion'    ' ' ' ' ' ' '35',
    'LAUFI'         'CONSULTA2' ' ' ' '  '02' ' ' ' ' 'Identificador'   ' ' ' ' ' ' '35',
    'HBKID'         'CONSULTA2' ' ' ' '  '03' ' ' ' ' 'Banco'    ' ' ' ' ' ' '35',
    'HKTID'         'CONSULTA2' ' ' ' '  '04' ' ' ' ' 'Cuenta'   ' ' ' ' ' ' '35',
    'FECHA_ENVIO'   'CONSULTA2' ' ' ' '  '05' ' ' ' ' 'Fecha Envío' ' ' ' ' ' ' '35',
    'USUARIO_ENVIO' 'CONSULTA2' ' ' ' '  '06' ' ' ' ' 'Usuario Envio' ' ' ' ' ' ' '35',
    'MONTO_OP'      'CONSULTA2' ' ' ' '  '07' 'X' ' ' 'Monto' ' ' ' ' ' ' '35',
    'CANTIDAD_OP'   'CONSULTA2' ' ' ' '  '08' ' ' ' ' 'Cantidad OP' ' ' ' ' ' ' '35',
    'MONTO_CU'      'CONSULTA2' ' ' ' '  '09' 'X' ' ' 'Monto Custodia' ' ' ' ' ' ' '35',
    'CANTIDAD_CU'   'CONSULTA2' ' ' ' '  '10' ' ' ' ' 'Cantidad Custodia' ' ' ' ' ' ' '35',
    'MONTO_PA'      'CONSULTA2' ' ' ' '  '11' 'X' ' ' 'Monto Pagado' ' ' ' ' ' ' '35',
    'CANTIDAD_PA'   'CONSULTA2' ' ' ' '  '12' ' ' ' ' 'Cantidad Pagos' ' ' ' ' ' ' '35',
    'MONTO_DE'      'CONSULTA2' ' ' ' '  '13' 'X' ' ' 'Monto Dev.' ' ' ' ' ' ' '35',
    'CANTIDAD_DE'   'CONSULTA2' ' ' ' '  '14' ' ' ' ' 'Cantidad Dev.' ' ' ' ' ' ' '35',
    'MONTO_RE'      'CONSULTA2' ' ' ' '  '15' 'X' ' ' 'Monto Rech.' ' ' ' ' ' ' '35',
    'CANTIDAD_RE'   'CONSULTA2' ' ' ' '  '16' ' ' ' ' 'Cantidad Rech.' ' ' ' ' ' ' '35'.


  print-no_print_listinfos = 'X'.
  print-no_print_selinfos  = 'X'.

  repid = sy-repid.


  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program      = repid
      i_structure_name        = 'CONSULTA2'
      i_grid_title            = wa_titulo
      is_layout               = layout
      it_fieldcat             = fieldcat[]
      is_print                = print
      i_callback_user_command = 'USER_COMMAND'
    TABLES
      t_outtab                = consulta2
    EXCEPTIONS
      program_error           = 1
      OTHERS                  = 2.

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
  IF x_field = 'MONTO_OP' OR x_field = 'MONTO_CU' OR
    x_field = 'MONTO_PA' OR x_field = 'MONTO_RE'  OR
    x_field = 'MONTO_DE' .
    fieldcat-currency      = 'CLP'.
  ENDIF.
  APPEND fieldcat.
  CLEAR fieldcat.

ENDFORM.                    " Total_NAME_RSM

*&---------------------------------------------------------------------*
*&      Form  user_command
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->R_UCOMM      text
*      -->RS_SELFIELD  text
*----------------------------------------------------------------------*
FORM user_command USING r_ucomm     LIKE sy-ucomm
                                      rs_selfield TYPE slis_selfield.


  IF r_ucomm = '&IC1'.

    CASE rs_selfield-fieldname.
      WHEN 'MONTO_OP'.
        detalle = '(Todas la Opercaciones)'.
        PERFORM detalle USING '1' rs_selfield-tabindex.
      WHEN 'MONTO_CU'.
        detalle = '(En Custodia)'.
        PERFORM detalle USING '2' rs_selfield-tabindex.
      WHEN 'MONTO_PA'.
         detalle = '(Pagados)'.
        PERFORM detalle USING '3' rs_selfield-tabindex.
      WHEN 'MONTO_DE'.
        detalle = '(Devueltos)'.
        PERFORM detalle USING '4' rs_selfield-tabindex.
      WHEN 'MONTO_RE'.
        detalle = '(Rechazados)'.
        PERFORM detalle USING '5' rs_selfield-tabindex.
    ENDCASE.

  ENDIF.






ENDFORM.                    "user_command
*&---------------------------------------------------------------------*
*&      Form  DETALLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_1022   text
*      -->P_RS_SELFIELD_TABINDEX  text
*----------------------------------------------------------------------*
FORM detalle  USING    selec TYPE char01
                       tabindex LIKE sy-tabix.

  REFRESH consulta3.
  READ TABLE consulta2 INDEX tabindex.


  IF sy-subrc = 0.

    LOOP AT consulta1 WHERE  laufd  =  consulta2-laufd
                      AND    laufi  =  consulta2-laufi.

      consulta1-rwbtr = consulta1-rwbtr * -1.
      CASE  selec .
        WHEN '1'.
          MOVE-CORRESPONDING consulta1  TO consulta3.
          APPEND consulta3.
        WHEN '2'.
          IF consulta1-ind_custodia = 'X' AND
             consulta1-ind_pago = ''      AND
             consulta1-ind_rechazo = ''   AND
             consulta1-ind_devuelto = ''.
            MOVE-CORRESPONDING consulta1  TO consulta3.
            APPEND consulta3.
          ENDIF.
        WHEN '3'.
          IF consulta1-ind_pago = 'X'.
            MOVE-CORRESPONDING consulta1  TO consulta3.
            APPEND consulta3.
          ENDIF.
        WHEN '4'.
          IF consulta1-ind_devuelto = 'X'.
            MOVE-CORRESPONDING consulta1  TO consulta3.
            APPEND consulta3.
          ENDIF.
        WHEN '5'.
          IF consulta1-ind_rechazo = 'X'.
            MOVE-CORRESPONDING consulta1  TO consulta3.
            APPEND consulta3.
          ENDIF.
      ENDCASE.

    ENDLOOP.

  ENDIF.


  PERFORM lista2.

ENDFORM.                    "DETALLE

*&---------------------------------------------------------------------*
*&      Form  lista2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM lista2.

  REFRESH: fieldcat1.
  CLEAR: fieldcat1, layout1, print1.

  layout1-no_keyfix = ' '.
  layout1-zebra = 'X'.
  layout1-colwidth_optimize = 'X'.

  concatenate 'Detalle Pagos enviados BBVA' detalle   into wa_titulo1 separated by space.

  tit011 = 'SOCI'.


  PERFORM f_monta_fieldcat1 USING:
    'LIFNR'          'CONSULTA3' ' ' ' '  '01' ' ' ' ' 'Acreedor'    ' ' ' ' ' ' '35',
    'NAME1'          'CONSULTA3' ' ' ' '  '02' ' ' ' ' 'Nombre'   ' ' ' ' ' ' '35',
    'RWBTR'          'CONSULTA3' ' ' ' '  '03' ' ' ' ' 'Imp.pag.ML'    ' ' ' ' ' ' '35',
    'AUSFD'          'CONSULTA3' ' ' ' '  '04' ' ' ' ' 'Vencimiento'   ' ' ' ' ' ' '35',
    'RZAWE'          'CONSULTA3' ' ' ' '  '05' ' ' ' ' 'Via de Pagoo' ' ' ' ' ' ' '35',
    'HBKID'          'CONSULTA3' ' ' ' '  '06' ' ' ' ' 'Id de Cuenta' ' ' ' ' ' ' '35',
    'HKTID'          'CONSULTA3' ' ' ' '  '07' ' ' ' ' 'Banco Propio' ' ' ' ' ' ' '35',
    'VALUT'          'CONSULTA3' ' ' ' '  '08' ' ' ' ' 'Fecha Valor' ' ' ' ' ' ' '35',
    'WDATE'          'CONSULTA3' ' ' ' '  '09' ' ' ' ' 'Fecha Emision' ' ' ' ' ' ' '35',
    'BUSAB'          'CONSULTA3' ' ' ' '  '10' ' ' ' ' 'Responsable' ' ' ' ' ' ' '35',
    'UBHKT'          'CONSULTA3' ' ' ' '  '11' ' ' ' ' 'N° cuenta' ' ' ' ' ' ' '35',
    'UBKNT'          'CONSULTA3' ' ' ' '  '12' ' ' ' ' 'Nuestro num.cta.' ' ' ' ' ' ' '35',
    'VBLNR'          'CONSULTA3' ' ' ' '  '13' ' ' ' ' 'N° doc.pago' ' ' ' ' ' ' '35',
    'ZBNKN'          'CONSULTA3' ' ' ' '  '14' ' ' ' ' 'Num.cta.receptor' ' ' ' ' ' ' '35',
    'ZBNKL'          'CONSULTA3' ' ' ' '  '15' ' ' ' ' 'Codigo bancario' ' ' ' ' ' ' '35',
    'WAERS'          'CONSULTA3' ' ' ' '  '16' ' ' ' ' 'Mon.' ' ' ' ' ' ' '35',
    'ZNME1'          'CONSULTA3' ' ' ' '  '17' ' ' ' ' 'Nombre recetor del pago' ' ' ' ' ' ' '35',
    'IDENTIF_PAGO'   'CONSULTA3' ' ' ' '  '18' ' ' ' ' 'Identificador Pago' ' ' ' ' ' ' '35',
    'FECHA_ENVIO'    'CONSULTA3' ' ' ' '  '19' ' ' ' ' 'Fecha Envio' ' ' ' ' ' ' '35',
    'USUARIO_ENVIO'  'CONSULTA3' ' ' ' '  '20' ' ' ' ' 'Usuario Envio' ' ' ' ' ' ' '35',
    'IND_CUSTODIA'   'CONSULTA3' ' ' ' '  '21' ' ' ' ' 'Custodia' ' ' ' ' ' ' '35',
    'FECHA_CUSTODIA' 'CONSULTA3' ' ' ' '  '22' ' ' ' ' 'Fecha Custodia' ' ' ' ' ' ' '35',
    'IND_PAGO'       'CONSULTA3' ' ' ' '  '23' ' ' ' ' 'Pago' ' ' ' ' ' ' '35',
    'FECHA_PAGO'     'CONSULTA3' ' ' ' '  '24' ' ' ' ' 'Fecha Pago' ' ' ' ' ' ' '35',
    'IND_DEVUELTO'   'CONSULTA3' ' ' ' '  '25' ' ' ' ' 'Devuelto' ' ' ' ' ' ' '35',
    'FECHA_DEVUELTO' 'CONSULTA3' ' ' ' '  '27' ' ' ' ' 'Fecha Devuelto' ' ' ' ' ' ' '35',
    'IND_RECHAZO'    'CONSULTA3' ' ' ' '  '28' ' ' ' ' 'Rechazo' ' ' ' ' ' ' '35',
    'FECHA_RECHAZO'  'CONSULTA3' ' ' ' '  '29' ' ' ' ' 'Fecha Rechazo' ' ' ' ' ' ' '35',
    'BELNR_DEV'      'CONSULTA3' ' ' ' '  '30' ' ' ' ' 'N° Voucher Dev/Rec' ' ' ' ' ' ' '35',
    'GJAHR_DEV'      'CONSULTA3' ' ' ' '  '31' ' ' ' ' 'Año Voucher Dev/Rec' ' ' ' ' ' ' '35'.








  print1-no_print_listinfos = 'X'.
  print1-no_print_selinfos  = 'X'.

  repid = sy-repid.


  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program = repid
      i_structure_name   = 'CONSULTA3'
      i_grid_title       = wa_titulo1
      is_layout          = layout1
      it_fieldcat        = fieldcat1[]
      is_print           = print1
    TABLES
      t_outtab           = consulta3
    EXCEPTIONS
      program_error      = 1
      OTHERS             = 2.

  IF sy-subrc <> 0.
*    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
ENDFORM.                                    " DETALLE

*&---------------------------------------------------------------------*
*&      Form  f_monta_fieldcat1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->X_FIELD      text
*      -->X_TAB        text
*      -->X_REF        text
*      -->X_REF_F      text
*      -->X_COL_POS    text
*      -->X_HOTSPOT    text
*      -->X_CHECKBOX   text
*      -->X_SELTEXT_L  text
*      -->X_KEY        text
*      -->X_NO_OUT     text
*      -->X_DO_SUM     text
*      -->X_LARGO      text
*----------------------------------------------------------------------*
FORM f_monta_fieldcat1 USING  x_field
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

  fieldcat1-fieldname     = x_field.
  fieldcat1-tabname       = x_tab.
  fieldcat1-ref_tabname   = x_ref.
  fieldcat1-ref_fieldname = x_ref_f.
  fieldcat1-col_pos       = x_col_pos.
  fieldcat1-hotspot       = x_hotspot.
  fieldcat1-checkbox      = x_checkbox.
  fieldcat1-seltext_l     = x_seltext_l.
  fieldcat1-key           = x_key.
  fieldcat1-no_out        = x_no_out.
  fieldcat1-do_sum        = x_do_sum.
  fieldcat1-outputlen     = x_largo.
  IF x_field = 'RWBTR' .
    fieldcat1-currency      = 'CLP'.
  ENDIF.
  APPEND fieldcat1.
  CLEAR fieldcat1.

ENDFORM.                    " Total_NAME_RSM

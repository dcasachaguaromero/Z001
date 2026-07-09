*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES04 > *
*& Description: < ReSQ Correction > *
*& Date: <19-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Report  ZDTE_DOC_REC_MONITOR
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  zdte_doc_rec_monitor.

INCLUDE:  zdte_doc_rec_monitor_co,
          zdte_doc_rec_monitor_t01.

*--------------------------------------------------------------------*
*
*--------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
SELECT-OPTIONS: s_rutemi FOR wa_data-rutemisor,
                s_fchemi FOR wa_data-fchemis  ,
                s_fchrec FOR wa_data-fchrec   ,
                s_estado FOR wa_data-estado   ,
                s_erdat  FOR wa_data-erdat    ,
                s_ernam  FOR wa_data-ernam    ,
                s_folio  FOR wa_data-folioref    ,
                s_bukrs  FOR t001-bukrs NO-EXTENSION NO INTERVALS ,
                s_ebeln  FOR ekko-ebeln NO-EXTENSION NO INTERVALS .
SELECTION-SCREEN END OF BLOCK b1.

INITIALIZATION.
  r_status_mod-sign = 'I'.
  r_status_mod-option = 'EQ'.
  r_status_mod-low = c_no_contabilizado.APPEND r_status_mod.
  r_status_mod-low = c_nuevo_xx.APPEND r_status_mod.
  r_status_mod-low = 'TD'.APPEND r_status_mod.
*
  AUTHORITY-CHECK OBJECT 'S_TCODE'
     ID 'TCD' FIELD sy-tcode.
  IF sy-subrc NE 0.
    MESSAGE e077(s#) WITH sy-tcode.
  ENDIF.

AT SELECTION-SCREEN ON s_bukrs.
  SELECT bukrs INTO TABLE @DATA(lt_bukrs)
         FROM t001 WHERE bukrs IN @s_bukrs.
  LOOP AT lt_bukrs INTO DATA(lw_bukrs).
    AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
       ID 'BUKRS' FIELD lw_bukrs.
    IF sy-subrc <> 0.
      MESSAGE e526(icc_tr) WITH lw_bukrs.
    ENDIF.
  ENDLOOP.

*--------------------------------------------------------------------*
START-OF-SELECTION.
*--------------------------------------------------------------------*
  IF s_bukrs[] IS NOT INITIAL.
*ResQ Comment:Correction not required as Select Single is used 24/12/2019 EY_DES02 ECDK917080 *
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE * INTO w_t001z
*      FROM t001z
*     WHERE bukrs IN s_bukrs.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  INTO w_t001z
      FROM t001z
     WHERE bukrs IN s_bukrs ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

    CONDENSE w_t001z-paval NO-GAPS.
    s_rut-sign = 'I'.
    s_rut-option = 'EQ'.
    s_rut-low = w_t001z-paval .
    APPEND s_rut.
  ENDIF.


* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT * FROM zdte_doc_rec
*  INTO CORRESPONDING FIELDS OF TABLE gt_data
*  WHERE rutemisor IN s_rutemi
*    AND fchemis   IN s_fchemi
*    AND fchrec    IN s_fchrec
*    AND estado    IN s_estado
*    AND erdat     IN s_erdat
*    AND ernam     IN s_ernam
*    AND folio     IN s_folio
*    AND rutrecep  IN s_rut
*     .
*
* NEW CODE
  SELECT *
 FROM zdte_doc_rec
  INTO CORRESPONDING FIELDS OF TABLE gt_data
  WHERE rutemisor IN s_rutemi
    AND fchemis   IN s_fchemi
    AND fchrec    IN s_fchrec
    AND estado    IN s_estado
    AND erdat     IN s_erdat
    AND ernam     IN s_ernam
    AND folio     IN s_folio
    AND rutrecep  IN s_rut
      ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
*
  IF gt_data[] IS NOT INITIAL.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*    SELECT * FROM zdte_doc_rec_ref
*      INTO TABLE gt_doc_rec_ref FOR ALL ENTRIES IN gt_data
*     WHERE tipodte   EQ gt_data-tipodte
*       AND folio     EQ gt_data-folio
*       AND rutemisor EQ gt_data-rutemisor
*       AND folioref  IN s_ebeln.
*
* NEW CODE
    SELECT *
 FROM zdte_doc_rec_ref
      INTO TABLE gt_doc_rec_ref FOR ALL ENTRIES IN gt_data
     WHERE tipodte   EQ gt_data-tipodte
       AND folio     EQ gt_data-folio
       AND rutemisor EQ gt_data-rutemisor
       AND folioref  IN s_ebeln ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
  ENDIF.

***NEW SELECT
*SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_data
*  FROM zdte_doc_rec as a INNER JOIN zdte_doc_rec_ref as b
*    on a~tipodte EQ b~tipodte
*   AND a~folio   eq b~folio
*   AND a~rutemisor eq b~rutemisor
*  WHERE a~rutemisor IN s_rutemi
*    AND a~fchemis   IN s_fchemi
*    AND a~fchrec    IN s_fchrec
*    AND a~estado    IN s_estado
*    AND a~erdat     IN s_erdat
*    AND a~ernam     IN s_ernam
*    AND a~folio     IN s_folio
*    AND a~rutrecep  IN s_rut
*    AND B~folioref  IN s_ebeln.


*--------------------------------------------------------------------*
END-OF-SELECTION.
*--------------------------------------------------------------------*
  DATA: lv_aux.
*Begin of change: ReSQ Correction for MODIFY on an unsorted Internal Table 19/12/2019 EY_DES04 ECDK917080 *
  SORT gt_data .
*End of change: ReSQ Correction for MODIFY on an unsorted Internal Table 19/12/2019 EY_DES04 ECDK917080 *
  LOOP AT gt_data INTO wa_data.
    vl_index = sy-tabix.
    REFRESH t_aux1.
*    TRANSLATE wa_data-url to UPPER CASE.
    SPLIT wa_data-url AT '/' INTO TABLE t_aux1.
    CLEAR: wa_data-url , lv_aux , w_t001z.

    LOOP AT t_aux1.
      AT LAST.
        lv_aux = 'X'.
      ENDAT.
      IF lv_aux EQ 'X'.
        TRANSLATE t_aux1-param TO UPPER CASE.
        CONCATENATE  wa_data-url t_aux1-param  INTO wa_data-url .
      ELSE.
        TRANSLATE t_aux1-param TO LOWER CASE.
        CONCATENATE  wa_data-url t_aux1-param '/' INTO wa_data-url .
      ENDIF.
    ENDLOOP.

*ResQ Comment:Correction not required as Select Single is used 19/12/2019 EY_DES04 ECDK917080 *
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE * INTO w_t001z
*      FROM t001z
*     WHERE paval EQ wa_data-rutrecep
*       AND party EQ 'TAXNR'.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  INTO w_t001z
      FROM t001z
     WHERE paval EQ wa_data-rutrecep
       AND party EQ 'TAXNR' ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    wa_data-bukrs = w_t001z-bukrs.

    MODIFY gt_data FROM wa_data INDEX vl_index TRANSPORTING url bukrs.
  ENDLOOP.

  LOOP AT gt_data INTO wa_data WHERE estado NE 'CO'.
    vl_index = sy-tabix.

    IF wa_data-mntexe > 0 AND wa_data-mntneto > 0 .
      wa_data-estado    = 'FM'."Factura mixta
      wa_data-message   = 'Factura Mixta'."Factura mixta
      UPDATE zdte_doc_rec FROM wa_data.
      COMMIT WORK AND WAIT.
    ENDIF.

    "Asigamos Iconos de Status
    IF wa_data-estado     = c_no_contabilizado OR wa_data-estado = c_rechazado.
      wa_data-icon_sts    = icon_red_light.
    ELSEIF wa_data-estado = c_contabilizado.
      wa_data-icon_sts    = icon_green_light.
    ELSEIF wa_data-estado EQ 'FM'."Factura Mixta
      wa_data-icon_sts  = icon_red_light.
    ELSE.
      wa_data-icon_sts    = icon_yellow_light.
    ENDIF.

    "Asignamos Iconos de Tiempo Rechazo

    DATA  vl_dias TYPE vtbbewe-atage.
    CLEAR vl_dias.

    CALL FUNCTION 'FIMA_DAYS_AND_MONTHS_AND_YEARS'
      EXPORTING
        i_date_from = wa_data-fchrec
*       I_KEY_DAY_FROM       =
        i_date_to   = sy-datum
*       I_KEY_DAY_TO         =
*       I_FLG_SEPARATE       = ' '
      IMPORTING
        e_days      = vl_dias
*       E_MONTHS    =
*       E_YEARS     =
      .

    wa_data-dias = vl_dias.
    "Calculamos días de plazo recepción
    IF vl_dias >= 6.
      wa_data-icon_rec    = icon_red_light.
    ELSEIF vl_dias >= 3 AND vl_dias =< 5.
      wa_data-icon_rec    = icon_yellow_light.
    ELSEIF vl_dias =< 2.
      wa_data-icon_rec    = icon_green_light.
    ENDIF.

    IF wa_data-formapago EQ '1'.
      wa_data-formapago = 'Contado'.
    ENDIF.
*    wa_data-ebeln = wa_data-folioref.
    READ TABLE gt_doc_rec_ref INTO wa_doc_ref WITH KEY tipodte = wa_data-tipodte
                                       folio   = wa_data-folio
                                     rutemisor = wa_data-rutemisor
                                     tpodocref = '801'.
    IF sy-subrc EQ 0.
      wa_data-folioref =  wa_doc_ref-folioref.
    ENDIF.
*      AND folioref  IN s_ebeln.
    IF s_ebeln-low NE space.
      IF s_ebeln-low NE wa_data-folioref.
        wa_data-del = 'X'.
      ENDIF.
    ENDIF.
*ReSQ: No Need Of Change Internal Table GT_DATA Already Sorted
    MODIFY gt_data FROM wa_data INDEX vl_index TRANSPORTING icon_sts icon_rec dias formapago folioref del estado message.
  ENDLOOP.

  LOOP AT gt_data INTO wa_data WHERE estado EQ 'CO'.
    vl_index = sy-tabix.

    READ TABLE gt_doc_rec_ref INTO wa_doc_ref WITH KEY tipodte = wa_data-tipodte
                                      folio   = wa_data-folio
                                    rutemisor = wa_data-rutemisor
                                    tpodocref = '801'.
    IF sy-subrc EQ 0.
      wa_data-folioref =  wa_doc_ref-folioref.
*ReSQ: No Need Of Change Internal Table GT_DATA Already Sorted
      MODIFY gt_data FROM wa_data INDEX vl_index TRANSPORTING folioref .
    ENDIF.
  ENDLOOP.

  DELETE gt_data WHERE del EQ 'X'.

*  PERFORM display_alv.
  PERFORM display_alv_grid.

  INCLUDE zdte_doc_rec_monitor_f01.
  INCLUDE zdte_doc_rec_monitor_o01.

*&---------------------------------------------------------------------*
*&      Form  display_alv_grid
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM display_alv_grid.
  DATA: l_layout   TYPE slis_layout_alv.
  DATA: i_catalogo TYPE slis_t_fieldcat_alv.
  DATA: i_orden    TYPE slis_t_sortinfo_alv.

  PERFORM f_cargar_layout CHANGING l_layout.
  PERFORM f_cargar_catalogo TABLES i_catalogo.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_bypassing_buffer       = 'X'
      i_callback_program       = sy-repid
      i_callback_pf_status_set = 'F_PF_STATUS'   " LIST_ALV
      i_callback_user_command  = 'F_USER_COMMAND'
*     i_grid_title             = ''
      is_layout                = l_layout
      it_fieldcat              = i_catalogo
*     it_sort                  = i_orden
      i_save                   = 'X'
    TABLES
      t_outtab                 = gt_data
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


ENDFORM.                    "display_alv_grid
*&---------------------------------------------------------------------*
*&      Form  f_pf_status
*&---------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
FORM f_pf_status USING rt_extab TYPE slis_t_extab .
  SET PF-STATUS 'LIST_ALV'.
ENDFORM.                    "f_pf_status
*&---------------------------------------------------------------------*
*&      Form  f_user_command
*&---------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
FORM f_user_command USING p_ucomm LIKE sy-ucomm
                       p_selfield TYPE slis_selfield.

  READ TABLE gt_data INTO wa_data INDEX p_selfield-tabindex.
  IF sy-subrc = 0.
    CASE p_selfield-fieldname.
      WHEN 'FOLIO'.
        CALL FUNCTION 'ZSD_DTE_MONITOR_REF'
          EXPORTING
            im_rutemisor = wa_data-rutemisor
            im_folio     = wa_data-folio
            im_tipodte   = wa_data-tipodte.

      WHEN 'URL'.
        CALL FUNCTION 'GUI_RUN'
          EXPORTING
            command = wa_data-url
*           PARAMETER        =
*           CD      =
*            IMPORTING
*           RETURNCODE       =
          .
      WHEN 'ICON_STS'.

      WHEN 'ICON_FIELD'.  "despliega detalle


      WHEN 'NRO_DOCUMENTO'.
*          SET PARAMETER ID 'VF' FIELD wa_data-nro_documento.
*          CALL TRANSACTION 'VF03' AND SKIP FIRST SCREEN.

      WHEN 'ICON_STS'.

*      WHEN 'ICON_FIELD'.  "despliega detalle
      WHEN 'FOLIOREF'.  "despliega detalle
        IF wa_data-folioref(1) EQ '4'.
          SET PARAMETER ID 'BES' FIELD wa_data-folioref.
          CALL TRANSACTION 'ME23N' AND SKIP FIRST SCREEN.

        ENDIF.
      WHEN 'BELNR'.  "despliega detalle
        IF wa_data-estado = c_contabilizado.
          CASE wa_data-tcode .
            WHEN 'MIRO'.
              SET PARAMETER ID 'RBN' FIELD wa_data-belnr.
              SET PARAMETER ID 'GJR' FIELD wa_data-gjahr.
              CALL TRANSACTION 'MIR4' AND SKIP FIRST SCREEN.
            WHEN 'FB60' OR 'ZFITR006B'.
              SET PARAMETER ID 'BLN' FIELD wa_data-belnr.
              SET PARAMETER ID 'GJR' FIELD wa_data-gjahr.
              SET PARAMETER ID 'BUK' FIELD wa_data-bukrs.
              CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
          ENDCASE.
        ENDIF.
    ENDCASE.

  ENDIF.

****Botones de la barra.
  DATA  lv_msg              TYPE i VALUE 0.

  DATA: l_folio(10) TYPE n,
*        l_tipo_dte          TYPE zdte_control-tipo_dte,
        l_tipo_dte  TYPE zdte_folio,
        l_hora      TYPE sy-timlo,
        l_lifnr     TYPE lfa1-lifnr.

  DATA: l_tabix LIKE sy-tabix,
        l_lines TYPE i.

  DATA: l_invoicedocnumber LIKE  bapi_incinv_fld-inv_doc_no,
        l_fiscalyear       LIKE  bapi_incinv_fld-fisc_year,
        l_message          TYPE  zdte_doc_rec-message.
*  gr_selections = gr_table->get_selections( ).
*
** set selection mode
*  gr_selections->set_selection_mode(
*  if_salv_c_selection_mode=>row_column ).
*
*  gt_rows = gr_selections->get_selected_rows( ).

  DATA lt_doc_ref       TYPE ty_tdoc_ref.
  DATA lt_doc_ref_d     TYPE ty_tdoc_ref.
  DATA ls_doc_ref       LIKE LINE OF lt_doc_ref.
  DATA l_motivo_rec     TYPE zdte_doc_rec-motivo_rec.
  DATA i_function TYPE sy-ucomm.

  DATA l_obj_key  TYPE bapiache03-obj_key.
  DATA l_year     TYPE gjahr.

  FIELD-SYMBOLS <wa_doc_ref> LIKE LINE OF lt_doc_ref.
  i_function = p_ucomm.

  CLEAR l_lines.
  LOOP AT  gt_data INTO wa_data WHERE sel EQ 'X'.
    ADD 1 TO l_lines.
  ENDLOOP.

  IF i_function = 'DELE'.
*    l_lines = LINES( gt_rows ).
    IF l_lines > 1.
      MESSAGE i000(0k) WITH 'Debe seleccionar sola una línea' DISPLAY LIKE 'E'.
      RETURN.
    ENDIF.
  ENDIF.

  DATA l_question(100)  TYPE c.
  DATA l_answer(1)      TYPE c.



*  CHECK wa_data-PCLO_ID is NOT INITIAL.
  CASE i_function.
* nuevo
    WHEN 'NUEVO'.

      CALL FUNCTION 'POPUP_TO_CONFIRM'
        EXPORTING
          text_question         = '¿Esta seguro de cambiar estado a NUEVO?'
          text_button_1         = 'Sí'
          default_button        = '2'
          display_cancel_button = 'X'
        IMPORTING
          answer                = l_answer.

      IF l_answer <> '1'.
        RETURN.
      ENDIF.

      LOOP AT  gt_data INTO wa_data WHERE sel EQ 'X'.
        l_tabix = sy-tabix.
*        READ TABLE gt_data INDEX l_tabix INTO wa_data.
*        IF sy-subrc = 0.
*        CHECK wa_data-estado = c_no_contabilizado.
        IF wa_data-estado EQ space."quedó sin status por error.
          wa_data-estado = 'XX'.
        ENDIF.
        IF wa_data-estado IN r_status_mod.
          UPDATE zdte_doc_rec SET estado    = c_nuevo WHERE rutemisor = wa_data-rutemisor AND
                                                            tipodte   = wa_data-tipodte   AND
                                                              folio     = wa_data-folio.
          IF sy-subrc = 0.
            COMMIT WORK.
            wa_data-estado = c_nuevo.
            MODIFY gt_data FROM wa_data INDEX l_tabix.
          ELSE.
            MESSAGE i000(0k) WITH 'Error al modificar Folio' wa_data-folio
                             DISPLAY LIKE 'E'.
          ENDIF.
        ELSE.
          MESSAGE i000(0k) WITH 'Estatus ' wa_data-estado ' no se puede modificar'
                            DISPLAY LIKE 'E'.
        ENDIF.
*        ENDIF.
      ENDLOOP.
* borrar
    WHEN 'DELE'.
      l_question = '¿Esta seguro de Eliminar Folio & ?'.
      LOOP AT  gt_data INTO wa_data WHERE sel EQ 'X'.
        l_tabix = sy-tabix.
*        READ TABLE gt_data INDEX l_tabix INTO wa_data.
*        IF sy-subrc <> 0.
*          RETURN.
*        ENDIF.
******borrar solo con estado Nc o XX
*      IF wa_data-estado <> c_no_contabilizado .
        IF NOT wa_data-estado IN r_status_mod .
          MESSAGE i000(0k) WITH 'Registro debe estar con estado'
                                'no contabilizado' DISPLAY LIKE 'E'.
          RETURN.
        ENDIF.

      ENDLOOP.


      REPLACE FIRST OCCURRENCE OF '&' IN l_question WITH wa_data-folio.

      CALL FUNCTION 'POPUP_TO_CONFIRM'
        EXPORTING
          text_question         = l_question
          text_button_1         = 'Sí'
          default_button        = '2'
          display_cancel_button = 'X'
        IMPORTING
          answer                = l_answer.

      IF l_answer <> '1'.
        RETURN.
      ENDIF.

      DELETE FROM zdte_doc_rec WHERE rutemisor = wa_data-rutemisor AND
                                     tipodte   = wa_data-tipodte   AND
                                     folio = wa_data-folio.
      IF sy-subrc = 0.
        SELECT COUNT(*) FROM zdte_doc_rec_ref WHERE rutemisor = wa_data-rutemisor AND
                               tipodte   = wa_data-tipodte   AND
                               folio = wa_data-folio.
        IF sy-subrc = 0.
          DELETE FROM zdte_doc_rec_ref WHERE rutemisor = wa_data-rutemisor AND
                                 tipodte   = wa_data-tipodte   AND
                                 folio = wa_data-folio.
          IF sy-subrc = 0.
            COMMIT WORK.
            DELETE gt_data INDEX l_tabix.
            MESSAGE i000(0k) WITH 'Folio' wa_data-folio 'eliminado con éxito' DISPLAY LIKE 'S'.
          ELSE.
            ROLLBACK WORK.
            MESSAGE i000(0k) WITH 'Error al borrar Folio' wa_data-folio DISPLAY LIKE 'E'.
          ENDIF.
        ELSE.
          COMMIT WORK.
          DELETE gt_data INDEX l_tabix.
          MESSAGE i000(0k) WITH 'Folio' wa_data-folio 'eliminado con éxito' DISPLAY LIKE 'S'.
        ENDIF.
      ELSE.
        ROLLBACK WORK.
        MESSAGE i000(0k) WITH 'Error al borrar Folio' wa_data-folio DISPLAY LIKE 'E'.
      ENDIF.

*   Log
    WHEN 'PROT'.
      CALL SCREEN 2000  STARTING AT 2 5
                        ENDING AT 125 20.
*--------------------------------------------------------------------*
    WHEN 'REC'.
*--------------------------------------------------------------------*
      DATA ld_a(1)    TYPE c.
      DATA ls_sval    LIKE sval.
      DATA lt_sval    TYPE TABLE OF sval.
*  DATA l_motivo_rec TYPE dd07v-domvalue_l.
      DATA l_text     TYPE dd07v-ddtext.
      DATA l_string   TYPE string.
      DATA l_paval    TYPE  t001z-paval.

      CLEAR: gt_rechazados[] .
*             gt_desc[].

      ls_sval-tabname   = 'ZDTE_DOC_REC'.
      ls_sval-fieldname = 'MOTIVO_REC'.
      ls_sval-field_obl = 'X'.
      APPEND ls_sval TO lt_sval.

      CALL FUNCTION 'POPUP_GET_VALUES'
        EXPORTING
*         NO_VALUE_CHECK  = ' '
          popup_title     = 'Ingresar motivo de Rechazo'
*         START_COLUMN    = '5'
*         START_ROW       = '5'
        IMPORTING
          returncode      = ld_a
        TABLES
          fields          = lt_sval
        EXCEPTIONS
          error_in_fields = 1
          OTHERS          = 2.

      READ TABLE lt_sval INTO ls_sval WITH KEY fieldname = 'MOTIVO_REC'.
      IF sy-subrc = 0.
        MOVE ls_sval-value TO l_motivo_rec.

*        SELECT COUNT(*) FROM zdtet_motivo_rec WHERE motivo_rec = l_motivo_rec.
        IF l_motivo_rec EQ space.
          MESSAGE i000(0k) WITH 'Motivo de Rechazo' l_motivo_rec 'no existe' DISPLAY LIKE 'E'.
          RETURN.
        ENDIF.
      ENDIF.

      CLEAR wa_data.
      LOOP AT  gt_data INTO wa_data WHERE sel EQ 'X'.
        l_tabix = sy-tabix.
*        READ TABLE gt_data INDEX l_tabix INTO wa_data.
        IF wa_data-estado = c_no_contabilizado.
*          PERFORM rechazar USING wa_data CHANGING g_subrc l_motivo_rec.
*          IF g_subrc = 0.
*            MOVE-CORRESPONDING   wa_data TO wa_doc_rec.
*            wa_doc_rec-estado = c_rechazado.
*            wa_doc_rec-motivo_rec = l_motivo_rec.
*            wa_doc_rec-uname = sy-uname.
*            MODIFY zdte_doc_rec FROM wa_doc_rec.
*          ENDIF.

          "Notificacion de rechazo
          MOVE-CORRESPONDING wa_data TO wa_datos.
          wa_datos-tpo_doc        = wa_data-tipodte.        "CHAR3
          wa_datos-tipo           = l_motivo_rec."NAR ARN
          wa_datos-tpo_notif      = 'RECHAZO'.
          wa_datos-fecha_emision  = wa_data-fchemis.
          wa_datos-rut_emi        = wa_data-rutemisor.
          wa_datos-rut_recep      = wa_data-rutrecep.
          wa_datos-monto_total    = wa_data-mnttotal.

          wa_data-estado     = c_rechazado.
          wa_data-motivo_rec = l_motivo_rec.
          wa_data-uname      = sy-uname.


          CALL FUNCTION 'ZDTE_ENVIO_NOTIFICACION'
            EXPORTING
              p_datos = wa_datos
              p_user  = p_user
              p_pwd   = p_pwd
              p_ip    = p_ip
            IMPORTING
              retorno = o_retorno.

          IF o_retorno EQ 0.
            MOVE-CORRESPONDING wa_data TO wa_doc_rec.
            wa_data-icon_rec = icon_green_light.
            MODIFY zdte_doc_rec FROM wa_doc_rec.
            MODIFY gt_data FROM wa_data INDEX l_tabix.

            COMMIT WORK AND WAIT.
          ELSE.
            CONCATENATE wa_doc_rec-message '- Error envío FTP.' INTO wa_doc_rec-message SEPARATED BY space.
            wa_data-icon_rec = icon_yellow_light.
          ENDIF.

        ENDIF.
      ENDLOOP.

**      IF gt_rechazados[] IS NOT INITIAL.
****        PERFORM call_proxy USING gt_rechazados[] CHANGING g_subrc.
****        IF g_subrc <> 0.
****          RETURN.
****        ENDIF.
**        DATA ls_desc LIKE LINE OF gt_desc.
**
*** procesamos respuesta desde SII
**        LOOP AT gt_desc INTO ls_desc WHERE respuesta = '0'.
**          READ TABLE gt_data INTO wa_data WITH KEY rutemisor = ls_desc-rutemisor
**                                                     tipodte = ls_desc-tipodte
**                                                       folio = ls_desc-folio.
**          IF sy-subrc = 0.
**            MOVE-CORRESPONDING   wa_data TO wa_doc_rec.
**            wa_doc_rec-estado = c_rechazado.
**            wa_doc_rec-motivo_rec = l_motivo_rec.
**            wa_doc_rec-uname = sy-uname.
**            MODIFY zdte_doc_rec FROM wa_doc_rec.
**            COMMIT WORK.
**          ENDIF.
**        ENDLOOP.
**
**
**      ENDIF.
*--------------------------------------------------------------------*
    WHEN 'FB61'.
*--------------------------------------------------------------------*
*DTEs no contabilizados Sin Orden de Compra
      CLEAR wa_data.
      LOOP AT  gt_data INTO wa_data WHERE sel EQ 'X'.
        l_tabix = sy-tabix.
*       gt_rows = l_tabix.

*        READ TABLE gt_data INDEX l_tabix INTO wa_data.
*        IF wa_data-estado NE c_rechazado.
        IF NOT 'REFM'  CS wa_data-estado.
*          PERFORM f_fb61 USING wa_data CHANGING g_subrc l_obj_key l_year l_message.

*          Doctores solo permitir excento 34
          IF wa_data-estado EQ 'TD' AND wa_data-tipodte EQ '33'."
            MESSAGE i000(0k) WITH 'No es posible contabilizar con esta'
               ' transacción' DISPLAY LIKE 'E'.
            CLEAR i_function.
            EXIT.
          ENDIF.
          PERFORM ejecuta_fb60 USING    wa_data
                               CHANGING l_obj_key
                                        l_year.

          IF l_obj_key IS NOT INITIAL.

            MOVE-CORRESPONDING wa_data TO wa_doc_rec  .

            wa_doc_rec-estado = c_contabilizado       .
            wa_doc_rec-uname  = sy-uname              .
            wa_doc_rec-belnr  = l_obj_key             .
            wa_doc_rec-gjahr  = l_year                .
            wa_doc_rec-tcode  = 'FB60'                .

            MODIFY zdte_doc_rec FROM wa_doc_rec.

            CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
              EXPORTING
                wait = 'X'.

            wa_data-estado    = c_contabilizado.
            wa_data-icon_sts  = icon_green_light.
            wa_data-belnr     = l_obj_key.
            wa_data-gjahr     = l_year.
            wa_data-tcode     = 'FB60'.


            "Enviamos Notificación ACEPTACIÓN
            CLEAR wa_datos.
            wa_datos-tpo_doc        = wa_doc_rec-tipodte.
            wa_datos-folio          = wa_doc_rec-folio.
            wa_datos-fecha_emision  = wa_doc_rec-fchemis.
            wa_datos-rut_emi        = wa_doc_rec-rutemisor.
            wa_datos-rut_recep      = wa_doc_rec-rutrecep.
            wa_datos-monto_total    = wa_doc_rec-mnttotal.
            wa_datos-tpo_notif      = 'ACEPTO'.
            wa_datos-glosa          = wa_doc_rec-message.
            wa_datos-tipo           = 'ACD'. "Aceptacion

            CALL FUNCTION 'ZDTE_ENVIO_NOTIFICACION'
              EXPORTING
                p_datos = wa_datos
                p_user  = p_user
                p_pwd   = p_pwd
                p_ip    = p_ip
              IMPORTING
                retorno = o_retorno.

            IF o_retorno EQ 0.
              wa_data-icon_rec = icon_green_light.
            ELSE.
              wa_data-icon_rec = icon_yellow_light.
            ENDIF.

            MODIFY gt_data FROM wa_data INDEX l_tabix.
          ELSEIF g_subrc = 99.  "cancel
            CONTINUE.
          ELSE.
            wa_data-icon_sts = icon_red_light.
            MODIFY gt_data FROM wa_data INDEX l_tabix.

            IF l_message IS NOT INITIAL.
              MOVE-CORRESPONDING wa_data TO news.
              news-text = l_message.
              news-color = col_negative.
              APPEND news.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDLOOP.
*--------------------------------------------------------------------*
    WHEN 'ZCONTAB'.                                         "ZFITR006B
*--------------------------------------------------------------------*
      CLEAR wa_data.
      LOOP AT  gt_data INTO wa_data WHERE sel EQ 'X'.
        l_tabix = sy-tabix.

        IF NOT 'REFM'  CS wa_data-estado.
*          PERFORM f_fb61 USING wa_data CHANGING g_subrc l_obj_key l_year l_message.

*         Doctores solo permitir tipo 33
          IF wa_data-estado EQ 'TD' AND wa_data-tipodte EQ '33'."
          ELSE.
            MESSAGE i000(0k) WITH 'No es posible contabilizar con esta'
               ' transacción' DISPLAY LIKE 'E'.
            CLEAR i_function.
            EXIT.
          ENDIF.
          PERFORM ejecuta_zfitr006b USING wa_data
                                 CHANGING l_obj_key
                                          l_year.

          IF l_obj_key IS NOT INITIAL.
            wa_data-estado    = c_contabilizado.
            wa_data-icon_sts  = icon_green_light.
            wa_data-belnr     = l_obj_key.
            wa_data-gjahr     = l_year.
            wa_data-tcode     = 'ZFITR006B'.
            MOVE-CORRESPONDING wa_data TO wa_doc_rec  .
            wa_doc_rec-uname  = sy-uname              .

            "Enviamos Notificación ACEPTACIÓN
            CLEAR wa_datos.
            wa_datos-tpo_doc        = wa_doc_rec-tipodte.
            wa_datos-folio          = wa_doc_rec-folio.
            wa_datos-fecha_emision  = wa_doc_rec-fchemis.
            wa_datos-rut_emi        = wa_doc_rec-rutemisor.
            wa_datos-rut_recep      = wa_doc_rec-rutrecep.
            wa_datos-monto_total    = wa_doc_rec-mnttotal.
            wa_datos-tpo_notif      = 'ACEPTO'.
            wa_datos-glosa          = wa_doc_rec-message.
            wa_datos-tipo           = 'ACD'. "Aceptacion

            CALL FUNCTION 'ZDTE_ENVIO_NOTIFICACION'
              EXPORTING
                p_datos = wa_datos
                p_user  = p_user
                p_pwd   = p_pwd
                p_ip    = p_ip
              IMPORTING
                retorno = o_retorno.

            IF o_retorno EQ 0.
              wa_data-icon_rec = icon_green_light.
            ELSE.
              wa_data-icon_rec = icon_yellow_light.
            ENDIF.

            "actualizar tabla z
            MODIFY zdte_doc_rec FROM wa_doc_rec.
            "actualizar ALV
            MODIFY gt_data FROM wa_data INDEX l_tabix.


            CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
              EXPORTING
                wait = 'X'.

          ELSEIF g_subrc = 99.  "cancel
            CONTINUE.
          ELSE.
            wa_data-icon_sts = icon_red_light.
            MODIFY gt_data FROM wa_data INDEX l_tabix.

            IF l_message IS NOT INITIAL.
              MOVE-CORRESPONDING wa_data TO news.
              news-text = l_message.
              news-color = col_negative.
              APPEND news.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDLOOP.
*--------------------------------------------------------------------*
    WHEN 'MIRO'.
*--------------------------------------------------------------------*
      CLEAR wa_data.

      LOOP AT  gt_data INTO wa_data WHERE sel EQ 'X'.
        l_tabix = sy-tabix.
*        READ TABLE gt_data INDEX l_tabix INTO wa_data.
        IF wa_data-estado = c_no_contabilizado.
          PERFORM miro_manual USING wa_data CHANGING g_subrc
                                                     l_invoicedocnumber
                                                     l_fiscalyear
                                                     l_message.
          IF g_subrc = 0.
            MOVE-CORRESPONDING   wa_data TO wa_doc_rec.
            wa_doc_rec-uname = sy-uname.
            wa_doc_rec-belnr = l_invoicedocnumber.
            wa_doc_rec-gjahr = l_fiscalyear.
            wa_doc_rec-tcode = 'MIRO'.
            wa_doc_rec-estado = c_contabilizado.
            MODIFY zdte_doc_rec FROM wa_doc_rec.

            wa_data-estado = c_contabilizado.
            wa_data-belnr = l_invoicedocnumber.
            wa_data-gjahr = l_fiscalyear.
            wa_data-tcode = 'MIRO'.
            wa_data-icon_sts = icon_green_light.

            "Enviamos Notificación ACEPTACIÓN
            CLEAR wa_datos.
            wa_datos-tpo_doc        = wa_doc_rec-tipodte.
            wa_datos-folio          = wa_doc_rec-folio.
            wa_datos-fecha_emision  = wa_doc_rec-fchemis.
            wa_datos-rut_emi        = wa_doc_rec-rutemisor.
            wa_datos-rut_recep      = wa_doc_rec-rutrecep.
            wa_datos-monto_total    = wa_doc_rec-mnttotal.
            wa_datos-tpo_notif      = 'ACEPTO'.
            wa_datos-glosa          = wa_doc_rec-message.
            wa_datos-tipo           = 'ACD'. "Aceptacion

            CALL FUNCTION 'ZDTE_ENVIO_NOTIFICACION'
              EXPORTING
                p_datos = wa_datos
                p_user  = p_user
                p_pwd   = p_pwd
                p_ip    = p_ip
              IMPORTING
                retorno = o_retorno.

            IF o_retorno EQ 0.
              wa_data-icon_rec = icon_green_light.
            ELSE.
              wa_data-icon_rec = icon_yellow_light.
            ENDIF.

            MODIFY zdte_doc_rec FROM wa_doc_rec.
            MODIFY gt_data FROM wa_data INDEX l_tabix.

            COMMIT WORK.
          ELSE.
            wa_data-icon_sts = icon_red_light.
            MODIFY gt_data FROM wa_data INDEX l_tabix.

            IF l_message IS NOT INITIAL.
              MOVE-CORRESPONDING wa_data TO news.
              news-text = l_message.
              news-color = col_negative.
              APPEND news.
            ENDIF.

          ENDIF.
        ENDIF.
      ENDLOOP.
  ENDCASE.

  p_selfield-refresh = 'X'.
ENDFORM.                    "user_command
*&---------------------------------------------------------------------*
*&      Form  f_cargar_layout
*&---------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
FORM f_cargar_layout  CHANGING ps_l_layout TYPE slis_layout_alv.
  ps_l_layout-zebra = 'X'.
  ps_l_layout-colwidth_optimize = 'X'.
  ps_l_layout-box_fieldname     = 'SEL'.
*  ps_l_layout-lights_condense   = 'X'.
*  ps_l_layout-info_fieldname = 'COLOR'.
*  ps_l_layout-coltab_fieldname = 'COLOR_C' .

ENDFORM.                    " F_CARGAR_LAYOUT

*&---------------------------------------------------------------------*
*&      Form  f_cargar_catalogo
*&---------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
FORM f_cargar_catalogo  TABLES   ps_i_catalogo TYPE slis_t_fieldcat_alv.

  DATA: r_catalogo TYPE slis_fieldcat_alv.

  r_catalogo-fieldname  = 'RUTEMISOR'.
  r_catalogo-seltext_m  = 'RUT Emisor.'.
*  r_catalogo-key        = 'X'.
  r_catalogo-emphasize  = 'C100'.
  r_catalogo-outputlen  = '12'.
  APPEND r_catalogo TO ps_i_catalogo.

  CLEAR r_catalogo.
  r_catalogo-fieldname  = 'TIPODTE'.
  r_catalogo-seltext_m  = 'Tipo DTE'.
  r_catalogo-just       = 'C'.
*  r_catalogo-key        = 'X'.
  r_catalogo-emphasize  = 'C100'.
  APPEND r_catalogo TO ps_i_catalogo.

  CLEAR r_catalogo.
  r_catalogo-fieldname  = 'FOLIO'.
  r_catalogo-seltext_m  = 'Folio DTE'.
*  r_catalogo-key        = 'X'.
  r_catalogo-emphasize  = 'C100'.
  r_catalogo-hotspot    = 'X'.
  APPEND r_catalogo TO ps_i_catalogo.

  CLEAR r_catalogo.
  r_catalogo-fieldname  = 'ESTADO'.
  r_catalogo-seltext_m  = 'Estado'.
  r_catalogo-emphasize  = 'C100'.
  r_catalogo-just       = 'C'.
  APPEND r_catalogo TO ps_i_catalogo.

  CLEAR r_catalogo.
  r_catalogo-fieldname  = 'RZNSOC'.
  r_catalogo-seltext_m  = 'DTE: Nombre o razón social emisor'.
  APPEND r_catalogo TO ps_i_catalogo.

  CLEAR r_catalogo.
  r_catalogo-fieldname  = 'RUTRECEP'.
  r_catalogo-seltext_m  = 'Rut Receptor'.
  APPEND r_catalogo TO ps_i_catalogo.
  CLEAR r_catalogo.
  r_catalogo-fieldname  = 'GIRORECEP'.
  r_catalogo-seltext_m  = 'Giro receptor'.
  APPEND r_catalogo TO ps_i_catalogo.
  CLEAR r_catalogo.
  r_catalogo-fieldname  = 'DIRRECEP'.
  r_catalogo-seltext_m  = 'Direccion Receptor'.
  APPEND r_catalogo TO ps_i_catalogo.
  CLEAR r_catalogo.
  r_catalogo-fieldname  = 'RZNRECEP'.
  r_catalogo-seltext_m  = 'Razon social receptor'.
  APPEND r_catalogo TO ps_i_catalogo.
  CLEAR r_catalogo.  r_catalogo-fieldname  = 'FCHEMIS'.
  r_catalogo-seltext_m  = 'Fecha emisión'.
  APPEND r_catalogo TO ps_i_catalogo.

  CLEAR r_catalogo.
  r_catalogo-fieldname  = 'IVA'.
  r_catalogo-seltext_m  = 'Monto IVA'.
  r_catalogo-cfieldname = 'WAERS'.
  APPEND r_catalogo TO ps_i_catalogo.

  CLEAR r_catalogo.
  r_catalogo-fieldname  = 'MNTEXE'.
  r_catalogo-seltext_m  = 'Monto Exento'.
  r_catalogo-cfieldname = 'WAERS'.
  APPEND r_catalogo TO ps_i_catalogo.

  CLEAR r_catalogo.
  r_catalogo-fieldname  = 'MNTNETO'.
  r_catalogo-seltext_m  = 'Monto Neto'.
  r_catalogo-cfieldname = 'WAERS'.
  APPEND r_catalogo TO ps_i_catalogo.

  CLEAR r_catalogo.
  r_catalogo-fieldname  = 'MNTTOTAL'.
  r_catalogo-seltext_m  = 'Monto Total'.
  r_catalogo-cfieldname = 'WAERS'.
  APPEND r_catalogo TO ps_i_catalogo.

  CLEAR r_catalogo.
  r_catalogo-fieldname  = 'TASAIVA'.
  r_catalogo-seltext_m  = 'Tasa IVA'.
  r_catalogo-cfieldname = 'WAERS'.
  APPEND r_catalogo TO ps_i_catalogo.

  CLEAR r_catalogo.
  r_catalogo-fieldname  = 'FCHREC'.
  r_catalogo-seltext_m  = 'Fecha Recepción'.
  APPEND r_catalogo TO ps_i_catalogo.

  CLEAR r_catalogo.
  r_catalogo-fieldname  = 'HORREC'.
  r_catalogo-seltext_m  = 'Hora Recepción'.
  APPEND r_catalogo TO ps_i_catalogo.

  CLEAR r_catalogo.
  r_catalogo-fieldname  = 'WAERS'.
  r_catalogo-seltext_m  = 'Clave de moneda'.
  r_catalogo-no_out     = 'X'.
  APPEND r_catalogo TO ps_i_catalogo.



  CLEAR r_catalogo.
  r_catalogo-fieldname  = 'MOTIVO_REC'.
  r_catalogo-seltext_m  = 'Motivo de Rechazo.'.
  APPEND r_catalogo TO ps_i_catalogo.
  CLEAR r_catalogo.
  r_catalogo-fieldname  = 'UNAME'.
  r_catalogo-seltext_m  = 'Nombre de usuario'.
  APPEND r_catalogo TO ps_i_catalogo.
  CLEAR r_catalogo.

  r_catalogo-fieldname  = 'BELNR'.
  r_catalogo-seltext_m  = 'Nº documento'.
  r_catalogo-hotspot    = 'X'.
  APPEND r_catalogo TO ps_i_catalogo.
  CLEAR r_catalogo.
  r_catalogo-fieldname  = 'GJAHR'.
  r_catalogo-seltext_m  = 'Ejercicio'.
  APPEND r_catalogo TO ps_i_catalogo.
  CLEAR r_catalogo.
  r_catalogo-fieldname  = 'TCODE'.
  r_catalogo-seltext_m  = 'CódT'.
  APPEND r_catalogo TO ps_i_catalogo.
  CLEAR r_catalogo.
  r_catalogo-fieldname  = 'ERDAT'.
  r_catalogo-seltext_m  = 'Creado el'.
  APPEND r_catalogo TO ps_i_catalogo.
  CLEAR r_catalogo.
  r_catalogo-fieldname  = 'ERZET'.
  r_catalogo-seltext_m  = 'Hora'.
  APPEND r_catalogo TO ps_i_catalogo.
  CLEAR r_catalogo.
  r_catalogo-fieldname  = 'ERNAM'.
  r_catalogo-seltext_m  = 'Creado por'.
  APPEND r_catalogo TO ps_i_catalogo.
  CLEAR r_catalogo.
  r_catalogo-fieldname  = 'MESSAGE'.
  r_catalogo-seltext_m  = 'Texto de mensaje'.
  APPEND r_catalogo TO ps_i_catalogo.
  CLEAR r_catalogo.
  r_catalogo-fieldname  = 'URL'.
  r_catalogo-seltext_m  = 'URL Factura DTE'.
  r_catalogo-hotspot    = 'X'.
*  r_catalogo-lowercase  = ''.
  APPEND r_catalogo TO ps_i_catalogo.
  CLEAR r_catalogo.
  r_catalogo-fieldname  = 'NUMERO_CLIENTE'.
  r_catalogo-seltext_m  = 'Numero Cliente LB'.
  APPEND r_catalogo TO ps_i_catalogo.
*clear r_catalogo.
*  r_catalogo-fieldname  = 'BORRAR'.
*  r_catalogo-seltext_m  = ''.
*  append r_catalogo to ps_i_catalogo.
  CLEAR r_catalogo.
  r_catalogo-fieldname  = 'FORMAPAGO'.
  r_catalogo-seltext_m  = 'Forma de pago'.
  APPEND r_catalogo TO ps_i_catalogo.
  CLEAR r_catalogo.
  r_catalogo-fieldname  = 'FOLIOREF'.
  r_catalogo-seltext_m  = 'Folio Ref.'.
  r_catalogo-hotspot    = 'X'.
  APPEND r_catalogo TO ps_i_catalogo.
  CLEAR r_catalogo.
  r_catalogo-fieldname  = 'STATUS'.
  r_catalogo-seltext_m  = 'Status'.
  APPEND r_catalogo TO ps_i_catalogo.
  CLEAR r_catalogo.
  r_catalogo-fieldname  = 'ICON_STS'.
  r_catalogo-seltext_m  = 'Icono Status'.
  r_catalogo-icon        = 'X'.

  APPEND r_catalogo TO ps_i_catalogo.
  CLEAR r_catalogo.
  r_catalogo-fieldname  = 'DIAS'.
  r_catalogo-seltext_m  = 'Días'."Días desde Recepción Factura
*  r_catalogo-tooltip    = 'Días desde Recepción Factura'."
  APPEND r_catalogo TO ps_i_catalogo.
*clear r_catalogo.
*  r_catalogo-fieldname  = 'STATREC'.
*  r_catalogo-seltext_m  = 'Rechazo'.
*  append r_catalogo to ps_i_catalogo.
  CLEAR r_catalogo.
  r_catalogo-fieldname  = 'ICON_REC'.
  r_catalogo-seltext_m  = 'Icono Rechazo'.
  r_catalogo-icon        = 'X'.
  APPEND r_catalogo TO ps_i_catalogo.



ENDFORM.                                                    " ALV1


*&---------------------------------------------------------------------*
*&      Form  display_alv
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*FORM display_alv.
**... Create Instance
*
*  DATA: lr_events   TYPE REF TO cl_salv_events_table .
*  DATA: lr_columns  TYPE REF TO cl_salv_columns_table,
*        lr_column   TYPE REF TO cl_salv_column       .
*
*  DATA  l_mycolumn  TYPE REF TO cl_salv_column_table .
*  DATA  lr_grid     TYPE REF TO cl_salv_form_layout_grid.
** reference to a functions object
*
*  DATA: lr_layout   TYPE REF TO cl_salv_layout,
*        ls_key      TYPE salv_s_layout_key.
*  DATA: lr_sorts    TYPE REF TO cl_salv_sorts,
*        lr_sort     TYPE REF TO cl_salv_sort.
*
*  TRY.
*      CALL METHOD cl_salv_table=>factory
**         EXPORTING
**            LIST_DISPLAY = IF_SALV_C_BOOL_SAP=>true
*        IMPORTING
*          r_salv_table = gr_table
*
*        CHANGING
*          t_table      = gt_data.
*    CATCH cx_salv_msg.
*
*  ENDTRY.
*
**... Enable Generic ALV functions
*
*  gr_table->set_screen_status(
*    pfstatus      =  'LIST_ALV'  "copiar de SALV_DEMO_TABLE_LAYOUT    SALV_STANDARD
*    report        =  sy-repid
*    set_functions = gr_table->c_functions_all ).
*
*
** setting default ALV generic funtions
*  gr_functions = gr_table->get_functions( ).
** gr_functions->set_detail( IF_SALV_C_BOOL_SAP=>false ).
*
** set layout
*  lr_layout = gr_table->get_layout( ).
** set the Layout Key
*  ls_key-report = sy-repid.
*  lr_layout->set_key( ls_key ).
*
**  LR_LAYOUT->SET_SAVE_RESTRICTION( 3 ).
*
*  lr_layout->set_save_restriction( ).
*  lr_layout->set_default( 'X' ).
*  gr_functions->set_all( ).
*
*
** edit ALV columns
*  lr_columns = gr_table->get_columns( ).
** optimize output
*  lr_columns->set_optimize( 'X' ).
*
**----------------------------------------------------------------------*
**  Set column names
**----------------------------------------------------------------------*
*  DEFINE m_column_names.
*    try.
*        lr_column = lr_columns->get_column( &1 ).
*        lr_column->set_long_text( &2 ).
*        lr_column->set_medium_text( &2 ).
*        lr_column->set_short_text( &3 ).
*      catch cx_salv_not_found.
*      catch cx_salv_existing.
*      catch cx_salv_data_error.
*    endtry.
*  END-OF-DEFINITION.
*
*  DEFINE m_no_display.
*    try.
*        lr_column = lr_columns->get_column( '&1' ).
*        lr_column->set_visible( if_salv_c_bool_sap=>false ).
*      catch cx_salv_not_found.
*    endtry.
*  END-OF-DEFINITION.
*
*  m_no_display: mandt, waers, status, statrec , del.
*
*  m_column_names 'ICON_STS' 'Status'  'Status'.
*  m_column_names 'ICON_REC' 'Rechazo' 'Rechazo'.
*  m_column_names 'DIAS' 'Días' 'Días'.
*
**  m_column_names 'TIPO_DTE_REF_00' 'T.DTE.Ref.' 'T.DTE.Ref.'.
**  m_column_names 'FOLIO_REF_00' 'Folio Ref.' 'Folio Ref.'.
**  m_column_names 'FCH_REF_00' 'Fecha Ref.' 'Fecha Ref.'.
**  m_column_names 'COD_REF_00' 'Cod.Ref.' 'Cod.Ref.'.
**  m_column_names 'RAZON_REF_00' 'Razon Ref' 'Razon Ref'.
**  m_column_names 'IND_GLOBAL_00' 'Ind.Global' 'Ind.Global'.
**  m_column_names 'RUT_OTRO_00'   'RUT Otro' 'RUT Otro'.
**
**  m_column_names 'TIPO_DTE_REF_01' 'T.DTE.Ref.' 'T.DTE.Ref.'.
**  m_column_names 'FOLIO_REF_01' 'Folio Ref.' 'Folio Ref.'.
**  m_column_names 'FCH_REF_01' 'Fecha Ref.' 'Fecha Ref.'.
**  m_column_names 'COD_REF_01' 'Cod.Ref.' 'Cod.Ref.'.
**  m_column_names 'RAZON_REF_01' 'Razon Ref' 'Razon Ref'.
**  m_column_names 'IND_GLOBAL_01' 'Ind.Global' 'Ind.Global'.
**  m_column_names 'RUT_OTRO_01'   'RUT Otro' 'RUT Otro'.
**
**  m_column_names 'TIPO_DTE_REF_02' 'T.DTE.Ref.' 'T.DTE.Ref.'.
**  m_column_names 'FOLIO_REF_02' 'Folio Ref.' 'Folio Ref.'.
**  m_column_names 'FCH_REF_02' 'Fecha Ref.' 'Fecha Ref.'.
**  m_column_names 'COD_REF_02' 'Cod.Ref.' 'Cod.Ref.'.
**  m_column_names 'RAZON_REF_02' 'Razon Ref' 'Razon Ref'.
**  m_column_names 'IND_GLOBAL_02' 'Ind.Global' 'Ind.Global'.
**  m_column_names 'RUT_OTRO_02'   'RUT Otro' 'RUT Otro'.
*
*
**  TRY.
**      lr_column = lr_columns->get_column( 'FCHREC' ).
**      lr_column->set_edit_mask( '==TSTPS' ).
**    CATCH cx_salv_not_found.
**  ENDTRY.
*
**RUTEMISOR
**TIPODTE
**FOLIO
*
*  TRY.
*      lr_column = lr_columns->get_column( 'DIAS' ).
*      lr_column->set_tooltip( 'Días desde Recepción Factura' ).
*    CATCH cx_salv_not_found.
*  ENDTRY.
*
*  TRY.
*      l_mycolumn ?= lr_columns->get_column( 'FOLIO' ).
*      CALL METHOD l_mycolumn->set_cell_type
*        EXPORTING
*          value = if_salv_c_cell_type=>hotspot.
*
*    CATCH cx_salv_data_error .
*    CATCH cx_salv_not_found.
*  ENDTRY.
*
*  TRY.
*      l_mycolumn ?= lr_columns->get_column( 'URL' ).
*      CALL METHOD l_mycolumn->set_cell_type
*        EXPORTING
*          value = if_salv_c_cell_type=>hotspot.
*
*    CATCH cx_salv_data_error .
*    CATCH cx_salv_not_found.
*  ENDTRY.
*
*
*  gr_selections = gr_table->get_selections( ).
*
** set selection mode
*  gr_selections->set_selection_mode(
*  if_salv_c_selection_mode=>row_column ).
*
** register to the events of cl_salv_table
*  lr_events = gr_table->get_event( ).
*  CREATE OBJECT gr_events.
*
** register to the event USER_COMMAND
*  SET HANDLER gr_events->on_user_command FOR lr_events.
*
** register to the event DOUBLE_CLICK
*  SET HANDLER gr_events->on_double_click FOR lr_events.
*
*  SET HANDLER gr_events->on_link_click FOR lr_events.
*
*  gr_table->display( ).
*
*ENDFORM.                    "display_alv

****************************************************
****************************************************
INCLUDE zdte_doc_rec_monitor_i01.

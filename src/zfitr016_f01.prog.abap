*&---------------------------------------------------------------------*
*&  Include           ZFITR016_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  VALIDA_INGRESO
*&---------------------------------------------------------------------*
FORM valida_ingreso USING p_valor
                          p_banco TYPE  ubnkl.
  DATA : lt_dynpfields  TYPE TABLE OF dynpread,
         lt_laufk       TYPE TABLE OF ilaufk,
         lw_dynpfields  TYPE  dynpread,
         lw_laufk       TYPE ilaufk,
         xf4_c1(1)      TYPE c,
         lv_dynpro_prog TYPE d020s-prog,
         lv_bukrs       TYPE bukrs.
*
  lv_dynpro_prog = sy-repid.
*
  lw_dynpfields-fieldname = 'P_BUKRS'.
  APPEND lw_dynpfields TO lt_dynpfields.
*
  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      dyname     = lv_dynpro_prog
      dynumb     = '1000'
    TABLES
      dynpfields = lt_dynpfields.
*
  SORT lt_dynpfields .
  READ TABLE lt_dynpfields INTO lw_dynpfields INDEX 1.
  lv_bukrs = lw_dynpfields-fieldvalue .
  TRANSLATE lv_bukrs TO UPPER CASE.
*
  lw_laufk-laufk = space.
  lw_laufk-sign  = 'I'.
  APPEND lw_laufk TO lt_laufk.
  CALL FUNCTION 'F4_ZAHLLAUF'   "'ZF4_ZAHLLAUF'
    EXPORTING
      f1typ            = 'D'
*     f2nme            = 'P_LAUFI'
*     bukrs            = lv_bukrs
*     banco            = p_valor
    IMPORTING
      laufd            = p_fecha
      laufi            = p_nomina
      nothing_selected = xf4_c1
    TABLES
      laufk            = lt_laufk.
*
  CLEAR lt_dynpfields[].
  lw_dynpfields-fieldname = p_valor.
  APPEND lw_dynpfields TO lt_dynpfields.

*  lw_dynpfields-fieldname = 'P_ARCHIV'.
*  APPEND lw_dynpfields TO lt_dynpfields.
*
  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      dyname     = lv_dynpro_prog
      dynumb     = '1000'
    TABLES
      dynpfields = lt_dynpfields.
*
  LOOP AT lt_dynpfields INTO lw_dynpfields.
    CASE lw_dynpfields-fieldname.
      WHEN 'P_NOMINA'.
        lw_dynpfields-fieldvalue = p_nomina.
      WHEN 'P_FECHA'.
        lw_dynpfields-fieldvalue = |{ p_fecha DATE = USER }|.
      WHEN 'P_ARCHIV'.
        IF lv_bukrs IS NOT INITIAL.
          lw_dynpfields-fieldvalue = 'C:\TRANSFER\' && lv_bukrs && '_BCI_' && sy-datum && '_' && sy-uzeit && '.txt'.
        ENDIF.
    ENDCASE.
    MODIFY  lt_dynpfields FROM lw_dynpfields INDEX sy-tabix.
  ENDLOOP.
*
  CALL FUNCTION 'DYNP_VALUES_UPDATE'
    EXPORTING
      dyname     = lv_dynpro_prog
      dynumb     = '1000'
    TABLES
      dynpfields = lt_dynpfields.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CARGA_DATOS
*&---------------------------------------------------------------------*
FORM carga_datos .
  DATA : lw_vrm_value TYPE vrm_value.
*
  CLEAR: gr_fac[], gr_ncr[].

  SELECT valsign valoption valfrom valto  INTO TABLE gr_fac
         FROM setleaf   WHERE setname = 'ZFITR001'.
  IF gr_fac[] IS INITIAL.
    MESSAGE e899(v1) WITH 'Revisar Set de Datos Cl. Doctos Factura'.
  ENDIF.
*
  SELECT valsign valoption valfrom valto  INTO TABLE gr_ncr
         FROM setleaf   WHERE setname = 'ZFITR002'.
  IF gr_ncr[] IS INITIAL.
    MESSAGE e899(v1) WITH 'Revisar Set de Datos Cl. Doctos N.Crédito'.
  ENDIF.
*
  CLEAR gt_list[].
  lw_vrm_value-key  =  '1'.
  lw_vrm_value-text =  'CARGAR_NOMINA'.
  APPEND lw_vrm_value TO gt_list.

  lw_vrm_value-key  =  '2'.
  lw_vrm_value-text =  'RENDICION_NOMINA'.
  APPEND lw_vrm_value TO gt_list.
*
  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id              = 'P_PROCES'
      values          = gt_list
    EXCEPTIONS
      id_illegal_name = 0
      OTHERS          = 0.
*
  CLEAR gt_convenio[].
  SELECT bukrs, convenio INTO TABLE @DATA(lt_convenio)
        FROM zfitr016 WHERE convenio NE @space.
  LOOP AT lt_convenio INTO DATA(wa_convenio).
    lw_vrm_value-key  =  |{ wa_convenio-convenio ALPHA = OUT }|.
    lw_vrm_value-text =  wa_convenio-bukrs.
    APPEND lw_vrm_value TO gt_convenio.
  ENDLOOP.
*
  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id              = 'P_CONVEN'
      values          = gt_convenio
    EXCEPTIONS
      id_illegal_name = 0
      OTHERS          = 0.
*
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  VERIFICA_DATOS
*&---------------------------------------------------------------------*
FORM verifica_datos USING p_sem.
  DATA : lv_resp         TYPE char01.
*
  CASE p_sem.
    WHEN gc_x.
      CLEAR gv_contabilizar.
      SELECT SINGLE bukrs INTO @DATA(lv_bukrs)
             FROM zlog_pago_bancos  WHERE bukrs = @p_bukrs
                                      AND ubnkl = @gc_banco
                                      AND laufd = @p_fecha
                                      AND laufi = @p_nomina.
      IF sy-subrc EQ 0.
        CALL FUNCTION 'POPUP_TO_CONFIRM'
          EXPORTING
            titlebar              = 'Confirmación '
            text_question         = 'Archivo ya Generado y Contabilizado en trx. ZFITR016. ¿Desea Continuar?'
            default_button        = '2'
            display_cancel_button = 'X'
          IMPORTING
            answer                = lv_resp.
        IF lv_resp <> '1'.
          LEAVE PROGRAM.
        ENDIF.
        gv_contabilizar = 'N'.
      ELSE.
*
        SELECT SINGLE bukrs INTO lv_bukrs
             FROM zfi_log_ws WHERE bukrs       EQ p_bukrs
                             AND   ubnkl       EQ gc_banco
                             AND   laufd       EQ p_fecha
                             AND   laufi       EQ p_nomina
                             AND   proceso     EQ 'CARGAR_NOMINA'
                             AND   num_folio   NE 0.
        IF sy-subrc EQ 0.
          CALL FUNCTION 'POPUP_TO_CONFIRM'
            EXPORTING
              titlebar              = 'Confirmación '
              text_question         = 'Archivo ya Enviado vía WebService al Banco BCI ¿Desea Continuar?'
              default_button        = '2'
              display_cancel_button = 'X'
            IMPORTING
              answer                = lv_resp.
          IF lv_resp <> '1'.
            LEAVE PROGRAM.
          ENDIF.
          gv_contabilizar = 'N'.
        ENDIF.
      ENDIF.
    WHEN OTHERS.
      SELECT SINGLE bukrs INTO lv_bukrs
           FROM zfi_log_ws WHERE bukrs       EQ p_bukrs
                           AND   ubnkl       EQ gc_banco
                           AND   laufd       EQ p_fecha
                           AND   laufi       EQ p_nomina
                           AND   proceso     EQ 'RENDICION_NOMINA'
                           AND   codigo_ret  IN gr_proceso        "('COD20','COD200')
                           AND   num_folio   NE 0.
      IF sy-subrc EQ 0.
        CALL FUNCTION 'POPUP_TO_CONFIRM'
          EXPORTING
            titlebar              = 'Confirmación '
            text_question         = 'Rendición ya procesada ¿Desea Continuar?'
            default_button        = '2'
            display_cancel_button = 'X'
          IMPORTING
            answer                = lv_resp.
        IF lv_resp <> '1'.
          LEAVE PROGRAM.
        ENDIF.
      ENDIF.
  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  BUSCA_DATOS_RENDICION
*&---------------------------------------------------------------------*
FORM busca_datos_rendicion .
  DATA : lt_bukrs TYPE TABLE OF bukrs.
*
  SELECT bukrs, datum, uzeit, laufd, laufi, num_folio, proceso, envios_erroneos
        INTO TABLE @DATA(lt_carg_nom)
        FROM zfi_log_ws WHERE ubnkl         EQ @gc_banco
                        AND   proceso       EQ 'CARGAR_NOMINA'
                        AND   codigo_ret    IN @gr_proceso     "('COD10','COD105')
                        AND   num_folio     NE 0
                        AND   estado        EQ 'En proceso'
                        AND   rendicion_nom EQ @space
                        ORDER BY bukrs.
  IF sy-subrc EQ 0.
    LOOP AT lt_carg_nom INTO DATA(lw_carg_nom).
      DATA(lv_tabix) = sy-tabix.
      DATA(lv_subrc) = 4.
      SELECT SINGLE bukrs INTO @DATA(lv_bukrs)
           FROM zfi_log_ws WHERE bukrs        EQ @lw_carg_nom-bukrs
                           AND   ubnkl        EQ @gc_banco
                           AND   laufd        EQ @lw_carg_nom-laufd
                           AND   laufi        EQ @lw_carg_nom-laufi
                           AND   proceso      EQ 'RENDICION_NOMINA'
                           AND   codigo_ret   IN @gr_proceso        "('COD20','COD200')
                           AND   num_folio    EQ @lw_carg_nom-num_folio
                           AND   envios_erroneos LT 3.
      IF sy-subrc NE 0.
        SELECT COUNT( * ) INTO @DATA(lv_num_error)
             FROM zfi_log_ws WHERE bukrs       EQ @lw_carg_nom-bukrs
                             AND   ubnkl       EQ @gc_banco
                             AND   laufd       EQ @lw_carg_nom-laufd
                             AND   laufi       EQ @lw_carg_nom-laufi
                             AND   proceso     EQ 'RENDICION_NOMINA'
                             AND   codigo_ret  NOT IN @gr_proceso
                             AND   envios_erroneos LT 3.
        IF sy-subrc NE 0.
          lv_num_error = 1.
        ELSE.
          ADD 1 TO lv_num_error.
        ENDIF.
      ELSE.
        lv_subrc = sy-subrc.
      ENDIF.
      IF  lv_subrc EQ 0 OR lv_num_error GT 3.
        UPDATE zfi_log_ws SET rendicion_nom   = gc_x
                              envios_erroneos = lv_num_error
                            WHERE bukrs      EQ lw_carg_nom-bukrs
                             AND  datum      EQ lw_carg_nom-datum
                             AND  uzeit      EQ lw_carg_nom-uzeit
                             AND  ubnkl      EQ gc_banco
                             AND  proceso    EQ lw_carg_nom-proceso
                             AND  laufd      EQ lw_carg_nom-laufd
                             AND  laufi      EQ lw_carg_nom-laufi
                             AND  codigo_ret IN gr_proceso        "('COD10','COD105')
                             AND  num_folio  EQ lw_carg_nom-num_folio.
        COMMIT WORK AND WAIT.
        DELETE lt_carg_nom INDEX lv_tabix.
      ELSE.
        COLLECT lw_carg_nom-bukrs INTO lt_bukrs.
      ENDIF.
    ENDLOOP.
  ENDIF.
* valida que este el puero y los datos de la sociedad a procesar.
  LOOP AT lt_bukrs INTO DATA(lw_bukrs).
    PERFORM validacion_accesos USING lw_bukrs.
    MOVE lw_bukrs TO p_bukrs.
    LOOP AT lt_carg_nom INTO lw_carg_nom WHERE bukrs EQ lw_bukrs.
      MOVE : lw_carg_nom-laufd TO p_fecha,
             lw_carg_nom-laufi TO p_nomina.

      PERFORM ws_rendicion_nomina .
    ENDLOOP.
  ENDLOOP.

ENDFORM.
**&---------------------------------------------------------------------*
**&      Form  LEE_DATOS
**&---------------------------------------------------------------------*
*FORM lee_datos .
*  DATA: wa_adrc         TYPE adrc,
*        lv_numero       TYPE numc09,
*        lv_num_c        TYPE char08,
*        lv_dv           TYPE char01,
*        lv_rut          TYPE char10,
*        lv_resp         TYPE char01,
*        lv_contabilizar TYPE char01.
**
*  SELECT SINGLE adrnr INTO @DATA(lv_adrnr)
*         FROM t001 WHERE bukrs EQ @p_bukrs.
**
*  IF lv_adrnr IS NOT INITIAL.
*    CALL FUNCTION 'RTP_US_DB_ADRC_READ'
*      EXPORTING
*        i_address_number = lv_adrnr
*      IMPORTING
*        e_adrc           = wa_adrc
*      EXCEPTIONS
*        not_found        = 1
*        OTHERS           = 2.
*    IF wa_adrc-sort1 IS NOT INITIAL.
*      SPLIT wa_adrc-sort1 AT '-' INTO lv_num_c lv_dv.
*      lv_numero = lv_num_c.
*      CONCATENATE lv_numero lv_dv INTO lv_rut.
*    ENDIF.
*  ENDIF.
*ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CARGO_DATOS
*&---------------------------------------------------------------------*
FORM cargo_datos .
  DATA : lw_tabla_00 TYPE reguh,
         lv_nomban   TYPE fibl_txt50,
         lv_cuarta   TYPE char01,
         lv_numsan   TYPE numc2,
         lv_forma    TYPE char03.
*
  CLEAR : gt_tabla_00[],
          gv_contar    ,
          gv_sumpagos  ,
          gv_nvoant    ,
          gv_contardoc ,
          gv_lineas       ,
          gv_bktxt        ,
          gv_zaldt        ,
          gv_cuenta       ,
          gv_cuenta_2     ,
          gv_secuencia    ,
          gv_zzmot_emis   ,
          gv_valut        .
*
  SELECT SINGLE * INTO @DATA(lw_reguh)
         FROM reguh WHERE  laufd EQ @p_fecha
                      AND  laufi EQ @p_nomina
                      AND  zbukr EQ @p_bukrs.
  IF sy-subrc <> 0.
    MESSAGE e004(zfi) WITH 'Nomina no corresponde a Sociedad' p_bukrs.
  ENDIF.
*
  SELECT SINGLE * INTO lw_reguh
         FROM reguh WHERE  laufd   = p_fecha
                      AND  laufi   = p_nomina
                      AND  zbukr   = p_bukrs
                      AND  ubnkl   = gc_banco
                      AND  xvorl   = ' '.
  IF sy-subrc <> 0.
    MESSAGE e004(zfi) WITH 'Nomina sin movimientos a Generar'.
  ENDIF.
*
  lv_nomban = 'NO esta en tabla de Bancos'.
  SELECT SINGLE * INTO @DATA(lw_t012t)
         FROM t012t WHERE bukrs EQ @p_bukrs
                      AND hbkid EQ @lw_reguh-hbkid.
  IF sy-subrc = 0.
    lv_nomban = lw_t012t-text1.
  ELSE.
    MESSAGE e004(zfi) WITH 'Banco no esta en tabla (t012T) ' lw_reguh-hbkid.
  ENDIF.
*
  SELECT SINGLE * INTO @DATA(zfolio_pagobanco)
         FROM zfolio_pagobanco  WHERE bukrs  EQ @lw_reguh-zbukr
                                AND   ubnkl  EQ @lw_reguh-ubnkl
                                AND   codigo EQ '001'.
  IF sy-subrc <> 0.
    MESSAGE e004(zfi) WITH 'Sociedad-Banco no tiene Folios'.
  ENDIF.
*
* Rescatamos Datos LOOP de lectura con SELECT a REGUH.
  SELECT * INTO TABLE @DATA(lt_reguh)
        FROM  reguh  WHERE  laufd EQ @p_fecha
                       AND  laufi EQ @p_nomina
                       AND  zbukr EQ @p_bukrs
                       AND  ubnkl EQ @gc_banco
                       AND  xvorl EQ ' '.
  LOOP AT lt_reguh INTO lw_reguh.
    gv_contar    = gv_contar   + 1.
    gv_sumpagos  = gv_sumpagos + ( lw_reguh-rbetr * -100 ).
    gv_contardoc = gv_contardoc + lw_reguh-rpost.
*
    IF ( lw_reguh-stcd1 IS INITIAL ) OR ( lw_reguh-zstc1 IS INITIAL ).
      SELECT SINGLE stcd1 INTO lw_reguh-stcd1
             FROM lfa1 WHERE lifnr = lw_reguh-lifnr.
    ENDIF.
    CHECK ( NOT lw_reguh-stcd1 IS INITIAL ) OR ( NOT lw_reguh-zstc1 IS INITIAL ).
    MOVE-CORRESPONDING lw_reguh TO lw_tabla_00.

    lw_tabla_00-xavis = ' '.
* revisamos si paga a un beneficiario alternativo
    IF lw_tabla_00-stcd1 <> lw_tabla_00-zstc1.
      lw_tabla_00-stcd1   = lw_tabla_00-zstc1.
      lw_tabla_00-name1   = lw_tabla_00-znme1.
      lw_tabla_00-ort01   = lw_tabla_00-zort1.
      lw_tabla_00-stras   = lw_tabla_00-zstra.
    ENDIF.

    IF gv_contar = 1.
      PERFORM datos_fi USING lw_reguh
                             lw_tabla_00-hbkid
                       CHANGING lv_forma
                                lv_cuarta
                                gv_nvoant
                                gv_bktxt.
    ENDIF.

    lw_tabla_00-zpfor = lv_forma.
    lw_tabla_00-xavis = lv_cuarta.
    REPLACE ALL OCCURRENCES OF '-' IN  lw_tabla_00-zbnkn WITH ''.
    REPLACE ALL OCCURRENCES OF '.' IN  lw_tabla_00-zbnkn WITH ''.
    REPLACE ALL OCCURRENCES OF '/' IN  lw_tabla_00-zbnkn WITH ''.
    REPLACE ALL OCCURRENCES OF '_' IN  lw_tabla_00-zbnkn WITH ''.

    TRANSLATE lw_tabla_00-name1 USING 'ÁAÉEÍIÓOÚUáaéeíióoúuÑNñn; : \ ~ ¨ , / % $S| ° #N& '.
*****   MOTIVO EMISION NUMERICA EN TABLA_00 *********
    lw_tabla_00-dtws4 = lv_numsan.
    APPEND lw_tabla_00 TO gt_tabla_00.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  DATOS_FI
*&---------------------------------------------------------------------*
FORM datos_fi  USING    p_lw_reguh  TYPE reguh
                        p_hbkid
               CHANGING p_lv_forma
                        p_lv_cuarta
                        p_lv_nvoant
                        p_lv_bktxt.
* Rescata motivos de emisión
*  CONCATENATE  p_lw_reguh-zaldt+6(2) p_lw_reguh-zaldt+4(2) p_lw_reguh-zaldt+0(4) INTO zaldt.
*  CONCATENATE  p_lw_reguh-valut+6(2) p_lw_reguh-valut+4(2) p_lw_reguh-valut+0(4) INTO valut.

  gv_zaldt    = p_lw_reguh-zaldt+6(2) && p_lw_reguh-zaldt+4(2) && p_lw_reguh-zaldt+0(4).
  gv_valut    = p_lw_reguh-valut+6(2) && p_lw_reguh-valut+4(2) && p_lw_reguh-valut+0(4).
  gv_cuenta   = p_lw_reguh-ubhkt.
  gv_cuenta_2 = gv_cuenta+0(9) && '3'.
*  gv_cuenta   = gv_cuenta_2. " 24052023 se elimina el cambio de cuenta

  SELECT  SINGLE bktxt INTO p_lv_bktxt
           FROM bkpf WHERE bukrs EQ p_bukrs
                       AND belnr EQ p_lw_reguh-vblnr
                       AND gjahr EQ p_lw_reguh-zaldt(4).

  SELECT SINGLE  bukrs, belnr, gjahr, buzei INTO @DATA(lw_regup)
         FROM  regup WHERE laufd EQ @p_lw_reguh-laufd
                       AND laufi EQ @p_lw_reguh-laufi
                       AND xvorl EQ @p_lw_reguh-xvorl
                       AND zbukr EQ @p_lw_reguh-zbukr
                       AND lifnr EQ @p_lw_reguh-lifnr
                       AND kunnr EQ @p_lw_reguh-kunnr
                       AND empfg EQ @p_lw_reguh-empfg
                       AND vblnr EQ @p_lw_reguh-vblnr.
  IF sy-subrc EQ 0.
    SELECT SINGLE zzmot_emis INTO @DATA(lv_zzmot_emis)
          FROM  bseg  WHERE bukrs EQ @lw_regup-bukrs
                        AND belnr EQ @lw_regup-belnr
                        AND gjahr EQ @lw_regup-gjahr
                        AND buzei EQ @lw_regup-buzei.
    IF sy-subrc EQ 0.
      gv_zzmot_emis = lv_zzmot_emis.
    ENDIF.
  ENDIF.
*
  p_lv_cuarta = ' '.
  p_lv_forma  = 'ANT'.
*
  SELECT SINGLE zformat, zflag INTO @DATA(lw_exc)
      FROM zfitr005 WHERE bukrs  EQ @p_bukrs
                      AND hbkid  EQ @p_hbkid
                      AND zmotiv EQ @lv_zzmot_emis.
  IF sy-subrc = 0.
    p_lv_forma  = lw_exc-zformat.
    IF lw_exc-zflag IS NOT INITIAL.
      p_lv_cuarta = '4'.
    ENDIF.
  ELSE.
    MESSAGE e004(zfi) WITH 'No existe SOC_BCO_MOTIVO en tabla ZFITR005: ' lv_zzmot_emis.
  ENDIF.

  IF p_lv_forma <> 'ANT'.
    p_lv_nvoant = '2'.
  ELSE.
    p_lv_nvoant = '1'.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  LLAMA_FUNCION
*&---------------------------------------------------------------------*
FORM llama_funcion TABLES ti_out_reg_bci
                          ti_file.
  DATA : lv_nombrefuncion TYPE rs38l-name,
         lv_tippro        TYPE char01,
         lv_subrc         TYPE sysubrc.
*Procesamos Datos
  CLEAR : ti_out_reg_bci[], ti_file[].

  CONCATENATE 'ZBANCO_' gc_banco INTO lv_nombrefuncion.
  CALL FUNCTION 'FUNCTION_EXISTS'
    EXPORTING
      funcname           = lv_nombrefuncion
    EXCEPTIONS
      function_not_exist = 1
      OTHERS             = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    DATA(lv_confirming) = 'G'.
    lv_tippro           = par_di.

    CALL FUNCTION lv_nombrefuncion
      EXPORTING
        tippro         = lv_tippro
        contar         = gv_contar
        sumpagos       = gv_sumpagos
        v_fecha        = p_fecpag
        nvoant         = gv_nvoant
        contardoc      = gv_contardoc
        confirming     = lv_confirming
        proceso_ws     = gc_x
        ret_vv         = ' '
      TABLES
        tabla_00       = gt_tabla_00
        filesalida     = ti_file
        ti_out_reg_bci = ti_out_reg_bci.

    DESCRIBE TABLE ti_file.
    IF sy-tfill > 0.
      gv_lineas = sy-tfill.
    ENDIF.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  BAJAR_ARCHIVO
*&---------------------------------------------------------------------*
FORM bajar_archivo  TABLES   ti_file.
  DATA : lv_archivo_a TYPE string.
*
  lv_archivo_a = p_archiv.
*
  CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING
      filename                = lv_archivo_a
      filetype                = 'ASC'
      confirm_overwrite       = 'X'
    TABLES
      data_tab                = ti_file
    EXCEPTIONS
      file_write_error        = 1
      no_batch                = 2
      gui_refuse_filetransfer = 3
      invalid_type            = 4
      no_authority            = 5
      unknown_error           = 6
      header_not_allowed      = 7
      separator_not_allowed   = 8
      filesize_not_allowed    = 9
      header_too_long         = 10
      dp_error_create         = 11
      dp_error_send           = 12
      dp_error_write          = 13
      unknown_dp_error        = 14
      access_denied           = 15
      dp_out_of_memory        = 16
      disk_full               = 17
      dp_timeout              = 18
      file_not_found          = 19
      dataprovider_exception  = 20
      control_flush_error     = 21
      OTHERS                  = 22.
*
  IF sy-subrc EQ 0.
    FORMAT COLOR 3 ON.
    WRITE : / 'Se genera el siguiente archivo en el PC :', lv_archivo_a.
  ELSE.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          INTO DATA(lv_mtext)
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    WRITE :/ 'error!!!!'  ,
           /  lv_mtext .
*
    FORMAT COLOR 3 ON.
    WRITE : / 'NO se genera el archivo en el PC :', lv_archivo_a.
  ENDIF.
*
  WRITE : /10 'total pagos  : ', gv_contar,
              'total monto  : ', gv_sumpagos.
  FORMAT COLOR 3 OFF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  WS_CARGA_NOMINA
*&---------------------------------------------------------------------*
FORM ws_carga_nomina  TABLES ti_gt_file.
  "ti_out_reg_bci TYPE ty_t_out_reg_bci.
  DATA: output            TYPE zbciiservicio_pago_bci_cargar,
        input             TYPE zbciiservicio_pago_bci_cargar1,
        lw_request        TYPE zbcicargar_nomina_request,
        lw_atributos      TYPE zbciatributos_to,
        lw_nomina_result  TYPE zbcicargar_nomina_response,
        lw_error          TYPE zbcierror_to,
        proxy             TYPE REF TO zbcico_iservicio_pago_bci,
        lo_sys_exception1 TYPE REF TO cx_ai_system_fault,
        lo_sys_exception2 TYPE REF TO cx_ai_application_fault,
        lw_zfi_log_ws     TYPE zfi_log_ws,
        l_exception_msg   TYPE string,
        lv_archivo        TYPE string,
        lv_cuerpo         TYPE xstring,
        lv_cuerp64        TYPE string,
        lv_rut            TYPE stcd1,
        lv_dv             TYPE char01,
        lv_codigocca      TYPE char10,
        lv_convenio       TYPE char10,
        lv_plantilla      TYPE char20,
        lv_gjahr          TYPE bkpf-gjahr,
        lv_belnr          TYPE bkpf-belnr,
        lv_error          TYPE c.
* ZFITR010_WS_NOVEDADES_F01  , RSTT_TEST
  CONCATENATE p_bukrs p_fecha gc_banco p_nomina '.txt' INTO lv_archivo.
  SPLIT wa_sociedad-stcd1 AT '-' INTO lv_rut
                                      lv_dv.
*  lv_cuerp64 = obj->if_http_utility~encode_base64( ti_gt_file ) .

  CALL FUNCTION 'SCMS_TEXT_TO_XSTRING'
    IMPORTING
      buffer   = lv_cuerpo
    TABLES
      text_tab = ti_gt_file
    EXCEPTIONS
      failed   = 1
      OTHERS   = 2.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.
  CALL FUNCTION 'SCMS_BASE64_ENCODE_STR'
    EXPORTING
      input  = lv_cuerpo
    IMPORTING
      output = lv_cuerp64.
*
  TRY.
      CREATE OBJECT proxy
        EXPORTING
          logical_port_name = wa_sociedad-puerto.

    CATCH cx_ai_system_fault      INTO lo_sys_exception1.
      l_exception_msg = lo_sys_exception1->get_text( ).
  ENDTRY.
*
  IF l_exception_msg IS INITIAL.
    TRY.

* INFORMACION ESTRUCTURA DD ATRIBUTOS
        lv_codigocca                   = |{ wa_zfitr016-codigo_cca ALPHA = OUT }|.
        lv_convenio                    = |{ wa_zfitr016-convenio   ALPHA = OUT }|.
        lw_request-convenio            = condense( lv_convenio ).
        lw_atributos-codigo_cca        = condense( lv_codigocca ).
        lw_atributos-modo_servicio     = wa_zfitr016-modo_servicio.
        lw_atributos-contenido_nomina  = wa_zfitr016-contenido_nomina.
        lw_request-atributos           = lw_atributos.
* INFORMACION DEL DETALLE
        IF p_fecpag IS NOT INITIAL.
          lw_request-fecha_pago        =  |{ p_fecpag DATE = USER }|.
          TRANSLATE lw_request-fecha_pago USING './'.
        ENDIF.
        lv_plantilla                 = |{ wa_zfitr016-plantilla_archivo ALPHA = OUT }|.
        lw_request-rut_empresa       = lv_rut.
        lw_request-dv_empresa        = lv_dv.
        lw_request-rut_usuario       = lv_rut.
        lw_request-dv_usuario        = lv_dv.
        lw_request-nombre_archivo    = lv_archivo.
        lw_request-tipo_pago         = wa_zfitr016-tipo_pago.
        lw_request-plantilla_archivo = condense( lv_plantilla ).
        lw_request-cuerpo_archivo    = lv_cuerp64.
        input-request                = lw_request.
*
        CALL METHOD proxy->cargar_nomina
          EXPORTING
            input  = input
          IMPORTING
            output = output.

        PERFORM graba_log USING lv_rut lv_dv
                                input
                                output
                                l_exception_msg
                                'CARGAR_NOMINA'
                          CHANGING lw_zfi_log_ws.
*
        lw_nomina_result          = output-cargar_nomina_result.
        lw_error                  = lw_nomina_result-error.
*
        lw_zfi_log_ws-fecha_pago  = p_fecpag.
        lw_zfi_log_ws-icono_pdf   = icon_pdf.
        lw_zfi_log_ws-file_pdf    = lv_cuerpo.
        lw_zfi_log_ws-codigo_ret  = lw_error-codigo.
        TRANSLATE lw_zfi_log_ws-codigo_ret TO UPPER CASE.
        lw_zfi_log_ws-descripcion = lw_error-descripcion.
        lw_zfi_log_ws-estado      = lw_nomina_result-estado.
        lw_zfi_log_ws-archivo     = lw_nomina_result-nombre_archivo.
        lw_zfi_log_ws-num_folio   = lw_nomina_result-numero_folio.
*
        APPEND lw_zfi_log_ws TO gt_salida.
        MODIFY zfi_log_ws FROM  lw_zfi_log_ws.
*
        gv_secuencia = gv_secuencia + 1.
        IF gv_contabilizar NE 'N'.
          PERFORM  contabilizacion CHANGING lv_belnr
                                            lv_gjahr.

          PERFORM  grabar_log_pago USING lv_belnr
                                         lv_gjahr.
        ENDIF.
*
      CATCH cx_ai_system_fault      INTO lo_sys_exception1.
        l_exception_msg = lo_sys_exception1->get_text( ).
      CATCH cx_ai_application_fault INTO lo_sys_exception2.
        l_exception_msg = lo_sys_exception2->get_text( ).
    ENDTRY.
  ELSE.
    PERFORM graba_log USING lv_rut lv_dv
                            input
                            output
                            l_exception_msg
                            'CARGAR_NOMINA'
                      CHANGING lw_zfi_log_ws.
*
    APPEND lw_zfi_log_ws TO gt_salida.
    MODIFY zfi_log_ws FROM  lw_zfi_log_ws.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  WS_RENDICION_NOMINA
*&---------------------------------------------------------------------*
FORM ws_rendicion_nomina .
  DATA: output            TYPE zbciiservicio_pago_bci_obtener,
        input             TYPE zbciiservicio_pago_bci_obtene1,
        lw_request        TYPE zbciobtener_nomina_request,
        proxy             TYPE REF TO zbcico_iservicio_pago_bci,
        lw_nomina_result  TYPE zbciobtener_nomina_response,
        lw_archivo        TYPE zbciarchivo_to,
        lw_error          TYPE zbcierror_to,
        lw_zfi_log_ws     TYPE zfi_log_ws,
        lo_sys_exception1 TYPE REF TO cx_ai_system_fault,
        lo_sys_exception2 TYPE REF TO cx_ai_application_fault,
        l_exception_msg   TYPE string,
        lv_cuerpo         TYPE xstring,
        lv_rut            TYPE stcd1,
        lv_dv             TYPE char01,
        lv_error          TYPE c.
*
  SPLIT wa_sociedad-stcd1 AT '-' INTO lv_rut
                                      lv_dv.
*
  TRY.
      CREATE OBJECT proxy
        EXPORTING
          logical_port_name = wa_sociedad-puerto.

    CATCH cx_ai_system_fault      INTO lo_sys_exception1.
      l_exception_msg = lo_sys_exception1->get_text( ).
    CATCH cx_ai_application_fault INTO lo_sys_exception2.
      l_exception_msg = lo_sys_exception2->get_text( ).
  ENDTRY.
*
  IF l_exception_msg IS INITIAL.
    TRY.
        SELECT bukrs, datum, uzeit, laufd, laufi, num_folio, fecha_pago
               INTO TABLE @DATA(lt_datos) UP TO 1 ROWS
               FROM zfi_log_ws WHERE bukrs      EQ @p_bukrs
                                AND  ubnkl      EQ @gc_banco
                                AND  laufd      EQ @p_fecha
                                AND  laufi      EQ @p_nomina
                                AND  proceso    EQ 'CARGAR_NOMINA'
                                AND  codigo_ret IN @gr_proceso    "('COD10','COD105')
                                AND  num_folio  NE 0
                 ORDER BY num_folio DESCENDING. "Se cambia orden por numero de folio HCD 20230502
        "  ORDER BY fecha_pago, datum, uzeit DESCENDING.
        IF sy-subrc EQ 0.
          DATA(lw_datos)                = lt_datos[ 1 ].
          lw_request-fecha             =  |{ lw_datos-fecha_pago DATE = USER }|.
          TRANSLATE lw_request-fecha USING './'.
          lw_request-convenio          = condense( |{ wa_zfitr016-convenio ALPHA = OUT }| ).
          lw_request-rut_empresa       = lv_rut.
          lw_request-dv_empresa        = lv_dv.
          lw_request-rut_usuario       = lv_rut.
          lw_request-dv_usuario        = lv_dv.
          lw_request-numero_folio      = condense( |{ lw_datos-num_folio ALPHA = OUT }| ).
          lw_request-tipo              = wa_zfitr016-tipo_rendicion.
          input-request                = lw_request.

          CALL METHOD proxy->obtener_nomina
            EXPORTING
              input  = input
            IMPORTING
              output = output.
*
          PERFORM graba_log USING lv_rut lv_dv
                                  input
                                  output
                                  l_exception_msg
                                  'OBTENER_NOMINA'
                            CHANGING lw_zfi_log_ws.
          lw_zfi_log_ws-proceso     = 'RENDICION_NOMINA'.
*
          lw_nomina_result          = output-obtener_nomina_result.
          lw_archivo                = lw_nomina_result-archivo.
          lw_error                  = lw_nomina_result-error.
*
          lw_zfi_log_ws-codigo_ret      = lw_error-codigo.
          TRANSLATE lw_zfi_log_ws-codigo_ret TO UPPER CASE.
          lw_zfi_log_ws-descripcion     = lw_error-descripcion.
          lw_zfi_log_ws-estado          = lw_nomina_result-estado.
          lw_zfi_log_ws-archivo         = lw_archivo-nom_archivo.
          lw_zfi_log_ws-num_folio       = lw_archivo-folio.
          lw_zfi_log_ws-envios_erroneos = 1.
*
          IF lw_archivo-cuerpo IS NOT INITIAL.
            CALL FUNCTION 'SCMS_BASE64_DECODE_STR'
              EXPORTING
                input  = lw_archivo-cuerpo
              IMPORTING
                output = lv_cuerpo
              EXCEPTIONS
                failed = 1
                OTHERS = 2.
            IF sy-subrc <> 0.
* Implement suitable error handling here
            ELSE.
              PERFORM verifica_acentos CHANGING lv_cuerpo.
              lw_zfi_log_ws-icono_pdf   = icon_pdf.
              lw_zfi_log_ws-file_pdf    = lv_cuerpo.

              PERFORM procesa_rendicion USING lv_cuerpo.
            ENDIF.
          ENDIF.
*
          APPEND lw_zfi_log_ws TO gt_salida.
          MODIFY zfi_log_ws FROM  lw_zfi_log_ws.

          IF lw_zfi_log_ws-codigo_ret IN gr_proceso.
            UPDATE zfi_log_ws SET rendicion_nom = gc_x
                                WHERE bukrs      EQ lw_datos-bukrs
                                 AND  datum      EQ lw_datos-datum
                                 AND  uzeit      EQ lw_datos-uzeit
                                 AND  ubnkl      EQ gc_banco
                                 AND  proceso    EQ 'CARGAR_NOMINA'
                                 AND  laufd      EQ lw_datos-laufd
                                 AND  laufi      EQ lw_datos-laufi
                                 AND  codigo_ret IN gr_proceso          "('COD10','COD105')
                                 AND  num_folio  EQ lw_datos-num_folio.
            COMMIT WORK AND WAIT.
          ENDIF.
        ELSE.
          MESSAGE i899(fi) WITH 'Información no encontrada'.
        ENDIF.
*
      CATCH cx_ai_system_fault      INTO lo_sys_exception1.
        l_exception_msg = lo_sys_exception1->get_text( ).
      CATCH cx_ai_application_fault INTO lo_sys_exception2.
        l_exception_msg = lo_sys_exception2->get_text( ).
    ENDTRY.
  ELSE.
    PERFORM graba_log USING lv_rut lv_dv
                            input
                            output
                            l_exception_msg
                            'OBTENER_NOMINA'
                      CHANGING lw_zfi_log_ws.
    lw_zfi_log_ws-proceso = 'RENDICION_NOMINA'.
*
    APPEND lw_zfi_log_ws TO gt_salida.
    MODIFY zfi_log_ws FROM  lw_zfi_log_ws.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GRABA_LOG
*&---------------------------------------------------------------------*
FORM graba_log  USING    p_lv_rut
                         p_lv_dv
                         p_input
                         p_output
                         p_exception_msg
                         p_proceso
               CHANGING lw_zfi_log_ws TYPE zfi_log_ws.
*
  CLEAR lw_zfi_log_ws.
  lw_zfi_log_ws-bukrs           = p_bukrs.
  lw_zfi_log_ws-datum           = sy-datum.
  lw_zfi_log_ws-uzeit           = sy-uzeit.
  lw_zfi_log_ws-uname           = sy-uname.
  lw_zfi_log_ws-rut_empresa     = p_lv_rut  && '-' && p_lv_dv.
  lw_zfi_log_ws-proceso         = p_proceso.
  lw_zfi_log_ws-ubnkl           = gc_banco.
  lw_zfi_log_ws-laufd           = p_fecha.
  lw_zfi_log_ws-laufi           = p_nomina.
*
  PERFORM lee_xml USING p_input
                       'ZBCICO_ISERVICIO_PAGO_BCI'
                       p_proceso
                       'I'
                  CHANGING lw_zfi_log_ws-xml_envio
                           lw_zfi_log_ws-icono_envio.

  PERFORM lee_xml USING p_output
                       'ZBCICO_ISERVICIO_PAGO_BCI'
                       p_proceso
                       'R'
                  CHANGING lw_zfi_log_ws-xml_respuesta
                           lw_zfi_log_ws-icono_respuesta.
*
  IF lw_zfi_log_ws-xml_envio     IS INITIAL AND
     lw_zfi_log_ws-xml_respuesta IS INITIAL.
    lw_zfi_log_ws-xml_envio = p_exception_msg.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  LEE_XML
*&---------------------------------------------------------------------*
FORM lee_xml  USING    p_wa_in
                       p_obj_name
                       p_method
                       p_tipo_envio
              CHANGING p_xml_myid
                       p_icono.
  DATA: xsalida  TYPE string,
        l_name   TYPE sychar20,
        l_transf TYPE sychar50.
*
  CHECK p_wa_in IS NOT INITIAL.
  SELECT SINGLE name INTO l_name
          FROM sproxxsl WHERE class  EQ p_obj_name AND
                              method EQ p_method.
  IF sy-subrc EQ 0.
    CASE p_tipo_envio.
      WHEN 'I'.
        CONCATENATE '/1SAI/TAS' l_name INTO l_transf.
        CALL TRANSFORMATION (l_transf)
             SOURCE input = p_wa_in
             RESULT XML xsalida.
      WHEN 'R'.
        CONCATENATE '/1SAI/TXS' l_name INTO l_transf.
        CALL TRANSFORMATION (l_transf)
          SOURCE output = p_wa_in
          RESULT XML xsalida.
    ENDCASE.

    p_xml_myid = cl_abap_codepage=>convert_to( xsalida ).
  ELSE.
    xsalida        = 'LECTURA DE XML NO FUE POSIBLE'.
    p_xml_myid = cl_abap_codepage=>convert_to( xsalida ).
  ENDIF.
*
  CASE p_tipo_envio.
    WHEN 'I'. p_icono = icon_xml_doc.
    WHEN 'R'. p_icono = icon_output_request.
  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  LEE_DATOS
*&---------------------------------------------------------------------*
FORM lee_datos .
  DATA : lr_proce TYPE RANGE OF zfi_log_ws-proceso,
         lr_fecha TYPE RANGE OF zfi_log_ws-laufd,
         lr_pago  TYPE RANGE OF zfi_log_ws-fecha_pago.
*
  IF p_proces IS NOT INITIAL.
    READ TABLE gt_list INTO DATA(lw_list) WITH KEY key = p_proces.
    lr_proce = VALUE #( sign = 'I' option = 'EQ'
                      ( low = lw_list-text ) ).
  ENDIF.
  IF p_fecha IS NOT INITIAL.
    lr_fecha = VALUE #( sign = 'I' option = 'EQ'
                      ( low = p_fecha ) ).
  ENDIF.
  IF p_fecpag IS NOT INITIAL.
    lr_pago  = VALUE #( sign = 'I' option = 'EQ'
                      ( low = p_fecpag ) ).
  ENDIF.
*
  SELECT * INTO TABLE gt_salida
         FROM zfi_log_ws WHERE bukrs       EQ p_bukrs
                         AND   laufd       IN lr_fecha
                         AND   datum       IN s_datum
                         AND   fecha_pago  IN lr_pago
                         AND   uname       IN s_uname
                         AND   proceso     IN lr_proce.
*
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  MUESTRA_DATOS
*&---------------------------------------------------------------------*
FORM muestra_datos .
  DATA: lt_sort       TYPE lvc_t_sort,
        lt_fieldcat   TYPE lvc_t_fcat,
        lv_grid_title TYPE lvc_title VALUE 'Reporte Envios BCI',
        wa_layout     TYPE lvc_s_layo.
*
  MOVE sy-repid           TO gv_repid.
  PERFORM layout_init     USING wa_layout.
  PERFORM fieldcat_init   USING lt_fieldcat[].
  PERFORM sort            USING lt_sort[].

*
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY_LVC'
    EXPORTING
      i_callback_program       = gv_repid
      i_callback_pf_status_set = 'PF_STATUS'
      i_callback_user_command  = 'USER_COMMAND'
      i_grid_title             = lv_grid_title
      is_layout_lvc            = wa_layout
      it_fieldcat_lvc          = lt_fieldcat[]
      it_sort_lvc              = lt_sort
      i_save                   = 'A'
    TABLES
      t_outtab                 = gt_salida
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  user_command
*&---------------------------------------------------------------------*
FORM user_command USING r_ucomm    LIKE sy-ucomm            "#EC NEEDED
                        rs_selfield TYPE slis_selfield.     "#EC CALLED
  DATA lw_salida TYPE zfi_log_ws.
*
  CASE rs_selfield-fieldname.
    WHEN 'ICONO_ENVIO'.
      READ TABLE gt_salida INTO lw_salida INDEX rs_selfield-tabindex.
      IF sy-subrc EQ 0.
        PERFORM muestra_xml USING lw_salida-xml_envio.
      ENDIF.
    WHEN 'ICONO_RESPUESTA'.
      READ TABLE gt_salida INTO lw_salida INDEX rs_selfield-tabindex.
      IF sy-subrc EQ 0.
        PERFORM muestra_xml USING lw_salida-xml_respuesta.
      ENDIF.
    WHEN 'ICONO_PDF'.
      READ TABLE gt_salida INTO lw_salida INDEX rs_selfield-tabindex.
      IF sy-subrc EQ 0.
        PERFORM muestra_pdf USING lw_salida.
      ENDIF.
  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  PF_STATUS
*&---------------------------------------------------------------------*
FORM pf_status USING ce_func_exclude TYPE slis_t_extab.     "#EC CALLED
  DATA: fcode_attrib_tab LIKE smp_dyntxt OCCURS 4 WITH HEADER LINE,
        l_procesado      TYPE char50.
*
  CLEAR: fcode_attrib_tab, fcode_attrib_tab[].
*
  PERFORM dynamic_report_fcodes(rhteiln0) TABLES fcode_attrib_tab
                                          USING  ce_func_exclude
                                                 ' ' ' '.
  SET PF-STATUS 'ALVLIST' EXCLUDING ce_func_exclude
                                              OF PROGRAM 'RHTEILN0'.
ENDFORM.                    "PF_STATUS
*&---------------------------------------------------------------------*
*&      Form  LAYOUT_INIT
*&---------------------------------------------------------------------*
FORM layout_init USING rs_layout TYPE lvc_s_layo.
  CLEAR rs_layout.
*  rs_layout-f2code               = 'DISPLAY'.
  rs_layout-zebra                = gc_x.
  rs_layout-detailinit           = gc_x.
  rs_layout-cwidth_opt           = gc_x.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FIELDCAT_INIT
*&---------------------------------------------------------------------*
FORM fieldcat_init  USING p_gt_fieldcat TYPE  lvc_t_fcat.
*
  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name       = gc_tabla
    CHANGING
      ct_fieldcat            = p_gt_fieldcat
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
*
  LOOP AT p_gt_fieldcat ASSIGNING FIELD-SYMBOL(<datos>).
*
    CASE <datos>-fieldname.
      WHEN 'BUKRS'.
        <datos>-key       = gc_x.
      WHEN 'DATUM'.
        <datos>-scrtext_m = 'Fecha Envio'.
        <datos>-key       = gc_x.
      WHEN 'UZEIT'.
        <datos>-scrtext_m = 'Hora Envio'.
        <datos>-key       = gc_x.
      WHEN 'RUT_EMPRESA'.
        <datos>-scrtext_m = 'RUT Empresa'.
        <datos>-key       = gc_x.
      WHEN 'RUT_USUARIO'.
        <datos>-scrtext_m = 'RUT Proveedor'.
        <datos>-key       = gc_x.
        <datos>-tech      = gc_x.
      WHEN 'PROCESO'.
        <datos>-scrtext_m = 'Proceso XML'.
        <datos>-key       = gc_x.
      WHEN 'LAUFD'.
        <datos>-scrtext_m = 'Fecha de propuesta'.
      WHEN 'XML_ENVIO' OR 'XML_RESPUESTA' OR 'FILE_PDF'.
        <datos>-tech      = gc_x.
      WHEN 'ICONO_ENVIO'.
        <datos>-scrtext_m = 'XML Envio'.
        <datos>-icon      = gc_x.
        <datos>-hotspot   = gc_x.
      WHEN 'ICONO_RESPUESTA'.
        <datos>-scrtext_m = 'XML Respuesta'.
        <datos>-icon      = gc_x.
        <datos>-hotspot   = gc_x.
      WHEN 'ICONO_PDF'.
        <datos>-scrtext_m = 'Archivo'.
        <datos>-icon      = gc_x.
        <datos>-hotspot   = gc_x.
      WHEN 'ESTADO'.
        <datos>-scrtext_m = 'Estado'.
        <datos>-emphasize = 'C210'.
      WHEN 'CODIGO_RET'.
        <datos>-scrtext_m = 'Código Retorno'.
        <datos>-emphasize = 'C210'.
      WHEN 'DESCRIPCION'.
        <datos>-scrtext_m = 'Descripción'.
        <datos>-emphasize = 'C210'.
      WHEN 'ARCHIVO'.
        <datos>-scrtext_m = 'Nombre Archivo'.
        <datos>-emphasize = 'C210'.
      WHEN 'NUM_FOLIO'.
        <datos>-scrtext_m = 'Folio Retorno'.
        <datos>-emphasize = 'C210'.
      WHEN 'RENDICION_NOM'.
        <datos>-scrtext_m = 'Con Rendición'.
      WHEN 'ENVIOS_ERRONEOS'.
        <datos>-tech      = gc_x.
    ENDCASE.
    <datos>-colddictxt = 'M'.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SORT
*&---------------------------------------------------------------------*
FORM sort  USING    p_lt_sort TYPE lvc_t_sort.
  DATA lw_sort TYPE lvc_s_sort.
*
  CLEAR p_lt_sort[].
  lw_sort-fieldname = 'BUKRS'.
  lw_sort-up        = gc_x.
  APPEND lw_sort TO p_lt_sort.
*
  lw_sort-fieldname = 'PROCESO'.
  lw_sort-up        = gc_x.
  APPEND lw_sort TO p_lt_sort.
*
  lw_sort-fieldname = 'DATUM'.
  lw_sort-up        = gc_x.
  APPEND lw_sort TO p_lt_sort.
*
  lw_sort-fieldname = 'UZEIT'.
  lw_sort-up        = gc_x.
  APPEND lw_sort TO p_lt_sort.
*
  lw_sort-fieldname = 'RUT_EMPRESA'.
  lw_sort-up        = gc_x.
  APPEND lw_sort TO p_lt_sort.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  MUESTRA_XML
*&---------------------------------------------------------------------*
FORM muestra_xml  USING  p_lw_salida.

  CALL FUNCTION 'DISPLAY_XML_STRING'
    EXPORTING
      xml_string      = p_lw_salida
*     TITLE           =
*     STARTING_X      = 5
*     STARTING_Y      = 5
    EXCEPTIONS
      no_xml_document = 1
      OTHERS          = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  MUESTRA_PDF
*&---------------------------------------------------------------------*
FORM muestra_pdf  USING p_zfi_log_ws TYPE zfi_log_ws.
  " binary itab definations
  TYPES: BEGIN OF ty_itab,
           line TYPE x LENGTH 255,
         END OF ty_itab.
  "Global Data Definations
  DATA: go_pdf_object  TYPE REF TO cl_gui_html_viewer,
        go_pdf_dialog  TYPE REF TO cl_gui_dialogbox_container,
        go_pdf_handler TYPE REF TO lcl_evt_handler.
  DATA: lt_itab  TYPE STANDARD TABLE OF x255, "ty_itab,
        lv_url   TYPE char255,
        lv_type  TYPE char20,
        ls_str   TYPE string,
        lt_str   TYPE TABLE OF string,
        lt_data  TYPE STANDARD TABLE OF x255,
        lv_title TYPE char255,
        lv_name  TYPE string,
        lv_size  TYPE i VALUE 0.

*
  CASE p_zfi_log_ws-proceso.
    WHEN 'CARGAR_NOMINA'.
      lv_type =  'text'.
      CALL METHOD cl_abap_conv_in_ce=>create
        EXPORTING
          input = p_zfi_log_ws-file_pdf
        RECEIVING
          conv  = DATA(lr_conv).

      CALL METHOD lr_conv->read
        IMPORTING
          data = ls_str.

*      SPLIT ls_str AT cl_abap_char_utilities=>cr_lf INTO TABLE DATA(lt_string).
*      CALL FUNCTION 'POPUP_DISPLAY_STRINGS' "Display a table of strings
*        EXPORTING
*          p_tab           = lt_string             " vmcdbg_string_table  Table of string values
*          p_title         = 'prueba'                " string
*          p_column_header = 'datos'        " string
*        .  "  POPUP_DISPLAY_STRINGS

      lv_title = 'Archivo enviado : ' && | | && p_zfi_log_ws-archivo.
      cl_abap_browser=>show_html(
          EXPORTING
              html_string = ls_str
              title       = lv_title ).

    WHEN 'RENDICION_NOMINA'.
      lv_type =  'text'.
      CALL METHOD cl_abap_conv_in_ce=>create
        EXPORTING
          input = p_zfi_log_ws-file_pdf
        RECEIVING
          conv  = DATA(lr_conv2).

      CALL METHOD lr_conv2->read
        IMPORTING
          data = ls_str.

      lv_title = 'Archivo Nomina : ' && | | && p_zfi_log_ws-archivo.
      cl_abap_browser=>show_html(
          EXPORTING
              html_string = ls_str
              title       = lv_title ).
*    WHEN 'OBTENER_NOMINA'.
**      lv_type =  'pdf'.
*      " xstring to binary
*      CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
*        EXPORTING
*          buffer        = p_zfi_log_ws-file_pdf
*        IMPORTING
*          output_length = lv_size
*        TABLES
*          binary_tab    = lt_data. "lt_itab.
*      " create dialogbox and set data
*      lv_title = 'Archivo Nomina : ' && | | && p_zfi_log_ws-archivo.
*      CREATE OBJECT go_pdf_dialog
*        EXPORTING
*          width   = 900
*          height  = 450
*          caption = lv_title.
*
*      CREATE OBJECT go_pdf_object
*        EXPORTING
*          parent = go_pdf_dialog.
*
*      CREATE OBJECT go_pdf_handler.
*      SET HANDLER   go_pdf_handler->event_close FOR go_pdf_dialog.
**
*      CALL METHOD go_pdf_object->load_data
*        EXPORTING
*          type                   = 'application'
*          subtype                = lv_type
*          size                   = lv_size
*        IMPORTING
*          assigned_url           = lv_url
*        CHANGING
*          data_table             = lt_data
*        EXCEPTIONS
*          dp_invalid_parameter   = 1
*          dp_error_general       = 2
*          cntl_error             = 3
*          html_syntax_notcorrect = 4
*          OTHERS                 = 5.
*
*      CALL METHOD go_pdf_object->show_data
*        EXPORTING
*          url      = lv_url
*          in_place = abap_true.
*
*      CALL METHOD go_pdf_dialog->set_visible
*        EXPORTING
*          visible = abap_true.
  ENDCASE.
ENDFORM.

CLASS lcl_evt_handler IMPLEMENTATION.
  METHOD event_close.
    CALL METHOD sender->set_visible
      EXPORTING
        visible = space.
    CALL METHOD sender->free( ).
  ENDMETHOD.
ENDCLASS.
*&---------------------------------------------------------------------*
*&      Form  ACTUALIZA_TABLA
*&---------------------------------------------------------------------*
FORM actualiza_tabla .
  DATA : lt_sellist        TYPE TABLE OF vimsellist,
         lt_excl_cua_funct TYPE TABLE OF vimexclfun,
         lv_view           TYPE dd02v-tabname VALUE 'ZFITR016'.
* MUESTRA TABLA
  CALL FUNCTION 'VIEW_MAINTENANCE_CALL'
    EXPORTING
      action            = 'S'
      view_name         = lv_view
      suppress_wa_popup = 'X'
    TABLES
      dba_sellist       = lt_sellist
      excl_cua_funct    = lt_excl_cua_funct.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CONTABILIZACION
*&---------------------------------------------------------------------*
FORM contabilizacion CHANGING p_belnr
                              p_gjahr.
  DATA: bdcdata_tab  TYPE TABLE OF bdcdata,
        lt_itab      TYPE TABLE OF bdcmsgcoll,
        lw_opt       TYPE ctu_params,
        lv_xblnr     TYPE bkpf-xblnr,
        lv_total     TYPE bseg-dmbtr,
        lv_valor(18) TYPE c.
*
  lv_valor = gv_sumpagos.
  REPLACE '.00' WITH '' INTO lv_valor.
  CONDENSE lv_valor NO-GAPS.

  lv_total = gv_sumpagos.
  CONCATENATE p_fecha p_nomina  gv_secuencia INTO lv_xblnr.

  bdcdata_tab = VALUE #(
    ( program  = 'SAPMF05A'     dynpro   = '0100' dynbegin = 'X' )
    ( fnam     = 'BDC_OKCODE'        fval     = '/00'         )
    ( fnam     = 'BKPF-BLDAT'        fval     = gv_zaldt      )
    ( fnam     = 'BKPF-BLART'        fval     = 'SA'          )
    ( fnam     = 'BKPF-BUKRS'        fval     = p_bukrs       )
    ( fnam     = 'BKPF-BUDAT'        fval     = gv_zaldt      )
    ( fnam     = 'BKPF-WAERS'        fval     = 'CLP'         )
    ( fnam     = 'BKPF-XBLNR'        fval     = lv_xblnr      )
    ( fnam     = 'BKPF-BKTXT'        fval     = gv_bktxt      )
    ( fnam     = 'RF05A-NEWBS'       fval     = '40'          )
    ( fnam     = 'RF05A-NEWKO'       fval     = gv_cuenta     )


    ( program  = 'SAPMF05A'     dynpro   = '0300' dynbegin = 'X' )
    ( fnam     = 'BDC_OKCODE'        fval     = '/00'         )
    ( fnam     = 'BSEG-WRBTR'        fval     = lv_valor      )
    ( fnam     = 'BSEG-VALUT'        fval     = gv_valut      )
    ( fnam     = 'BSEG-ZUONR'        fval     = gv_bktxt      )
    ( fnam     = 'BSEG-SGTXT'        fval     = gv_bktxt      )
    ( fnam     = 'RF05A-NEWBS'       fval    = '50'           )
    ( fnam     = 'RF05A-NEWKO'       fval    = gv_cuenta_2    )

    ( program  = 'SAPLKACB'     dynpro   = '0002' dynbegin = 'X' )
    ( fnam     = 'BDC_OKCODE'        fval     = '=ENTE'       )
    ( fnam     = 'COBL-ZZMOT_EMIS'   fval     = gv_zzmot_emis )

    ( program  = 'SAPMF05A'     dynpro   = '0300' dynbegin = 'X' )
    ( fnam     = 'BDC_OKCODE'        fval     = '=BU'         )
    ( fnam     = 'BSEG-WRBTR'        fval     = lv_valor      )
    ( fnam     = 'BSEG-VALUT'        fval     = gv_valut      )
    ( fnam     = 'BSEG-ZUONR'        fval     = gv_bktxt      )
    ( fnam     = 'BSEG-SGTXT'        fval     = gv_bktxt      )

    ( program  = 'SAPLKACB'     dynpro   = '0002' dynbegin = 'X' )
    ( fnam     = 'BDC_OKCODE'        fval     = '=ENTE'       )
    ( fnam     = 'COBL-ZZMOT_EMIS'   fval     = gv_zzmot_emis )
    ).

  lw_opt-dismode = 'E'.
  lw_opt-defsize = 'X'.

  TRY.
      CALL TRANSACTION 'F-02' WITH AUTHORITY-CHECK
                              USING bdcdata_tab OPTIONS FROM lw_opt
                              MESSAGES INTO lt_itab.

      LOOP AT lt_itab INTO DATA(lw_itab).
        IF lw_itab-msgid = 'F5' AND lw_itab-msgnr = '312'.
          p_belnr = lw_itab-msgv1.
          p_gjahr = gv_zaldt+4(4).
        ENDIF.
      ENDLOOP.
    CATCH cx_sy_authorization_error ##NO_HANDLER.
  ENDTRY.
*

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GRABAR_LOG_PAGO
*&---------------------------------------------------------------------*
FORM grabar_log_pago  USING    p_belnr
                               p_gjahr.
  DATA : wa_pago_bancos TYPE zlog_pago_bancos.
*
  wa_pago_bancos-bukrs     = p_bukrs.
  wa_pago_bancos-ubnkl     = gc_banco.
  SHIFT wa_pago_bancos-ubnkl LEFT DELETING LEADING space.
  wa_pago_bancos-laufd     = p_fecha.
  wa_pago_bancos-laufi     = p_nomina.
  wa_pago_bancos-fecha_gen = sy-datum.
  wa_pago_bancos-hora_gen  = sy-uzeit.
  wa_pago_bancos-uname     = sy-uname.
  CONCATENATE p_bukrs p_fecha p_nomina  gv_secuencia INTO wa_pago_bancos-nombre_arc.
  wa_pago_bancos-total     = gv_sumpagos.
  wa_pago_bancos-lineas    = gv_lineas.
  wa_pago_bancos-gjahr     = p_gjahr.
  wa_pago_bancos-belnr     = p_belnr.
  wa_pago_bancos-nrotran   = p_nrotra.
  INSERT zlog_pago_bancos FROM wa_pago_bancos.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  PROCESA_RENDICION
*&---------------------------------------------------------------------*
FORM procesa_rendicion  USING    p_lv_cuerpo.
* revisar funcion ZFITR040037B
  DATA : lt_table       TYPE TABLE OF string,
         lt_rendicion   TYPE ty_t_rendicion,
         lw_rendicion   TYPE ty_rendicion,
         ws_rendicion   TYPE ty_rendicion,
         ws_suma(13)    TYPE n,
         lw_conv        TYPE REF TO cl_abap_conv_in_ce,
         lw_znovedad    TYPE znovedadbanco,
         lv_text        TYPE string,
         lv_uzeit       TYPE syuzeit,
         lv_datum       TYPE sydatum,
         lv_nomina      TYPE char15,
         lv_identif     TYPE numc11,
         lv_rut_empresa TYPE char12,
         lv_numlot      TYPE numc3.

*
  lw_conv      = cl_abap_conv_in_ce=>create( input = p_lv_cuerpo ).
  lw_conv->read( IMPORTING data = lv_text ).
  SPLIT lv_text AT cl_abap_char_utilities=>newline INTO: TABLE lt_table.
*
** INI RVY 29-05-2023
*  LOOP AT lt_table INTO DATA(lw_table) FROM 2.
*    lw_rendicion = lw_table.
*    APPEND lw_rendicion TO lt_rendicion.
*  ENDLOOP.
  LOOP AT lt_table INTO DATA(lw_table).
    lw_rendicion = lw_table.
    IF sy-tabix = 1.
      ws_rendicion = lw_rendicion.
      ws_suma      = lw_rendicion-monto_pago.
    ELSE.
      IF lw_rendicion-nro_documento = ws_rendicion-nro_documento.
        ws_suma = ws_suma + lw_rendicion-monto_pago.
      ELSE.
        ws_rendicion-monto_pago = ws_suma.
        APPEND ws_rendicion TO lt_rendicion.
        ws_rendicion = lw_rendicion.
        ws_suma      = lw_rendicion-monto_pago.
      ENDIF.
    ENDIF.
  ENDLOOP.
  ws_rendicion-monto_pago = ws_suma.
  APPEND ws_rendicion TO lt_rendicion.
** FIN RVY 29-06-2023
**
  IF lt_rendicion[] IS NOT INITIAL.
    PERFORM numero_folio CHANGING lv_numlot.
*
    lv_rut_empresa        = wa_sociedad-stcd1.
    TRANSLATE lv_rut_empresa USING '- '.
    CONDENSE lv_rut_empresa NO-GAPS.
*
    lv_uzeit  = sy-uzeit.
    lv_datum  = sy-datum.
    lv_nomina = '0' && lv_datum && lv_uzeit.
*
    LOOP AT lt_rendicion INTO lw_rendicion.
      CLEAR lw_znovedad.
*
      lv_identif            = lw_rendicion-nro_documento.
*
      lw_znovedad-sociedad  = p_bukrs.
      lw_znovedad-banco     = gc_banco.
      lw_znovedad-identif   = p_bukrs && lv_identif.
      lw_znovedad-fecha     = lv_datum.
      lw_znovedad-hora      = lv_uzeit.
      lw_znovedad-nomina    = lv_nomina.
      lw_znovedad-numemp    = |{ lv_rut_empresa ALPHA = IN }|.
      lw_znovedad-rutemi    = lv_rut_empresa.
      lw_znovedad-cuenta    = wa_zfitr016-cta_cte.  "lw_rendicion-nro_cta_destino.
      lw_znovedad-nomben    = lw_rendicion-razon_social.
      lw_znovedad-rutben    = lw_rendicion-rut_beneficiario && lw_rendicion-div_beneficiario.
      lw_znovedad-montow    = lw_rendicion-monto_pago.
      lw_znovedad-fecpag    = lw_rendicion-fecha_pago+4(4) && lw_rendicion-fecha_pago+2(2) && lw_rendicion-fecha_pago+0(2).
      lw_znovedad-numlot    = lv_numlot.
      lw_znovedad-numche    = '000000000'.
      lw_znovedad-vvmcad    = ''.
      lw_znovedad-cenpag    = '0000'.
      lw_znovedad-fecrec    = lv_datum.
      lw_znovedad-fecpro    = lv_datum.
      lw_znovedad-fecest    = lv_datum.
*
      TRANSLATE lw_rendicion-estado_pago TO UPPER CASE.
      SELECT SINGLE * INTO @DATA(lw_estado_banco)
        FROM zestadosbanco WHERE banco  EQ @gc_banco
                             AND codban EQ @lw_rendicion-estado_pago.
      IF sy-subrc = 0.
        lw_znovedad-estpag   = lw_estado_banco-codint.
      ELSE.
        lw_znovedad-estpag   = lw_rendicion-estado_pago.
      ENDIF.
*
      CASE lw_znovedad-estpag.
        WHEN 'PAGADO'.
          lw_znovedad-estado    = '1'.
        WHEN OTHERS.
          lw_znovedad-estado    = '0'.
      ENDCASE.
* Si la novedad no ha sido procesada, se encuentra en estado "cero"
* cambia a un estatus para dejar fuera del proceso, se marcara con “8”.
      SELECT * INTO TABLE @DATA(lt_novedad)
           FROM znovedadbanco WHERE sociedad = @lw_znovedad-sociedad
                                AND banco    = @lw_znovedad-banco
                                AND identif  = @lw_znovedad-identif
                                AND estado   = '0'
                              ORDER BY  fecha DESCENDING,
                                        hora  DESCENDING.
      IF sy-subrc EQ 0.
        LOOP AT lt_novedad INTO DATA(lw_novedad).
          UPDATE znovedadbanco SET estado = '8'
                              WHERE sociedad = lw_novedad-sociedad
                                AND banco    = lw_novedad-banco
                                AND identif  = lw_novedad-identif
                                AND fecha    = lw_novedad-fecha
                                AND hora     = lw_novedad-hora.
        ENDLOOP.
        COMMIT WORK AND WAIT.
      ENDIF.
*
      SELECT SINGLE * INTO @DATA(lw_reguh)
             FROM reguh WHERE identif_pago EQ @lw_znovedad-identif.
      IF sy-subrc  = 0.
        INSERT znovedadbanco FROM lw_znovedad.
*
        IF  lw_znovedad-estpag EQ 'PAGADO' OR
            lw_znovedad-estpag EQ 'CHEQUE PAGADO'.
          lw_reguh-ind_pago   = 'X'.
          lw_reguh-fecha_pago = lw_znovedad-fecpag.
          MODIFY reguh FROM lw_reguh.
        ENDIF.
        COMMIT WORK AND WAIT.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  NUMERO_FOLIO
*&---------------------------------------------------------------------*
FORM numero_folio CHANGING p_numlot.
  DATA :  lw_zfolio    TYPE zfolio_soc02.
*
  CLEAR p_numlot.
  CALL FUNCTION 'ENQUEUE_EZ_FOLIO_SOC02'
    EXPORTING
      mode_zfolio_soc02 = 'E'
      mandt             = sy-mandt
      bukrs             = p_bukrs
      fecha             = sy-datum
      _scope            = 1
    EXCEPTIONS
      foreign_lock      = 1
      system_failure    = 2
      OTHERS            = 3.

  WHILE sy-subrc <> 0.
    CALL FUNCTION 'ENQUEUE_EZ_FOLIO_SOC02' " Se modifica 01-09-2020 HCD
      EXPORTING
        mode_zfolio_soc02 = 'E'
        mandt             = sy-mandt
        bukrs             = p_bukrs
        fecha             = sy-datum
        _scope            = 1
      EXCEPTIONS
        foreign_lock      = 1
        system_failure    = 2
        OTHERS            = 3.
  ENDWHILE.
*
  SELECT SINGLE *  INTO lw_zfolio
     FROM zfolio_soc02  WHERE bukrs  EQ p_bukrs
                          AND fecha  EQ sy-datum.
  IF sy-subrc <> 0.
    lw_zfolio-bukrs    = p_bukrs.
    lw_zfolio-fecha    = sy-datum.
    lw_zfolio-folsoc02 = 0.
  ENDIF.
* USO E INCREMENTO
  lw_zfolio-folsoc02 = lw_zfolio-folsoc02 + 1.
  MODIFY zfolio_soc02 FROM lw_zfolio.
  p_numlot = lw_zfolio-folsoc02.

* DESBLOQUEO
  CALL FUNCTION 'DEQUEUE_EZ_FOLIO_SOC02'
    EXPORTING
      mode_zfolio_soc02 = 'E'
      mandt             = sy-mandt.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  VALIDACION_ACCESOS
*&---------------------------------------------------------------------*
FORM validacion_accesos USING p_lv_bukrs.
*
  SELECT SINGLE puerto INTO @DATA(lv_puerto)
         FROM zws_puerto WHERE sociedad EQ @p_lv_bukrs
                           AND programa EQ 'ZFITR016'
                           AND estado   EQ 'H'.
  IF sy-subrc <> 0.
    MESSAGE i899(fi) WITH 'No existe puerto ws habilitado '
                          ' para este programa y Sociedad : '
                          sy-repid p_lv_bukrs.
    LEAVE PROGRAM.
  ELSE.
    SELECT SINGLE * INTO wa_zfitr016
           FROM zfitr016 WHERE bukrs EQ p_lv_bukrs.
    IF sy-subrc EQ 0.
      wa_sociedad-puerto = lv_puerto.
      SELECT SINGLE bukrs paval INTO (wa_sociedad-bukrs, wa_sociedad-stcd1 )
             FROM t001z WHERE bukrs EQ p_lv_bukrs
                          AND party EQ 'TAXNR'.
    ELSE.
      MESSAGE i899(fi) WITH 'No existen datos fijos para el WS '
                            ' verificar tabla ZFITR016  '.
      LEAVE PROGRAM.
    ENDIF.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  LEE_DATOS_SET
*&---------------------------------------------------------------------*
FORM lee_datos_set .
  TYPES : BEGIN OF ty_rango,
            sign TYPE  tvarvc-sign,
            opti TYPE  tvarvc-opti,
            low  TYPE  tvarvc-low,
            high TYPE  tvarvc-high,
          END OF ty_rango.
  DATA : lr_rango TYPE TABLE OF ty_rango.

  CLEAR gr_proceso[].
  SELECT sign opti low high INTO TABLE lr_rango
        FROM tvarvc WHERE name EQ 'ZWS_BCI_PROCESOS'
                    AND   type EQ 'S'.
  DELETE lr_rango WHERE opti EQ space.

  gr_proceso[] = lr_rango[].


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  VERIFICA_ACENTOS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_P_LV_CUERPO  text
*----------------------------------------------------------------------*
FORM verifica_acentos  CHANGING p_p_lv_cuerpo TYPE xstring.
  DATA : lv_string TYPE string.
*
  lv_string     = p_p_lv_cuerpo.
  SELECT text_hex_4110, text_hex_4103 INTO TABLE @DATA(lt_transf)
         FROM zfi_ws_transf WHERE text_hex_4110 NE @space.
  IF sy-subrc EQ 0.
    LOOP AT lt_transf INTO DATA(lw_transf).
      REPLACE ALL OCCURRENCES OF lw_transf-text_hex_4110 IN lv_string WITH lw_transf-text_hex_4103.
*      REPLACE ALL OCCURRENCES OF '76D5' IN lv_string WITH '7669'.
    ENDLOOP.
  ENDIF.
  p_p_lv_cuerpo =  lv_string.
ENDFORM.

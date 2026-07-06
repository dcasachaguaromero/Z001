*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES04 > *
*& Description: < ReSQ Correction > *
*& Date: <24-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Report       :ZDTE_CARGA_DTE
*& Autor        : Carlos López - E-Forza
*& Fecha       	: 17.03.2018 16:10:02
*& Descripción 	: Reporte Carga DTE
*&---------------------------------------------------------------------*

REPORT  zdte_carga_dte  NO STANDARD PAGE HEADING
                        LINE-SIZE 255.

*-----------------------------------------------------------------------
* DESCRIPTION  : Reporte Carga DTE
*
*
*
************************************************************************
* Historial de Modificaciones:
* ----------------------------------------------------------------------
* DATE      User ID    |TS Ver  | Transport Request  | Description
* ----------------------------------------------------------------------
*
*
*
************************************************************************

***************************************************
*Tablas
***************************************************
TABLES: zdte_doc_rec    ,
        zdte_doc_rec_ref,
        zbmnc_listabcab ,
        zdte_tabla_doc  .

***************************************************
*Type pools
***************************************************
*type-pools:

***************************************************
*Constantes
***************************************************
CONSTANTS:
           c_contabilizado(2)    VALUE 'CO',
           c_no_contabilizado(2) VALUE 'NC',
           c_rechazado(2)        VALUE 'RE',
           c_nuevo(2)            VALUE 'NU'.

***************************************************
*Variables globales
***************************************************

DATA: lt_dte_doc_rec            TYPE TABLE OF zdte_doc_rec     WITH HEADER LINE,
      lt_dte_doc_rec_ref        TYPE TABLE OF zdte_doc_rec_ref WITH HEADER LINE,
      wa_doc_rec                TYPE          zdte_doc_rec                     ,
      wa_doc_rec_ref            TYPE          zdte_doc_rec_ref                 .

DATA:   bdcdata LIKE bdcdata    OCCURS 0 WITH HEADER LINE.
*       messages of call transaction
DATA:   messtab LIKE bdcmsgcoll OCCURS 0 WITH HEADER LINE.

"Campos Conexión FTP
DATA: wa_datos                  TYPE  zemm157 ,
      o_retorno                 TYPE  subrc   .

DATA:   p_user(30) TYPE c .
DATA:   p_pwd(30)  TYPE c .
DATA:   p_ip(64)   TYPE c .



***************************************************
*SELECTION-SCREEN
***************************************************
SELECTION-SCREEN BEGIN OF BLOCK b1.
*select-options:
*parameters:
SELECTION-SCREEN END OF BLOCK b1.

INITIALIZATION.
  AUTHORITY-CHECK OBJECT 'S_TCODE'
     ID 'TCD' FIELD sy-tcode.
  IF sy-subrc NE 0.
    MESSAGE e077(s#) WITH sy-tcode.
  ENDIF.

***************************************************
***START-OF-SELECTION
***************************************************
START-OF-SELECTION.
  DATA: w_cierre_cont TYPE zdte_cierre_cont.
  DATA: w_t001z TYPE t001z.
  DATA fecha_max TYPE sy-datum.
  fecha_max = sy-datum - 7.

  PERFORM rutina.

***************************************************
***SUBRUTINAS
***************************************************

FORM rutina .
*

  DATA: vl_resultado  TYPE  subrc       ,
        vl_factura    TYPE  belnr_d     ,
        vl_ejercicio  TYPE  gjahr       ,
        vl_estado     TYPE  zdte_estado ,
        vl_mensaje    TYPE  bapi_msg    .
  "busca validaciones por sociedad
  DATA: ti_val_dte    TYPE STANDARD TABLE OF  zmm_val_dte WITH HEADER LINE.

  DATA: lv_bukrs           TYPE bukrs,
        lv_rzno_social     TYPE char01,
        lv_giro            TYPE char01,
        lv_dir             TYPE char01,
        lv_proveedor       TYPE char01,
        lv_hes             TYPE char01,
        lv_oc              TYPE char01,
        lv_retorno         TYPE char02,
        wa_doc_rec         TYPE zdte_doc_rec,
        ti_return          TYPE STANDARD TABLE OF  bapiret2 WITH HEADER LINE,
        gt_eksel           TYPE /bev1/ne_eksel_tt,
        gt_doc_rec_ref     TYPE TABLE OF zdte_doc_rec_ref.

  DATA: t_set TYPE TABLE OF setleaf WITH HEADER LINE.
  RANGES: s_tipodte FOR zdte_doc_rec-tipodte.
  RANGES: s_estado  FOR zdte_doc_rec-estado.

**Set de datos
  SELECT *
    FROM setleaf
    INTO TABLE t_set
   WHERE setname = 'ZDTE_CARGA_DTE'.

*Cargamos una tabla ranges
  LOOP AT t_set .
    s_tipodte-sign    = t_set-valsign.
    s_tipodte-option  = t_set-valoption.
    s_tipodte-low     = t_set-valfrom.
    APPEND s_tipodte.
  ENDLOOP.
  IF s_tipodte[] IS INITIAL .
    WRITE:/ 'Set de Datos vacío. Ingresar TipoDte a procesar ZDTE_CARGA_DTE'.
    EXIT.
  ENDIF.

  REFRESH s_estado.
  s_estado-sign    = 'I'.
  s_estado-option  = 'EQ'.
  s_estado-low     = c_nuevo.
  APPEND s_estado.
  s_estado-low     = c_no_contabilizado.
  APPEND s_estado.

  SELECT *
  INTO CORRESPONDING FIELDS OF TABLE lt_dte_doc_rec
  FROM zdte_doc_rec
*  WHERE estado  EQ c_nuevo
  WHERE estado  IN s_estado   "nuevo y no contab.
    AND tipodte IN s_tipodte. "

  IF sy-subrc EQ 0.
**********************************************************************
*
**********************************************************************
    DATA: lv_index TYPE sy-tabix.
    LOOP AT lt_dte_doc_rec INTO wa_doc_rec WHERE estado NE c_rechazado.
      lv_index = sy-tabix.
*ResQ Comment:Correction not required as Select Single is used 24/12/2019 EY_DES04 ECDK917080 *
      SELECT SINGLE * INTO w_t001z
        FROM t001z
       WHERE paval EQ wa_doc_rec-rutrecep.

      SELECT SINGLE * INTO w_cierre_cont
        FROM zdte_cierre_cont
       WHERE bukrs EQ w_t001z-bukrs
         AND gjahr EQ sy-datum(4)
         AND monat EQ sy-datum+4(2).
*         AND budat_ini GE sy-datum
*         AND budat_fin LE sy-datum.

      IF w_cierre_cont-budat_ini <= sy-datum AND w_cierre_cont-budat_fin >= sy-datum.
        WRITE: / 'Cierre Contable Sociedad:' , w_t001z-bukrs ,  sy-datum(4) , sy-datum+4(2) , sy-datum.
        wa_doc_rec-borrar = 'X'.
        MODIFY lt_dte_doc_rec FROM wa_doc_rec INDEX lv_index.
        CONTINUE.
      ENDIF.
    ENDLOOP.

    DELETE lt_dte_doc_rec WHERE borrar EQ 'X'.

*****Factura mixta
    LOOP AT lt_dte_doc_rec INTO wa_doc_rec WHERE estado NE c_rechazado.
      lv_index = sy-tabix.
      IF wa_doc_rec-mntexe > 0 AND wa_doc_rec-mntneto > 0.
        wa_doc_rec-estado  = 'FM'.
        wa_doc_rec-message = 'Factura Mixta'.
        UPDATE zdte_doc_rec FROM wa_doc_rec.
        MODIFY lt_dte_doc_rec FROM wa_doc_rec INDEX lv_index.
      ENDIF.
    ENDLOOP.

    DATA  wa_listablanca TYPE zbmnc_listabcab.
    " Proceso Lista Blancas
    LOOP AT lt_dte_doc_rec INTO wa_doc_rec WHERE estado NE c_rechazado.
      CLEAR wa_listablanca.
      lv_index = sy-tabix.

      SELECT SINGLE *  INTO wa_listablanca
      FROM zbmnc_listabcab
      WHERE numero_cliente EQ wa_doc_rec-numero_cliente
        AND rut_proveedor  EQ wa_doc_rec-rutemisor.
      IF sy-subrc EQ 0.
        wa_doc_rec-estado  = 'LB'.
        wa_doc_rec-message = 'Pendiente Proceso Lista Blanca.'.

        MODIFY zdte_doc_rec FROM wa_doc_rec.
        COMMIT WORK AND WAIT.

        wa_doc_rec-borrar = 'X'.
        MODIFY lt_dte_doc_rec FROM wa_doc_rec INDEX lv_index.

      ENDIF.
    ENDLOOP.

    DELETE lt_dte_doc_rec WHERE borrar EQ 'X'.

    " Proceso Tabla Doctores
    LOOP AT lt_dte_doc_rec INTO wa_doc_rec WHERE estado NE c_rechazado.
      lv_index = sy-tabix.

      CLEAR w_t001z.
*ResQ Comment:Correction not required as Select Single is used 24/12/2019 EY_DES04 ECDK917080 *
      SELECT SINGLE * INTO w_t001z
        FROM t001z
       WHERE paval EQ wa_doc_rec-rutrecep.


      SELECT SINGLE *
        FROM zdte_tabla_doc
       WHERe bukrs     EQ w_t001z-bukrs
         AND rutemisor EQ wa_doc_rec-rutemisor.

      IF sy-subrc EQ 0.
        wa_doc_rec-estado  = 'TD'.
        wa_doc_rec-message = 'Proceso Tabla Doctores'.

        MODIFY zdte_doc_rec FROM wa_doc_rec.
        COMMIT WORK AND WAIT.

        wa_doc_rec-borrar = 'X'.
        MODIFY lt_dte_doc_rec FROM wa_doc_rec INDEX lv_index.

      ENDIF.
    ENDLOOP.

    DELETE lt_dte_doc_rec WHERE borrar EQ 'X'.

**********************************************************************
*
**********************************************************************
    DATA lv_tabix TYPE sy-tabix.
    "Verificamos Validaciones
    LOOP AT lt_dte_doc_rec INTO wa_doc_rec.
      lv_tabix = sy-tabix.
      CLEAR:lv_retorno.
      REFRESH:ti_return.
*ResQ Comment:Correction not required as Select Single is used 24/12/2019 EY_DES04 ECDK917080 *
      SELECT SINGLE bukrs INTO lv_bukrs
        FROM t001z
       WHERE paval EQ wa_doc_rec-rutrecep
         AND party EQ 'TAXNR'.
      IF sy-subrc EQ 0.
*Busca Validaciones por sociedad
        SELECT * INTO CORRESPONDING FIELDS OF TABLE ti_val_dte
          FROM zmm_val_dte
         WHERE bukrs = lv_bukrs.

        IF sy-subrc EQ 0.

          LOOP AT ti_val_dte.
            CASE ti_val_dte-validacion.
              WHEN 'VAL_RZNO_SOCIAL'.
                lv_rzno_social  = ti_val_dte-ind_activo.
              WHEN 'VAL_GIRO'.
                lv_giro         = ti_val_dte-ind_activo.
              WHEN  'VAL_DIR'.
                lv_dir          = ti_val_dte-ind_activo.
              WHEN  'VAL_OC'.
                lv_oc           = ti_val_dte-ind_activo.
              WHEN  'VAL_PROVEEDOR'.
                lv_proveedor    = ti_val_dte-ind_activo.
              WHEN  'VAL_HES'.
                lv_hes          = ti_val_dte-ind_activo.
            ENDCASE.
          ENDLOOP.

*Valida dartos DTE recepcion electronica
          CALL FUNCTION 'ZDTE_VALIDA_DATOS'
            EXPORTING
              val_rzno_social = lv_rzno_social
              val_giro        = lv_giro
              val_dir         = lv_dir
              val_oc          = lv_oc
              val_proveedor   = lv_proveedor
              val_hes         = lv_hes
              gt_data         = wa_doc_rec
            IMPORTING
              retorno         = lv_retorno
            TABLES
              return          = ti_return
              gt_eksel        = gt_eksel
              gt_ref          = gt_doc_rec_ref.

          READ TABLE  ti_return INDEX 1.

          "RECHAZAR 8VO DIA
          IF wa_doc_rec-fchemis <= fecha_max .
             lv_retorno        = 'RE'.
             ti_return-message = 'Rechazo Automático - Fuera de Plazo'.
          ENDIF.

          IF lv_retorno = 'RE'.

            wa_doc_rec-estado  = c_rechazado.
            wa_doc_rec-message = ti_return-message.

            MODIFY lt_dte_doc_rec FROM wa_doc_rec INDEX lv_tabix.

            "Enviamos Notificación RECHAZO
            CLEAR wa_datos.

            wa_datos-tpo_doc        = wa_doc_rec-tipodte.
            wa_datos-folio          = wa_doc_rec-folio.
            wa_datos-fecha_emision  = wa_doc_rec-fchemis.
            wa_datos-rut_emi        = wa_doc_rec-rutemisor.
            wa_datos-rut_recep      = wa_doc_rec-rutrecep.
            wa_datos-monto_total    = wa_doc_rec-mnttotal.
            wa_datos-tpo_notif      = 'RECHAZO'.
*              wa_datos-rut_firmante   = wa_doc_rec-RUTEMISOR. "????
*              wa_datos-contacto       = wa_doc_rec-.
*              wa_datos-fono_contacto  = wa_doc_rec-.
*              wa_datos-mail_contacto  = wa_doc_rec-.
*              wa_datos-mail_receptor  = wa_doc_rec-.
            wa_datos-glosa          = wa_doc_rec-message.

*              Se indica el tipo de rechazo/aceptación:
*              NAR: Rechazo/Aceptación comercial
*              ARM: Rechazo/Aceptación Mercadería
*              ACD: Acepta Contenido del Documento
*              RCD: Reclamo al Contenido del Documento
*              ERM: Otorga Recibo de Mercaderías o Servicio
*              RFP: Reclamo por Falta Parcial de Mercaderías
*              RFT: Reclamo por Falta Total de Mercaderías

            wa_datos-tipo           = 'NAR'. "???

            CALL FUNCTION 'ZDTE_ENVIO_NOTIFICACION'
              EXPORTING
                p_datos = wa_datos
                p_user  = p_user
                p_pwd   = p_pwd
                p_ip    = p_ip
              IMPORTING
                retorno = o_retorno.

            IF o_retorno EQ 0.
            ELSE.
              CONCATENATE wa_doc_rec-message '- Error envío FTP.' INTO wa_doc_rec-message SEPARATED BY space.
            ENDIF.

            "Actualizamos Tabla DB
            MODIFY zdte_doc_rec FROM wa_doc_rec.
            COMMIT WORK AND WAIT.

          ENDIF.
        ENDIF.
      ELSE.

      ENDIF.

    ENDLOOP.

    " Procesamos DTE Habilitados
    LOOP AT lt_dte_doc_rec INTO wa_doc_rec WHERE estado EQ c_nuevo."NE c_rechazado.
      CLEAR: w_t001z , vl_resultado  , vl_factura , vl_ejercicio , vl_mensaje .
*ResQ Comment:Correction not required as Select Single is used 24/12/2019 EY_DES04 ECDK917080 *
      SELECT SINGLE * INTO w_t001z
        FROM t001z
       WHERE paval EQ wa_doc_rec-rutrecep.


      IF w_cierre_cont-budat_ini <= sy-datum AND w_cierre_cont-budat_fin >= sy-datum.
        WRITE: / 'Cierre Contable Sociedad:' , w_t001z-bukrs ,  sy-datum(4) , sy-datum+4(2) , sy-datum.
        CONTINUE.
      ENDIF.

      CALL FUNCTION 'ZDTE_CONTABILIZA'
        EXPORTING
          rut_emisor = wa_doc_rec-rutemisor
          tipo_dte   = wa_doc_rec-tipodte
          folio      = wa_doc_rec-folio
          fchemis    = wa_doc_rec-fchemis
        IMPORTING
          resultado  = vl_resultado
          factura    = vl_factura
          ejercicio  = vl_ejercicio
          estado     = vl_estado
          mensaje    = vl_mensaje.

      IF vl_resultado EQ 0.
        wa_doc_rec-estado   = vl_estado.
        wa_doc_rec-belnr    = vl_factura.
        wa_doc_rec-tcode    = 'MIRO'.
        wa_doc_rec-gjahr    = vl_ejercicio.
        wa_doc_rec-message  = vl_mensaje.
        "Actualizamos Tabla DB
        MODIFY zdte_doc_rec FROM wa_doc_rec.
        IF sy-subrc EQ 0.
          COMMIT WORK AND WAIT.
        ENDIF.

        "Enviamos Notificación ACEPTACIÓN

        CLEAR wa_datos.

        wa_datos-tpo_doc        = wa_doc_rec-tipodte.
        wa_datos-folio          = wa_doc_rec-folio.
        wa_datos-fecha_emision  = wa_doc_rec-fchemis.
        wa_datos-rut_emi        = wa_doc_rec-rutemisor.
        wa_datos-rut_recep      = wa_doc_rec-rutrecep.
        wa_datos-monto_total    = wa_doc_rec-mnttotal.
        wa_datos-tpo_notif      = 'ACEPTO'.
*              wa_datos-rut_firmante   = wa_doc_rec-RUTEMISOR. "????
*              wa_datos-contacto       = wa_doc_rec-.
*              wa_datos-fono_contacto  = wa_doc_rec-.
*              wa_datos-mail_contacto  = wa_doc_rec-.
*              wa_datos-mail_receptor  = wa_doc_rec-.
        wa_datos-glosa          = wa_doc_rec-message.

*              Se indica el tipo de rechazo/aceptación:
*              NAR: Rechazo/Aceptación comercial
*              ARM: Rechazo/Aceptación Mercadería
*              ACD: Acepta Contenido del Documento
*              RCD: Reclamo al Contenido del Documento
*              ERM: Otorga Recibo de Mercaderías o Servicio
*              RFP: Reclamo por Falta Parcial de Mercaderías
*              RFT: Reclamo por Falta Total de Mercaderías

        wa_datos-tipo           = 'ACD'. "???

        CALL FUNCTION 'ZDTE_ENVIO_NOTIFICACION'
          EXPORTING
            p_datos = wa_datos
            p_user  = p_user
            p_pwd   = p_pwd
            p_ip    = p_ip
          IMPORTING
            retorno = o_retorno.

        IF o_retorno EQ 0.
        ELSE.
          CONCATENATE wa_doc_rec-message '- Error envío FTP.' INTO wa_doc_rec-message SEPARATED BY space.
        ENDIF.

        "Actualizamos Tabla DB
        MODIFY zdte_doc_rec FROM wa_doc_rec.
        IF sy-subrc EQ 0.
          COMMIT WORK AND WAIT.
        ENDIF.

      ELSE.
        wa_doc_rec-estado   = vl_estado.
        wa_doc_rec-message  = vl_mensaje.

        MODIFY zdte_doc_rec FROM wa_doc_rec.
        IF sy-subrc EQ 0.
          COMMIT WORK AND WAIT.
        ENDIF.

      ENDIF.

      IF vl_factura NE space .
        PERFORM update_doc_fi USING vl_factura vl_ejercicio w_t001z-bukrs wa_doc_rec-rutemisor wa_doc_rec-fchemis  vl_resultado .
      ENDIF.

    ENDLOOP.
  ELSE.
    WRITE: / 'No hay Registros Nuevos para Procesar. Fecha:' , sy-datum, 'Hora:' , sy-uzeit.
  ENDIF.

ENDFORM.                    " rutina

*&---------------------------------------------------------------------*
*&      Form  update_doc_fi
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM update_doc_fi USING    p_factura
                            p_ejercicio
                            p_bukrs
                            p_rut
                            p_fechaemi
                            p_resultado.

  DATA vl_awkey TYPE bkpf-awkey.
  DATA vl_belnr TYPE bkpf-belnr.
  DATA w_bkpf   TYPE bkpf.
  CONCATENATE p_factura p_ejercicio INTO vl_awkey.

  CONDENSE vl_awkey NO-GAPS.

  SELECT SINGLE * INTO w_bkpf
   FROM bkpf
   WHERE bukrs EQ p_bukrs
     AND gjahr EQ p_ejercicio
     AND awkey EQ vl_awkey.

  IF sy-subrc NE 0.
    EXIT.
  ENDIF.
***AGEGAR RUT DE TERCERO
  DATA lv_fecha TYPE c LENGTH 10.

  CONCATENATE   p_fechaemi+6(2) '.' p_fechaemi+4(2) '.' p_fechaemi(4) INTO lv_fecha.

**AGEGAR RUT DE TERCERO
  PERFORM bdc_dynpro      USING 'SAPMF05L'          '0102'.
  PERFORM bdc_field       USING 'BDC_CURSOR'        'RF05L-GJAHR'.
  PERFORM bdc_field       USING 'BDC_OKCODE'        '/00'.
  PERFORM bdc_field       USING 'RF05L-BELNR'       w_bkpf-belnr.
  PERFORM bdc_field       USING 'RF05L-BUKRS'       w_bkpf-bukrs.
  PERFORM bdc_field       USING 'RF05L-GJAHR'       w_bkpf-gjahr.
  PERFORM bdc_field       USING 'RF05L-BUZEI'       '1'.

  PERFORM bdc_dynpro      USING 'SAPMF05L'          '0302'.
  PERFORM bdc_field       USING 'BDC_CURSOR'        'BSEG-ZBD1T'.
  PERFORM bdc_field       USING 'BDC_OKCODE'        '/00'.
  PERFORM bdc_field       USING 'BSEG-ZTERM'        'ZC01'.
  PERFORM bdc_field       USING 'BSEG-ZBD1T'        '30'.
  PERFORM bdc_field       USING 'BSEG-ZFBDT'        lv_fecha.

  PERFORM bdc_dynpro      USING 'SAPMF05L'          '0302'.
  PERFORM bdc_field       USING 'BDC_CURSOR'        'BSEG-ZBD1T'.
  PERFORM bdc_field       USING 'BDC_OKCODE'        '/00'.
  PERFORM bdc_field       USING 'BSEG-ZTERM'        'ZC01'.
  PERFORM bdc_field       USING 'BSEG-ZBD1T'        '30'.
  PERFORM bdc_field       USING 'BSEG-ZFBDT'        lv_fecha.

  PERFORM bdc_dynpro      USING 'SAPMF05L'          '0302'.
  PERFORM bdc_field       USING 'BDC_CURSOR'        'BSEG-ZTERM'.
  PERFORM bdc_field       USING 'BDC_OKCODE'        '=AE'.
  PERFORM bdc_field       USING 'BSEG-ZTERM'        'ZC01'.
  PERFORM bdc_field       USING 'BSEG-ZBD1T'        '30'.
  PERFORM bdc_field       USING 'BSEG-ZFBDT'        lv_fecha.

  PERFORM bdc_transaction2 USING 'FB09' p_resultado.


  DATA w_lfa1 TYPE lfa1.
  DATA w_bseg_ref TYPE bseg.
  DATA w_bseg_doc TYPE bseg.

  SELECT SINGLE * INTO w_lfa1
    FROM lfa1
    WHERE stcd1 EQ  p_rut.

  IF sy-subrc EQ 0.
    UPDATE bseg SET zzrut_terc = w_lfa1-lifnr
     WHERE bukrs EQ w_bkpf-bukrs
       AND belnr EQ w_bkpf-belnr
       AND gjahr EQ w_bkpf-gjahr
       AND ( bschl EQ '91' OR bschl EQ '86' ).


*****Buscar doc.contable entrada de mcia.
*ResQ Comment:Correction not required as Select Single is used 24/12/2019 EY_DES04 ECDK917080 *
    SELECT SINGLE * INTO w_bseg_ref
      FROM bseg
     WHERE bukrs EQ w_bkpf-bukrs
       AND belnr EQ w_bkpf-belnr
       AND gjahr EQ w_bkpf-gjahr
       AND bschl EQ '86'.

    IF sy-subrc EQ 0.
*ResQ Comment:Correction not required as Select Single is used 24/12/2019 EY_DES04 ECDK917080 *
      SELECT SINGLE * INTO w_bseg_doc
        FROM bseg
       WHERE bukrs EQ w_bkpf-bukrs
*         AND belnr EQ w_bkpf-belnr
         AND gjahr EQ w_bkpf-gjahr
         AND xref3 EQ w_bseg_ref-xref3
         AND bschl EQ '96'.

      IF sy-subrc EQ 0.
        UPDATE bseg SET zzrut_terc = w_lfa1-lifnr
         WHERE bukrs EQ w_bseg_doc-bukrs
           AND belnr EQ w_bseg_doc-belnr
           AND gjahr EQ w_bseg_doc-gjahr
           AND ( bschl EQ '96' OR bschl EQ '86'  OR bschl EQ '81' ).
      ENDIF.


    ENDIF.


  ENDIF.
ENDFORM.                    "update_doc_fi
*&---------------------------------------------------------------------*
*&      Form  bdc_transaction2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->TCODE      text
*      -->RETORNO    text
*----------------------------------------------------------------------*
FORM bdc_transaction2  USING tcode retorno.
  DATA: l_mstring(480).
  DATA: l_subrc LIKE sy-subrc.
  DATA: ctumode LIKE ctu_params-dismode VALUE 'N'.
  DATA: cupdate LIKE ctu_params-updmode VALUE 'A'.

  REFRESH messtab.
  CALL TRANSACTION tcode USING bdcdata
                   MODE   ctumode
                   UPDATE cupdate
                   MESSAGES INTO messtab.
  retorno = sy-subrc.

*  IF sy-subrc NE 0.
  LOOP AT messtab." WHERE msgtyp = 'E'.
*    CALL FUNCTION 'MESSAGE_TEXT_BUILD'
*      EXPORTING
*        msgid               = messtab-msgid
*        msgnr               = messtab-msgnr
*        msgv1               = messtab-msgv1
*        msgv2               = messtab-msgv2
*        msgv3               = messtab-msgv3
*        msgv4               = messtab-msgv4
*      IMPORTING
*        message_text_output = t_salida-message.
*
*    APPEND t_salida.
*
*    MOVE-CORRESPONDING messtab TO mensaje_salida.
*    APPEND mensaje_salida.
  ENDLOOP.

*  ENDIF.
  COMMIT WORK AND WAIT.

  REFRESH bdcdata.

ENDFORM.                    "bdc_transaction
*&---------------------------------------------------------------------*
*&      Form  bdc_dynpro
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->PROGRAM    text
*      -->DYNPRO     text
*----------------------------------------------------------------------*
FORM bdc_dynpro USING program dynpro.
  CLEAR bdcdata.
  bdcdata-program  = program.
  bdcdata-dynpro   = dynpro.
  bdcdata-dynbegin = 'X'.
  APPEND bdcdata.
ENDFORM.                    "BDC_DYNPRO

*----------------------------------------------------------------------*
*        Insert field                                                  *
*----------------------------------------------------------------------*
FORM bdc_field USING fnam fval.
  CLEAR bdcdata.
  bdcdata-fnam = fnam.
  bdcdata-fval = fval.
  APPEND bdcdata.
ENDFORM.                    "BDC_FIELD

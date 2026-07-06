FUNCTION zdte_envio_notificacion.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     REFERENCE(P_DATOS) LIKE  ZEMM157 STRUCTURE  ZEMM157
*"     VALUE(P_USER) TYPE  CHAR30 OPTIONAL
*"     VALUE(P_PWD) TYPE  CHAR30 OPTIONAL
*"     VALUE(P_IP) TYPE  CHAR64 OPTIONAL
*"  EXPORTING
*"     VALUE(RETORNO) TYPE  SUBRC
*"----------------------------------------------------------------------

  DATA: lv_tpo_doc(3)       TYPE c,
        lv_fecha_emi(10)    TYPE c,
        lv_rut_emi(12)      TYPE c,
        lv_rut_recep(12)    TYPE c,
        lv_rut_firm(12)     TYPE c,
        lv_tpo_notif(7)     TYPE c,
        lv_glosa(40)        TYPE c,
        lv_contacto(40)     TYPE c,
        lv_fono(40)         TYPE c,
        lv_mail(40)         TYPE c,
        lv_mail_rece(40)    TYPE c,
        lv_folio(10)        TYPE c,
        lv_monto_total(18)  TYPE c.

  REFRESH gt_data.
  CLEAR:  wa_data       ,
          lv_tpo_doc    ,
          lv_fecha_emi  ,
          lv_rut_emi    ,
          lv_rut_recep  ,
          lv_rut_firm   ,
          lv_tpo_notif  ,
          lv_glosa      ,
          lv_contacto   ,
          lv_fono       ,
          lv_mail       ,
          lv_mail_rece  ,
          lv_folio      ,
          lv_monto_total.

  MOVE: p_datos-tpo_doc       TO  lv_tpo_doc,
        p_datos-rut_emi       TO  lv_rut_emi,
        p_datos-rut_recep     TO  lv_rut_recep,
        p_datos-rut_firmante  TO  lv_rut_firm,
        p_datos-tpo_notif     TO  lv_tpo_notif,
        p_datos-contacto      TO  lv_contacto,
        p_datos-fono_contacto TO  lv_fono,
        p_datos-mail_contacto TO  lv_mail,
        p_datos-mail_receptor TO  lv_mail_rece,
        p_datos-folio         TO  lv_folio,
        p_datos-monto_total   TO  lv_monto_total.

***traer datos del mantenedor
  lv_rut_firm = '17027039-8'.
  lv_contacto = 'Proveedores VidaIntegra'.
  lv_fono     = '224107488'.
  lv_mail     = 'proveedores@vidaintegra.cl'.

***mail receptor
  DATA w_lfa1 TYPE lfa1.
  SELECT SINGLE * INTO w_lfa1
    FROM lfa1
   WHERE stcd1 EQ lv_rut_emi.

  IF sy-subrc EQ 0.
    SELECT SINGLE smtp_addr INTO lv_mail_rece
      FROM adr6
     WHERE addrnumber EQ w_lfa1-adrnr.
  ENDIF.

  CONCATENATE p_datos-fecha_emision+0(4) '-' p_datos-fecha_emision+4(2) '-' p_datos-fecha_emision+6(2)
         INTO lv_fecha_emi.

  REPLACE ALL OCCURRENCES OF '.' IN lv_rut_emi   WITH ''.
  REPLACE ALL OCCURRENCES OF '.' IN lv_rut_recep WITH ''.
  REPLACE ALL OCCURRENCES OF '.' IN lv_rut_firm  WITH ''.

*  REPLACE ALL OCCURRENCES OF '-' IN lv_rut_emi   WITH ''.
*  REPLACE ALL OCCURRENCES OF '-' IN lv_rut_recep WITH ''.
*  REPLACE ALL OCCURRENCES OF '-' IN lv_rut_firm  WITH ''.

  CONDENSE lv_rut_emi   NO-GAPS.
  CONDENSE lv_rut_recep NO-GAPS.
  CONDENSE lv_rut_firm  NO-GAPS.

  TRANSLATE lv_tpo_notif TO UPPER CASE.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
    EXPORTING
      input  = lv_folio
    IMPORTING
      output = lv_folio.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
    EXPORTING
      input  = lv_monto_total
    IMPORTING
      output = lv_monto_total.

*  Armar linea primera parte
  CONCATENATE lv_tpo_doc      '|'
              lv_folio        '|'
              lv_fecha_emi    '|'
              lv_rut_emi      '|'
              lv_rut_recep    '|'
              lv_monto_total  '|'
              lv_tpo_notif    '|'
              lv_rut_firm     '|'
         INTO wa_data-linea.

* Se eliminan espacios vacios de la primera parte de la linea
  CONDENSE wa_data-linea NO-GAPS.

  CASE p_datos-tipo.
    WHEN 'NAR'.
      IF lv_tpo_notif EQ 'ACEPTO'.
        lv_glosa = 'Aceptación comercial'.
      ELSEIF lv_tpo_notif EQ 'RECHAZO'.
        lv_glosa = 'Rechazo comercial'.
      ENDIF.
    WHEN 'ARM'.
      IF lv_tpo_notif EQ 'ACEPTO'.
        lv_glosa = 'Aceptación Mercadería'.
      ELSEIF lv_tpo_notif EQ 'RECHAZO'.
        lv_glosa = 'Rechazo Mercadería'.
      ENDIF.
    WHEN 'ACD'.
      lv_glosa = 'Acepta Contenido del Documento'.
    WHEN 'RCD'.
      lv_glosa = 'Reclamo al Contenido del Documento'.
    WHEN 'ERM'.
      lv_glosa = 'Otorga Recibo de Mercaderías o Servicio'.
    WHEN 'RFP'.
      lv_glosa = 'Reclamo por Falta Parcial de Mercaderías'.
    WHEN 'RFT'.
      lv_glosa = 'Reclamo por Falta Total de Mercaderías'.
  ENDCASE.

  REPLACE ALL OCCURRENCES OF '|' IN lv_contacto   WITH  ''.
  REPLACE ALL OCCURRENCES OF '|' IN lv_fono       WITH  ''.
  REPLACE ALL OCCURRENCES OF '|' IN lv_mail       WITH  ''.
  REPLACE ALL OCCURRENCES OF '|' IN lv_mail_rece  WITH  ''.

* Se arma la segunda parte de la linea
  CONCATENATE wa_data-linea
              lv_contacto     '|'
              lv_fono         '|'
              lv_mail         '|'
              lv_mail_rece    '|'
              lv_glosa        '|'
              p_datos-tipo    '}!'
         INTO wa_data-linea.

* Se guarda la linea en la tabla para ser generado el txt
  APPEND wa_data TO gt_data.

  PERFORM envio_ftp USING p_user p_pwd p_ip retorno
                          p_datos-tpo_doc p_datos-folio.

ENDFUNCTION.

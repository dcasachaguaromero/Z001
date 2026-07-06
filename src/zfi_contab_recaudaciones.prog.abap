*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES04 > *
*& Description: < ReSQ Correction > *
*& Date: <24-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Report  ZFI_Contabilizacion Recaudaciones
*&
*&---------------------------------------------------------------------*
*& Autor:    Elias Sobarzo M.- Vision One
*& Fecha:    12.12.2011
*& Objetivo: Contabilizacion de Recaudaciones
*&
*&--------------------MODIFICACIONES-----------------------------------*
*& Autor:    Programador VisionOne.
*& Fecha:    11.09.2014
*& Objetivo: Actualiza el campo asignacion con un 0, en la partida de
*&           del cliente en el anticipo.
*&---------------------------------------------------------------------*
*& Autor:    Programador VisionOne CNN R27765
*& Fecha:    18.06.2015
*& Objetivo: Para DPP se contabiliza con clave '09' y CME = 'D' en
*&           convenios. Lo mismo para cobranzas la selección a la BSID
*&           es con '09' y 'D'
*&---------------------------------------------------------------------*
*& Autor:    V1-CNN ECDK912798
*& Fecha:    23.12.2015
*& Objetivo: Para DPP se contabiliza con clave CME 'D' en contracuenta
*&---------------------------------------------------------------------*
REPORT  zfi_contab_recaudaciones.

CONSTANTS: c_x         TYPE c VALUE 'X',
           c_fp_dpp(3) VALUE  '003'. "DPP

TYPES: BEGIN OF ty_anex,
         bukrs       TYPE bukrs,
         belnr       TYPE belnr_d,
         gjahr       TYPE gjahr,
         buzei       TYPE buzei,
         zzconve_dpp TYPE zzconvenio,
         zzrut_dpp   TYPE stcd1,
         gjahr_dpp   TYPE gjahr,
         augbl_dpp   TYPE augbl,
         augdt_dpp   TYPE augdt.
TYPES END OF ty_anex.

TYPES: BEGIN OF ty_bsid,
         bukrs        TYPE bsid-bukrs,
         kunnr        TYPE bsid-kunnr,
         umsks        TYPE bsid-umsks,
         umskz        TYPE bsid-umskz,
         augdt        TYPE bsid-augdt,
         augbl        TYPE bsid-augbl,
         zuonr        TYPE bsid-zuonr,
         gjahr        TYPE bsid-gjahr,
         belnr        TYPE bsid-belnr,
         buzei        TYPE bsid-buzei,
         budat        TYPE bsid-budat,
         bschl        TYPE bsid-bschl,
         bldat        TYPE bsid-bldat,
         wrbtr        TYPE bsid-wrbtr,
         vertn        TYPE bsid-vertn,
         vertt        TYPE bsid-vertt,
         rebzg        TYPE bsid-rebzg,
         zcod_rechazo TYPE bsid-zcod_rechazo.
TYPES END OF ty_bsid.

DATA ti_anex TYPE STANDARD TABLE OF ty_anex.
DATA wa_anex LIKE LINE OF ti_anex.

DATA t_data TYPE STANDARD TABLE OF zfire001_est.
DATA wa_data LIKE LINE OF t_data.
DATA wa_fpagrec TYPE zfifpagrec.
DATA wa_zfimtvrechz TYPE zfimtvrechz.
DATA t_bsid TYPE STANDARD TABLE OF ty_bsid.
DATA wa_bsid LIKE LINE OF t_bsid.


DATA bdcdata TYPE STANDARD TABLE OF bdcdata.
DATA ls_bdc  LIKE LINE OF bdcdata.
DATA cupdate TYPE ctu_update VALUE 'L'.
DATA messtab TYPE STANDARD TABLE OF bdcmsgcoll.
DATA ls_mess LIKE LINE OF messtab.
DATA t_log TYPE STANDARD TABLE OF bdcmsgcoll.
DATA:lt_files   TYPE filetable,
     l_file     TYPE file_table,
     l_title    TYPE string,
     l_subrc    TYPE i,
     l_usr_act  TYPE i,
     l_def_file TYPE string,
     l_filter   TYPE string,
     lf_dsnam   TYPE file_table-filename.
DATA g_regindex(10) TYPE c.
DATA : l_kunnr    TYPE kunnr,
       l_cliente  TYPE kna1-kunnr,
       l_contrato TYPE bsid-vertn.
DATA l_kunnr_dpp TYPE  kunnr.

DATA : l_monto    TYPE bsid-wrbtr,
       lv_monto_y TYPE wrbtr.      "V1-CNN ECDK922573 Facturación el línea HELP

DATA lv_evento TYPE char18.


**Totales
DATA: BEGIN OF gs_total,
        leidos         TYPE i , "Total de Registros leídos
        contab         TYPE i, "Total de Registros contabilizados
        rechaz         TYPE i, "Total de Registros con rechazos
        error          TYPE i, "Total de Registros con error
        monto          TYPE wrbtr, "Total de Monto recaudado
        monto_recha    TYPE wrbtr, "Total de Monto rechazo
        monto_sn_recha TYPE wrbtr, "Total de Monto sin/rechazo
      END OF gs_total.
**-
SELECTION-SCREEN: BEGIN OF BLOCK uno WITH FRAME TITLE TEXT-001.
PARAMETERS:r1 RADIOBUTTON GROUP g2 DEFAULT 'X' USER-COMMAND aaaa,
           r2 RADIOBUTTON GROUP g2.
PARAMETERS: p_file(128) TYPE c DEFAULT 'D:\' LOWER CASE,
            p_sfile     TYPE rlgrap-filename
                        DEFAULT  '/usr/sap/',
            p_moneda    TYPE waers    DEFAULT 'CLP' NO-DISPLAY,
            p_mode      TYPE ctu_mode   DEFAULT 'N'.

SELECTION-SCREEN: END OF BLOCK uno.

AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
*---- Opción 1
    IF r1 = 'X'.
      IF screen-name CS 'P_FILE'.
        screen-invisible = '0'.
        screen-input = '1'.
      ELSEIF screen-name CS 'P_SFILE'  .
        screen-invisible = '1'.
        screen-input = '0'.
      ENDIF.

*---- Opción 2
    ELSEIF r2 = 'X'.
      IF screen-name CS 'P_SFILE'.
        screen-invisible = '0'.
        screen-input = '1'.
      ELSEIF screen-name CS 'P_FILE'.
        screen-invisible = '1'.
        screen-input = '0'.
      ELSEIF screen-name CS 'P_MODE'.
        screen-invisible = '1'.
        screen-input = '0'.
      ENDIF.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.

  l_title = 'Selección de Archivo'(006).
  l_filter = 'Todos|*.*'(010).
  l_def_file = p_file.

  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    EXPORTING
      window_title            = l_title
      default_filename        = l_def_file
      file_filter             = l_filter
    CHANGING
      file_table              = lt_files
      rc                      = l_subrc
      user_action             = l_usr_act
    EXCEPTIONS
      file_open_dialog_failed = 1
      cntl_error              = 2
      error_no_gui            = 3
      not_supported_by_gui    = 4
      OTHERS                  = 5.
  IF sy-subrc = 0 AND
    l_usr_act <> cl_gui_frontend_services=>action_cancel.
*Begin of change: ReSQ Correction INDEX READ on an unsorted Internal TABLE 24/12/2019 EY_DES04 ECDK917080 *
*SORT LT_FILES . "JOROZCO 20.01.2020
*End of change: ReSQ Correction for INDEX READ on an unsorted Internal TABLE 24/12/2019 EY_DES04 ECDK917080 *
    READ TABLE lt_files INTO l_file INDEX 1.
    IF sy-subrc = 0.
      MOVE l_file-filename TO l_def_file.
      MOVE l_def_file TO lf_dsnam.
      MOVE lf_dsnam TO p_file.
    ENDIF.
  ENDIF.

*--------------------------------------------------------------------*
*                 START-OF-SELECTION
*--------------------------------------------------------------------*
START-OF-SELECTION.

  PERFORM subir_archivo.
  CHECK sy-subrc = 0.
  gs_total-leidos = lines( t_data ).


  CLEAR gs_total-monto.
  CLEAR gs_total-monto_recha.
  CLEAR gs_total-monto_sn_recha.

  LOOP AT t_data INTO wa_data.
    g_regindex = sy-tabix.
    PERFORM procesar_datos.
  ENDLOOP.

  PERFORM totales.
  IF t_log IS NOT INITIAL.
    PERFORM display_log.
  ENDIF.

*&---------------------------------------------------------------------*
*&      Form  CALL_TRANSACTION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM call_transaction USING p_transac.
  DATA ls_messtab TYPE bdcmsgcoll.
  DATA l_message TYPE string.
  DATA ti_fac_anex TYPE STANDARD TABLE OF zfac_anex.
  DATA wa_fac_anex LIKE LINE OF ti_fac_anex.
  DATA: ti_bsid TYPE TABLE OF ty_bsid.
  DATA: sociedad  TYPE bseg-bukrs,
        documento TYPE bseg-belnr,
        ejercicio TYPE bseg-gjahr.

  FIELD-SYMBOLS : <fs>       TYPE ty_bsid,
                  <fac_anex> LIKE LINE OF  ti_fac_anex.
  REFRESH messtab.
  CALL TRANSACTION p_transac USING bdcdata
                   MODE   p_mode "ctumode
                   UPDATE cupdate
                   MESSAGES INTO messtab.                "#EC CI_CALLTA
**- verifica documento creado
  READ TABLE messtab INTO ls_messtab WITH KEY msgtyp = 'S'
                                              msgid = 'F5'
                                              msgnr = '312'.
  IF sy-subrc = 0.
    MESSAGE  ID  'F5' TYPE 'S' NUMBER '312'
       WITH ls_messtab-msgv1 ls_messtab-msgv2 INTO l_message.

    CLEAR : sociedad, documento, ejercicio.
    sociedad = ls_messtab-msgv2.
    documento = ls_messtab-msgv1.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = documento
      IMPORTING
        output = documento.

    ejercicio = wa_data-fecha_contable+4(4).
    IF wa_data-forma_pago = c_fp_dpp. "DPP - Convenios
      REFRESH ti_bsid.
      SELECT
             bukrs
             kunnr
             umsks
             umskz
             augdt
             augbl
             zuonr
             gjahr
             belnr
             buzei
             budat
             bschl
             bldat
             wrbtr
             vertn
             vertt
             rebzg
             zcod_rechazo
        INTO CORRESPONDING FIELDS OF TABLE ti_bsid
        FROM bsid
        WHERE bukrs = ls_messtab-msgv2
          AND belnr = ls_messtab-msgv1
          AND gjahr = wa_data-fecha_contable+4(4)
          AND kunnr = l_kunnr_dpp.

      IF sy-subrc = 0.
        REFRESH ti_fac_anex.
        LOOP AT ti_bsid ASSIGNING <fs>.
          CLEAR wa_fac_anex.
          wa_fac_anex-bukrs = <fs>-bukrs.
          wa_fac_anex-belnr   = <fs>-belnr.
          wa_fac_anex-gjahr   = <fs>-gjahr.
          wa_fac_anex-buzei   = <fs>-buzei.
          wa_fac_anex-zzconve_dpp = wa_data-convenio.
          wa_fac_anex-zzrut_dpp   = wa_data-rut_empresa_dpp.
          APPEND wa_fac_anex TO ti_fac_anex.
        ENDLOOP.
        INSERT zfac_anex  FROM TABLE ti_fac_anex.
        IF sy-subrc = 0.
          COMMIT WORK.
        ENDIF.
      ENDIF.
    ELSE.
**--  Actualiza partidas que fueron compensdas
      IF lines( t_bsid ) > 0.
        REFRESH ti_fac_anex.
        SELECT *
          INTO CORRESPONDING FIELDS OF TABLE ti_fac_anex
          FROM zfac_anex
        FOR ALL ENTRIES IN t_bsid
          WHERE bukrs = t_bsid-bukrs
           AND belnr = t_bsid-belnr
           AND gjahr = t_bsid-gjahr
           AND buzei = t_bsid-buzei.
        IF sy-subrc = 0.
          LOOP AT ti_fac_anex ASSIGNING <fac_anex>.
            wa_fac_anex-zzconve_dpp = wa_data-convenio.
            wa_fac_anex-zzrut_dpp   = wa_data-rut_empresa_dpp.
          ENDLOOP.
          UPDATE zfac_anex FROM TABLE ti_fac_anex.
          IF sy-subrc = 0.
            COMMIT WORK.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    CLEAR ls_messtab.
    ls_messtab-msgtyp = 'I'.
    ls_messtab-msgspra = sy-langu.
    ls_messtab-msgid = '00'.
    ls_messtab-msgnr = '001'.
    MOVE g_regindex TO ls_messtab-msgv1.
    CONDENSE ls_messtab-msgv1.
    ls_messtab-msgv2 = l_message.
    APPEND ls_messtab TO t_log.
    gs_total-contab = gs_total-contab + 1.

***Actualizamos el XREF2 y SGTXT del documento generado
    IF NOT wa_data-id_proceso IS INITIAL OR
       NOT wa_data-sgtxt IS INITIAL.
      PERFORM actualizar_doc USING sociedad "Sociedad
                                   documento "Documento
                                   ejercicio. "Ejercicio.
    ENDIF.
  ELSE.
**-- Error BI Contabilización/Despliega todos los mensajes
    CLEAR ls_messtab.
    ls_messtab-msgtyp = 'E'.
    ls_messtab-msgspra = sy-langu.
    ls_messtab-msgid = '00'.
    ls_messtab-msgnr = '001'.
    MOVE g_regindex TO ls_messtab-msgv2.
    CONDENSE ls_messtab-msgv2.
    ls_messtab-msgv1 = TEXT-007. "'Error(es) reg.Nº:'(007).
    APPEND ls_messtab TO t_log.


    DATA: msgty TYPE msgty.
    LOOP AT  messtab INTO ls_messtab.
      CLEAR msgty.
      msgty = ls_messtab-msgtyp.
      MESSAGE  ID  ls_messtab-msgid TYPE ls_messtab-msgtyp
      NUMBER  ls_messtab-msgnr
      WITH ls_messtab-msgv1
           ls_messtab-msgv2
           ls_messtab-msgv3
           ls_messtab-msgv4 INTO l_message.
      CLEAR ls_messtab.
      ls_messtab-msgtyp = msgty.  "'E'.
      ls_messtab-msgspra = sy-langu.
      ls_messtab-msgid = '00'.
      ls_messtab-msgnr = '001'.
      MOVE g_regindex TO ls_messtab-msgv1.
      CONDENSE ls_messtab-msgv1.
      ls_messtab-msgv2 = l_message.
      APPEND ls_messtab TO t_log.
    ENDLOOP.
    gs_total-error = gs_total-error + 1.
  ENDIF.
  FREE messtab.
  FREE bdcdata.
  REFRESH : bdcdata, messtab.
  CLEAR lv_evento.
ENDFORM.                    "  CALL_TRANSACTION
*&---------------------------------------------------------------------*
*&      Form  SUBIR_ARCHIVO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM subir_archivo .
  DATA: l_filename TYPE string.
  DATA: ld_file TYPE rlgrap-filename.
  DATA: wa_string(540) TYPE c.
  DATA wa_data LIKE LINE OF t_data.

  CLASS cl_abap_char_utilities DEFINITION LOAD.
  CONSTANTS:
     con_tab  TYPE c VALUE cl_abap_char_utilities=>horizontal_tab.
  TYPES: BEGIN OF t_uploadtxt,
           forma_pago(3)       TYPE c,
           rut_cliente(10)     TYPE c,
           fecha_documento(8)  TYPE c,
           clase_documento(2)  TYPE c,
           sociedad(4)         TYPE c,
           fecha_contable(8)   TYPE c,
           periodo(2)          TYPE c,
           referencia(16)      TYPE c,
           texto_cabecera(25)  TYPE c,
           importe(13)         TYPE c,
           fecha_valor(8)      TYPE c,
           evento(18)          TYPE c,
           rut(10)             TYPE c,
           clase_cuenta(1)     TYPE c,
           contrato(10)        TYPE c,
           clase_contrato(1)   TYPE c,
           convenio(20)        TYPE c,
           via_pago_sap(1)     TYPE c,
           banco(3)            TYPE c,
           pais_banco(2)       TYPE c,
           cheque(20)          TYPE c,
           fecha_emision(8)    TYPE c,
           fecha_vencto(8)     TYPE c,
           vpago_sap_sucu(1)   TYPE c,
           nro_cta_cte_cli(18) TYPE c,
           centro_costo(10)    TYPE c,
           centro_benef(10)    TYPE c,
           rechazo(5)          TYPE c,
           cuenta_contable(10) TYPE c,
           rut_empresa_dpp(10) TYPE c,
           moneda(5)           TYPE c,
           id_proceso(12)      TYPE c,
           sgtxt(50)           TYPE c,
           vacio(2)            TYPE c,
         END OF t_uploadtxt.

*
  CASE 'X'.
    WHEN r1." Local
      l_filename  = p_file.
      CALL METHOD cl_gui_frontend_services=>gui_upload
        EXPORTING
          filename                = l_filename
          has_field_separator     = 'X' " Delimitado por TAB
        CHANGING
          data_tab                = t_data
        EXCEPTIONS
          file_open_error         = 1
          file_read_error         = 2
          no_batch                = 3
          gui_refuse_filetransfer = 4
          invalid_type            = 5
          no_authority            = 6
          unknown_error           = 7
          bad_data_format         = 8
          header_not_allowed      = 9
          separator_not_allowed   = 10
          header_too_long         = 11
          unknown_dp_error        = 12
          access_denied           = 13
          dp_out_of_memory        = 14
          disk_full               = 15
          dp_timeout              = 16
          not_supported_by_gui    = 17
          error_no_gui            = 18
          OTHERS                  = 19.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                   WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
    WHEN r2.
      ld_file = p_sfile.
      OPEN DATASET ld_file FOR INPUT IN TEXT MODE ENCODING DEFAULT.
      IF sy-subrc <> 0.
        IF sy-batch = abap_true.
          WRITE /  TEXT-003."  'Error al abrir archivo en servidor
        ELSE.
          MESSAGE TEXT-003 "'Error al abrir archivo en servidor(
          TYPE   'I'.
        ENDIF.
      ELSE.
        DO.
          CLEAR: wa_string.
          READ DATASET ld_file INTO wa_string.
          IF sy-subrc <> 0.
            EXIT.
          ELSE.
            SPLIT wa_string AT con_tab INTO
              wa_data-forma_pago
              wa_data-rut_cliente
              wa_data-fecha_documento
              wa_data-clase_documento
              wa_data-sociedad
              wa_data-fecha_contable
              wa_data-periodo
              wa_data-referencia
              wa_data-texto_cabecera
              wa_data-importe
              wa_data-fecha_valor
              wa_data-evento
              wa_data-rut
              wa_data-clase_cuenta
              wa_data-contrato
              wa_data-clase_contrato
              wa_data-convenio
              wa_data-via_pago_sap
              wa_data-banco
              wa_data-pais_banco
              wa_data-cheque
              wa_data-fecha_emision
              wa_data-fecha_vencto
              wa_data-vpago_sap_sucu
              wa_data-nro_cta_cte_cli
              wa_data-centro_costo
              wa_data-centro_benef
              wa_data-rechazo
              wa_data-cuenta_contable
              wa_data-rut_empresa_dpp
              wa_data-id_proceso
              wa_data-sgtxt.
            APPEND  wa_data TO t_data.
          ENDIF.
        ENDDO.
        CLOSE DATASET ld_file.
        IF sy-subrc <> 0.
          IF sy-batch = abap_true.
            WRITE / TEXT-004 ."'Error cerrar archivo en servidor(CLOSE)
          ELSE.
            MESSAGE TEXT-004"Error al cerrar archivo en servidor(CLOSE)
            TYPE 'I'.
          ENDIF.
        ENDIF.
      ENDIF.
    WHEN OTHERS.
      RETURN.
  ENDCASE.

ENDFORM.                    " SUBIR_ARCHIVO

*----------------------------------------------------------------------*
*        Start new screen                                              *
*----------------------------------------------------------------------*
FORM bdc_dynpro USING program dynpro.
  CLEAR ls_bdc.
  ls_bdc-program  = program.
  ls_bdc-dynpro   = dynpro.
  ls_bdc-dynbegin = 'X'.
  APPEND ls_bdc TO bdcdata.
ENDFORM.                    "BDC_DYNPRO

*----------------------------------------------------------------------*
*        Insert field                                                  *
*----------------------------------------------------------------------*
FORM bdc_field USING fnam fval.
  CLEAR ls_bdc.
  ls_bdc-fnam = fnam.
  ls_bdc-fval = fval.
  APPEND ls_bdc TO bdcdata.
ENDFORM.                    "BDC_FIELD
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_LOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM display_log .

  TYPES : BEGIN OF t_balmi,
            msgty     TYPE balmi-msgty,
            msgid     TYPE balmi-msgid,
            msgno     TYPE balmi-msgno,
            msgv1     TYPE char100,
            msgv2     TYPE char100,
            msgv3     TYPE char100,
            msgv4     TYPE char100,
            altext    TYPE balmi-altext,
            userexitp TYPE balmi-userexitp,
            userexitf TYPE balmi-userexitf,
            detlevel  TYPE balmi-detlevel,
            probclass TYPE balmi-probclass,
            alsort    TYPE balmi-alsort,
          END OF t_balmi.

  DATA: lf_obj        TYPE balobj_d,
        lf_subobj     TYPE balsubobj,
        ls_header     TYPE balhdri,
        lf_log_handle TYPE balloghndl,
        lf_log_number TYPE balognr,
        lt_msg        TYPE TABLE OF t_balmi, "balmi_tab,
        ls_msg        TYPE t_balmi,
        lt_lognum     TYPE TABLE OF balnri,
        ls_lognum     TYPE balnri.
*
  lf_obj     = 'ZFI_LOG'.
  lf_subobj  = 'Z01'.

  ls_header-object     = lf_obj.
  ls_header-subobject  = lf_subobj.
  ls_header-aldate     = sy-datum.
  ls_header-altime     = sy-uzeit.
  ls_header-aluser     = sy-uname.
  ls_header-aldate_del = sy-datum + 1.
*

  CALL FUNCTION 'APPL_LOG_WRITE_HEADER'
    EXPORTING
      header              = ls_header
    IMPORTING
      e_log_handle        = lf_log_handle
    EXCEPTIONS
      object_not_found    = 1
      subobject_not_found = 2
      error               = 3
      OTHERS              = 4.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  CALL FUNCTION 'BAL_DB_LOGNUMBER_GET' ""#EC *
    EXPORTING
      i_client     = sy-mandt
      i_log_handle = lf_log_handle
    IMPORTING
      e_lognumber  = lf_log_number
    EXCEPTIONS
      OTHERS       = 1.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.

*
    REFRESH lt_msg.
    LOOP AT t_log INTO ls_mess.
      CLEAR ls_msg.
      MOVE-CORRESPONDING  ls_mess TO ls_msg."MSGV1 MSGV1
      MOVE: ls_mess-msgtyp TO ls_msg-msgty,
            ls_mess-msgnr TO ls_msg-msgno.
      APPEND ls_msg TO lt_msg.
    ENDLOOP.

    CALL FUNCTION 'APPL_LOG_WRITE_MESSAGES'
      EXPORTING
        object              = lf_obj
        subobject           = lf_subobj
        log_handle          = lf_log_handle
      TABLES
        messages            = lt_msg
      EXCEPTIONS
        object_not_found    = 1
        subobject_not_found = 2
        OTHERS              = 3.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
    IF sy-batch = abap_true.
      MOVE-CORRESPONDING ls_header TO ls_lognum.
      ls_lognum-lognumber = lf_log_number.
      APPEND ls_lognum TO lt_lognum.
*
      CALL FUNCTION 'APPL_LOG_WRITE_DB'
        EXPORTING
          object                = lf_obj
          subobject             = lf_subobj
          log_handle            = lf_log_handle
        TABLES
          object_with_lognumber = lt_lognum
        EXCEPTIONS
          object_not_found      = 1
          subobject_not_found   = 2
          internal_error        = 3
          OTHERS                = 4.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ELSE.
        WRITE / 'Use transaccion SLG1 para revisar log proceso:'(008).
        WRITE: / 'Objeto:ZFI_LOG, SubObjeto = Z01 Log.Number :'(009),
        ls_lognum-lognumber.
      ENDIF.
    ELSE.
      CALL FUNCTION 'BAL_DSP_LOG_DISPLAY'.
    ENDIF.
  ENDIF.
  CLEAR t_log.
  FREE t_log.
ENDFORM.                    " DISPLAY_LOG


*&---------------------------------------------------------------------*
*&      Form  PROCESAR_DATOS
*&---------------------------------------------------------------------*
FORM procesar_datos .

  DATA l_total TYPE bsid-wrbtr.
  DATA l_importe TYPE bsid-wrbtr.
  DATA ls_log LIKE LINE OF t_log.


  l_importe = wa_data-importe / 100. "Buscar FM
  gs_total-monto = gs_total-monto + l_importe.
*- Ajustamos codigo banco
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = wa_data-banco
    IMPORTING
      output = wa_data-banco.
*- Obtenemos via Pago
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = wa_data-forma_pago
    IMPORTING
      output = wa_data-forma_pago.
  SELECT SINGLE operec
    INTO CORRESPONDING FIELDS OF wa_fpagrec
    FROM zfifpagrec
    WHERE fpago = wa_data-forma_pago .
  IF sy-subrc <> 0.
    CLEAR ls_log.
    ls_log-msgtyp = 'E'.
    ls_log-msgspra = sy-langu.
    ls_log-msgid = '00'.
    ls_log-msgnr = '398'.
    CONDENSE g_regindex.
    CONCATENATE TEXT-031 g_regindex ':' INTO ls_log-msgv1
    SEPARATED BY space.

    CONCATENATE TEXT-033 "'Forma de pago no existe'
    wa_data-forma_pago
    INTO ls_log-msgv2 SEPARATED BY space.

    APPEND ls_log TO t_log.
    gs_total-error =  gs_total-error + 1.
    EXIT.
  ENDIF.

  CLEAR l_kunnr.
  IF NOT wa_data-forma_pago = '011'.
    PERFORM obtener_codigo_cliente USING wa_data-rut_cliente
                                   CHANGING l_kunnr.
    IF l_kunnr IS INITIAL.
      CLEAR ls_log.
      ls_log-msgtyp = 'E'.
      ls_log-msgspra = sy-langu.
      ls_log-msgid = '00'.
      ls_log-msgnr = '398'.
      CONDENSE g_regindex.
      CONCATENATE TEXT-031 g_regindex ':' INTO ls_log-msgv1
      SEPARATED BY space.
      CONCATENATE TEXT-034 "'Cliente no existe para RUT'
      wa_data-rut_cliente
      INTO ls_log-msgv2 SEPARATED BY space.
      APPEND ls_log TO t_log.
      gs_total-error =  gs_total-error + 1.
      EXIT.
    ENDIF.
  ENDIF.
**-- Verifica si corresponde a rechazo
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = wa_data-rechazo
    IMPORTING
      output = wa_data-rechazo.

  IF NOT ( wa_data-rechazo IS INITIAL OR
           wa_data-rechazo CO '0' ).
    SELECT SINGLE mandt
                  zmtvrechz
                  zmtvrechzd
     FROM zfimtvrechz
     INTO wa_zfimtvrechz
     WHERE zmtvrechz = wa_data-rechazo.
    IF sy-subrc = 0.
      gs_total-monto_recha = gs_total-monto_recha + l_importe.
      PERFORM actualizar_rechazo.
    ELSE.
      CLEAR ls_log.
      ls_log-msgtyp = 'E'.
      ls_log-msgspra = sy-langu.
      ls_log-msgid = '00'.
      ls_log-msgnr = '398'.
      CONDENSE g_regindex.
      CONCATENATE TEXT-031 g_regindex ':' INTO ls_log-msgv1
      SEPARATED BY space.
      ls_log-msgv2 = TEXT-035. "'Motivo rechazo no existe'.
      APPEND ls_log TO t_log.
      gs_total-error =  gs_total-error + 1.
      EXIT.
    ENDIF.
  ELSE.
    gs_total-monto_sn_recha = gs_total-monto_sn_recha + l_importe.

    CASE     wa_data-forma_pago.
      WHEN '011'. "promociones
        PERFORM procesa_promocion USING l_importe.
      WHEN '012'.
        PERFORM procesa_cambio_cheque USING l_importe.

      WHEN OTHERS.
**--    Obtienen Docuementos Contart/Convenio(DPP)/Evento
        DATA l_vertn(13). " LIKE bsid-vertn.
        REFRESH t_bsid.
        CLEAR t_bsid.

        PERFORM obtener_documentos USING l_total.
        IF t_bsid[] IS INITIAL.
* ---------------- REVISA RUT DPP
          IF wa_data-forma_pago = '003'.
            PERFORM obtener_codigo_cliente USING wa_data-rut_empresa_dpp
                                   CHANGING l_kunnr_dpp.
            IF sy-subrc <>  0.
              CLEAR ls_log.
              ls_log-msgtyp = 'E'.
              ls_log-msgspra = sy-langu.
              ls_log-msgid = '00'.
              ls_log-msgnr = '398'.
              CONDENSE g_regindex.
              CONCATENATE TEXT-031 g_regindex ':' INTO ls_log-msgv1
              SEPARATED BY space.
              CONCATENATE TEXT-032 "'Cliente no existe para RUT DPP'(032)
                           wa_data-rut_empresa_dpp INTO ls_log-msgv2
                           SEPARATED BY space.
              APPEND ls_log TO t_log.
              EXIT.
            ENDIF.
          ENDIF.
*
          PERFORM procesa_anticipo USING l_importe.
          EXIT.
        ELSE.
          CLEAR l_vertn.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'      " SIN 0
            EXPORTING
              input  = wa_data-contrato
            IMPORTING
              output = l_vertn.

          READ TABLE t_bsid WITH KEY  vertn = l_vertn
                                      vertt = wa_data-clase_contrato
          TRANSPORTING NO FIELDS.

          IF sy-subrc <> 0.
            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'     "CON 0
              EXPORTING
                input  = wa_data-contrato
              IMPORTING
                output = l_vertn.
            READ TABLE t_bsid WITH KEY  vertn = l_vertn
                                        vertt = wa_data-clase_contrato
            TRANSPORTING NO FIELDS.

          ENDIF.

          IF sy-subrc <> 0.
            PERFORM procesa_anticipo USING l_importe.
            EXIT.
          ENDIF.
        ENDIF.

**----  Evento
        IF wa_data-evento IS NOT INITIAL. "Evento
          IF l_total <> l_importe.
            CLEAR ls_log.
            ls_log-msgtyp = 'E'.
            ls_log-msgspra = sy-langu.
            ls_log-msgid = '00'.
            ls_log-msgnr = '398'.
            CONDENSE g_regindex.
            CONCATENATE TEXT-031 g_regindex ':' INTO ls_log-msgv1
            SEPARATED BY space.
            ls_log-msgv2 = ' Importe no coincide para evento'(021).
            APPEND ls_log TO t_log.
            gs_total-error =  gs_total-error + 1.
            EXIT.
          ELSE.
            PERFORM procesa_importe USING l_importe.
          ENDIF.
**----  Contrato/Convenio
        ELSEIF ( wa_data-contrato IS NOT INITIAL ) OR
               ( wa_data-convenio IS NOT INITIAL ) .
          IF l_importe > l_total AND
             wa_data-convenio IS NOT INITIAL."Pago DPP
            CLEAR ls_log.
            ls_log-msgtyp = 'E'.
            ls_log-msgspra = sy-langu.
            ls_log-msgid = '00'.
            ls_log-msgnr = '398'.
            CONDENSE g_regindex.
            CONCATENATE TEXT-031 g_regindex ':' INTO ls_log-msgv1
            SEPARATED BY space.
            ls_log-msgv2 = TEXT-036.
            "              'Monto partidas DP es mayor que importe informado'.
            APPEND ls_log TO t_log.
            gs_total-error =  gs_total-error + 1.
            EXIT.
          ENDIF.
          PERFORM procesa_importe USING l_importe.
        ENDIF.

    ENDCASE.
  ENDIF.
ENDFORM.                    " PROCESAR_DATOS


*&---------------------------------------------------------------------*
*&      Form  OBTENER_DOCUMENTOS
*&---------------------------------------------------------------------*
FORM obtener_documentos USING p_total.

  CLEAR p_total.
  IF wa_data-convenio IS NOT INITIAL.   "Pago DPP
    PERFORM get_doc_dpp USING p_total.
  ELSE.
    IF wa_data-evento IS NOT INITIAL.   "Evento
      PERFORM get_doc_eventos USING p_total.
    ELSEIF wa_data-contrato IS NOT INITIAL.
*-> BEG INS V1-CNN ECDK922573 Facturación el línea HELP
      IF wa_data-clase_contrato <> 'Y'.
        PERFORM get_doc_contrato USING p_total.
      ELSE.
        PERFORM get_doc_contrato_y USING p_total.
      ENDIF.
*-> EMD INS V1-CNN ECDK922573 Facturación el línea HELP
    ENDIF.
  ENDIF.

ENDFORM.                    " OBTENER_DOCUMENTOS


*&---------------------------------------------------------------------*
*&      Form  PROCESA_IMPORTE_IGUAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*FORM procesa_importe_igual USING p_importe.
*  PERFORM datos_cabecera.
*  PERFORM ingresar_criterios USING c_x.
*
***- Ingresar documentos a procesar.
***------------------------------------------------------
*  LOOP AT t_bsid INTO wa_bsid.
*    PERFORM bdc_dynpro      USING 'SAPMF05A' '0731'.
*
*    PERFORM bdc_field       USING 'BDC_CURSOR'
*                                  'RF05A-SEL01(01)'.
*    PERFORM bdc_field       USING 'BDC_OKCODE'
*                                  '/00'.
*    PERFORM bdc_field       USING 'RF05A-SEL01(01)'
*                                  wa_bsid-belnr.
*  ENDLOOP.
*  PERFORM procesar_pa  USING p_importe '0.0' sy-tabix .
*
*  PERFORM call_transaction USING 'F-30'.
*ENDFORM.                    " PROCESA_IMPORTE_IGUAL


*&---------------------------------------------------------------------*
*&      Form  PROCESA_IMPORTE
*&---------------------------------------------------------------------*
FORM procesa_importe USING p_importe.


  DATA : l_saldo_importe TYPE bsid-wrbtr,
         saldo           TYPE bsid-wrbtr,
         campo           TYPE string.
  DATA : l_num    TYPE i,
         conta(2) TYPE n.
  TYPES : BEGIN OF t_ref,
            bukrs TYPE bsid-bukrs,
            kunnr TYPE bsid-kunnr,
            belnr TYPE bsid-belnr,
            rebzg TYPE bsid-rebzg,
            wrbtr TYPE bsid-wrbtr,
          END OF t_ref.
  DATA: abonos_parciales TYPE bsid-wrbtr.
  DATA: ti_ref TYPE TABLE OF t_ref,
        wa_ref TYPE t_ref.

*-> BEG INS V1-CNN ECDK922573 Facturación el línea HELP
  CONSTANTS: lc_par_max_dif TYPE rvari_val_255 VALUE 'ZSD_HELP_COMPENSA_MAX_DIF'.
  DATA: lv_max_dif TYPE wrbtr,
        lv_dif_c   TYPE c LENGTH 16.
*-> END INS V1-CNN ECDK922573 Facturación el línea HELP

  l_saldo_importe = p_importe.
  IF l_kunnr <> l_cliente. "cliente nuevo
    CLEAR: l_monto, lv_monto_y.
    l_cliente = l_kunnr.
  ENDIF.

  IF wa_data-contrato <> l_contrato.
    CLEAR: l_monto, lv_monto_y.
    l_contrato = wa_data-contrato.
  ENDIF.
**- Ingresar documentos a procesar.
**------------------------------------------------------
  l_num = 0.
  LOOP AT t_bsid INTO wa_bsid WHERE kunnr = l_kunnr.
    IF l_num =  0.
      PERFORM datos_cabecera.
*
      PERFORM ingresar_criterios USING c_x.
      PERFORM bdc_dynpro     USING 'SAPMF05A' '0731'.

      conta = 0.
      l_num = 1.
    ENDIF.
*
    IF l_saldo_importe > 0.
      ADD 1 TO conta.
      CONCATENATE 'RF05A-SEL01(' conta ')' INTO campo.
      PERFORM bdc_field        USING campo  wa_bsid-belnr.
*
      CLEAR: abonos_parciales.

*     Buscamos si tiene abonos la factura
      REFRESH ti_ref.
      SELECT bukrs kunnr belnr rebzg wrbtr
        INTO CORRESPONDING FIELDS OF TABLE ti_ref
        FROM bsid
        WHERE bukrs = wa_bsid-bukrs
          AND kunnr = wa_bsid-kunnr
          AND rebzg = wa_bsid-belnr.
      IF sy-subrc = 0.
*       Tiene abonos
        LOOP AT ti_ref INTO wa_ref.
          ADD 1 TO conta.
          CLEAR campo.
          CONCATENATE 'RF05A-SEL01(' conta ')' INTO campo.
          PERFORM bdc_field USING campo wa_ref-belnr. "Abono

          ADD wa_ref-wrbtr TO abonos_parciales.
        ENDLOOP.
      ENDIF.

      MOVE l_saldo_importe TO l_monto.
      CLEAR saldo.

      IF NOT abonos_parciales IS INITIAL.
        saldo = wa_bsid-wrbtr - abonos_parciales.

        IF saldo < l_monto.
          l_monto = saldo.
        ENDIF.
        l_saldo_importe = l_saldo_importe - l_monto. "Saldo

      ELSE.
*-> BEG INS V1-CNN ECDK922573 Facturación el línea HELP
        lv_monto_y = l_monto - wa_bsid-wrbtr.
*-> END INS V1-CNN ECDK922573 Facturación el línea HELP

        IF wa_bsid-wrbtr <= l_monto. "Monto de partida menor a archivo
          l_monto = wa_bsid-wrbtr.
        ENDIF.

        l_saldo_importe = l_saldo_importe - l_monto. "Saldo
      ENDIF.
    ELSE.
      EXIT.
    ENDIF.
  ENDLOOP.
*
  IF wa_data-clase_contrato <> 'Y'.
    IF l_saldo_importe > 0.
      CLEAR l_monto.
    ENDIF.
*-> BEG INS V1-CNN ECDK922573 Facturación el línea HELP
  ELSE.
    CLEAR:  lv_max_dif, lv_dif_c.
*   Rescatar parámetro importe máximo
    SELECT SINGLE FROM tvarvc FIELDS low
      WHERE name = @lc_par_max_dif
        AND type = 'P'
        AND numb = '0000'
      INTO @DATA(lv_low).
    IF sy-subrc = 0.
      lv_max_dif = lv_low.
    ELSE.
      lv_max_dif = 1000.
    ENDIF.

    WRITE lv_monto_y  TO lv_dif_c CURRENCY 'CLP' NO-SIGN NO-GROUPING.

    IF lv_dif_c <= lv_max_dif.
      IF l_saldo_importe <= 0.
        CLEAR l_monto.
      ENDIF.
    ENDIF.
  ENDIF.
*-> END INS V1-CNN ECDK922573 Facturación el línea HELP

*-> BEG DEL V1-CNN ECDK922573 Facturación el línea HELP
* PERFORM procesar_pa USING p_importe l_monto l_saldo_importe.
*-> END DEL V1-CNN ECDK922573 Facturación el línea HELP

*-> BEG INS V1-CNN ECDK922573 Facturación el línea HELP
  IF wa_data-clase_contrato <> 'Y' OR lv_dif_c > lv_max_dif.
    PERFORM procesar_pa USING p_importe l_monto l_saldo_importe.
  ELSE.
    PERFORM procesar_pa_y USING p_importe l_monto lv_monto_y.
  ENDIF.
*-> END INS V1-CNN ECDK922573 Facturación el línea HELP

  PERFORM call_transaction USING 'F-30'.

ENDFORM.                    " PROCESA_IMPORTE


*&---------------------------------------------------------------------*
*&      Form  PROCESA_IMPORTE_MAYOR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*FORM procesa_importe_mayor  USING p_importe p_total.
*  DATA: l_saldo TYPE bsid-wrbtr,
*        l_saldo2(16) TYPE c.
*  DATA l_importec(16) TYPE c.
*  DATA l_saldoc(16) TYPE c.
*  DATA l_fechac(10) TYPE c.
*
*  l_saldo = p_importe - p_total.
*  WRITE p_importe  TO l_importec CURRENCY 'CLP'.
*  WRITE l_saldo TO l_saldoc CURRENCY 'CLP'.
*
*  PERFORM bdc_dynpro      USING 'SAPMF05A' '0122'.
*  PERFORM bdc_field       USING 'BDC_CURSOR'
*                                'RF05A-NEWKO'.
*  PERFORM bdc_field       USING 'BDC_OKCODE'
*                                '/00'.
*  PERFORM bdc_field       USING 'BKPF-BLDAT'
*                                wa_data-fecha_documento.
*  PERFORM bdc_field       USING 'BKPF-BLART'
*                                wa_data-clase_documento.
*  PERFORM bdc_field       USING 'BKPF-BUKRS'
*                                wa_data-sociedad.
*  PERFORM bdc_field       USING 'BKPF-BUDAT'
*                                wa_data-fecha_contable.
*  PERFORM bdc_field       USING 'BKPF-MONAT'
*                                wa_data-periodo.
*  PERFORM bdc_field       USING 'BKPF-WAERS'
*                                'CLP'.
*  PERFORM bdc_field       USING 'BKPF-XBLNR'
*                                wa_data-referencia.
*
*  IF wa_data-forma_pago = '016'. "Cheque a fecha
*    CLEAR : l_saldo2.
****Calculo del saldo que irá como anticipo
*    WRITE l_saldo TO l_saldo2 CURRENCY 'CLP'.
*
*    IF wa_data-contrato IS INITIAL.
*      wa_data-contrato = 'PROC.RECAUDACIÓN'.
*    ENDIF.
*
*    PERFORM bdc_field       USING 'BKPF-BKTXT'
*                                  wa_data-contrato.
*  ELSE.
*
*    IF wa_data-texto_cabecera IS INITIAL.
*      wa_data-texto_cabecera = 'PROC. RECAUDACIÓN'.
*    ENDIF.
*
*    PERFORM bdc_field       USING 'BKPF-BKTXT'
*                                  wa_data-texto_cabecera.
*  ENDIF.
*
*  PERFORM bdc_field       USING 'FS006-DOCID'
*                                '*'.
*
*  IF wa_data-forma_pago = '016'.
****primer asiento
*    PERFORM bdc_field     USING 'RF05A-NEWBS'
*                                  '09'.
*    PERFORM bdc_field     USING 'RF05A-NEWUM'
*                                  '5'.
*    PERFORM bdc_field     USING 'RF05A-NEWKO'
*                                 l_kunnr.
***  ----------------------------------------------
*    PERFORM bdc_dynpro    USING 'SAPMF05A' '2320'.
*    PERFORM bdc_field     USING 'BDC_OKCODE'
*                                 '=SL'.
*    PERFORM bdc_field     USING 'BSEG-WRBTR'
*                                  l_importec. "Importe total
*    PERFORM bdc_field     USING 'BSEG-ZUONR'
*                                  wa_data-cheque .
*    PERFORM bdc_field     USING 'BSEG-SGTXT'
*                                 'ANTICIPO CHEQUE A FECHA'.
*    PERFORM bdc_field     USING 'BSEG-ZFBDT'
*                                   wa_data-fecha_vencto.
*    PERFORM bdc_field     USING 'BSED-WDATE'
*                                  wa_data-fecha_emision.
*    PERFORM bdc_field     USING 'BSEG-ZLSCH'
*                                  wa_data-via_pago_sap.
*    PERFORM bdc_field     USING 'BSEC-BANKL'
*                                  wa_data-banco.
*    PERFORM bdc_field     USING 'BSEC-BANKN'
*                                  wa_data-nro_cta_cte_cli.
*    PERFORM bdc_field     USING 'BSED-WBANK'
*                                  ''.
*    PERFORM bdc_field     USING 'BSEC-BANKS'
*                                  wa_data-pais_banco.
*
****segundo asiento
*    PERFORM bdc_field     USING 'RF05A-NEWBS'  '19'.
*    PERFORM bdc_field     USING 'RF05A-NEWKO'  l_kunnr.
*    PERFORM bdc_field     USING 'RF05A-NEWUM' 'A'.
*
*    PERFORM bdc_dynpro    USING 'SAPMF05A'   '0304'.
*    PERFORM bdc_field     USING 'BDC_OKCODE' '=SL'.
*    PERFORM bdc_field     USING 'BSEG-WRBTR' l_saldo2. "Saldo
*    PERFORM bdc_field     USING 'BSEG-ZUONR' wa_data-cheque .
*    PERFORM bdc_field     USING 'BSEG-ZFBDT' wa_data-fecha_vencto.
*    PERFORM bdc_field     USING 'BSEG-VERTN' wa_data-contrato.
*    PERFORM bdc_field     USING 'BSEG-VERTT' 'A'.
*    PERFORM bdc_field     USING 'BSEG-ZLSCH' wa_data-via_pago_sap.
*    PERFORM bdc_field     USING 'BSEG-SGTXT' 'ANTICIPO CHEQUE A FECHA'.
*
****Asiento de las partidas abiertas
*    PERFORM bdc_dynpro      USING 'SAPMF05A' '0710'.
*    PERFORM bdc_field       USING 'BDC_CURSOR'
*                                  'RF05A-XPOS1(04)'.
*    PERFORM bdc_field       USING 'BDC_OKCODE'
*                                  '/00'.
*    PERFORM bdc_field       USING 'RF05A-AGBUK'
*                                  wa_data-sociedad.
*    PERFORM bdc_field       USING 'RF05A-AGKON'
*                                  l_kunnr.
*    PERFORM bdc_field       USING 'RF05A-AGKOA'
*                                  'D'.
*    PERFORM bdc_field       USING 'RF05A-XNOPS'
*                                  'X'.
*    PERFORM bdc_field       USING 'RF05A-XPOS1(01)'
*                                  ''.
*    PERFORM bdc_field       USING 'RF05A-XPOS1(04)'
*                                  'X'.
*
*    LOOP AT t_bsid INTO wa_bsid.
*      PERFORM bdc_dynpro      USING 'SAPMF05A'       '0731'.
*      PERFORM bdc_field       USING 'BDC_OKCODE'     '/00'.
*      PERFORM bdc_field       USING 'RF05A-SEL01(01)' wa_bsid-belnr.
*    ENDLOOP.
*
*    PERFORM bdc_dynpro      USING 'SAPMF05A'    '0731'.
*    PERFORM bdc_field       USING 'BDC_OKCODE'  '=BU'.
*
*    PERFORM call_transaction USING 'F-30'.
*
*  ELSE.
*
*    PERFORM bdc_field      USING 'RF05A-NEWBS' '40'.
*    PERFORM bdc_field      USING 'RF05A-NEWKO' wa_data-cuenta_contable.
***---------------------------------------------------
*    PERFORM bdc_dynpro      USING 'SAPMF05A'    '0300'.
*    PERFORM bdc_field       USING 'BDC_CURSOR'  'RF05A-NEWUM'.
*    PERFORM bdc_field       USING 'BDC_OKCODE'  '/00'.
*    PERFORM bdc_field       USING 'BSEG-WRBTR'  l_importec.
*    PERFORM bdc_field       USING 'BSEG-VALUT'  wa_data-fecha_valor.
*    PERFORM bdc_field       USING 'BSEG-ZUONR' 'OPCIONAL'.
*    PERFORM bdc_field       USING 'BSEG-SGTXT'
*                                  'PAGO CLIENTE Y ANTICIPO'.
*    PERFORM bdc_field       USING 'RF05A-NEWBS'  '19'.
*    PERFORM bdc_field       USING 'RF05A-NEWKO'  l_kunnr.
*    PERFORM bdc_field       USING 'RF05A-NEWUM'  'A'.
*    PERFORM bdc_field       USING 'DKACB-FMORE'  ''.
***----------------------------------------------
*** Contabilizacion
*    PERFORM bdc_dynpro      USING 'SAPMF05A' '0304'.
*    PERFORM bdc_field       USING 'BDC_CURSOR'
*                                  'BSEG-SGTXT'.
*    PERFORM bdc_field       USING 'BDC_OKCODE'
*                                  '=SL'.
*    PERFORM bdc_field       USING 'BSEG-WRBTR'
*                                  l_saldoc.
*    WRITE sy-datum TO l_fechac.
*    PERFORM bdc_field       USING 'BSEG-ZFBDT'
*                                  l_fechac.
*    PERFORM bdc_field       USING 'BSEG-VERTN'
*                                  wa_data-contrato.
*    PERFORM bdc_field       USING 'BSEG-VERTT'
*                                  'A'.
*    PERFORM bdc_field       USING 'BSEG-ZUONR'
*                                  'OPCIONAL'.
*    PERFORM bdc_field       USING 'BSEG-SGTXT'
*                                  'PAGO CLIENTE Y ANTICIPO'.
***----------------------------------------------------------
*    PERFORM bdc_dynpro      USING 'SAPMF05A' '0710'.
*    PERFORM bdc_field       USING 'BDC_CURSOR'
*                                  'RF05A-XPOS1(04)'.
*    PERFORM bdc_field       USING 'BDC_OKCODE'
*                                  '/00'.
*    PERFORM bdc_field       USING 'RF05A-AGBUK'
*                                  wa_data-sociedad.
*    PERFORM bdc_field       USING 'RF05A-AGKON'
*                                  l_kunnr.
*    PERFORM bdc_field       USING 'RF05A-AGKOA'
*                                  'D'.
*    PERFORM bdc_field       USING 'RF05A-XNOPS'
*                                  'X'.
*    PERFORM bdc_field       USING 'RF05A-XPOS1(01)'
*                                  ''.
*    PERFORM bdc_field       USING 'RF05A-XPOS1(04)'
*                                  'X'.
***-----------------------------------------------------
***- Ingresar documentos a procesar.
***------------------------------------------------------
*    LOOP AT t_bsid INTO wa_bsid.
*      PERFORM bdc_dynpro      USING 'SAPMF05A' '0731'.
*
*      PERFORM bdc_field       USING 'BDC_CURSOR'
*                                    'RF05A-SEL01(01)'.
*      PERFORM bdc_field       USING 'BDC_OKCODE'
*                                    '/00'.
*      PERFORM bdc_field       USING 'RF05A-SEL01(01)'
*                                    wa_bsid-belnr.
*    ENDLOOP.
*    PERFORM bdc_dynpro      USING 'SAPMF05A' '0731'.
*    PERFORM bdc_field       USING 'BDC_CURSOR'
*                                  'RF05A-SEL01(05)'.
*    PERFORM bdc_field       USING 'BDC_OKCODE'
*                                  '=PA'.
**---------------------------------------------------
*    PERFORM bdc_dynpro      USING 'SAPDF05X' '3100'.
*    PERFORM bdc_field       USING 'BDC_OKCODE'
*                                  '=BS'.
*    PERFORM bdc_field       USING 'BDC_CURSOR'
*                                  'DF05B-PSSKT(01)'.
*    PERFORM bdc_field       USING 'RF05A-ABPOS'
*                                  '1'.
*    PERFORM bdc_dynpro      USING 'SAPMF05A' '0700'.
*    PERFORM bdc_field       USING 'BDC_CURSOR'
*                                  'RF05A-NEWBS'.
*    PERFORM bdc_field       USING 'BDC_OKCODE'
*                                  '=BU'.
*    PERFORM bdc_field       USING 'BKPF-XBLNR'
*                                  wa_data-referencia.
*
*    IF wa_data-texto_cabecera IS INITIAL.
*      wa_data-texto_cabecera = 'PROC.RECAUDACIÓN'.
*    ENDIF.
*
*    PERFORM bdc_field       USING 'BKPF-BKTXT'
*                                  wa_data-texto_cabecera.
*
*    PERFORM call_transaction USING 'F-30'.
*  ENDIF.
*ENDFORM.                    " PROCESA_IMPORTE_MAYOR
*&---------------------------------------------------------------------*
*&      Form  DATOS_CABECERA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*

FORM datos_cabecera .
  PERFORM bdc_dynpro      USING 'SAPMF05A' '0122'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'BKPF-BKTXT'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=SL'.
  PERFORM bdc_field       USING 'BKPF-BLDAT'
                                wa_data-fecha_documento.
  PERFORM bdc_field       USING 'BKPF-BLART'
                                wa_data-clase_documento."'DZ'.
  PERFORM bdc_field       USING 'BKPF-BUKRS'
                                wa_data-sociedad.
  PERFORM bdc_field       USING 'BKPF-BUDAT'
                                wa_data-fecha_contable.
  PERFORM bdc_field       USING 'BKPF-MONAT'
                                wa_data-periodo.
  PERFORM bdc_field       USING 'BKPF-WAERS'
                                'CLP'.
  PERFORM bdc_field       USING 'BKPF-XBLNR'
                                wa_data-referencia.

  IF wa_data-texto_cabecera IS INITIAL.
    wa_data-texto_cabecera = 'PROC.RECAUDACIÓN'.
  ENDIF.

  PERFORM bdc_field       USING 'BKPF-BKTXT'
                                wa_data-texto_cabecera.

  PERFORM bdc_field       USING 'FS006-DOCID'
                                '*'.
  CASE wa_fpagrec-operec.
    WHEN 'E'.
      PERFORM bdc_field       USING 'RF05A-XPOS1(02)'
                                    'X'.
      PERFORM bdc_field       USING 'RF05A-XPOS1(04)'
                                    ''.
    WHEN 'T'.

    WHEN OTHERS." Corregir
      PERFORM bdc_field       USING 'RF05A-XPOS1(02)'
                                'X'.
      PERFORM bdc_field       USING 'RF05A-XPOS1(04)'
                                       ''.
  ENDCASE.
ENDFORM.                    " DATOS_CABECERA
*&---------------------------------------------------------------------*
*&      Form  INGRESAR_CRITERIOS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*

FORM ingresar_criterios USING p_x.
**-----------------------------------------------------
  PERFORM bdc_dynpro      USING 'SAPMF05A'    '0710'.
  PERFORM bdc_field       USING 'BDC_OKCODE'  '/00'.
  PERFORM bdc_field       USING 'RF05A-AGBUK'  wa_data-sociedad.
  PERFORM bdc_field       USING 'RF05A-AGKON'  l_kunnr.
  PERFORM bdc_field       USING 'RF05A-AGKOA'  'D'.
  PERFORM bdc_field       USING 'RF05A-XNOPS'  'X'.
  IF NOT p_x IS INITIAL."Busqueda por referencia de factura
    PERFORM bdc_field      USING 'RF05A-XPOS1(01)' space.
    PERFORM bdc_field      USING 'RF05A-XPOS1(18)' 'X'.

    PERFORM bdc_dynpro      USING 'SAPMF05A'   '0608'.
    PERFORM bdc_field       USING 'BDC_OKCODE' '=P+'.

    PERFORM bdc_dynpro      USING 'SAPMF05A'        '0608'.
    PERFORM bdc_field       USING 'BDC_OKCODE'      '=ENTR'.
    PERFORM bdc_field       USING 'RF05A-XPOS1(01)' space.
* INI V1 RVY 11-06-2025
*    PERFORM bdc_field       USING 'RF05A-XPOS1(10)' 'X'.
    PERFORM bdc_field       USING 'RF05A-XPOS1(06)' 'X'.
* FIN V1 RVY 11-06-2025
  ELSE."Búsqueda por factura
    PERFORM bdc_field       USING 'RF05A-XPOS1(01)' ''.
    PERFORM bdc_field       USING 'RF05A-XPOS1(04)' 'X'.
  ENDIF.
ENDFORM.                    " INGRESAR_CRITERIOS


*&---------------------------------------------------------------------*
*&      Form  PROCESAR_PA
*&---------------------------------------------------------------------*
FORM procesar_pa USING p_importe p_saldo p_diferencia.

  DATA l_importec(16) TYPE c.
  DATA l_diferenc(16) TYPE c.
  DATA l_saldoc(16) TYPE c.
  DATA ls_log LIKE LINE OF t_log.
**
  WRITE p_importe     TO l_importec CURRENCY 'CLP'.
  WRITE p_saldo       TO l_saldoc   CURRENCY 'CLP'.
  WRITE p_diferencia  TO l_diferenc CURRENCY 'CLP'.
*-------------------------------------------------
  PERFORM bdc_dynpro      USING 'SAPMF05A'    '0731'.
  PERFORM bdc_field       USING 'BDC_OKCODE'  '=PA'.

  IF  p_saldo > 0. "parcialidad en ultimo documento
*    READ TABLE t_bsid INDEX p_tabix INTO wa_bsid .
*    IF sy-subrc = 0.
    PERFORM bdc_dynpro USING 'SAPDF05X'	           '3100'.
    PERFORM bdc_field  USING 'BDC_OKCODE'	         '=Z+'.
    PERFORM bdc_field  USING 'RF05A-ABPOS'         '1'.

    PERFORM bdc_dynpro USING 'SAPDF05X'             '3100'.
    PERFORM bdc_field  USING 'BDC_OKCODE'           '=OSO'.
    PERFORM bdc_field  USING 'RF05A-ABPOS'          '1'.

    IF p_mode NE 'A'.
      PERFORM bdc_dynpro USING 'SAPDF05X'           '2003'.
      PERFORM bdc_field  USING 'BDC_OKCODE'         '=SO-'.
      PERFORM bdc_field  USING 'RF05A-SRTFO(05)'    '1'.
    ENDIF.
*---------------------------------------------------
    PERFORM bdc_dynpro      USING 'SAPDF05X'        '3100'.
    PERFORM bdc_field       USING 'BDC_OKCODE'      '=PART'.
    PERFORM bdc_field       USING 'RF05A-ABPOS'     '1'.

    PERFORM bdc_dynpro      USING 'SAPDF05X'        '3100'.
    PERFORM bdc_field       USING 'BDC_OKCODE'      '/00'.
    PERFORM bdc_field       USING 'RF05A-ABPOS'     '1'.
    PERFORM bdc_field       USING 'DF05B-PSZAH(01)'  l_saldoc.
    PERFORM bdc_field       USING 'DF05B-RSTGR(01)'  '058'.
*    ENDIF.
  ENDIF.
**-----------------------------------------------------
  PERFORM bdc_dynpro      USING 'SAPDF05X'    '3100'.
  PERFORM bdc_field       USING 'BDC_OKCODE'  '=KMD'.
  PERFORM bdc_field       USING 'RF05A-ABPOS' '1'.
**------------------------------------------------------
  PERFORM bdc_dynpro      USING 'SAPMF05A'    '0700'.
  PERFORM bdc_field       USING 'BDC_CURSOR'  'RF05A-NEWKO'.
  PERFORM bdc_field       USING 'BDC_OKCODE'  '/00'.
  PERFORM bdc_field       USING 'BKPF-XBLNR'  wa_data-referencia.

  IF wa_data-texto_cabecera IS INITIAL.
    wa_data-texto_cabecera = 'PROC. RECAUDACIÓN'.
  ENDIF.
  PERFORM bdc_field       USING 'BKPF-BKTXT'  wa_data-texto_cabecera.
**-----------------------------------------------------
  CASE wa_data-forma_pago.
    WHEN '015' ."Cheque día
      PERFORM bdc_field  USING 'RF05A-NEWBS'  '40'.
      PERFORM bdc_field  USING 'RF05A-NEWKO'  wa_data-cuenta_contable.
**----------------------------------------------------------------------
*-
      PERFORM bdc_dynpro USING 'SAPMF05A'      '0300'.
      PERFORM bdc_field  USING 'BDC_CURSOR'    'BSEG-SGTXT'.
      IF p_diferencia = 0.
        PERFORM bdc_field  USING 'BDC_OKCODE'    '=BU'.
      ELSE.
        PERFORM bdc_field  USING 'BDC_OKCODE'    '/00'.
      ENDIF.
      PERFORM bdc_field  USING 'BSEG-WRBTR'    l_importec.
      PERFORM bdc_field  USING 'BSEG-VALUT'    wa_data-fecha_valor.
      PERFORM bdc_field  USING 'BSEG-ZUONR'    wa_data-texto_cabecera.
      PERFORM bdc_field  USING 'BSEG-SGTXT'    wa_data-cheque.
      PERFORM bdc_field  USING 'DKACB-FMORE'   ' '.
    WHEN '016'."Cheque Fecha
      PERFORM bdc_field  USING 'RF05A-NEWBS'   '09'.
      PERFORM bdc_field  USING 'RF05A-NEWKO'   l_kunnr.
      PERFORM bdc_field  USING 'RF05A-NEWUM'   '5'.
**  ----------------------------------------------
      PERFORM bdc_dynpro USING 'SAPMF05A'      '2320'.
      PERFORM bdc_field  USING 'BDC_CURSOR'    'BSED-WBANK'.
      IF p_diferencia = 0.
        PERFORM bdc_field  USING 'BDC_OKCODE'    '=BU'.
      ELSE.
        PERFORM bdc_field  USING 'BDC_OKCODE'    '/00'.
      ENDIF.
      PERFORM bdc_field  USING 'BSEG-WRBTR'    l_importec.
      PERFORM bdc_field  USING 'BSEG-ZUONR'    wa_data-cheque .
      PERFORM bdc_field  USING 'BSEG-SGTXT'   'PAGO CLIENTE CON CHEQUE'.
      PERFORM bdc_field  USING 'BSEG-ZFBDT'    wa_data-fecha_vencto.
      PERFORM bdc_field  USING 'BSED-WDATE'    wa_data-fecha_emision.
      PERFORM bdc_field  USING 'BSEG-ZLSCH'    wa_data-via_pago_sap.
      PERFORM bdc_field  USING 'BSEC-BANKL'    wa_data-banco.
      PERFORM bdc_field  USING 'BSEC-BANKN'    wa_data-nro_cta_cte_cli.
      PERFORM bdc_field  USING 'BSED-WBANK'    ''.
      PERFORM bdc_field  USING 'BSEC-BANKS'    wa_data-pais_banco.
    WHEN '003'. "DPP
      PERFORM obtener_codigo_cliente USING wa_data-rut_empresa_dpp
                             CHANGING l_kunnr_dpp.
      IF sy-subrc <>  0.
        CLEAR ls_log.
        ls_log-msgtyp = 'E'.
        ls_log-msgspra = sy-langu.
        ls_log-msgid = '00'.
        ls_log-msgnr = '398'.
        CONDENSE g_regindex.
        CONCATENATE TEXT-031 g_regindex ':' INTO ls_log-msgv1
        SEPARATED BY space.
        CONCATENATE TEXT-032 "'Cliente no existe para RUT DPP'(032)
                     wa_data-rut_empresa_dpp INTO ls_log-msgv2
                     SEPARATED BY space.
        APPEND ls_log TO t_log.
        EXIT.
      ENDIF.
*
      SHIFT wa_data-texto_cabecera LEFT DELETING LEADING space.
      PERFORM bdc_field       USING 'BKPF-BKTXT'  wa_data-texto_cabecera.
*CNN       PERFORM bdc_field       USING 'RF05A-NEWBS' '01'.
      PERFORM bdc_field       USING 'RF05A-NEWBS' '09'.
      PERFORM bdc_field       USING 'RF05A-NEWKO' l_kunnr_dpp.
      PERFORM bdc_field       USING 'RF05A-NEWUM' 'D'.
**-------------------------------------------------------
*CNN      PERFORM bdc_dynpro      USING 'SAPMF05A'    '0301'.
      PERFORM bdc_dynpro      USING 'SAPMF05A'    '0303'.
      PERFORM bdc_field       USING 'BDC_CURSOR'  'BSEG-SGTXT'.
      IF p_diferencia = 0.
        PERFORM bdc_field       USING 'BDC_OKCODE'  '=BU'.
      ELSE.
        PERFORM bdc_field       USING 'BDC_OKCODE'  '/00'.
      ENDIF.
      PERFORM bdc_field       USING 'BSEG-WRBTR'  l_importec.
      PERFORM bdc_field       USING 'BSEG-MWSKZ'  '**'.
      PERFORM bdc_field       USING 'BSEG-VERTN'  wa_data-contrato.
      IF NOT wa_data-clase_contrato IS INITIAL.
        PERFORM bdc_field       USING 'BSEG-VERTT'  wa_data-clase_contrato.
      ELSE.
        PERFORM bdc_field       USING 'BSEG-VERTT'  'A'.
      ENDIF.
      PERFORM bdc_field       USING 'BSEG-ZFBDT'  wa_data-fecha_vencto.
      PERFORM bdc_field       USING 'BSEG-SGTXT'  'PAGO DPP'.
      l_kunnr = l_kunnr_dpp.

    WHEN OTHERS.
      PERFORM bdc_field    USING 'RF05A-NEWBS' '40'.
      PERFORM bdc_field    USING 'RF05A-NEWKO' wa_data-cuenta_contable.
**  -----------------------------------------------------
      PERFORM bdc_dynpro   USING 'SAPMF05A'     '0300'.
      PERFORM bdc_field    USING 'BDC_CURSOR'   'BSEG-SGTXT'.
      PERFORM bdc_field    USING 'BSEG-SGTXT'   ' '."'OPCIONAL'.
      PERFORM bdc_field    USING 'BSEG-VALUT'    wa_data-fecha_valor.
      PERFORM bdc_field    USING 'BSEG-WRBTR'   l_importec.
      PERFORM bdc_field    USING 'DKACB-FMORE'  ' '.
      PERFORM bdc_field    USING 'BDC_OKCODE'   '=ZK'.
*
      PERFORM bdc_dynpro   USING 'SAPMF05A'     '0330'.
      PERFORM bdc_field    USING 'BSEG-XREF1'   wa_data-cheque.

      IF p_diferencia = 0.
        PERFORM bdc_field       USING 'BDC_OKCODE' '=BU'.
      ELSE.
        PERFORM bdc_field       USING 'BDC_OKCODE' '/00'.
      ENDIF.
  ENDCASE.

  IF p_diferencia GT 0.
    PERFORM bdc_field   USING 'RF05A-NEWBS'	'19'.
    PERFORM bdc_field   USING 'RF05A-NEWKO' l_kunnr.
    PERFORM bdc_field   USING 'RF05A-NEWUM'	'A'.
*
    PERFORM bdc_dynpro  USING 'SAPMF05A'    '0304'.
    PERFORM bdc_field   USING 'BSEG-WRBTR'  l_diferenc.
    PERFORM bdc_field   USING 'BSEG-ZFBDT'  wa_data-fecha_valor.
    PERFORM bdc_field   USING 'BSEG-VERTN'  wa_data-contrato.
    IF NOT wa_data-clase_contrato IS INITIAL.
      PERFORM bdc_field   USING 'BSEG-VERTT'  wa_data-clase_contrato.
    ELSE.
      PERFORM bdc_field   USING 'BSEG-VERTT'  'A'.
    ENDIF.
    PERFORM bdc_field   USING 'BSEG-SGTXT'  'ANTICIPO RECAUDACIÓN'.
    PERFORM bdc_field   USING 'BDC_OKCODE'   '=ZK'.
*
    PERFORM bdc_dynpro  USING 'SAPMF05A'     '0331'.
    PERFORM bdc_field   USING 'BSEG-XREF1'   wa_data-cheque.
    PERFORM bdc_field   USING 'BDC_OKCODE'  '=BU'.
*
    PERFORM bdc_dynpro      USING 'SAPLKACB'    '0002'  .
    PERFORM bdc_field       USING 'BDC_OKCODE' '=ENTE'.

  ENDIF.
**--------------------------------------------------------

ENDFORM.                    " PROCESAR_PA


*-> BEG INS V1-CNN ECDK922573 Facturación el línea HELP
*&---------------------------------------------------------------------*
*&      Form  PROCESAR_PA_Y
*&---------------------------------------------------------------------*
FORM procesar_pa_y USING p_importe p_saldo p_diferencia.

  CONSTANTS: lc_par_max_dif TYPE rvari_val_255 VALUE 'ZSD_HELP_COMPENSA_MAX_DIF',
             lc_par_hkont   TYPE rvari_val_255 VALUE 'ZSD_HELP_COMPENSA_HKONT',
             lc_par_kostl   TYPE rvari_val_255 VALUE 'ZSD_HELP_COMPENSA_KOSTL'.

  DATA l_importec(16) TYPE c.
  DATA l_diferenc(16) TYPE c.
  DATA l_saldoc(16) TYPE c.
  DATA ls_log LIKE LINE OF t_log.

  DATA: lv_max_dif TYPE wrbtr.


* Rescatar parámetro importe máximo
  SELECT SINGLE FROM tvarvc FIELDS low
    WHERE name = @lc_par_max_dif
      AND type = 'P'
      AND numb = '0000'
    INTO @DATA(lv_low).
  IF sy-subrc = 0.
    lv_max_dif = lv_low.
  ELSE.
    lv_max_dif = 1000.
  ENDIF.

* Rescatar parámetros: Cuenta contable
  SELECT SINGLE FROM tvarvc FIELDS low
    WHERE name = @lc_par_hkont
      AND type = 'P'
      AND numb = '0000'
    INTO @DATA(lv_hkont).
  IF sy-subrc <> 0.
    lv_hkont = '8111100099'.
  ENDIF.

* Rescatar parámetros: Centro de costo
  SELECT SINGLE FROM tvarvc FIELDS low
    WHERE name = @lc_par_kostl
      AND type = 'P'
      AND numb = '0000'
    INTO @DATA(lv_kostl).
  IF sy-subrc <> 0.
    lv_kostl = 'CL51011201'.
  ENDIF.

  WRITE p_importe     TO l_importec CURRENCY 'CLP'.
  WRITE p_saldo       TO l_saldoc   CURRENCY 'CLP'.
  WRITE p_diferencia  TO l_diferenc CURRENCY 'CLP' NO-SIGN NO-GROUPING.

*
  PERFORM bdc_dynpro      USING 'SAPMF05A'    '0731'.
  PERFORM bdc_field       USING 'BDC_OKCODE'  '=PA'.

  IF  p_saldo > 0. "parcialidad en ultimo documento
    PERFORM bdc_dynpro USING 'SAPDF05X'	           '3100'.
    PERFORM bdc_field  USING 'BDC_OKCODE'	         '=Z+'.
    PERFORM bdc_field  USING 'RF05A-ABPOS'         '1'.

    PERFORM bdc_dynpro USING 'SAPDF05X'             '3100'.
    PERFORM bdc_field  USING 'BDC_OKCODE'           '=OSO'.
    PERFORM bdc_field  USING 'RF05A-ABPOS'          '1'.

    IF p_mode NE 'A'.
      PERFORM bdc_dynpro USING 'SAPDF05X'           '2003'.
      PERFORM bdc_field  USING 'BDC_OKCODE'         '=SO-'.
      PERFORM bdc_field  USING 'RF05A-SRTFO(05)'    '1'.
    ENDIF.
*---------------------------------------------------
    PERFORM bdc_dynpro      USING 'SAPDF05X'        '3100'.
    PERFORM bdc_field       USING 'BDC_OKCODE'      '=PART'.
    PERFORM bdc_field       USING 'RF05A-ABPOS'     '1'.

    PERFORM bdc_dynpro      USING 'SAPDF05X'        '3100'.
    PERFORM bdc_field       USING 'BDC_OKCODE'      '/00'.
    PERFORM bdc_field       USING 'RF05A-ABPOS'     '1'.
    IF p_diferencia >= 0.
      PERFORM bdc_field       USING 'DF05B-PSZAH(01)'  l_saldoc.
    ELSE.
      PERFORM bdc_field       USING 'DF05B-PSZAH(01)'  l_importec.
    ENDIF.
    PERFORM bdc_field       USING 'DF05B-RSTGR(01)'  '058'.
  ENDIF.
**-----------------------------------------------------
  PERFORM bdc_dynpro      USING 'SAPDF05X'    '3100'.
  PERFORM bdc_field       USING 'BDC_OKCODE'  '=KMD'.
  PERFORM bdc_field       USING 'RF05A-ABPOS' '1'.
**------------------------------------------------------
  PERFORM bdc_dynpro      USING 'SAPMF05A'    '0700'.
  PERFORM bdc_field       USING 'BDC_CURSOR'  'RF05A-NEWKO'.
  PERFORM bdc_field       USING 'BDC_OKCODE'  '/00'.
  PERFORM bdc_field       USING 'BKPF-XBLNR'  wa_data-referencia.

  IF wa_data-texto_cabecera IS INITIAL.
    wa_data-texto_cabecera = 'PROC. RECAUDACIÓN'.
  ENDIF.
  PERFORM bdc_field    USING 'BKPF-BKTXT'  wa_data-texto_cabecera.
  PERFORM bdc_field    USING 'RF05A-NEWBS' '40'.
  PERFORM bdc_field    USING 'RF05A-NEWKO' wa_data-cuenta_contable.
*
  PERFORM bdc_dynpro   USING 'SAPMF05A'     '0300'.
  PERFORM bdc_field    USING 'BSEG-SGTXT'   ' '."'OPCIONAL'.
  PERFORM bdc_field    USING 'BSEG-VALUT'   wa_data-fecha_valor.
  PERFORM bdc_field    USING 'BSEG-WRBTR'   l_importec.
  PERFORM bdc_field    USING 'DKACB-FMORE'  ' '.
  PERFORM bdc_field    USING 'BDC_OKCODE'   '=ZK'.
*
  PERFORM bdc_dynpro   USING 'SAPMF05A'     '0330'.
  PERFORM bdc_field    USING 'BSEG-XREF1'   wa_data-cheque.

  IF p_diferencia = 0.
    PERFORM bdc_field  USING 'BDC_OKCODE' '=BU'.
  ELSE.
    PERFORM bdc_field  USING 'BDC_OKCODE' '/00'.
  ENDIF.

  IF l_diferenc > 1000.
    PERFORM bdc_field   USING 'RF05A-NEWBS'	'19'.
    PERFORM bdc_field   USING 'RF05A-NEWKO' l_kunnr.
    PERFORM bdc_field   USING 'RF05A-NEWUM'	'A'.

    PERFORM bdc_dynpro  USING 'SAPMF05A'    '0304'.
    PERFORM bdc_field   USING 'BDC_OKCODE'  '=BU'.
    PERFORM bdc_field   USING 'BSEG-WRBTR'  l_diferenc.
    PERFORM bdc_field   USING 'BSEG-ZFBDT'  wa_data-fecha_valor.
    PERFORM bdc_field   USING 'BSEG-VERTN'  wa_data-contrato.
    PERFORM bdc_field   USING 'BSEG-VERTT'  'A'.
    PERFORM bdc_field   USING 'BSEG-SGTXT'  'ANTICIPO RECAUDACIÓN'.
    PERFORM bdc_dynpro  USING 'SAPLKACB'    '0002'.
    PERFORM bdc_field   USING 'BDC_OKCODE' '=ENTE'.
  ENDIF.

  IF l_diferenc < 1000 AND p_diferencia <> 0.

    IF p_diferencia > 0.
      PERFORM bdc_field   USING 'RF05A-NEWBS'	'50'.
    ELSE.
      PERFORM bdc_field  USING 'RF05A-NEWBS' '40'.
    ENDIF.
    PERFORM bdc_field   USING 'RF05A-NEWKO' lv_hkont.
    PERFORM bdc_field   USING 'BDC_OKCODE' '=ENTE'.
*
    PERFORM bdc_dynpro  USING 'SAPMF05A'    '0300'.
    PERFORM bdc_field   USING 'BSEG-WRBTR'  '*'.
    PERFORM bdc_field   USING 'BSEG-MWSKZ'  'D0'.
    PERFORM bdc_field   USING 'BDC_OKCODE'  '/00'.
*
    PERFORM bdc_dynpro  USING 'SAPLKACB'    '0002'.
    PERFORM bdc_field   USING 'COBL-KOSTL'  lv_kostl.
    PERFORM bdc_field   USING 'BDC_OKCODE' '=ENTE'.
*
    PERFORM bdc_dynpro USING 'SAPMF05A'    '0330'.
    PERFORM bdc_field  USING 'BDC_OKCODE'  '=BU'.

  ENDIF.

ENDFORM.                    " PROCESAR_PA_Y
*-> END INS V1-CNN ECDK922573 Facturación el línea HELP


*&---------------------------------------------------------------------*
*&      Form  PROCESA_PROMOCION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM procesa_promocion USING p_importe.

  DATA l_importec(16) TYPE c.
  WRITE p_importe  TO l_importec CURRENCY 'CLP'.

* ****
  PERFORM bdc_dynpro      USING 'SAPMF05A' '0100'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'RF05A-NEWKO'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM bdc_field       USING 'BKPF-BLDAT'
                               wa_data-fecha_documento.
  PERFORM bdc_field       USING 'BKPF-BLART'
                                'SA'.
  PERFORM bdc_field       USING 'BKPF-BUKRS'
                                wa_data-sociedad.
  PERFORM bdc_field       USING 'BKPF-BUDAT'
                                wa_data-fecha_contable.
  PERFORM bdc_field       USING 'BKPF-MONAT'
                                wa_data-periodo.
  PERFORM bdc_field       USING 'BKPF-WAERS'
                                'CLP'.
  PERFORM bdc_field       USING 'BKPF-XBLNR'
                                wa_data-referencia.

  IF wa_data-texto_cabecera IS INITIAL.
    wa_data-texto_cabecera = 'PROC.RECAUDACIÓN'.
  ENDIF.
  PERFORM bdc_field       USING 'BKPF-BKTXT'
                                wa_data-texto_cabecera.
  PERFORM bdc_field       USING 'FS006-DOCID'
                                '*'.
  PERFORM bdc_field       USING 'RF05A-NEWBS'
                                '40'.
  PERFORM bdc_field       USING 'RF05A-NEWKO'
                                '4111180059'.
**---------------------------------------------
  PERFORM bdc_dynpro      USING 'SAPMF05A' '0300'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'RF05A-NEWKO'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM bdc_field       USING 'BSEG-WRBTR'
                                l_importec.
  PERFORM bdc_field       USING 'BSEG-ZUONR'
                                'GRATUIDAD'.
  PERFORM bdc_field       USING 'BSEG-SGTXT'
                                'GRATUIDAD'.
  PERFORM bdc_field       USING 'RF05A-NEWBS'
                                '50'.
  PERFORM bdc_field       USING 'RF05A-NEWKO'
                                '4111180060'.
  PERFORM bdc_field       USING 'DKACB-FMORE'
                                'X'.
**------------------------------------------------
  PERFORM bdc_dynpro      USING 'SAPLKACB' '0002'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'COBL-PRCTR'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=ENTE'.
  PERFORM bdc_field       USING 'COBL-KOSTL'
                                wa_data-centro_costo.
  PERFORM bdc_field       USING 'COBL-PRCTR'
                                wa_data-centro_benef.
**-------------------------------------------------
  PERFORM bdc_dynpro      USING 'SAPMF05A' '0300'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'BSEG-SGTXT'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM bdc_field       USING 'BSEG-WRBTR'
                                '*'.
  PERFORM bdc_field       USING 'BSEG-ZUONR'
                                'GRATUIDAD'.
  PERFORM bdc_field       USING 'BSEG-SGTXT'
                                'GRATUIDAD'.
  PERFORM bdc_field       USING 'DKACB-FMORE'
                                'X'.
**-------------------------------------------------
  PERFORM bdc_dynpro      USING 'SAPLKACB' '0002'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'COBL-PRCTR'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=ENTE'.
  PERFORM bdc_field       USING 'COBL-KOSTL'
                                wa_data-centro_costo.
  PERFORM bdc_field       USING 'COBL-AUFNR'
                                ''.
  PERFORM bdc_field       USING 'COBL-PRCTR'
                                wa_data-centro_benef.
**------------------------------------------------
  PERFORM bdc_dynpro      USING 'SAPMF05A' '0300'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'BSEG-WRBTR'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=BU'.
  PERFORM bdc_field       USING 'BSEG-WRBTR'
                                l_importec.
  PERFORM bdc_field       USING 'BSEG-ZUONR'
                                'GRATUIDAD'.
  PERFORM bdc_field       USING 'BSEG-SGTXT'
                                'GRATUIDAD'.
  PERFORM bdc_field       USING 'DKACB-FMORE'
                                'X'.
**-------------------------------------------------
  PERFORM bdc_dynpro      USING 'SAPLKACB' '0002'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'COBL-KOSTL'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=ENTE'.
  PERFORM bdc_field       USING 'COBL-KOSTL'
                                wa_data-centro_costo.
  PERFORM bdc_field       USING 'COBL-PRCTR'
                                wa_data-centro_benef.

  PERFORM call_transaction USING 'F-02'.
ENDFORM.                    " PROCESA_PROMOCION


*&---------------------------------------------------------------------*
*&      Form  GET_DOC_EVENTOS
*&---------------------------------------------------------------------*
FORM get_doc_eventos  USING  p_total.

  CLEAR: t_bsid.
  REFRESH: t_bsid.

  SELECT bukrs kunnr umsks umskz augdt augbl zuonr
         gjahr belnr buzei budat bschl bldat wrbtr
         vertn vertt rebzg
         zcod_rechazo
    INTO CORRESPONDING FIELDS OF TABLE t_bsid
  FROM bsid
  WHERE bukrs = wa_data-sociedad AND
      kunnr = l_kunnr AND
      bschl = '01' AND
      zuonr  = wa_data-evento.

  SORT t_bsid BY bldat gjahr belnr buzei ASCENDING.
  IF sy-subrc = 0.
    LOOP AT t_bsid INTO wa_bsid.
      p_total = p_total + wa_bsid-wrbtr.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " GET_DOC_EVENTOS


*&---------------------------------------------------------------------*
*&      Form  GET_DOC_CONTRATO
*&---------------------------------------------------------------------*
FORM get_doc_contrato  USING    p_total.
  DATA l_vertn(13).  " LIKE bsid-vertn.
  CLEAR t_bsid.
  REFRESH t_bsid.


  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'  " Sin ceros
    EXPORTING
      input  = wa_data-contrato
    IMPORTING
      output = l_vertn.

  SELECT
             bukrs
             kunnr
             umsks
             umskz
             augdt
             augbl
             zuonr
             gjahr
             belnr
             buzei
             budat
             bschl
             bldat
             wrbtr
             vertn
             vertt
             rebzg
             zcod_rechazo
    INTO CORRESPONDING FIELDS OF TABLE t_bsid
    FROM bsid
    WHERE bukrs = wa_data-sociedad AND
          kunnr = l_kunnr AND
*          ( bschl =  '01'  OR  bschl = '15' ) AND
          bschl = '01' AND
          vertn = l_vertn AND
          vertt = wa_data-clase_contrato.


*  if sy-subrc <> 0.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'  " pone ceros
    EXPORTING
      input  = wa_data-contrato
    IMPORTING
      output = l_vertn.
  SELECT
             bukrs
             kunnr
             umsks
             umskz
             augdt
             augbl
             zuonr
             gjahr
             belnr
             buzei
             budat
             bschl
             bldat
             wrbtr
             vertn
             vertt
             rebzg
             zcod_rechazo
    APPENDING CORRESPONDING FIELDS OF TABLE t_bsid
    FROM bsid
    WHERE bukrs = wa_data-sociedad AND
          kunnr = l_kunnr AND
          bschl = '01' AND
          vertn = l_vertn AND
          vertt = wa_data-clase_contrato.


  IF NOT t_bsid[] IS INITIAL.
    SORT t_bsid BY bldat gjahr belnr buzei ASCENDING.

    LOOP AT t_bsid INTO wa_bsid.
      p_total = p_total + wa_bsid-wrbtr.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " GET_DOC_CONTRATO


*&---------------------------------------------------------------------*
*&      Form  GET_DOC_CONTRATO_Y
*&---------------------------------------------------------------------*
FORM get_doc_contrato_y  USING    p_total.

  DATA l_vertn(13).

  CLEAR t_bsid.
  REFRESH t_bsid.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'  " Sin ceros
    EXPORTING
      input  = wa_data-contrato
    IMPORTING
      output = l_vertn.

  SELECT     bukrs
             kunnr
             umsks
             umskz
             augdt
             augbl
             zuonr
             gjahr
             belnr
             buzei
             budat
             bschl
             bldat
             wrbtr
             vertn
             vertt
             rebzg
             zcod_rechazo
    INTO CORRESPONDING FIELDS OF TABLE t_bsid
    FROM bsid
    WHERE bukrs = wa_data-sociedad         AND
          kunnr = l_kunnr                  AND
          bschl = '01'                     AND
          vertn = l_vertn                  AND
          vertt = wa_data-clase_contrato   AND
          xref1 = wa_data-cheque.


  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'  " pone ceros
    EXPORTING
      input  = wa_data-contrato
    IMPORTING
      output = l_vertn.

  SELECT     bukrs
             kunnr
             umsks
             umskz
             augdt
             augbl
             zuonr
             gjahr
             belnr
             buzei
             budat
             bschl
             bldat
             wrbtr
             vertn
             vertt
             rebzg
             zcod_rechazo
    APPENDING CORRESPONDING FIELDS OF TABLE t_bsid
    FROM bsid
    WHERE bukrs = wa_data-sociedad       AND
          kunnr = l_kunnr                AND
          bschl = '01'                   AND
          vertn = l_vertn                AND
          vertt = wa_data-clase_contrato AND
          xref1 = wa_data-cheque.


  IF NOT t_bsid[] IS INITIAL.
    SORT t_bsid BY bldat gjahr belnr buzei ASCENDING.

    LOOP AT t_bsid INTO wa_bsid.
      p_total = p_total + wa_bsid-wrbtr.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " GET_DOC_CONTRATO_Y


*&---------------------------------------------------------------------*
*&      Form  get_doc_dpp
*&---------------------------------------------------------------------*
FORM get_doc_dpp  USING    p_total.
**- Busca partidas abiertas del cliente
  CLEAR t_bsid.
  SELECT     bukrs
             kunnr
             umsks
             umskz
             augdt
             augbl
             zuonr
             gjahr
             belnr
             buzei
             budat
             bschl
             bldat
             wrbtr
             vertn
             vertt
             rebzg
             zcod_rechazo
    INTO CORRESPONDING FIELDS OF TABLE t_bsid
    FROM bsid
    WHERE bukrs = wa_data-sociedad AND
          kunnr = l_kunnr AND
          bschl = '01'
*         bschl = '09'    AND
*         umskz = 'D'     AND
    ORDER BY bldat ASCENDING.

  IF sy-subrc = 0.
    IF wa_data-forma_pago <> '003'.
      IF NOT wa_data-convenio IS INITIAL.
**-    { Begin -  datos adicionales 25.07.2013
*        DELETE t_bsid WHERE zzconvenio <> wa_data-convenio.
*        REFRESH ti_anex.
*        SELECT bukrs belnr gjahr buzei zzconve_dpp
*          INTO CORRESPONDING FIELDS OF TABLE ti_anex
*          FROM zfac_anex
*        FOR ALL ENTRIES IN t_bsid
*          WHERE bukrs = t_bsid-bukrs
*           AND belnr = t_bsid-belnr
*           AND gjahr = t_bsid-gjahr
*           AND buzei = t_bsid-buzei
*          AND zzconve_dpp <> wa_data-convenio.
*        IF sy-subrc = 0.
*          LOOP AT ti_anex INTO wa_anex .
*            DELETE t_bsid WHERE bukrs = wa_anex-bukrs
*               AND belnr = wa_anex-belnr
*               AND gjahr = wa_anex-gjahr
*               AND buzei = wa_anex-buzei.
*          ENDLOOP.
*        ENDIF.
**     End-  datos adicionales 25.07.2013 }
      ENDIF.
    ENDIF.
    LOOP AT t_bsid INTO wa_bsid.
      p_total = p_total + wa_bsid-wrbtr.
    ENDLOOP.
  ENDIF.

ENDFORM.                    "get_doc_dpp


*&---------------------------------------------------------------------*
*&      Form  ACTUALIZAR_RECHAZO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM actualizar_rechazo .
  DATA wa_zfirechzrec TYPE zfirechzrec.
  DATA ls_log LIKE LINE OF t_log.
  DATA l_total TYPE bsid-wrbtr.
  DATA l_vertn TYPE zfirechzrec-vertn.

  FIELD-SYMBOLS <fs_bsid> TYPE ty_bsid.

**-
  gs_total-rechaz      = gs_total-rechaz + 1.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = wa_data-contrato
    IMPORTING
      output = l_vertn.

  SELECT SINGLE mandt
                bukrs
                kunnr
                vertn
                wrbtr
                waers
                zfechrechz
                zmtvrechz
                zcontrechz
    INTO wa_zfirechzrec
    FROM zfirechzrec
    WHERE bukrs = wa_data-sociedad AND
          kunnr = l_kunnr AND
          vertn = l_vertn. " wa_data-contrato.

  IF sy-subrc <> 0." Crea registro
    wa_zfirechzrec-mandt = sy-mandt.
    wa_zfirechzrec-bukrs = wa_data-sociedad .
    wa_zfirechzrec-kunnr = l_kunnr.
    wa_zfirechzrec-vertn = l_vertn.
    wa_zfirechzrec-wrbtr = wa_data-importe / 100.
    wa_zfirechzrec-waers = 'CLP'.
    wa_zfirechzrec-zfechrechz = sy-datum.
    wa_zfirechzrec-zcontrechz = '001'.
    wa_zfirechzrec-zmtvrechz = wa_data-rechazo.
    INSERT zfirechzrec FROM wa_zfirechzrec.

  ELSE."Actualiza
    wa_zfirechzrec-wrbtr = wa_data-importe / 100.
    wa_zfirechzrec-zfechrechz = sy-datum.
    wa_zfirechzrec-zmtvrechz = wa_data-rechazo.
    wa_zfirechzrec-zcontrechz = wa_zfirechzrec-zcontrechz + 1.
    UPDATE zfirechzrec FROM wa_zfirechzrec.
  ENDIF.
  IF sy-subrc = 0.
    COMMIT WORK.
    CLEAR ls_log.
    ls_log-msgtyp = 'I'.
    ls_log-msgspra = sy-langu.
    ls_log-msgid = '00'.
    ls_log-msgnr = '001'.
    MOVE g_regindex TO ls_log-msgv1.
    ls_log-msgv2 = ' Tabla Rechazo actualizada'(027).
    APPEND ls_log TO t_log.

    PERFORM obtener_documentos USING l_total.
    IF t_bsid[] IS INITIAL.
      CLEAR ls_log.
      ls_log-msgtyp = 'W'.
      ls_log-msgspra = sy-langu.
      ls_log-msgid = '00'.
      ls_log-msgnr = '398'.
      CONDENSE g_regindex.
      CONCATENATE TEXT-031 g_regindex ':' INTO ls_log-msgv1
      SEPARATED BY space.
      ls_log-msgv2 = TEXT-037."'No existen PA para DPP'.
      APPEND ls_log TO t_log.
      EXIT.
    ELSE.

      LOOP AT t_bsid ASSIGNING <fs_bsid>.
        UPDATE bsid  SET zcod_rechazo = wa_data-rechazo
        WHERE bukrs = <fs_bsid>-bukrs AND
              kunnr = <fs_bsid>-kunnr AND
              umsks = <fs_bsid>-umsks AND
              umskz = <fs_bsid>-umskz AND
              augdt = <fs_bsid>-augdt AND
              augbl = <fs_bsid>-augbl AND
              zuonr = <fs_bsid>-zuonr AND
              gjahr = <fs_bsid>-gjahr AND
              belnr = <fs_bsid>-belnr AND
              buzei = <fs_bsid>-buzei.
        IF sy-subrc = 0.
          CLEAR ls_log.
          ls_log-msgtyp = 'I'.
          ls_log-msgspra = sy-langu.
          ls_log-msgid = '00'.
          ls_log-msgnr = '001'.
          MOVE g_regindex TO ls_log-msgv1.
          ls_log-msgv2 = ' PA Rechazo actualizadas con exito'(023).
          APPEND ls_log TO t_log.
        ELSE.
          CLEAR ls_log.
          ls_log-msgtyp = 'E'.
          ls_log-msgspra = sy-langu.
          ls_log-msgid = '00'.
          ls_log-msgnr = '001'.
          MOVE g_regindex TO ls_log-msgv1.
          ls_log-msgv2 = ' Error al actualizar PA Rechazo'(024).
          APPEND ls_log TO t_log.
          gs_total-error = gs_total-error + 1.
        ENDIF.
      ENDLOOP.
      COMMIT WORK.
    ENDIF.
  ELSE.
    ROLLBACK WORK.                                     "#EC CI_ROLLBACK
    CLEAR ls_log.
    ls_log-msgtyp = 'E'.
    ls_log-msgspra = sy-langu.
    ls_log-msgid = '00'.
    ls_log-msgnr = '001'.
    MOVE g_regindex TO ls_log-msgv2.
    ls_log-msgv1 = 'Error al actualizar rechazo(zfirechzrec)'(025).
    APPEND ls_log TO t_log.
    gs_total-error = gs_total-error + 1.
  ENDIF.

ENDFORM.                    " ACTUALIZAR_RECHAZO


*&---------------------------------------------------------------------*
*&      Form  PROCESA_CAMBIO_CHEQUE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*

FORM procesa_cambio_cheque  USING    p_importe.

  DATA l_importec(16) TYPE c.
*
  WRITE p_importe  TO l_importec CURRENCY 'CLP'.


  PERFORM bdc_dynpro      USING 'SAPMF05A'     '0122'.
  PERFORM bdc_field       USING 'BDC_CURSOR'   'RF05A-NEWUM'.
  PERFORM bdc_field       USING 'BDC_OKCODE'   '/00'.
  PERFORM bdc_field       USING 'BKPF-BLDAT'   wa_data-fecha_documento.
  PERFORM bdc_field       USING 'BKPF-BLART'   wa_data-clase_documento.
  PERFORM bdc_field       USING 'BKPF-BUKRS'   wa_data-sociedad.
  PERFORM bdc_field       USING 'BKPF-BUDAT'   wa_data-fecha_contable.
  PERFORM bdc_field       USING 'BKPF-MONAT'   wa_data-periodo.
  PERFORM bdc_field       USING 'BKPF-WAERS'  'CLP'.
  PERFORM bdc_field       USING 'BKPF-XBLNR'   wa_data-referencia.

  IF wa_data-texto_cabecera IS INITIAL.
    wa_data-texto_cabecera = 'PROC.RECAUDACIÓN'.
  ENDIF.
  PERFORM bdc_field       USING 'BKPF-BKTXT'
                                wa_data-texto_cabecera.
  PERFORM bdc_field       USING 'FS006-DOCID'
                                '*'.
  IF wa_data-cuenta_contable IS INITIAL.
    PERFORM bdc_field       USING 'RF05A-NEWBS'
                                  '09'.
    PERFORM bdc_field       USING 'RF05A-NEWUM'
                              '5'.
  ELSE.
    PERFORM bdc_field       USING 'RF05A-NEWBS'
                            '05'.
    PERFORM bdc_field       USING 'RF05A-NEWUM'
                            ' '.
  ENDIF.
  PERFORM bdc_field       USING 'RF05A-NEWKO'
                                l_kunnr.

  PERFORM bdc_field       USING 'RF05A-XPOS1(01)'
                                ' '.
  PERFORM bdc_field       USING 'RF05A-XPOS1(04)'
  "Trasalado Compensación
                                 'X'.
**-------------------------------------------------------------
  PERFORM bdc_dynpro      USING 'SAPMF05A' '2320'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'BSEG-ZLSCH'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=SL'.
  PERFORM bdc_field       USING 'BSEG-WRBTR'
                                l_importec.
  IF wa_data-cuenta_contable IS INITIAL.
    PERFORM bdc_field       USING 'BSEG-ZUONR'
                                  wa_data-cheque.
    PERFORM bdc_field       USING 'BSEG-SGTXT'
                                  'cambio cheque'.
    PERFORM bdc_field       USING 'BSEG-ZFBDT'
                                  wa_data-fecha_vencto.
    PERFORM bdc_field       USING 'BSED-WDATE'
                                  wa_data-fecha_emision.
    PERFORM bdc_field       USING 'BSEG-ZLSCH'
                                  'A'. "Via de Pago
    PERFORM bdc_field       USING 'BSED-WNAME'
                                  'HELP S.A.'.
    PERFORM bdc_field       USING 'BSED-WORT1'
                                  ''.
    PERFORM bdc_field       USING 'BSED-REGIO'
                                  '13'.
    PERFORM bdc_field       USING 'BSED-WBZOG'
                                  ' '."'NOMBRE'.
    PERFORM bdc_field       USING 'BSED-WORT2'
                                  ' '."'SANTIAGO'.
    PERFORM bdc_field       USING 'BSEC-BANKL'
                                  wa_data-banco.            "'037'.
    PERFORM bdc_field       USING 'BSEC-BANKN'
                                  wa_data-nro_cta_cte_cli.
    PERFORM bdc_field       USING 'BSEC-BANKS'
                                  wa_data-pais_banco."'cl'.
  ELSE.
    PERFORM bdc_field       USING 'BSEG-VALUT'
                              wa_data-fecha_valor.
*  PERFORM bdc_field        USING 'BSEG-ZUONR'
*                                 ' '." 'OPCIONAL'.
*    PERFORM bdc_field       USING 'BSEG-ZUONR' '0'. "WAJ 12-10-2021
    PERFORM bdc_field       USING 'BSEG-SGTXT'
                                  'cambio cheque'.
  ENDIF.
**--------------------------------------------------------------------
**Seleccionar PA por Importe
  PERFORM bdc_dynpro      USING 'SAPMF05A' '0710'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'RF05A-AGUMS'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM bdc_field       USING 'RF05A-AGBUK'
                                wa_data-sociedad.
  PERFORM bdc_field       USING 'RF05A-AGKON'
                                l_kunnr.
  PERFORM bdc_field       USING 'RF05A-AGKOA'
                                'D'.
  PERFORM bdc_field       USING 'RF05A-AGUMS'
                                '5'.
  PERFORM bdc_field       USING 'RF05A-XNOPS'
                                'X'.
  PERFORM bdc_field       USING 'RF05A-XPOS1(01)'
                                ''.
  PERFORM bdc_field       USING 'RF05A-XPOS1(02)' "Importe
                                'X'.
**-------------------------------------------------------------------
  PERFORM bdc_dynpro      USING 'SAPMF05A' '0730'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'RF05A-VONWT(01)'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM bdc_field       USING 'RF05A-VONWT(01)'
                                l_importec.
**----------------------------------------------------
  PERFORM bdc_dynpro      USING 'SAPMF05A' '0730'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'RF05A-VONWT(01)'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '/00'.
**-----------------------------------------------------
  PERFORM bdc_dynpro      USING 'SAPMF05A' '0730'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'RF05A-VONWT(01)'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=PA'.
**--------------------------------------------------------
  PERFORM bdc_dynpro      USING 'SAPDF05X' '3100'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=BU'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'RF05A-ABPOS'.
  PERFORM bdc_field       USING 'RF05A-ABPOS'
                                '1'.
  PERFORM call_transaction USING 'F-30'.

ENDFORM.                    " PROCESA_CAMBIO_CHEQUE
*&---------------------------------------------------------------------*
*&      Form  OBTENER_CODIGO_CLIENTE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_WA_DATA_RUT_CLIENTE  text
*      <--P_L_STCD1  text
*----------------------------------------------------------------------*
FORM obtener_codigo_cliente  USING    p_rut
                             CHANGING p_kunnr.
  DATA l_stcd1 TYPE kna1-stcd1.
  DATA off TYPE i.

  CATCH SYSTEM-EXCEPTIONS data_access_errors  = 4
                          OTHERS = 8.
    off = strlen( p_rut ) - 1.
    CONCATENATE p_rut(off) '-' p_rut+off(1) INTO l_stcd1.
  ENDCATCH.
  IF sy-subrc = 0.
    SELECT  kunnr
      INTO p_kunnr
      FROM kna1 UP TO 1 ROWS
       WHERE stcd1 = l_stcd1.
    ENDSELECT.                                              "#EC *
  ENDIF.
ENDFORM.                    " OBTENER_CODIGO_CLIENTE
*&---------------------------------------------------------------------*
*&      Form  PROCESA_ANTICIPO
*&---------------------------------------------------------------------*
FORM procesa_anticipo  USING    p_importe TYPE bsid-wrbtr.
  DATA l_importec(16) TYPE c.
  DATA l_fechac(10) TYPE c.
*
  CLEAR lv_evento.
*
  WRITE p_importe  TO l_importec CURRENCY 'CLP'.

  PERFORM bdc_dynpro      USING 'SAPMF05A'    '0122'.
  PERFORM bdc_field       USING 'BDC_CURSOR'  'RF05A-NEWKO'.
  PERFORM bdc_field       USING 'BDC_OKCODE'  '/00'.
  PERFORM bdc_field       USING 'BKPF-BLDAT'  wa_data-fecha_documento.
  PERFORM bdc_field       USING 'BKPF-BLART'  wa_data-clase_documento.
  PERFORM bdc_field       USING 'BKPF-BUKRS'  wa_data-sociedad.
  PERFORM bdc_field       USING 'BKPF-BUDAT'  wa_data-fecha_contable.
  PERFORM bdc_field       USING 'BKPF-MONAT'  wa_data-periodo.
  PERFORM bdc_field       USING 'BKPF-WAERS'  'CLP'.
  PERFORM bdc_field       USING 'BKPF-XBLNR'  wa_data-referencia.
  IF wa_data-forma_pago = '016'.
    PERFORM bdc_field       USING 'BKPF-BKTXT' wa_data-contrato.
  ELSE.
    PERFORM bdc_field       USING 'BKPF-BKTXT' wa_data-texto_cabecera.
  ENDIF.

  PERFORM bdc_field       USING 'FS006-DOCID'  '*'.
  CASE wa_data-forma_pago.
    WHEN '016'.
***primer asiento
      PERFORM bdc_field     USING 'RF05A-NEWBS'  '09'.
      PERFORM bdc_field     USING 'RF05A-NEWUM'  '5'.
      PERFORM bdc_field     USING 'RF05A-NEWKO'  l_kunnr."1011123651'.
**  ----------------------------------------------
      PERFORM bdc_dynpro    USING 'SAPMF05A'    '2320'.
      PERFORM bdc_field     USING 'BDC_OKCODE'  '/00'.
      PERFORM bdc_field     USING 'BSEG-WRBTR'  l_importec.
      PERFORM bdc_field     USING 'BSEG-ZUONR'  wa_data-cheque .
      PERFORM bdc_field     USING 'BSEG-SGTXT' 'ANTICIPO CHEQUE A FECHA'.
      PERFORM bdc_field     USING 'BSEG-ZFBDT' wa_data-fecha_vencto.
      PERFORM bdc_field     USING 'BSED-WDATE' wa_data-fecha_emision.
      PERFORM bdc_field     USING 'BSEG-ZLSCH' wa_data-via_pago_sap."'A'.
      PERFORM bdc_field     USING 'BSEC-BANKL' wa_data-banco. "'037'.
      PERFORM bdc_field     USING 'BSEC-BANKN' wa_data-nro_cta_cte_cli.
      PERFORM bdc_field     USING 'BSED-WBANK' ''.
      PERFORM bdc_field     USING 'BSEC-BANKS' wa_data-pais_banco."'CL'.

***segundo asiento
      PERFORM bdc_field     USING 'RF05A-NEWBS'	'19'.
      PERFORM bdc_field     USING 'RF05A-NEWKO'	l_kunnr.
      PERFORM bdc_field     USING 'RF05A-NEWUM' 'A'.

      PERFORM bdc_dynpro    USING 'SAPMF05A'   '0304'.
      PERFORM bdc_field     USING 'BDC_OKCODE' '=BU'.
      PERFORM bdc_field     USING 'BSEG-WRBTR' l_importec.
*     PERFORM bdc_field     USING 'BSEG-ZUONR' '0'. "WAJ 12-10-2021
      PERFORM bdc_field     USING 'BSEG-ZFBDT' wa_data-fecha_vencto.
      PERFORM bdc_field     USING 'BSEG-VERTN' wa_data-contrato.
      PERFORM bdc_field     USING 'BSEG-VERTT' 'A'.
      PERFORM bdc_field     USING 'BSEG-ZLSCH' wa_data-via_pago_sap.
      PERFORM bdc_field     USING 'BSEG-SGTXT' 'ANTICIPO CHEQUE A FECHA'.
      PERFORM call_transaction USING 'F-30'.
    WHEN '003'.
***primer asiento
      PERFORM bdc_field     USING 'RF05A-XPOS1(02)' 'X'.
      PERFORM bdc_field     USING 'RF05A-NEWBS'     '19'.
      PERFORM bdc_field     USING 'RF05A-NEWUM'     'A'.
      PERFORM bdc_field     USING 'RF05A-NEWKO'     l_kunnr.
**  ----------------------------------------------
      PERFORM bdc_dynpro    USING 'SAPMF05A'        '0304'.
      PERFORM bdc_field     USING 'BDC_OKCODE'      '/00'.
      PERFORM bdc_field     USING 'BSEG-WRBTR' l_importec.
      PERFORM bdc_field     USING 'BSEG-ZFBDT' wa_data-fecha_vencto.
      PERFORM bdc_field     USING 'BSEG-ZLSCH' wa_data-via_pago_sap.
      PERFORM bdc_field     USING 'BSEG-VERTN' wa_data-contrato.
      PERFORM bdc_field     USING 'BSEG-VERTT' 'A'.
      IF wa_data-sgtxt IS NOT INITIAL.
        PERFORM bdc_field     USING 'BSEG-SGTXT' wa_data-sgtxt.
      ELSE.
        PERFORM bdc_field     USING 'BSEG-SGTXT' 'ANTICIPO POR RECAUDACION'.
      ENDIF.
      PERFORM bdc_field     USING 'RF05A-NEWBS'	'04'.
      PERFORM bdc_field     USING 'RF05A-NEWKO'	l_kunnr_dpp.
***segundo asiento
      PERFORM bdc_dynpro    USING 'SAPMF05A'   '0301'.
      PERFORM bdc_field     USING 'BDC_OKCODE' '=BU'.
      PERFORM bdc_field     USING 'BSEG-WRBTR' l_importec.
      PERFORM bdc_field     USING 'BSEG-MWSKZ' '**'.
      PERFORM bdc_field     USING 'BSEG-VERTN' wa_data-contrato.
      PERFORM bdc_field     USING 'BSEG-VERTT' 'A'.
      PERFORM bdc_field     USING 'BSEG-ZFBDT' wa_data-fecha_vencto.
      IF wa_data-sgtxt IS NOT INITIAL.
        PERFORM bdc_field     USING 'BSEG-SGTXT' wa_data-sgtxt.
      ELSE.
        PERFORM bdc_field     USING 'BSEG-SGTXT' 'ANTICIPO POR RECAUDACION'.
      ENDIF.
      PERFORM call_transaction USING 'F-30'.
*-> BEG INS V1-CNN ECDK922573 Facturación el línea HELP
    WHEN '019'.
*     Cuenta contable
      PERFORM bdc_field     USING 'RF05A-NEWBS'  '40'.
      PERFORM bdc_field     USING 'RF05A-NEWKO'  wa_data-cuenta_contable.
*     A anticipo cliente
      PERFORM bdc_dynpro    USING 'SAPMF05A'     '0300'.
      PERFORM bdc_field     USING 'BSEG-VALUT'   wa_data-fecha_valor.
      PERFORM bdc_field     USING 'BSEG-WRBTR'   l_importec.
      IF NOT wa_data-evento IS INITIAL.
        PERFORM bdc_field     USING 'BSEG-ZUONR'  wa_data-evento.
        MOVE wa_data-evento   TO lv_evento.
      ENDIF.
      PERFORM bdc_field     USING 'BSEG-SGTXT'   'ANTICIPO POR RECAUDACION'.
      PERFORM bdc_field     USING 'RF05A-NEWBS'  '19'.
      PERFORM bdc_field     USING 'RF05A-NEWKO'  l_kunnr.
      PERFORM bdc_field     USING 'RF05A-NEWUM'  'A'.
      PERFORM bdc_field     USING 'DKACB-FMORE'  'X'.
      PERFORM bdc_field     USING 'BDC_OKCODE'   '/00'.
*
      PERFORM bdc_dynpro    USING 'SAPLKACB'     '0002'.
      PERFORM bdc_field     USING 'BDC_CURSOR'   'COBL-PRCTR'.
      PERFORM bdc_field     USING 'BDC_OKCODE'   '=ENTE'.
*
      PERFORM bdc_dynpro    USING 'SAPMF05A'   '0304'.
      PERFORM bdc_field     USING 'BDC_CURSOR'   'BSEG-SGTXT'.
      PERFORM bdc_field     USING 'BSEG-WRBTR'   l_importec.
      WRITE sy-datum TO l_fechac.
      PERFORM bdc_field     USING 'BSEG-ZFBDT'    l_fechac.
      PERFORM bdc_field     USING 'BSEG-VERTN'    wa_data-contrato.
      PERFORM bdc_field     USING 'BSEG-VERTT'   'Y'.
      IF NOT wa_data-evento IS INITIAL.
        PERFORM bdc_field     USING 'BSEG-ZUONR'  wa_data-evento.
        MOVE wa_data-evento   TO lv_evento.
      ENDIF.
      PERFORM bdc_field     USING 'BSEG-SGTXT'
                                    'ANTICIPO POR RECAUDACION'.
      PERFORM bdc_field     USING 'BDC_OKCODE'   '=ZK'.
*
      PERFORM bdc_dynpro    USING 'SAPMF05A'     '0331'.
      PERFORM bdc_field     USING 'BSEG-XREF1'   wa_data-cheque.
      PERFORM bdc_field     USING 'BDC_OKCODE'   '=BU'.

      PERFORM call_transaction USING 'F-30'.
*-> END INS V1-CNN ECDK922573 Facturación el línea HELP
    WHEN OTHERS.
      PERFORM bdc_field     USING 'RF05A-NEWBS' '40'.
      PERFORM bdc_field     USING 'RF05A-NEWKO' wa_data-cuenta_contable.
**---------------------------------------------------
      PERFORM bdc_dynpro    USING 'SAPMF05A'    '0300'.
      PERFORM bdc_field     USING 'BDC_CURSOR'  'RF05A-NEWUM'.
      PERFORM bdc_field     USING 'BDC_OKCODE'  '/00'.
      PERFORM bdc_field     USING 'BSEG-WRBTR'  l_importec.
      PERFORM bdc_field     USING 'BSEG-VALUT'  wa_data-fecha_valor.
      IF wa_data-evento IS INITIAL.
*       PERFORM bdc_field     USING 'BSEG-ZUONR'  'OPCIONAL'.
*        PERFORM bdc_field     USING 'BSEG-ZUONR' '0'. "WAJ 12-10-2021
      ELSE.
        PERFORM bdc_field     USING 'BSEG-ZUONR'  wa_data-evento.
        MOVE wa_data-evento   TO lv_evento.
      ENDIF.
      PERFORM bdc_field     USING 'BSEG-SGTXT' 'ANTICIPO POR RECAUDACION'.
      PERFORM bdc_field     USING 'RF05A-NEWBS'  '19'.
      PERFORM bdc_field     USING 'RF05A-NEWKO'  l_kunnr.
      IF NOT wa_data-convenio IS INITIAL.                "V1-CNN ECDK912798
        PERFORM bdc_field     USING 'RF05A-NEWUM'  'D'.  "V1-CNN ECDK912798
      ELSE.                                              "V1-CNN ECDK912798
        PERFORM bdc_field     USING 'RF05A-NEWUM'  'A'.
      ENDIF.                                             "V1-CNN ECDK912798
      PERFORM bdc_field     USING 'DKACB-FMORE'  'X'.
**---------------------------------------------------
      PERFORM bdc_dynpro    USING 'SAPLKACB'     '0002'.
      PERFORM bdc_field     USING 'BDC_CURSOR'   'COBL-PRCTR'.
      PERFORM bdc_field     USING 'BDC_OKCODE'   '=ENTE'.
**----------------------------------------------
      IF NOT wa_data-convenio IS INITIAL.                "V1-CNN ECDK912798
        PERFORM bdc_dynpro    USING 'SAPMF05A'   '0303'. "V1-CNN ECDK912798
      ELSE.                                              "V1-CNN ECDK912798
        PERFORM bdc_dynpro    USING 'SAPMF05A'   '0304'.
      ENDIF.                                             "V1-CNN ECDK912798
      PERFORM bdc_field     USING 'BDC_CURSOR'   'BSEG-SGTXT'.
      PERFORM bdc_field     USING 'BDC_OKCODE'   '=BU'.
      PERFORM bdc_field     USING 'BSEG-WRBTR'   l_importec.
      WRITE sy-datum TO l_fechac.
      PERFORM bdc_field     USING 'BSEG-ZFBDT'   l_fechac.
      PERFORM bdc_field     USING 'BSEG-VERTN'   wa_data-contrato.
      PERFORM bdc_field     USING 'BSEG-VERTT'   'A'.
      IF wa_data-evento IS INITIAL.
*       PERFORM bdc_field     USING 'BSEG-ZUONR'  'OPCIONAL'.
*        PERFORM bdc_field     USING 'BSEG-ZUONR' '0'. "WAJ 12-10-2021
      ELSE.
        PERFORM bdc_field     USING 'BSEG-ZUONR'  wa_data-evento.
        MOVE wa_data-evento   TO lv_evento.
      ENDIF.
      PERFORM bdc_field     USING 'BSEG-SGTXT'
                                    'ANTICIPO POR RECAUDACION'.

      PERFORM call_transaction USING 'F-30'.
  ENDCASE.
ENDFORM.                    " PROCESA_ANTICIPO
*&---------------------------------------------------------------------*
*&      Form  TOTALES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM totales .
  DATA ls_messtab LIKE LINE OF messtab.
*
**-- Leidos
  ls_messtab-msgv1 = 'Total Registros Leidos:'(011).
  CLEAR ls_messtab.
  ls_messtab-msgtyp = 'I'.
  ls_messtab-msgspra = sy-langu.
  ls_messtab-msgid = '00'.
  ls_messtab-msgnr = '001'.
  WRITE gs_total-leidos TO ls_messtab-msgv2.
  CONDENSE ls_messtab-msgv2.
  APPEND ls_messtab TO t_log.
**-- Contabilizados
  ls_messtab-msgv1 = 'Total Registros Contabilizados:'(012).
  WRITE gs_total-contab TO ls_messtab-msgv2.
  CONDENSE ls_messtab-msgv2.
  APPEND ls_messtab TO t_log.
**-- c/rechazo
  ls_messtab-msgv1 = 'Total Registros con Rechazos:'(013).
  WRITE gs_total-rechaz TO ls_messtab-msgv2.
  CONDENSE ls_messtab-msgv2.
  APPEND ls_messtab TO t_log.
**-- Con error
  ls_messtab-msgv1 = 'Total Registros con Error:'(016).
  WRITE gs_total-error TO ls_messtab-msgv2.
  CONDENSE ls_messtab-msgv2.
  APPEND ls_messtab TO t_log.
**-- Total monto recaudado
  ls_messtab-msgv1 = 'Total Monto en archivo Recaudado: $'(015).
  WRITE gs_total-monto CURRENCY 'CLP' TO ls_messtab-msgv2.
  CONDENSE ls_messtab-msgv2.
  APPEND ls_messtab TO t_log.
**-- Total Monto Rechazo
  ls_messtab-msgv1 = 'Total Monto Rechazo: $'(017).
  WRITE gs_total-monto_recha CURRENCY 'CLP' TO ls_messtab-msgv2.
  CONDENSE ls_messtab-msgv2.
  APPEND ls_messtab TO t_log.
**-- Total Monto  Sin Rechazo
  ls_messtab-msgv1 = 'Total Monto S/N Rechazo: $'(018).
  WRITE gs_total-monto_sn_recha CURRENCY 'CLP' TO ls_messtab-msgv2.
  CONDENSE ls_messtab-msgv2.
  APPEND ls_messtab TO t_log.
*
ENDFORM.                    " TOTALES
*&---------------------------------------------------------------------*
*&      Form  ACTUALIZAR_DOC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*

FORM actualizar_doc  USING    p_bukrs TYPE bukrs
                              p_belnr TYPE belnr_d
                              p_gjahr TYPE gjahr.

  DATA: it_bkpf TYPE TABLE OF bkpf,
        it_bseg TYPE TABLE OF bseg,
        it_bsec TYPE TABLE OF bsec,
        it_bkdf TYPE TABLE OF bkdf,
        it_bset TYPE TABLE OF bset,
        it_bsed TYPE TABLE OF bsed.

  FIELD-SYMBOLS: <fs> TYPE bseg.

  SELECT *
    INTO TABLE it_bkpf
    FROM bkpf
    WHERE bukrs = p_bukrs
      AND belnr = p_belnr
      AND gjahr = p_gjahr.

  SELECT *
  INTO TABLE it_bseg
  FROM bseg
  WHERE bukrs = p_bukrs
  AND belnr = p_belnr
*Begin of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 24/12/2019 EY_DES04 ECDK917080 *
*AND gjahr = p_gjahr.
  AND gjahr = p_gjahr ORDER BY PRIMARY KEY.
*End of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 24/12/2019 EY_DES04 ECDK917080 *

  SELECT *
  INTO TABLE it_bset
  FROM bset
  WHERE bukrs = p_bukrs
  AND belnr = p_belnr
*Begin of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 24/12/2019 EY_DES04 ECDK917080 *
*AND gjahr = p_gjahr.
  AND gjahr = p_gjahr ORDER BY PRIMARY KEY.
*End of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 24/12/2019 EY_DES04 ECDK917080 *

  SELECT *
  INTO TABLE it_bsed
  FROM bsed
  WHERE bukrs = p_bukrs
  AND belnr = p_belnr
*Begin of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 24/12/2019 EY_DES04 ECDK917080 *
*AND gjahr = p_gjahr.
  AND gjahr = p_gjahr ORDER BY PRIMARY KEY.
*End of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 24/12/2019 EY_DES04 ECDK917080 *

  SELECT *
  INTO TABLE it_bsec
  FROM bsec
  WHERE bukrs = p_bukrs
  AND belnr = p_belnr
*Begin of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 24/12/2019 EY_DES04 ECDK917080 *
*AND gjahr = p_gjahr.
  AND gjahr = p_gjahr ORDER BY PRIMARY KEY.
*End of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 24/12/2019 EY_DES04 ECDK917080 *

  SELECT *
    INTO TABLE it_bkdf
    FROM bkdf
    WHERE bukrs = p_bukrs
      AND belnr = p_belnr
      AND gjahr = p_gjahr.

* LOOP AT it_bseg ASSIGNING <fs> WHERE koart = 'D'.
  LOOP AT it_bseg ASSIGNING <fs>.
    IF <fs>-koart = 'D'.
       <fs>-xref2 = wa_data-id_proceso.
* INI Waldo Alarcón - Visionone - 12-10-2021
* INI RVY 17-10-23
**    IF <fs>-zuonr IS NOT INITIAL AND <fs>-zuonr NE lv_evento.
      IF <fs>-zuonr IS NOT INITIAL AND <fs>-zuonr NE lv_evento and
         <fs>-umskz <> '5'.
        CLEAR <fs>-zuonr.
      ENDIF.
* FIN Waldo Alarcón - Visionone - 12-10-2021
    ENDIF.
*
    IF NOT wa_data-sgtxt IS INITIAL.
      <fs>-sgtxt = wa_data-sgtxt.
    ENDIF.
  ENDLOOP.

  CALL FUNCTION 'CHANGE_DOCUMENT'
    TABLES
      t_bkdf = it_bkdf
      t_bkpf = it_bkpf
      t_bsec = it_bsec
      t_bsed = it_bsed
      t_bseg = it_bseg
      t_bset = it_bset.

  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
    EXPORTING
      wait = 'X'.

ENDFORM.                    " ACTUALIZAR_DOC

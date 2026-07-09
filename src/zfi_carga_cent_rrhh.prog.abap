*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION >                                      *
*& Author: < EY_DES04 >                                                *
*& Description: < ReSQ Correction >                                    *
*& Date: <24-12-2019>                                                  *
*& Transport Number: < ECDK917080 >                                    *
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
* Nombre Programa : ZFI_CARGA_CENT_RRHH                                *
* Descripción     : Carga una centralizacion de RRHH y genera una      *
*                   contabilización                                    *
*----------------------------------------------------------------------*
* Objetivo        :
*----------------------------------------------------------------------*
* Creado por      : VIsionOne.                                         *
* Creado en fecha : 19.02.2013                                         *
*----------------------------------------------------------------------*
REPORT  zfi_carga_cent_rrhh LINE-SIZE 250.
* Tablas y estructuras de transferencia para docs. contables.
* -----------------------------------------------------------
TABLES: bgr00,                         " Registro de juego de datos
        bbkpf,                         " Datos de cabecera BTCI
        bbseg, " Datos de segmento de doc. (incl. datos CpD, datos COBL)
        d020s. " Tabla de sistema D020S (sources de dynpro)

* Definición de variables y tablas internas.
* ------------------------------------------
FIELD-SYMBOLS <f>.
DATA:
*FICHERO   LIKE RLGRAP-FILENAME,
  cont(3)     TYPE n VALUE 0,
  cont_cab(3) TYPE n VALUE 0,
  cierre      VALUE 'F'.

TYPES: BEGIN OF gty_reg_entrada,
         id_nomina           TYPE char10,
         fecha_fin           TYPE char08,
         codigo_empresa      TYPE char10,
         fecha_pago          TYPE char08,
         id_centro_costo     TYPE char20,
         id_tercero          TYPE char20,
         nombre_tercero      TYPE char100,
         id_empleado         TYPE char20,
         nombre_empleado     TYPE char100,
         id_afp              TYPE char20,
         nombre_afp          TYPE char100,
         id_isapre           TYPE char20,
         nombre_isapre       TYPE char100,
         categoria           TYPE char20,
         banco_propio        TYPE char20,
         tipo_cancelacion    TYPE char20,
         fecha_vencimiento   TYPE char08,
         fecha_contable      TYPE char08,
         cuenta_contable_sap TYPE char20,
         imputacion          TYPE char01,
         producto            TYPE char20,
         codigo_concepto     TYPE char20,
         nombre_concepto     TYPE char40,
         valor               TYPE char28,
         fecha_finiquito     TYPE char08,
       END OF gty_reg_entrada.

TYPES: gtt_reg_entrada  TYPE STANDARD TABLE OF gty_reg_entrada.
TYPES: gtt2_reg_entrada TYPE STANDARD TABLE OF gty_reg_entrada.

DATA: gt_reg_entrada   TYPE gtt_reg_entrada.
DATA: gt2_reg_entrada  TYPE gtt_reg_entrada.
DATA: gt3_reg_entrada  TYPE gtt_reg_entrada.
DATA: lg_reg_entrada   TYPE gty_reg_entrada.
DATA: lg2_reg_entrada  TYPE gty_reg_entrada.

DATA: jobcount    LIKE tbtcjob-jobcount,
      jobname(32) TYPE c,
      l_datum     LIKE sy-datum,
      l_uzeit     LIKE sy-uzeit,
      l_hora_prev LIKE sy-uzeit,
      strtimmed   LIKE btch0000-char1,
      tit_job(30) TYPE c.

DATA: wa_header     TYPE bapiache09,
      ti_currency   TYPE TABLE OF bapiaccr09,
      wa_currency   TYPE bapiaccr09,
      ti_accountgl  TYPE TABLE OF bapiacgl09,
      wa_accountgl  TYPE bapiacgl09,
      ti_payable    TYPE TABLE OF bapiacap09,
      wa_payable    TYPE bapiacap09,
      ti_deudor     TYPE TABLE OF bapiacar09,
      wa_deudor     TYPE bapiacar09,
      ti_extension1 TYPE TABLE OF bapiacextc,
      wa_extension1 TYPE bapiacextc,
      ti_return     TYPE TABLE OF bapiret2,
      wa_return     TYPE bapiret2,
      wa_total_doc  TYPE bseg-dmbtr,
      wa_total_doch TYPE bseg-dmbtr,
      wa_total_docd TYPE bseg-dmbtr,
      wa_doc_compen TYPE bsad-augbl,
      wa_xref2_hd   TYPE bkpf-xref2_hd,
      wa_emision    TYPE bseg-zzmot_emis,
      wa_agencia    TYPE bseg-zz_agencia,
      wa_rut_terc   TYPE bseg-zzrut_terc,
      wa_prestacion TYPE bseg-zzprestac,
      wa_unid_pro   TYPE bseg-zzunid_pro,
      wa_desc_est   TYPE bseg-zzdesc_est,
      wa_xref1      TYPE bseg-xref1,
      wa_xref2      TYPE bseg-xref2,
      wa_zzunid_pro TYPE bseg-zzunid_pro,
      wa_zfpago     TYPE zfitr031-zfpago,
      wa_zgposi     TYPE zfitr031-zgposi,
      wa_zvalor(1)  TYPE c,
      wa_zlsch      TYPE bseg-zlsch,
      wa_hbkid      TYPE bseg-hbkid,
      wa_stcd1      TYPE lfa1-stcd1,
      wa_fecha_pago TYPE bseg-valut,
*     wa_nom_arch   TYPE bkpf-xblnr.
      wa_nom_arch   TYPE bkpf-BKTXT.
DATA: objtype TYPE bapiache09-obj_type,
      objkey  TYPE bapiache09-obj_key,
      objsys  TYPE bapiache09-obj_sys,
      conta   TYPE i.

DATA:   bdcdata LIKE bdcdata    OCCURS 0 WITH HEADER LINE.
*       messages of call transaction
DATA:   messtab LIKE bdcmsgcoll OCCURS 0 WITH HEADER LINE.
*       error session opened (' ' or 'X')
DATA:   e_group_opened.

DATA: ctumode TYPE c VALUE 'N',
      cupdate TYPE c VALUE 'L'.

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

DATA: ti_log TYPE TABLE OF t_balmi,
      wa_log TYPE t_balmi.
DATA lg_cod_lifnr    TYPE lfa1-lifnr.
DATA lg_cod_kunnr    TYPE kna1-kunnr.

*DATA t_reg_entrada-belnr1.

* Definición de Parámetros.
* -------------------------
SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE TEXT-001.

PARAMETERS: p_local RADIOBUTTON GROUP a1 DEFAULT 'X' USER-COMMAND cmd,
            p_serv  RADIOBUTTON GROUP a1.
SELECTION-SCREEN END   OF BLOCK bl1.

SELECTION-SCREEN BEGIN OF BLOCK bl2 WITH FRAME TITLE TEXT-001.
PARAMETERS:    fichero  LIKE rlgrap-filename MODIF ID a1
              DEFAULT 'C:\',
               servidor LIKE rlgrap-filename MODIF ID b1
                          DEFAULT '/usr/sap/tmp' .
PARAMETERS: p_bukrs TYPE bukrs MODIF ID b1.
SELECTION-SCREEN END   OF BLOCK bl2.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR fichero.
  CALL FUNCTION 'WS_FILENAME_GET'
    EXPORTING
      def_filename     = fichero
      def_path         = 'c:\'
      mask             = ',*.*,*.*.'
      mode             = 'O'
      title            = 'Directorio de Datos'
    IMPORTING
      filename         = fichero
    EXCEPTIONS
      inv_winsys       = 01
      no_batch         = 02
      selection_cancel = 03
      selection_error  = 04.


AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    IF screen-group1 EQ 'A1'.
      IF NOT p_local IS INITIAL.
        screen-active = 1.
      ELSE.
        screen-active = 0.
      ENDIF.
    ELSEIF screen-group1 EQ 'B1'.
      IF NOT p_local IS INITIAL.
        screen-active = 0.
      ELSE.
        screen-active = 1.
      ENDIF.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.


**---------------------------------------------------------------------
**- Inicio Programa Principal -----------------------------------------
**---------------------------------------------------------------------
START-OF-SELECTION.
* -> Tratamiento Archivo de Entrada
  IF NOT p_local IS INITIAL AND fichero IS INITIAL.
    MESSAGE s398(00) WITH 'Favor ingresar fichero' DISPLAY LIKE 'E'.
    EXIT.
  ELSEIF NOT p_serv IS INITIAL AND servidor IS INITIAL.
    MESSAGE s398(00) WITH 'Favor ingresar fichero' DISPLAY LIKE 'E'.
    EXIT.
  ELSEIF NOT p_serv IS INITIAL.
    IF p_bukrs IS INITIAL.
      MESSAGE s398(00) WITH 'Favor ingresar sociedad' DISPLAY LIKE 'E'.
      EXIT.
    ELSE.
      FIND FIRST OCCURRENCE OF p_bukrs IN servidor.
      IF sy-subrc <> 0.
        MESSAGE s398(00) WITH 'El nombre del fichero debe contener el codigo de la sociedad' DISPLAY LIKE 'E'.
        EXIT.
      ENDIF.
    ENDIF.
  ENDIF.

  PERFORM input_local.
  IF wa_nom_arch+0(1) = 'C'.
     IF wa_nom_arch+2(1) = 'R' OR wa_nom_arch+2(1) = 'F' OR
        wa_nom_arch+2(1) = 'N'.
        PERFORM validaciones_basicas.
        wa_total_doc = wa_total_docd - wa_total_doch.
        IF wa_total_doc NE 0.
           CLEAR wa_log.
           wa_log-msgty = 'E'.
           wa_log-msgid = '00'.
           wa_log-msgno = '398'.
           wa_log-msgv1 = 'Archivo descuadrado. Saldo al Debe no es igual al Saldo al Haber.'.
           wa_log-msgv2 = wa_return-message_v2.
           wa_log-msgv3 = wa_return-message_v3.
           wa_log-msgv4 = wa_return-message_v4.
           APPEND wa_log TO ti_log.
        ENDIF.
     ELSE.
        CLEAR wa_log.
        wa_log-msgty = 'E'.
        wa_log-msgid = '00'.
        wa_log-msgno = '398'.
        wa_log-msgv1 = 'Estructura de nombre de archivo no VALIDO'.
        wa_log-msgv2 = wa_return-message_v2.
        wa_log-msgv3 = wa_return-message_v3.
        wa_log-msgv4 = wa_return-message_v4.
        APPEND wa_log TO ti_log.
     ENDIF.
  ELSE.
     CLEAR wa_log.
     wa_log-msgty = 'E'.
     wa_log-msgid = '00'.
     wa_log-msgno = '398'.
     wa_log-msgv1 = 'Estructura de nombre de archivo no VALIDO'.
     wa_log-msgv2 = wa_return-message_v2.
     wa_log-msgv3 = wa_return-message_v3.
     wa_log-msgv4 = wa_return-message_v4.
     APPEND wa_log TO ti_log.
  ENDIF.
  wa_total_doc = 0.

  IF NOT ti_log[] IS INITIAL.
    PERFORM mostrar_log.
  ELSE.
    perform sum_x_RUT_ctas_balance.
    PERFORM armar_datos.
    IF NOT ti_log[] IS INITIAL.
      PERFORM mostrar_log.
    ENDIF.
  ENDIF.

*** -> Subrutinas (FORM)
***-----------------------------------------------------------------***
***-- Inicio Subrutinas --------------------------------------------***
***-----------------------------------------------------------------***

*---------------------------------------------------------------------*
*       FORM INIT_NODATA                                              *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  TABLA                                                         *
*---------------------------------------------------------------------*
FORM init_nodata USING tabla.
  DATA: c_acumu TYPE i.
  DO.
    ADD 1 TO c_acumu.
    ASSIGN COMPONENT c_acumu OF STRUCTURE tabla TO <f>.
    IF sy-subrc NE 0. EXIT. ENDIF.
    MOVE '/' TO <f>.
  ENDDO.
ENDFORM.                    "INIT_NODATA

*---------------------------------------------------------------------*
*       FORM CHECK_FIELD                                              *
*---------------------------------------------------------------------*
FORM check_field.



ENDFORM.                    "CHECK_FIELD

*&---------------------------------------------------------------------*
*&      Form  input_local
*&---------------------------------------------------------------------*
FORM input_local .

  TYPES: BEGIN OF lty_reg_leido,
           informacion TYPE c LENGTH 800,
         END OF lty_reg_leido.

  TYPES: ltt_reg_leido TYPE STANDARD TABLE OF lty_reg_leido.

  DATA: ls_reg_leido   TYPE lty_reg_leido,
        ls_reg_entrada TYPE gty_reg_entrada.

  DATA: lt_reg_leido TYPE ltt_reg_leido.

  DATA: lv_strarq TYPE string,
        lv_cadena TYPE c LENGTH 800.

  IF NOT p_local IS INITIAL.

    lv_strarq = fichero.

    CALL FUNCTION 'SO_SPLIT_FILE_AND_PATH'
      EXPORTING
        full_name     = lv_strarq
      IMPORTING
        stripped_name = wa_nom_arch
      EXCEPTIONS
        x_error       = 1
        OTHERS        = 2.

    CALL FUNCTION 'GUI_UPLOAD'
      EXPORTING
        filename                = lv_strarq
        filetype                = 'ASC'
        has_field_separator     = 'X'
      TABLES
        data_tab                = lt_reg_leido
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
        OTHERS                  = 17.

    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    LOOP AT lt_reg_leido INTO ls_reg_leido.
      SPLIT ls_reg_leido-informacion AT ';'
       INTO ls_reg_entrada-id_nomina
            ls_reg_entrada-fecha_fin
            ls_reg_entrada-codigo_empresa
            ls_reg_entrada-fecha_pago
            ls_reg_entrada-id_centro_costo
            ls_reg_entrada-id_tercero
            ls_reg_entrada-nombre_tercero
            ls_reg_entrada-id_empleado
            ls_reg_entrada-nombre_empleado
            ls_reg_entrada-id_afp
            ls_reg_entrada-nombre_afp
            ls_reg_entrada-id_isapre
            ls_reg_entrada-nombre_isapre
            ls_reg_entrada-categoria
            ls_reg_entrada-banco_propio
            ls_reg_entrada-tipo_cancelacion
            ls_reg_entrada-fecha_vencimiento
            ls_reg_entrada-fecha_contable
            ls_reg_entrada-cuenta_contable_sap
            ls_reg_entrada-imputacion
            ls_reg_entrada-producto
            ls_reg_entrada-codigo_concepto
            ls_reg_entrada-nombre_concepto
            ls_reg_entrada-valor
            ls_reg_entrada-fecha_finiquito.
      APPEND ls_reg_entrada TO gt_reg_entrada.
    ENDLOOP.
  ELSE.
    lv_strarq = servidor.
    DATA: tab TYPE c.
    tab = cl_abap_char_utilities=>horizontal_tab.
    OPEN DATASET lv_strarq FOR INPUT ENCODING DEFAULT IN TEXT MODE.
    IF sy-subrc EQ 0.
      DO.
        READ DATASET lv_strarq INTO lv_cadena.
        IF sy-subrc EQ 0.
          CLEAR: ls_reg_entrada.
          SPLIT lv_cadena AT tab
       INTO ls_reg_entrada-id_nomina
            ls_reg_entrada-fecha_fin
            ls_reg_entrada-codigo_empresa
            ls_reg_entrada-fecha_pago
            ls_reg_entrada-id_centro_costo
            ls_reg_entrada-id_tercero
            ls_reg_entrada-nombre_tercero
            ls_reg_entrada-id_empleado
            ls_reg_entrada-nombre_empleado
            ls_reg_entrada-id_afp
            ls_reg_entrada-nombre_afp
            ls_reg_entrada-id_isapre
            ls_reg_entrada-nombre_isapre
            ls_reg_entrada-categoria
            ls_reg_entrada-banco_propio
            ls_reg_entrada-tipo_cancelacion
            ls_reg_entrada-fecha_vencimiento
            ls_reg_entrada-fecha_contable
            ls_reg_entrada-cuenta_contable_sap
            ls_reg_entrada-imputacion
            ls_reg_entrada-producto
            ls_reg_entrada-codigo_concepto
            ls_reg_entrada-nombre_concepto
            ls_reg_entrada-valor
            ls_reg_entrada-fecha_finiquito.
          APPEND ls_reg_entrada TO gt_reg_entrada.
        ELSE.
          EXIT.
        ENDIF.
      ENDDO.
    ELSE.
      MESSAGE e398(00) WITH
      'No se encuentra archivo en la ruta indicada'.
    ENDIF.
  ENDIF.
ENDFORM.                    " input_local

FORM validaciones_basicas.
*&---------------------------------------------------------------------*
*&      Form  validaciones_basicas.
*&---------------------------------------------------------------------*
  DATA: lt_mitkz               TYPE skb1-mitkz.
  DATA: lt_datbi               TYPE csks-datbi.
  DATA: lt_hkont               TYPE bseg-hkont.
  DATA: lt_kostl               TYPE bseg-kostl.
  DATA: lt_belnr               TYPE bkpf-belnr.
  DATA: lt_nomb_conce          TYPE char40.
  DATA: lt_reg_leido(4)        TYPE n VALUE 0.
  DATA: lt_cc(1)               TYPE n VALUE 0.
** V1 RVY 03-06-2024
* DATA: lt_currency_tot        TYPE i.
  DATA: lt_currency_tot        TYPE int8.
*
  SORT gt_reg_entrada ASCENDING BY cuenta_contable_sap id_centro_costo
                                   nombre_concepto .

  READ TABLE gt_reg_entrada INTO lg_reg_entrada INDEX 1.
  AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
     ID 'BUKRS' FIELD lg_reg_entrada-codigo_empresa.

  IF sy-subrc NE 0.
    CLEAR wa_log.
    wa_log-msgty = 'E'.
    wa_log-msgid = '00'.
    wa_log-msgno = '398'.
    CONCATENATE 'No esta autorizado para procesar archivos de la sociedad '
                'lg_reg_entrada-codigo_empres' INTO wa_log-msgv1.
    wa_log-msgv2 = wa_return-message_v2.
    wa_log-msgv3 = wa_return-message_v3.
    wa_log-msgv4 = wa_return-message_v4.
    APPEND wa_log TO ti_log.
  ELSE.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE belnr
*                INTO lt_belnr
*                FROM bkpf
*                WHERE bukrs EQ wa_nom_arch+4(4)  and
*                      blart EQ 'RH'              and
*                      bktxt EQ wa_nom_arch+0(25) and
*                      STBLG EQ ' '.
*
* NEW CODE
    SELECT belnr
    UP TO 1 ROWS 
                INTO lt_belnr
                FROM bkpf
                WHERE bukrs EQ wa_nom_arch+4(4)  and
                      blart EQ 'RH'              and
                      bktxt EQ wa_nom_arch+0(25) and
                      STBLG EQ ' ' ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    IF sy-subrc EQ 0.
       CLEAR wa_log.
       wa_log-msgty = 'E'.
       wa_log-msgid = '00'.
       wa_log-msgno = '398'.
       CONCATENATE 'Proceso: ' wa_nom_arch+0(25) ' ya Existe '
                    INTO wa_log-msgv1.
       CONCATENATE 'Sociedad: ' wa_nom_arch+4(4) ' Docto.: ' lt_belnr
                    INTO wa_log-msgv2.
       wa_log-msgv3 = wa_return-message_v3.
       wa_log-msgv4 = wa_return-message_v4.
       APPEND wa_log TO ti_log.
    else.
     LOOP AT gt_reg_entrada INTO lg_reg_entrada.
      lt_reg_leido = lt_reg_leido + 1.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE mitkz INTO lt_mitkz
*                    FROM  skb1
*                    WHERE bukrs = lg_reg_entrada-codigo_empresa AND
*                          saknr = lg_reg_entrada-cuenta_contable_sap.
*
* NEW CODE
      SELECT mitkz
      UP TO 1 ROWS  INTO lt_mitkz
                    FROM  skb1
                    WHERE bukrs = lg_reg_entrada-codigo_empresa AND
                          saknr = lg_reg_entrada-cuenta_contable_sap ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
      IF sy-subrc NE 0.
        CLEAR wa_log.
        wa_log-msgty = 'E'.
        wa_log-msgid = '00'.
        wa_log-msgno = '398'.
        CONCATENATE 'Cuenta Mayor: ' lg_reg_entrada-cuenta_contable_sap
                    ' No EXISTE' INTO wa_log-msgv1.
        CONCATENATE ' En posición: ' lt_reg_leido INTO wa_log-msgv2.
        wa_log-msgv3 = wa_return-message_v3.
        wa_log-msgv4 = wa_return-message_v4.
        APPEND wa_log TO ti_log.
      ENDIF.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE zvalor zzrut_terc xref1 zzprestac
*                    ZZDESC_EST xref2 zzunid_pro zlsch
*                    zz_agencia zzmot_emis hbkid zfpago zgposi
*             INTO  (wa_zvalor, wa_rut_terc, wa_xref1, wa_prestacion,
*                    wa_desc_est, wa_xref2, wa_zzunid_pro, wa_zlsch,
*                    wa_agencia, wa_emision, wa_hbkid, wa_zfpago, wa_zgposi)
*             FROM   zfitr031
*             WHERE bukrs  = lg_reg_entrada-codigo_empresa    AND
*                   hkont  = lg_reg_entrada-cuenta_contable_sap.
*
* NEW CODE
      SELECT zvalor zzrut_terc xref1 zzprestac
                    ZZDESC_EST xref2 zzunid_pro zlsch
                    zz_agencia zzmot_emis hbkid zfpago zgposi
      UP TO 1 ROWS 
             INTO  (wa_zvalor, wa_rut_terc, wa_xref1, wa_prestacion,
                    wa_desc_est, wa_xref2, wa_zzunid_pro, wa_zlsch,
                    wa_agencia, wa_emision, wa_hbkid, wa_zfpago, wa_zgposi)
             FROM   zfitr031
             WHERE bukrs  = lg_reg_entrada-codigo_empresa    AND
                   hkont  = lg_reg_entrada-cuenta_contable_sap ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

      IF sy-subrc NE 0.
        CLEAR wa_log.
        wa_log-msgty = 'E'.
        wa_log-msgid = '00'.
        wa_log-msgno = '398'.
        CONCATENATE 'Sociedad/Cuenta Mayor: ' lg_reg_entrada-codigo_empresa
                    '/'  lg_reg_entrada-cuenta_contable_sap
                    ' No EXISTE en Tabla ZFITR031' INTO wa_log-msgv1.
        CONCATENATE ' En posición: ' lt_reg_leido INTO wa_log-msgv2.
        wa_log-msgv3 = wa_return-message_v3.
        wa_log-msgv4 = wa_return-message_v4.
        APPEND wa_log TO ti_log.
      ENDIF.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE datbi INTO lt_datbi
*             FROM csks
*             WHERE kostl EQ lg_reg_entrada-id_centro_costo.
*
* NEW CODE
      SELECT datbi
      UP TO 1 ROWS  INTO lt_datbi
             FROM csks
             WHERE kostl EQ lg_reg_entrada-id_centro_costo ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

      IF sy-subrc NE 0.
        CLEAR wa_log.
        wa_log-msgty = 'E'.
        wa_log-msgid = '00'.
        wa_log-msgno = '398'.
        CONCATENATE 'Centro Costo: ' lg_reg_entrada-id_centro_costo
                    ' No EXISTE' INTO wa_log-msgv1.
        CONCATENATE ' En posición: ' lt_reg_leido INTO wa_log-msgv2.
        wa_log-msgv3 = wa_return-message_v3.
        wa_log-msgv4 = wa_return-message_v4.
        APPEND wa_log TO ti_log.
      ENDIF.

      wa_currency-amt_doccur = lg_reg_entrada-valor.
      IF lg_reg_entrada-imputacion EQ 'H'.
        wa_total_doch          = wa_total_doch + wa_currency-amt_doccur.
        wa_currency-amt_doccur = wa_currency-amt_doccur * -1.
      ELSE.
        wa_total_docd = wa_total_docd + wa_currency-amt_doccur.
      ENDIF.

      IF lg_reg_entrada-cuenta_contable_sap > '7000000000'.
        IF lt_cc = 0.
          MOVE lg_reg_entrada                     TO lg2_reg_entrada.
          MOVE lg_reg_entrada-cuenta_contable_sap TO lt_hkont.
          MOVE lg_reg_entrada-id_centro_costo     TO lt_kostl.
          MOVE lg_reg_entrada-id_centro_costo     TO lt_kostl.
          Move lg_reg_entrada-nombre_concepto     TO lt_nomb_conce.
          MOVE 1                                  TO lt_cc.
          MOVE wa_currency-amt_doccur             TO lt_currency_tot.
        ELSE.
          IF lg_reg_entrada-cuenta_contable_sap = lt_hkont.
            IF lg_reg_entrada-id_centro_costo  = lt_kostl and
               lg_reg_entrada-nombre_concepto = lt_nomb_conce.
               lt_currency_tot = lt_currency_tot + wa_currency-amt_doccur.
            else.
              lg2_reg_entrada-id_empleado = ' '.
              IF lt_currency_tot > 0.
                lg2_reg_entrada-valor       = lt_currency_tot.
                lg2_reg_entrada-imputacion  = 'D'.
              ELSE.
                lg2_reg_entrada-valor       = lt_currency_tot * -1.
                lg2_reg_entrada-imputacion  = 'H'.
              ENDIF.
              APPEND lg2_reg_entrada TO gt2_reg_entrada.
              MOVE lg_reg_entrada-id_centro_costo TO lt_kostl.
              Move lg_reg_entrada-nombre_concepto TO lt_nomb_conce.
              MOVE wa_currency-amt_doccur         TO lt_currency_tot.
              MOVE lg_reg_entrada                 TO lg2_reg_entrada.
            ENDIF.
          ELSE.
            lg2_reg_entrada-id_empleado = ' '.
            IF lt_currency_tot > 0.
              lg2_reg_entrada-valor       = lt_currency_tot.
              lg2_reg_entrada-imputacion  = 'D'.
            ELSE.
              lg2_reg_entrada-valor       = lt_currency_tot * -1.
              lg2_reg_entrada-imputacion  = 'H'.
            ENDIF.
            APPEND lg2_reg_entrada TO gt2_reg_entrada.
            MOVE lg_reg_entrada-id_centro_costo     TO lt_kostl.
            MOVE lg_reg_entrada-cuenta_contable_sap TO lt_hkont.
            Move lg_reg_entrada-nombre_concepto     TO lt_nomb_conce.
            MOVE wa_currency-amt_doccur             TO lt_currency_tot.
            MOVE lg_reg_entrada                     TO lg2_reg_entrada.
          ENDIF.
        ENDIF.
      ELSE.
         IF lt_currency_tot > 0.
            lg2_reg_entrada-id_empleado = ' '.
            lg2_reg_entrada-valor       = lt_currency_tot.
            lg2_reg_entrada-imputacion  = 'D'.
            APPEND lg2_reg_entrada TO gt2_reg_entrada.
            clear lg2_reg_entrada.
            move 0 to lt_currency_tot.
         ELSE.
            IF lt_currency_tot < 0.
               lg2_reg_entrada-id_empleado = ' '.
               lg2_reg_entrada-valor       = lt_currency_tot * -1.
               lg2_reg_entrada-imputacion  = 'H'.
               APPEND lg2_reg_entrada TO gt2_reg_entrada.
               clear lg2_reg_entrada.
               move 0 to lt_currency_tot.
            ENDIF.
         ENDIF.
         IF wa_zvalor = '1'.
            wa_stcd1 = lg_reg_entrada-id_tercero.
         ELSE.
         IF wa_zvalor = '2'.
            wa_stcd1 = lg_reg_entrada-id_afp.
         ELSE.
         IF wa_zvalor = '3'.
            wa_stcd1 = lg_reg_entrada-id_isapre.
         ELSE.
         IF wa_zvalor = '4'.
            IF wa_nom_arch+2(1) = 'N'.
               wa_stcd1 = lg_reg_entrada-id_empleado.
            ELSE.
               wa_stcd1 = '301-8'.
            ENDIF.
         ELSE.
         IF wa_zvalor = '5'.
            wa_stcd1 = lg_reg_entrada-id_empleado.
         ELSE.
            wa_stcd1 = space.
         ENDIF.
         ENDIF.
         ENDIF.
         ENDIF.
         ENDIF.
         MOVE lg_reg_entrada   to lg2_reg_entrada.
         MOVE space            to lg2_reg_entrada-id_afp.
         MOVE space            to lg2_reg_entrada-id_isapre.
         MOVE space            to lg2_reg_entrada-id_empleado.
         MOVE wa_stcd1         to lg2_reg_entrada-id_tercero.
         APPEND lg2_reg_entrada TO gt2_reg_entrada.
         clear lg2_reg_entrada.
      ENDIF.
     ENDLOOP.
    endif.

    IF lt_currency_tot <> 0.
       IF lg2_reg_entrada-cuenta_contable_sap > '7000000000'.
          lg2_reg_entrada-id_empleado = ' '.
       ENDIF.
       IF lt_currency_tot > 0.
          lg2_reg_entrada-valor       = lt_currency_tot.
          lg2_reg_entrada-imputacion  = 'D'.
       ELSE.
          lg2_reg_entrada-valor       = lt_currency_tot * -1.
          lg2_reg_entrada-imputacion  = 'H'.
       ENDIF.
       APPEND lg2_reg_entrada TO gt2_reg_entrada.
    ENDIF.
  ENDIF.
ENDFORM.                    " validaciones_basicas

*&---------------------------------------------------------------------*
*&      Form  sum_x_RUT_ctas_balance
*&---------------------------------------------------------------------*
FORM sum_x_RUT_ctas_balance.
  DATA: lt_hkont               TYPE bseg-hkont.
  DATA: lt_id_tercero          TYPE char20.
  DATA: lt_nomb_conce          TYPE char40.
  DATA: lt_reg_leido(4)        TYPE n VALUE 0.
  DATA: lt_cc(1)               TYPE n VALUE 0.
** V1 RVY 03-06-2024
*  DATA: lt_currency_tot        TYPE i.
  DATA: lt_currency_tot        TYPE int8.

  SORT gt2_reg_entrada ASCENDING BY cuenta_contable_sap id_tercero
                                    nombre_concepto.
  wa_total_doch = 0.
  wa_total_docd = 0.

  LOOP AT gt2_reg_entrada INTO lg_reg_entrada.
     IF lg_reg_entrada-cuenta_contable_sap <> ' '.
        wa_currency-amt_doccur = lg_reg_entrada-valor.
        IF lg_reg_entrada-imputacion EQ 'H'.
           wa_total_doch          = wa_total_doch + wa_currency-amt_doccur.
           wa_currency-amt_doccur = wa_currency-amt_doccur * -1.
        ELSE.
           wa_total_docd = wa_total_docd + wa_currency-amt_doccur.
        ENDIF.

        IF lg_reg_entrada-cuenta_contable_sap <  '7000000000'.
           IF lt_cc = 0.
              MOVE lg_reg_entrada                     TO lg2_reg_entrada.
              MOVE lg_reg_entrada-cuenta_contable_sap TO lt_hkont.
              MOVE lg_reg_entrada-id_tercero          TO lt_id_tercero.
              MOVE lg_reg_entrada-nombre_concepto     TO lt_nomb_conce.
              MOVE 1                                  TO lt_cc.
              MOVE wa_currency-amt_doccur             TO lt_currency_tot.
           ELSE.
              IF lg_reg_entrada-cuenta_contable_sap = lt_hkont.
                 IF lg_reg_entrada-id_tercero = ' '.
                    IF lg_reg_entrada-nombre_concepto = lt_nomb_conce.
                       lt_currency_tot = lt_currency_tot + wa_currency-amt_doccur.
                    ELSE.
                       IF lt_currency_tot > 0.
                          lg2_reg_entrada-valor       = lt_currency_tot.
                          lg2_reg_entrada-imputacion  = 'D'.
                       ELSE.
                          lg2_reg_entrada-valor       = lt_currency_tot * -1.
                          lg2_reg_entrada-imputacion  = 'H'.
                       ENDIF.
                       APPEND lg2_reg_entrada              TO gt3_reg_entrada.
                       MOVE lg_reg_entrada-id_tercero      TO lt_id_tercero.
                       MOVE lg_reg_entrada-nombre_concepto TO lt_nomb_conce.
                       MOVE wa_currency-amt_doccur         TO lt_currency_tot.
                       MOVE lg_reg_entrada                 TO lg2_reg_entrada.
                    endif.
                 ELSE.
                    IF lg_reg_entrada-id_tercero       = lt_Id_tercero.
                       lt_currency_tot = lt_currency_tot + wa_currency-amt_doccur.
                    ELSE.
                       IF lt_currency_tot > 0.
                          lg2_reg_entrada-valor       = lt_currency_tot.
                          lg2_reg_entrada-imputacion  = 'D'.
                       ELSE.
                          lg2_reg_entrada-valor       = lt_currency_tot * -1.
                          lg2_reg_entrada-imputacion  = 'H'.
                       ENDIF.
                       APPEND lg2_reg_entrada              TO gt3_reg_entrada.
                       MOVE lg_reg_entrada-id_tercero      TO lt_id_tercero.
                       MOVE lg_reg_entrada-nombre_concepto TO lt_nomb_conce.
                       MOVE wa_currency-amt_doccur         TO lt_currency_tot.
                       MOVE lg_reg_entrada                 TO lg2_reg_entrada.
                    ENDIF.
                  endif.
              ELSE.
                 IF lt_currency_tot > 0.
                    lg2_reg_entrada-valor       = lt_currency_tot.
                    lg2_reg_entrada-imputacion  = 'D'.
                 ELSE.
                    lg2_reg_entrada-valor       = lt_currency_tot * -1.
                    lg2_reg_entrada-imputacion  = 'H'.
                 ENDIF.
                 APPEND lg2_reg_entrada                  TO gt3_reg_entrada.
                 MOVE lg_reg_entrada-id_tercero          TO lt_id_tercero.
                 MOVE lg_reg_entrada-cuenta_contable_sap TO lt_hkont.
                 MOVE lg_reg_entrada-nombre_concepto     TO lt_nomb_conce.
                 MOVE wa_currency-amt_doccur             TO lt_currency_tot.
                 MOVE lg_reg_entrada                     TO lg2_reg_entrada.
              ENDIF.
           endif.
        else.
           APPEND lg_reg_entrada TO gt3_reg_entrada.
        endif.
     endif.
  ENDLOOP.

  IF lt_currency_tot <> 0.
     IF lg2_reg_entrada-cuenta_contable_sap > '7000000000' OR
        lg2_reg_entrada-id_empleado = ' '.
     ENDIF.
     IF lt_currency_tot > 0.
        lg2_reg_entrada-valor       = lt_currency_tot.
        lg2_reg_entrada-imputacion  = 'D'.
     ELSE.
        lg2_reg_entrada-valor       = lt_currency_tot * -1.
        lg2_reg_entrada-imputacion  = 'H'.
     ENDIF.
     APPEND lg2_reg_entrada TO gt3_reg_entrada.
  ENDIF.

ENDFORM.                    " sum_x_RUT_ctas_balance

*&---------------------------------------------------------------------*
*&      Form  ARMAR_DATOS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
**----------------------------------------------------------------------*
FORM armar_datos .
  DATA: indicador    TYPE tbsl-shkzg.
  DATA: lt_reg_1     TYPE i.
  DATA: lt_mitkz     TYPE skb1-mitkz.
  DATA: ls_reg_entrada TYPE gty_reg_entrada.

  lt_reg_1 = 0.

  LOOP AT gt3_reg_entrada INTO lg_reg_entrada.

    IF lt_reg_1 = 0.
       lt_reg_1 = 1.
       wa_total_doc = 0.
       PERFORM cabecera.
    ENDIF.

    CLEAR wa_stcd1.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE zvalor zzrut_terc xref1 zzprestac
*                    ZZDESC_EST xref2 zzunid_pro zlsch
*                    zz_agencia zzmot_emis hbkid zfpago zgposi
*             INTO  (wa_zvalor, wa_rut_terc, wa_xref1, wa_prestacion,
*                    wa_desc_est, wa_xref2, wa_zzunid_pro, wa_zlsch,
*                    wa_agencia, wa_emision, wa_hbkid, wa_zfpago, wa_zgposi)
*           FROM   zfitr031
*           WHERE bukrs  = wa_header-comp_code            AND
*                 hkont  = lg_reg_entrada-cuenta_contable_sap.
*
* NEW CODE
      SELECT zvalor zzrut_terc xref1 zzprestac
                    ZZDESC_EST xref2 zzunid_pro zlsch
                    zz_agencia zzmot_emis hbkid zfpago zgposi
      UP TO 1 ROWS 
             INTO  (wa_zvalor, wa_rut_terc, wa_xref1, wa_prestacion,
                    wa_desc_est, wa_xref2, wa_zzunid_pro, wa_zlsch,
                    wa_agencia, wa_emision, wa_hbkid, wa_zfpago, wa_zgposi)
           FROM   zfitr031
           WHERE bukrs  = wa_header-comp_code            AND
                 hkont  = lg_reg_entrada-cuenta_contable_sap ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

    ADD 1 TO conta.
***tipo de cuenta
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE mitkz INTO lt_mitkz
*                  FROM  skb1
*                  WHERE bukrs = wa_header-comp_code AND
*                        saknr = lg_reg_entrada-cuenta_contable_sap.
*
* NEW CODE
    SELECT mitkz
    UP TO 1 ROWS  INTO lt_mitkz
                  FROM  skb1
                  WHERE bukrs = wa_header-comp_code AND
                        saknr = lg_reg_entrada-cuenta_contable_sap ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    IF sy-subrc EQ 0.
       IF lt_mitkz = ' '.
          PERFORM account_gl USING conta.
       ELSE.
*         move lg_reg_entrada-id_empleado to wa_stcd1.
          Translate lg_reg_entrada-id_tercero to upper case.
          move lg_reg_entrada-id_tercero      to wa_stcd1.
          IF lt_mitkz = 'K'.
             CLEAR lg_cod_lifnr.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*             SELECT SINGLE lifnr
*                INTO lg_cod_lifnr
*                FROM lfa1
*                WHERE stcd1 EQ wa_stcd1.
*
* NEW CODE
             SELECT lifnr
             UP TO 1 ROWS 
                INTO lg_cod_lifnr
                FROM lfa1
                WHERE stcd1 EQ wa_stcd1 ORDER BY PRIMARY KEY.

             ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
             IF wa_stcd1 <> ' '.
                IF sy-subrc EQ 0.
                   PERFORM acreedor USING conta.
                ELSE.
                   CLEAR wa_log.
                   wa_log-msgty = 'E'.
                   wa_log-msgid = '00'.
                   wa_log-msgno = '398'.
*         wa_log-msgv1 = wa_return-message_v1.
                   CONCATENATE 'Acredor-RUT: ' wa_stcd1 ' No EXISTE'
                          INTO wa_log-msgv1.
                   wa_log-msgv2 = wa_return-message_v2.
                   wa_log-msgv3 = wa_return-message_v3.
                   wa_log-msgv4 = wa_return-message_v4.
                   APPEND wa_log TO ti_log.
                ENDIF.
             else.
                CLEAR wa_log.
                wa_log-msgty = 'E'.
                wa_log-msgid = '00'.
                wa_log-msgno = '398'.
*         wa_log-msgv1 = wa_return-message_v1.
                CONCATENATE 'la cuenta: ' lg_reg_entrada-cuenta_contable_sap
                            ' Tipo RUT: ' wa_zvalor ' en En Blanco'
                       INTO wa_log-msgv1.
                wa_log-msgv2 = wa_return-message_v2.
                wa_log-msgv3 = wa_return-message_v3.
                wa_log-msgv4 = wa_return-message_v4.
                APPEND wa_log TO ti_log.
             ENDIF.
          ELSE.
             CLEAR lg_cod_kunnr.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*             SELECT SINGLE kunnr
*                INTO lg_cod_kunnr
*                FROM kna1
*                WHERE stcd1 EQ wa_stcd1.
*
* NEW CODE
             SELECT kunnr
             UP TO 1 ROWS 
                INTO lg_cod_kunnr
                FROM kna1
                WHERE stcd1 EQ wa_stcd1 ORDER BY PRIMARY KEY.

             ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
             IF sy-subrc EQ 0.
                PERFORM deudor USING conta.
             ELSE.
                CLEAR wa_log.
                wa_log-msgty = 'E'.
                wa_log-msgid = '00'.
                wa_log-msgno = '398'.
*     wa_log-msgv1 = wa_return-message_v1.
                CONCATENATE 'DEUDOR-RUT: ' wa_stcd1 ' No EXISTE'
                       INTO wa_log-msgv1.
                wa_log-msgv2 = wa_return-message_v2.
                wa_log-msgv3 = wa_return-message_v3.
                wa_log-msgv4 = wa_return-message_v4.
                APPEND wa_log TO ti_log.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    indicador = lg_reg_entrada-imputacion.
    PERFORM currency USING conta indicador.

    IF wa_rut_terc = 'ID_EMPLEAD'.
       If wa_zvalor = '5'.
          wa_stcd1 = lg_reg_entrada-id_tercero.
       else.
          wa_stcd1 = lg_reg_entrada-id_empleado.
       endif.
    else.
      If wa_zvalor = '4'.
         wa_stcd1 = wa_rut_terc.
      endif.
    endif.

    PERFORM extension USING conta
*                            lg_reg_entrada-ID_TERCERO.
                             wa_stcd1
*                                  t_reg_entrada-newbs
                             wa_prestacion
                             wa_zzunid_pro
                             wa_desc_est
                             wa_emision
                             wa_agencia.

    IF conta > 950.
      PERFORM account_gl_900 USING conta.
      PERFORM currency_900   USING conta.
      PERFORM bapi_post.
      PERFORM cabecera.
      conta = 0.
      PERFORM account_gl_900 USING conta.
      PERFORM currency_900_r USING conta.
    ENDIF.
  ENDLOOP.

  PERFORM bapi_post.

ENDFORM.                    " ARMAR_DATOS

*&---------------------------------------------------------------------*
*&      Form  BAPI_POST
*&---------------------------------------------------------------------*
FORM bapi_post.
  CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST' "#EC CI_USAGE_OK[2438131]
    EXPORTING
      documentheader    = wa_header
    IMPORTING
      obj_type          = objtype
      obj_key           = objkey
      obj_sys           = objsys
    TABLES
      accountgl         = ti_accountgl
      accountreceivable = ti_deudor
      accountpayable    = ti_payable
      currencyamount    = ti_currency
      extension1        = ti_extension1
      return            = ti_return.

  CLEAR conta.
  conta = strlen( objkey ).
  IF conta >= 18.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.
    READ TABLE ti_return INTO wa_return WITH KEY id = 'RW'
                                                    number = '605'.
    IF sy-subrc EQ 0.
      CLEAR wa_log.
      wa_log-msgid = wa_return-id.
      wa_log-msgno = wa_return-number.
      wa_log-msgty = wa_return-type.
      wa_log-msgv1 = wa_return-message_v1.
      wa_log-msgv2 = wa_return-message_v2.
      wa_log-msgv3 = wa_return-message_v3.
      wa_log-msgv4 = wa_return-message_v4.
      APPEND wa_log TO ti_log.
    ENDIF.
  ELSE.
    LOOP AT ti_return INTO wa_return.
      CLEAR wa_log.
      wa_log-msgid = wa_return-id.
      wa_log-msgno = wa_return-number.
      wa_log-msgty = wa_return-type.
      IF wa_log-msgty = 'E'.
        wa_log-msgno = 398.
        wa_log-msgid = '00'.
      ENDIF.

      wa_log-msgv1 = wa_return-message.
      CONCATENATE 'Doc' lg_reg_entrada-id_nomina '-' wa_log-msgv1
      INTO wa_log-msgv1 SEPARATED BY space.
      APPEND wa_log TO ti_log.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " BAPI_POST

*&---------------------------------------------------------------------*
*&      Form  CABECERA
*&---------------------------------------------------------------------*
FORM cabecera.
  CLEAR: wa_header, objtype, objsys, objkey, conta,
         wa_doc_compen,wa_emision,wa_agencia, wa_xref2_hd,
         wa_rut_terc, wa_unid_pro, wa_desc_est,wa_prestacion.

  REFRESH: ti_accountgl, ti_payable, ti_currency, ti_deudor,
**V1 RVY 05-10-2025
*           ti_return.
           ti_return, ti_extension1.
**V1 RVY 05-10-2025
***cabecera de documento por cada nuevo grupo
  wa_header-username    = sy-uname.              "Usuario
  wa_header-bus_act     = 'RFBU'.                "Tipo de operación
*  wa_header-header_txt  = 'Centralización RRHH'. "Texto cabecera
  wa_header-header_txt  = wa_nom_arch.            "Texto cabecera
  wa_header-comp_code   = lg_reg_entrada-codigo_empresa.
  wa_header-doc_date    = lg_reg_entrada-fecha_contable.
  wa_header-pstng_date  = lg_reg_entrada-fecha_contable.      "Fecha contable
  wa_header-trans_date  = lg_reg_entrada-fecha_contable.      "Fecha de conversion
  wa_header-fisc_year   = lg_reg_entrada-fecha_contable+0(4). "Ejercicio
  wa_header-fis_period  = lg_reg_entrada-fecha_contable+4(2).  "Periodo
  wa_header-doc_type    = 'RH'.                     "Clase de documento
  ADD 1 TO cont_cab.
* CONCATENATE lg_reg_entrada-ID_NOMINA '-' cont_cab
*              INTO wa_header-ref_doc_no.
*  wa_header-ref_doc_no  = wa_nom_arch.
* wa_header-ref_doc_no  = 'Centralización RRHH'.
  wa_header-ref_doc_no  = lg_reg_entrada-id_nomina.
  CLEAR wa_log.
  wa_log-msgid = '00'.
  wa_log-msgno = 398.
  wa_log-msgty = 'S'.
  CONCATENATE 'Log Documento' lg_reg_entrada-id_nomina
                              wa_header-comp_code
                              wa_header-doc_type  INTO
  wa_log-msgv1  SEPARATED BY space.
  APPEND wa_log TO ti_log.
ENDFORM.                    " CABECERA

*&---------------------------------------------------------------------*
*&      Form  ACCOUNT_GL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_CONTA  text
*----------------------------------------------------------------------*
FORM account_gl USING p_conta.
  CLEAR wa_accountgl.
  wa_accountgl-itemno_acc  = p_conta. "Posicion
  wa_accountgl-gl_account  = lg_reg_entrada-cuenta_contable_sap. "Cuenta mayor
  wa_accountgl-costcenter  = lg_reg_entrada-id_centro_costo.     "centro costo
*  CONCATENATE wa_header-comp_code '0' lg_reg_entrada-ID_CENTRO_COSTO
*              INTO wa_accountgl-costcenter.
  wa_accountgl-item_text   = lg_reg_entrada-nombre_concepto.     "Texto de posicion
  wa_accountgl-doc_type    = wa_header-doc_type.                 "Clase de documento
  wa_accountgl-comp_code   = wa_header-comp_code.                "Sociedad
  wa_accountgl-fis_period  = wa_header-fis_period.               "Periodo
  wa_accountgl-fisc_year   = wa_header-fisc_year.                "Ejercicio
  wa_accountgl-pstng_date  = wa_header-pstng_date.               "Fecha contable
  wa_accountgl-value_date  = wa_header-pstng_date.               "Fecha valor
  wa_accountgl-alloc_nmbr  = lg_reg_entrada-id_empleado.         "Asignación
  wa_accountgl-bus_area    = ' '.                                "División
  wa_accountgl-orderid     = ' '.                                "Orden
  wa_accountgl-profit_ctr  = ' '.                                "cebe
  wa_accountgl-wbs_element = ' '.                                "PEP
  wa_accountgl-segment     = ' '.                                "Segmento
* wa_accountgl-tax_code    = 'C0'.                               "Indicador IVA
  wa_accountgl-acct_type   = 'S'.                                "Clase de cuenta
  APPEND wa_accountgl TO  ti_accountgl.
ENDFORM.                    " ACCOUNT_GL

*&---------------------------------------------------------------------*
*&      Form  ACCOUNT_GL_900
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_CONTA  text
*----------------------------------------------------------------------*
FORM account_gl_900 USING p_conta.
  CLEAR wa_accountgl.
  wa_accountgl-itemno_acc  = p_conta + 1. "Posicion
  wa_accountgl-gl_account  = '9000000008'.                       "Cuenta mayor
  wa_accountgl-costcenter  = ' '.
  wa_accountgl-item_text   = 'documento mas de 900 lineas'.       "Texto de posicion
  wa_accountgl-doc_type    = wa_header-doc_type.                  "Clase de documento
  wa_accountgl-comp_code   = wa_header-comp_code.                 "Sociedad
  wa_accountgl-fis_period  = wa_header-fis_period.                "Periodo
  wa_accountgl-fisc_year   = wa_header-fisc_year.                 "Ejercicio
  wa_accountgl-pstng_date  = wa_header-pstng_date.                "Fecha contable
  wa_accountgl-value_date  = wa_header-pstng_date.                "Fecha valor
  wa_accountgl-alloc_nmbr  = ' '.                                 "Asignación
  wa_accountgl-bus_area    = ' '.                                 "División
  wa_accountgl-orderid     = ' '.                                 "Orden
  wa_accountgl-profit_ctr  = ' '.                                 "cebe
  wa_accountgl-wbs_element = ' '.                                 "PEP
  wa_accountgl-segment     = ' '.                                 "Segmento
* wa_accountgl-tax_code    = 'C0'.                                "Indicador IVA
  wa_accountgl-acct_type   = 'S'.                                 "Clase de cuenta
  APPEND wa_accountgl TO  ti_accountgl.
ENDFORM.                    " ACCOUNT_GL

*&---------------------------------------------------------------------*
*&      Form  ACREEDOR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_CONTA  text
*----------------------------------------------------------------------*
FORM acreedor  USING    p_conta.
  CLEAR wa_payable.
  wa_payable-itemno_acc = p_conta.                            "Posicion
  wa_payable-vendor_no  = lg_cod_lifnr.                       "Proveedor
  wa_payable-gl_account = lg_reg_entrada-cuenta_contable_sap. "Cuenta mayor
  wa_payable-ref_key_1  = ' '.                                "Clave ref1
  wa_payable-ref_key_2  = ' '.                                "Clave ref2
  wa_payable-ref_key_3  = ' '.                                "Clave ref3
  wa_payable-comp_code  = wa_header-comp_code.                "Sociedad
  wa_payable-bus_area   = ' '.                                "Division
  wa_payable-pmnttrms   = ' '.                                "Cond. pago
  wa_payable-dsct_days1 = '0'.                                "Dias  1
  wa_payable-alloc_nmbr = ' '.                                "Asignacion
  wa_payable-item_text  = lg_reg_entrada-nombre_concepto.     "Texto posicion
  wa_payable-pymt_meth  = wa_zlsch.                           "Via de pago
  wa_payable-sp_gl_ind  = ' '.                                "CME
  wa_payable-bank_id    = wa_hbkid.                           "Banco Propio
  IF wa_zfpago = '1'.
    wa_payable-bline_date = lg_reg_entrada-fecha_pago.       "fecha base
  ELSE.
    IF wa_zfpago = '2'.
      wa_payable-bline_date = lg_reg_entrada-fecha_vencimiento.
    ELSE.
      wa_payable-bline_date = ' '.                          "fecha base
    ENDIF.
  ENDIF.
*  wa_payable-tax_Code   = 'C0'.
  APPEND wa_payable TO ti_payable.
ENDFORM.                    " ACREEDOR

*&---------------------------------------------------------------------*
*&      Form  DEUDOR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_CONTA  text
*----------------------------------------------------------------------*
FORM deudor  USING    p_conta.
  CLEAR wa_payable.
  wa_deudor-itemno_acc = p_conta.                            "Posicion
  wa_deudor-customer   = lg_cod_kunnr.                       "Deudor
  wa_deudor-gl_account = lg_reg_entrada-cuenta_contable_sap. "Cuenta mayor
  wa_deudor-ref_key_1  = ' '.                                "Clave ref1
  wa_deudor-ref_key_2  = ' '.                                "Clave ref2
  wa_deudor-ref_key_3  = ' '.                                "Clave ref3
  wa_deudor-comp_code  = wa_header-comp_code.                "Sociedad
  wa_deudor-bus_area   = ' '.                                "Division
** V1 RVY 12-07-2024
  wa_deudor-pmnttrms   = ' '.                                 "Cond. pago
*  wa_deudor-pmnttrms   = 'ZK10'.                              "Cond. pago
** V1 RVY 12-07.2024
  wa_deudor-dsct_days1 = '0'.                                "Dias  1
  wa_deudor-alloc_nmbr = ' '.                                "Asignacion
  wa_deudor-item_text  = lg_reg_entrada-nombre_concepto.     "Texto posicion
  wa_deudor-pymt_meth  = wa_zlsch.                           "Via de pago
  wa_deudor-sp_gl_ind  = ' '.                                "CME
  wa_deudor-bank_id    = wa_hbkid.                           "Clave de banco
  IF wa_zfpago = '1'.
    wa_deudor-bline_date = lg_reg_entrada-fecha_pago.       "fecha base
  ELSE.
    IF wa_zfpago = '2'.
      wa_deudor-bline_date = lg_reg_entrada-fecha_vencimiento.
    ELSE.
      wa_deudor-bline_date = ' '.                          "fecha base
    ENDIF.
  ENDIF.
*  wa_payable-tax_Code   = 'C0'.
  APPEND wa_deudor TO ti_deudor.
ENDFORM.                    " DEUDOR

*&---------------------------------------------------------------------*
*&      Form  CURRENCY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_CONTA  text
*      -->P_SHKZG  text
*----------------------------------------------------------------------*
FORM currency  USING    p_conta p_shkzg.
  CLEAR wa_currency.
  wa_currency-itemno_acc = p_conta.
  wa_currency-curr_type  = '00'.
  wa_currency-currency   = 'CLP'.
  REPLACE ALL OCCURRENCES OF '.' IN lg_reg_entrada-valor WITH space.
  wa_currency-amt_doccur = lg_reg_entrada-valor.
  IF p_shkzg EQ 'H'.
    wa_currency-amt_doccur = wa_currency-amt_doccur * -1.
  ENDIF.
  APPEND wa_currency TO ti_currency.
  wa_total_doc = wa_total_doc + wa_currency-amt_doccur.

ENDFORM.                    " CURRENCY

*&---------------------------------------------------------------------*
*&      Form  CURRENCY_900
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_CONTA  text
*----------------------------------------------------------------------*
FORM currency_900  USING    p_conta.
  CLEAR wa_currency.
  wa_currency-itemno_acc = p_conta + 1.
  wa_currency-curr_type  = '00'.
  wa_currency-currency   = 'CLP'.
  wa_currency-amt_doccur = wa_total_doc.
  wa_currency-amt_doccur = wa_currency-amt_doccur * -1.
  APPEND wa_currency TO ti_currency.
  p_conta = 1.
ENDFORM.                    " CURRENCY

*&---------------------------------------------------------------------*
*&      Form  CURRENCY_900
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_CONTA  text
*----------------------------------------------------------------------*
FORM currency_900_r  USING    p_conta.
  CLEAR wa_currency.
  wa_currency-itemno_acc = p_conta + 1.
  wa_currency-curr_type  = '00'.
  wa_currency-currency   = 'CLP'.
  wa_currency-amt_doccur = wa_total_doc.
  APPEND wa_currency TO ti_currency.
* wa_total_doc = 0.
  p_conta = 1.
ENDFORM.                    " CURRENCY

*&---------------------------------------------------------------------*
*&      Form  MOSTRAR_LOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM mostrar_log .
  DATA: lf_obj        TYPE balobj_d,
        lf_subobj     TYPE balsubobj,
        ls_header     TYPE balhdri,
        lf_log_handle TYPE balloghndl,
        lf_log_number TYPE balognr,
        lt_lognum     TYPE TABLE OF balnri,
        ls_lognum     TYPE balnri.

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

  IF sy-subrc EQ 0.
    CALL FUNCTION 'BAL_DB_LOGNUMBER_GET'
      EXPORTING
        i_client                 = sy-mandt
        i_log_handle             = lf_log_handle
      IMPORTING
        e_lognumber              = lf_log_number
      EXCEPTIONS
        log_not_found            = 1
        lognumber_already_exists = 2
        numbering_error          = 3
        OTHERS                   = 4.
    IF sy-subrc EQ 0.
      CALL FUNCTION 'APPL_LOG_WRITE_MESSAGES'
        EXPORTING
          object              = lf_obj
          subobject           = lf_subobj
          log_handle          = lf_log_handle
        TABLES
          messages            = ti_log
        EXCEPTIONS
          object_not_found    = 1
          subobject_not_found = 2
          OTHERS              = 3.

      MOVE-CORRESPONDING ls_header TO ls_lognum.
      ls_lognum-lognumber = lf_log_number.
      APPEND ls_lognum TO lt_lognum.

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
      CALL FUNCTION 'BAL_DSP_LOG_DISPLAY'.
    ENDIF.
  ENDIF.
ENDFORM.                    " MOSTRAR_LOG
*&---------------------------------------------------------------------*
*&      Form  EXTENSION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_CONTA  text
*----------------------------------------------------------------------*
FORM extension  USING    p_conta
                         p_rut
*                         p_bschl
                         p_prestacion
                         p_unid
                         p_desc_est
                         p_emision
                         p_agencia.
*
***Se usará la función ZINTERFACE_RWBAPI01
  DATA: posicion TYPE bseg-buzei.
*  CLEAR wa_extension1.
*  posicion = p_conta.
*  wa_extension1-field1 = posicion.
*  CONCATENATE wa_extension1-field1
*              'BSCHL'
*              p_bschl
*              INTO wa_extension1-field1.
*  APPEND wa_extension1 TO ti_extension1.
*
  IF NOT p_rut IS INITIAL.
    CLEAR wa_extension1.
    posicion = p_conta.
    wa_extension1-field1 = posicion.
    CONCATENATE wa_extension1-field1
                'ZZRUT_TERC'
                p_rut
                INTO wa_extension1-field1.
    APPEND wa_extension1 TO ti_extension1.
  ENDIF.
*
  IF NOT p_prestacion IS INITIAL.
    CLEAR wa_extension1.
    posicion             = p_conta.
    wa_extension1-field1 = posicion.
    CONCATENATE wa_extension1-field1
                'ZZPRESTAC'
                p_prestacion
                INTO wa_extension1-field1.
    APPEND wa_extension1 TO ti_extension1.
  ENDIF.
*
  IF NOT p_unid IS  INITIAL.
    CLEAR wa_extension1.
    posicion = p_conta.
    wa_extension1-field1 = posicion.
    IF P_UNID = 'SPROD'.
       CONCATENATE wa_extension1-field1 'ZZUNID_PRO' 'SPROD'
                   INTO wa_extension1-field1.
    ELSE.
       IF P_UNID = 'PRODUCTO'.
          CONCATENATE wa_extension1-field1 'ZZUNID_PRO' lg_reg_entrada-producto
                     INTO wa_extension1-field1.
       endif.
    endif.
    APPEND wa_extension1 TO ti_extension1.
  ENDIF.
*
  IF NOT p_desc_est IS INITIAL.
     CLEAR wa_extension1.
     posicion = p_conta.
     wa_extension1-field1 = posicion.
     IF p_desc_est = 'CATEGORIA'.
        CONCATENATE wa_extension1-field1 'ZZDESC_EST' lg_reg_entrada-categoria
                INTO wa_extension1-field1.
        APPEND wa_extension1 TO ti_extension1.
     endif.
  ENDIF.

  IF NOT p_emision IS INITIAL.
    CLEAR wa_extension1.
    posicion = p_conta.
    wa_extension1-field1 = posicion.
    CONCATENATE wa_extension1-field1
                'ZZMOT_EMIS'
                p_emision
                INTO wa_extension1-field1.
    APPEND wa_extension1 TO ti_extension1.
  ENDIF.
*
  IF NOT p_agencia IS INITIAL.
    CLEAR wa_extension1.
    posicion = p_conta.
    wa_extension1-field1 = posicion.
    CONCATENATE wa_extension1-field1
                'ZZ_AGENCIA'
                p_agencia
                INTO wa_extension1-field1.
    APPEND wa_extension1 TO ti_extension1.
  ENDIF.
ENDFORM.                    " EXTENSION

*----------------------------------------------------------------------*
* Nombre Programa : ZFI_CARGA_PAGO_RRHH                                *
* Descripción     : Carga pagos relacionados con RRHH generando        *
*                   contabilización                                    *
*----------------------------------------------------------------------*
* Objetivo        :
*----------------------------------------------------------------------*
* Creado por      : VIsionOne.                                         *
* Creado en fecha : 19.01.2023                                         *
*----------------------------------------------------------------------*
REPORT  zfi_carga_pago_rrhh LINE-SIZE 250.
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
         id_nomina         TYPE char10,
         codigo_empresa    TYPE char10,
         codigo_concepto   TYPE char10,
         fecha_contable    TYPE char08,
         fecha_pago        TYPE char08,
         id_centro_costo   TYPE char10,
         id_categoria      TYPE char10,
         id_banco          TYPE char10,
         id_tipo_pago      TYPE char10,
         id_empleado       TYPE char10,
         id_sap            TYPE char10,
         apellido_pa       TYPE char20,
         apellido_ma       TYPE char20,
         nombre            TYPE char20,
         tipo_proceso_pago TYPE char01,
         valor             TYPE char28,
         cod_proceso       TYPE char02,
         tipo_cta          TYPE char01,
       END OF gty_reg_entrada.

TYPES: gtt_reg_entrada  TYPE STANDARD TABLE OF gty_reg_entrada.
TYPES: gtt2_reg_entrada TYPE STANDARD TABLE OF gty_reg_entrada.

DATA: gt_reg_entrada   TYPE gtt_reg_entrada.
DATA: gt2_reg_entrada  TYPE gtt_reg_entrada.
DATA: lg_reg_entrada   TYPE gty_reg_entrada.
DATA: lg2_reg_entrada  TYPE gty_reg_entrada.

TYPES: BEGIN OF gty_reg_entrada2,
         id_nomina         TYPE char10,
         codigo_empresa    TYPE char10,
         codigo_concepto   TYPE char10,
         fecha_contable    TYPE char08,
         fecha_pago        TYPE char08,
         id_categoria      TYPE char10,
         id_banco          TYPE char10,
         id_tipo_pago      TYPE char10,
         id_empleado       TYPE char10,
         id_Cuenta_mayor   TYPE char10,
         apellido_pa       TYPE char20,
         apellido_ma       TYPE char20,
         nombre            TYPE char20,
         tipo_proceso_pago TYPE char01,
         valor             TYPE char28,
         cod_proceso       TYPE char02,
         tipo_cta          TYPE char01,
         texto_pos         TYPE char50,
         Ceco_pos          TYPE char10,
         sentido           TYPE char01,
         rut_ter           TYPE char10,
         desc_est          TYPE char10,
         motemi            TYPE char10,
         agencia           TYPE char10,
       END OF gty_reg_entrada2.

TYPES: gtt2_reg_entrada2  TYPE STANDARD TABLE OF gty_reg_entrada2.
DATA: gt2_reg_entrada2 TYPE gtt2_reg_entrada2.
DATA: gt3_reg_entrada2 TYPE gtt2_reg_entrada2.
DATA: lg2_reg_entrada2 TYPE gty_reg_entrada2.
DATA: lg3_reg_entrada2 TYPE gty_reg_entrada2.

DATA: jobcount    LIKE tbtcjob-jobcount,
      jobname(32) TYPE c,
      l_datum     LIKE sy-datum,
      l_uzeit     LIKE sy-uzeit,
      l_hora_prev LIKE sy-uzeit,
      strtimmed   LIKE btch0000-char1,
      tit_job(30) TYPE c.

DATA: wa_header      TYPE bapiache09,
      ti_currency    TYPE TABLE OF bapiaccr09,
      wa_currency    TYPE bapiaccr09,
      ti_accountgl   TYPE TABLE OF bapiacgl09,
      wa_accountgl   TYPE bapiacgl09,
      ti_payable     TYPE TABLE OF bapiacap09,
      wa_payable     TYPE bapiacap09,
      ti_deudor      TYPE TABLE OF bapiacar09,
      wa_deudor      TYPE bapiacar09,
      ti_extension1  TYPE TABLE OF bapiacextc,
      wa_extension1  TYPE bapiacextc,
      ti_return      TYPE TABLE OF bapiret2,
      wa_return      TYPE bapiret2,
      wa_total_doc   TYPE bseg-dmbtr,
      wa_doc_compen  TYPE bsad-augbl,
      wa_xref2_hd    TYPE bkpf-xref2_hd,
      wa_emision     TYPE bseg-zzmot_emis,
      wa_agencia     TYPE bseg-zz_agencia,
      wa_rut_terc    TYPE bseg-zzrut_terc,
      wa_prestacion  TYPE bseg-zzprestac,
      wa_unid_pro    TYPE bseg-zzunid_pro,
      wa_desc_est    TYPE bseg-zzdesc_est,
      wa_lg_saknr    TYPE skb1-saknr,
      wa_lg_sgtxt    TYPE bseg-sgtxt,
      wa_lg_hbkid    TYPE bseg-hbkid,
      wa_lg_zterm    TYPE bseg-zterm,
      wa_lg_zlsch    TYPE bseg-zlsch,
      wa_lg_kostl    TYPE bseg-kostl,
      wa_lg_agencia  TYPE bseg-zz_agencia,
      wa_lg_motemi   TYPE bseg-zzmot_emis,
      wa_lg_desc_est TYPE bseg-zzdesc_est,
      wa_lg_asigna   TYPE bseg-zuonr,
      wa_lg_rut_ter  TYPE bseg-zzrut_terc,
      wa_lg_rut_pr   TYPE kna1-stcd1,
      wa_lg_tipoCont TYPE ZFITR030-ZTIPO_CONT,
      wa_stcd1       TYPE lfa1-stcd1,
      wa_mitkz       TYPE skb1-mitkz,
*      wa_nom_arch    TYPE bkpf-xblnr.
      wa_nom_arch    TYPE bkpf-BKTXT.

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
DATA lg_cod_lifnr2   TYPE lfa1-lifnr.
DATA lg_cod_kunnr    TYPE kna1-kunnr.
DATA lg_cod_kunnr2   TYPE kna1-kunnr.
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
  IF p_local = 'X'.
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

  ELSE.

  ENDIF.


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
        MESSAGE s398(00) WITH 'El fichero debe contener el codigo de la sociedad' DISPLAY LIKE 'E'.
        EXIT.
      ENDIF.
    ENDIF.
  ENDIF.

  PERFORM input_local.

  IF wa_nom_arch+2(1) = 'T'.
**¨Se genera un asiento contable.
    PERFORM armar_datos_un_asiento.
  ELSE.
** Se generar un asiento contable por linea del archivo.
    PERFORM armar_datos_varios_asientos.
  ENDIF.

  IF NOT ti_log[] IS INITIAL.
    PERFORM mostrar_log.
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
            ls_reg_entrada-codigo_empresa
            ls_reg_entrada-codigo_concepto
            ls_reg_entrada-fecha_contable
            ls_reg_entrada-fecha_pago
            ls_reg_entrada-id_centro_costo
            ls_reg_entrada-id_categoria
            ls_reg_entrada-id_banco
            ls_reg_entrada-id_tipo_pago
            ls_reg_entrada-id_empleado
            ls_reg_entrada-id_sap
            ls_reg_entrada-apellido_pa
            ls_reg_entrada-apellido_ma
            ls_reg_entrada-nombre
            ls_reg_entrada-tipo_proceso_pago
            ls_reg_entrada-valor
            ls_reg_entrada-cod_proceso.
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
                ls_reg_entrada-codigo_empresa
                ls_reg_entrada-codigo_concepto
                ls_reg_entrada-fecha_contable
                ls_reg_entrada-fecha_pago
                ls_reg_entrada-id_centro_costo
                ls_reg_entrada-id_categoria
                ls_reg_entrada-id_banco
                ls_reg_entrada-id_tipo_pago
                ls_reg_entrada-id_empleado
                ls_reg_entrada-id_sap
                ls_reg_entrada-apellido_pa
                ls_reg_entrada-apellido_ma
                ls_reg_entrada-nombre
                ls_reg_entrada-tipo_proceso_pago
                ls_reg_entrada-valor
                ls_reg_entrada-cod_proceso.
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

*&---------------------------------------------------------------------*
*&      Form  ARMAR_DATOS_VARIOS_ASIENTOS.                             *
*&            generar un asiento contable por cada linea del archivo   *
*&---------------------------------------------------------------------*
FORM armar_datos_varios_asientos.
  DATA: indicador      TYPE tbsl-shkzg.
  DATA: lt_reg_1(4)    TYPE n.
  DATA: lt_mitkz       TYPE skb1-mitkz.
  DATA: lt_saknr       TYPE skb1-saknr.
  DATA: lt_kostl       TYPE bseg-kostl.
  DATA: lt_reg_err     TYPE i.
  DATA: ls_reg_entrada TYPE gty_reg_entrada.

  lt_reg_1   = 0.
  lt_reg_err = 0.

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

    SORT gt_reg_entrada ASCENDING BY id_empleado.
    LOOP AT gt_reg_entrada INTO lg_reg_entrada.

      PERFORM cabecera.
      ADD 1 TO lt_reg_1.
      indicador = 'H'.
      conta = 1.
      PERFORM currency USING conta indicador.
      indicador = 'D'.
      conta = 2.
      PERFORM currency USING conta indicador.
      conta = 1.

***Si existe uenta contable con Imputacioin H
      SELECT SINGLE hkont kostl hbkid zterm sgtxt zz_agencia zzmot_emis
                    zzdesc_est zuonr zrutacreedor zzrut_terc ZLSCH
             INTO  (wa_lg_saknr,  wa_lg_kostl,   wa_lg_hbkid,  wa_lg_zterm,
                    wa_lg_sgtxt,  wa_lg_agencia, wa_lg_motemi, wa_lg_desc_est,
                    wa_lg_asigna, wa_lg_rut_pr,  wa_lg_rut_ter, wa_lg_zlsch)
             FROM  zfitr030
             WHERE bukrs         = wa_header-comp_code            AND
                   zcod_planilla = lg_reg_entrada-cod_proceso     AND
                   zconcepto     = lg_reg_entrada-codigo_concepto AND
                   sentido       = 'H'.
      IF sy-subrc NE 0.
         CLEAR wa_log.
         lt_reg_err   = 1.
         wa_log-msgty = 'E'.
         wa_log-msgid = '00'.
         wa_log-msgno = '398'.
         CONCATENATE 'Sociedad/COPROCESO/COD_PLANILLA/IMPUTACION '
                     wa_header-comp_code
                     lg_reg_entrada-cod_proceso
                     lg_reg_entrada-codigo_concepto
                      '/H:  No EXITE' INTO wa_log-msgv1.
         CONCATENATE ' En posición: ' lt_reg_1 INTO wa_log-msgv2.
         wa_log-msgv3 = wa_return-message_v3.
         wa_log-msgv4 = wa_return-message_v4.
         APPEND wa_log TO ti_log.
      ELSE.
***tipo de cuenta
        SELECT SINGLE mitkz INTO lt_mitkz
                   FROM  skb1
                   WHERE bukrs = wa_header-comp_code AND
                         saknr = wa_lg_saknr.
        IF sy-subrc NE 0.
           CLEAR wa_log.
           lt_reg_err   = 1.
           wa_log-msgty = 'E'.
           wa_log-msgid = '00'.
           wa_log-msgno = '398'.
           CONCATENATE 'Sociedad/Cuenta Mayor: '
                        lg_reg_entrada-codigo_empresa
                        wa_lg_saknr
                       ' No EXITE' INTO wa_log-msgv1.
           CONCATENATE ' En posición: ' lt_reg_1 INTO wa_log-msgv2.
           wa_log-msgv3 = wa_return-message_v3.
           wa_log-msgv4 = wa_return-message_v4.
           APPEND wa_log TO ti_log.
        ELSE.
           IF lt_mitkz = ' '.
* Cuanta de Mayor
              PERFORM account_gl USING conta.
              PERFORM extension  USING conta.
              ADD 1 TO conta.
           ELSE.
           IF lt_mitkz = 'K'.
* Cuenta de mayor Asociedad de Acreedor
              IF wa_lg_rut_pr = 'ID_EMPLEADO'.
                 wa_stcd1 = lg_reg_entrada-id_empleado.
              else.
                 wa_stcd1 = wa_lg_rut_pr.
              ENDIF.
              Translate wa_stcd1 to upper case.
              CLEAR lg_cod_lifnr.
              SELECT SINGLE lifnr
                     INTO lg_cod_lifnr
                     FROM lfa1
                     WHERE stcd1 EQ wa_stcd1.
              IF sy-subrc EQ 0.
                 SELECT SINGLE lifnr
                     INTO  lg_cod_lifnr2
                     FROM  lfb1
                     WHERE bukrs = wa_header-comp_code AND
                           lifnr = lg_cod_lifnr.
                 IF sy-subrc EQ 0.
                    PERFORM acreedor  USING conta.
                    PERFORM extension USING conta.
                    ADD 1 TO conta.
                 ELSE.
                    CLEAR wa_log.
                    wa_log-msgty = 'E'.
                    wa_log-msgid = '00'.
                    wa_log-msgno = '398'.
                    CONCATENATE 'SOCIEDAD/ACREEDOR: '
                                wa_header-comp_code '/' lg_cod_lifnr
                                ' No EXITE'
                           INTO wa_log-msgv1.
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
                 CONCATENATE 'ACREEDOR/RUT : ' wa_stcd1 ' No EXITE'
                        INTO wa_log-msgv1.
                 wa_log-msgv2 = wa_return-message_v2.
                 wa_log-msgv3 = wa_return-message_v3.
                 wa_log-msgv4 = wa_return-message_v4.
                 APPEND wa_log TO ti_log.
             ENDIF.
           ELSE.
* Cuenta de mayor Asociedad de Deudor
              IF wa_lg_rut_pr = 'ID_EMPLEADO'.
                 wa_stcd1 = lg_reg_entrada-id_empleado.
              else.
                 wa_stcd1 = wa_lg_rut_pr.
              ENDIF.
              CLEAR lg_cod_kunnr.
              Translate wa_stcd1 to upper case.
              SELECT SINGLE kunnr
                     INTO lg_cod_kunnr
                     FROM kna1
                     WHERE stcd1 EQ wa_stcd1.
              IF sy-subrc EQ 0.
                 SELECT SINGLE kunnr
                     INTO  lg_cod_kunnr2
                     FROM  knb1
                     WHERE bukrs = wa_header-comp_code AND
                           kunnr = lg_cod_kunnr.
                 IF sy-subrc EQ 0.
                    PERFORM deudor    USING conta.
                    PERFORM extension USING conta.
                    ADD 1 TO conta.
                 ELSE.
                    CLEAR wa_log.
                    wa_log-msgty = 'E'.
                    wa_log-msgid = '00'.
                    wa_log-msgno = '398'.
                    CONCATENATE 'SOCIEDAD/EUDOR: '
                                wa_header-comp_code '/' lg_cod_kunnr
                                ' No EXITE'
                           INTO wa_log-msgv1.
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
                 CONCATENATE 'DEUDOR:RUT ' wa_stcd1 ' No EXITE'
                           INTO wa_log-msgv1.
                 wa_log-msgv2 = wa_return-message_v2.
                 wa_log-msgv3 = wa_return-message_v3.
                 wa_log-msgv4 = wa_return-message_v4.
                 APPEND wa_log TO ti_log.
              ENDIF.
           ENDIF.
           ENDIF.
        ENDIF.
      ENDIF.
* ver datos para la segunda posicion.
      IF lt_reg_err   = 0.
***Si existe uenta contable con Imputacioin D
         SELECT SINGLE hkont kostl hbkid zterm sgtxt zz_agencia zzmot_emis
                       zzdesc_est zuonr zrutacreedor zzrut_terc ZLSCH
                INTO (wa_lg_saknr,  wa_lg_kostl,   wa_lg_hbkid,  wa_lg_zterm,
                      wa_lg_sgtxt,  wa_lg_agencia, wa_lg_motemi, wa_lg_desc_est,
                      wa_lg_asigna, wa_lg_rut_pr,  wa_lg_rut_ter, wa_lg_zlsch)
                FROM  zfitr030
                WHERE bukrs         = wa_header-comp_code            AND
                      zcod_planilla = lg_reg_entrada-cod_proceso     AND
                      zconcepto     = lg_reg_entrada-codigo_concepto AND
                      sentido       = 'D'.
         IF sy-subrc NE 0.
            CLEAR wa_log.
            lt_reg_err   = 1.
            wa_log-msgty = 'E'.
            wa_log-msgid = '00'.
            wa_log-msgno = '398'.
            CONCATENATE 'Sociedad/COPROCESO/COD_PLANILLA/IMPUTACION '
                        wa_header-comp_code
                        lg_reg_entrada-cod_proceso
                        lg_reg_entrada-codigo_concepto
                        '/H:  No EXITE' INTO wa_log-msgv1.
            CONCATENATE ' En posición: ' lt_reg_1 INTO wa_log-msgv2.
            wa_log-msgv3 = wa_return-message_v3.
            wa_log-msgv4 = wa_return-message_v4.
            APPEND wa_log TO ti_log.
         ELSE.
***tipo de cuenta
           SELECT SINGLE mitkz INTO lt_mitkz
                   FROM  skb1
                   WHERE bukrs = wa_header-comp_code AND
                         saknr = wa_lg_saknr.
           IF sy-subrc NE 0.
              CLEAR wa_log.
              lt_reg_err   = 1.
              wa_log-msgty = 'E'.
              wa_log-msgid = '00'.
              wa_log-msgno = '398'.
              CONCATENATE 'Sociedad/Cuenta Mayor: '
                          lg_reg_entrada-codigo_empresa
                          wa_lg_saknr
                          ' No EXITE' INTO wa_log-msgv1.
              CONCATENATE ' En posición: ' lt_reg_1 INTO wa_log-msgv2.
              wa_log-msgv3 = wa_return-message_v3.
              wa_log-msgv4 = wa_return-message_v4.
              APPEND wa_log TO ti_log.
           ELSE.
           IF lt_mitkz = ' '.
* Cuanta de Mayor
              PERFORM account_gl USING conta.
              PERFORM extension  USING conta.
           ELSE.
           IF lt_mitkz = 'K'.
* Cuenta de mayor Asociedad de Acreedor
              CLEAR lg_cod_lifnr.
              Translate wa_stcd1 to upper case.
              SELECT SINGLE lifnr
                     INTO lg_cod_lifnr
                     FROM lfa1
                     WHERE stcd1 EQ wa_stcd1.
              IF sy-subrc EQ 0.
                 SELECT SINGLE lifnr
                     INTO  lg_cod_lifnr2
                     FROM  lfb1
                     WHERE bukrs = wa_header-comp_code AND
                           lifnr = lg_cod_lifnr.
                 IF sy-subrc EQ 0.
                    PERFORM acreedor  USING conta.
                    PERFORM extension USING conta.
                 ELSE.
                    CLEAR wa_log.
                    wa_log-msgty = 'E'.
                    wa_log-msgid = '00'.
                    wa_log-msgno = '398'.
                    CONCATENATE 'SOCIEDAD/ACREEDOR: '
                                wa_header-comp_code '/' lg_cod_lifnr
                                ' No EXITE'
                           INTO wa_log-msgv1.
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
                 CONCATENATE 'ACREEDOR/RUT : ' wa_stcd1 ' No EXITE'
                        INTO wa_log-msgv1.
                 wa_log-msgv2 = wa_return-message_v2.
                 wa_log-msgv3 = wa_return-message_v3.
                 wa_log-msgv4 = wa_return-message_v4.
                 APPEND wa_log TO ti_log.
             ENDIF.
           ELSE.
* Cuenta de mayor Asociedad de Deudor
              CLEAR lg_cod_kunnr.
              Translate wa_stcd1 to upper case.
              SELECT SINGLE kunnr
                     INTO lg_cod_kunnr
                     FROM kna1
                     WHERE stcd1 EQ wa_stcd1.
              IF sy-subrc EQ 0.
                 SELECT SINGLE kunnr
                     INTO  lg_cod_kunnr
                     FROM  knb1
                     WHERE bukrs = wa_header-comp_code AND
                           kunnr = lg_cod_kunnr.
                 IF sy-subrc EQ 0.
                    PERFORM deudor    USING conta.
                    PERFORM extension USING conta.
                 ELSE.
                    CLEAR wa_log.
                    wa_log-msgty = 'E'.
                    wa_log-msgid = '00'.
                    wa_log-msgno = '398'.
                    CONCATENATE 'SOCIEDAD/EUDOR: '
                                wa_header-comp_code '/' lg_cod_kunnr
                                ' No EXITE'
                           INTO wa_log-msgv1.
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
                 CONCATENATE 'DEUDOR:RUT ' wa_stcd1 ' No EXITE'
                           INTO wa_log-msgv1.
                 wa_log-msgv2 = wa_return-message_v2.
                 wa_log-msgv3 = wa_return-message_v3.
                 wa_log-msgv4 = wa_return-message_v4.
                 APPEND wa_log TO ti_log.
              ENDIF.
            ENDIF.
           ENDIF.
         ENDIF.
        ENDIF.
      ENDIF.
      IF lt_reg_err   = 0.
         PERFORM bapi_post.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " ARMAR_DATOS

*&---------------------------------------------------------------------*
*&      Form  ARMAR_DATOS_VARIOS_ASIENTOS.
*&---------------------------------------------------------------------*
FORM armar_datos_un_asiento.

 PERFORM validaciones_basicas.

  wa_total_doc = 0.

  IF NOT ti_log[] IS INITIAL.
    PERFORM mostrar_log.
  ELSE.
    IF wa_lg_tipoCont = 1.
       PERFORM armar_datos1.
    ELSE.
       PERFORM armar_datos2.
    ENDIF.
    IF NOT ti_log[] IS INITIAL.
      PERFORM mostrar_log.
    ENDIF.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form VALIDACIONES_BASICAS
*&---------------------------------------------------------------------*
FORM validaciones_basicas.
  DATA: lt_mitkz               TYPE skb1-mitkz.
  DATA: lt_datbi               TYPE csks-datbi.
  DATA: lt_hkont               TYPE bseg-hkont.
  DATA: lt_kostl               TYPE bseg-kostl.
  DATA: lt_belnr               TYPE bseg-belnr.
  DATA: lt_reg_leido(4)        TYPE n VALUE 0.
  DATA: lt_cc(1)               TYPE n VALUE 0.
* DATA: lt_currency_tot        TYPE i.
  DATA: lt_currency_tot        TYPE int8.
  DATA: lt_reg_1               TYPE i.

  SELECT SINGLE belnr
                INTO lt_belnr
                FROM bkpf
                WHERE bukrs EQ wa_nom_arch+4(4)  and
                      blart EQ 'RH'              and
                      bktxt EQ wa_nom_arch+0(25) and
                      STBLG EQ '0'.
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
*
    ADD 1 TO lt_reg_leido.
*
    SELECT SINGLE hkont kostl hbkid zterm sgtxt zz_agencia zzmot_emis
                  zzdesc_est zuonr zrutacreedor zzrut_terc zlsch ZTIPO_CONT
           INTO
                 (wa_lg_saknr,  wa_lg_kostl,   wa_lg_hbkid,  wa_lg_zterm,
                  wa_lg_sgtxt,  wa_lg_agencia, wa_lg_motemi, wa_lg_desc_est,
                  wa_lg_asigna, wa_lg_rut_pr,  wa_lg_rut_ter, wa_lg_zlsch,
                  wa_lg_tipoCont)
                  FROM  zfitr030
                  WHERE bukrs         = lg_reg_entrada-codigo_empresa+0(4) AND
                        zcod_planilla = lg_reg_entrada-cod_proceso         AND
                        zconcepto     = lg_reg_entrada-codigo_concepto     AND
                        sentido       = 'D'.

    IF sy-subrc EQ 0.
      SELECT SINGLE mitkz INTO wa_mitkz
                 FROM  skb1
                 WHERE bukrs = lg_reg_entrada-codigo_empresa AND
                       saknr = wa_lg_saknr.
      IF sy-subrc EQ 0.
         IF wa_mitkz = ' '.
            SELECT SINGLE mitkz INTO lt_mitkz
                   FROM  skb1
                   WHERE bukrs = wa_header-comp_code AND
                         saknr = wa_lg_saknr.
            Move space to wa_stcd1.
            move 'D'   to lg2_reg_entrada2-sentido.
            PERFORM llenar_tabla2.
         ELSE.
            IF WA_LG_RUT_PR = 'ID_EMPLEADO'.
               move lg_reg_entrada-id_empleado to wa_stcd1.
            ELSE.
               move WA_LG_RUT_PR               to wa_stcd1.
            endif.
            Translate wa_stcd1 to upper case.
            IF wa_mitkz = 'K'.
               CLEAR lg_cod_lifnr.
               SELECT SINGLE lifnr
                     INTO lg_cod_lifnr2
                     FROM lfa1
                     WHERE stcd1 EQ wa_stcd1.
               IF sy-subrc EQ 0.
                  Move lg_cod_lifnr2 to wa_stcd1.
                  move 'D'           to lg2_reg_entrada2-sentido.
                  PERFORM llenar_tabla2.
               ELSE.
                  CLEAR wa_log.
                  wa_log-msgty = 'E'.
                  wa_log-msgid = '00'.
                  wa_log-msgno = '398'.
                  CONCATENATE 'Acredor-RUT: ' wa_stcd1 ' No EXITE'
                          INTO wa_log-msgv1.
                  wa_log-msgv2 = wa_return-message_v2.
                  wa_log-msgv3 = wa_return-message_v3.
                  wa_log-msgv4 = wa_return-message_v4.
                  APPEND wa_log TO ti_log.
               ENDIF.
            ELSE.
               CLEAR lg_cod_kunnr2.
               IF WA_LG_RUT_PR = 'ID_EMPLEADO'.
                  move lg_reg_entrada-id_empleado to wa_stcd1.
               ELSE.
                  move WA_LG_RUT_PR               to wa_stcd1.
               endif.
               Translate wa_stcd1 to upper case.
               SELECT SINGLE kunnr
                      INTO lg_cod_kunnr2
                      FROM kna1
                      WHERE stcd1 EQ wa_stcd1.
               IF sy-subrc EQ 0.
                   Move lg_cod_kunnr2 to wa_stcd1.
                   move 'D'           to lg2_reg_entrada2-sentido.
                   PERFORM llenar_tabla2.
               ELSE.
                  CLEAR wa_log.
                  wa_log-msgty = 'E'.
                  wa_log-msgid = '00'.
                  wa_log-msgno = '398'.
                  CONCATENATE 'DEUDOR-RUT: ' wa_stcd1 ' No EXITE'
                         INTO wa_log-msgv1.
                  wa_log-msgv2 = wa_return-message_v2.
                  wa_log-msgv3 = wa_return-message_v3.
                  wa_log-msgv4 = wa_return-message_v4.
                  APPEND wa_log TO ti_log.
               ENDIF.
         ENDIF.
        ENDIF.
      ELSE.
         CLEAR wa_log.
         wa_log-msgty = 'E'.
         wa_log-msgid = '00'.
         wa_log-msgno = '398'.
         CONCATENATE 'Cuenta Mayor: ' wa_lg_saknr
                      ' No existe en Sociedad: '
                     wa_header-comp_code
                INTO wa_log-msgv1.
         CONCATENATE ' En posición: ' lt_reg_leido
                INTO wa_log-msgv2.
         wa_log-msgv3 = wa_return-message_v3.
         wa_log-msgv4 = wa_return-message_v4.
         APPEND wa_log TO ti_log.
    ENDIF.
    ELSE.
       SELECT SINGLE hkont kostl hbkid zterm sgtxt zz_agencia zzmot_emis
                  zzdesc_est zuonr zrutacreedor zzrut_terc zlsch ZTIPO_CONT
              INTO
                 (wa_lg_saknr,  wa_lg_kostl,   wa_lg_hbkid,  wa_lg_zterm,
                  wa_lg_sgtxt,  wa_lg_agencia, wa_lg_motemi, wa_lg_desc_est,
                  wa_lg_asigna, wa_lg_rut_pr,  wa_lg_rut_ter, wa_lg_zlsch,
                  wa_lg_tipoCont)
              FROM  zfitr030
              WHERE bukrs         = lg_reg_entrada-codigo_empresa+0(4) AND
                    zcod_planilla = lg_reg_entrada-cod_proceso         AND
                    zconcepto     = lg_reg_entrada-codigo_concepto     AND
                    sentido       = 'H'.
       IF sy-subrc EQ 0.
          SELECT SINGLE mitkz INTO wa_mitkz
                 FROM  skb1
                 WHERE bukrs = lg_reg_entrada-codigo_empresa AND
                       saknr = wa_lg_saknr.
          IF sy-subrc EQ 0.
             IF wa_mitkz = ' '.
                SELECT SINGLE mitkz INTO lt_mitkz
                       FROM  skb1
                       WHERE bukrs = wa_header-comp_code AND
                             saknr = wa_lg_saknr.
                Move space to wa_stcd1.
                move 'H'   to lg2_reg_entrada2-sentido.
                PERFORM llenar_tabla2.
             ELSE.
                IF WA_LG_RUT_PR = 'ID_EMPLEADO'.
                   move lg_reg_entrada-id_empleado to wa_stcd1.
                ELSE.
                   move WA_LG_RUT_PR               to wa_stcd1.
                endif.
                Translate wa_stcd1 to upper case.
                IF wa_mitkz = 'K'.
                   CLEAR lg_cod_lifnr.
                   SELECT SINGLE lifnr
                          INTO lg_cod_lifnr2
                          FROM lfa1
                          WHERE stcd1 EQ wa_stcd1.
                   IF sy-subrc EQ 0.
                      Move lg_cod_lifnr2 to wa_stcd1.
                      move 'H'           to lg2_reg_entrada2-sentido.
                      PERFORM llenar_tabla2.
                   ELSE.
                      CLEAR wa_log.
                      wa_log-msgty = 'E'.
                      wa_log-msgid = '00'.
                      wa_log-msgno = '398'.
                      CONCATENATE 'Acredor-RUT: ' wa_stcd1 ' No EXITE'
                             INTO wa_log-msgv1.
                      wa_log-msgv2 = wa_return-message_v2.
                      wa_log-msgv3 = wa_return-message_v3.
                      wa_log-msgv4 = wa_return-message_v4.
                      APPEND wa_log TO ti_log.
                   ENDIF.
                ELSE.
                   CLEAR lg_cod_kunnr2.
                   IF WA_LG_RUT_PR = 'ID_EMPLEADO'.
                      move lg_reg_entrada-id_empleado to wa_stcd1.
                   ELSE.
                      move WA_LG_RUT_PR               to wa_stcd1.
                   endif.
                   Translate wa_stcd1 to upper case.
                   SELECT SINGLE kunnr
                         INTO lg_cod_kunnr2
                         FROM kna1
                         WHERE stcd1 EQ wa_stcd1.
                   IF sy-subrc EQ 0.
                      Move lg_cod_kunnr2 to wa_stcd1.
                      move 'H'           to lg2_reg_entrada2-sentido.
                      PERFORM llenar_tabla2.
                   ELSE.
                      CLEAR wa_log.
                      wa_log-msgty = 'E'.
                      wa_log-msgid = '00'.
                      wa_log-msgno = '398'.
                      CONCATENATE 'DEUDOR-RUT: ' wa_stcd1 ' No EXITE'
                             INTO wa_log-msgv1.
                      wa_log-msgv2 = wa_return-message_v2.
                      wa_log-msgv3 = wa_return-message_v3.
                      wa_log-msgv4 = wa_return-message_v4.
                      APPEND wa_log TO ti_log.
                   ENDIF.
                ENDIF.
          ENDIF.
          ELSE.
            CLEAR wa_log.
            wa_log-msgty = 'E'.
            wa_log-msgid = '00'.
            wa_log-msgno = '398'.
            CONCATENATE 'Cuenta Mayor: ' wa_lg_saknr
                        ' No existe en Sociedad: '
                        wa_header-comp_code
                   INTO wa_log-msgv1.
            CONCATENATE ' En posición: ' lt_reg_leido
                   INTO wa_log-msgv2.
            wa_log-msgv3 = wa_return-message_v3.
            wa_log-msgv4 = wa_return-message_v4.
            APPEND wa_log TO ti_log.
          endif.
      ELSE.
         CLEAR wa_log.
         wa_log-msgty = 'E'.
         wa_log-msgid = '00'.
         wa_log-msgno = '398'.
         CONCATENATE 'Sociedad: '  lg_reg_entrada-codigo_empresa
                     ' COPROCESO: ' lg_reg_entrada-cod_proceso
                     ' CONCEPTO: '  lg_reg_entrada-codigo_concepto
                     ' IMPUTACION: D/H:  No EXISTEN en Tabla ZFITR0030 '
                INTO wa_log-msgv1.
         CONCATENATE ' En posición: ' lt_reg_leido
                INTO wa_log-msgv2.
         wa_log-msgv3 = wa_return-message_v3.
         wa_log-msgv4 = wa_return-message_v4.
         APPEND wa_log TO ti_log.
     ENDIF.
     endif.
   ENDLOOP.
  endif.

  sort gt2_reg_entrada2 ASCENDING BY id_empleado id_cuenta_mayor.

  lt_reg_1 = 0.

  LOOP AT gt2_reg_entrada2 INTO lg2_reg_entrada2.

    IF lt_reg_1 = 0.
       move 1                     to lt_reg_1.
       move lg2_reg_entrada2      to lg3_reg_entrada2.
       add lg2_reg_entrada2-valor to lt_currency_tot.
    else.
       if lg2_reg_entrada2-id_empleado = lg3_reg_entrada2-id_empleado AND
          lg2_reg_entrada2-id_cuenta_mayor = lg3_reg_entrada2-id_cuenta_mayor.
          add lg2_reg_entrada2-valor to lt_currency_tot.
       else.
          move lt_currency_tot        to lg3_reg_entrada2-valor.
          APPEND lg3_reg_entrada2     TO gt3_reg_entrada2.
          clear lg3_reg_entrada2.
          move lg2_reg_entrada2-valor to lt_currency_tot.
          move lg2_reg_entrada2       to lg3_reg_entrada2.
       endif.
    endif.
  endloop.

  move lt_currency_tot     TO lg3_reg_entrada2-valor.
  APPEND lg3_reg_entrada2  TO gt3_reg_entrada2.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  LLENAR_TABLA2
*&---------------------------------------------------------------------*
FORM llenar_tabla2.

     move lg_reg_entrada-id_nomina       to lg2_reg_entrada2-id_nomina.
     move lg_reg_entrada-codigo_empresa  to lg2_reg_entrada2-codigo_empresa.
     move lg_reg_entrada-codigo_concepto to lg2_reg_entrada2-codigo_concepto.
     move lg_reg_entrada-fecha_contable  to lg2_reg_entrada2-fecha_contable.
     move lg_reg_entrada-fecha_pago      to lg2_reg_entrada2-fecha_pago.
     move lg_reg_entrada-id_categoria    to lg2_reg_entrada2-id_categoria.
     move lg_reg_entrada-id_banco        to lg2_reg_entrada2-id_banco.
     move lg_reg_entrada-id_tipo_pago    to lg2_reg_entrada2-id_tipo_pago.
     move wa_stcd1                       to lg2_reg_entrada2-id_empleado.
     move wa_lg_saknr                    to lg2_reg_entrada2-id_Cuenta_mayor.
     move lg_reg_entrada-apellido_pa     to lg2_reg_entrada2-apellido_pa.
     move lg_reg_entrada-apellido_ma     to lg2_reg_entrada2-apellido_ma.
     move lg_reg_entrada-nombre          to lg2_reg_entrada2-nombre.
     move lg_reg_entrada-tipo_proceso_pago to lg2_reg_entrada2-tipo_proceso_pago.
     move lg_reg_entrada-valor           to lg2_reg_entrada2-valor.
     move lg_reg_entrada-cod_proceso     to lg2_reg_entrada2-cod_proceso.
     move wa_lg_sgtxt                    to lg2_reg_entrada2-texto_pos.
     move wa_lg_kostl                    to lg2_reg_entrada2-ceco_pos.
     move wa_mitkz                       to lg2_reg_entrada2-tipo_cta.
     move wa_lg_rut_ter                  to lg2_reg_entrada2-rut_ter.
     move wa_lg_desc_est                 to lg2_reg_entrada2-desc_est.
     move wa_lg_motemi                   to lg2_reg_entrada2-motemi.
     move wa_lg_agencia                  to lg2_reg_entrada2-agencia.
     APPEND lg2_reg_entrada2 TO gt2_reg_entrada2.

ENDFORM.             "llenar_tabla2

*&---------------------------------------------------------------------*
*&      Form  ARMAR_DATOS1
*&---------------------------------------------------------------------*
FORM armar_datos1.
  DATA: indicador    TYPE tbsl-shkzg.
  DATA: lt_reg_1     TYPE i.
  DATA: lt_mitkz     TYPE skb1-mitkz.
  DATA: ls_reg_entrada TYPE gty_reg_entrada.

  lt_reg_1 = 0.


  LOOP AT gt3_reg_entrada2 INTO lg2_reg_entrada2.

   IF lt_reg_1 = 0.
      lt_reg_1 = 1.
      wa_total_doc = 0.
      move lg2_reg_entrada2 to lg_reg_entrada.
      PERFORM cabecera.
      conta = 1.
* Posicion Debe
      IF lg2_reg_entrada2-tipo_cta = ' '.
         move lg2_reg_entrada2-id_Cuenta_mayor to wa_lg_saknr.
         move lg2_reg_entrada2-ceco_pos        to wa_lg_kostl.
         move lg2_reg_entrada2-texto_pos      to wa_lg_sgtxt.
         PERFORM account_gl USING conta.
         PERFORM extension  USING conta.
         move lg2_reg_entrada2-valor  to lg_reg_entrada-valor.
         move 'D'                     to indicador.
         PERFORM currency   USING conta indicador.
         ADD 1 TO conta.
      ELSE.
         IF lg2_reg_entrada2-tipo_cta = 'K'.
            move lg2_reg_entrada2-id_Cuenta_mayor to wa_lg_saknr.
            move lg2_reg_entrada2-id_Empleado     to lg_cod_lifnr2.
            move lg2_reg_entrada2-ceco_pos        to wa_lg_kostl.
            move lg2_reg_entrada2-texto_pos       to wa_lg_sgtxt.
            PERFORM acreedor  USING conta.
            PERFORM extension USING conta.
            move lg2_reg_entrada2-valor  to lg_reg_entrada-valor.
            move 'D'                     to indicador.
            PERFORM currency   USING conta indicador.
            ADD 1 TO conta.
         ELSE.
            move lg2_reg_entrada2-id_Cuenta_mayor to wa_lg_saknr.
            move lg2_reg_entrada2-id_Empleado     to lg_cod_kunnr2.
            move lg2_reg_entrada2-ceco_pos        to wa_lg_kostl.
            move lg2_reg_entrada2-texto_pos       to wa_lg_sgtxt.
            PERFORM deudor    USING conta.
            PERFORM extension USING conta.
            move lg2_reg_entrada2-valor  to lg_reg_entrada-valor.
            move 'D'                     to indicador.
            PERFORM currency  USING conta indicador.
            ADD 1 TO conta.
         ENDIF.
      ENDIF.
   ELSE.
      indicador = 'D'.
      IF lg2_reg_entrada2-tipo_cta = ' '.
         move lg2_reg_entrada2-id_Cuenta_mayor to wa_lg_saknr.
         move lg2_reg_entrada2-ceco_pos        to wa_lg_kostl.
         move lg2_reg_entrada2-texto_pos       to wa_lg_sgtxt.
         PERFORM account_gl USING conta.
         PERFORM extension  USING conta.
         move lg2_reg_entrada2-valor  to lg_reg_entrada-valor.
         PERFORM currency   USING conta indicador.
         ADD 1 TO conta.
      ELSE.
         IF lg2_reg_entrada2-tipo_cta = 'K'.
            move lg2_reg_entrada2-id_Cuenta_mayor to wa_lg_saknr.
            move lg2_reg_entrada2-id_Empleado     to lg_cod_lifnr2.
            move lg2_reg_entrada2-ceco_pos        to wa_lg_kostl.
            move lg2_reg_entrada2-texto_pos       to wa_lg_sgtxt.
            PERFORM acreedor  USING conta.
            PERFORM extension USING conta.
            move lg2_reg_entrada2-valor  to lg_reg_entrada-valor.
            PERFORM currency  USING conta indicador.
            ADD 1 TO conta.
         ELSE.
            move lg2_reg_entrada2-id_Cuenta_mayor to wa_lg_saknr.
            move lg2_reg_entrada2-id_Empleado     to lg_cod_kunnr2.
            move lg2_reg_entrada2-ceco_pos        to wa_lg_kostl.
            move lg2_reg_entrada2-texto_pos       to wa_lg_sgtxt.
            PERFORM deudor    USING conta.
            PERFORM extension USING conta.
            move lg2_reg_entrada2-valor  to lg_reg_entrada-valor.
            PERFORM currency   USING conta indicador.
            ADD 1 TO conta.
         ENDIF.
      ENDIF.
   ENDIF.
   IF conta > 950.
      PERFORM account_gl_900 USING conta.
      PERFORM currency_900   USING conta.
      PERFORM bapi_post.
      PERFORM cabecera.
      conta = 0.
      PERFORM account_gl_900 USING conta.
      PERFORM currency_900_r USING conta.
      ADD 1 TO conta.
   ENDIF.
  ENDLOOP.

** Ultima linea sumatoria de montos de lineas detalle.
   SELECT SINGLE hkont kostl hbkid zterm sgtxt zz_agencia zzmot_emis
                 zzdesc_est zuonr zrutacreedor zzrut_terc zlsch
          INTO
                (wa_lg_saknr,  wa_lg_kostl,   wa_lg_hbkid,  wa_lg_zterm,
                 wa_lg_sgtxt,  wa_lg_agencia, wa_lg_motemi, wa_lg_desc_est,
                 wa_lg_asigna, wa_lg_rut_pr,  wa_lg_rut_ter, wa_lg_zlsch)
          FROM   zfitr030
          WHERE  bukrs         = wa_header-comp_code              AND
                 zcod_planilla = lg2_reg_entrada2-cod_proceso     AND
                 zconcepto     = lg2_reg_entrada2-codigo_concepto AND
                 sentido       = 'H'.
*
   SELECT SINGLE mitkz
          INTO   lt_mitkz
          FROM   skb1
          WHERE  bukrs = wa_header-comp_code AND
                 saknr = wa_lg_saknr.
   indicador = 'H'.
   IF lt_mitkz = ' '.
      SELECT SINGLE mitkz INTO lt_mitkz
             FROM  skb1
             WHERE bukrs = wa_header-comp_code AND
                   saknr = wa_lg_saknr.
      PERFORM account_gl    USING conta.
      PERFORM extension     USING conta.
      PERFORM currency_suma USING conta.
   ELSE.
      IF WA_LG_RUT_PR = 'ID_EMPLEADO'.
         move lg_reg_entrada-id_empleado to wa_stcd1.
      ELSE.
         move WA_LG_RUT_PR               to wa_stcd1.
      endif.
      IF lt_mitkz = 'K'.
         CLEAR lg_cod_lifnr2.
         SELECT SINGLE lifnr
                INTO   lg_cod_lifnr2
                FROM   lfa1
                WHERE   stcd1 EQ wa_stcd1.
         IF sy-subrc EQ 0.
            PERFORM acreedor      USING conta.
            PERFORM extension     USING conta.
            PERFORM currency_suma USING conta.
         ELSE.
            CLEAR wa_log.
            wa_log-msgty = 'E'.
            wa_log-msgid = '00'.
            wa_log-msgno = '398'.
            CONCATENATE 'Acredor-RUT: ' wa_stcd1 ' No EXITE'
                   INTO wa_log-msgv1.
            wa_log-msgv2 = wa_return-message_v2.
            wa_log-msgv3 = wa_return-message_v3.
            wa_log-msgv4 = wa_return-message_v4.
            APPEND wa_log TO ti_log.
         ENDIF.
      ELSE.
         IF WA_LG_RUT_PR = 'ID_EMPLEADO'.
            move lg_reg_entrada-id_empleado to wa_stcd1.
         ELSE.
            move WA_LG_RUT_PR               to wa_stcd1.
         endif.
         CLEAR lg_cod_kunnr2.
         SELECT SINGLE kunnr
                INTO   lg_cod_kunnr2
                FROM   kna1
                WHERE  stcd1 EQ wa_stcd1.
         IF sy-subrc EQ 0.
            PERFORM deudor        USING conta.
            PERFORM extension     USING conta.
            PERFORM currency_suma USING conta.
         ELSE.
            CLEAR wa_log.
            wa_log-msgty = 'E'.
            wa_log-msgid = '00'.
            wa_log-msgno = '398'.
            CONCATENATE 'DEUDOR-RUT: ' wa_stcd1 ' No EXITE'
                    INTO wa_log-msgv1.
            wa_log-msgv2 = wa_return-message_v2.
            wa_log-msgv3 = wa_return-message_v3.
            wa_log-msgv4 = wa_return-message_v4.
            APPEND wa_log TO ti_log.
         ENDIF.
      endif.
   ENDIF.

  PERFORM bapi_post.

ENDFORM.                    "ARMAR_DATOS1

*&---------------------------------------------------------------------*
*&      Form  ARMAR_DATOS2
*&---------------------------------------------------------------------*
FORM armar_datos2.
  DATA: indicador    TYPE tbsl-shkzg.
  DATA: lt_reg_1     TYPE i.
  DATA: lt_mitkz     TYPE skb1-mitkz.
  DATA: ls_reg_entrada TYPE gty_reg_entrada.

  lt_reg_1 = 0.

  LOOP AT gt3_reg_entrada2 INTO lg2_reg_entrada2.

   IF lt_reg_1 = 0.
      lt_reg_1 = 1.
      wa_total_doc = 0.
      move lg2_reg_entrada2 to lg_reg_entrada.
      PERFORM cabecera.
      conta = 1.
      IF lg2_reg_entrada2-tipo_cta = ' '.
         move lg2_reg_entrada2-id_Cuenta_mayor to wa_lg_saknr.
         move lg2_reg_entrada2-ceco_pos        to wa_lg_kostl.
         move lg2_reg_entrada2-texto_pos       to wa_lg_sgtxt.
         PERFORM account_gl USING conta.
         move lg2_reg_entrada2-rut_ter  to wa_lg_rut_ter.
         move lg2_reg_entrada2-desc_est to wa_lg_desc_est.
         move lg2_reg_entrada2-motemi   to wa_lg_motemi.
         move lg2_reg_entrada2-agencia  to wa_lg_agencia.
         PERFORM extension  USING conta.
         move lg2_reg_entrada2-valor   to lg_reg_entrada-valor.
         move lg2_reg_entrada2-sentido to indicador.
         PERFORM currency   USING conta indicador.
         ADD 1 TO conta.
      ELSE.
         IF lg2_reg_entrada2-tipo_cta = 'K'.
            move lg2_reg_entrada2-id_Cuenta_mayor to wa_lg_saknr.
            move lg2_reg_entrada2-id_Empleado     to lg_cod_lifnr2.
            move lg2_reg_entrada2-ceco_pos        to wa_lg_kostl.
            move lg2_reg_entrada2-texto_pos       to wa_lg_sgtxt.
            PERFORM acreedor  USING conta.
            move lg2_reg_entrada2-rut_ter  to wa_lg_rut_ter.
            move lg2_reg_entrada2-desc_est to wa_lg_desc_est.
            move lg2_reg_entrada2-motemi   to wa_lg_motemi.
            move lg2_reg_entrada2-agencia  to wa_lg_agencia.
            PERFORM extension USING conta.
            move lg2_reg_entrada2-valor   to lg_reg_entrada-valor.
            move lg2_reg_entrada2-sentido to indicador.
            PERFORM currency   USING conta indicador.
            ADD 1 TO conta.
         ELSE.
            move lg2_reg_entrada2-id_Cuenta_mayor to wa_lg_saknr.
            move lg2_reg_entrada2-id_Empleado     to lg_cod_kunnr2.
            move lg2_reg_entrada2-ceco_pos        to wa_lg_kostl.
            move lg2_reg_entrada2-texto_pos       to wa_lg_sgtxt.
            PERFORM deudor    USING conta.
            move lg2_reg_entrada2-rut_ter  to wa_lg_rut_ter.
            move lg2_reg_entrada2-desc_est to wa_lg_desc_est.
            move lg2_reg_entrada2-motemi   to wa_lg_motemi.
            move lg2_reg_entrada2-agencia  to wa_lg_agencia.
            PERFORM extension USING conta.
            move lg2_reg_entrada2-valor   to lg_reg_entrada-valor.
            move lg2_reg_entrada2-sentido to indicador.
            PERFORM currency  USING conta indicador.
            ADD 1 TO conta.
         ENDIF.
      ENDIF.
   ELSE.
      IF lg2_reg_entrada2-tipo_cta = ' '.
         move lg2_reg_entrada2-id_Cuenta_mayor to wa_lg_saknr.
         move lg2_reg_entrada2-ceco_pos        to wa_lg_kostl.
         move lg2_reg_entrada2-texto_pos       to wa_lg_sgtxt.
         PERFORM account_gl USING conta.
         move lg2_reg_entrada2-rut_ter  to wa_lg_rut_ter.
         move lg2_reg_entrada2-desc_est to wa_lg_desc_est.
         move lg2_reg_entrada2-motemi   to wa_lg_motemi.
         move lg2_reg_entrada2-agencia  to wa_lg_agencia.
         PERFORM extension  USING conta.
         move lg2_reg_entrada2-valor   to lg_reg_entrada-valor.
         move lg2_reg_entrada2-sentido to indicador.
         PERFORM currency   USING conta indicador.
         ADD 1 TO conta.
      ELSE.
         IF lg2_reg_entrada2-tipo_cta = 'K'.
            move lg2_reg_entrada2-id_Cuenta_mayor to wa_lg_saknr.
            move lg2_reg_entrada2-id_Empleado     to lg_cod_lifnr2.
            move lg2_reg_entrada2-ceco_pos        to wa_lg_kostl.
            move lg2_reg_entrada2-texto_pos       to wa_lg_sgtxt.
            PERFORM acreedor  USING conta.
            move lg2_reg_entrada2-rut_ter  to wa_lg_rut_ter.
            move lg2_reg_entrada2-desc_est to wa_lg_desc_est.
            move lg2_reg_entrada2-motemi   to wa_lg_motemi.
            move lg2_reg_entrada2-agencia  to wa_lg_agencia.
            PERFORM extension USING conta.
            move lg2_reg_entrada2-valor   to lg_reg_entrada-valor.
            move lg2_reg_entrada2-sentido to indicador.
            PERFORM currency  USING conta indicador.
            ADD 1 TO conta.
         ELSE.
            move lg2_reg_entrada2-id_Cuenta_mayor to wa_lg_saknr.
            move lg2_reg_entrada2-id_Empleado     to lg_cod_kunnr2.
            move lg2_reg_entrada2-ceco_pos        to wa_lg_kostl.
            move lg2_reg_entrada2-texto_pos       to wa_lg_sgtxt.
            PERFORM deudor    USING conta.
            move lg2_reg_entrada2-rut_ter  to wa_lg_rut_ter.
            move lg2_reg_entrada2-desc_est to wa_lg_desc_est.
            move lg2_reg_entrada2-motemi   to wa_lg_motemi.
            move lg2_reg_entrada2-agencia  to wa_lg_agencia.
            PERFORM extension USING conta.
            move lg2_reg_entrada2-valor  to lg_reg_entrada-valor.
            move lg2_reg_entrada2-sentido to indicador.
            PERFORM currency   USING conta indicador.
            ADD 1 TO conta.
         ENDIF.
      ENDIF.
   ENDIF.
   IF conta > 950.
      PERFORM account_gl_900 USING conta.
      PERFORM currency_900   USING conta.
      PERFORM bapi_post.
      PERFORM cabecera.
      conta = 0.
      PERFORM account_gl_900 USING conta.
      PERFORM currency_900_r USING conta.
      ADD 1 TO conta.
   ENDIF.
  ENDLOOP.

  PERFORM bapi_post.

ENDFORM.                           "ARMAR_DATOS2
*&---------------------------------------------------------------------*
*&      Form  BAPI_POST
*&---------------------------------------------------------------------*
FORM bapi_post.
  CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'
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
           ti_return.
***cabecera de documento por cada nuevo grupo
  wa_header-username    = sy-uname.              "Usuario
  wa_header-bus_act     = 'RFBU'.                "Tipo de operación
*  CONCATENATE 'Liquidación' sy-datum+4(2) '-' sy-datum+0(4)
*              INTO wa_header-header_txt.
  wa_header-header_txt  = wa_nom_arch.            "Texto cabecera
  wa_header-comp_code   = lg_reg_entrada-codigo_empresa+0(4).
  wa_header-doc_date    = lg_reg_entrada-fecha_contable.
  wa_header-pstng_date  = lg_reg_entrada-fecha_contable.      "Fecha contable
  wa_header-trans_date  = lg_reg_entrada-fecha_contable.      "Fecha de conversion
  wa_header-fisc_year   = lg_reg_entrada-fecha_contable+0(4). "Ejercicio
  wa_header-fis_period  = lg_reg_entrada-fecha_contable+4(2).  "Periodo
  wa_header-doc_type    = 'RH'.                     "Clase de documento
  ADD 1 TO cont_cab.
  CONCATENATE 'RRHH' sy-datum+4(2) sy-datum+6(2) sy-datum+0(4)
                     sy-uzeit+0(2) sy-uzeit+2(2)
              INTO wa_header-ref_doc_no.
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
  wa_accountgl-itemno_acc  = p_conta.                            "Posicion
  wa_accountgl-gl_account  = wa_lg_saknr.                        "Cuenta mayor
  wa_accountgl-costcenter  = wa_lg_kostl.                        "centro costo
  wa_accountgl-item_text   = wa_lg_sgtxt.                        "Texto de posicion
  wa_accountgl-doc_type    = wa_header-doc_type.                 "Clase de documento
  wa_accountgl-comp_code   = wa_header-comp_code.                "Sociedad
  wa_accountgl-fis_period  = wa_header-fis_period.               "Periodo
  wa_accountgl-fisc_year   = wa_header-fisc_year.                "Ejercicio
  wa_accountgl-pstng_date  = wa_header-pstng_date.               "Fecha contable
  wa_accountgl-value_date  = wa_header-pstng_date.               "Fecha valor
  wa_accountgl-alloc_nmbr  = ' '.                                 "Asignación
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
*&      Form  ACREEDOR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_CONTA  text
*----------------------------------------------------------------------*
FORM acreedor  USING    p_conta.
  CLEAR wa_payable.
  wa_payable-itemno_acc = p_conta.                          "Posicion
  wa_payable-vendor_no  = lg_cod_lifnr2.                    "Proveedor
  wa_payable-gl_account = wa_lg_saknr.                      "Cuenta mayor
  wa_payable-ref_key_1  = ' '.                              "Clave ref1
  wa_payable-ref_key_2  = ' '.                              "Clave ref2
  wa_payable-ref_key_3  = ' '.                              "Clave ref3
  wa_payable-comp_code  = wa_header-comp_code.              "Sociedad
  wa_payable-bus_area   = ' '.                              "Division
  wa_payable-pmnttrms   = wa_lg_zterm.                       "Cond. pago
  wa_payable-bline_date = lg_reg_entrada-fecha_pago.        "Fecha base
  wa_payable-dsct_days1 = '0'.                              "Dias  1
  wa_payable-alloc_nmbr = wa_lg_asigna.                     "Asignacion
  wa_payable-item_text  = wa_lg_sgtxt.                      "Texto posicion
  wa_payable-pymt_meth  = wa_lg_zlsch.                      "Via de pago
  wa_payable-sp_gl_ind  = ' '.                              "CME
  wa_payable-bank_id    = wa_lg_hbkid.                      "Clave de banco
*  wa_payable-tax_Code   = 'C0'.
*  wa_payable-housebankacctid = t_reg_entrada-hktid.
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
  wa_deudor-customer   = lg_cod_kunnr2.                      "Deudor
  wa_deudor-gl_account = wa_lg_saknr.                        "Cuenta mayor
  wa_deudor-ref_key_1  = ' '.                                "Clave ref1
  wa_deudor-ref_key_2  = ' '.                                "Clave ref2
  wa_deudor-ref_key_3  = ' '.                                "Clave ref3
  wa_deudor-comp_code  = wa_header-comp_code.                "Sociedad
  wa_deudor-bus_area   = ' '.                                "Division
  wa_deudor-pmnttrms   = ' '.                                 "Cond. pago
  wa_deudor-dsct_days1 = '0'.                                "Dias  1
  wa_deudor-alloc_nmbr = ' '.                                "Asignacion
  wa_deudor-item_text  = wa_lg_sgtxt.                        "Texto posicion
  wa_deudor-pymt_meth  = wa_lg_zlsch.                           "Via de pago
  wa_deudor-sp_gl_ind  = ' '.                                "CME
  wa_deudor-bank_id    = wa_lg_hbkid.                         "Clave de banco
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
FORM currency_suma  USING    p_conta.
  CLEAR wa_currency.
  wa_currency-itemno_acc = p_conta.
  wa_currency-curr_type  = '00'.
  wa_currency-currency   = 'CLP'.
  wa_currency-amt_doccur = wa_total_doc.
  wa_currency-amt_doccur = wa_currency-amt_doccur * -1.
  APPEND wa_currency TO ti_currency.
ENDFORM.                    " CURRENCY_suma

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
ENDFORM.

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
FORM extension  USING    p_conta.
*
***Se usará la función ZINTERFACE_RWBAPI01
  DATA: posicion TYPE bseg-buzei.
*
  IF NOT wa_lg_rut_ter IS INITIAL.
    CLEAR wa_extension1.
    posicion = p_conta.
    wa_extension1-field1 = posicion.
    CONCATENATE wa_extension1-field1
                'ZZRUT_TERC'
                wa_lg_rut_ter
                INTO wa_extension1-field1.
    APPEND wa_extension1 TO ti_extension1.
  ENDIF.
*
*  IF NOT p_prestacion IS INITIAL.
*    CLEAR wa_extension1.
*    posicion = p_conta.
*    wa_extension1-field1 = posicion.
*    CONCATENATE wa_extension1-field1
*                'ZZPRESTAC'
*                p_prestacion
*                INTO wa_extension1-field1.
*    APPEND wa_extension1 TO ti_extension1.
*  ENDIF.
*
*  IF NOT p_unid IS  INITIAL.
*    CLEAR wa_extension1.
*    posicion = p_conta.
*    wa_extension1-field1 = posicion.
*    CONCATENATE wa_extension1-field1
*                'ZZUNID_PRO'
*                p_unid
*                INTO wa_extension1-field1.
*    APPEND wa_extension1 TO ti_extension1.
*  ENDIF.
*
  IF NOT wa_lg_desc_est IS INITIAL.
    CLEAR wa_extension1.
    posicion = p_conta.
    wa_extension1-field1 = posicion.
    CONCATENATE wa_extension1-field1
                'ZZDESC_EST'
                wa_lg_desc_est
                INTO wa_extension1-field1.
    APPEND wa_extension1 TO ti_extension1.
  ENDIF.
*
  IF NOT wa_lg_motemi IS INITIAL.
    CLEAR wa_extension1.
    posicion = p_conta.
    wa_extension1-field1 = posicion.
    CONCATENATE wa_extension1-field1
                'ZZMOT_EMIS'
                wa_lg_motemi
                INTO wa_extension1-field1.
    APPEND wa_extension1 TO ti_extension1.
  ENDIF.
*
  IF NOT wa_lg_agencia IS INITIAL.
    CLEAR wa_extension1.
    posicion = p_conta.
    wa_extension1-field1 = posicion.
    CONCATENATE wa_extension1-field1
                'ZZ_AGENCIA'
                wa_lg_agencia
                INTO wa_extension1-field1.
    APPEND wa_extension1 TO ti_extension1.
  ENDIF.
ENDFORM.                    " EXTENSION

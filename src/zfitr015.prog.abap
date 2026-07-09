*&---------------------------------------------------------------------*
*& Report: ZFITR015                                                    *
*& Author: VisionOne                                                   *
*& Description: Generar archivo de pagos para el Banco BCI.            *
*& Date: 18-08-2021                                                    *
*& Transport Number: < ECDKXXXXX >                                     *
*&---------------------------------------------------------------------*
REPORT zfitr015 NO STANDARD PAGE HEADING
                                   LINE-COUNT 60
                                   LINE-SIZE 132.
*----------------------------------------------------------------------*
* Tablas usadas.
*----------------------------------------------------------------------*
TABLES : reguh,              "  Datos cabecera del programa de pagos bancos
         regup,              "  Datos detalle  del programa de pagos bancos
         bkpf,               "  Datos cabecera documento para Contabilidad
         bseg,               "  Datos segmento documento para Contabilidad
         bsak,               "  Datos contabilidad indice por acreedores
         bsik,               "  Datos contabilidad indice por acreedores
         payr,               "  Archivo de medio de Pago
         lfa1,               "  Maestro de proveedores (parte general)
         lfb1,               "  Maestro de proveedores (sociedad)
         t001,               "  Sociedades
         t012,               "  Bancos Propios
         t012t,              "  Cuentas en Bancos Propios
         zfolio_pagobanco,   "  Folios pagos sociedad bancos
         zlog_pago_bancos,   "  Log pagos sociedad bancos
         zfimotemisan,       "  Equivalencias causales para HUB Santander
         zfitr005.           "  Datos base para pagos banco, formato y cuentas
*&---------------------------------------------------------------------*
*&      Definiciones de Datos variables de programa
*&---------------------------------------------------------------------*
DATA : BEGIN OF tabla_00 OCCURS 0.
         INCLUDE STRUCTURE reguh.
       DATA : END OF tabla_00.

DATA: zaldt            LIKE reguh-zaldt,
      xblnr            LIKE bkpf-xblnr,
      bktxt            LIKE bkpf-bktxt,
      total            LIKE bseg-dmbtr,
      valut            LIKE reguh-valut,
      zzmot_emis       LIKE bseg-zzmot_emis,
      asignacion       LIKE bseg-zuonr,
      gjahr            LIKE bkpf-gjahr,
      belnr            LIKE bkpf-belnr,
      cuenta           LIKE reguh-ubhkt,
      cuenta_2         LIKE reguh-ubhkt,
      contabilizar(1),
      monto_z          LIKE bseg-dmbtr,
      lins(07)         TYPE c VALUE 0,
      lineas(5)        TYPE n,
      sumpagos(15)     TYPE n,
      contar(6)        TYPE n,
      contarnvo(5)     TYPE n,
      contarant(5)     TYPE n,
      contardoc(6)     TYPE n,
      sumpagosa(15)    TYPE n,
      sumpagosn(15)    TYPE n,
      secuencia(2)     TYPE n,
      archivo_a(130)   TYPE c,
      archivo_s(130)   TYPE c,
      archivo_1s(130)  TYPE c,
      v_format         TYPE zfitr005-zformat,
      v_adrnr          TYPE adrc-addrnumber,
      f_adrnr          TYPE adrc-addrnumber,
      v_banco          LIKE t012-bankl VALUE '016',
      v_rut(10)        TYPE c,
      v_rut15(15)      TYPE c  VALUE '000000000000000',
      f_rut(10)        TYPE c,
      numero(9)        TYPE n,
      numero11(11)     TYPE n,
      numero14(14)     TYPE n,
      num_c(8)         TYPE c,
      dv,
      v_flag,
      indice           TYPE sy-tabix,
      v_reg            TYPE sy-tfill,
      v_hbkid          TYPE reguh-hbkid,
      v_ct(20)         TYPE c,
      folio_aux(15),
      v_mail           TYPE adr6-smtp_addr,
      td,
      tipdoc(4)        TYPE c,
      v_monto(15),
      v_monto13(13),
      v_monto_temp(15),
      v_doc(15)        TYPE c,
      v_cod(3)         TYPE c,
      v_cta(18)        TYPE c,
      v_vta(18)        TYPE c,
      v_cla(15)        TYPE c,
      v_rutn(8)        TYPE c,
      v_rutd(1)        TYPE c,
      v_apellidop(15)  TYPE c,
      v_apellidom(15)  TYPE c,
      v_nombres(15)    TYPE c,
      v_rutn2(8)       TYPE c,
      v_rutd2(1)       TYPE c,
      v_apellidop2(15) TYPE c,
      v_apellidom2(15) TYPE c,
      v_nombres2(15)   TYPE c,
      nomban(30)       TYPE c,
      nombrefuncion    TYPE rs38l-name, "(10) TYPE c,
      tippro(1),
      nvoant(1),
      cuarta(1),
      forma(3),
      numsan(2)        TYPE n,
      secw(3)          TYPE n,
      letsan(2),
      sw,
      resp(1),
      lv_subrc         TYPE sysubrc,
      lv_subrc_sv      TYPE sysubrc.

DATA:  BEGIN OF tlaufk OCCURS 1.
         INCLUDE STRUCTURE ilaufk.
       DATA:  END OF tlaufk.

DATA lv_dynpro_prog    LIKE d020s-prog.

INCLUDE zbatchinput_v2.

DATA: ti_adrc       TYPE adrc       OCCURS 0 WITH HEADER LINE,
      t_items       TYPE bapi3008_2 OCCURS 0 WITH HEADER LINE,
      ti_set_fac    LIKE setleaf    OCCURS 0 WITH HEADER LINE,
      ti_set_ncr    LIKE setleaf    OCCURS 0 WITH HEADER LINE,
      ti_bsak       LIKE bsak       OCCURS 0 WITH HEADER LINE,
      ti_exc        LIKE zfitr005   OCCURS 0 WITH HEADER LINE,
      itab          TYPE TABLE OF bdcmsgcoll WITH HEADER LINE,
      lt_dynpfields LIKE dynpread   OCCURS 1 WITH HEADER LINE.

DATA : BEGIN OF file OCCURS 0,
         linea(640) TYPE c.
DATA : END OF file.
DATA : BEGIN OF file1 OCCURS 0,
         linea(610) TYPE c.
DATA : END OF file1.

DATA : BEGIN OF file2 OCCURS 0,
         linea(581) TYPE c.
DATA : END OF file2.
DATA : BEGIN OF file3 OCCURS 0,
         linea TYPE string.
DATA : END OF file3.

DATA: t_est  TYPE reguh.
DATA: dirpc  TYPE string.

DATA : gv_forma TYPE zeformat.
DATA : BEGIN OF file_nvo OCCURS 0,
         linea(400) TYPE c.
DATA : END OF file_nvo.

CONSTANTS: formato     TYPE zfitr005-zformat  VALUE 'NVO',
           header_soc  VALUE '1',
           header_prov VALUE '2',
           posiciones  VALUE '3'.

RANGES: r_fac FOR bkpf-blart,
        r_ncr FOR bkpf-blart.

*----------------------------------------------------------------------*
* Parametros Recepción de datos
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK marco1 WITH FRAME TITLE TEXT-001.

PARAMETERS : bukrs    LIKE bkpf-bukrs             OBLIGATORY,
             v_fecha  LIKE reguh-laufd            OBLIGATORY,
             v_nomina LIKE f110v-laufi            OBLIGATORY.

SELECTION-SCREEN SKIP 1.
* INI - WALDO ALARCON - VISIONONE - ASIGNACION 564
PARAMETERS  : v_nrotra   LIKE  zlog_pago_bancos-nrotran DEFAULT '1' NO-DISPLAY.
PARAMETERS  : p_conf RADIOBUTTON GROUP uno MODIF ID del,
              p_otro RADIOBUTTON GROUP uno MODIF ID del DEFAULT 'X'.
* FIN - WALDO ALARCON - VISIONONE - ASIGNACION 564

SELECTION-SCREEN SKIP 1.
PARAMETERS  : server      TYPE string MODIF ID sv.
*PARAMETERS  : archivo     TYPE string DEFAULT 'C:\TRANSFER\'.
PARAMETERS  : archivo     TYPE string.

SELECTION-SCREEN SKIP 1.
PARAMETERS :
*            Par_VV  DEFAULT ' '.
             par_VV AS CHECKBOX.
SELECTION-SCREEN SKIP 1.

PARAMETERS : par_tes RADIOBUTTON GROUP test       " Ejecución en Test
                     DEFAULT 'X' USER-COMMAND pro,
             par_di  RADIOBUTTON GROUP test.     " Ejecución real

SELECTION-SCREEN END OF BLOCK marco1 .

SELECTION-SCREEN BEGIN OF BLOCK marco2 WITH FRAME TITLE TEXT-002.
PARAMETERS :         v_fecpag  LIKE reguh-laufd MODIF ID im1. "Se agrega FECHA DE PAGO PARA GENERACION DE TEXT 29-03-2021
SELECTION-SCREEN END   OF BLOCK marco2 .

AT SELECTION-SCREEN OUTPUT.
  PERFORM invisible.

AT SELECTION-SCREEN ON BLOCK marco1.
* INI - WALDO ALARCON - VISIONONE - ASIGNACION 564
  IF par_di EQ 'X'.
    PERFORM lee_ruta_server CHANGING server archivo.
  ELSE.
    CLEAR server.
  ENDIF.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE rutn rutd apellidop apellidom nombres
*                rutn2 rutd2 apellidop2 apellidom2 nombres2
*     FROM ZFITR026
*     INTO (v_rutn, v_rutd, v_apellidoP, V_apellidom, v_nombres,
*           v_rutn2, v_rutd2, v_apellidoP2, V_apellidom2, v_nombres2)
*    WHERE bukrs = bukrs AND
*          BANKS = 'CL'  AND
*          BANKL = '016'.
*
* NEW CODE
  SELECT rutn rutd apellidop apellidom nombres
                rutn2 rutd2 apellidop2 apellidom2 nombres2
  UP TO 1 ROWS 
     FROM ZFITR026
     INTO (v_rutn, v_rutd, v_apellidoP, V_apellidom, v_nombres,
           v_rutn2, v_rutd2, v_apellidoP2, V_apellidom2, v_nombres2)
    WHERE bukrs = bukrs AND
          BANKS = 'CL'  AND
          BANKL = '016' ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

  IF Par_VV = 'X'.
     IF sy-subrc <> 0.
       MESSAGE e004(zfi) WITH 'Seleciono Retiro VV y sociedad ' bukrs
                              'No esta en tabla ZFITR026'.
     endif.
  endif.
* FIN - WALDO ALARCON - VISIONONE - ASIGNACION 564

AT SELECTION-SCREEN ON VALUE-REQUEST FOR archivo.
  CALL METHOD cl_gui_frontend_services=>directory_browse
    EXPORTING
      window_title    = 'Carpeta de Almacenamiento'
      initial_folder  = 'C:\'
    CHANGING
      selected_folder = archivo.
*                                                       FIN
*&---------------------------------------------------------------------*
*&     Validación de parámetros ingresados
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN ON bukrs.
  AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
     ID 'BUKRS' FIELD bukrs.
  IF sy-subrc <> 0.
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

AT SELECTION-SCREEN ON VALUE-REQUEST FOR v_fecha.
  REFRESH lt_dynpfields.
  lt_dynpfields-fieldname = 'BUKRS'.
  APPEND lt_dynpfields.

  lv_dynpro_prog = sy-repid.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      dyname     = lv_dynpro_prog
      dynumb     = '1000'
    TABLES
      dynpfields = lt_dynpfields.

  SORT lt_dynpfields .
  READ TABLE lt_dynpfields INDEX 1.
  bukrs = lt_dynpfields-fieldvalue .
  TRANSLATE bukrs TO UPPER CASE.

  REFRESH tlaufk.
  tlaufk-laufk = space.
  tlaufk-sign  = 'I'.
  APPEND tlaufk.
  CALL FUNCTION 'ZF4_ZAHLLAUF'
    EXPORTING
      f1typ = 'D'
      f2nme = 'F110V-LAUFI'
      bukrs = bukrs
      banco = '504'
    IMPORTING
      laufd = v_fecha
      laufi = v_nomina
    TABLES
      laufk = tlaufk.

  REFRESH lt_dynpfields.
  lt_dynpfields-fieldname = 'V_NOMINA'.
  APPEND lt_dynpfields.

  lt_dynpfields-fieldname = 'ARCHIVO'.
  APPEND lt_dynpfields.

  lv_dynpro_prog = sy-repid.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      dyname     = lv_dynpro_prog
      dynumb     = '1000'
    TABLES
      dynpfields = lt_dynpfields.

  READ TABLE lt_dynpfields INDEX 1.
  lt_dynpfields-fieldvalue = v_nomina.
  SORT lt_dynpfields .
  MODIFY  lt_dynpfields INDEX 1.

  READ TABLE lt_dynpfields INDEX 2.
  lt_dynpfields-fieldvalue = archivo.

  SORT lt_dynpfields .
  MODIFY  lt_dynpfields INDEX 2.

  CALL FUNCTION 'DYNP_VALUES_UPDATE'
    EXPORTING
      dyname     = lv_dynpro_prog
      dynumb     = '1000'
    TABLES
      dynpfields = lt_dynpfields.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR v_nomina.
  REFRESH lt_dynpfields.
  lt_dynpfields-fieldname = 'BUKRS'.
  APPEND lt_dynpfields.

  lv_dynpro_prog = sy-repid.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      dyname     = lv_dynpro_prog
      dynumb     = '1000'
    TABLES
      dynpfields = lt_dynpfields.


  READ TABLE lt_dynpfields INDEX 1.
  bukrs = lt_dynpfields-fieldvalue .
  TRANSLATE bukrs TO UPPER CASE.

  REFRESH tlaufk.
  tlaufk-laufk = space.
  tlaufk-sign  = 'I'.
  APPEND tlaufk.
  CALL FUNCTION 'ZF4_ZAHLLAUF'
    EXPORTING
      f1typ = 'I'
      f2nme = 'F110V-LAUFD'
      bukrs = bukrs
      banco = '027'
    IMPORTING
      laufd = v_fecha
      laufi = v_nomina
    TABLES
      laufk = tlaufk.

  REFRESH lt_dynpfields.
  lt_dynpfields-fieldname = 'V_FECHA'.
  APPEND lt_dynpfields.
  lt_dynpfields-fieldname = 'ARCHIVO'.
  APPEND lt_dynpfields.

  lv_dynpro_prog = sy-repid.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      dyname     = lv_dynpro_prog
      dynumb     = '1000'
    TABLES
      dynpfields = lt_dynpfields.

  READ TABLE lt_dynpfields INDEX 1.
  CONCATENATE v_fecha+06(2) '.' v_fecha+04(2) '.' v_fecha+0(4) INTO lt_dynpfields-fieldvalue.
  SORT lt_dynpfields .
  MODIFY  lt_dynpfields INDEX 1.

  READ TABLE lt_dynpfields INDEX 2.
  CONCATENATE 'C:\TRANSFER\' bukrs '_BCI' '_' sy-datum '_' sy-uzeit '.txt' INTO
   lt_dynpfields-fieldvalue.
  SORT lt_dynpfields .
  MODIFY  lt_dynpfields INDEX 2.

  CALL FUNCTION 'DYNP_VALUES_UPDATE'
    EXPORTING
      dyname     = lv_dynpro_prog
      dynumb     = '1000'
    TABLES
      dynpfields = lt_dynpfields.

*AT SELECTION-SCREEN.

*&---------------------------------------------------------------------*
*&   Inicialización de tablas internas
*&---------------------------------------------------------------------*
INITIALIZATION.

  CLEAR:   r_fac,
           r_ncr,
           ti_set_fac,
           ti_set_ncr.

  REFRESH: r_fac,
           r_ncr,
           ti_set_fac,
           ti_set_ncr.
*&---------------------------------------------------------------------*
*&     Carga Clases de Documento, Facturas y N. Crédito
*&---------------------------------------------------------------------*

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT *
*  FROM setleaf
*  INTO CORRESPONDING FIELDS OF TABLE  ti_set_fac
*  WHERE setname = 'ZFITR001'.
*
* NEW CODE
  SELECT *

  FROM setleaf
  INTO CORRESPONDING FIELDS OF TABLE  ti_set_fac
  WHERE setname = 'ZFITR001' ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

  IF ti_set_fac[] IS INITIAL.
    MESSAGE e899(v1) WITH 'Revisar Set de Datos Cl. Doctos Factura'.
    EXIT.
  ENDIF.

  LOOP AT ti_set_fac.
    r_fac-sign      = 'I'.
    r_fac-option    = 'EQ'.
    r_fac-low       = ti_set_fac-valfrom.
    APPEND r_fac.
    CLEAR  r_fac.
  ENDLOOP.

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT *
*  FROM setleaf
*  INTO CORRESPONDING FIELDS OF TABLE  ti_set_ncr
*  WHERE setname = 'ZFITR002'.
*
* NEW CODE
  SELECT *

  FROM setleaf
  INTO CORRESPONDING FIELDS OF TABLE  ti_set_ncr
  WHERE setname = 'ZFITR002' ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

  IF ti_set_ncr[] IS INITIAL.
    MESSAGE e899(v1) WITH 'Revisar Set de Datos Cl. Doctos N.Crédito'.
    EXIT.
  ENDIF.

  LOOP AT ti_set_ncr.
    r_ncr-sign      = 'I'.
    r_ncr-option    = 'EQ'.
    r_ncr-low       = ti_set_ncr-valfrom.
    APPEND r_ncr.
    CLEAR  r_ncr.
  ENDLOOP.

*&---------------------------------------------------------------------*
*&     Inicio de Proceso
*&---------------------------------------------------------------------*
START-OF-SELECTION.

  IF archivo IS INITIAL.
    MESSAGE e899(v1) WITH 'No ingreso el PATH para registro de archivo banco'.
    EXIT.
  ENDIF.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE adrnr
*            FROM t001
*            INTO v_adrnr
*  WHERE bukrs EQ t001-bukrs.
*
* NEW CODE
  SELECT adrnr
  UP TO 1 ROWS 
            FROM t001
            INTO v_adrnr
  WHERE bukrs EQ t001-bukrs ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

  f_adrnr = v_adrnr.

  IF f_adrnr IS NOT INITIAL.
    CALL FUNCTION 'RTP_US_DB_ADRC_READ'
      EXPORTING
        i_address_number = f_adrnr
      IMPORTING
        e_adrc           = ti_adrc
      EXCEPTIONS
        not_found        = 1
        OTHERS           = 2.
  ENDIF.

  v_rut = ti_adrc-sort1.

  IF v_rut IS NOT INITIAL.
    SPLIT v_rut AT '-' INTO num_c dv.
    numero = num_c.
    CONCATENATE numero dv INTO f_rut.
  ENDIF.

  IF par_di = 'X'.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE *
*       FROM zlog_pago_bancos
*        WHERE bukrs = bukrs
*          AND ubnkl = v_banco
*          AND laufd = v_fecha
*          AND laufi = v_nomina.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS 
       FROM zlog_pago_bancos
        WHERE bukrs = bukrs
          AND ubnkl = v_banco
          AND laufd = v_fecha
          AND laufi = v_nomina ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
*&---------------------------------------------------------------------*
*&     Si encuentra registro de proceso previo
*&         Solicita confirmar
*&         Inhibe la Contabilización
*&---------------------------------------------------------------------*
    IF sy-subrc = 0.

      CALL FUNCTION 'POPUP_TO_CONFIRM'
        EXPORTING
          titlebar              = 'Confirmación '
          text_question         = 'Archivo ya Generado y Contabilizado. ¿Desea Continuar?'
          default_button        = '2'
          display_cancel_button = 'X'
        IMPORTING
          answer                = resp.

      IF  resp <> '1'.
        LEAVE PROGRAM.
      ENDIF.

      contabilizar = 'N'.

    ENDIF.

  ENDIF.
*&---------------------------------------------------------------------*
*&     Si no se informa número de transacción
*&            Se despliega error y termina programa
*&---------------------------------------------------------------------*
  IF v_nrotra IS INITIAL.
    MESSAGE i004(zfi) WITH 'Debe Ingresar Numero Transferencia'.
  ELSE.
    PERFORM cargo_datos.
    IF par_di = 'X'.
      SUBMIT zjob_ins_transfer AND RETURN
              WITH bukrs    = bukrs
              WITH v_fecha  = v_fecha
              WITH v_nomina = v_nomina.
    ENDIF.
  ENDIF.

END-OF-SELECTION.

*&---------------------------------------------------------------------*
*&      Form  Invisible
*&---------------------------------------------------------------------*
FORM invisible.

  IF ( bukrs = 'CL35' OR bukrs = 'CL44' OR
       bukrs = 'CL36' OR bukrs = 'CL55' OR
       bukrs = 'CL38' ) AND v_banco = '016'.

    LOOP AT SCREEN.
      IF screen-group1 = 'IM1'.
        screen-input = 1. " Campo editable
        screen-invisible = 0. " Campo invisible
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ELSE.
    LOOP AT SCREEN.
      IF screen-group1 = 'IM1'.
        screen-input = 0. " Campo no editable/grisado
        screen-invisible = 1. " Campo invisible
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.
*
  LOOP AT SCREEN.
    CASE screen-group1.
      WHEN 'SV'.
        screen-input  = 0. " Campo no editable/grisado
      WHEN 'DEL'.
        screen-active = 0.
    ENDCASE.
    MODIFY SCREEN.
  ENDLOOP.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  cargo_datos para poblar TABLA_00
*&---------------------------------------------------------------------*

FORM cargo_datos.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE * FROM reguh
*                WHERE  laufd     = v_fecha
*                  AND  laufi     = v_nomina
*                  AND  zbukr     = bukrs.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  FROM reguh
                WHERE  laufd     = v_fecha
                  AND  laufi     = v_nomina
                  AND  zbukr     = bukrs ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

  IF sy-subrc <> 0.
    MESSAGE e004(zfi) WITH 'Nomina no corresponde a Sociedad' bukrs.
  ENDIF.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE * FROM reguh
*                WHERE  laufd   = v_fecha
*                  AND  laufi   = v_nomina
*                  AND  zbukr   = bukrs
*                  AND  ubnkl   = v_banco
*                  AND  xvorl   = ' '.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  FROM reguh
                WHERE  laufd   = v_fecha
                  AND  laufi   = v_nomina
                  AND  zbukr   = bukrs
                  AND  ubnkl   = v_banco
                  AND  xvorl   = ' ' ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

  IF sy-subrc <> 0.
    MESSAGE e004(zfi) WITH 'Nomina sin movimientos a Generar'.
  ENDIF.

  nomban = 'NO esta en tabla de Bancos'.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE * FROM t012t
*                 WHERE bukrs      = bukrs
*                   AND hbkid      = reguh-hbkid.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  FROM t012t
                 WHERE bukrs      = bukrs
                   AND hbkid      = reguh-hbkid ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

  IF sy-subrc = 0.
    nomban = t012t-text1.
  ELSE.
    MESSAGE e004(zfi) WITH 'Banco no esta en tabla (t012T) ' reguh-hbkid.
  ENDIF.

  CLEAR contar.
  CLEAR contarant.
  CLEAR contarnvo.
  CLEAR contardoc.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE * FROM zfolio_pagobanco  WHERE bukrs  = reguh-zbukr
*                                         AND   ubnkl  = reguh-ubnkl
*                                         AND   codigo = '001'.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  FROM zfolio_pagobanco  WHERE bukrs  = reguh-zbukr
                                         AND   ubnkl  = reguh-ubnkl
                                         AND   codigo = '001' ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
  IF sy-subrc <> 0.
    MESSAGE e004(zfi) WITH 'Sociedad-Banco no tiene Folios'.
  ENDIF.

* Rescatamos Datos LOOP de lectura con SELECT a REGUH.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT *  FROM  reguh
*           WHERE  laufd      = v_fecha
*             AND  laufi      = v_nomina
*             AND  zbukr      = bukrs
*             AND  ubnkl      = v_banco
*             AND  xvorl      = ' '.
*
* NEW CODE
  SELECT *
  FROM  reguh
           WHERE  laufd      = v_fecha
             AND  laufi      = v_nomina
             AND  zbukr      = bukrs
             AND  ubnkl      = v_banco
             AND  xvorl      = ' ' ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

    contar   = contar   + 1.
    sumpagos = sumpagos + ( reguh-rbetr * -100 ).
    contardoc = contardoc + reguh-rpost.

    IF ( reguh-stcd1 IS INITIAL ) OR ( reguh-zstc1 IS INITIAL ).
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE stcd1 INTO reguh-stcd1
*             FROM lfa1 WHERE lifnr = reguh-lifnr.
*
* NEW CODE
      SELECT stcd1
      UP TO 1 ROWS  INTO reguh-stcd1
             FROM lfa1 WHERE lifnr = reguh-lifnr ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    ENDIF.

    IF ( NOT reguh-stcd1 IS INITIAL ) OR ( NOT reguh-zstc1 IS INITIAL ).
      MOVE-CORRESPONDING reguh TO tabla_00.

      tabla_00-xavis = ' '.
* revisamos si paga a un beneficiario alternativo
      IF tabla_00-stcd1 <> tabla_00-zstc1.
        tabla_00-stcd1   = tabla_00-zstc1.
        tabla_00-name1   = tabla_00-znme1.
        tabla_00-ort01   = tabla_00-zort1.
        tabla_00-stras   = tabla_00-zstra.
      ENDIF.

      IF contar = 1.
* Rescata motivos de emisión

        CONCATENATE  reguh-zaldt+6(2) reguh-zaldt+4(2) reguh-zaldt+0(4) INTO zaldt.
        CONCATENATE  reguh-valut+6(2) reguh-valut+4(2) reguh-valut+0(4) INTO valut.

        cuenta = reguh-ubhkt.

        CONCATENATE cuenta+0(9) '3' INTO cuenta_2.
"        cuenta  = cuenta_2. HCD 16052024

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT  SINGLE bktxt INTO  bktxt FROM bkpf
*                             WHERE bukrs = bukrs
*                               AND belnr = reguh-vblnr
*                               AND gjahr = reguh-zaldt(4).
*
* NEW CODE
        SELECT bktxt
        UP TO 1 ROWS  INTO  bktxt FROM bkpf
                             WHERE bukrs = bukrs
                               AND belnr = reguh-vblnr
                               AND gjahr = reguh-zaldt(4) ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE  * FROM  regup WHERE laufd = reguh-laufd
*                                       AND laufi = reguh-laufi
*                                       AND xvorl = reguh-xvorl
*                                       AND zbukr = reguh-zbukr
*                                       AND lifnr = reguh-lifnr
*                                       AND kunnr = reguh-kunnr
*                                       AND empfg = reguh-empfg
*                                       AND vblnr = reguh-vblnr.
*
* NEW CODE
        SELECT *
        UP TO 1 ROWS  FROM  regup WHERE laufd = reguh-laufd
                                       AND laufi = reguh-laufi
                                       AND xvorl = reguh-xvorl
                                       AND zbukr = reguh-zbukr
                                       AND lifnr = reguh-lifnr
                                       AND kunnr = reguh-kunnr
                                       AND empfg = reguh-empfg
                                       AND vblnr = reguh-vblnr ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE  * FROM  bseg  WHERE bukrs = regup-bukrs
*                                       AND belnr = regup-belnr
*                                       AND gjahr = regup-gjahr
*                                       AND buzei = regup-buzei.
*
* NEW CODE
        SELECT *
        UP TO 1 ROWS  FROM  bseg  WHERE bukrs = regup-bukrs
                                       AND belnr = regup-belnr
                                       AND gjahr = regup-gjahr
                                       AND buzei = regup-buzei ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

        IF sy-subrc = 0.
          zzmot_emis = bseg-zzmot_emis.
        ENDIF.

        cuarta = ' '.
        forma  = 'ANT'.

        CLEAR v_hbkid.

        v_hbkid = tabla_00-hbkid.
*
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE * INTO ti_exc
*            FROM zfitr005 WHERE bukrs = bukrs
*                            AND hbkid = v_hbkid
*                            AND zmotiv = zzmot_emis.
*
* NEW CODE
        SELECT *
        UP TO 1 ROWS  INTO ti_exc
            FROM zfitr005 WHERE bukrs = bukrs
                            AND hbkid = v_hbkid
                            AND zmotiv = zzmot_emis ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
        IF sy-subrc = 0.
          forma  = ti_exc-zformat.
          IF ti_exc-zflag IS NOT INITIAL.
            cuarta = '4'.
          ENDIF.
        ELSE.
          MESSAGE e004(zfi) WITH 'No existe SOC_BCO_MOTIVO  en tabla ZFITR005: ' zzmot_emis.
        ENDIF.

        IF forma <> 'ANT'.
          nvoant = '2'.
        ELSE.
          nvoant = '1'.
        ENDIF.

      ENDIF.

      tabla_00-zpfor = forma.
      tabla_00-xavis = cuarta.
      REPLACE ALL OCCURRENCES OF '-' IN  tabla_00-zbnkn WITH ''.
      REPLACE ALL OCCURRENCES OF '.' IN  tabla_00-zbnkn WITH ''.
      REPLACE ALL OCCURRENCES OF '/' IN  tabla_00-zbnkn WITH ''.
      REPLACE ALL OCCURRENCES OF '_' IN  tabla_00-zbnkn WITH ''.

      TRANSLATE tabla_00-name1 USING 'ÁAÉEÍIÓOÚUáaéeíióoúuÑNñn; : \ ~ ¨ , / % $S| ° #N& '.
*****   MOTIVO EMISION NUMERICA EN TABLA_00 *********
      tabla_00-dtws4 = numsan.
      APPEND tabla_00.
    ENDIF.
  ENDSELECT.

*Procesamos Datos

  secw = v_nomina+2(3).

  numero11 = numero.
  numero14 = numero.
  IF contar > 0.
    CONCATENATE 'ZBANCO_' v_banco INTO nombrefuncion.
    IF par_di = 'X'.
      CONCATENATE archivo bukrs v_fecha v_banco v_nomina '.txt'
          INTO archivo_a.
* INI - WALDO ALARCON - VISIONONE - ASIGNACION 564
      IF server IS NOT INITIAL.
        CONCATENATE server bukrs v_fecha v_banco v_nomina '.txt'
            INTO archivo_s.
      ENDIF.
* FIN - WALDO ALARCON - VISIONONE - ASIGNACION 564
      IF dirpc IS NOT INITIAL.
        CONCATENATE server bukrs v_fecha v_banco v_nomina '.txt'
            INTO archivo_1s.
      ENDIF.
      PERFORM procesar_funcion.
    ELSE.

      CONCATENATE archivo 'TEST' bukrs v_fecha v_banco v_nomina '.txt'
         INTO archivo_a.
* INI - WALDO ALARCON - VISIONONE - ASIGNACION 564
      IF server IS NOT INITIAL.
        CONCATENATE server 'TEST' bukrs v_fecha v_banco v_nomina '.txt'
            INTO archivo_s.
      ENDIF.
* FIN - WALDO ALARCON - VISIONONE - ASIGNACION 564
      PERFORM procesar_funcion.
    ENDIF.
  ENDIF.
ENDFORM.                    "cargo_datos
*&---------------------------------------------------------------------*
*&      Form  procesar funcion
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM procesar_funcion.
  DATA lv_confirming TYPE c.
*"     REFERENCE(TI_ADRC) LIKE  ADRC STRUCTURE  ADRC
*"     REFERENCE(PAR_DI) TYPE  CHAR01
*"     REFERENCE(CONTAR) TYPE  NUMC05
*"     REFERENCE(SUMPAGOS) TYPE  NUMC15
*"     REFERENCE(V_FECHA) TYPE  DATS
*"     REFERENCE(NVOANT) TYPE  CHAR01

  tippro = par_di.

  CALL FUNCTION 'FUNCTION_EXISTS'
    EXPORTING
      funcname           = nombrefuncion
    EXCEPTIONS
      function_not_exist = 1
      OTHERS             = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
* INI - WALDO ALARCON - VISIONONE - ASIGNACION 564
    CASE 'X'.
      WHEN p_conf.  lv_confirming = 'F'.
      WHEN OTHERS.  lv_confirming = 'G'.
    ENDCASE.
* FIN - WALDO ALARCON - VISIONONE - ASIGNACION 564

    CALL FUNCTION nombrefuncion
      EXPORTING
        tippro     = tippro
        contar     = contar
        sumpagos   = sumpagos
*       v_fecha    = v_fecha
        v_fecha    = v_fecpag
        nvoant     = nvoant
        contardoc  = contardoc
        confirming = lv_confirming "WALDO ALARCON - VISIONONE - ASIGNACION 564
        ret_VV     = Par_VV
      TABLES
        tabla_00   = tabla_00
        filesalida = file.

    DESCRIBE TABLE file.

    IF sy-tfill > 0.
      lineas = sy-tfill.
    ENDIF.

    IF par_di = 'X'.
      PERFORM bajar_archivo USING lv_subrc.
* INI - WALDO ALARCON - VISIONONE - ASIGNACION 564
      IF server IS NOT INITIAL.
        PERFORM bajar_archivo_server USING lv_subrc_sv.
      ENDIF.
* FIN - WALDO ALARCON - VISIONONE - ASIGNACION 564
      SKIP 2 .
      FORMAT COLOR 3 ON.
      IF lv_subrc EQ 0.
        WRITE : / 'Se genero archivo PC :', archivo_a.
      ELSE.
        WRITE : / 'NO Se genero archivo PC :', archivo_a.
      ENDIF.
* INI - WALDO ALARCON - VISIONONE - ASIGNACION 564
      IF server IS NOT INITIAL.
        SKIP 1 .
        IF lv_subrc_sv EQ 0.
          WRITE : / 'Se genero archivo SERVER :', archivo_s.
        ELSE.
          WRITE : / 'NO Se genero archivo SERVER :', archivo_s.
        ENDIF.
      ENDIF.
* FIN - WALDO ALARCON - VISIONONE - ASIGNACION 564
      SKIP 1 .
      WRITE : /10 'total pagos   : ', contar,
                  'total monto  : ',  sumpagos.
      IF contabilizar <> 'N'.
        PERFORM  contabilizacion.
      ENDIF.
      PERFORM  grabar_log.
      FORMAT COLOR 3 OFF.
    ELSE.
      PERFORM bajar_archivo USING lv_subrc.
      FORMAT COLOR 3 ON.
      IF lv_subrc EQ 0.
        WRITE : / 'Se generara el siguiente archivo PC :', archivo_a.
      ELSE.
        WRITE : / 'NO e generara el siguiente archivo PC :', archivo_a.
      ENDIF.
* INI - WALDO ALARCON - VISIONONE - ASIGNACION 564
      IF server IS NOT INITIAL.
        PERFORM bajar_archivo_server USING lv_subrc_sv.
      ENDIF.
      IF server IS NOT INITIAL.
        SKIP 1 .
        IF lv_subrc_sv EQ 0.
          WRITE : / 'Se generara el siguiente archivo SERVER :', archivo_s.
        ELSE.
          WRITE : / 'NO Se generara el siguiente archivo SERVER :', archivo_s.
        ENDIF.
      ENDIF.
      SKIP 1 .
* FIN - WALDO ALARCON - VISIONONE - ASIGNACION 564
      WRITE : /10 'total pagos  : ', contar,
                  'total monto  : ', sumpagos.
      FORMAT COLOR 3 OFF.
    ENDIF.
    CLEAR: lineas, monto_z.
  ENDIF.
ENDFORM.                    "procesar_funcion
*&---------------------------------------------------------------------*
*&      Form  bajar_archivo SUBRUTINA PARA PASAR A DOCUMENTO
*&---------------------------------------------------------------------*
FORM bajar_archivo USING p_subrc.
*--------------------*
  DATA : nombre_a  TYPE string.
*
  nombre_a = archivo_a.

  sy-subrc = 0.

*    IF par_di = 'X'.

  CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING
      filename                = nombre_a
      filetype                = 'ASC'
      confirm_overwrite       = 'X'
    TABLES
      data_tab                = file
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
  p_subrc = sy-subrc.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            INTO DATA(lv_mtext)
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    WRITE :/ 'error!!!!'  ,
           /  lv_mtext .
  ENDIF.
  secuencia = secuencia + 1.
* REFRESH file.
*---------------------------------------------------------------------
ENDFORM.                    "bajar_archivo

*&---------------------------------------------------------------------*
*&      Form  bajar_archivo_server
*&---------------------------------------------------------------------*
FORM bajar_archivo_server USING p_subrc.
*  DATA lv_mess TYPE string.
**
*  OPEN DATASET archivo_s FOR OUTPUT IN TEXT MODE
*                                    ENCODING DEFAULT
*                                    WITH SMART LINEFEED
*                                    MESSAGE lv_mess.
*  IF sy-subrc EQ 0.
*    LOOP AT file.
*      TRANSFER file-linea TO archivo_s.
*    ENDLOOP.
*    CLOSE DATASET archivo_s.
*  ELSE.
*    MESSAGE lv_mess TYPE 'I'.
*  ENDIF.

  DATA : nombre_a  TYPE string.
*
  nombre_a = archivo_s.

  sy-subrc = 0.

*    IF par_di = 'X'.

  CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING
      filename                = nombre_a
      filetype                = 'ASC'
      confirm_overwrite       = 'X'
    TABLES
      data_tab                = file
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
  p_subrc = sy-subrc.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            INTO DATA(lv_mtext)
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    WRITE :/ 'error!!!!'  ,
           /  lv_mtext .
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  GRABAR_LOG
*&---------------------------------------------------------------------*
FORM grabar_log.
  zlog_pago_bancos-bukrs = bukrs.
  zlog_pago_bancos-ubnkl = v_banco.
  SHIFT zlog_pago_bancos-ubnkl LEFT DELETING LEADING space.
  zlog_pago_bancos-laufd = v_fecha.
  zlog_pago_bancos-laufi = v_nomina.
  zlog_pago_bancos-fecha_gen = sy-datum.
  zlog_pago_bancos-hora_gen = sy-uzeit.
  zlog_pago_bancos-uname = sy-uname.
  CONCATENATE bukrs v_fecha v_nomina  secuencia INTO zlog_pago_bancos-nombre_arc.
  zlog_pago_bancos-total  = sumpagos.
  zlog_pago_bancos-lineas = lineas.
  zlog_pago_bancos-gjahr  =  gjahr.
  zlog_pago_bancos-belnr  =  belnr.
  zlog_pago_bancos-nrotran  =  v_nrotra.
  INSERT zlog_pago_bancos.

ENDFORM.                    "GRABAR_LOG
*&---------------------------------------------------------------------*
*&      Form  contabilizacion
*&---------------------------------------------------------------------*
FORM contabilizacion.
  DATA: valor(18) TYPE c.

  CLEAR bdcdata.
  REFRESH bdcdata.
  valor = sumpagos.
  REPLACE '.00' WITH '' INTO valor.
  CONDENSE valor NO-GAPS.
  total = sumpagos.
*
  CONCATENATE v_fecha v_nomina  secuencia INTO xblnr.

  PERFORM bdc_dynpro      USING 'SAPMF05A' '0100'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'RF05A-NEWKO'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM bdc_field       USING 'BKPF-BLDAT'
                                zaldt.
  PERFORM bdc_field       USING 'BKPF-BLART'
                                'SA'.
  PERFORM bdc_field       USING 'BKPF-BUKRS'
                                 bukrs.
  PERFORM bdc_field       USING 'BKPF-BUDAT'
                                zaldt.
  PERFORM bdc_field       USING 'BKPF-WAERS'
                                'CLP'.
  PERFORM bdc_field       USING 'BKPF-XBLNR'
                                xblnr.
  PERFORM bdc_field       USING 'BKPF-BKTXT'
                                bktxt.

  PERFORM bdc_field       USING 'RF05A-NEWBS'
                                 '40'.
  PERFORM bdc_field       USING 'RF05A-NEWKO'
                                cuenta.
  PERFORM bdc_dynpro      USING 'SAPMF05A' '0300'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'RF05A-NEWKO'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '/00'.

  PERFORM bdc_field       USING 'BSEG-WRBTR'
                                valor. "total. LSC
  PERFORM bdc_field       USING 'BSEG-VALUT'
                                 valut.
  PERFORM bdc_field       USING 'BSEG-ZUONR'
                                bktxt.
  PERFORM bdc_field       USING 'BSEG-SGTXT'
                                bktxt.
  PERFORM bdc_field       USING 'RF05A-NEWBS'
                                '50'.
  PERFORM bdc_field       USING 'RF05A-NEWKO'
                                cuenta_2.

  PERFORM bdc_dynpro      USING 'SAPLKACB' '0002'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=ENTE'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'COBL-ZZMOT_EMIS'.
  PERFORM bdc_field       USING 'COBL-ZZMOT_EMIS'
                                 zzmot_emis.

  PERFORM bdc_dynpro      USING 'SAPMF05A' '0300'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'BSEG-VALUT'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=BU'.
  PERFORM bdc_field       USING 'BSEG-WRBTR'
                                valor. "total. LSC
  PERFORM bdc_field       USING 'BSEG-VALUT'
                                valut.
  PERFORM bdc_field       USING 'BSEG-SGTXT'
                                bktxt.
  PERFORM bdc_field       USING 'BSEG-ZUONR'
                             bktxt.

  PERFORM bdc_dynpro      USING 'SAPLKACB' '0002'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=ENTE'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'COBL-ZZMOT_EMIS'.
  PERFORM bdc_field       USING 'COBL-ZZMOT_EMIS'
                                zzmot_emis.

  CALL TRANSACTION 'F-02' USING bdcdata
                                  MODE 'E'
                                  UPDATE 'S'
                                  MESSAGES INTO itab.

  LOOP AT itab.
    IF itab-msgid = 'F5' AND     itab-msgnr = '312'.
      belnr = itab-msgv1.
      gjahr = zaldt+4(4).
    ENDIF.

  ENDLOOP.

ENDFORM.                    "contabilizacion

TOP-OF-PAGE.
  WRITE : /1  t001-butxt,
           43  'ARCHIVO DE PAGO PROVEEDORES BANCO ' ,
           77  nomban,
           120 sy-datum,

          /120 sy-uzeit ,
          /27 'Identificación De Propuesta de Pago : ',
              'Fecha Nomina: ',v_fecha, ' Nomina:' ,  v_nomina ,
          120 sy-pagno.

  WRITE : / sy-uline(136).
*&---------------------------------------------------------------------*
*&      Form  BAJA_ARCHIVO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_FILE1  text
*----------------------------------------------------------------------*
FORM baja_archivo  TABLES t_tabla
                   USING  p_nombre_a.

  CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING
      filename                  = p_nombre_a
      filetype                  = 'ASC'
      confirm_overwrite         = 'X'
      trunc_trailing_blanks_eol = space
    TABLES
      data_tab                  = t_tabla
    EXCEPTIONS
      file_write_error          = 1
      no_batch                  = 2
      gui_refuse_filetransfer   = 3
      invalid_type              = 4
      no_authority              = 5
      unknown_error             = 6
      header_not_allowed        = 7
      separator_not_allowed     = 8
      filesize_not_allowed      = 9
      header_too_long           = 10
      dp_error_create           = 11
      dp_error_send             = 12
      dp_error_write            = 13
      unknown_dp_error          = 14
      access_denied             = 15
      dp_out_of_memory          = 16
      disk_full                 = 17
      dp_timeout                = 18
      file_not_found            = 19
      dataprovider_exception    = 20
      control_flush_error       = 21
      OTHERS                    = 22.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            INTO DATA(lv_mtext)
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    WRITE :/ 'error!!!!'  ,
           /  lv_mtext .
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  LEE_RUTA_SERVER
*&---------------------------------------------------------------------*
FORM lee_ruta_server  CHANGING p_server p_dirpc.
  DATA: prgname(40) TYPE c VALUE 'ZFITR015',
        lv_dirpc    TYPE string.
*
  CLEAR p_server.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT zruta zruta_respaldo INTO (p_server, lv_dirpc)
*    FROM ztparamftp  WHERE zbukr = bukrs
*                       AND zprog = prgname.
*
* NEW CODE
  SELECT zruta zruta_respaldo
 INTO (p_server, lv_dirpc)
    FROM ztparamftp  WHERE zbukr = bukrs
                       AND zprog = prgname ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
  ENDSELECT.

  IF p_server IS INITIAL AND bukrs IS NOT INITIAL.
    MESSAGE e899(fi) WITH 'Falta directorio del Servidor'
                          ',configurar en trx. ZPARFTP'.
  ENDIF.
  IF p_dirpc IS INITIAL.
    p_dirpc = lv_dirpc.
  ENDIF.
ENDFORM.

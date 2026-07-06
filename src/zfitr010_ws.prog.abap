*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES04 > *
*& Description: < ReSQ Correction > *
*& Date: <24-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
REPORT zfitr010 NO STANDARD PAGE HEADING
                                   LINE-COUNT 60
                                   LINE-SIZE 132.

*----------------------------------------------------------------------*
* Tablas usadas.
*----------------------------------------------------------------------*
TABLES : reguh,   "  Datos de pago del programa de pagos              02
         regup,
         bkpf,
         bseg,
         payr,     "  Cheque pago
         lfa1,    "  Maestro de proveedores (parte general)           02
         lfb1,
         t001,
         zfolio_bbva,
         zlog_bbva_ws,
         zlog_bbva_ws_det,
         zfitr005,
         zfitr006,
         zfitr008,
         zws_puerto.

DATA : BEGIN OF tabla_00 OCCURS 0.
         INCLUDE STRUCTURE reguh.
       DATA : END OF tabla_00.



DATA : BEGIN OF reg01 OCCURS 0,
         rut_prv(08)       TYPE n,
         rut_dvr(01)       TYPE c,
         identificador(15) TYPE c,
         nombre(45)        TYPE c,
         tipo_proceso(01)  TYPE c,
         cod_banco(03)     TYPE c,
         cuenta_abo(20)    TYPE c,
         destino(01)       TYPE c,
         monto_pago(09)    TYPE n,
       END OF reg01.

** V1 RVY 04.02.2021
DATA : BEGIN OF reg02 OCCURS 0,
         rut_prv(08)       TYPE n,
         rut_dvr(01)       TYPE c,
         identificador(15) TYPE c,
         nombre(45)        TYPE c,
         tipo_proceso(01)  TYPE c,
         cod_banco(03)     TYPE c,
         cuenta_abo(20)    TYPE c,
         destino(01)       TYPE c,
         monto_pago(09)    TYPE n,
         email_benef(80)   TYPE c,
       END OF reg02.
** V1 RVY 04.02.2021

DATA: zaldt           LIKE reguh-zaldt,
      xblnr           LIKE bkpf-xblnr,
      bktxt           LIKE bkpf-bktxt,
      total(15),
      valut           LIKE reguh-valut,
      zzmot_emis      LIKE bseg-zzmot_emis,
      gjahr           LIKE bkpf-gjahr,
      belnr           LIKE bkpf-belnr,
      cuenta          LIKE reguh-ubhkt,
      cuenta_2        LIKE reguh-ubhkt,
      contabilizar(1),
      ws_puerto(60)   TYPE c,
      resp(1).

DATA:    BEGIN OF tlaufk OCCURS 1.
           INCLUDE STRUCTURE ilaufk.
         DATA:    END OF tlaufk.

DATA lt_dynpfields LIKE dynpread OCCURS 1 WITH HEADER LINE.
DATA lv_dynpro_prog LIKE d020s-prog.

DATA: monto_z        LIKE bseg-dmbtr,
      lins(07)       TYPE c VALUE 0,
      lineas(5)      TYPE n,
      secuencia(2)   TYPE n,
      archivo_a(130) TYPE c.

INCLUDE zbatchinput.
DATA : itab TYPE TABLE OF bdcmsgcoll WITH HEADER LINE.

DATA : BEGIN OF it_modulo OCCURS 0,
         modulo      TYPE zfitr007-modulo,
         descripcion TYPE zfitr007-descripcion.
DATA : END OF it_modulo.

DATA : BEGIN OF it_servicios OCCURS 0,
         servicio    TYPE zfitr008-servicio,
         descripcion TYPE zfitr008-descripcion.
DATA : END OF it_servicios.
DATA: BEGIN OF it_match OCCURS 0,
        shlpname  LIKE ddshretval-shlpname,
        fieldname LIKE ddshretval-fieldname,
        recordpos LIKE ddshretval-recordpos,
        fieldval  LIKE ddshretval-fieldval,
        retfield  LIKE ddshretval-retfield,
      END OF it_match.

DATA : BEGIN OF file OCCURS 0,
         linea(400) TYPE c.
DATA : END OF file.
*----------------------------------------------------------------------*
* Parametros
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK marco1 WITH FRAME TITLE TEXT-001.
PARAMETER : bukrs     LIKE bkpf-bukrs     OBLIGATORY ,
            v_fecha   LIKE reguh-laufd    OBLIGATORY,
            v_nomina  LIKE f110v-laufi    OBLIGATORY,
* ini - Waldo Alarcón - Visionone - 03-02-2021
            p_viapag  LIKE reguh-rzawe    OBLIGATORY.
* fin - Waldo Alarcón - Visionone - 03-02-2021
PARAMETER  : v_nrotra   LIKE  zlog_bbva_vv-nrotran   OBLIGATORY  .
PARAMETER : v_modulo  LIKE zfitr008-modulo      OBLIGATORY,
            v_servi  LIKE zfitr008-servicio     OBLIGATORY ,
            v_fpago  LIKE bkpf-budat            OBLIGATORY,
            v_descr  LIKE zfitr008-descripcion  OBLIGATORY.

SELECTION-SCREEN SKIP 1.
SELECTION-SCREEN BEGIN OF BLOCK marco2 WITH FRAME TITLE TEXT-002.
PARAMETERS : par_tes RADIOBUTTON GROUP test       " Ejecución en Test
                     DEFAULT 'X' USER-COMMAND sel,
             par_di  RADIOBUTTON GROUP test,      " Ejecución real
* ini - Waldo Alarcón - Visionone - 03-02-2021
             par_rej RADIOBUTTON GROUP test.      " Re-Ejecución Test
* fin - waldo alarcón - visionone - 03-02-2021
SELECTION-SCREEN END OF BLOCK marco2.

* ini - Waldo Alarcón - Visionone - 03-02-2021
SELECTION-SCREEN BEGIN OF BLOCK marco3 WITH FRAME TITLE TEXT-003.
PARAMETERS : p_bajfil AS CHECKBOX USER-COMMAND baj MODIF ID sel.
PARAMETERS : p_file   TYPE string MODIF ID baj.
SELECTION-SCREEN END OF BLOCK marco3.
* fin - waldo alarcón - visionone - 03-02-2021
SELECTION-SCREEN END OF BLOCK marco1 .

* ini - Waldo Alarcón - Visionone - 03-02-2021
AT SELECTION-SCREEN ON p_viapag.
  IF p_viapag NE 'V' AND p_viapag NE 'T'.
    MESSAGE e899(fi) WITH 'Sólo Vías de Pago "V" o "T"'.
  ENDIF.
* fin - waldo alarcón - visionone - 03-02-2021

AT SELECTION-SCREEN ON bukrs.
  AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
     ID 'BUKRS' FIELD bukrs.
  IF sy-subrc <> 0.
*--------'No authorization for company code &'------------------------
    MESSAGE e526(icc_tr) WITH bukrs.
  ENDIF.
  SELECT SINGLE * FROM t001 WHERE bukrs = bukrs.

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

*Begin of change: ReSQ Correction INDEX READ on an unsorted Internal TABLE 24/12/2019 EY_DES04 ECDK917080 *
  SORT lt_dynpfields .
*End of change: ReSQ Correction for INDEX READ on an unsorted Internal TABLE 24/12/2019 EY_DES04 ECDK917080 *
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


  lv_dynpro_prog = sy-repid.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      dyname     = lv_dynpro_prog
      dynumb     = '1000'
    TABLES
      dynpfields = lt_dynpfields.

*ReSQ: No Need Of Change Internal Table LT_DYNPFIELDS Already Sorted
  READ TABLE lt_dynpfields INDEX 1.
  lt_dynpfields-fieldvalue = v_nomina.
*Begin of change: ReSQ Correction for MODIFY on an unsorted Internal Table 24/12/2019 EY_DES04 ECDK917080 *
  SORT lt_dynpfields .
*End of change: ReSQ Correction for MODIFY on an unsorted Internal Table 24/12/2019 EY_DES04 ECDK917080 *
  MODIFY  lt_dynpfields INDEX 1.

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

*ReSQ: No Need Of Change Internal Table LT_DYNPFIELDS Already Sorted
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

*ReSQ: No Need Of Change Internal Table LT_DYNPFIELDS Already Sorted
  READ TABLE lt_dynpfields INDEX 1.
  CONCATENATE v_fecha+06(2) '.' v_fecha+04(2) '.' v_fecha+0(4) INTO lt_dynpfields-fieldvalue.
*Begin of change: ReSQ Correction for MODIFY on an unsorted Internal Table 24/12/2019 EY_DES04 ECDK917080 *
  SORT lt_dynpfields .
*End of change: ReSQ Correction for MODIFY on an unsorted Internal Table 24/12/2019 EY_DES04 ECDK917080 *
  MODIFY  lt_dynpfields INDEX 1.


AT SELECTION-SCREEN ON VALUE-REQUEST FOR v_modulo.
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

*ReSQ: No Need Of Change Internal Table LT_DYNPFIELDS Already Sorted
  READ TABLE lt_dynpfields INDEX 1.
  bukrs = lt_dynpfields-fieldvalue .
  TRANSLATE bukrs TO UPPER CASE.


  SELECT modulo descripcion FROM zfitr007
         INTO TABLE it_modulo
         WHERE bukrs =  bukrs.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'MODULO'
      window_title    = 'MODULO'
      value_org       = 'S'
    TABLES
      value_tab       = it_modulo
      return_tab      = it_match
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

  IF sy-subrc EQ 0.
*Begin of change: ReSQ Correction INDEX READ on an unsorted Internal TABLE 24/12/2019 EY_DES04 ECDK917080 *
    SORT it_match .
*End of change: ReSQ Correction for INDEX READ on an unsorted Internal TABLE 24/12/2019 EY_DES04 ECDK917080 *
    READ TABLE it_match INDEX 1.
    MOVE it_match-fieldval TO v_modulo.
  ENDIF.


AT SELECTION-SCREEN ON VALUE-REQUEST FOR v_servi.

  REFRESH lt_dynpfields.
  lt_dynpfields-fieldname = 'BUKRS'.
  APPEND lt_dynpfields.

  lt_dynpfields-fieldname = 'V_MODULO'.
  APPEND lt_dynpfields.
  lv_dynpro_prog = sy-repid.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      dyname     = lv_dynpro_prog
      dynumb     = '1000'
    TABLES
      dynpfields = lt_dynpfields.

*ReSQ: No Need Of Change Internal Table LT_DYNPFIELDS Already Sorted
  READ TABLE lt_dynpfields INDEX 1.
  bukrs = lt_dynpfields-fieldvalue .
  TRANSLATE bukrs TO UPPER CASE.
*ReSQ: No Need Of Change Internal Table LT_DYNPFIELDS Already Sorted
  READ TABLE lt_dynpfields INDEX 2.
  v_modulo = lt_dynpfields-fieldvalue .

  SELECT servicio descripcion FROM zfitr008
         INTO TABLE it_servicios
         WHERE bukrs =  bukrs
          AND   modulo = v_modulo.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'SERVICIO'
      window_title    = 'SERVICIOS'
      value_org       = 'S'
    TABLES
      value_tab       = it_servicios
      return_tab      = it_match
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

  IF sy-subrc EQ 0.
*ReSQ: No Need Of Change Internal Table IT_MATCH Already Sorted
    READ TABLE it_match INDEX 1.
    MOVE it_match-fieldval TO v_servi.
  ENDIF.

* ini - Waldo Alarcón - Visionone - 03-02-2021
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file .
  PERFORM busqueda_archivo  CHANGING p_file.

AT SELECTION-SCREEN ON p_file.
  CHECK sy-ucomm NE 'BAJ' AND sy-ucomm NE 'SEL'.
  IF p_bajfil EQ 'X' AND  p_file IS INITIAL.
    MESSAGE e899(fi) WITH ' Ingrese archivo de bajada'.
  ENDIF.

AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    CASE screen-group1.
      WHEN 'SEL'.
        IF  par_tes EQ 'X'.
          screen-active = 0.
          CLEAR  p_bajfil.
        ENDIF.
      WHEN 'BAJ'.
        IF p_bajfil IS INITIAL.
          screen-active = 0.
        ENDIF.
    ENDCASE.
    MODIFY SCREEN.
  ENDLOOP.
* fin - Waldo Alarcón - Visionone - 03-02-2021

START-OF-SELECTION.
  DATA final(1).
  CLEAR final.

  SELECT SINGLE * FROM zws_puerto WHERE sociedad = bukrs
                                          AND programa  = 'ZFITR010_WS'
                                          AND estado = 'H'.
  IF sy-subrc <> 0.
    MESSAGE i016(z1) WITH 'No existe puerto ws habilitado ' ' para este programa y Sociedad : ' bukrs.
    LEAVE PROGRAM.
  ELSE.
    ws_puerto = zws_puerto-puerto.
  ENDIF.

  IF v_nrotra IS INITIAL.
    MESSAGE i004(zfi) WITH 'Debe Ingresar Numero Transferencia'.
  ELSE.
    SELECT SINGLE *
        FROM zlog_bbva_ws
         WHERE bukrs = bukrs
            AND laufd = v_fecha
            AND laufi = v_nomina.

    IF sy-subrc = 0.
      IF NOT zlog_bbva_ws-id_nomina IS INITIAL AND par_rej IS INITIAL.
        MESSAGE i016(z1) WITH 'Informacion ya fue enviada a Banco' 'Identificador Nomina : ' zlog_bbva_ws-id_nomina.
        LEAVE PROGRAM.
      ELSE.
        IF par_di = 'X' OR par_rej EQ 'X'.
          PERFORM reenvio_ws.
        ENDIF.
        final = 'X'.
      ENDIF.
    ENDIF.


    IF final IS INITIAL.
      PERFORM cargo_datos.
      IF par_di = 'X'.
        SUBMIT zjob_ins_transfer AND RETURN
                WITH bukrs = bukrs
                WITH v_fecha = v_fecha
                WITH v_nomina = v_nomina.
      ENDIF.
    ENDIF.
  ENDIF.


END-OF-SELECTION.

*&---------------------------------------------------------------------*
*&      Form  cargo_datos
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM cargo_datos.
  SELECT SINGLE * FROM reguh
                 WHERE laufd       = v_fecha
                 AND   laufi       = v_nomina
                 AND   zbukr       = bukrs
* ini - Waldo Alarcón - Visionone - 03-02-2021
                 AND   rzawe       EQ p_viapag.
* fin - Waldo Alarcón - Visionone - 03-02-2021

  IF sy-subrc <> 0.
    MESSAGE e004(zfi) WITH 'Nomina no corresponde a Sociedad' bukrs.
  ENDIF.

* Rescatamos Datos.
  SELECT *  FROM  reguh
           WHERE  laufd      = v_fecha
           AND    laufi      = v_nomina
           AND    xvorl      = ' '
* ini - Waldo Alarcón - Visionone - 03-02-2021
*           AND  ( rzawe = 'V' )
           AND   rzawe       EQ p_viapag.
* fin - Waldo Alarcón - Visionone - 03-02-2021

    IF ( reguh-stcd1 IS INITIAL ) OR ( reguh-zstc1 IS INITIAL ).
      SELECT SINGLE stcd1 INTO reguh-stcd1
        FROM lfa1 WHERE lifnr = reguh-lifnr.
    ENDIF.

    IF ( NOT reguh-stcd1 IS INITIAL ) OR ( NOT reguh-zstc1 IS INITIAL ).
      MOVE-CORRESPONDING reguh TO tabla_00.


* revisamos si paga a un beneficiario alternativo
      IF tabla_00-stcd1 <> tabla_00-zstc1.
        tabla_00-stcd1 = tabla_00-zstc1.
        tabla_00-name1 = tabla_00-znme1.
        tabla_00-ort01 = tabla_00-zort1.
        tabla_00-stras = tabla_00-zstra.
      ENDIF.
      APPEND tabla_00.
      IF sy-dbcnt = 1.
        CONCATENATE  reguh-zaldt+6(2) reguh-zaldt+4(2) reguh-zaldt+0(4) INTO zaldt.
        CONCATENATE  reguh-valut+6(2) reguh-valut+4(2) reguh-valut+0(4) INTO valut.
        cuenta = reguh-ubhkt.
* CBD - 2012-01-11 - MANEJO CUENTA CARGO
        CONCATENATE cuenta+0(9) '3' INTO cuenta_2.
* CBD - 2012-01-11 - MANEJO CUENTA CARGO
        SELECT  SINGLE bktxt INTO bktxt
                FROM bkpf WHERE bukrs = bukrs
                          AND   belnr = reguh-vblnr
                          AND   gjahr = reguh-zaldt(4).
*ResQ Comment:Correction not required as Select Single is used 24/12/2019 EY_DES04 ECDK917080 *
        SELECT SINGLE  * FROM  regup WHERE laufd = reguh-laufd
                                 AND   laufi = reguh-laufi
                                 AND   xvorl = reguh-xvorl
                                 AND   zbukr = reguh-zbukr
                                 AND   lifnr = reguh-lifnr
                                 AND   kunnr = reguh-kunnr
                                 AND   empfg = reguh-empfg
                                 AND   vblnr = reguh-vblnr.
*ResQ Comment:Correction not required as Select Single is used 24/12/2019 EY_DES04 ECDK917080 *
        SELECT SINGLE  * FROM  bseg WHERE bukrs  = regup-bukrs
                               AND  belnr = regup-belnr
                               AND  gjahr = regup-gjahr
                               AND  buzei = regup-buzei.

        IF sy-subrc = 0.
          zzmot_emis = bseg-zzmot_emis.
          IF zzmot_emis IS INITIAL.
            zzmot_emis = 'TESORERIA'.
          ENDIF.
        ELSE.
          zzmot_emis = 'TESORERIA'.
        ENDIF.
      ENDIF.

    ENDIF.
  ENDSELECT.

*Procesamos Datos
  SORT tabla_00 BY  lifnr.   " prov

  DESCRIBE TABLE tabla_00 LINES lins.

  IF lins <> 0.
*    PERFORM listado.  "informe.
    IF p_viapag = 'V'.
      PERFORM preparo_salida.
    ELSE.
      PERFORM preparo_salida_t.
    ENDIF.
  ELSE.
    WRITE : /,/, 'No Existe Informacion Para Procesar....!!!!!!!!'.

  ENDIF.
ENDFORM.                    "cargo_datos

*&---------------------------------------------------------------------*
*&      Form  PREPARO_SALIDA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM preparo_salida.
  DATA : folio_aux(15).
  DATA : largo(05) TYPE n.
  DATA : largo1(05) TYPE n.
  REFRESH reg01.

  CALL FUNCTION 'ENQUEUE_EZFOLIO'
    EXPORTING
      mode_zfolio_bbva = 'E'
      mandt            = sy-mandt
      bukrs            = bukrs
      codigo           = '001'.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
       WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  SELECT SINGLE * FROM zfolio_bbva WHERE bukrs = bukrs
                                   AND   codigo ='001'.
  IF sy-subrc <> 0.
    zfolio_bbva-bukrs = bukrs.
    zfolio_bbva-codigo ='001'.
    zfolio_bbva-folio = 0.
  ENDIF.

  lineas = 0.
  secuencia = 1.

  LOOP AT tabla_00.
    zfolio_bbva-folio =  zfolio_bbva-folio + 1.
    IF par_di = 'X'.
      MODIFY  zfolio_bbva.
    ENDIF.
    CONCATENATE bukrs zfolio_bbva-folio INTO folio_aux .
    TRANSLATE tabla_00-zstc1 USING '- ' .
    CONDENSE  tabla_00-zstc1 NO-GAPS    .
    largo = strlen( tabla_00-zstc1 ) - 1.
    reg01-rut_prv         =  tabla_00-zstc1+0(largo).
    reg01-rut_dvr        =  tabla_00-zstc1+largo(1).

    reg01-identificador   =  folio_aux.
    reg01-nombre          =  tabla_00-name1.
    reg01-tipo_proceso    = '1'.
    reg01-cod_banco       = '504'.
    reg01-cuenta_abo      = ''.
    reg01-destino         = '3'.
    reg01-monto_pago = tabla_00-rbetr * -100.

* ini - Waldo Alarcón - Visionone - 03-02-2021
* obtiene el identificador ya grabado desde la REGUH
    IF par_rej EQ 'X'.
      SELECT SINGLE identif_pago INTO reg01-identificador
           FROM reguh WHERE  laufd = tabla_00-laufd
                         AND laufi = tabla_00-laufi
                         AND xvorl = tabla_00-xvorl
                         AND zbukr = tabla_00-zbukr
                         AND lifnr = tabla_00-lifnr
                         AND kunnr = tabla_00-kunnr
                         AND empfg = tabla_00-empfg
                         AND vblnr = tabla_00-vblnr.
    ENDIF.
* fin - Waldo Alarcón - Visionone - 03-02-2021
    APPEND reg01.


    IF par_di = 'X'.
      UPDATE reguh
      SET    identif_pago = folio_aux
             fecha_envio = sy-datum
             usuario_envio = sy-uname
      WHERE  laufd =  tabla_00-laufd
      AND laufi = tabla_00-laufi
      AND xvorl = tabla_00-xvorl
      AND zbukr = tabla_00-zbukr
      AND lifnr = tabla_00-lifnr
      AND kunnr = tabla_00-kunnr
      AND empfg = tabla_00-empfg
      AND vblnr = tabla_00-vblnr.
    ENDIF.

    lineas = lineas + 1.
    monto_z  =   monto_z + ( tabla_00-rbetr * -1 ).
    .
  ENDLOOP.

  CALL FUNCTION 'ENQUEUE_EZFOLIO'
    EXPORTING
      mode_zfolio_bbva = 'E'
      mandt            = sy-mandt
      bukrs            = bukrs
      codigo           = '001'.

  IF lineas > 0.
    PERFORM bajar_archivo.
  ENDIF.

ENDFORM.                    " PREPARO_SALIDA

*&---------------------------------------------------------------------*
*&      Form  PREPARO_SALIDA_T
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM preparo_salida_t.
  DATA : folio_aux(15).
  DATA : largo(05) TYPE n.
  DATA : largo1(05) TYPE n.
  REFRESH reg02.

  CALL FUNCTION 'ENQUEUE_EZFOLIO'
    EXPORTING
      mode_zfolio_bbva = 'E'
      mandt            = sy-mandt
      bukrs            = bukrs
      codigo           = '001'.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
       WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  SELECT SINGLE * FROM zfolio_bbva WHERE bukrs = bukrs
                                   AND   codigo ='001'.
  IF sy-subrc <> 0.
    zfolio_bbva-bukrs = bukrs.
    zfolio_bbva-codigo ='001'.
    zfolio_bbva-folio = 0.
  ENDIF.

  lineas = 0.
  secuencia = 1.

  LOOP AT tabla_00.
    zfolio_bbva-folio =  zfolio_bbva-folio + 1.
    IF par_di = 'X'.
      MODIFY  zfolio_bbva.
    ENDIF.
    CONCATENATE bukrs zfolio_bbva-folio INTO folio_aux .
    TRANSLATE tabla_00-zstc1 USING '- ' .
    CONDENSE  tabla_00-zstc1 NO-GAPS    .
    largo                 = strlen( tabla_00-zstc1 ) - 1.
    reg02-rut_prv         =  tabla_00-zstc1+0(largo).
    reg02-rut_dvr         =  tabla_00-zstc1+largo(1).

    reg02-identificador   =  folio_aux.
    reg02-nombre          =  tabla_00-name1.
    reg02-tipo_proceso    = '1'.
    reg02-cod_banco       = tabla_00-zbnkl.
    reg02-cuenta_abo      = tabla_00-zbnkn.
    reg02-destino         = '1'.
    reg02-monto_pago      = tabla_00-rbetr * -100.
*correo del proveedor
    SELECT SINGLE smtp_addr INTO reg02-email_benef
           FROM lfa1 INNER JOIN adr6
                 ON lfa1~adrnr EQ adr6~addrnumber
                WHERE lifnr EQ  tabla_00-lifnr.
    IF sy-subrc NE 0.
      CLEAR reg02-email_benef.
    ENDIF.
*
* ini - Waldo Alarcón - Visionone - 03-02-2021
* obtiene el identificador ya grabado desde la REGUH
    IF par_rej EQ 'X'.
      SELECT SINGLE identif_pago INTO reg02-identificador
           FROM reguh WHERE  laufd = tabla_00-laufd
                         AND laufi = tabla_00-laufi
                         AND xvorl = tabla_00-xvorl
                         AND zbukr = tabla_00-zbukr
                         AND lifnr = tabla_00-lifnr
                         AND kunnr = tabla_00-kunnr
                         AND empfg = tabla_00-empfg
                         AND vblnr = tabla_00-vblnr.
    ENDIF.
* fin - Waldo Alarcón - Visionone - 03-02-2021

    APPEND reg02.

    IF par_di = 'X'.
      UPDATE reguh
      SET    identif_pago  = folio_aux
             fecha_envio   = sy-datum
             usuario_envio = sy-uname
      WHERE  laufd =  tabla_00-laufd
      AND laufi = tabla_00-laufi
      AND xvorl = tabla_00-xvorl
      AND zbukr = tabla_00-zbukr
      AND lifnr = tabla_00-lifnr
      AND kunnr = tabla_00-kunnr
      AND empfg = tabla_00-empfg
      AND vblnr = tabla_00-vblnr.
    ENDIF.

    lineas   = lineas + 1.
    monto_z  =   monto_z + ( tabla_00-rbetr * -1 ).
    .
  ENDLOOP.

  CALL FUNCTION 'ENQUEUE_EZFOLIO'
    EXPORTING
      mode_zfolio_bbva = 'E'
      mandt            = sy-mandt
      bukrs            = bukrs
      codigo           = '001'.

  IF lineas > 0.
    PERFORM bajar_archivo.
  ENDIF.

ENDFORM.                    " PREPARO_SALIDA_T

*&---------------------------------------------------------------------*
*&      Form  bajar_archivo
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM bajar_archivo.
*-----------------*
  REFRESH file.

  IF par_di = 'X' OR par_rej EQ 'X'. "Waldo Alarcón - Visionone - 03-02-2021

* ini - Waldo Alarcón - Visionone - 03-02-2021
    IF p_viapag = 'V'.
      LOOP AT reg01.
        file-linea =      reg01.
        APPEND file.
      ENDLOOP.
* nueva vía de pago T
    ELSE.
      LOOP AT reg02.
        file-linea =      reg02.
        APPEND file.
      ENDLOOP.
    ENDIF.
* fin - Waldo Alarcón - Visionone - 03-02-2021

    CLEAR: belnr, gjahr.
* ini - Waldo Alarcón - Visionone - 03-02-2021
* solo si es ejecucion real raliza la contabilización.
    IF par_rej IS INITIAL.
      IF contabilizar <> 'N'.
        PERFORM  contabilizacion.
      ENDIF.
      PERFORM grabar_log.
    ENDIF.
* Si se ingresa archivo de bajada
    IF p_bajfil IS NOT INITIAL.
      PERFORM baja_archivo.
    ELSE.
* fin - Waldo Alarcón - Visionone - 03-02-2021
      PERFORM llamar_ws.
    ENDIF.
  ELSE.
    SKIP 2 .
    FORMAT COLOR 3 ON.
    WRITE : / 'Se Enviara la siguiente Informacion:'.
    WRITE : /10 'total registros : ', lineas,
                'total monto  : ',  monto_z.
  ENDIF.

  FORMAT COLOR 3 OFF.
  CLEAR: lineas, monto_z.

  REFRESH: reg01, file .
*----------------------------------------------
ENDFORM.                    "bajar_archivo



TOP-OF-PAGE.
  WRITE : /1  t001-butxt,
           43   'ARCHIVO DE PAGO PROVEEDORES BANCO BBVA' ,
           120 sy-datum,

          /120 sy-uzeit ,
          /27 'Identificación De Propuesta de Pago : ',
              'Fecha Nomina: ',v_fecha, ' Nomina:' ,  v_nomina ,
          120 sy-pagno.




  WRITE : / sy-uline(136).
*&---------------------------------------------------------------------*
*&      Form  GRABAR_LOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM grabar_log.
  CLEAR zlog_bbva_ws.
  zlog_bbva_ws-bukrs       = bukrs.
  zlog_bbva_ws-laufd       = v_fecha.
  zlog_bbva_ws-laufi       = v_nomina.
  zlog_bbva_ws-fecha_gen   = sy-datum.
  zlog_bbva_ws-hora_gen    = sy-uzeit.
  zlog_bbva_ws-uname       = sy-uname.
  zlog_bbva_ws-total       = monto_z.
  zlog_bbva_ws-lineas      = lineas.
  zlog_bbva_ws-gjahr       = gjahr.
  zlog_bbva_ws-belnr       = belnr.
  zlog_bbva_ws-nrotran     = v_nrotra.
  INSERT zlog_bbva_ws.

  LOOP AT file.
    zlog_bbva_ws_det-bukrs     = bukrs.
    zlog_bbva_ws_det-laufd     = v_fecha.
    zlog_bbva_ws_det-laufi     = v_nomina.
    zlog_bbva_ws_det-nro_linea = sy-tabix.
    zlog_bbva_ws_det-linea_p1  = file-linea+0(200).
    zlog_bbva_ws_det-linea_p2  = file-linea+199(200).
    INSERT zlog_bbva_ws_det.
  ENDLOOP.
ENDFORM.                    "grabar_log
*&---------------------------------------------------------------------*
*&      Form  contabilizacion
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM contabilizacion.

  CLEAR bdcdata.
  REFRESH bdcdata.

  WRITE  monto_z CURRENCY 'CLP'  TO total.
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
                                total.
  PERFORM bdc_field       USING 'BSEG-VALUT'
                                 valut.
  PERFORM bdc_field       USING 'BSEG-ZUONR'
                                bktxt.
  PERFORM bdc_field       USING 'BSEG-SGTXT'
                                bktxt.
  PERFORM bdc_field       USING 'RF05A-NEWBS'
                                '50'.
* CBD - 2012-01-11 - MANEJO CTA CARGO - PERFORM bdc_field       USING 'RF05A-NEWKO'
* CBD - 2012-01-11 - MANEJO CTA CARGO -                               cuenta.
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
                                total.
  PERFORM bdc_field       USING 'BSEG-VALUT'
                                valut.
  PERFORM bdc_field       USING 'BSEG-SGTXT'
                                bktxt.
  PERFORM bdc_field       USING 'BSEG-ZUONR'
                              xblnr.

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

*&---------------------------------------------------------------------*
*&      Form  reenvio_ws
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM reenvio_ws.
  SELECT  *  FROM zlog_bbva_ws_det
             WHERE bukrs = bukrs
                AND laufd = v_fecha
                AND laufi = v_nomina.

    file-linea+0(200) = zlog_bbva_ws_det-linea_p1.
    file-linea+199(200) = zlog_bbva_ws_det-linea_p2.
    APPEND file.

  ENDSELECT.

  lineas = zlog_bbva_ws-lineas.
  monto_z = zlog_bbva_ws-total.

* ini - Waldo Alarcón - Visionone - 03-02-2021.
  IF p_bajfil IS NOT INITIAL.
    PERFORM baja_archivo.
  ELSE.
* fin - Waldo Alarcón - Visionone - 03-02-2021.
    PERFORM llamar_ws.
  ENDIF.

  REFRESH: reg01, file .
ENDFORM.                    "reenvio_ws
*&---------------------------------------------------------------------*
*&      Form  LLAMAR_WS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM llamar_ws .

  DATA: output TYPE zbbvawsingreso_nomina_soap_ou1 .
  DATA: input TYPE zbbvawsingreso_nomina_soap_in1 .

  DATA: proxy TYPE REF TO zbbvaco_service1soap1.
  DATA: datos TYPE string.

  LOOP AT file.
    IF sy-tabix = 1.
      CONCATENATE datos file-linea INTO datos.
    ELSE.
      CONCATENATE datos  '|' file-linea INTO datos.
    ENDIF.

  ENDLOOP.

  TRY.
      CREATE OBJECT proxy
        EXPORTING
          logical_port_name = ws_puerto.
    CATCH cx_ai_system_fault .
  ENDTRY.

  TRY.

      SELECT SINGLE * FROM zfitr006 WHERE bukrs = bukrs.

      SELECT SINGLE * FROM zfitr008 WHERE bukrs    = bukrs
                                    AND   modulo   = v_modulo
                                    AND   servicio = v_servi.

      input-user_name         = zfitr006-usuario.
      input-password          = zfitr006-clave.
      input-cuenta_pago       = zfitr008-ctapago.
      input-fecha_pago        = v_fpago.
      input-glosa_nomina      = v_descr.
      input-modulo            = v_modulo.
      CONCATENATE  bukrs v_fecha v_nomina  INTO input-nombrearchivo.
      input-numero_referencia = zfitr006-numeroref.
      input-servicio          = v_servi.
      input-archivo           = datos.

      CALL METHOD proxy->wsingreso_nomina
        EXPORTING
          input  = input
        IMPORTING
          output = output.


    CATCH cx_ai_system_fault .
    CATCH cx_ai_application_fault .
  ENDTRY.

  IF  output-identificador_nomina IS INITIAL.
    WRITE : / 'Error : ', output-motivo_no_exito.
  ELSE.
    SELECT SINGLE * FROM zlog_bbva_ws WHERE  bukrs = bukrs
                                      AND    laufd = v_fecha
                                      AND    laufi = v_nomina.
    IF sy-subrc = 0.
      zlog_bbva_ws-id_nomina    = output-identificador_nomina.
      zlog_bbva_ws-modulo       = v_modulo.
      zlog_bbva_ws-servicio     = v_servi.
      zlog_bbva_ws-ctapago      = zfitr008-ctapago.
      zlog_bbva_ws-fecha_pago   = v_fpago.
      zlog_bbva_ws-descripcion  = v_descr.
      zlog_bbva_ws-fecha_env    = sy-datum.
      zlog_bbva_ws-hora_env     = sy-uzeit.
** ini - Waldo Alarcón - Visionone - 23-03-2022
*      zlog_bbva_ws-viapago       = p_viapag.
*      zlog_bbva_ws-proce_novedad = 'N'.
** fin - Waldo Alarcón - Visionone - 23-03-2022
      MODIFY zlog_bbva_ws.
    ENDIF.
    SKIP 2 .
    FORMAT COLOR 3 ON.
    WRITE : / 'Se Envio la siguiente Informacion:'.
    WRITE : /10 'total registros : ', lineas,
                'total monto  : '   ,  monto_z,
                'Id Nomina : '      , zlog_bbva_ws-id_nomina.
  ENDIF.

ENDFORM.                    " LLAMAR_WS

*INCLUDE zfitr010_ws_preparo_salidaf01.
*&---------------------------------------------------------------------*
*&      Form  BUSQUEDA_ARCHIVO
*&---------------------------------------------------------------------*
FORM busqueda_archivo  CHANGING p_path_file.
  DATA: lv_file TYPE string,
        lv_path TYPE string.
*
  CALL METHOD cl_gui_frontend_services=>file_save_dialog
    EXPORTING
      window_title              = 'Indique Archivo destino'
      default_extension         = 'TXT'
      prompt_on_overwrite       = 'X'
    CHANGING
      filename                  = lv_file
      path                      = lv_path
      fullpath                  = p_path_file
    EXCEPTIONS
      cntl_error                = 1
      error_no_gui              = 2
      not_supported_by_gui      = 3
      invalid_default_file_name = 4
      OTHERS                    = 5.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
       WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  BAJA_ARCHIVO
*&---------------------------------------------------------------------*
FORM baja_archivo .

  CHECK p_file IS NOT INITIAL.
  CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING
      filename                = p_file
      filetype                = 'DAT'
    TABLES
      data_tab                = file
*     fieldnames              = i_column
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
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.

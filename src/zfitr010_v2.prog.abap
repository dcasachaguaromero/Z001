*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES04 > *
*& Description: < ReSQ Correction > *
*& Date: <24-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
REPORT zfitr010_v2 NO STANDARD PAGE HEADING
                                   LINE-COUNT 60
                                   LINE-SIZE 132.

*----------------------------------------------------------------------*
* Tablas usadas.
*----------------------------------------------------------------------*
TABLES : reguh,   "  Datos de pago del programa de pagos              02
         regup,
         bkpf,
         bseg,
         bsak,
         payr,     "  Cheque pago
         lfa1,    "  Maestro de proveedores (parte general)           02
         lfb1,
         t001,
         zfolio_bbva,
         zlog_bbva_vv,
         zfitr005.

DATA : BEGIN OF tabla_00 OCCURS 0.
        INCLUDE STRUCTURE reguh.
DATA : END OF tabla_00.

DATA : BEGIN OF tabla_ant OCCURS 0.
        INCLUDE STRUCTURE reguh.
DATA : END OF tabla_ant.

DATA : BEGIN OF reg01 OCCURS 0,
          rut_prv(08)           TYPE n,
          rut_dvr(01)           TYPE c,
          identificador(15)     TYPE c,
          nombre(45)            TYPE c,
          tipo_proceso(01)      TYPE c,
          cod_banco(03)         TYPE c,
          cuenta_abo(20)        TYPE c,
          destino(01)           TYPE c,
          monto_pago(09)        TYPE n,
 END OF reg01.

DATA: zaldt      LIKE reguh-zaldt,
      xblnr      LIKE bkpf-xblnr,
      bktxt      LIKE bkpf-bktxt,
      total      LIKE bseg-dmbtr,
* CBD      total(15),
      valut      LIKE reguh-valut,
      zzmot_emis LIKE bseg-zzmot_emis,
      asignacion LIKE bseg-zuonr,
      gjahr      LIKE bkpf-gjahr,
      belnr      LIKE bkpf-belnr,
      cuenta     LIKE reguh-ubhkt,
      cuenta_2   LIKE reguh-ubhkt,
      contabilizar(1),
      resp(1).

DATA:  BEGIN OF tlaufk OCCURS 1.
        INCLUDE STRUCTURE ilaufk.
DATA:  END OF tlaufk.

DATA lt_dynpfields LIKE dynpread OCCURS 1 WITH HEADER LINE.
DATA lv_dynpro_prog LIKE d020s-prog.

DATA:   monto_z     LIKE bseg-dmbtr ,
        lins(07)    TYPE c VALUE 0,
        lineas(5)    TYPE n,
        secuencia(2)   TYPE n,
        archivo_a(130) TYPE c.

INCLUDE zbatchinput_v2.
*INCLUDE zbatchinput.
DATA : itab TYPE TABLE OF bdcmsgcoll WITH HEADER LINE.

* CGC      Declaracion de Variables              24-10-2011

DATA : BEGIN OF ti_cc OCCURS 0.
        INCLUDE STRUCTURE reguh.
DATA : END OF ti_cc.


DATA: v_format     TYPE zfitr005-zformat,
      v_adrnr      TYPE adrc-addrnumber,
      f_adrnr      TYPE adrc-addrnumber,
      numero(9)    TYPE n,
      num_c(8)     TYPE c,
      dv,
      v_flag,
      indice       TYPE sy-tabix,
      v_reg        TYPE sy-tfill,
      v_hbkid      TYPE reguh-hbkid,
      sw.

DATA: ti_adrc    TYPE adrc       OCCURS 0 WITH HEADER LINE,
      t_items    TYPE bapi3008_2 OCCURS 0 WITH HEADER LINE,
      ti_set_fac LIKE setleaf    OCCURS 0 WITH HEADER LINE,
      ti_set_ncr LIKE setleaf    OCCURS 0 WITH HEADER LINE.

DATA : BEGIN OF file OCCURS 0,
        linea(400) TYPE c.
DATA : END OF file.

DATA : BEGIN OF file2 OCCURS 0,
        linea(400) TYPE c.
DATA : END OF file2.

DATA : BEGIN OF ti_prov OCCURS 0,
        lifnr      TYPE lfa1-lifnr,
        vblnr      TYPE reguh-vblnr,
        stcd1      TYPE reguh-stcd1,
        name1      TYPE reguh-name1,
        stras      TYPE reguh-stras,
        ort01      TYPE reguh-ort01,
        ubknt      TYPE reguh-ubknt,
        ubnkl      TYPE reguh-ubnkl,
        adrnr      TYPE reguh-adrnr,
        identif_pago TYPE reguh-identif_pago,
        ztelf      TYPE reguh-ztelf.
DATA : END OF ti_prov.

DATA : BEGIN OF ti_prov2 OCCURS 0,
        lifnr      TYPE lfa1-lifnr,
        vblnr      TYPE reguh-vblnr,
        stcd1      TYPE reguh-stcd1,
        name1      TYPE reguh-name1,
        stras      TYPE reguh-stras,
        ort01      TYPE reguh-ort01,
        ubknt      TYPE reguh-ubknt,
        ubnkl      TYPE reguh-ubnkl,
        adrnr      TYPE reguh-adrnr,
        identif_pago TYPE reguh-identif_pago,
        ztelf      TYPE reguh-ztelf.
DATA : END OF ti_prov2.

DATA: ti_bsak LIKE bsak OCCURS 0 WITH HEADER LINE.

DATA: t_est  TYPE reguh.

DATA: ti_exc LIKE zfitr005 OCCURS 0 WITH HEADER LINE.

CONSTANTS:  formato   TYPE zfitr005-zformat  VALUE 'NVO',
            header_soc                       VALUE '1',
            header_prov                      VALUE '2',
            posiciones                       VALUE '3'.

RANGES: r_fac FOR bkpf-blart,
        r_ncr FOR bkpf-blart.

*----------------------------------------------------------------------*
* Parametros
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK marco1 WITH FRAME TITLE text-001.

PARAMETER : bukrs     LIKE bkpf-bukrs     OBLIGATORY,
            v_fecha   LIKE reguh-laufd    OBLIGATORY,
            v_nomina  LIKE f110v-laufi    OBLIGATORY.
*            v_fecpag  LIKE reguh-laufd    OBLIGATORY.

SELECTION-SCREEN SKIP 1.


PARAMETER  : v_nrotra   LIKE  zlog_bbva_vv-nrotran    OBLIGATORY.

"PARAMETER  : v_hbkid  LIKE payr-hbkid  OBLIGATORY,
"             v_hktid  LIKE payr-hktid  OBLIGATORY,
"             v_chect  LIKE payr-chect  OBLIGATORY.

SELECTION-SCREEN SKIP 1.

*Mejoras 24-10-2011  CGC   PRIMEGROUP Cambia Objeto Busqueda de Ruta Almacenamiento
*PARAMETER  : archivo     LIKE rlgrap-filename DEFAULT 'C:\TRANSFER\'.
PARAMETER  : archivo     TYPE string DEFAULT 'C:\TRANSFER\'.


SELECTION-SCREEN SKIP 1.

PARAMETERS : par_tes RADIOBUTTON GROUP test       " Ejecución en Test
                     DEFAULT 'X',
             par_di  RADIOBUTTON GROUP test.      " Ejecución real


SELECTION-SCREEN END OF BLOCK marco1 .

* Mejoras PRIMEGROUP   24-10-2011                       CGC
*AT SELECTION-SCREEN ON VALUE-REQUEST FOR archivo .
*  CALL FUNCTION 'F4_FILENAME'
*    IMPORTING
*      file_name = archivo.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR archivo.

  CALL METHOD cl_gui_frontend_services=>directory_browse
    EXPORTING
      window_title    = 'Carpeta de Almacenamiento'
      initial_folder  = 'C:\'
    CHANGING
      selected_folder = archivo.

*                                                       FIN

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
SORT LT_DYNPFIELDS .
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
  lt_dynpfields-fieldvalue = v_nomina.
*Begin of change: ReSQ Correction for MODIFY on an unsorted Internal Table 24/12/2019 EY_DES04 ECDK917080 *
SORT LT_DYNPFIELDS .
*End of change: ReSQ Correction for MODIFY on an unsorted Internal Table 24/12/2019 EY_DES04 ECDK917080 *
  MODIFY  lt_dynpfields INDEX 1.


*ReSQ: No Need Of Change Internal Table LT_DYNPFIELDS Already Sorted
  READ TABLE lt_dynpfields INDEX 2.
*  CONCATENATE 'C:\TRANSFER\' bukrs '_BCORPBANCA' '_' sy-datum '_' sy-uzeit '.txt' INTO
*  lt_dynpfields-fieldvalue.
  lt_dynpfields-fieldvalue = archivo.

*Begin of change: ReSQ Correction for MODIFY on an unsorted Internal Table 24/12/2019 EY_DES04 ECDK917080 *
SORT LT_DYNPFIELDS .
*End of change: ReSQ Correction for MODIFY on an unsorted Internal Table 24/12/2019 EY_DES04 ECDK917080 *
  MODIFY  lt_dynpfields INDEX 2.

  CALL FUNCTION 'DYNP_VALUES_UPDATE'
    EXPORTING
      dyname     = lv_dynpro_prog
      dynumb
      ='1000'
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
SORT LT_DYNPFIELDS .
*End of change: ReSQ Correction for MODIFY on an unsorted Internal Table 24/12/2019 EY_DES04 ECDK917080 *
  MODIFY  lt_dynpfields INDEX 1.

*ReSQ: No Need Of Change Internal Table LT_DYNPFIELDS Already Sorted
  READ TABLE lt_dynpfields INDEX 2.
  CONCATENATE 'C:\TRANSFER\' bukrs '_BCORPBANCA' '_' sy-datum '_' sy-uzeit '.txt' INTO
   lt_dynpfields-fieldvalue.
*Begin of change: ReSQ Correction for MODIFY on an unsorted Internal Table 24/12/2019 EY_DES04 ECDK917080 *
SORT LT_DYNPFIELDS .
*End of change: ReSQ Correction for MODIFY on an unsorted Internal Table 24/12/2019 EY_DES04 ECDK917080 *
  MODIFY  lt_dynpfields INDEX 2.

  CALL FUNCTION 'DYNP_VALUES_UPDATE'
    EXPORTING
      dyname     = lv_dynpro_prog
      dynumb
      ='1000'
    TABLES
      dynpfields = lt_dynpfields.

AT SELECTION-SCREEN.


INITIALIZATION.

  CLEAR:   r_fac,
           r_ncr,
           ti_set_fac,
           ti_set_ncr.

  REFRESH: r_fac,
           r_ncr,
           ti_set_fac,
           ti_set_ncr.

*  Carga Clases de Documento, Facturas y N. Crédito
  SELECT *
  FROM setleaf
  INTO CORRESPONDING FIELDS OF TABLE  ti_set_fac
     WHERE setname = 'ZFITR001'.

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

  SELECT *
  FROM setleaf
  INTO CORRESPONDING FIELDS OF TABLE  ti_set_ncr
     WHERE setname = 'ZFITR002'.

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



START-OF-SELECTION.

  DATA v_fecha_30 LIKE reguh-laufd.

  IF par_di = 'X'.

    SELECT SINGLE *
    FROM zlog_bbva_vv
       WHERE bukrs = bukrs
         AND laufd = v_fecha
         AND laufi = v_nomina.

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

  IF v_nrotra IS INITIAL.
    MESSAGE i004(zfi) WITH 'Debe Ingresar Numero Transferencia'.
  ELSE.
    PERFORM cargo_datos.
*    Modificacion Herman graba tes_docpago
    IF par_di = 'X'.
*        SET PARAMETER ID: 'BUKRS' FIELD bukrs,
*                  'V_FECHA' FIELD v_fecha,
*                  'V_NOMINA' field v_nomina.

*        CALL TRANSACTION 'ZJOB_INS_TRANSFER' AND SKIP FIRST SCREEN.

      SUBMIT zjob_ins_transfer AND RETURN
              WITH bukrs = bukrs
              WITH v_fecha = v_fecha
              WITH v_nomina = v_nomina.

    ENDIF.
*    Fin Modificacion
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
                 AND   zbukr       = bukrs.


  IF sy-subrc <> 0.
    MESSAGE e004(zfi) WITH 'Nomina no corresponde a Sociedad' bukrs.

  ENDIF.

* Rescatamos Datos.
  SELECT *  FROM  reguh
           WHERE  laufd      = v_fecha
           AND    laufi      = v_nomina
           AND    xvorl      = ' '
           AND  ( rzawe = 'V' ).

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
*        CONCATENATE cuenta+0(9) '3' INTO cuenta_2.
* CBD - 2012-01-11 - MANEJO CUENTA CARGO
* PYV 03/10/2012 Se cambia a cuenta de transferencia
        CONCATENATE cuenta+0(9) '5' INTO cuenta_2.
* PYV 03/10/2012 Se cambia a cuenta de transferencia
        SELECT  SINGLE bktxt INTO bktxt FROM bkpf WHERE belnr =  reguh-vblnr
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
  SORT tabla_00 BY  lifnr.

  READ TABLE tabla_00 INDEX 1.

  CLEAR v_hbkid.

  v_hbkid = tabla_00-hbkid.

*  SELECT SINGLE zflag
*  INTO v_flag
*  FROM zfitr005
*     WHERE bukrs  EQ bukrs
*       AND hbkid  EQ v_hbkid
*       AND zmotiv EQ v_exc.

* Rescata motivos de emisión
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE ti_exc
    FROM zfitr005
    WHERE bukrs = bukrs
      AND hbkid = v_hbkid.

  LOOP AT tabla_00.
    CLEAR indice.
    MOVE sy-tabix TO indice.

*   Valida Motivo de Emisión 4° Copia
    SELECT SINGLE *
    FROM bsak
       WHERE bukrs EQ bukrs
         AND lifnr EQ tabla_00-lifnr
         AND augbl EQ tabla_00-vblnr
         AND belnr <> tabla_00-vblnr.

*  Lee el registro en la tabla de motivos de emisión
    READ TABLE ti_exc WITH KEY bukrs = bukrs
                               hbkid = v_hbkid
                               zmotiv = bsak-zzmot_emis.

    IF sy-subrc = 0.
*      IF bsak-zzmot_emis EQ v_exc AND v_flag IS NOT INITIAL.
*      IF v_flag IS NOT INITIAL.
      IF ti_exc-zflag IS NOT INITIAL.
        MOVE-CORRESPONDING tabla_00 TO ti_cc.
        APPEND ti_cc.
        CLEAR  ti_cc.
        DELETE tabla_00 INDEX indice.
      ELSEIF ti_exc-zformat NE 'NVO'.
        MOVE-CORRESPONDING tabla_00 TO tabla_ant.
        APPEND tabla_ant.
        CLEAR  tabla_ant.
        DELETE tabla_00 INDEX indice.
      ENDIF.
    ELSE.
      MOVE-CORRESPONDING tabla_00 TO tabla_ant.
      APPEND tabla_ant.
      CLEAR  tabla_ant.
      DELETE tabla_00 INDEX indice.
    ENDIF.
  ENDLOOP.

  IF tabla_00[] IS NOT INITIAL.
    LOOP AT tabla_00.
      CLEAR t_est.
      MOVE-CORRESPONDING tabla_00 TO t_est.

      AT NEW lifnr.
        MOVE-CORRESPONDING t_est TO ti_prov.
        APPEND ti_prov.
        CLEAR  ti_prov.
      ENDAT.
    ENDLOOP.
  ENDIF.

  IF ti_cc[] IS NOT INITIAL.

    LOOP AT ti_cc.

      CLEAR t_est.
      MOVE-CORRESPONDING ti_cc TO t_est.

      AT NEW lifnr.
        MOVE-CORRESPONDING t_est TO ti_prov2.
        APPEND ti_prov2.
        CLEAR  ti_prov2.
      ENDAT.

    ENDLOOP.

  ENDIF.

  DESCRIBE TABLE tabla_00.
  IF sy-tfill > 0.
    PERFORM nvo_formato.
  ENDIF.

  DESCRIBE TABLE ti_cc.
  IF sy-tfill > 0.
    CLEAR sw.
    sw = 'X'.
    tabla_00[] = ti_cc[].
    ti_prov[]  = ti_prov2[].
    PERFORM nvo_formato.
  ENDIF.

  DESCRIBE TABLE tabla_ant.
  IF sy-tfill > 0.
    tabla_00[] = tabla_ant[].
    PERFORM preparo_salida.
  ENDIF.

*  DESCRIBE TABLE tabla_00 LINES lins.
*  DESCRIBE TABLE ti_cc    LINES v_reg.
*
*  lins = lins + v_reg.
*
** Revisar Datos de Banco  CGC
*
*  IF lins <> 0.
**    PERFORM listado.  "informe.
*
**   Se valida que formato de Salida por Tabla Z
*
*    CLEAR v_format.
*
*    SELECT SINGLE zformat
*    FROM zfitr005
*    INTO v_format
*       WHERE bukrs EQ bukrs
*         AND hbkid EQ v_hbkid.
*
*    IF v_format EQ formato.
*      DESCRIBE TABLE tabla_00 LINES lins.
*      IF lins > 0.
*        PERFORM nvo_formato.
*      ENDIF.
*      IF v_reg > 0.
*        CLEAR sw.
*        sw = 'X'.
*        tabla_00[] = ti_cc[].
*        ti_prov[]  = ti_prov2[].
*        PERFORM nvo_formato.
*      ENDIF.
*    ELSE.
*      PERFORM preparo_salida.
*    ENDIF.
*
**                                          FIN
*
*ELSE.
*  WRITE : /,/, 'No Existe Informacion Para Procesar....!!!!!!!!'.
*
*ENDIF.
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
   MODE_ZFOLIO_BBVA       = 'E'
   MANDT                  = SY-MANDT
   BUKRS                  = bukrs
   CODIGO                 = '001'.
          .
IF sy-subrc <> 0.
 MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
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

    IF lineas = 9000.
      CONCATENATE archivo bukrs v_fecha v_nomina  secuencia INTO archivo_a.

      PERFORM bajar_archivo.
      CLEAR: lineas, monto_z.
    ENDIF.

    zfolio_bbva-folio =  zfolio_bbva-folio + 1.
    IF par_di = 'X'.
      MODIFY  zfolio_bbva.
    ENDIF.

    IF tabla_00-identif_pago IS INITIAL.
      CONCATENATE bukrs zfolio_bbva-folio INTO folio_aux .
    ELSE.
      CLEAR folio_aux.
      MOVE tabla_00-identif_pago TO folio_aux.
    ENDIF.

    TRANSLATE tabla_00-zstc1 USING '- ' .
    CONDENSE  tabla_00-zstc1 NO-GAPS    .
    largo = STRLEN( tabla_00-zstc1 ) - 1.
    reg01-rut_prv         =  tabla_00-zstc1+0(largo).
    reg01-rut_dvr        =  tabla_00-zstc1+largo(1).

    reg01-identificador   =  folio_aux.
    reg01-nombre          =  tabla_00-name1.
    reg01-tipo_proceso    = '1'.
    reg01-cod_banco       = '504'.
    reg01-cuenta_abo      =''.
    reg01-destino         = '3'.
    reg01-monto_pago = tabla_00-rbetr * -100.
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
* CBD - SE MULTIPLICA POR 100 PARA IGUAL CON CAMBIO EN NVO_FORMATO
* CBD    monto_z  =   monto_z + ( tabla_00-rbetr * -1 ).
    monto_z  =   monto_z + ( tabla_00-rbetr * -100 ).
* CBD - SE MULTIPLICA POR 100 PARA IGUAL CON CAMBIO EN NVO_FORMATO
  ENDLOOP.


CALL FUNCTION 'DEQUEUE_EZFOLIO'
 EXPORTING
   MODE_ZFOLIO_BBVA       = 'E'
   MANDT                  = SY-MANDT
   BUKRS                  = bukrs
   CODIGO                 = '001'.

  IF lineas > 0.
    IF par_di = 'X'.
      CONCATENATE archivo bukrs v_fecha v_nomina  secuencia INTO archivo_a.
    ELSE.
      CONCATENATE archivo 'TEST_' bukrs v_fecha v_nomina  secuencia INTO archivo_a.
    ENDIF.
    PERFORM bajar_archivo.
  ENDIF.

ENDFORM.                    " PREPARO_SALIDA

*&---------------------------------------------------------------------*
*&      Form  bajar_archivo
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM bajar_archivo.
*-----------------*
  DATA : nombre_a  TYPE string.

  CONCATENATE archivo_a '_ant.txt'
    INTO archivo_a.

  nombre_a = archivo_a.

  sy-subrc = 0.

  IF par_di = 'X'.
    CALL FUNCTION 'GUI_DOWNLOAD'
      EXPORTING
        filename                = nombre_a
        filetype                = 'ASC'
        confirm_overwrite       = 'X'
      TABLES
        data_tab                = reg01
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

  ENDIF.

  IF sy-subrc <> 0.
    WRITE :/ 'error!!!!'  ,
           /  sy-msgv1 ,
           /  sy-msgv2 ,
           /  sy-msgv3 ,
           /  sy-msgv4 .

  ELSE.
    SKIP 2 .
    FORMAT COLOR 3 ON.

    IF par_di = 'X'.
      WRITE : / 'Se genero archivo :', archivo_a.
      IF contabilizar <> 'N'.
        PERFORM  contabilizacion.
      ENDIF.
      PERFORM  grabar_log.
    ELSE.
      WRITE : / 'Se generara el siguiente archivo :', archivo_a.
    ENDIF.
* CBD - SE CAMBIA PARA IGUALAR CON NVO_FORMATO
* CBD    WRITE : /10 'total registros : ', lineas,
* CBD                'total monto  : ',  monto_z CURRENCY 'CLP'.
    WRITE : /10 'total registros : ', lineas,
                'total monto  : ',  monto_z.
* CBD - SE CAMBIA PARA IGUALAR CON NVO_FORMATO
    FORMAT COLOR 3 OFF.
    CLEAR: lineas, monto_z.
  ENDIF.

  secuencia = secuencia + 1.
  REFRESH reg01.

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
  zlog_bbva_vv-bukrs = bukrs.
  zlog_bbva_vv-laufd = v_fecha.
  zlog_bbva_vv-laufi = v_nomina.
  zlog_bbva_vv-fecha_gen = sy-datum.
  zlog_bbva_vv-hora_gen = sy-uzeit.
  zlog_bbva_vv-uname = sy-uname.
  CONCATENATE bukrs v_fecha v_nomina  secuencia INTO zlog_bbva_vv-nombre_arc.
  zlog_bbva_vv-total  = monto_z.
  zlog_bbva_vv-lineas = lineas.
  zlog_bbva_vv-gjahr  =  gjahr.
  zlog_bbva_vv-belnr  =  belnr.
  zlog_bbva_vv-nrotran  =  v_nrotra.
  INSERT zlog_bbva_vv.

ENDFORM.                    "GRABAR_LOG
*&---------------------------------------------------------------------*
*&      Form  contabilizacion
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM contabilizacion.
  DATA: valor(18) TYPE c.

  CLEAR bdcdata.
  REFRESH bdcdata.
* CBD - SE SACA FORMATEO A 'CLP'
* LSC
  valor = monto_z.
  REPLACE '.00' WITH '' INTO valor.
  CONDENSE valor NO-GAPS.
  total = monto_z.
* CBD WRITE  monto_z                 TO total.
* CBD - SE SACA FORMATEO A 'CLP'
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
                                valor. "total. LSC
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

INCLUDE zfitr010_nvo_formato.

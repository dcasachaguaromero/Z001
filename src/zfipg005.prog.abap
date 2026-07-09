*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES02 > *
*& Description: < ReSQ Correction > *
*& Date: <20-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Report  ZFIPG005
*&
*&---------------------------------------------------------------------*
*&  Informe Cheques Emitidos
*&*&---------------------------------------------------------------------*

REPORT  zfipg005 NO STANDARD PAGE HEADING
                                   LINE-COUNT 60
                                   LINE-SIZE 180 .

TABLES: reguh,
        regup,
        payr,
        bseg,
        zmot_emis,
        zagencia,
        zfipg001.


DATA : BEGIN OF tdatos OCCURS 0,
         bukrs      LIKE  bseg-bukrs,
         zz_agencia LIKE  bseg-zz_agencia,
         xref1      LIKE  regup-xref1,
         blart      LIKE  regup-blart,
         zzmot_emis LIKE  bseg-zzmot_emis,
         zaldt      LIKE  payr-zaldt,
         stcd1      LIKE  reguh-stcd1,
         chect      LIKE  payr-chect,
         znme1      LIKE  payr-znme1,
         rwbtr      LIKE  payr-rwbtr,
         hktid      LIKE  payr-hktid,
         hbkid      LIKE regup-hbkid,
       END OF tdatos.


DATA : BEGIN OF tage  OCCURS 0,
          bukrs          LIKE  zagencia-bukrs,
          zzcod_unidad   LIKE  zagencia-zzcod_unidad,
          zzdescr        LIKE  zagencia-zzdescr,
       END OF tage.

DATA : BEGIN OF tmot OCCURS 0,
          bukrs          LIKE  zmot_emis-bukrs,
          zzmot_emis     LIKE  zmot_emis-zzmot_emis,
          zzdescr        LIKE  zmot_emis-zzdescr,
       END OF tmot.


DATA : BEGIN OF tare OCCURS 0,
          bukrs          LIKE  zfipg001-bukrs,
          blart          LIKE  zfipg001-blart,
          descr          LIKE  zfipg001-descr,
       END OF tare.

*------- interne Tabelle für die Laufkennung (nur SPACE erlaubt)

DATA:    BEGIN OF tlaufk OCCURS 1.
        INCLUDE STRUCTURE ilaufk.
DATA:    END OF tlaufk.
DATA lt_dynpfields LIKE dynpread OCCURS 1 WITH HEADER LINE.
DATA lv_dynpro_prog LIKE d020s-prog.

DATA: ncheques(5)   TYPE n.
DATA: tcheques(5)   TYPE n.
DATA  v_nom_soc(30) type c.
DATA  v_fech_pago   like  tdatos-zaldt.
DATA: v_agen(40)    type c.
DATA: v_total_ln    like tdatos-rwbtr.

PARAMETER : v_fecha  LIKE reguh-laufd    OBLIGATORY,
            v_nomina LIKE f110v-laufi    OBLIGATORY.


AT SELECTION-SCREEN ON VALUE-REQUEST FOR v_fecha.

  REFRESH tlaufk.
  tlaufk-laufk = space.
  tlaufk-sign  = 'I'.
  APPEND tlaufk.
  CALL FUNCTION 'F4_ZAHLLAUF'
    EXPORTING
      f1typ = 'D'
      f2nme = 'F110V-LAUFI'
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

*Begin of change: ReSQ Correction INDEX READ on an unsorted Internal TABLE 20/12/2019 EY_DES02 ECDK917080 *
SORT LT_DYNPFIELDS .
*End of change: ReSQ Correction for INDEX READ on an unsorted Internal TABLE 20/12/2019 EY_DES02 ECDK917080 *
  READ TABLE lt_dynpfields INDEX 1.
  lt_dynpfields-fieldvalue = v_nomina.
*Begin of change: ReSQ Correction for MODIFY on an unsorted Internal Table 20/12/2019 EY_DES02 ECDK917080 *
SORT LT_DYNPFIELDS .
*End of change: ReSQ Correction for MODIFY on an unsorted Internal Table 20/12/2019 EY_DES02 ECDK917080 *
  MODIFY  lt_dynpfields INDEX 1.

*ReSQ: No Need Of Change Internal Table LT_DYNPFIELDS Already Sorted
  READ TABLE lt_dynpfields INDEX 1.
  lt_dynpfields-fieldvalue = v_nomina.
*Begin of change: ReSQ Correction for MODIFY on an unsorted Internal Table 20/12/2019 EY_DES02 ECDK917080 *
SORT LT_DYNPFIELDS .
*End of change: ReSQ Correction for MODIFY on an unsorted Internal Table 20/12/2019 EY_DES02 ECDK917080 *
  MODIFY  lt_dynpfields INDEX 1.

  CALL FUNCTION 'DYNP_VALUES_UPDATE'
    EXPORTING
      dyname     = lv_dynpro_prog
      dynumb
      ='1000'
    TABLES
      dynpfields = lt_dynpfields.


AT SELECTION-SCREEN ON VALUE-REQUEST FOR v_nomina.


  REFRESH tlaufk.
  tlaufk-laufk = space.
  tlaufk-sign  = 'I'.
  APPEND tlaufk.
  CALL FUNCTION 'F4_ZAHLLAUF'
    EXPORTING
      f1typ = 'I'
      f2nme = 'F110V-LAUFD'
    IMPORTING
      laufd = v_fecha
      laufi = v_nomina
    TABLES
      laufk = tlaufk.

  REFRESH lt_dynpfields.
  lt_dynpfields-fieldname = 'V_FECHA'.
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
*Begin of change: ReSQ Correction for MODIFY on an unsorted Internal Table 20/12/2019 EY_DES02 ECDK917080 *
SORT LT_DYNPFIELDS .
*End of change: ReSQ Correction for MODIFY on an unsorted Internal Table 20/12/2019 EY_DES02 ECDK917080 *
  MODIFY  lt_dynpfields INDEX 1.


  CALL FUNCTION 'DYNP_VALUES_UPDATE'
    EXPORTING
      dyname     = lv_dynpro_prog
      dynumb
      ='1000'
    TABLES
      dynpfields = lt_dynpfields.


START-OF-SELECTION.

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT * FROM  reguh   WHERE  laufd = v_fecha
*                         AND    laufi = v_nomina
*                         AND    xvorl = '' .
*
* NEW CODE
  SELECT *
 FROM  reguh   WHERE  laufd = v_fecha
                         AND    laufi = v_nomina
                         AND    xvorl = ''  ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03



* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE * FROM  payr WHERE zbukr  = reguh-zbukr
*                               AND   vblnr  = reguh-vblnr
*                               AND   gjahr  = reguh-zaldt+0(4).
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  FROM  payr WHERE zbukr  = reguh-zbukr
                               AND   vblnr  = reguh-vblnr
                               AND   gjahr  = reguh-zaldt+0(4) ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

    if sy-subrc <> 0.
      clear payr.
    endif.

*ResQ Comment:Correction not required as Select Single is used 20/12/2019 EY_DES02 ECDK917080 *
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE  * FROM  regup WHERE laufd = reguh-laufd
*                                AND   laufi = reguh-laufi
*                                AND   xvorl = reguh-xvorl
*                                AND   zbukr = reguh-zbukr
*                                AND   lifnr = reguh-lifnr
*                                AND   kunnr = reguh-kunnr
*                                AND   empfg = reguh-empfg
*                                AND   vblnr = reguh-vblnr.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  FROM  regup WHERE laufd = reguh-laufd
                                AND   laufi = reguh-laufi
                                AND   xvorl = reguh-xvorl
                                AND   zbukr = reguh-zbukr
                                AND   lifnr = reguh-lifnr
                                AND   kunnr = reguh-kunnr
                                AND   empfg = reguh-empfg
                                AND   vblnr = reguh-vblnr ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
*ResQ Comment:Correction not required as Select Single is used 20/12/2019 EY_DES02 ECDK917080 *
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE  * FROM  bseg WHERE bukrs  = regup-bukrs
*                           AND  belnr = regup-belnr
*                           AND  gjahr = regup-gjahr
*                           AND  buzei = regup-buzei.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  FROM  bseg WHERE bukrs  = regup-bukrs
                           AND  belnr = regup-belnr
                           AND  gjahr = regup-gjahr
                           AND  buzei = regup-buzei ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01



    payr-rwbtr        = payr-rwbtr * -1.
    tdatos-blart      = regup-blart.

    tdatos-zz_agencia = bseg-zz_agencia.
    tdatos-zzmot_emis = bseg-zzmot_emis.
    tdatos-zaldt      = payr-zaldt.
    tdatos-stcd1      = reguh-stcd1.
    tdatos-chect      = payr-chect.
    tdatos-znme1      = payr-znme1.
    tdatos-rwbtr      = payr-rwbtr.
    tdatos-hktid      = payr-hktid.
    tdatos-xref1      = regup-xref1.
    tdatos-hbkid      = bseg-hbkid.

    tdatos-bukrs      = reguh-zbukr.
    APPEND tdatos.


  ENDSELECT.


  SORT tdatos BY bukrs  zz_agencia xref1.



  SELECT *  FROM zagencia INTO CORRESPONDING FIELDS OF TABLE tage .

  SELECT *  FROM zmot_emis INTO CORRESPONDING FIELDS OF TABLE tmot .

  SELECT *  FROM zfipg001 INTO CORRESPONDING FIELDS OF TABLE tare .

  SORT tage BY bukrs zzcod_unidad.

  SORT tmot BY bukrs zzmot_emis.

  SORT tare BY bukrs blart.


  CLEAR:  ncheques, tcheques.

  LOOP AT tdatos.

*    AT NEW zz_agencia.
*      NEW-PAGE.
*    ENDAT.


    READ TABLE tare WITH KEY bukrs    =  tdatos-bukrs
                             blart    =  tdatos-blart
                             BINARY SEARCH.

    IF sy-subrc <> 0.
      tare-descr  = 'Sin Descripcion'.
    ENDIF.

    READ TABLE tmot WITH KEY bukrs           =  tdatos-bukrs
                             zzmot_emis     =  tdatos-zzmot_emis
                             BINARY SEARCH.

    IF sy-subrc <> 0.
      tmot-zzdescr  = 'Sin Descripcion'.
    ENDIF.


    READ TABLE tage WITH KEY bukrs           =  tdatos-bukrs
                             zzcod_unidad    =  tdatos-zz_agencia
                             BINARY SEARCH.

    IF sy-subrc <> 0.
      tage-zzdescr  = 'Sin Descripcion'.
    ENDIF.

    v_fech_pago =  tdatos-zaldt.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = tdatos-zz_agencia
      IMPORTING
        OUTPUT = tdatos-zz_agencia.

    CONCATENATE tdatos-zz_agencia '-' tage-zzdescr INTO v_agen SEPARATED BY space.

    ncheques = ncheques + 1.
    tcheques = tcheques + 1.

    v_total_ln = v_total_ln + tdatos-rwbtr.
    FORMAT INTENSIFIED OFF COLOR = 0.

    AT END OF zz_agencia.
      SUM.
      WRITE:/1
      v_agen(30),
      '',
      tare-descr(30),
      '          ',
      tmot-zzdescr(20),
      '       ',
      v_fech_pago
      .

      WRITE:125 v_total_ln CURRENCY payr-waers RIGHT-JUSTIFIED.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          INPUT  = ncheques
        IMPORTING
          OUTPUT = ncheques.

      WRITE:158 ncheques RIGHT-JUSTIFIED.

      CLEAR: ncheques, v_total_ln.

      AT LAST.
        SUM.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
          EXPORTING
            INPUT  = tcheques
          IMPORTING
            OUTPUT = tcheques.

        ULINE.
        WRITE:/110 'Total General:', 125 tdatos-rwbtr CURRENCY payr-waers RIGHT-JUSTIFIED.
        WRITE:158 tcheques RIGHT-JUSTIFIED.

        CLEAR ncheques.

      ENDAT.

    ENDAT.



  ENDLOOP.


END-OF-SELECTION.



TOP-OF-PAGE.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  select single name1 from T880 into v_nom_soc where RCOMP = tdatos-bukrs.
*
* NEW CODE
  SELECT name1
  UP TO 1 ROWS  from T880 into v_nom_soc where RCOMP = tdatos-bukrs ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
 FORMAT INTENSIFIED OFF COLOR = 0.
  WRITE:/70 'RESUMEN DE CHEQUES DEL PROCESO ',
   150  'Fecha: ', sy-datum LEFT-JUSTIFIED.
*  WRITE:/70 tdatos-bukrs, v_nom_soc.

  WRITE:/1  'Fecha Proceso :',
             v_fecha, 70 tdatos-bukrs, v_nom_soc,
        150  'Hora : ', sy-uzeit LEFT-JUSTIFIED.

  WRITE:/ 'Identificador :',
             v_nomina,
         150  'Pág. : ', sy-pagno LEFT-JUSTIFIED.
  write:/150 'Prog.: ', sy-cprog(10) LEFT-JUSTIFIED.

  SKIP.

  ULINE.

  WRITE:/1 'Agencia                         ',
           'Area                                     ',
           'Motivo                      ',
           'Fecha Pago',
            129 'Monto Cheques',
            150 'Total Cheques'.

  ULINE.

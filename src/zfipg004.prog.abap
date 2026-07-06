*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES02 > *
*& Description: < ReSQ Correction > *
*& Date: <20-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Report  ZFIPG004
*&
*&---------------------------------------------------------------------*
*&  Informe Cheques Emitidos
*&*&---------------------------------------------------------------------*

REPORT  zfipg004 NO STANDARD PAGE HEADING
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
DATA: v_nom_soc(30) TYPE c.
DATA: v_agen(40)    TYPE c.
DATA: v_total_ln    LIKE tdatos-rwbtr.

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

  SELECT * FROM  reguh   WHERE  laufd = v_fecha
                         AND    laufi = v_nomina
                         AND    xvorl = '' .



    SELECT SINGLE * FROM  payr WHERE zbukr  = reguh-zbukr
                               AND   vblnr  = reguh-vblnr
                               AND   gjahr  = reguh-zaldt+0(4)
                               AND   voidr EQ ''.


    IF sy-subrc <> 0.
      CLEAR payr.
    ENDIF.

*ResQ Comment:Correction not required as Select Single is used 20/12/2019 EY_DES02 ECDK917080 *
    SELECT SINGLE  * FROM  regup WHERE laufd = reguh-laufd
                                AND   laufi = reguh-laufi
                                AND   xvorl = reguh-xvorl
                                AND   zbukr = reguh-zbukr
                                AND   lifnr = reguh-lifnr
                                AND   kunnr = reguh-kunnr
                                AND   empfg = reguh-empfg
                                AND   vblnr = reguh-vblnr.

*ResQ Comment:Correction not required as Select Single is used 20/12/2019 EY_DES02 ECDK917080 *
    SELECT SINGLE  * FROM  bseg WHERE bukrs  = regup-bukrs
                           AND  belnr = regup-belnr
                           AND  gjahr = regup-gjahr
                           AND  buzei = regup-buzei.



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

    AT NEW zz_agencia.
      NEW-PAGE.
    ENDAT.


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

    FORMAT INTENSIFIED OFF COLOR = 0.

    WRITE:/1

    tare-descr(25),
    ' ',
    tmot-zzdescr(25),
    ' ',
    tdatos-zaldt,
     ' ',
    tdatos-stcd1(13) RIGHT-JUSTIFIED,
    ' ',
    tdatos-chect,
    ' ',
    tdatos-znme1,
    ' ',
    tdatos-rwbtr CURRENCY payr-waers,
    ' ',
*    tdatos-hktid,
    tdatos-hbkid,
    ' ',
    tdatos-xref1.

    ncheques = ncheques + 1.
    tcheques = tcheques + 1.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        input  = ncheques
      IMPORTING
        output = ncheques.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        input  = tcheques
      IMPORTING
        output = tcheques.

    v_total_ln = v_total_ln + tdatos-rwbtr.

    AT END OF zz_agencia.
      SUM.
      ULINE.
      WRITE:/100 'Total Agencia',
        121 'Monto Total      :',
          v_total_ln CURRENCY payr-waers.
      WRITE:/121 'Total de Cheques :            ',
          ncheques RIGHT-JUSTIFIED.

      CLEAR: ncheques, v_total_ln.

      AT LAST.

        SUM.
        ULINE.
        WRITE:/100 'Total General',

            121 'Monto Total      :',

            tdatos-rwbtr CURRENCY payr-waers.
        WRITE:/121 'Total de Cheques :            ',

        tcheques RIGHT-JUSTIFIED.

        CLEAR ncheques.

      ENDAT.

    ENDAT.



  ENDLOOP.


END-OF-SELECTION.



TOP-OF-PAGE.

  SELECT SINGLE name1 FROM t880 INTO v_nom_soc WHERE rcomp = tdatos-bukrs.
  FORMAT INTENSIFIED OFF COLOR = 0.

  WRITE:/70 'LISTA DE CHEQUES DEL PROCESO ',
   150  'Fecha: ', sy-datum LEFT-JUSTIFIED.
*  WRITE:/70 tdatos-bukrs, v_nom_soc.

  WRITE:/1  'Fecha Proceso :',
             v_fecha, 70 tdatos-bukrs, v_nom_soc,
        150  'Hora : ', sy-uzeit LEFT-JUSTIFIED.

  WRITE:/ 'Identificador :',
             v_nomina,
         150  'Pág. : ', sy-pagno LEFT-JUSTIFIED.
  WRITE:/150 'Prog.: ', sy-cprog(10) LEFT-JUSTIFIED.


  READ TABLE tage WITH KEY bukrs           =  tdatos-bukrs
                           zzcod_unidad    =  tdatos-zz_agencia
                           BINARY SEARCH.

  IF sy-subrc <> 0.
    tage-zzdescr  = 'Sin Descripcion'.
  ENDIF.

  SKIP.


  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
    EXPORTING
      input  = tdatos-zz_agencia
    IMPORTING
      output = tdatos-zz_agencia.

  CONCATENATE tdatos-zz_agencia '-' tage-zzdescr INTO v_agen SEPARATED BY space.
  IF v_agen = '1000'.
    CONCATENATE v_agen '-' tdatos-xref1 INTO v_agen SEPARATED BY space.
  ENDIF.

*  WRITE:/1 'AGENCIA       :', tdatos-zz_agencia, '-', tage-zzdescr.
  WRITE:/1 'AGENCIA       :', v_agen.

  ULINE.

  WRITE:/1 'Area                       ',
           'Motivo                     ',
           'Fecha Pago          ',
           'RUT        ',
           'N° Cheque  ',
           'Glosa Cheque                              ',
           'Monto Cheque  ',
           'Cta.Bco.',
           'Referencia'.



  ULINE.

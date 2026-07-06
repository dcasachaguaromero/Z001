*&---------------------------------------------------------------------*
*&  Include           ZCL_CREA_PEDIDOS_F01
*&---------------------------------------------------------------------*


*&---------------------------------------------------------------------*
*&      Form  UPDATE_ORACLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM UPDATE_ORACLE.

  CLEAR WA_TE.
  MOVE-CORRESPONDING LS_PEDIDO TO WA_TE.
  WA_TE-SAPINDTRASPASO = 'X'.
  exec sql.
    update factsaptraspaso set sapindtraspaso = :wa_te-sapindtraspaso
                               where sapnumfactura = :wa_te-sapnumfactura
  endexec.

ENDFORM.                    " UPDATE_ORACLE
*&---------------------------------------------------------------------*
*&      Form  ORACLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ORACLE .

  SELECT SINGLE DBMS FROM DBCON INTO DBTYPE WHERE CON_NAME EQ PCONNAME.
  IF DBTYPE = 'ORA'.
    CLEAR INDTRAS.
    TRY.
      EXEC SQL.
        CONNECT TO :PCONNAME
      ENDEXEC.
      IF SY-SUBRC <> 0.
        RAISE EXCEPTION TYPE CX_SY_NATIVE_SQL_ERROR.
      ELSE.
        EXEC SQL.
          SET CONNECTION :PCONNAME
        ENDEXEC.
        EXEC SQL.
          OPEN :PCONNAME FOR SELECT sapclaseventa,
                                    sapindelec,
                                    saporgvta,
                                    sapcanaldis,
                                    sapsectorfact,
                                    sapofivta,
                                    sapgrupovend,
                                    saprutfactura,
                                    sapnombrefactura,
                                    saprutpagador,
                                    sapgirocli,
                                    sapdircli,
                                    sapcomuna,
                                    sapciudad,
                                    sapnumfolioctr,
                                    to_char(sapfechactr, 'YYYYMMDD') as sapfechactr,
                                    sapnumevento,
                                    sapconpago,
                                    sapnumfactura,
                                    sapindtraspaso,
                                    saptarjcuenta,
                                    sapcodbanco,
                                    sapestctr,
                                    saptipotarj,
                                    sapmoneda,
                                    sapplanctr,
                                    sapviapago,
                                    saptipocambio,
                                    sapcentro,
                                    sapnummandato,
                                    sapnumendoso,
                                    sapafeexe,
                                    saptipocopago,
                                    sapperiodicidad,
                                    sapcodplan,
                                    saptotalfact,
                                    sapindbloqueo,
                                    sapmontouf,
                                    saprutbeneficiario,
                                    sapcodproducto,
                                    sapctdad,
                                    sapvallista,
                                    sapvaladic,
                                    sapdctoconv,
                                    sapdctoperm,
                                    sapdctoprom,
                                    sapdctotemp,
                                    sapingbemhelp,
                                    sapingotros,
                                    saprangoeta,
                                    sapsectorafi,
                                    to_char(SAPFECHAFACT, 'YYYYMMDD') as SAPFECHAFACT,
                                    to_char(SAPFECHACORE, 'YYYYMMDD') as SAPFECHACORE,
                                    to_char(SAPFECHAVENC, 'YYYYMMDD') as SAPFECHAVENC,
                                    sapglosadoc
                 FROM FACTSAPTRASPASO
        ENDEXEC.

        DO.
          EXEC SQL.
            FETCH NEXT :PCONNAME INTO :WA_TE-SAPCLASEVENTA,
                                      :WA_TE-SAPINDELEC,
                                      :WA_TE-SAPORGVTA,
                                      :WA_TE-SAPCANALDIS,
                                      :WA_TE-SAPSECTORFACT,
                                      :WA_TE-SAPOFIVTA,
                                      :WA_TE-SAPGRUPOVEND,
                                      :WA_TE-SAPRUTFACTURA,
                                      :WA_TE-SAPNOMBREFACTURA,
                                      :WA_TE-SAPRUTPAGADOR,
                                      :WA_TE-SAPGIROCLI,
                                      :WA_TE-SAPDIRCLI,
                                      :WA_TE-SAPCOMUNA,
                                      :WA_TE-SAPCIUDAD,
                                      :WA_TE-SAPNUMFOLIOCTR,
                                      :WA_TE-SAPFECHACTR,
                                      :WA_TE-SAPNUMEVENTO,
                                      :WA_TE-SAPCONPAGO,
                                      :WA_TE-SAPNUMFACTURA,
                                      :WA_TE-SAPINDTRASPASO,
                                      :WA_TE-SAPTARJCUENTA,
                                      :WA_TE-SAPCODBANCO,
                                      :WA_TE-SAPESTCTR,
                                      :WA_TE-SAPTIPOTARJ,
                                      :WA_TE-SAPMONEDA,
                                      :WA_TE-SAPPLANCTR,
                                      :WA_TE-SAPVIAPAGO,
                                      :WA_TE-SAPTIPOCAMBIO,
                                      :WA_TE-SAPCENTRO,
                                      :WA_TE-SAPNUMMANDATO,
                                      :WA_TE-SAPNUMENDOSO,
                                      :WA_TE-SAPAFEEXE,
                                      :WA_TE-SAPTIPOCOPAGO,
                                      :WA_TE-SAPPERIODICIDAD,
                                      :WA_TE-SAPCODPLAN,
                                      :WA_TE-SAPTOTALFACT,
                                      :WA_TE-SAPINDBLOQUEO,
                                      :WA_TE-SAPMONTOUF,
                                      :WA_TE-SAPRUTBENEFICIARIO,
                                      :WA_TE-SAPCODPRODUCTO,
                                      :WA_TE-SAPCTDAD,
                                      :WA_TE-SAPVALLISTA,
                                      :WA_TE-SAPVALADIC,
                                      :WA_TE-SAPDCTOCONV,
                                      :WA_TE-SAPDCTOPERM,
                                      :WA_TE-SAPDCTOPROM,
                                      :WA_TE-SAPDCTOTEMP,
                                      :WA_TE-SAPINGBEMHELP,
                                      :WA_TE-SAPINGOTROS,
                                      :WA_TE-SAPRANGOETA,
                                      :WA_TE-SAPSECTORAFI,
                                      :WA_TE-SAPFECHAFACT,
                                      :WA_TE-SAPFECHACORE,
                                      :WA_TE-SAPFECHAVENC,
                                      :WA_TE-SAPGLOSADOC
          ENDEXEC.
          IF SY-SUBRC <> 0.
            EXIT.
          ELSE.
            If WA_TE-SAPNUMFACTURA IS INITIAL.
              WRITE : '** Sin numero Core : ', WA_TE.
            else.
              APPEND WA_TE TO TI_PEDIDO.
            Endif.
          ENDIF.
        ENDDO.
      ENDIF.
    ENDTRY.
  ENDIF.

 DELETE TI_PEDIDO WHERE SAPINDTRASPASO EQ 'X'.

ENDFORM.                    " ORACLE
*&---------------------------------------------------------------------*
*&      Form  LOCAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM LOCAL .

  CLEAR FILE.
  FILE = P_FILE.

  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      FILENAME = FILE
      FILETYPE = 'DAT'
    TABLES
      DATA_TAB = TI_FILE[].

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ELSE.
    LOOP AT TI_FILE.
      SPLIT TI_FILE-LINE AT ';' INTO: LS_PEDIDO-SAPCLASEVENTA
      LS_PEDIDO-SAPINDELEC
      LS_PEDIDO-SAPORGVTA
      LS_PEDIDO-SAPCANALDIS
      LS_PEDIDO-SAPSECTORFACT
      LS_PEDIDO-SAPOFIVTA
      LS_PEDIDO-SAPGRUPOVEND
      LS_PEDIDO-SAPRUTFACTURA
      LS_PEDIDO-SAPNOMBREFACTURA
      LS_PEDIDO-SAPRUTPAGADOR
      LS_PEDIDO-SAPGIROCLI
      LS_PEDIDO-SAPDIRCLI
      LS_PEDIDO-SAPCOMUNA
      LS_PEDIDO-SAPCIUDAD
      LS_PEDIDO-SAPNUMFOLIOCTR
      LS_PEDIDO-SAPFECHACTR
      LS_PEDIDO-SAPNUMEVENTO
      LS_PEDIDO-SAPCONPAGO
      LS_PEDIDO-SAPNUMFACTURA
      LS_PEDIDO-SAPINDTRASPASO
      LS_PEDIDO-SAPTARJCUENTA
      LS_PEDIDO-SAPCODBANCO
      LS_PEDIDO-SAPESTCTR
      LS_PEDIDO-SAPTIPOTARJ
      LS_PEDIDO-SAPMONEDA
      LS_PEDIDO-SAPPLANCTR
      LS_PEDIDO-SAPVIAPAGO
      LS_PEDIDO-SAPTIPOCAMBIO
      LS_PEDIDO-SAPCENTRO
      LS_PEDIDO-SAPNUMMANDATO
      LS_PEDIDO-SAPNUMENDOSO
      LS_PEDIDO-SAPAFEEXE
      LS_PEDIDO-SAPTIPOCOPAGO
      LS_PEDIDO-SAPPERIODICIDAD
      LS_PEDIDO-SAPCODPLAN
      LS_PEDIDO-SAPTOTALFACT
      LS_PEDIDO-SAPINDBLOQUEO
      LS_PEDIDO-SAPMONTOUF
      LS_PEDIDO-SAPRUTBENEFICIARIO
      LS_PEDIDO-SAPCODPRODUCTO
      LS_PEDIDO-SAPCTDAD
      LS_PEDIDO-SAPVALLISTA
      LS_PEDIDO-SAPVALADIC
      LS_PEDIDO-SAPDCTOCONV
      LS_PEDIDO-SAPDCTOPERM
      LS_PEDIDO-SAPDCTOPROM
      LS_PEDIDO-SAPDCTOTEMP
      LS_PEDIDO-SAPINGBEMHELP
      LS_PEDIDO-SAPINGOTROS
      LS_PEDIDO-SAPRANGOETA
      LS_PEDIDO-SAPSECTORAFI
      LS_PEDIDO-SAPFECHAFACT
      LS_PEDIDO-SAPFECHACORE
      LS_PEDIDO-SAPFECHAVENC
      LS_PEDIDO-SAPGLOSADOC.
      APPEND LS_PEDIDO TO TI_PEDIDO.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " LOCAL
*&---------------------------------------------------------------------*
*&      Form  INIT_FIELDCAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM INIT_FIELDCAT .

  PERFORM CREATE_FIEDCAT USING 'SAPNUMFACTURA'      'N° Factura'.
  PERFORM CREATE_FIEDCAT USING 'POS_FAC'            'Posición'.
  PERFORM CREATE_FIEDCAT USING 'EST_PROC'           'E°Carga'.
  PERFORM CREATE_FIEDCAT USING 'DES_EST'            'Descripción'.
  PERFORM CREATE_FIEDCAT USING 'SAPCLASEVENTA'      'Clase de venta'.
  PERFORM CREATE_FIEDCAT USING 'SAPINDELEC'         'Ind. Elec'.
  PERFORM CREATE_FIEDCAT USING 'SAPORGVTA'          'Org.Vta'.
  PERFORM CREATE_FIEDCAT USING 'SAPCANALDIS'        'Canal Dis.'.
  PERFORM CREATE_FIEDCAT USING 'SAPSECTORFACT'      'Sector Fact'.
  PERFORM CREATE_FIEDCAT USING 'SAPOFIVTA'          'Ofic. Vta.'.
  PERFORM CREATE_FIEDCAT USING 'SAPGRUPOVEND'       'Grp. Vendedor'.
  PERFORM CREATE_FIEDCAT USING 'SAPRUTFACTURA'      'Rut Fact.'.
  PERFORM CREATE_FIEDCAT USING 'SAPNOMBREFACTURA'   'Nombe Fact.'.
  PERFORM CREATE_FIEDCAT USING 'SAPRUTPAGADOR'      'Rut Pagador'.
  PERFORM CREATE_FIEDCAT USING 'SAPGIROCLI'         'Giro Cliente'.
  PERFORM CREATE_FIEDCAT USING 'SAPDIRCLI'          'Dirección Cliente'.
  PERFORM CREATE_FIEDCAT USING 'SAPCOMUNA'          'Comuna'.
  PERFORM CREATE_FIEDCAT USING 'SAPCIUDAD'          'Ciudad'.
  PERFORM CREATE_FIEDCAT USING 'SAPNUMFOLIOCTR'     'N° Folio Ctr.'.
  PERFORM CREATE_FIEDCAT USING 'SAPFECHACTR'        'Fecha Ctr.'.
  PERFORM CREATE_FIEDCAT USING 'SAPNUMEVENTO'       'N° Evento'.
  PERFORM CREATE_FIEDCAT USING 'SAPCONPAGO'         'Cond. Pago'.
  PERFORM CREATE_FIEDCAT USING 'SAPINDTRASPASO'     'Ind. Traspaso'.
  PERFORM CREATE_FIEDCAT USING 'SAPTARJCUENTA'      'Tarj. Cta'.
  PERFORM CREATE_FIEDCAT USING 'SAPCODBANCO'        'Cod. Banco'.
  PERFORM CREATE_FIEDCAT USING 'SAPESTCTR'          'Est. Contrato'.
  PERFORM CREATE_FIEDCAT USING 'SAPTIPOTARJ'        'Tipo tarjeta'.
  PERFORM CREATE_FIEDCAT USING 'SAPMONEDA'          'Moneda'.
  PERFORM CREATE_FIEDCAT USING 'SAPPLANCTR'         'Plan Ctr.'.
  PERFORM CREATE_FIEDCAT USING 'SAPVIAPAGO'         'Vía Pago'.
  PERFORM CREATE_FIEDCAT USING 'SAPTIPOCAMBIO'      'Tipo Cambio'.
  PERFORM CREATE_FIEDCAT USING 'SAPCENTRO'          'Centro'.
  PERFORM CREATE_FIEDCAT USING 'SAPNUMMANDATO'      'N° Mandato'.
  PERFORM CREATE_FIEDCAT USING 'SAPNUMENDOSO'       'N° Endoso'.
  PERFORM CREATE_FIEDCAT USING 'SAPAFEEXE'          'Afe.Exe.'.
  PERFORM CREATE_FIEDCAT USING 'SAPTIPOCOPAGO'      'Tipo Copago'.
  PERFORM CREATE_FIEDCAT USING 'SAPPERIODICIDAD'    'Periodicidad'.
  PERFORM CREATE_FIEDCAT USING 'SAPCODPLAN'         'Cod. Plan'.
  PERFORM CREATE_FIEDCAT USING 'SAPTOTALFACT'       'Total Fact'.
  PERFORM CREATE_FIEDCAT USING 'SAPINDBLOQUEO'      'Ind. Bloqueo'.
  PERFORM CREATE_FIEDCAT USING 'SAPMONTOUF'         'Monto UF'.
  PERFORM CREATE_FIEDCAT USING 'SAPRUTBENEFICIARIO' 'Rut Beneficiario'.
  PERFORM CREATE_FIEDCAT USING 'SAPCODPRODUCTO'     'Cod. Producto'.
  PERFORM CREATE_FIEDCAT USING 'SAPCTDAD'           'Cantidad'.
  PERFORM CREATE_FIEDCAT USING 'SAPVALLISTA'        'Val. Lista'.
  PERFORM CREATE_FIEDCAT USING 'SAPVALADIC'         'Val. Adicional'.
  PERFORM CREATE_FIEDCAT USING 'SAPDCTOCONV'        'Dscto. Conv.'.
  PERFORM CREATE_FIEDCAT USING 'SAPDCTOPERM'        'Dscto. Perm.'.
  PERFORM CREATE_FIEDCAT USING 'SAPDCTOPROM'        'Dscto. Prom'.
  PERFORM CREATE_FIEDCAT USING 'SAPDCTOTEMP'        'Dscto. Temp.'.
  PERFORM CREATE_FIEDCAT USING 'SAPINGBEMHELP'      'Ing.Bem.Help'.
  PERFORM CREATE_FIEDCAT USING 'SAPINGOTROS'        'Ing. Otros'.
  PERFORM CREATE_FIEDCAT USING 'SAPRANGOETA'        'Rango Etareo'.
  PERFORM CREATE_FIEDCAT USING 'SAPSECTORAFI'       'Sector Afi'.
  PERFORM CREATE_FIEDCAT USING 'SAPFECHAFACT'       'Fecha Factura'.
  PERFORM CREATE_FIEDCAT USING 'SAPFECHACORE'       'Fecha Core'.
  PERFORM CREATE_FIEDCAT USING 'SAPFECHAVENC'       'Fecha Vencimiento'.

ENDFORM.                    " INIT_FIELDCAT

*&---------------------------------------------------------------------*
*&      Form  CREATE_FIEDCAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FIELDNAME  text
*----------------------------------------------------------------------*
FORM CREATE_FIEDCAT USING FIELDNAME TEXT.

  GT_FIELDCAT-FIELDNAME   = FIELDNAME .
  GT_FIELDCAT-REF_TABNAME = 'FACTSAPTRASPASO'.
  GT_FIELDCAT-SELTEXT_L   = TEXT.
  GT_FIELDCAT-SELTEXT_M   = TEXT.
  GT_FIELDCAT-SELTEXT_S   = TEXT.
  APPEND GT_FIELDCAT.
  CLEAR GT_FIELDCAT.

ENDFORM.                    " CREATE_FIEDCAT
*&---------------------------------------------------------------------*
*&      Form  INIT_LAYOUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM INIT_LAYOUT .

  GS_LAYOUT-ZEBRA = 'X'.
  GS_LAYOUT-F2CODE = '&ETA'.
  GS_LAYOUT-DETAIL_POPUP = 'X'.

ENDFORM.                    " INIT_LAYOUT
*&---------------------------------------------------------------------*
*&      Form  LISTADO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM LISTADO .

  SORT TI_PEDIDO BY SAPNUMFACTURA POS_FAC ASCENDING.
  CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
    EXPORTING
      I_CALLBACK_PROGRAM = SY-REPID
      IS_LAYOUT          = GS_LAYOUT
      IT_FIELDCAT        = GT_FIELDCAT[]
    TABLES
      T_OUTTAB           = TI_PEDIDO
    EXCEPTIONS
      PROGRAM_ERROR      = 1
      OTHERS             = 2.

ENDFORM.                    " LISTADO
*&---------------------------------------------------------------------*
*&      Form  DISCONNECT_DB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DISCONNECT_DB .

  EXEC SQL.
    DISCONNECT :PCONNAME
  ENDEXEC.

ENDFORM.                    " DISCONNECT_DB
*&---------------------------------------------------------------------*
*&      Form  UPDATE_DATA_SAP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM UPDATE_DATA_SAP.
* Inicio de documentación de proceso de log
  CLEAR: DBCNT_NDOC, DBCNT_REG, POS.
  SORT TI_PEDIDO BY SAPNUMFACTURA.
  LOOP AT TI_PEDIDO INTO LS_PEDIDO WHERE EST_PROC NE 'OK'.
    IF LS_PEDIDO-SAPTOTALFACT > 0.
      ON CHANGE OF LS_PEDIDO-SAPNUMFACTURA.
        CLEAR POS.
        ADD 1 TO DBCNT_NDOC.
        SELECT SINGLE * FROM ZCABPEDEXT WHERE ZNUM_DOC_CORE EQ LS_PEDIDO-SAPNUMFACTURA.
        IF SY-SUBRC EQ 0.
          LS_PEDIDO-EST_PROC = 'ER'.
          LS_PEDIDO-DES_EST  = 'Doc. ya Existe'.
        ELSE.
        IF LS_PEDIDO-SAPNUMFACTURA = 0.
          SY-SUBRC           = 4.
          LS_PEDIDO-EST_PROC = 'ER'.
          LS_PEDIDO-DES_EST  = 'Sin Num.Doc.Core'.
        ELSE.
          CHECK LS_PEDIDO-SAPTOTALFACT > 0.
          REPLACE ',' WITH '.' INTO LS_PEDIDO-SAPTIPOCAMBIO.
          MOVE  LS_PEDIDO-SAPCLASEVENTA         TO ZCABPEDEXT-ZBLART.
          MOVE  LS_PEDIDO-SAPINDELEC            TO ZCABPEDEXT-ZELECTRONICO.
          MOVE  LS_PEDIDO-SAPORGVTA             TO ZCABPEDEXT-VKORG.
          MOVE  LS_PEDIDO-SAPCANALDIS           TO ZCABPEDEXT-VTWEG.
          MOVE  LS_PEDIDO-SAPSECTORFACT         TO ZCABPEDEXT-SPART.
          MOVE  LS_PEDIDO-SAPOFIVTA             TO ZCABPEDEXT-VKBUR.
          MOVE  LS_PEDIDO-SAPGRUPOVEND          TO ZCABPEDEXT-VKGRP.
          MOVE  LS_PEDIDO-SAPRUTFACTURA         TO ZCABPEDEXT-ZRUT_CLI_FACT.
          MOVE  LS_PEDIDO-SAPNOMBREFACTURA      TO ZCABPEDEXT-ZNOM_CLI_FACT.
          MOVE  LS_PEDIDO-SAPRUTPAGADOR         TO ZCABPEDEXT-ZRUT_CLI_PAGADOR.
          MOVE  LS_PEDIDO-SAPGIROCLI            TO ZCABPEDEXT-ZGIRO_CLI_FACT.
          MOVE  LS_PEDIDO-SAPDIRCLI             TO ZCABPEDEXT-ZDIR_FACT.
          MOVE  LS_PEDIDO-SAPCOMUNA             TO ZCABPEDEXT-ZCOMUNA_FACT.
          MOVE  LS_PEDIDO-SAPCIUDAD             TO ZCABPEDEXT-ZCIUDAD_FACT.
          MOVE  LS_PEDIDO-SAPNUMFOLIOCTR        TO ZCABPEDEXT-VERTN.
          MOVE  LS_PEDIDO-SAPFECHACTR           TO ZCABPEDEXT-ZFEC_CONT.
          MOVE  LS_PEDIDO-SAPNUMEVENTO          TO ZCABPEDEXT-ZUONR.
          MOVE  LS_PEDIDO-SAPCONPAGO            TO ZCABPEDEXT-ZTERM.
          MOVE  LS_PEDIDO-SAPNUMFACTURA         TO ZCABPEDEXT-ZNUM_DOC_CORE.
          MOVE  LS_PEDIDO-SAPINDTRASPASO        TO ZCABPEDEXT-ZIND_TRASPASO.
          MOVE  LS_PEDIDO-SAPTARJCUENTA         TO ZCABPEDEXT-XREF3.
          MOVE  LS_PEDIDO-SAPCODBANCO           TO ZCABPEDEXT-HBKID.
          MOVE  LS_PEDIDO-SAPESTCTR             TO ZCABPEDEXT-VERTT.
          MOVE  LS_PEDIDO-SAPTIPOTARJ           TO ZCABPEDEXT-XREF1.
          MOVE  LS_PEDIDO-SAPMONEDA             TO ZCABPEDEXT-WAERS.
          MOVE  LS_PEDIDO-SAPPLANCTR            TO ZCABPEDEXT-ZPLAN.
          MOVE  LS_PEDIDO-SAPVIAPAGO            TO ZCABPEDEXT-ZLSCH.
          MOVE  LS_PEDIDO-SAPTIPOCAMBIO         TO ZCABPEDEXT-ZTIP_CAMBIO_REF.
          MOVE  LS_PEDIDO-SAPCENTRO             TO ZCABPEDEXT-ZCENTRO.
          MOVE  LS_PEDIDO-SAPNUMMANDATO         TO ZCABPEDEXT-ZNUM_MANDATO.
          MOVE  LS_PEDIDO-SAPNUMENDOSO          TO ZCABPEDEXT-ZNUM_ENDOSO.
          MOVE  LS_PEDIDO-SAPAFEEXE             TO ZCABPEDEXT-ZIND_AFECTO.
          MOVE  LS_PEDIDO-SAPTIPOCOPAGO         TO ZCABPEDEXT-ZKVGR3.
          MOVE  LS_PEDIDO-SAPPERIODICIDAD       TO ZCABPEDEXT-ZKVGR4.
          MOVE  LS_PEDIDO-SAPCODPLAN            TO ZCABPEDEXT-ZCOPAGO_PLAN.
          MOVE  LS_PEDIDO-SAPTOTALFACT          TO ZCABPEDEXT-ZMONTO_TOTAL.
          MOVE  LS_PEDIDO-SAPINDBLOQUEO         TO ZCABPEDEXT-ZBLOQ_PAGO.
          MOVE  SY-DATLO                        TO ZCABPEDEXT-FEC_CAR.
          MOVE  SY-TIMLO                        TO ZCABPEDEXT-HOR_CAR.
          MOVE  LS_PEDIDO-SAPFECHACORE          TO ZCABPEDEXT-FECDOCCORE.
          MOVE  LS_PEDIDO-SAPFECHAFACT          TO ZCABPEDEXT-FECFACCON.
          MOVE  LS_PEDIDO-SAPFECHAVENC          TO ZCABPEDEXT-FECVENTES.
          WRITE LS_PEDIDO-SAPGLOSADOC+000(250)  TO ZCABPEDEXT-GLOSA_P1.
          WRITE LS_PEDIDO-SAPGLOSADOC+250(250)  TO ZCABPEDEXT-GLOSA_P2.
          WRITE LS_PEDIDO-SAPGLOSADOC+500(250)  TO ZCABPEDEXT-GLOSA_P3.
          WRITE LS_PEDIDO-SAPGLOSADOC+750(250)  TO ZCABPEDEXT-GLOSA_P4.
          MOVE  SY-MANDT                        TO ZCABPEDEXT-MANDT.
          MOVE  SPACE                           TO ZCABPEDEXT-PEDIDO.
          MOVE  SPACE                           TO ZCABPEDEXT-FACTURA.
          MOVE  SPACE                           TO ZCABPEDEXT-ERROR.
          MOVE  SPACE                           TO ZCABPEDEXT-ERROR_E.
          MOVE  SPACE                           TO ZCABPEDEXT-LOG_ERROR.
          UPDATE ZCABPEDEXT.
          IF SY-SUBRC NE 0.
            INSERT ZCABPEDEXT.
            IF SY-SUBRC = 0.
              LS_PEDIDO-EST_PROC = 'OK'.
              LS_PEDIDO-DES_EST  = 'Doc.Transferido'.
            ELSE.
              LS_PEDIDO-EST_PROC = 'EC'.
              LS_PEDIDO-DES_EST  = 'Doc.No Cargado'.
            ENDIF.
          ELSE.
            LS_PEDIDO-EST_PROC = 'OK'.
            LS_PEDIDO-DES_EST  = 'Doc.Transferido'.
          ENDIF.
          ENdif.
        ENDIF.
      ENDON.
      IF LS_PEDIDO-EST_PROC = 'OK' OR LS_PEDIDO-EST_PROC = SPACE.
        SELECT SINGLE * FROM ZCABPEDEXT WHERE ZNUM_DOC_CORE EQ LS_PEDIDO-SAPNUMFACTURA.
        IF SY-SUBRC EQ 0.
          ADD 1 TO DBCNT_REG.
          ADD 1 TO POS.
          MOVE LS_PEDIDO-SAPNUMFACTURA      TO ZDETPEDEXT-ZNUM_DOC_CORE.
          MOVE POS                          TO ZDETPEDEXT-ZPOS_EXT.
          MOVE POS                          TO LS_PEDIDO-POS_FAC.
          REPLACE ',' WITH '.' INTO LS_PEDIDO-SAPMONTOUF.
          MOVE LS_PEDIDO-SAPMONTOUF         TO ZDETPEDEXT-ZMONTO_UF.

          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              INPUT  = LS_PEDIDO-SAPRUTBENEFICIARIO
            IMPORTING
              OUTPUT = ZDETPEDEXT-ZRUT_BENEFICIARI.

          MOVE LS_PEDIDO-SAPCODPRODUCTO     TO ZDETPEDEXT-MATNR.
          MOVE LS_PEDIDO-SAPCTDAD           TO ZDETPEDEXT-MENGE.
          MOVE LS_PEDIDO-SAPVALLISTA        TO ZDETPEDEXT-ZPREC.
          MOVE LS_PEDIDO-SAPVALADIC         TO ZDETPEDEXT-ZREC_AD.
          MOVE LS_PEDIDO-SAPDCTOCONV        TO ZDETPEDEXT-ZDCTO_CONV.
          MOVE LS_PEDIDO-SAPDCTOPERM        TO ZDETPEDEXT-ZDCTO_ESP.
          MOVE LS_PEDIDO-SAPDCTOPROM        TO ZDETPEDEXT-ZDCTO_PROM.
          MOVE LS_PEDIDO-SAPDCTOTEMP        TO ZDETPEDEXT-ZDCTO_ESP_T.
          MOVE LS_PEDIDO-SAPINGBEMHELP      TO ZDETPEDEXT-ZING_B_H.
          MOVE LS_PEDIDO-SAPINGOTROS        TO ZDETPEDEXT-ZOTRO_ING.
          MOVE LS_PEDIDO-SAPRANGOETA        TO ZDETPEDEXT-ZRANG_ETAREO.
          MOVE LS_PEDIDO-SAPSECTORAFI       TO ZDETPEDEXT-ZSECTOR.
          UPDATE ZDETPEDEXT.
          IF SY-SUBRC NE 0.
            INSERT ZDETPEDEXT.
            IF SY-SUBRC = 0.
              LS_PEDIDO-EST_PROC = 'OK'.
              LS_PEDIDO-DES_EST  = 'Doc.Transferido'.
              PERFORM UPDATE_ORACLE.
            ELSE.
              LS_PEDIDO-EST_PROC = 'ED'.
              LS_PEDIDO-DES_EST  = 'Doc.No Cargado'.
            ENDIF.
          ELSE.
            LS_PEDIDO-EST_PROC = 'OK'.
            LS_PEDIDO-DES_EST  = 'Doc.Transferido'.
            PERFORM UPDATE_ORACLE.
          ENDIF.
        ENDIF.
      ELSEIF LS_PEDIDO-EST_PROC = SPACE.
        SELECT SINGLE * FROM ZCABPEDEXT WHERE ZNUM_DOC_CORE EQ LS_PEDIDO-SAPNUMFACTURA.
        IF SY-SUBRC EQ 0.
          LS_PEDIDO-EST_PROC = 'ER'.
          LS_PEDIDO-DES_EST  = 'Doc. ya Existe'.
        ENDIF.
      ENDIF.
    ELSE.
      LS_PEDIDO-EST_PROC = 'M0'.
      LS_PEDIDO-DES_EST  = 'Doc.Mnt.Cero'.
    ENDIF.
    MODIFY TI_PEDIDO FROM LS_PEDIDO.

    CLEAR LS_PEDIDO.
  ENDLOOP.
  COMMIT WORK.

  IF SY-SUBRC = 0.
*
    CLEAR DBCNT_REG.
    DESCRIBE TABLE TI_PEDIDO LINES DBCNT_REG.
    TEXTO1 = TEXT-002.
    CLEAR STR_DBCNT.
    STR_DBCNT = DBCNT_REG.
    REPLACE '<NR>' INTO TEXTO1 WITH STR_DBCNT.
*
    TEXTO2 = TEXT-006.
    CLEAR STR_DBCNT.
    STR_DBCNT = DBCNT_NDOC.
    REPLACE '<ND>' INTO TEXTO2 WITH STR_DBCNT.
*
    MESSAGE I000(0K) WITH TEXTO1 TEXTO2.
  ENDIF.

ENDFORM.                    " UPDATE_DATA_SAP
*&---------------------------------------------------------------------*
*&      Form  SHOW_DIR_LOC_FILE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_FILE  text
*----------------------------------------------------------------------*
FORM SHOW_DIR_LOC_FILE USING P_FILE.

  CALL FUNCTION 'WS_FILENAME_GET'
    EXPORTING
      DEF_FILENAME     = '*.csv'
      DEF_PATH         = 'C:\'
      MASK             = ',*.*'
      MODE             = 'O'
      TITLE            = TEXT-C12
    IMPORTING
      FILENAME         = P_FILE
    EXCEPTIONS
      INV_WINSYS       = 01
      NO_BATCH         = 02
      SELECTION_CANCEL = 03
      SELECTION_ERROR  = 04.

ENDFORM.                    " SHOW_DIR_LOC_FILE

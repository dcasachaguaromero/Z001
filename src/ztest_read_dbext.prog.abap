*&---------------------------------------------------------------------*
*& Report  ZTEST_READ_DBEXT
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT ZTEST_READ_DBEXT LINE-SIZE 1023 NO STANDARD PAGE HEADING.
TYPE-POOLS SLIS.
DATA IS_PRINT      TYPE SLIS_PRINT_ALV.
DATA IS_U_LAYOUT   TYPE SLIS_LAYOUT_ALV.
DATA IT_U_FIELDCAT TYPE SLIS_T_FIELDCAT_ALV.
DATA IT_U_SORT     TYPE SLIS_T_SORTINFO_ALV.
DATA GT_EVENTS     TYPE SLIS_T_EVENT.
DATA WA_EVENT      TYPE SLIS_ALV_EVENT.
DATA GT_EVENT_EXIT TYPE SLIS_T_EVENT_EXIT.
DATA LV_CURRENT_CONNECTION TYPE DBCON-CON_NAME.
DATA DBTYPE                TYPE DBCON_DBMS.
DATA EXC_REF               TYPE REF TO CX_SY_NATIVE_SQL_ERROR.
DATA L_DUPLICATE_COUNTER   TYPE I.
DATA ERROR_TEXT            TYPE STRING.
CONSTANTS TRUE                   TYPE C VALUE 'X'.
CONSTANTS C_FORMNAME_TOP_OF_PAGE TYPE SLIS_FORMNAME VALUE 'TOP_OF_PAGE'.
CONSTANTS C_FORMNAME_TOP_OF_LIST TYPE SLIS_FORMNAME VALUE 'TOP_OF_LIST'.
CONSTANTS C_FORMNAME_END_OF_LIST TYPE SLIS_FORMNAME VALUE 'END_OF_LIST'.

PARAMETERS PCONNAME TYPE DBCON-CON_NAME DEFAULT 'SAPCSC'.
*PARAMETERS NAMETAB  TYPE TABNAME16 DEFAULT 'SAPCTACTE'.
PARAMETERS P_BUKRS  TYPE BUKRS.

*DATA TMP_BSID TYPE STANDARD TABLE OF ZSAPCTACTEBSID WITH HEADER LINE.
DATA BEGIN OF TMP_BSID OCCURS 0.
        INCLUDE STRUCTURE ZSAPCTACTEBSID.
DATA AUGDT_TMP(10).
DATA BUDAT_TMP(10).
DATA BLDAT_TMP(10).
DATA CPUDT_TMP(10).
DATA ZFBDT_TMP(10).
DATA PRODPER_TMP(10).
DATA ZFEC_CONT_TMP(10).
DATA FDTAG_TMP(10).
DATA END OF TMP_BSID.

DATA BEGIN OF TMP_BSAD OCCURS 0.
        INCLUDE STRUCTURE ZSAPCTACTEBSID.
DATA AUGDT_TMP(10).
DATA BUDAT_TMP(10).
DATA BLDAT_TMP(10).
DATA CPUDT_TMP(10).
DATA ZFBDT_TMP(10).
DATA PRODPER_TMP(10).
DATA ZFEC_CONT_TMP(10).
DATA FDTAG_TMP(10).
DATA END OF TMP_BSAD.

DATA LS_BSID LIKE LINE OF TMP_BSID.
DATA LS_BSAD LIKE LINE OF TMP_BSAD.

START-OF-SELECTION.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE DBMS FROM DBCON INTO DBTYPE WHERE CON_NAME EQ PCONNAME.
*
* NEW CODE
  SELECT DBMS
  UP TO 1 ROWS  FROM DBCON INTO DBTYPE WHERE CON_NAME EQ PCONNAME ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
  IF DBTYPE = 'ORA'.
    TRY.
      EXEC SQL.
        CONNECT TO :PCONNAME
      ENDEXEC.
      IF SY-SUBRC <> 0.
        RAISE EXCEPTION TYPE CX_SY_NATIVE_SQL_ERROR.
      ENDIF.
*
      EXEC SQL.
        SET CONNECTION :PCONNAME
      ENDEXEC.
      PERFORM LOAD_TI_BSID TABLES TMP_BSID.
      PERFORM LOAD_TI_BSAD TABLES TMP_BSAD.
      EXEC SQL.
        DISCONNECT :PCONNAME
      ENDEXEC.
    ENDTRY.

  ENDIF.

  WRITE:/ 'Datos BSID'.
  LOOP AT TMP_BSID INTO LS_BSID.
    WRITE:/ SY-VLINE, LS_BSID-MANDT,
            SY-VLINE, LS_BSID-BUKRS,
            SY-VLINE, LS_BSID-KUNNR,
            SY-VLINE, LS_BSID-STCD1,
            SY-VLINE, LS_BSID-UMSKS,
            SY-VLINE, LS_BSID-UMSKZ,
            SY-VLINE, LS_BSID-AUGDT_TMP,
            SY-VLINE, LS_BSID-AUGBL,
            SY-VLINE, LS_BSID-ZUONR,
            SY-VLINE, LS_BSID-GJAHR,
            SY-VLINE, LS_BSID-BELNR,
            SY-VLINE, LS_BSID-BUDAT_TMP,
            SY-VLINE, LS_BSID-BLDAT_TMP,
            SY-VLINE, LS_BSID-CPUDT_TMP,
            SY-VLINE, LS_BSID-WAERS,
            SY-VLINE, LS_BSID-XBLNR,
            SY-VLINE, LS_BSID-BLART,
            SY-VLINE, LS_BSID-MONAT,
            SY-VLINE, LS_BSID-BSCHL,
            SY-VLINE, LS_BSID-ZUMSK,
                            SY-VLINE, LS_BSID-SHKZG,
                            SY-VLINE, LS_BSID-MWSKZ,
                            SY-VLINE, LS_BSID-DMBTR,
                            SY-VLINE, LS_BSID-WRBTR,
                            SY-VLINE, LS_BSID-MWSTS,
                            SY-VLINE, LS_BSID-WMWST,
                            SY-VLINE, LS_BSID-SGTXT,
                            SY-VLINE, LS_BSID-SAKNR,
                            SY-VLINE, LS_BSID-HKONT,
                            SY-VLINE, LS_BSID-ZFBDT,
                            SY-VLINE, LS_BSID-ZTERM,
                            SY-VLINE, LS_BSID-ZBD1T,
                            SY-VLINE, LS_BSID-ZBD2T,
                            SY-VLINE, LS_BSID-ZBD3T,
                            SY-VLINE, LS_BSID-ZBD1P,
                            SY-VLINE, LS_BSID-ZBD2P,
                            SY-VLINE, LS_BSID-SKFBT,
                            SY-VLINE, LS_BSID-SKNTO,
                            SY-VLINE, LS_BSID-WSKTO,
                            SY-VLINE, LS_BSID-ZLSCH,
                            SY-VLINE, LS_BSID-ZLSPR,
                            SY-VLINE, LS_BSID-HBKID,
                            SY-VLINE, LS_BSID-REBZG,
                            SY-VLINE, LS_BSID-REBZJ,
                            SY-VLINE, LS_BSID-BSTAT,
                            SY-VLINE, LS_BSID-VBELN,
                            SY-VLINE, LS_BSID-VERTT,
                            SY-VLINE, LS_BSID-VERTN,
                            SY-VLINE, LS_BSID-XREF1,
                            SY-VLINE, LS_BSID-XREF2,
                            SY-VLINE, LS_BSID-KOSTL,
                            SY-VLINE, LS_BSID-KKBER,
                            SY-VLINE, LS_BSID-PRCTR,
                            SY-VLINE, LS_BSID-XREF3,
                            SY-VLINE, LS_BSID-KIDNO,
                            SY-VLINE, LS_BSID-PRODPER_TMP,
                            SY-VLINE, LS_BSID-ZFEC_CONT_TMP,
                            SY-VLINE, LS_BSID-ZRUT_BENEF,
                            SY-VLINE, LS_BSID-ZSECTOR,
                            SY-VLINE, LS_BSID-ZR_ETAREO,
                            SY-VLINE, LS_BSID-KNUMV,
                            SY-VLINE, LS_BSID-ZRUT_CLI_PAGADOR,
                            SY-VLINE, LS_BSID-ZRUT_CLI_FACT,
                            SY-VLINE, LS_BSID-ZNOM_CLI_FACT,
                            SY-VLINE, LS_BSID-ZGIRO_CLI_FACT,
                            SY-VLINE, LS_BSID-ZDIR_FACT,
                            SY-VLINE, LS_BSID-ZCOMUNA_FACT,
                            SY-VLINE, LS_BSID-ZCIUDAD_FACT,
                            SY-VLINE, LS_BSID-ZTIP_CAMBIO_REF,
                            SY-VLINE, LS_BSID-ZBLART,
                            SY-VLINE, LS_BSID-ZELECTRONICO,
                            SY-VLINE, LS_BSID-ZVKORG,
                            SY-VLINE, LS_BSID-ZVTWEG,
                            SY-VLINE, LS_BSID-ZKVGR3,
                            SY-VLINE, LS_BSID-ZCENTRO,
                            SY-VLINE, LS_BSID-ZNUM_MANDATO,
                            SY-VLINE, LS_BSID-ZNUM_ENDOSO,
                            SY-VLINE, LS_BSID-ZKVGR4,
                            SY-VLINE, LS_BSID-ZMONTO_TOTAL,
                            SY-VLINE, LS_BSID-ZBLOQ_PAGO,
                            SY-VLINE, LS_BSID-ZMONTO_UF,
                            SY-VLINE, LS_BSID-ZPLAN,
                            SY-VLINE, LS_BSID-ZCOPAGO_PLAN,
                            SY-VLINE, LS_BSID-ZNUM_DOC_CORE,
                            SY-VLINE, LS_BSID-ZIND_TRASPASO,
                            SY-VLINE, LS_BSID-ZIND_AFECTO,
                            SY-VLINE.
  ENDLOOP.

  WRITE:/ 'Datos BSAD'.
  LOOP AT TMP_BSAD INTO LS_BSAD.
    WRITE:/ SY-VLINE, LS_BSAD-MANDT,
            SY-VLINE, LS_BSAD-BUKRS,
            SY-VLINE, LS_BSAD-KUNNR,
            SY-VLINE, LS_BSAD-STCD1,
                            SY-VLINE, LS_BSAD-UMSKS,
                            SY-VLINE, LS_BSAD-UMSKZ,
                            SY-VLINE, LS_BSAD-AUGDT_TMP,
                            SY-VLINE, LS_BSAD-AUGBL,
                            SY-VLINE, LS_BSAD-ZUONR,
                            SY-VLINE, LS_BSAD-GJAHR,
                            SY-VLINE, LS_BSAD-BELNR,
                            SY-VLINE, LS_BSAD-BUDAT_TMP,
                            SY-VLINE, LS_BSAD-BLDAT_TMP,
                            SY-VLINE, LS_BSAD-CPUDT_TMP,
                            SY-VLINE, LS_BSAD-WAERS,
                            SY-VLINE, LS_BSAD-XBLNR,
                            SY-VLINE, LS_BSAD-BLART,
                            SY-VLINE, LS_BSAD-MONAT,
                            SY-VLINE, LS_BSAD-BSCHL,
                            SY-VLINE, LS_BSAD-ZUMSK,
                            SY-VLINE, LS_BSAD-SHKZG,
                            SY-VLINE, LS_BSAD-MWSKZ,
                            SY-VLINE, LS_BSAD-DMBTR,
                            SY-VLINE, LS_BSAD-WRBTR,
                            SY-VLINE, LS_BSAD-MWSTS,
                            SY-VLINE, LS_BSAD-WMWST,
                            SY-VLINE, LS_BSAD-SGTXT,
                            SY-VLINE, LS_BSAD-SAKNR,
                            SY-VLINE, LS_BSAD-HKONT,
                            SY-VLINE, LS_BSAD-ZFBDT_TMP,
                            SY-VLINE, LS_BSAD-ZTERM,
                            SY-VLINE, LS_BSAD-ZBD1T,
                            SY-VLINE, LS_BSAD-ZBD2T,
                            SY-VLINE, LS_BSAD-ZBD3T,
                            SY-VLINE, LS_BSAD-ZBD1P,
                            SY-VLINE, LS_BSAD-ZBD2P,
                            SY-VLINE, LS_BSAD-SKFBT,
                            SY-VLINE, LS_BSAD-SKNTO,
                            SY-VLINE, LS_BSAD-WSKTO,
                            SY-VLINE, LS_BSAD-ZLSCH,
                            SY-VLINE, LS_BSAD-ZLSPR,
                            SY-VLINE, LS_BSAD-HBKID,
                            SY-VLINE, LS_BSAD-REBZG,
                            SY-VLINE, LS_BSAD-REBZJ,
                            SY-VLINE, LS_BSAD-BSTAT,
                            SY-VLINE, LS_BSAD-VBELN,
                            SY-VLINE, LS_BSAD-VERTT,
                            SY-VLINE, LS_BSAD-VERTN,
                            SY-VLINE, LS_BSAD-XREF1,
                            SY-VLINE, LS_BSAD-XREF2,
                            SY-VLINE, LS_BSAD-KOSTL,
                            SY-VLINE, LS_BSAD-KKBER,
                            SY-VLINE, LS_BSAD-PRCTR,
                            SY-VLINE, LS_BSAD-XREF3,
                            SY-VLINE, LS_BSAD-KIDNO,
                            SY-VLINE, LS_BSAD-PRODPER_TMP,
                            SY-VLINE, LS_BSAD-ZFEC_CONT_TMP,
                            SY-VLINE, LS_BSAD-ZRUT_BENEF,
                            SY-VLINE, LS_BSAD-ZSECTOR,
                            SY-VLINE, LS_BSAD-ZR_ETAREO,
                            SY-VLINE, LS_BSAD-KNUMV,
                            SY-VLINE, LS_BSAD-ZRUT_CLI_PAGADOR,
                            SY-VLINE, LS_BSAD-ZRUT_CLI_FACT,
                            SY-VLINE, LS_BSAD-ZNOM_CLI_FACT,
                            SY-VLINE, LS_BSAD-ZGIRO_CLI_FACT,
                            SY-VLINE, LS_BSAD-ZDIR_FACT,
                            SY-VLINE, LS_BSAD-ZCOMUNA_FACT,
                            SY-VLINE, LS_BSAD-ZCIUDAD_FACT,
                            SY-VLINE, LS_BSAD-ZTIP_CAMBIO_REF,
                            SY-VLINE, LS_BSAD-ZBLART,
                            SY-VLINE, LS_BSAD-ZELECTRONICO,
                            SY-VLINE, LS_BSAD-ZVKORG,
                            SY-VLINE, LS_BSAD-ZVTWEG,
                            SY-VLINE, LS_BSAD-ZKVGR3,
                            SY-VLINE, LS_BSAD-ZCENTRO,
                            SY-VLINE, LS_BSAD-ZNUM_MANDATO,
                            SY-VLINE, LS_BSAD-ZNUM_ENDOSO,
                            SY-VLINE, LS_BSAD-ZKVGR4,
                            SY-VLINE, LS_BSAD-ZMONTO_TOTAL,
                            SY-VLINE, LS_BSAD-ZBLOQ_PAGO,
                            SY-VLINE, LS_BSAD-ZMONTO_UF,
                            SY-VLINE, LS_BSAD-ZPLAN,
                            SY-VLINE, LS_BSAD-ZCOPAGO_PLAN,
                            SY-VLINE, LS_BSAD-ZNUM_DOC_CORE,
                            SY-VLINE, LS_BSAD-ZIND_TRASPASO,
                            SY-VLINE, LS_BSAD-ZIND_AFECTO,
                            SY-VLINE.
  ENDLOOP.
*&---------------------------------------------------------------------*
*&      Form  LOAD_TI_BSID
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TMP_BSID  text
*----------------------------------------------------------------------*
FORM LOAD_TI_BSID TABLES TMP_BSID STRUCTURE TMP_BSID.
*
  DATA TMP_BUDAT(10).
*
  EXEC SQL.
    OPEN :PCONNAME FOR SELECT sapmandte,
                        sapsocied,
                        sapnumcli1,
                        sapnumidfi1,
                        sapclasopmay,
                        sapindopmay,
                        sapfeccompens,
                        sapnumdoccompens,
                        sapnumasigna,
                        sapejercicio,
                        sapnumdoccont,
                        sapfeccontabdoc,
                        sapfecdonendoc,
                        sapdiaregdoccont,
                        sapclavemoneda,
                        sapnumdocrefer,
                        sapclasedoc,
                        sapmescontable,
                        sapclavecontab,
                        sapindcmedest,
                        sapinddebhab,
                        sapindiva,
                        sapimportemonloc,
                        sapimportemondoc,
                        sapimporteivaloc,
                        sapimporteivadoc,
                        saptxtposicion,
                        sapnumctamayor,
                        sapctamaycontpri,
                        sapfeccalcvenc,
                        sapcondicpago,
                        sapdiasdscpag1,
                        sapdiasdscpag2,
                        sapplazcondpag,
                        sapporcdscpag1,
                        sapporcdscpag2,
                        sapimpdermondoc,
                        sapimpdermonloc,
                        sapimpdscmondoc,
                        sapviapago,
                        sapbloqpago,
                        sapbcopropio,
                        sapnumfactop,
                        sapejfactabo,
                        sapstatusdoc,
                        sapfactura,
                        sapclasectr,
                        sapnumctr,
                        sapclavintcom1,
                        sapclavintcom2,
                        sapcencosto,
                        saparctrlcred,
                        sapcenbenef,
                        sapclrefposdoc,
                        saprefpago,
                        sapfecmesprod,
                        sapfecctr,
                        saprutbenef,
                        sapsector,
                        saprangoeta,
                        sapnumconddoc,
                        saprutclipagador,
                        saprutclifact,
                        sapnombreclifact,
                        sapgiroclifact,
                        sapdircallefact,
                        sapdircomunafact,
                        sapdirciudadfact,
                        saptipocambio,
                        sapclasedoc2,
                        sapclasedocelectr,
                        saporgventas,
                        sapcanaldistr,
                        saptipocopago,
                        sapcentro,
                        sapnummandato,
                        sapnumendoso,
                        sapperiodicid,
                        sapimpototmonloc,
                        sapbloqpago2,
                        sapmontouf,
                        sapplan,
                        sapcopagoplan,
                        sapnumdoccore,
                        sapindtraspaso,
                        sapindafecto
       FROM SAPCTACTE where sapsocied = :P_BUKRS
  ENDEXEC.
*
  CLEAR TMP_BUDAT.
  DO.
    EXEC SQL.
      FETCH NEXT :PCONNAME INTO :LS_BSID-MANDT,
                                :LS_BSID-BUKRS,
                                :LS_BSID-KUNNR,
                                :LS_BSID-STCD1,
                                :LS_BSID-UMSKS,
                                :LS_BSID-UMSKZ,
                        :LS_BSID-AUGDT_TMP,
                        :LS_BSID-AUGBL,
                        :LS_BSID-ZUONR,
                        :LS_BSID-GJAHR,
                        :LS_BSID-BELNR,
                        :LS_BSID-BUDAT_TMP,
                        :LS_BSID-BLDAT_TMP,
                        :LS_BSID-CPUDT_TMP,
                        :LS_BSID-WAERS,
                        :LS_BSID-XBLNR,
                        :LS_BSID-BLART,
                        :LS_BSID-MONAT,
                        :LS_BSID-BSCHL,
                        :LS_BSID-ZUMSK,
                        :LS_BSID-SHKZG,
                        :LS_BSID-MWSKZ,
                        :LS_BSID-DMBTR,
                        :LS_BSID-WRBTR,
                        :LS_BSID-MWSTS,
                        :LS_BSID-WMWST,
                        :LS_BSID-SGTXT,
                        :LS_BSID-SAKNR,
                        :LS_BSID-HKONT,
                        :LS_BSID-ZFBDT_TMP,
                        :LS_BSID-ZTERM,
                        :LS_BSID-ZBD1T,
                        :LS_BSID-ZBD2T,
                        :LS_BSID-ZBD3T,
                        :LS_BSID-ZBD1P,
                        :LS_BSID-ZBD2P,
                        :LS_BSID-SKFBT,
                        :LS_BSID-SKNTO,
                        :LS_BSID-WSKTO,
                        :LS_BSID-ZLSCH,
                        :LS_BSID-ZLSPR,
                        :LS_BSID-HBKID,
                        :LS_BSID-REBZG,
                        :LS_BSID-REBZJ,
                        :LS_BSID-BSTAT,
                        :LS_BSID-VBELN,
                        :LS_BSID-VERTT,
                        :LS_BSID-VERTN,
                        :LS_BSID-XREF1,
                        :LS_BSID-XREF2,
                        :LS_BSID-KOSTL,
                        :LS_BSID-KKBER,
                        :LS_BSID-PRCTR,
                        :LS_BSID-XREF3,
                        :LS_BSID-KIDNO,
                        :LS_BSID-PRODPER_TMP,
                        :LS_BSID-ZFEC_CONT_TMP,
                        :LS_BSID-ZRUT_BENEF,
                        :LS_BSID-ZSECTOR,
                        :LS_BSID-ZR_ETAREO,
                        :LS_BSID-KNUMV,
                        :LS_BSID-ZRUT_CLI_PAGADOR,
                        :LS_BSID-ZRUT_CLI_FACT,
                        :LS_BSID-ZNOM_CLI_FACT,
                        :LS_BSID-ZGIRO_CLI_FACT,
                        :LS_BSID-ZDIR_FACT,
                        :LS_BSID-ZCOMUNA_FACT,
                        :LS_BSID-ZCIUDAD_FACT,
                        :LS_BSID-ZTIP_CAMBIO_REF,
                        :LS_BSID-ZBLART,
                        :LS_BSID-ZELECTRONICO,
                        :LS_BSID-ZVKORG,
                        :LS_BSID-ZVTWEG,
                        :LS_BSID-ZKVGR3,
                        :LS_BSID-ZCENTRO,
                        :LS_BSID-ZNUM_MANDATO,
                        :LS_BSID-ZNUM_ENDOSO,
                        :LS_BSID-ZKVGR4,
                        :LS_BSID-ZMONTO_TOTAL,
                        :LS_BSID-ZBLOQ_PAGO,
                        :LS_BSID-ZMONTO_UF,
                        :LS_BSID-ZPLAN,
                        :LS_BSID-ZCOPAGO_PLAN,
                        :LS_BSID-ZNUM_DOC_CORE,
                        :LS_BSID-ZIND_TRASPASO,
                        :LS_BSID-ZIND_AFECTO
    ENDEXEC.
    IF SY-SUBRC <> 0.
      EXIT.
    ELSE.
      APPEND LS_BSID TO TMP_BSID.
    ENDIF.
  ENDDO.
  EXEC SQL.
    CLOSE :PCONNAME
  ENDEXEC.

ENDFORM.                    " LOAD_TI_BSID
*&---------------------------------------------------------------------*
*&      Form  LOAD_TI_BSAD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TMP_BSAD  text
*----------------------------------------------------------------------*
FORM LOAD_TI_BSAD TABLES TMP_BSAD STRUCTURE TMP_BSAD.

  EXEC SQL.
    OPEN :PCONNAME FOR SELECT sapmandte, sapsocied,
                              sapnumcli1, sapnumidfi1,
                              sapclasopmay, sapindopmay,
                              sapfeccompens,
                              sapnumdoccompens,
                        sapnumasigna,
                        sapejercicio,
                        sapnumdoccont,
                        sapfeccontabdoc,
                        sapfecdonendoc,
                        sapdiaregdoccont,
                        sapclavemoneda,
                        sapnumdocrefer,
                        sapclasedoc,
                        sapmescontable,
                        sapclavecontab,
                        sapindcmedest,
                        sapinddebhab,
                        sapindiva,
                        sapimportemonloc,
                        sapimportemondoc,
                        sapimporteivaloc,
                        sapimporteivadoc,
                        saptxtposicion,
                        sapnumctamayor,
                        sapctamaycontpri,
                        sapfeccalcvenc,
                        sapcondicpago,
                        sapdiasdscpag1,
                        sapdiasdscpag2,
                        sapplazcondpag,
                        sapporcdscpag1,
                        sapporcdscpag2,
                        sapimpdermondoc,
                        sapimpdermonloc,
                        sapimpdscmondoc,
                        sapviapago,
                        sapbloqpago,
                        sapbcopropio,
                        sapnumfactop,
                        sapejfactabo,
                        sapstatusdoc,
                        sapfactura,
                        sapclasectr,
                        sapnumctr,
                        sapclavintcom1,
                        sapclavintcom2,
                        sapcencosto,
                        saparctrlcred,
                        sapcenbenef,
                        sapclrefposdoc,
                        saprefpago,
                        sapfecmesprod,
                        sapfecctr,
                        saprutbenef,
                        sapsector,
                        saprangoeta,
                        sapnumconddoc,
                        saprutclipagador,
                        saprutclifact,
                        sapnombreclifact,
                        sapgiroclifact,
                        sapdircallefact,
                        sapdircomunafact,
                        sapdirciudadfact,
                        saptipocambio,
                        sapclasedoc2,
                        sapclasedocelectr,
                        saporgventas,
                        sapcanaldistr,
                        saptipocopago,
                        sapcentro,
                        sapnummandato,
                        sapnumendoso,
                        sapperiodicid,
                        sapimpototmonloc,
                        sapbloqpago2,
                        sapmontouf,
                        sapplan,
                        sapcopagoplan,
                        sapnumdoccore,
                        sapindtraspaso,
                        sapindafecto
       FROM SAPCTACTEBSAD where sapsocied = :P_BUKRS
  ENDEXEC.
*
  DO.
    EXEC SQL.
      FETCH NEXT :PCONNAME INTO :LS_BSAD-MANDT, :LS_BSAD-BUKRS,
                                :LS_BSAD-KUNNR, :LS_BSAD-STCD1,
                                :LS_BSAD-UMSKS, :LS_BSAD-UMSKZ,
                        :LS_BSAD-AUGDT_TMP,
                        :LS_BSAD-AUGBL,
                        :LS_BSAD-ZUONR,
                        :LS_BSAD-GJAHR,
                        :LS_BSAD-BELNR,
                        :LS_BSAD-BUDAT_TMP,
                        :LS_BSAD-BLDAT_TMP,
                        :LS_BSAD-CPUDT_TMP,
                        :LS_BSAD-WAERS,
                        :LS_BSAD-XBLNR,
                        :LS_BSAD-BLART,
                        :LS_BSAD-MONAT,
                        :LS_BSAD-BSCHL,
                        :LS_BSAD-ZUMSK,
                        :LS_BSAD-SHKZG,
                        :LS_BSAD-MWSKZ,
                        :LS_BSAD-DMBTR,
                        :LS_BSAD-WRBTR,
                        :LS_BSAD-MWSTS,
                        :LS_BSAD-WMWST,
                        :LS_BSAD-SGTXT,
                        :LS_BSAD-SAKNR,
                        :LS_BSAD-HKONT,
                        :LS_BSAD-ZFBDT_TMP,
                        :LS_BSAD-ZTERM,
                        :LS_BSAD-ZBD1T,
                        :LS_BSAD-ZBD2T,
                        :LS_BSAD-ZBD3T,
                        :LS_BSAD-ZBD1P,
                        :LS_BSAD-ZBD2P,
                        :LS_BSAD-SKFBT,
                        :LS_BSAD-SKNTO,
                        :LS_BSAD-WSKTO,
                        :LS_BSAD-ZLSCH,
                        :LS_BSAD-ZLSPR,
                        :LS_BSAD-HBKID,
                        :LS_BSAD-REBZG,
                        :LS_BSAD-REBZJ,
                        :LS_BSAD-BSTAT,
                        :LS_BSAD-VBELN,
                        :LS_BSAD-VERTT,
                        :LS_BSAD-VERTN,
                        :LS_BSAD-XREF1,
                        :LS_BSAD-XREF2,
                        :LS_BSAD-KOSTL,
                        :LS_BSAD-KKBER,
                        :LS_BSAD-PRCTR,
                        :LS_BSAD-XREF3,
                        :LS_BSAD-KIDNO,
                        :LS_BSAD-PRODPER_TMP,
                        :LS_BSAD-ZFEC_CONT_TMP,
                        :LS_BSAD-ZRUT_BENEF,
                        :LS_BSAD-ZSECTOR,
                        :LS_BSAD-ZR_ETAREO,
                        :LS_BSAD-KNUMV,
                        :LS_BSAD-ZRUT_CLI_PAGADOR,
                        :LS_BSAD-ZRUT_CLI_FACT,
                        :LS_BSAD-ZNOM_CLI_FACT,
                        :LS_BSAD-ZGIRO_CLI_FACT,
                        :LS_BSAD-ZDIR_FACT,
                        :LS_BSAD-ZCOMUNA_FACT,
                        :LS_BSAD-ZCIUDAD_FACT,
                        :LS_BSAD-ZTIP_CAMBIO_REF,
                        :LS_BSAD-ZBLART,
                        :LS_BSAD-ZELECTRONICO,
                        :LS_BSAD-ZVKORG,
                        :LS_BSAD-ZVTWEG,
                        :LS_BSAD-ZKVGR3,
                        :LS_BSAD-ZCENTRO,
                        :LS_BSAD-ZNUM_MANDATO,
                        :LS_BSAD-ZNUM_ENDOSO,
                        :LS_BSAD-ZKVGR4,
                        :LS_BSAD-ZMONTO_TOTAL,
                        :LS_BSAD-ZBLOQ_PAGO,
                        :LS_BSAD-ZMONTO_UF,
                        :LS_BSAD-ZPLAN,
                        :LS_BSAD-ZCOPAGO_PLAN,
                        :LS_BSAD-ZNUM_DOC_CORE,
                        :LS_BSAD-ZIND_TRASPASO,
                        :LS_BSAD-ZIND_AFECTO
    ENDEXEC.
    IF SY-SUBRC <> 0.
      EXIT.
    ELSE.
      APPEND LS_BSAD TO TMP_BSAD.
    ENDIF.
  ENDDO.
  EXEC SQL.
    CLOSE :PCONNAME
  ENDEXEC.

ENDFORM.                    " LOAD_TI_BSAD

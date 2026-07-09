*&---------------------------------------------------------------------*
*&  Include           ZEICCCBM_F01
*&---------------------------------------------------------------------*
*
*&---------------------------------------------------------------------*
*&      Form  OPENCONNECTION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM openconnection.

  EXEC                                                  "#EC CI_EXECSQL
    SQL .
    connect to 'SAPCSC' as 'CON'
  ENDEXEC.

  EXEC                                                  "#EC CI_EXECSQL
    SQL.
    set connection 'CON'
  ENDEXEC.

  IF p_pa = true.
    EXEC                                                "#EC CI_EXECSQL
      SQL.
      DELETE FROM SAPCTACTE where sapsocied = :SO_BUKRS-LOW
    ENDEXEC.
  ENDIF.

  IF p_pc = true.
    IF p_feini IS INITIAL.
      EXEC                                              "#EC CI_EXECSQL
       SQL.
        DELETE FROM SAPCTACTEBSAD where sapsocied = :SO_BUKRS-LOW
      ENDEXEC.
    ENDIF.
  ENDIF.

ENDFORM.                    "OPENCONNECTION

*&---------------------------------------------------------------------*
*&      Form  CLOSECONNECTION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM closeconnection.

  EXEC                                                  "#EC CI_EXECSQL
    SQL.
    SET CONNECTION DEFAULT
  ENDEXEC.

ENDFORM.                    "CLOSECONNECTION
*&---------------------------------------------------------------------*
*&      Form  SEND_DBORACLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0076   text
*      -->P_LS_BSID  text
*----------------------------------------------------------------------*
FORM send_dboracle_bsid USING ls_bsid STRUCTURE ls_bsid.

  CLEAR: tmp_dmbtr, tmp_wrbtr.

  tmp_dmbtr = ls_bsid-dmbtr.
  REPLACE '.' WITH space INTO tmp_dmbtr.
  CONDENSE tmp_dmbtr NO-GAPS.

  tmp_wrbtr = ls_bsid-wrbtr.
  REPLACE '.' WITH space INTO tmp_wrbtr.
  CONDENSE tmp_wrbtr NO-GAPS.

  tmp_nebtr = ls_bsid-nebtr.
  REPLACE '.' WITH space INTO tmp_nebtr.
  CONDENSE tmp_nebtr NO-GAPS.

  IF NOT ls_bsid-vertn IS INITIAL AND ls_bsid-vertn NE '0000000000000'.
    WHILE ls_bsid-vertn(1) = '0'.
      SHIFT ls_bsid-vertn LEFT.
    ENDWHILE.
  ENDIF.

  EXEC                                                  "#EC CI_EXECSQL
    SQL.
    insert into SAPCTACTE ( sapmandte,
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
                            sapindafecto,
                            url,
                            zcod_rechazo,
                            sapfecvencimiento,
*                           sapnroconvenio),
                            sapnroconvenio,
                            BSEG_NEBTR)
                   values ( :LS_BSID-MANDT,
                            :LS_BSID-BUKRS,
                            :LS_BSID-KUNNR,
                            :LS_BSID-STCD1,
                            :LS_BSID-UMSKS,
                            :LS_BSID-UMSKZ,
                            CASE WHEN :LS_BSID-AUGDT = '00000000' THEN NULL ELSE TO_DATE(:LS_BSID-AUGDT,'YYYY-MM-DD') END,
                            :LS_BSID-AUGBL,
                            :LS_BSID-ZUONR,
                            :LS_BSID-GJAHR,
                            :LS_BSID-BELNR,
                            CASE WHEN :LS_BSID-BUDAT = '00000000' THEN NULL ELSE TO_DATE(:LS_BSID-BUDAT,'YYYY-MM-DD') END,
                            CASE WHEN :LS_BSID-BLDAT = '00000000' THEN NULL ELSE TO_DATE(:LS_BSID-BLDAT,'YYYY-MM-DD') END,
                            CASE WHEN :LS_BSID-CPUDT = '00000000' THEN NULL ELSE TO_DATE(:LS_BSID-CPUDT,'YYYY-MM-DD') END,
                            :LS_BSID-WAERS,
                            :LS_BSID-XBLNR,
                            :LS_BSID-BLART,
                            :LS_BSID-MONAT,
                            :LS_BSID-BSCHL,
                            :LS_BSID-ZUMSK,
                            :LS_BSID-SHKZG,
                            :LS_BSID-MWSKZ,
                            :TMP_DMBTR,
                            :TMP_WRBTR,
                            :LS_BSID-MWSTS,
                            :LS_BSID-WMWST,
                            :LS_BSID-SGTXT,
                            :LS_BSID-SAKNR,
                            :LS_BSID-HKONT,
                            CASE WHEN :LS_BSID-ZFBDT = '00000000' THEN NULL ELSE TO_DATE(:LS_BSID-ZFBDT,'YYYY-MM-DD') END,
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
                            CASE WHEN :LS_BSID-PRODPER = '00000000' THEN NULL ELSE TO_DATE(:LS_BSID-PRODPER,'YYYY-MM-DD') END,
                            CASE WHEN :LS_BSID-ZFEC_CONT = '00000000' THEN NULL ELSE TO_DATE(:LS_BSID-ZFEC_CONT,'YYYY-MM-DD') END,
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
                            :LS_BSID-ZIND_AFECTO,
                            :LS_BSID-ZURL,
                            :LS_BSID-ZCOD_RECHAZO,
                            CASE WHEN :LS_BSID-FDTAG = '00000000' THEN NULL ELSE TO_DATE(:LS_BSID-FDTAG,'YYYY-MM-DD') END,
*                           :LS_BSID-ZZCONVENIO)
                            :LS_BSID-ZZCONVENIO,
*                           :TMP_DMBTR)
                            :TMP_NEBTR)
  ENDEXEC.

ENDFORM.                    " SEND_DBORACLE
*&---------------------------------------------------------------------*
*&      Form  ORACLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM oracle .

  PERFORM openconnection.
*
  IF p_pa = true.
    SORT tmp_bsid BY kunnr belnr ASCENDING.
    LOOP AT tmp_bsid INTO ls_bsid.
      PERFORM send_dboracle_bsid USING ls_bsid.
    ENDLOOP.
  ENDIF.
*

  IF p_pc = true.
    SORT tmp_bsad BY kunnr belnr ASCENDING.
    LOOP AT tmp_bsad INTO ls_bsad.
      PERFORM send_dboracle_bsad USING ls_bsad.
    ENDLOOP.
  ENDIF.
*
  PERFORM closeconnection.
*
ENDFORM.                    " ORACLE


*&---------------------------------------------------------------------*
*&      Form  ALV
*&---------------------------------------------------------------------*
FORM alv .

  is_print-no_print_selinfos  = true.
  is_print-no_print_listinfos = true.
*
  is_u_layout-zebra = true.
*
  CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
    EXPORTING
      i_list_type     = 0
    IMPORTING
      et_events       = gt_events
    EXCEPTIONS
      list_type_wrong = 1
      OTHERS          = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
       WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    SORT gt_events BY name.
    READ TABLE gt_events INTO wa_event BINARY SEARCH WITH KEY name = slis_ev_top_of_page.
    IF sy-subrc = 0.
      MOVE c_formname_top_of_page TO wa_event-form.
      MODIFY gt_events FROM wa_event INDEX sy-tabix.
    ENDIF.
    READ TABLE gt_events INTO wa_event BINARY SEARCH  WITH KEY name = slis_ev_top_of_list.
    IF sy-subrc = 0.
      MOVE c_formname_top_of_list TO wa_event-form.
      MODIFY gt_events FROM wa_event INDEX sy-tabix.
    ENDIF.
    READ TABLE gt_events INTO wa_event BINARY SEARCH WITH KEY name = slis_ev_end_of_list.
    IF sy-subrc = 0.
      MOVE c_formname_end_of_list TO wa_event-form.
      MODIFY gt_events FROM wa_event INDEX sy-tabix.
    ENDIF.

    DELETE gt_events WHERE form IS INITIAL.
    CASE true.
      WHEN p_pa.
        CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
          EXPORTING
            i_buffer_active    = space
            i_callback_program = sy-repid
            i_structure_name   = 'ZSAPCTACTEBSID'
            is_layout          = is_u_layout
            it_fieldcat        = it_u_fieldcat
            it_sort            = it_u_sort
            i_default          = 'X'
            is_print           = is_print
            it_events          = gt_events
          TABLES
            t_outtab           = tmp_bsid[]
          EXCEPTIONS
            program_error      = 1
            OTHERS             = 2.
        IF sy-subrc NE 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
             WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.
      WHEN p_pc.
        CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
          EXPORTING
            i_buffer_active    = space
            i_callback_program = sy-repid
            i_structure_name   = 'ZSAPCTACTEBSID'
            is_layout          = is_u_layout
            it_fieldcat        = it_u_fieldcat
            it_sort            = it_u_sort
            i_default          = 'X'
            is_print           = is_print
            it_events          = gt_events
          TABLES
            t_outtab           = tmp_bsad[]
          EXCEPTIONS
            program_error      = 1
            OTHERS             = 2.
        IF sy-subrc NE 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                     WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.
    ENDCASE.
  ENDIF.
ENDFORM.                    " ALV
*&---------------------------------------------------------------------*
*&      Form  OBTAIN_BSID
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM obtain_bsid TABLES tmp_bsid TYPE tyt_sapctactebsid .   "#EC

  DATA:ti_bsid TYPE STANDARD TABLE OF bsid,
       wa_bsid LIKE LINE OF ti_bsid,
       wa_tmp_bsid LIKE LINE OF tmp_bsid.

  REFRESH :tmp_bsid, ti_bseg, ti_kna1, ti_anex.

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT mandt bukrs kunnr umsks umskz augdt augbl zuonr gjahr
*         belnr budat bldat cpudt waers xblnr blart monat bschl
*         zumsk shkzg mwskz dmbtr wrbtr mwsts wmwst sgtxt saknr
*         hkont zfbdt zterm zbd1t zbd2t zbd3t zbd1p zbd2p skfbt
*         sknto wskto zlsch zlspr hbkid rebzg rebzj bstat vbeln
*         vertt vertn xref1 xref2 kostl kkber prctr xref3 kidno
*         zcod_rechazo
*    INTO CORRESPONDING FIELDS OF TABLE ti_bsid
*    FROM bsid
*    WHERE bukrs IN so_bukrs
*      AND kunnr IN so_kunnr.
*
* NEW CODE
  SELECT mandt bukrs kunnr umsks umskz augdt augbl zuonr gjahr
         belnr budat bldat cpudt waers xblnr blart monat bschl
         zumsk shkzg mwskz dmbtr wrbtr mwsts wmwst sgtxt saknr
         hkont zfbdt zterm zbd1t zbd2t zbd3t zbd1p zbd2p skfbt
         sknto wskto zlsch zlspr hbkid rebzg rebzj bstat vbeln
         vertt vertn xref1 xref2 kostl kkber prctr xref3 kidno
         zcod_rechazo

    INTO CORRESPONDING FIELDS OF TABLE ti_bsid
    FROM bsid
    WHERE bukrs IN so_bukrs
      AND kunnr IN so_kunnr ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

  IF sy-subrc = 0.
    SORT ti_bsid BY bukrs belnr gjahr.
    LOOP AT ti_bsid INTO wa_bsid.
      MOVE-CORRESPONDING wa_bsid TO wa_tmp_bsid .           "#EC ENHOK
      APPEND wa_tmp_bsid  TO tmp_bsid.
    ENDLOOP.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*    SELECT bukrs belnr gjahr fdtag nebtr
*      INTO TABLE ti_bseg
*      FROM bseg
*      FOR ALL ENTRIES IN tmp_bsid
*      WHERE bukrs = tmp_bsid-bukrs
*        AND belnr = tmp_bsid-belnr
*        AND gjahr = tmp_bsid-gjahr
**       AND buzei = '001'.
*        AND koart = 'D'.
*
* NEW CODE
    SELECT bukrs belnr gjahr fdtag nebtr

      INTO TABLE ti_bseg
      FROM bseg
      FOR ALL ENTRIES IN tmp_bsid
      WHERE bukrs = tmp_bsid-bukrs
        AND belnr = tmp_bsid-belnr
        AND gjahr = tmp_bsid-gjahr
*       AND buzei = '001'.
        AND koart = 'D' ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
    SORT ti_bseg BY bukrs belnr gjahr.

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*    SELECT kunnr stcd1
*      INTO TABLE ti_kna1
*      FROM kna1
*      FOR ALL ENTRIES IN tmp_bsid
*      WHERE kunnr = tmp_bsid-kunnr.
*
* NEW CODE
    SELECT kunnr stcd1

      INTO TABLE ti_kna1
      FROM kna1
      FOR ALL ENTRIES IN tmp_bsid
      WHERE kunnr = tmp_bsid-kunnr ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
    SORT ti_kna1 BY kunnr.

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*    SELECT *
*      FROM zfac_anex
*      INTO CORRESPONDING FIELDS OF TABLE ti_anex
*      FOR ALL ENTRIES IN tmp_bsid
*      WHERE bukrs = tmp_bsid-bukrs
*        AND belnr = tmp_bsid-belnr
*        AND gjahr = tmp_bsid-gjahr.
*
* NEW CODE
    SELECT *

      FROM zfac_anex
      INTO CORRESPONDING FIELDS OF TABLE ti_anex
      FOR ALL ENTRIES IN tmp_bsid
      WHERE bukrs = tmp_bsid-bukrs
        AND belnr = tmp_bsid-belnr
        AND gjahr = tmp_bsid-gjahr ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
    SORT ti_anex BY bukrs belnr gjahr.
  ENDIF.

  LOOP AT tmp_bsid ASSIGNING <fs>.
    CLEAR: wa_bseg, wa_kna1, wa_anex.

    IF <fs>-znum_doc_core = space.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE znum_doc_core INTO
*                  (wznum_doc_core)
*            FROM vbrk WHERE vbeln = <fs>-kidno.
*
* NEW CODE
      SELECT znum_doc_core
      UP TO 1 ROWS  INTO
                  (wznum_doc_core)
            FROM vbrk WHERE vbeln = <fs>-kidno ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

      <fs>-znum_doc_core = wznum_doc_core.

    ENDIF.
*
    READ TABLE ti_bseg INTO wa_bseg WITH KEY bukrs = <fs>-bukrs
                                             belnr = <fs>-belnr
                                             gjahr = <fs>-gjahr
                                             BINARY SEARCH.
    IF sy-subrc = 0.
      <fs>-fdtag = wa_bseg-fdtag.
      <fs>-nebtr = wa_bseg-nebtr.
    ENDIF.

    READ TABLE ti_anex INTO wa_anex WITH KEY bukrs = <fs>-bukrs
                                             belnr = <fs>-belnr
                                             gjahr = <fs>-gjahr
                                             BINARY SEARCH.
    IF sy-subrc = 0.
      MOVE-CORRESPONDING wa_anex TO <fs>.                   "#EC ENHOK
      MOVE wa_anex-zzconve_dpp TO <fs>-zzconvenio.
      IF <fs>-zzconvenio IS INITIAL.
        <fs>-zzconvenio = '0000000000'.
      ENDIF.
    ENDIF.

    READ TABLE ti_kna1 INTO wa_kna1 WITH KEY kunnr = <fs>-kunnr
                                             BINARY SEARCH.
    IF sy-subrc = 0.
      <fs>-zrut_cli_pagador = wa_kna1-stcd1.
    ENDIF.
  ENDLOOP.



ENDFORM.                    " OBTAIN_BSID
*&---------------------------------------------------------------------*
*&      Form  OBTAIN_BSAD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TMP_BSAD  text
*----------------------------------------------------------------------*
FORM obtain_bsad TABLES tmp_bsad TYPE tyt_sapctactebsid .   "#EC

  DATA:ti_bsad TYPE STANDARD TABLE OF bsad,
       wa_bsad LIKE LINE OF ti_bsad,
       wkidno TYPE bsad-kidno,
       wa_tmp_bsad LIKE LINE OF tmp_bsad.
*
  REFRESH :tmp_bsad, ti_bseg, ti_kna1, ti_anex.

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT mandt bukrs kunnr umsks umskz augdt augbl zuonr gjahr
*         belnr budat bldat cpudt waers xblnr blart monat bschl
*         zumsk shkzg mwskz dmbtr wrbtr mwsts wmwst sgtxt saknr
*         hkont zfbdt zterm zbd1t zbd2t zbd3t zbd1p zbd2p skfbt
*         sknto wskto zlsch zlspr hbkid rebzg rebzj bstat vbeln
*         vertt vertn xref1 xref2 kostl kkber prctr xref3 kidno
*    INTO CORRESPONDING FIELDS OF TABLE ti_bsad
*    FROM bsad
*    WHERE bukrs IN so_bukrs
**->   BEG DEL CNN 18.06.2015
**      AND kunnr IN so_kunnr
**      AND augdt GE p_feini
**      AND augdt LE p_fefin.
**->   END DEL CNN 18.06.2015
**->   BEG INS CNN 18.06.2015
*      AND cpudt GE p_feini
*      AND cpudt LE p_fefin
*      AND kunnr IN so_kunnr.
*
* NEW CODE
  SELECT mandt bukrs kunnr umsks umskz augdt augbl zuonr gjahr
         belnr budat bldat cpudt waers xblnr blart monat bschl
         zumsk shkzg mwskz dmbtr wrbtr mwsts wmwst sgtxt saknr
         hkont zfbdt zterm zbd1t zbd2t zbd3t zbd1p zbd2p skfbt
         sknto wskto zlsch zlspr hbkid rebzg rebzj bstat vbeln
         vertt vertn xref1 xref2 kostl kkber prctr xref3 kidno

    INTO CORRESPONDING FIELDS OF TABLE ti_bsad
    FROM bsad
    WHERE bukrs IN so_bukrs
*->   BEG DEL CNN 18.06.2015
*      AND kunnr IN so_kunnr
*      AND augdt GE p_feini
*      AND augdt LE p_fefin.
*->   END DEL CNN 18.06.2015
*->   BEG INS CNN 18.06.2015
      AND cpudt GE p_feini
      AND cpudt LE p_fefin
      AND kunnr IN so_kunnr ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
*      AND augdt LE p_fefin.(03.11.2015 se excluye fecha
*->   END INS CNN 18.06.2015
  IF sy-subrc = 0.
    LOOP AT ti_bsad INTO wa_bsad.
      MOVE-CORRESPONDING wa_bsad TO wa_tmp_bsad.            "#EC ENHOK
      APPEND wa_tmp_bsad TO tmp_bsad.
    ENDLOOP.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*    SELECT bukrs belnr gjahr fdtag nebtr
*      INTO TABLE ti_bseg
*      FROM bseg
*      FOR ALL ENTRIES IN tmp_bsad
*      WHERE bukrs = tmp_bsad-bukrs
*        AND belnr = tmp_bsad-belnr
*        AND gjahr = tmp_bsad-gjahr
*        AND buzei = '001'.
*
* NEW CODE
    SELECT bukrs belnr gjahr fdtag nebtr

      INTO TABLE ti_bseg
      FROM bseg
      FOR ALL ENTRIES IN tmp_bsad
      WHERE bukrs = tmp_bsad-bukrs
        AND belnr = tmp_bsad-belnr
        AND gjahr = tmp_bsad-gjahr
        AND buzei = '001' ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
    SORT ti_bseg BY bukrs belnr gjahr.

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*    SELECT kunnr stcd1
*      INTO TABLE ti_kna1
*      FROM kna1
*      FOR ALL ENTRIES IN tmp_bsad
*      WHERE kunnr = tmp_bsad-kunnr.
*
* NEW CODE
    SELECT kunnr stcd1

      INTO TABLE ti_kna1
      FROM kna1
      FOR ALL ENTRIES IN tmp_bsad
      WHERE kunnr = tmp_bsad-kunnr ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
    SORT ti_kna1 BY kunnr.

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*    SELECT *
*      INTO TABLE ti_anex
*      FROM zfac_anex
*      FOR ALL ENTRIES IN tmp_bsad
*      WHERE bukrs = tmp_bsad-bukrs
*        AND belnr = tmp_bsad-belnr
*        AND gjahr = tmp_bsad-gjahr.
*
* NEW CODE
    SELECT *

      INTO TABLE ti_anex
      FROM zfac_anex
      FOR ALL ENTRIES IN tmp_bsad
      WHERE bukrs = tmp_bsad-bukrs
        AND belnr = tmp_bsad-belnr
        AND gjahr = tmp_bsad-gjahr ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
    SORT ti_anex BY bukrs belnr gjahr.
  ENDIF.

  LOOP AT tmp_bsad ASSIGNING <fs>.
    CLEAR: wa_bseg, wa_kna1, wa_anex.

    IF <fs>-bschl = '01' OR
       <fs>-bschl = '11'.
      IF <fs>-znum_doc_core = space.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE znum_doc_core INTO
*                    (wznum_doc_core)
*           FROM vbrk WHERE vbeln = <fs>-kidno.
*
* NEW CODE
        SELECT znum_doc_core
        UP TO 1 ROWS  INTO
                    (wznum_doc_core)
           FROM vbrk WHERE vbeln = <fs>-kidno ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

        <fs>-znum_doc_core = wznum_doc_core.
      ENDIF.
    ELSE.
      IF <fs>-znum_doc_core = space.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE kidno INTO
*                     (wkidno)
*            FROM bsad WHERE bukrs =  <fs>-bukrs
*                        AND kunnr =  <fs>-kunnr
*                        AND augbl =  <fs>-belnr
*                        AND belnr <> <fs>-belnr.
*
* NEW CODE
        SELECT kidno
        UP TO 1 ROWS  INTO
                     (wkidno)
            FROM bsad WHERE bukrs =  <fs>-bukrs
                        AND kunnr =  <fs>-kunnr
                        AND augbl =  <fs>-belnr
                        AND belnr <> <fs>-belnr ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
*
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE znum_doc_core INTO
*                     (wznum_doc_core)
*            FROM vbrk WHERE vbeln = wkidno.
*
* NEW CODE
        SELECT znum_doc_core
        UP TO 1 ROWS  INTO
                     (wznum_doc_core)
            FROM vbrk WHERE vbeln = wkidno ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

        <fs>-znum_doc_core = wznum_doc_core.
      ENDIF.
    ENDIF.
*
    READ TABLE ti_bseg INTO wa_bseg WITH KEY bukrs = <fs>-bukrs
                                             belnr = <fs>-belnr
                                             gjahr = <fs>-gjahr
                                             BINARY SEARCH.
    IF sy-subrc = 0.
      <fs>-fdtag = wa_bseg-fdtag.
      <fs>-nebtr = wa_bseg-nebtr.
    ENDIF.

    READ TABLE ti_anex INTO wa_anex WITH KEY bukrs = <fs>-bukrs
                                             belnr = <fs>-belnr
                                             gjahr = <fs>-gjahr
                                             BINARY SEARCH.
    IF sy-subrc = 0.
      MOVE-CORRESPONDING wa_anex TO <fs>.                   "#EC ENHOK
      MOVE wa_anex-zzconve_dpp TO <fs>-zzconvenio.
      IF <fs>-zzconvenio IS INITIAL.
        <fs>-zzconvenio = '0000000000'.
      ENDIF.
    ENDIF.

    READ TABLE ti_kna1 INTO wa_kna1 WITH KEY kunnr = <fs>-kunnr
                                             BINARY SEARCH.
    IF sy-subrc = 0.
      <fs>-zrut_cli_pagador = wa_kna1-stcd1.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " OBTAIN_BSAD


*&---------------------------------------------------------------------*
*&      Form  SEND_DBORACLE_BSAD
*&---------------------------------------------------------------------*
FORM send_dboracle_bsad USING ls_bsad TYPE ty_sapctactebsid. "#EC
  DATA : lv_stblg TYPE stblg.
*
* ini 24.12.2013  verifica si documento fue de anulación.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE stblg INTO lv_stblg
*         FROM bkpf WHERE bukrs EQ ls_bsad-bukrs AND
*                         belnr EQ ls_bsad-belnr AND
*                         gjahr EQ ls_bsad-gjahr.
*
* NEW CODE
  SELECT stblg
  UP TO 1 ROWS  INTO lv_stblg
         FROM bkpf WHERE bukrs EQ ls_bsad-bukrs AND
                         belnr EQ ls_bsad-belnr AND
                         gjahr EQ ls_bsad-gjahr ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
* fin 24.12.2013  verifica si documento fue de anulación.
  CLEAR: tmp_dmbtr, tmp_wrbtr.

  tmp_dmbtr = ls_bsad-dmbtr.
  REPLACE '.' WITH space INTO tmp_dmbtr.
  CONDENSE tmp_dmbtr NO-GAPS.

  tmp_wrbtr = ls_bsad-wrbtr.
  REPLACE '.' WITH space INTO tmp_wrbtr.
  CONDENSE tmp_wrbtr NO-GAPS.

  tmp_nebtr = ls_bsad-wrbtr.
  REPLACE '.' WITH space INTO tmp_nebtr.
  CONDENSE tmp_nebtr NO-GAPS.

  IF NOT ls_bsad-vertn IS INITIAL AND ls_bsad-vertn NE '0000000000000'.
    WHILE ls_bsad-vertn(1) = '0'.
      SHIFT ls_bsad-vertn LEFT.
    ENDWHILE.
  ENDIF.

  EXEC                                                  "#EC CI_EXECSQL
    SQL.
    insert into SAPCTACTEBSAD ( sapmandte,
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
                                sapindafecto,
                                sapfecvencimiento,
                                sapnroconvenio,
                                BSAD_STBLG)
                   values ( :LS_BSAD-MANDT,
                            :LS_BSAD-BUKRS,
                            :LS_BSAD-KUNNR,
                            :LS_BSAD-STCD1,
                            :LS_BSAD-UMSKS,
                            :LS_BSAD-UMSKZ,
                            CASE WHEN :LS_BSAD-AUGDT = '00000000' THEN NULL ELSE TO_DATE(:LS_BSAD-AUGDT,'YYYY-MM-DD') END,
                            :LS_BSAD-AUGBL,
                            :LS_BSAD-ZUONR,
                            :LS_BSAD-GJAHR,
                            :LS_BSAD-BELNR,
                            CASE WHEN :LS_BSAD-BUDAT = '00000000' THEN NULL ELSE TO_DATE(:LS_BSAD-BUDAT,'YYYY-MM-DD') END,
                            CASE WHEN :LS_BSAD-BLDAT = '00000000' THEN NULL ELSE TO_DATE(:LS_BSAD-BLDAT,'YYYY-MM-DD') END,
                            CASE WHEN :LS_BSAD-CPUDT = '00000000' THEN NULL ELSE TO_DATE(:LS_BSAD-CPUDT,'YYYY-MM-DD') END,
                            :LS_BSAD-WAERS,
                            :LS_BSAD-XBLNR,
                            :LS_BSAD-BLART,
                            :LS_BSAD-MONAT,
                            :LS_BSAD-BSCHL,
                            :LS_BSAD-ZUMSK,
                            :LS_BSAD-SHKZG,
                            :LS_BSAD-MWSKZ,
                            :TMP_DMBTR,
                            :TMP_WRBTR,
                            :LS_BSAD-MWSTS,
                            :LS_BSAD-WMWST,
                            :LS_BSAD-SGTXT,
                            :LS_BSAD-SAKNR,
                            :LS_BSAD-HKONT,
                            CASE WHEN :LS_BSAD-ZFBDT = '00000000' THEN NULL ELSE TO_DATE(:LS_BSAD-ZFBDT,'YYYY-MM-DD') END,
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
                            CASE WHEN :LS_BSAD-PRODPER = '00000000' THEN NULL ELSE TO_DATE(:LS_BSAD-PRODPER,'YYYY-MM-DD') END,
                            CASE WHEN :LS_BSAD-ZFEC_CONT = '00000000' THEN NULL ELSE TO_DATE(:LS_BSAD-ZFEC_CONT,'YYYY-MM-DD') END,
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
                            :LS_BSAD-ZIND_AFECTO,
                            CASE WHEN :LS_BSAD-FDTAG = '00000000' THEN NULL ELSE TO_DATE(:LS_BSAD-FDTAG,'YYYY-MM-DD') END,
                            :LS_BSAD-ZZCONVENIO,
                            :LV_STBLG)
  ENDEXEC.

ENDFORM.                    " SEND_DBORACLE_BSAD


*&---------------------------------------------------------------------*
*&      Form  GRABAR_LOG
*&---------------------------------------------------------------------*
*& Se graba en el servidor local el log para la BSAD
*&---------------------------------------------------------------------*
FORM grabar_log.

  DATA: l_arlog    TYPE string,
        l_lin(100) TYPE c,
        l_cfech(10).

* Archivo de salida en servidor SAP
  CONCATENATE '/usr/sap/tmp/BSAD_' p_fefin
    INTO l_arlog.

  OPEN DATASET l_arlog FOR OUTPUT IN TEXT MODE ENCODING DEFAULT.

* Cabecera
  l_lin = 'Soc.  Documento   Cliente     Contrato      Fec.Contab. Fec.Regis.'.
  TRANSFER l_lin TO l_arlog.

  LOOP AT tmp_bsad INTO ls_bsad.
    CLEAR l_lin.
    l_lin+00(04) = ls_bsad-bukrs.
    l_lin+06(10) = ls_bsad-belnr.
    l_lin+18(10) = ls_bsad-kunnr.
    l_lin+30(13) = ls_bsad-vertn.
    WRITE ls_bsad-budat TO l_cfech.
    l_lin+44(10) = l_cfech.
    WRITE ls_bsad-cpudt TO l_cfech.
    l_lin+56(10) = l_cfech.
    TRANSFER l_lin TO l_arlog.
  ENDLOOP.

  CLOSE DATASET l_arlog.

ENDFORM.                    "grabar_log

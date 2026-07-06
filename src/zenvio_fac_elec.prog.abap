*----------------------------------------------------------------------*
*  Código basado en RVADIN01                                           *
*----------------------------------------------------------------------*
REPORT zenvio_fac_elec LINE-COUNT 100 MESSAGE-ID vn.

INCLUDE zenv_fac_elec_top.
*
*&---------------------------------------------------------------------*
*&      Form  ENTRY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->RETURN_CODE  text
*      -->US_SCREEN    text
*----------------------------------------------------------------------*
FORM entry USING return_code us_screen.

  CLEAR return_code.
  xscreen = us_screen.
  PERFORM processing USING us_screen return_code.

ENDFORM.                    "ENTRY

*&---------------------------------------------------------------------*
*&      Form  PROCESSING
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->PROC_SCREEN  text
*----------------------------------------------------------------------*
FORM processing USING proc_screen return_code.

  PERFORM get_data TABLES tvbdpr USING vbdkr.
  CHECK return_code EQ 0.
  IF nast-anzal EQ 0.
    nast_anzal = 1.
  ELSE.
    nast_anzal = nast-anzal.
  ENDIF.
  nast-anzal = 1.
  nast_tdarmod = nast-tdarmod.
  nast-tdarmod = 1.
*  PERFORM send_msg_electronic_acepta TABLES tvbdpr USING nast vbdkr
*  CHANGING return_code.
*
  PERFORM send_msg_electronic_acepta TABLES tvbdpr
                                     USING vbdkr
                                     CHANGING nast return_code.

  nast-anzal = nast_anzal.
  nast-tdarmod = nast_tdarmod.

ENDFORM.                    "PROCESSING

*---------------------------------------------------------------------*
*       FORM CHECK_REPEAT
*
*---------------------------------------------------------------------*
*       A text is printed, if it is a repeat print for the document.  *
*---------------------------------------------------------------------*
FORM check_repeat.

  CLEAR repeat.
  CLEAR anzal.
  SELECT * INTO *nast FROM nast WHERE kappl = nast-kappl
                                AND   objky = nast-objky
                                AND   kschl = nast-kschl
                                AND   spras = nast-spras
                                AND   parnr = nast-parnr
                                AND   parvw = nast-parvw
                                AND   nacha BETWEEN '1' AND '4'.
    IF *nast-vstat = '1'.
      anzal = anzal + *nast-anzal.
      repeat = 'X'.
    ENDIF.
  ENDSELECT.

ENDFORM.                    "CHECK_REPEAT

*---------------------------------------------------------------------*
*       FORM GET_DATA                                                 *
*---------------------------------------------------------------------*
*       General provision of data for the form                        *
*---------------------------------------------------------------------*
FORM get_data TABLES tvbdpr STRUCTURE tvbdpr
              USING vbdkr STRUCTURE vbdkr.

  CALL FUNCTION 'RV_PRICE_PRINT_REFRESH'
    TABLES
      tkomv = tkomv.

  REFRESH ixsdaccdpc.
  CLEAR: komk, komp, nast_anzal, sdaccdpc, downpay_refresh.

  IF nast-objky+10(6) NE space.
    vbco3-vbeln = nast-objky+16(10).
  ELSE.
    vbco3-vbeln = nast-objky.
  ENDIF.

  vbco3-mandt = sy-mandt.
  vbco3-spras = nast-spras.
  vbco3-kunde = nast-parnr.
  vbco3-parvw = nast-parvw.

  CALL FUNCTION 'RV_BILLING_PRINT_VIEW'
    EXPORTING
      comwa                        = vbco3
    IMPORTING
      kopf                         = vbdkr
    TABLES
      pos                          = tvbdpr
    EXCEPTIONS
      terms_of_payment_not_in_t052 = 1
      error_message                = 5
      OTHERS                       = 4.

  IF NOT sy-subrc IS INITIAL.
    IF sy-subrc = 1.
      syst-msgty = 'I'.
      PERFORM protocol_update.
    ENDIF.
  ENDIF.

* fill address key --> necessary for emails
  addr_key-addrnumber = vbdkr-adrnr.
  addr_key-persnumber = vbdkr-adrnp.
  addr_key-addr_type  = vbdkr-address_type.

  PERFORM sender.
  PERFORM check_repeat.
  PERFORM get_header_prices.

* Calling customer subroutine dynamically for additional data transfer
  IF NOT get_data_userexit IS INITIAL.
    PERFORM (get_data_userexit) IN PROGRAM rvadin01 IF FOUND.
  ENDIF.

ENDFORM.                    "GET_DATA

*---------------------------------------------------------------------*
*       FORM GET_HEADER_PRICES                                        *
*---------------------------------------------------------------------*
*       In this routine the price data for the header is fetched from *
*       the database.                                                 *
*---------------------------------------------------------------------*
FORM get_header_prices.

  IF komk-knumv NE vbdkr-knumv.
    CLEAR komk.
    komk-mandt = sy-mandt.
    komk-kalsm = vbdkr-kalsm.
    komk-fkart = vbdkr-fkart.
    komk-kappl = pr_kappl.
    IF vbdkr-kappl NE space.
      komk-kappl = vbdkr-kappl.
    ENDIF.
    komk-waerk = vbdkr-waerk.
    komk-knumv = vbdkr-knumv.
    komk-vbtyp = vbdkr-vbtyp.
    komk-knuma = vbdkr-knuma.
    komk-bukrs = vbdkr-bukrs.
    komk-land1 = vbdkr-lland.
    komk-vkorg = vbdkr-vkorg.
    komk-vtweg = vbdkr-vtweg.
    komk-spart = vbdkr-spart.
    komk-hwaer = vbdkr-waers.
    komk-prsdt = vbdkr-erdat.
    komk-kurst = vbdkr-kurst.
    komk-kurrf = vbdkr-kurrf.
    komk-kurrf_dat = vbdkr-kurrf_dat.
  ENDIF.
  CALL FUNCTION 'RV_PRICE_PRINT_HEAD'
    EXPORTING
      comm_head_i = komk
      language    = nast-spras
    IMPORTING
      comm_head_e = komk
      comm_mwskz  = print_mwskz
    TABLES
      tkomv       = tkomv
      tkomvd      = hkomvd.
* Calling customer subroutine dynamically for handling header prices
  IF NOT header_userexit IS INITIAL.
    PERFORM (header_userexit) IN PROGRAM rvadin01 IF FOUND.
  ENDIF.

ENDFORM.                    "GET_HEADER_PRICES

*&---------------------------------------------------------------------*
*&      Form  PROTOCOL_UPDATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM protocol_update.

  CHECK xscreen = space.
  CALL FUNCTION 'NAST_PROTOCOL_UPDATE'
    EXPORTING
      msg_arbgb = syst-msgid
      msg_nr    = syst-msgno
      msg_ty    = syst-msgty
      msg_v1    = syst-msgv1
      msg_v2    = syst-msgv2
      msg_v3    = syst-msgv3
      msg_v4    = syst-msgv4
    EXCEPTIONS
      OTHERS    = 1.

ENDFORM.                    "PROTOCOL_UPDATE

*---------------------------------------------------------------------*
*       FORM SENDER                                                   *
*---------------------------------------------------------------------*
*       This routine determines the address of the sender (Table VKO) *
*---------------------------------------------------------------------*

FORM sender.

  SELECT SINGLE * FROM tvko  WHERE vkorg = vbdkr-vkorg.
  IF sy-subrc NE 0.
    syst-msgid = 'VN'.
    syst-msgno = '203'.
    syst-msgty = 'E'.
    syst-msgv1 = 'TVKO'.
    syst-msgv2 = syst-subrc.
    PERFORM protocol_update.
    EXIT.
  ENDIF.
  CLEAR gv_fb_addr_get_selection.
  gv_fb_addr_get_selection-addrnumber = tvko-adrnr.
  CALL FUNCTION 'ADDR_GET'
    EXPORTING
      address_selection = gv_fb_addr_get_selection
      address_group     = 'CA01'
    IMPORTING
      sadr              = sadr
    EXCEPTIONS
      OTHERS            = 01.                               "SADR40A
  IF sy-subrc NE 0.
    CLEAR sadr.
  ENDIF.

  vbdkr-sland = sadr-land1.
  IF sy-subrc NE 0.
    syst-msgid = 'VN'.
    syst-msgno = '203'.
    syst-msgty = 'E'.
    syst-msgv1 = 'SADR'.
    syst-msgv2 = syst-subrc.
    PERFORM protocol_update.
  ENDIF.

* Interne Verrechnung: Adresse des Buchungskreises lesen
  IF vbdkr-vbtyp CA '56'.
    CLEAR t001g.
    SELECT SINGLE * FROM t001g WHERE bukrs = vbdkr-bukrs
                                 AND programm EQ sy-repid
                                 AND txtid EQ 'SD'.
  ENDIF.

ENDFORM.                    "SENDER


*&---------------------------------------------------------------------*
*&      Form  SEND_MSG_ELECTRONIC_ACEPTA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM send_msg_electronic_acepta TABLES tvbdpr STRUCTURE tvbdpr
                                USING vbdkr STRUCTURE vbdkr
                                CHANGING  nast STRUCTURE nast
                                          return_code.
  TABLES ztdea.
  DATA l TYPE i.
  DATA: long   TYPE i,
        cadena TYPE string.
  DATA: new_xblnr TYPE vbrk-xblnr.
  DATA: c_vbrk TYPE bkpf-awtyp VALUE 'VBRK'.
  DATA: wa_zcabpedext TYPE zcabpedext.
  DATA s_mnt_net_det  TYPE c LENGTH 21.
  DATA : l_kunnr    TYPE kunnr,
         l_kunnr_re TYPE kunnr,
         l_kunnr_rg TYPE kunnr,
         l_parvw    TYPE parvw,
         l_fech_ini TYPE char10,
         l_fech_fin TYPE char10,
         l_fecvente TYPE char10.

  DATA: lt_vbfa TYPE STANDARD TABLE OF vbfa.

  com_acc = TEXT-000.

  SELECT SINGLE * FROM vbrk WHERE vbeln EQ nast-objky.
  IF sy-subrc = 0.
    SELECT SINGLE * FROM ztdea WHERE blart EQ vbrk-zblart
                                 AND dea   EQ 'X'.
    IF sy-subrc = 0.
      SELECT SINGLE adrnr  INTO t001-adrnr
        FROM t001  WHERE bukrs EQ vbrk-bukrs.
      IF sy-subrc = 0.
        SELECT SINGLE * FROM adrc WHERE addrnumber EQ t001-adrnr.
      ENDIF.
      SELECT SINGLE * FROM bkpf WHERE bukrs EQ vbrk-bukrs
                                  AND gjahr EQ vbrk-fkdat(4)
                                  AND awtyp EQ c_vbrk
                                  AND awkey EQ vbrk-vbeln.
      CLEAR total_doc.
      total_doc = vbrk-netwr + vbrk-mwsbk.
      IF vbrk-mwsbk IS INITIAL.
        WRITE vbrk-netwr TO s_mnt_exe CURRENCY vbrk-waerk.
        REPLACE ALL OCCURRENCES OF '.' IN s_mnt_exe WITH space.
        CONDENSE s_mnt_exe NO-GAPS.
        IF s_mnt_exe CS '-'.
          REPLACE '-' WITH space INTO s_mnt_exe.
          CONCATENATE '-' s_mnt_exe INTO s_mnt_exe.
        ENDIF.
        s_mnt_net = 0.
        s_mnt_iva = 0.
      ELSE.
        s_mnt_exe = 0.
        WRITE vbrk-netwr TO s_mnt_net CURRENCY vbrk-waerk.
        REPLACE ALL OCCURRENCES OF '.' IN s_mnt_net WITH space.
        CONDENSE s_mnt_net NO-GAPS.
        IF s_mnt_net CS '-'.
          REPLACE '-' WITH space INTO s_mnt_net.
          CONCATENATE '-' s_mnt_net INTO s_mnt_net.
        ENDIF.

        WRITE vbrk-mwsbk TO s_mnt_iva CURRENCY vbrk-waerk.
        REPLACE ALL OCCURRENCES OF '.' IN s_mnt_iva WITH space.
        CONDENSE s_mnt_iva NO-GAPS.
        IF s_mnt_iva CS '-'.
          REPLACE '-' WITH space INTO s_mnt_iva.
          CONCATENATE '-' s_mnt_iva INTO s_mnt_iva.
        ENDIF.
      ENDIF.

      WRITE total_doc TO s_mnt_tot CURRENCY vbrk-waerk.
      REPLACE ALL OCCURRENCES OF '.' IN s_mnt_tot WITH space.
      CONDENSE s_mnt_tot NO-GAPS.
      IF s_mnt_tot CS '-'.
        REPLACE '-' WITH space INTO s_mnt_tot.
        CONCATENATE '-' s_mnt_tot INTO s_mnt_tot.
      ENDIF.
      CLEAR: str_detalle, pos, str_referencia, new_xblnr.
      new_xblnr = vbrk-xblnr.
      new_xblnr(2) = space.
      CONDENSE new_xblnr.
      h_niinv =  new_xblnr. "vbrk-zfolio.
    ELSE.
      SELECT SINGLE vbelv INTO vbfa-vbelv
        FROM vbfa
         WHERE vbeln   EQ vbrk-vbeln "Nro factura
           AND vbtyp_n EQ 'M' "Factura
           AND vbtyp_v EQ 'C'."Pedido
      IF sy-subrc = 0.
        SELECT SINGLE * INTO wa_zcabpedext
          FROM zcabpedext WHERE pedido EQ vbfa-vbelv.
        wa_zcabpedext-fec_car   = sy-datlo.
        wa_zcabpedext-hor_car   = sy-timlo.
        wa_zcabpedext-error_e   = space.
        wa_zcabpedext-log_error = TEXT-094. "
        "'Este tipo de documentos no se envía a Acepta. Ver transacción ZTDEA'.
        UPDATE zcabpedext FROM wa_zcabpedext.
        CHECK wa_zcabpedext-error_e IS INITIAL.
      ENDIF.

    ENDIF.
  ENDIF.
  CLEAR str_detalle.

  DATA: ti_vbrp TYPE TABLE OF vbrp,
        wa_vbrp TYPE vbrp.

  SELECT * INTO TABLE ti_vbrp
    FROM vbrp  WHERE vbeln EQ vbrk-vbeln
               ORDER BY PRIMARY KEY.

  LOOP AT ti_vbrp INTO wa_vbrp.
    CLEAR: str_netwr, str_xblnr_ref,
           str_fkdat_ref, str_tip_ref, str_bsark.
    ADD 1 TO pos.
    str_pos = pos.
    WRITE wa_vbrp-netwr TO str_netwr CURRENCY vbrk-waerk.
    REPLACE ALL OCCURRENCES OF '.' IN str_netwr WITH space.
    CONDENSE str_netwr NO-GAPS.
    IF str_netwr CS '-'.
      REPLACE '-' WITH space INTO str_netwr.
      CONCATENATE '-' str_netwr INTO str_netwr.
    ENDIF.

    CLEAR: lt_vbfa.
    SELECT * FROM vbfa INTO TABLE lt_vbfa
      WHERE vbelv   = wa_vbrp-vgbel
*       AND posnv   = wa_vbrp-vgpos
        AND vbtyp_n = 'M'
        AND vbtyp_v = 'C'.

    LOOP AT lt_vbfa ASSIGNING FIELD-SYMBOL(<ls_vbfa>).
      SELECT SINGLE * FROM vbrk WHERE vbeln  = <ls_vbfa>-vbeln
                                  AND fksto <> 'X'
                                  AND rfbsk  = 'C'.
      IF sy-subrc = 0.
        str_xblnr_ref = vbrk-xblnr.
        str_fkdat_ref = vbrk-fkdat.
        str_tip_ref   = vbrk-zelectronico.
        EXIT.
      ENDIF.
    ENDLOOP.

    SELECT bsark  INTO str_bsark UP TO 1 ROWS
      FROM vbkd  WHERE vbeln EQ wa_vbrp-vgbel
                 ORDER BY PRIMARY KEY.
    ENDSELECT.
    IF str_bsark IS INITIAL.
      str_bsark = '1'.
    ENDIF.

    CLEAR str_desc.
    IF pos EQ 1.
      t_name = vbrk-vbeln.
      CALL FUNCTION 'READ_TEXT'
        EXPORTING
          client                  = sy-mandt
          id                      = '0002'
          language                = sy-langu
          name                    = t_name
          object                  = 'VBBK'
        TABLES
          lines                   = t_lines
        EXCEPTIONS
          id                      = 1
          language                = 2
          name                    = 3
          not_found               = 4
          object                  = 5
          reference_check         = 6
          wrong_access_to_archive = 7
          OTHERS                  = 8.
      LOOP AT t_lines INTO gs_lines.
        CONCATENATE str_desc gs_lines-tdline INTO str_desc.
      ENDLOOP.

*-> BEG INS V1-CNN 14.01.2025 ECDK925993
      IF str_desc IS INITIAL.
        str_desc = tvbdpr-arktx.
      ENDIF.
*-> END INS V1-CNN 14.01.2025

      CONDENSE s_mnt_net NO-GAPS.
      IF s_mnt_net EQ '0'.
        s_mnt_net_det = s_mnt_exe.
      ELSE.
        s_mnt_net_det = s_mnt_net.
      ENDIF.
*
      CASE vbrk-zblart.
        WHEN 'O3' OR 'O4'.   "BOLETA
          CONCATENATE str_detalle
                      TEXT-053                        "<Detalle>
*                       text-b21                       "<CdgItem>
*                        text-b23              text-b24
*                        text-b25              text-b26
*                       text-b22
*                       text-057 '1'          text-058
                       TEXT-059 '1'           TEXT-060
                       TEXT-061 str_desc      TEXT-062
                       TEXT-b27 '1'           TEXT-b28
                       TEXT-063 s_mnt_net_det TEXT-064
                      TEXT-054                        "</Detalle>
                 INTO str_detalle.
        WHEN OTHERS.
          CONCATENATE str_detalle
                      TEXT-053                        "<Detalle>
                       TEXT-055 str_pos   TEXT-056
                       TEXT-057 '1'       TEXT-058
                       TEXT-059 '1'       TEXT-060          "24.12.2013
*                  text-059 space     text-060 "str_arktx text-060
                       TEXT-061 str_desc      TEXT-062 "str_desc  text-062
                       TEXT-063 s_mnt_net_det TEXT-064 "str_netwr text-064
                      TEXT-054                        "</Detalle>
                 INTO str_detalle.
      ENDCASE.
    ENDIF.
  ENDLOOP.

  CLEAR str_fecha.
  CLEAR str_dat.
  CLEAR str_tmstfirma.
  CONCATENATE vbrk-fkdat+0(4) vbrk-fkdat+4(2) vbrk-fkdat+6(2)
              INTO str_fecha SEPARATED BY '-'.
  CONCATENATE sy-datlo+0(4) '-' sy-datlo+4(2) '-' sy-datlo+6(2)
             'T' sy-timlo+0(2) ':' sy-timlo+2(2) ':' sy-timlo+4(2)
             INTO str_tmstfirma.

  SELECT SINGLE vbelv INTO vbfa-vbelv
    FROM vbfa
    WHERE vbeln   EQ vbrk-vbeln "Nro factura
      AND vbtyp_n EQ 'M' "Factura
      AND vbtyp_v EQ 'C'."Pedido
  IF sy-subrc = 0.
    CLEAR wa_zcabpedext.
    SELECT SINGLE *  INTO wa_zcabpedext
      FROM zcabpedext  WHERE pedido EQ vbfa-vbelv.
  ENDIF.
* verifica interlocutor comercial
  CLEAR: l_kunnr, l_parvw.
  SELECT kunnr parvw INTO (l_kunnr, l_parvw )
         FROM vbpa WHERE vbeln EQ vbrk-vbeln AND
                         parvw IN ('RE','RG').
    CASE l_parvw.
      WHEN 'RE'.
        MOVE l_kunnr TO l_kunnr_re.
      WHEN 'RG'.
        MOVE l_kunnr TO l_kunnr_rg.
    ENDCASE.
  ENDSELECT.
* si son distintos obtiene el RUT del interlocutor RG
  IF l_kunnr_re NE l_kunnr_rg.
    SELECT SINGLE stcd1 INTO wa_zcabpedext-zrut_cli_fact
         FROM kna1 WHERE kunnr EQ l_kunnr_re.
  ENDIF.

*-> BEG INS V1-CNN ECDK922573 Facturación el línea HELP
  DATA: ls_kna1 TYPE kna1.
  IF wa_zcabpedext-zrut_cli_fact IS INITIAL.
    SELECT SINGLE stcd1 name1 stras ort02
      INTO CORRESPONDING FIELDS OF ls_kna1
      FROM kna1 WHERE kunnr EQ l_kunnr_re.
    IF sy-subrc = 0.
      wa_zcabpedext-zrut_cli_fact  = ls_kna1-stcd1.
      wa_zcabpedext-znom_cli_fact  = ls_kna1-name1.
      wa_zcabpedext-zgiro_cli_fact = 'Otro giro'.
      wa_zcabpedext-zdir_fact      = ls_kna1-stras.
      wa_zcabpedext-zcomuna_fact   = ls_kna1-ort02.
      wa_zcabpedext-zciudad_fact   = ls_kna1-ort01.
    ENDIF.
  ENDIF.
*-> END INS V1-CNN ECDK922573 Facturación el línea HELP

  CASE vbrk-zblart.
    WHEN 'O3' OR 'O4'.   "BOLETA
* OBTIENE CODIGO DEL CLIENTE SEGUN EL RUT DEL RECEPTOR
      IF wa_zcabpedext-zrut_cli_fact IS INITIAL.
        SELECT SINGLE stcd1 INTO wa_zcabpedext-zrut_cli_fact
             FROM kna1 WHERE kunnr EQ l_kunnr_re.
      ELSE.
        SELECT SINGLE kunnr INTO l_kunnr_re
             FROM kna1 WHERE stcd1 EQ wa_zcabpedext-zrut_cli_fact.
      ENDIF.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          input  = l_kunnr_re
        IMPORTING
          output = l_kunnr_re.
* FECHA DESDE
      CONCATENATE sy-datum(4)   '-'
                  sy-datum+4(2) '-'
                  sy-datum+6(2) INTO l_fech_ini.
* FECHA HASTA
      CONCATENATE sy-datum(4)   '-'
                  sy-datum+4(2) '-'
                  sy-datum+6(2) INTO l_fech_fin.
* FECHA DE VENCIMIENTO
      IF wa_zcabpedext-fecventes IS NOT INITIAL.
        CONCATENATE wa_zcabpedext-fecventes(4)   '-'
                    wa_zcabpedext-fecventes+4(2) '-'
                    wa_zcabpedext-fecventes+6(2) INTO l_fecvente.
      ENDIF.
      CASE vbrk-zelectronico.
        WHEN '41'.  "Boleta Exenta
          CONCATENATE TEXT-b01                        "<BOLETA>
                       TEXT-003                       "<Encabezado>
                        TEXT-005                      "<IdDoc>
                          TEXT-007 vbrk-zelectronico TEXT-008
                          TEXT-009 h_niinv           TEXT-010
                          TEXT-011 str_fecha         TEXT-012
                          TEXT-b03 '3'               TEXT-b04
                          TEXT-b05 l_fech_ini        TEXT-b06
                          TEXT-b07 l_fech_fin        TEXT-b08
                          TEXT-b09 l_fecvente        TEXT-b10
                        TEXT-006                      "</IdDoc>
                        TEXT-013                      "<Emisor>
                          TEXT-015 adrc-sort1            TEXT-016
                          TEXT-017 adrc-name1 adrc-name2 TEXT-018
                          TEXT-019 adrc-name3 adrc-name4 TEXT-020
                          TEXT-021 adrc-sort2            TEXT-022
                          TEXT-023 adrc-street           TEXT-024
                          TEXT-025 adrc-city2            TEXT-026
                          TEXT-027 adrc-city1            TEXT-028
                        TEXT-014                      "</Emisor>
                        TEXT-029                      "<Receptor>
                          TEXT-031 wa_zcabpedext-zrut_cli_fact  TEXT-032"ojo
                          TEXT-b11 l_kunnr_re                   TEXT-b12
                          TEXT-033 wa_zcabpedext-znom_cli_fact  TEXT-034
                          TEXT-037 wa_zcabpedext-zdir_fact      TEXT-038
                          TEXT-039 wa_zcabpedext-zcomuna_fact   TEXT-040
                          TEXT-041 wa_zcabpedext-zciudad_fact   TEXT-042
                        TEXT-030                      "</Receptor>
                        TEXT-043                      "<Totales>
*                          text-045 '0'       text-046
                          TEXT-047 s_mnt_tot TEXT-048
                          TEXT-051 s_mnt_tot TEXT-052
*                          text-b13 '0'       text-b14
                          TEXT-b15 s_mnt_tot TEXT-b16
*                          text-b17 '0'       text-b18
                          TEXT-b19 s_mnt_tot TEXT-b20
                        TEXT-044                      "</Totales>
                       TEXT-004                       " </Encabezado>
                       str_detalle
                       TEXT-077                       "<Adjuntos>
                         TEXT-079 str_tmstfirma TEXT-080
                       TEXT-078                       "</Adjuntos>
                      TEXT-b02                        "</BOLETA>
                 INTO str_dat.
        WHEN '39'. "Boleta
          CONCATENATE TEXT-b01                        "<BOLETA>
                       TEXT-003                       "<Encabezado>
                        TEXT-005                      "<IdDoc>
                          TEXT-007 vbrk-zelectronico TEXT-008
                          TEXT-009 h_niinv           TEXT-010
                          TEXT-011 str_fecha         TEXT-012
                          TEXT-b03 '3'               TEXT-b04
                          TEXT-b05 l_fech_ini        TEXT-b06
                          TEXT-b07 l_fech_fin        TEXT-b08
                          TEXT-b09 l_fecvente        TEXT-b10
                        TEXT-006                      "</IdDoc>
                        TEXT-013                      "<Emisor>
                          TEXT-015 adrc-sort1            TEXT-016
                          TEXT-017 adrc-name1 adrc-name2 TEXT-018
                          TEXT-019 adrc-name3 adrc-name4 TEXT-020
                          TEXT-021 adrc-sort2            TEXT-022
                          TEXT-023 adrc-street           TEXT-024
                          TEXT-025 adrc-city2            TEXT-026
                          TEXT-027 adrc-city1            TEXT-028
                        TEXT-014                      "</Emisor>
                        TEXT-029                      "<Receptor>
                          TEXT-031 wa_zcabpedext-zrut_cli_fact  TEXT-032"ojo
                          TEXT-b11 l_kunnr_re                   TEXT-b12
                          TEXT-033 wa_zcabpedext-znom_cli_fact  TEXT-034
                          TEXT-037 wa_zcabpedext-zdir_fact      TEXT-038
                          TEXT-039 wa_zcabpedext-zcomuna_fact   TEXT-040
                          TEXT-041 wa_zcabpedext-zciudad_fact   TEXT-042
                        TEXT-030                      "</Receptor>
                        TEXT-043                      "<Totales>
                          TEXT-045 s_mnt_net TEXT-046
                          TEXT-047 s_mnt_exe TEXT-048
                          TEXT-049 s_mnt_iva TEXT-050
                          TEXT-051 s_mnt_tot TEXT-052
*                          text-b13 '0'       text-b14
                          TEXT-b15 s_mnt_tot TEXT-b16
*                          text-b17 '0'       text-b18
                          TEXT-b19 s_mnt_tot TEXT-b20
                        TEXT-044                      "</Totales>
                       TEXT-004                       " </Encabezado>
                       str_detalle
                       TEXT-077                       "<Adjuntos>
                         TEXT-079 str_tmstfirma TEXT-080
                       TEXT-078                       "</Adjuntos>
                      TEXT-b02                        "</BOLETA>
                 INTO str_dat.
      ENDCASE.
    WHEN OTHERS.
      CONCATENATE TEXT-001                        "<Documento>
                   TEXT-003                       "<Encabezado>
                    TEXT-005                      "<IdDoc>
                      TEXT-007 vbrk-zelectronico TEXT-008
                      TEXT-009 h_niinv           TEXT-010
                      TEXT-011 str_fecha         TEXT-012
                    TEXT-006                      "</IdDoc>
                    TEXT-013                      "<Emisor>
                      TEXT-015 adrc-sort1            TEXT-016
                      TEXT-017 adrc-name1 adrc-name2 TEXT-018
                      TEXT-019 adrc-name3 adrc-name4 TEXT-020
                      TEXT-021 adrc-sort2            TEXT-022
                      TEXT-023 adrc-street           TEXT-024
                      TEXT-025 adrc-city2            TEXT-026
                      TEXT-027 adrc-city1            TEXT-028
                    TEXT-014                      "</Emisor>
                    TEXT-029                      "<Receptor>
                      TEXT-031 wa_zcabpedext-zrut_cli_fact  TEXT-032"ojo
                      TEXT-033 wa_zcabpedext-znom_cli_fact  TEXT-034
                      TEXT-035 wa_zcabpedext-zgiro_cli_fact TEXT-036
                      TEXT-037 wa_zcabpedext-zdir_fact      TEXT-038
                      TEXT-039 wa_zcabpedext-zcomuna_fact   TEXT-040
                      TEXT-041 wa_zcabpedext-zciudad_fact   TEXT-042
                    TEXT-030                      "</Receptor>
                    TEXT-043                      "<Totales>
                      TEXT-045 s_mnt_net TEXT-046
                      TEXT-047 s_mnt_exe TEXT-048
                      TEXT-049 s_mnt_iva TEXT-050
                      TEXT-051 s_mnt_tot TEXT-052
                    TEXT-044                      "</Totales>
                   TEXT-004                       " </Encabezado>
                   str_detalle
                   str_referencia
                   TEXT-077                       "<Adjuntos>
                     TEXT-079 str_tmstfirma TEXT-080
                   TEXT-078                       "</Adjuntos>
                  TEXT-002                        "</Documento>
             INTO str_dat.
  ENDCASE.
  REPLACE ALL OCCURRENCES OF 'á' IN str_dat WITH 'a'.
  REPLACE ALL OCCURRENCES OF 'é' IN str_dat WITH 'e'.
  REPLACE ALL OCCURRENCES OF 'í' IN str_dat WITH 'i'.
  REPLACE ALL OCCURRENCES OF 'ó' IN str_dat WITH 'o'.
  REPLACE ALL OCCURRENCES OF 'ú' IN str_dat WITH 'u'.
  REPLACE ALL OCCURRENCES OF 'Á' IN str_dat WITH 'A'.
  REPLACE ALL OCCURRENCES OF 'É' IN str_dat WITH 'E'.
  REPLACE ALL OCCURRENCES OF 'Í' IN str_dat WITH 'I'.
  REPLACE ALL OCCURRENCES OF 'Ó' IN str_dat WITH 'O'.
  REPLACE ALL OCCURRENCES OF 'Ú' IN str_dat WITH 'U'.
  REPLACE ALL OCCURRENCES OF 'Ñ' IN str_dat WITH 'N'.
  REPLACE ALL OCCURRENCES OF 'ñ' IN str_dat WITH 'n'.
  REPLACE ALL OCCURRENCES OF '&' IN str_dat WITH space.
  REPLACE ALL OCCURRENCES OF '¿' IN str_dat WITH space.

  TABLES zhostacepta.
  DATA file_name TYPE string.
*
  CLEAR file_name.
  CONCATENATE '/tmp/xml' h_niinv '.txt' INTO file_name.
  OPEN DATASET file_name FOR OUTPUT IN TEXT MODE ENCODING DEFAULT.
*
  TRANSFER str_dat TO file_name.
  CLOSE DATASET file_name.
*
  SELECT SINGLE * FROM zhostacepta WHERE sysid EQ sy-sysid.

  CLEAR path.
  CONCATENATE zhostacepta-host h_niinv '&comando='
              com_acc '&parametros=&datos=' str_dat
         INTO path.

* Checking if Path is SSL or not
  IF path(8) = 'https://' OR path(8) = 'HTTPS://'.
    scheme = 2.
    path = path+8(*).
  ELSEIF path(7) = 'http://' OR path(7) = 'HTTP://'.
    scheme = 1.
    path = path+7(*).
  ELSE.
    scheme = 1.
  ENDIF.
  IF path(30) CA ':'.
    off  = sy-fdpos.
    host = path+0(off).
    ADD 1 TO off.
    path  = path+off(*).
    IF path CA '/'.
      off  = sy-fdpos.
      port = path+0(off).
      path  = path+off(*).
    ENDIF.
  ELSE.
    IF path CA '/'.
      off  = sy-fdpos.
      host = path+0(off).
      path  = path+off(*).
    ELSE.
      host = path.
      path = '/'.
    ENDIF.
  ENDIF.

* Setting the port, 80 or 443 for SSL
  IF port IS INITIAL.
    IF scheme = 1.
      port = '80'.
    ELSE.
      port = '443'.
    ENDIF.
  ENDIF.

  IF path IS INITIAL.
    path = '/'.
  ENDIF.

* Create client object
  CALL METHOD cl_http_client=>create
    EXPORTING
      host    = host
      service = port
      scheme  = scheme
    IMPORTING
      client  = client.

  CALL METHOD client->request->set_method(
    if_http_request=>co_request_method_get ).

  client->request->set_version( if_http_request=>co_protocol_version_1_1
  ).

* Set request uri (/<path>[?<querystring>])
  cl_http_utility=>set_request_uri( request = client->request
                                    uri     = path ).
* Send and receive
  CALL METHOD client->send
    EXPORTING
      timeout                    = timeout
    EXCEPTIONS
      http_communication_failure = 1
      http_invalid_state         = 2
      http_processing_failed     = 3
      OTHERS                     = 4.

  IF sy-subrc <> 0.
    CALL METHOD client->get_last_error
      IMPORTING
        code    = subrc
        message = errortext.
    WRITE: / TEXT-095, "'Error de comunicación en el envío',
           / TEXT-096, "'Código: ',
             subrc,
             TEXT-097, "'Mensage: ',
             errortext.
    EXIT.
  ENDIF.

  CALL METHOD client->receive
    EXCEPTIONS
      http_communication_failure = 1
      http_invalid_state         = 2
      http_processing_failed     = 3
      OTHERS                     = 4.
* Did you get an error
*  rc = sy-subrc.
  IF sy-subrc = 0.
*    IMPORT numcore TO numcore FROM MEMORY ID 'ENVFACACEPTA_NUM'.
    SELECT SINGLE *  INTO wa_zcabpedext
      FROM zcabpedext
      WHERE znum_doc_core = wa_zcabpedext-znum_doc_core.
    client->response->get_status( IMPORTING code = http_rc ).

* display content
    IF binary IS INITIAL.
      content = client->response->get_cdata( ).
      FIND 'OK' IN content MATCH OFFSET off.
      IF sy-subrc = 0.
        CLEAR off.
        FIND 'http://' IN content MATCH OFFSET off.
        SELECT SINGLE * FROM vbrk INTO ls_vbrk WHERE vbeln = nast-objky.
        IF sy-subrc = 0.
          SELECT SINGLE * FROM bkpf WHERE bukrs = ls_vbrk-bukrs
                                      AND awtyp = c_vbrk
                                      AND awkey = ls_vbrk-vbeln.
          IF sy-subrc = 0.
***Inicio V1 10.07.2013***
            UPDATE zfac_anex SET zurl = content+off
                            WHERE bukrs = bkpf-bukrs
                              AND belnr = bkpf-belnr
                              AND gjahr = bkpf-gjahr.
*-> BEG INS V1-CNN ECDK922573 Facturación el línea HELP
            IF sy-subrc <> 0.
              DATA: ls_zfac_anex TYPE zfac_anex.
              ls_zfac_anex-bukrs = bkpf-bukrs.
              ls_zfac_anex-belnr = bkpf-belnr.
              ls_zfac_anex-gjahr = bkpf-gjahr.
              ls_zfac_anex-zurl  = content+off.
              INSERT zfac_anex FROM ls_zfac_anex.
            ENDIF.
*-> END INS V1-CNN ECDK922573 Facturación el línea HELP
            PERFORM update_doc USING bkpf-bukrs
                                     bkpf-belnr
                                     bkpf-gjahr
                                     h_niinv.

            wa_zcabpedext-fec_car   = sy-datlo.
            wa_zcabpedext-hor_car   = sy-timlo.
            wa_zcabpedext-error_e   = space.
            wa_zcabpedext-error     = space.
            wa_zcabpedext-log_error = space.
            UPDATE zcabpedext FROM wa_zcabpedext.

****Fin V1 10.07.2013***
            CLEAR gs_thead.
            CLEAR gs_lines.
            REFRESH t_lines.

            gs_thead-tdobject = 'VBBK'.
            gs_thead-tdname   = ls_vbrk-vbeln.
            gs_thead-tdid     = 'ZXML'.
            gs_thead-tdspras  = sy-langu.

            FREE t_lines.
            CLEAR l_str.
            l_str = strlen( str_dat ).
            CLEAR pos_str.
            WHILE l_str > 132.
              gs_lines-tdformat = '*'.
              gs_lines-tdline   = str_dat+pos_str(132).
              APPEND gs_lines TO t_lines.
              ADD 132 TO pos_str.
              SUBTRACT 132 FROM l_str.
            ENDWHILE.
            gs_lines-tdformat = '*'.
            gs_lines-tdline   = str_dat+pos_str.
            APPEND gs_lines TO t_lines.

            CALL FUNCTION 'SAVE_TEXT'
              EXPORTING
                header          = gs_thead
                savemode_direct = 'X'
              TABLES
                lines           = t_lines
              EXCEPTIONS
                id              = 1
                language        = 2
                name            = 3
                object          = 4
                OTHERS          = 5.
          ENDIF.
        ENDIF.

        txt_content = content.
        nast-vstat = '1'.
        syst-msgid = 'AM'.
        syst-msgno = '001'.
        syst-msgty = 'S'.
        syst-msgv1 = txt_content+000(50).
        syst-msgv2 = txt_content+050(50).
        syst-msgv3 = txt_content+100(50).
        syst-msgv4 = txt_content+150(50).

      ELSE.
        return_code = '4'.
        CLEAR l.
        l = strlen( content ).
        IF l < 200.
          WRITE content+00(l) TO txt_content.
        ELSE.
          WRITE content+00(200) TO txt_content.
        ENDIF.
        nast-vstat = '2'.
        syst-msgid = 'AM'.
        syst-msgno = '001'.
        syst-msgty = 'E'.
        syst-msgv1 = txt_content+000(50).
        syst-msgv2 = txt_content+050(50).
        syst-msgv3 = txt_content+100(50).
        syst-msgv4 = txt_content+150(50).
        wa_zcabpedext-fec_car   = sy-datlo.
        wa_zcabpedext-hor_car   = sy-timlo.
        wa_zcabpedext-error_e   = 'X'.
        CONCATENATE syst-msgv1 syst-msgv2 syst-msgv3 syst-msgv4 INTO
        wa_zcabpedext-log_error.
        UPDATE zcabpedext FROM wa_zcabpedext.
      ENDIF.
    ENDIF.
  ELSE.
    DATA: lv_mensaje TYPE string.
    CLEAR lv_mensaje.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO lv_mensaje.
    WRITE: / nast-objky, '-', lv_mensaje.

    return_code = '4'.
    nast-vstat = '2'.
    syst-msgid = 'AM'.
    syst-msgno = '001'.
    syst-msgty = 'E'.
    syst-msgv1 = TEXT-081. "Existió un error de comunicación con Acepta.
    syst-msgv2 = TEXT-082. "Por favor contactese con su administrador.'.
    syst-msgv3 = space.
    syst-msgv4 = space.
    SELECT SINGLE * INTO wa_zcabpedext
      FROM zcabpedext
      WHERE znum_doc_core EQ wa_zcabpedext-znum_doc_core.
    "numcore.
    wa_zcabpedext-fec_car   = sy-datlo.
    wa_zcabpedext-hor_car   = sy-timlo.
    wa_zcabpedext-error_e   = 'X'.
    CONCATENATE syst-msgv1 syst-msgv2 syst-msgv3 syst-msgv4 INTO
    wa_zcabpedext-log_error.
    UPDATE zcabpedext FROM wa_zcabpedext.
  ENDIF.

  CALL FUNCTION 'NAST_PROTOCOL_UPDATE'
    EXPORTING
      msg_arbgb = syst-msgid
      msg_nr    = syst-msgno
      msg_ty    = syst-msgty
      msg_v1    = syst-msgv1
      msg_v2    = syst-msgv2
      msg_v3    = syst-msgv3
      msg_v4    = syst-msgv4
    EXCEPTIONS
      OTHERS    = 0.
* Desbloqueo Tabla de Folio
  CALL FUNCTION 'DEQUEUE_EBOOKNO'
    EXPORTING
      mode_idcn_boma = 'E'
      mandt          = sy-mandt
      bukrs          = idcn_boma-bukrs
      lotno          = idcn_boma-lotno
      bokno          = idcn_boma-bokno.

  WAIT UP TO 1 SECONDS.
ENDFORM.                    " SEND_MSG_ELECTRONIC_ACEPTA
*&---------------------------------------------------------------------*
*&      Form  UPDATE_DOC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_BKPF_BUKRS  text
*      -->P_BKPF_BELNR  text
*      -->P_BKPF_GJAHR  text
*----------------------------------------------------------------------*
FORM update_doc  USING    p_bukrs
                          p_belnr
                          p_gjahr
                          p_xblnr.

  DATA: ti_bkpf TYPE TABLE OF bkpf,
        wa_bkpf TYPE bkpf,
        ti_bseg TYPE TABLE OF bseg,
        ti_bsec TYPE TABLE OF bsec,
        ti_bsed TYPE TABLE OF bsed,
        ti_bset TYPE TABLE OF bset,
        ti_bkdf TYPE TABLE OF bkdf.

  REFRESH: ti_bkpf, ti_bseg, ti_bsec, ti_bsed, ti_bkdf.

  SELECT SINGLE * INTO wa_bkpf
    FROM bkpf  WHERE bukrs EQ p_bukrs
                 AND belnr EQ p_belnr
                 AND gjahr EQ p_gjahr.

  IF sy-subrc EQ 0.
    wa_bkpf-xblnr = p_xblnr.
    APPEND wa_bkpf TO ti_bkpf.
  ENDIF.

  SELECT * INTO TABLE ti_bseg
    FROM bseg
    WHERE bukrs EQ p_bukrs
      AND belnr EQ p_belnr
      AND gjahr EQ p_gjahr.

  SELECT * INTO TABLE ti_bkdf
    FROM bkdf
    WHERE bukrs EQ p_bukrs
      AND belnr EQ p_belnr
      AND gjahr EQ p_gjahr.

  SELECT * INTO TABLE ti_bsec
   FROM bsec
    WHERE bukrs EQ p_bukrs
      AND belnr EQ p_belnr
      AND gjahr EQ p_gjahr.

  SELECT * INTO TABLE ti_bset
    FROM bset
    WHERE bukrs EQ p_bukrs
      AND belnr EQ p_belnr
      AND gjahr EQ p_gjahr.

  SELECT * INTO TABLE ti_bsed
    FROM bsed
    WHERE bukrs EQ p_bukrs
      AND belnr EQ p_belnr
      AND gjahr EQ p_gjahr.

  CALL FUNCTION 'CHANGE_DOCUMENT'
    TABLES
      t_bkdf = ti_bkdf
      t_bkpf = ti_bkpf
      t_bsec = ti_bsec
      t_bsed = ti_bsed
      t_bseg = ti_bseg
      t_bset = ti_bset.
ENDFORM.                    " UPDATE_DOC

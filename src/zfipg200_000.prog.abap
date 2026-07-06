*&---------------------------------------------------------------------*
*&  Include           ZFIPG002_000
*&---------------------------------------------------------------------*

START-OF-SELECTION.


  PERFORM proceso.

  CALL SCREEN 100.

END-OF-SELECTION.

*---------------------------------------------------------------------*
*       FORM PROCESO                                                  *
*---------------------------------------------------------------------*
FORM proceso.

  DATA: BEGIN OF p_blart OCCURS 10,
          sign   TYPE c LENGTH 1,
          option TYPE c LENGTH 2,
          low    LIKE bsik-blart,
          high   LIKE bsik-blart,
        END OF p_blart.

  DATA: BEGIN OF p_budat OCCURS 10,
          sign   TYPE c LENGTH 1,
          option TYPE c LENGTH 2,
          low    LIKE bsik-budat,
          high   LIKE bsik-budat,
        END OF p_budat.

  DATA: BEGIN OF p_zlsch OCCURS 10,
          sign   TYPE c LENGTH 1,
          option TYPE c LENGTH 2,
          low    LIKE bsik-zlsch,
          high   LIKE bsik-zlsch,
        END OF p_zlsch.


  DATA: BEGIN OF p_xref1 OCCURS 10,
          sign   TYPE c LENGTH 1,
          option TYPE c LENGTH 2,
          low    LIKE bsik-xref1,
          high   LIKE bsik-xref1,
        END OF p_xref1.

*  SELECT * FROM    zfipg001 WHERE bukrs  = bukrs.
*    p_blart-sign   = 'I'.
*    p_blart-option = 'EQ'.
*    p_blart-low    = zfipg001-blart.
*    CLEAR p_blart-high.
*    APPEND p_blart.
*  ENDSELECT.

  SELECT * FROM zfipg201 INTO CORRESPONDING FIELDS OF TABLE int_motban WHERE bukrs  = bukrs.

  SORT int_motban BY zzmot_emis bancop.

  IF NOT  budat IS INITIAL.
    p_budat-sign   = 'I'.
    p_budat-option = 'LE'.
    p_budat-low    = budat.
    CLEAR p_budat-high.
    APPEND p_budat.
  ENDIF.

  IF NOT  zlsch IS INITIAL.
    p_zlsch-sign   = 'I'.
    p_zlsch-option = 'EQ'.
    p_zlsch-low    = zlsch.
    CLEAR p_zlsch-high.
    APPEND p_zlsch.
  ENDIF.

  IF NOT  xref1 IS INITIAL.
    p_xref1-sign   = 'I'.
    p_xref1-option = 'EQ'.
    p_xref1-low    = xref1.
    CLEAR p_xref1-high.
    APPEND p_xref1.
  ENDIF.

  REFRESH tpago.
  CLEAR tpago.


  SELECT * FROM bsik WHERE bukrs = bukrs
    AND   budat IN p_budat
    AND   zfbdt IN p_zfbdt
    AND   zlsch IN p_zlsch
    AND   zzmot_emis  = p_xzzmot
    AND   hbkid =  p_hbkid
    AND   xref1 IN p_xref1.
*    AND   hbkid <> ''.

    CLEAR tpago.

    READ TABLE int_motban WITH KEY zzmot_emis  = bsik-zzmot_emis
                                   bancop       = bsik-hbkid.

    IF sy-subrc = 0.

      IF  bsik-zlspr  <> '' .
        IF  bsik-zlspr  <> 'Z'.
          MOVE-CORRESPONDING bsik TO tpago.
          tpago-wrbtr_r = tpago-wrbtr.
          CLEAR tpago-wrbtr.
          tpago-msg = 'Pago Bloqueado'.
          tpago-docto_r = 1.
          APPEND tpago.
        ENDIF.
        IF  bsik-zlspr  = 'Z'.
          MOVE-CORRESPONDING bsik TO tpago.
          tpago-wrbtr_na = tpago-wrbtr.
          CLEAR tpago-wrbtr.
          tpago-msg = 'Abono/FAC No Aplicado'.
          tpago-docto_na = 1.
          APPEND tpago.
        ENDIF.
      ELSE.
        SELECT SINGLE * FROM regus WHERE koart = 'K'
                                   AND   bukrs = bsik-bukrs
                                   AND   konko = bsik-lifnr.
        IF sy-subrc <> 0.
          MOVE-CORRESPONDING bsik TO tpago.
          tpago-docto = 1.
          APPEND tpago.
        ELSE.
          MOVE-CORRESPONDING bsik TO tpago.
          tpago-wrbtr_r = tpago-wrbtr.
          CLEAR tpago-wrbtr.
          tpago-docto_r = 1.
          CONCATENATE 'Acreedor se encuentra en propuesta:'  regus-laufd regus-laufi INTO tpago-msg SEPARATED BY space.
          APPEND tpago.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDSELECT.

  REFRESH int_tabla.
  CLEAR  int_tabla.

*** intervenir

  LOOP AT tpago.
    IF tpago-shkzg = 'S'.
      MULTIPLY tpago-wrbtr    BY -1.
      MULTIPLY tpago-wrbtr_r  BY -1.
      MULTIPLY tpago-wrbtr_na BY -1.
      MODIFY tpago FROM tpago
       TRANSPORTING wrbtr wrbtr_r wrbtr_na.
    ENDIF.
  ENDLOOP.

  SORT tpago BY zfbdt zzmot_emis hbkid zlsch lifnr.

  sw_p = 'S'.
*-- cilo de conteo docs por clte --*

  REFRESH docs_cltes.
  CLEAR docs_cltes.
  LOOP AT tpago.
    IF sw_p = 'S'.
      docs_cltes-zfbdt_dscs = tpago-zfbdt.
      docs_cltes-zzmot_emis_dscs = tpago-zzmot_emis.
      docs_cltes-hbkid_dscs = tpago-hbkid.
      docs_cltes-zlsch_dscs = tpago-zlsch.
      docs_cltes-lifnr_dscs = tpago-lifnr.
      docs_cltes-cantdocs = 0.
      sw_p = 'N'.
    ENDIF.

    IF tpago-zfbdt <> docs_cltes-zfbdt_dscs
    OR tpago-zzmot_emis <> docs_cltes-zzmot_emis_dscs
    OR tpago-hbkid <> docs_cltes-hbkid_dscs
    OR tpago-zlsch <> docs_cltes-zlsch_dscs
    OR tpago-lifnr <> docs_cltes-lifnr_dscs.
      APPEND docs_cltes.
      CLEAR docs_cltes.
      sw_p = 'S'.
    ENDIF.

    IF tpago-docto = 1.
      docs_cltes-cantdocs = docs_cltes-cantdocs + 1.
    ENDIF.
  ENDLOOP.

  APPEND docs_cltes.
  CLEAR docs_cltes.


  SORT docs_cltes BY zfbdt_dscs zzmot_emis_dscs hbkid_dscs zlsch_dscs lifnr_dscs.

  CLEAR : zzmot_emis_p , hbkid_p, lifnr_p.

  cregpro    = 0.
  cregban    = 0.
  wrbtr_p    = 0.
  wrbtr_r_p  = 0.
  wrbtr_na_p = 0.
  docto_p      = 0.
  docto_r_p    = 0.
  docto_na_p   = 0.
  wrbtr_tot = 0.
  npagos_tot = 0.

  sw_p = 'S'.

*-- cilo de agrupacion --*
  LOOP AT tpago.

    IF tpago-lifnr <> lifnr_p.
      IF tpago-docto = 1.

        READ TABLE docs_cltes WITH KEY zfbdt_dscs = tpago-zfbdt
                              zzmot_emis_dscs = tpago-zzmot_emis
                              hbkid_dscs = tpago-hbkid
                              zlsch_dscs = tpago-zlsch
                              lifnr_dscs = tpago-lifnr
                              BINARY SEARCH.
        cdocscltes = docs_cltes-cantdocs.
      ENDIF.
    ENDIF.

    reg_proc = cregpro + cdocscltes.

    IF tpago-zfbdt <> zfbdt_p
    OR tpago-zzmot_emis <> zzmot_emis_p
    OR tpago-hbkid <> hbkid_p
    OR tpago-zlsch <> zlsch_p
    OR reg_proc > int_motban-rmaxp
    OR cregban >= int_motban-rmaxb.

      IF  sw_p = 'S'.

        READ TABLE int_motban WITH KEY zzmot_emis  = tpago-zzmot_emis
                                       bancop      = tpago-hbkid.

        zfbdt_p = tpago-zfbdt.
        zzmot_emis_p = tpago-zzmot_emis.
        hbkid_p = tpago-hbkid.
        zlsch_p = tpago-zlsch.

        sw_p = 'N'.
      ELSE.
        SELECT SINGLE zzdescr INTO  int_tabla-descr
                              FROM  zmot_emis
                              WHERE bukrs = bukrs
                              AND   zzmot_emis  =  zzmot_emis_p.

        int_tabla-zlsch     = zlsch_p.
        int_tabla-docto     = docto_p.
*      IF tpago-wrbtr < 0.
*       MULTIPLY tpago-wrbtr BY -1.
*      ENDIF.
        int_tabla-zzmot_emis = zzmot_emis_p.
        int_tabla-monto     = wrbtr_p.
        int_tabla-docto_r   = docto_r_p.
        int_tabla-monto_r   = wrbtr_r_p.
        int_tabla-docto_na  = docto_na_p.
        int_tabla-monto_na  = wrbtr_na_p.
        int_tabla-fecha_v   = zfbdt_p.
        int_tabla-banco_pgo = hbkid_p.
        int_tabla-cli_dde   = lifnr_p_dde.
        int_tabla-cli_hta   = lifnr_p.
        int_tabla-reg_pro   = cregpro.
        int_tabla-reg_ban   = cregban.
        wrbtr_tot = wrbtr_tot + int_tabla-monto.
        npagos_tot =  npagos_tot + int_tabla-reg_ban.
        APPEND int_tabla.
        CLEAR int_tabla.
        cregpro    = 0.
        cregban    = 0.
        wrbtr_p    = 0.
        wrbtr_r_p  = 0.
        wrbtr_na_p = 0.
        docto_p      = 0.
        docto_r_p    = 0.
        docto_na_p   = 0.
        CLEAR lifnr_p.
        READ TABLE int_motban WITH KEY zzmot_emis  = tpago-zzmot_emis
                                       bancop      = tpago-hbkid.

      ENDIF.
    ENDIF.

    IF tpago-docto = 1.
      cregpro      = cregpro + 1.
    ENDIF.

    IF tpago-lifnr <> lifnr_p.
      IF tpago-docto = 1.
        cregban = cregban + 1.
        READ TABLE docs_cltes WITH KEY zfbdt_dscs = tpago-zfbdt
                              zzmot_emis_dscs = tpago-zzmot_emis
                              hbkid_dscs = tpago-hbkid
                              zlsch_dscs = tpago-zlsch
                              lifnr_dscs = tpago-lifnr
                              BINARY SEARCH.
        cdocscltes = docs_cltes-cantdocs.
      ENDIF.
      IF lifnr_p IS INITIAL.
        lifnr_p_dde = tpago-lifnr.
      ENDIF.
      lifnr_p = tpago-lifnr.
    ENDIF.


    zfbdt_p      = tpago-zfbdt.
    zzmot_emis_p = tpago-zzmot_emis.
    hbkid_p      = tpago-hbkid.
    zlsch_p      = tpago-zlsch.
    wrbtr_p      = tpago-wrbtr + wrbtr_p.
    wrbtr_r_p    = tpago-wrbtr_r + wrbtr_r_p.
    wrbtr_na_p   = tpago-wrbtr_na + wrbtr_na_p.
    docto_p      = docto_p + tpago-docto.
    docto_r_p    = docto_r_p + tpago-docto_r.
    docto_na_p   = docto_na_p + tpago-docto_na.
    lifnr_p      = tpago-lifnr.
  ENDLOOP.


  IF  sy-tabix > 0.
    SELECT SINGLE zzdescr INTO  int_tabla-descr
                              FROM  zmot_emis
                              WHERE bukrs = bukrs
                              AND   zzmot_emis  =  zzmot_emis_p.
    int_tabla-zlsch     = zlsch_p.
    int_tabla-docto     = docto_p.
*      IF tpago-wrbtr < 0.
*       MULTIPLY tpago-wrbtr BY -1.
*      ENDIF.
    int_tabla-zzmot_emis = zzmot_emis_p.
    int_tabla-monto     = wrbtr_p.
    int_tabla-docto_r   = docto_r_p.
    int_tabla-monto_r   = wrbtr_r_p.
    int_tabla-docto_na  = docto_na_p.
    int_tabla-monto_na  = wrbtr_na_p.
    int_tabla-fecha_v   = zfbdt_p.
    int_tabla-banco_pgo = hbkid_p.
    int_tabla-cli_dde   = lifnr_p_dde.
    int_tabla-cli_hta   = lifnr_p.
    int_tabla-reg_pro   = cregpro.
    int_tabla-reg_ban   = cregban.
    wrbtr_tot = wrbtr_tot + int_tabla-monto.
    npagos_tot =  npagos_tot + int_tabla-reg_ban.
    APPEND int_tabla.
  ENDIF.

write wrbtr_tot to wrbtr_tot1 currency t001-waers.

  LOOP AT tpago.
    IF tpago-shkzg = 'S'.
      MULTIPLY tpago-wrbtr    BY -1.
      MULTIPLY tpago-wrbtr_r  BY -1.
      MULTIPLY tpago-wrbtr_na BY -1.
      MODIFY tpago FROM tpago
       TRANSPORTING wrbtr wrbtr_r wrbtr_na.
    ENDIF.
  ENDLOOP.

  DESCRIBE TABLE int_tabla LINES fill.
  SORT int_tabla BY fecha_v zzmot_emis zlsch.
  tabla-lines = fill.
  tabla-top_line = 1.
***** fin
ENDFORM.                    "PROCESO

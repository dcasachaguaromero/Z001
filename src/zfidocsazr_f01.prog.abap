*&---------------------------------------------------------------------*
*&  Include           ZFIDOCSAZR_F01
*&---------------------------------------------------------------------*
*
*&---------------------------------------------------------------------*
*&      Form  OBTENER_DOCTOS_SA
*&---------------------------------------------------------------------*
FORM OBTENER_DOCTOS_CON_SA.

  DATA: wa_augbl TYPE bseg-augbl.
  DATA: wa_augdt TYPE bseg-augdt.
  DATA: wa_bldat TYPE bkpf-bldat.
  DATA: wa_cpudt TYPE bkpf-cpudt.
  DATA: wa_blart TYPE bkpf-blart.
  DATA: wa_belnr TYPE bsas-belnr.
  DATA: wa_budat TYPE bsas-budat.

  AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
    ID 'BUKRS' FIELD so_bukrs-low.
  IF sy-subrc <> 0.
    MESSAGE e899(fi) WITH 'No esta autorizado para operar esta sociedad'.
  ENDIF.

*  SELECT bukrs, belnr, gjahr, UBHKT
  SELECT * into TABLE @data(ti_ZFI_DOC_ZPSAZR)
    FROM ZFI_DOC_ZPSAZR
    WHERE ZCOMPENS_ZP = ' ' AND
          BUKRS       in @so_bukrs.

  IF sy-subrc eq 0.
     LOOP at ti_ZFI_DOC_ZPSAZR INTO data(wa_tabla).
**** si esta compensado el documento ZP
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT single augbl augdt
*               into (wa_augbl, wa_augdt)
*               from BSEG where BUKRS = wa_tabla-bukrs and
*                               BELNR = wa_tabla-belnr and
*                               GJAHR = wa_tabla-gjahr and
*                               HKONT = wa_tabla-UBHKT.
*
* NEW CODE
        SELECT augbl augdt
        UP TO 1 ROWS 
               into (wa_augbl, wa_augdt)
               from BSEG where BUKRS = wa_tabla-bukrs and
                               BELNR = wa_tabla-belnr and
                               GJAHR = wa_tabla-gjahr and
                               HKONT = wa_tabla-UBHKT ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
        IF wa_augbl <> ' '.
** el documento esta compensado y buscar si es SA en BSAS
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*           SELECT single belnr budat
*               into (wa_belnr, wa_budat)
*               from BSAS where BUKRS = wa_tabla-bukrs and
*                               HKONT = wa_tabla-UBHKT and
*                               augdt = wa_augdt       and
*                               augbl = wa_augbl       and
*                               BLART = 'SA'.
*
* NEW CODE
           SELECT belnr budat
           UP TO 1 ROWS 
               into (wa_belnr, wa_budat)
               from BSAS where BUKRS = wa_tabla-bukrs and
                               HKONT = wa_tabla-UBHKT and
                               augdt = wa_augdt       and
                               augbl = wa_augbl       and
                               BLART = 'SA' ORDER BY PRIMARY KEY.

           ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
           IF sy-subrc = '0'.
** se encontro documento SA
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*              select single BLART BLDAT CPUDT
*                  into (wa_blart, wa_bldat, wa_cpudt)
*                  from BKPF where bukrs = wa_tabla-bukrs and
*                                  BELNR = wa_belnr       and
*                                  GJAHR = wa_budat+0(4).
*
* NEW CODE
              SELECT BLART BLDAT CPUDT
              UP TO 1 ROWS 
                  into (wa_blart, wa_bldat, wa_cpudt)
                  from BKPF where bukrs = wa_tabla-bukrs and
                                  BELNR = wa_belnr       and
                                  GJAHR = wa_budat+0(4) ORDER BY PRIMARY KEY.

              ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
              WA_tabla-ZCOMPENS_ZP = 'X'.
              wa_tabla-sa_blart    = wa_blart.
              WA_tabla-AUGDT       = wa_budat.
              WA_tabla-ZNDOC_SA    = wa_belnr.
              WA_tabla-ZEDOC_SA    = wa_budat+0(4).
              WA_tabla-ZFDOC_SA    = wa_cpudt.
              WA_tabla-ZFCDOC_SA   = wa_bldat.
              MODIFY ZFI_DOC_ZPSAZR FROM WA_tabla.
           ELSE.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*              SELECT single belnr budat
*               into (wa_belnr, wa_budat)
*               from BSAS where BUKRS =  wa_tabla-bukrs and
*                               HKONT <> wa_tabla-UBHKT and
*                               augdt =  wa_augdt       and
*                               augbl =  wa_augbl       and
*                               BLART = 'SA'.
*
* NEW CODE
              SELECT belnr budat
              UP TO 1 ROWS 
               into (wa_belnr, wa_budat)
               from BSAS where BUKRS =  wa_tabla-bukrs and
                               HKONT <> wa_tabla-UBHKT and
                               augdt =  wa_augdt       and
                               augbl =  wa_augbl       and
                               BLART = 'SA' ORDER BY PRIMARY KEY.

              ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
              IF sy-subrc = '0'.
** se encontro documento SA
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*                 select single BLART BLDAT CPUDT
*                     into (wa_blart, wa_bldat, wa_cpudt)
*                     from BKPF where bukrs = wa_tabla-bukrs and
*                                     BELNR = wa_belnr       and
*                                     GJAHR = wa_budat+0(4).
*
* NEW CODE
                 SELECT BLART BLDAT CPUDT
                 UP TO 1 ROWS 
                     into (wa_blart, wa_bldat, wa_cpudt)
                     from BKPF where bukrs = wa_tabla-bukrs and
                                     BELNR = wa_belnr       and
                                     GJAHR = wa_budat+0(4) ORDER BY PRIMARY KEY.

                 ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
                 WA_tabla-ZCOMPENS_ZP = 'X'.
                 wa_tabla-sa_blart    = wa_blart.
                 WA_tabla-AUGDT       = wa_budat.
                 WA_tabla-ZNDOC_SA    = wa_belnr.
                 WA_tabla-ZEDOC_SA    = wa_budat+0(4).
                 WA_tabla-ZFDOC_SA    = wa_cpudt.
                 WA_tabla-ZFCDOC_SA   = wa_bldat.
                 MODIFY ZFI_DOC_ZPSAZR FROM WA_tabla.
              endif.
           ENDIF.
        ENDIF.
     ENDLOOP.
*    MESSAGE i899(fi) WITH 'Registros ZP a procesados'.
*  ELSE.
*    MESSAGE i899(fi) WITH 'NO hay registros ZP a procesar'.
  ENDIF.
ENDFORM.                    " OBTENER_DOCTOS_CON_SA

*&---------------------------------------------------------------------*
*&      Form  OBTENER_DOCTOS_ZR
*&---------------------------------------------------------------------*
FORM OBTENER_DOCTOS_CON_ZR.

  DATA: wa_augbl TYPE bseg-augbl.
  DATA: wa_augdt TYPE bseg-augdt.
  DATA: wa_bldat TYPE bkpf-bldat.
  DATA: wa_cpudt TYPE bkpf-cpudt.
  DATA: wa_blart TYPE bkpf-blart.
  DATA: wa_belnr TYPE bsas-belnr.
  DATA: wa_budat TYPE bsas-budat.

*  SELECT bukrs, belnr, gjahr, UBHKT
  SELECT * into TABLE @data(ti_ZFI_DOC_ZPSAZR)
    FROM ZFI_DOC_ZPSAZR
    WHERE ZCOMPENS_ZP = 'X' AND
          ZCOMPENS_SA = ' ' AND
          BUKRS       in @so_bukrs.

  IF sy-subrc eq 0.
     LOOP at ti_ZFI_DOC_ZPSAZR INTO data(wa_tabla).
**** si esta compensado el documento SA
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT single augbl augdt
*               into (wa_augbl, wa_augdt)
*               from BSEG where BUKRS = wa_tabla-bukrs    and
*                               BELNR = wa_tabla-zndoc_sa and
*                               GJAHR = wa_tabla-zedoc_sa and
*                               HKONT <> wa_tabla-UBHKT   and
*                               BSCHL = '50'.
*
* NEW CODE
        SELECT augbl augdt
        UP TO 1 ROWS 
               into (wa_augbl, wa_augdt)
               from BSEG where BUKRS = wa_tabla-bukrs    and
                               BELNR = wa_tabla-zndoc_sa and
                               GJAHR = wa_tabla-zedoc_sa and
                               HKONT <> wa_tabla-UBHKT   and
                               BSCHL = '50' ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
        IF wa_augbl <> ' '.
** se encontro documento ZR
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*           select single BLART BLDAT CPUDT
*                  into (wa_blart, wa_bldat, wa_cpudt)
*                  from BKPF where bukrs = wa_tabla-bukrs and
*                                  BELNR = wa_augbl       and
*                                  GJAHR = wa_augdt+0(4)  and
*                                  BLART = 'ZR'.
*
* NEW CODE
           SELECT BLART BLDAT CPUDT
           UP TO 1 ROWS 
                  into (wa_blart, wa_bldat, wa_cpudt)
                  from BKPF where bukrs = wa_tabla-bukrs and
                                  BELNR = wa_augbl       and
                                  GJAHR = wa_augdt+0(4)  and
                                  BLART = 'ZR' ORDER BY PRIMARY KEY.

           ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
           IF sy-subrc = '0'.
              WA_tabla-ZCOMPENS_SA   = 'X'..
              wa_tabla-zr_blart      = wa_blart.
              WA_tabla-ZFCOMDOC_SAZR = wa_augdt.
              WA_tabla-ZNDOC_ZR      = wa_augbl.
              WA_tabla-ZEDOC_ZR      = wa_augdt+0(4).
              WA_tabla-ZFDOC_ZR      = wa_bldat.
              WA_tabla-ZFCDOC_ZR     = wa_cpudt.
              MODIFY ZFI_DOC_ZPSAZR FROM WA_tabla.
           ELSE.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*              SELECT single belnr budat
*               into (wa_belnr, wa_budat)
*               from BSAS where BUKRS =  wa_tabla-bukrs and
*                               augdt =  wa_augdt       and
*                               augbl =  wa_augbl       and
*                               BLART = 'ZR'.
*
* NEW CODE
              SELECT belnr budat
              UP TO 1 ROWS 
               into (wa_belnr, wa_budat)
               from BSAS where BUKRS =  wa_tabla-bukrs and
                               augdt =  wa_augdt       and
                               augbl =  wa_augbl       and
                               BLART = 'ZR' ORDER BY PRIMARY KEY.

              ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
              IF sy-subrc = '0'.
** se encontro documento ZR
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*                 select single BLART BLDAT CPUDT
*                     into (wa_blart, wa_bldat, wa_cpudt)
*                     from BKPF where bukrs = wa_tabla-bukrs and
*                                     BELNR = wa_belnr       and
*                                     GJAHR = wa_budat+0(4).
*
* NEW CODE
                 SELECT BLART BLDAT CPUDT
                 UP TO 1 ROWS 
                     into (wa_blart, wa_bldat, wa_cpudt)
                     from BKPF where bukrs = wa_tabla-bukrs and
                                     BELNR = wa_belnr       and
                                     GJAHR = wa_budat+0(4) ORDER BY PRIMARY KEY.

                 ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
                 WA_tabla-ZCOMPENS_SA   = 'X'..
                 wa_tabla-zr_blart      = wa_blart.
                 WA_tabla-ZFCOMDOC_SAZR = wa_augdt.
                 WA_tabla-ZNDOC_ZR      = wa_belnr.
                 WA_tabla-ZEDOC_ZR      = wa_budat+0(4).
                 WA_tabla-ZFDOC_ZR      = wa_bldat.
                 WA_tabla-ZFCDOC_ZR     = wa_cpudt.
                 MODIFY ZFI_DOC_ZPSAZR FROM WA_tabla.
              ENDIF.
           ENDIF.
        ENDIF.
      ENDLOOP.
*      MESSAGE i899(fi) WITH 'Registros SA a procesados'.
*  ELSE.
*    MESSAGE i899(fi) WITH 'NO hay registros SA a procesar'.
  ENDIF.
ENDFORM.                    " OBTENER_DOCTOS_CON_ZR

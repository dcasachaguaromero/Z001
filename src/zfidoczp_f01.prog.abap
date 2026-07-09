*&---------------------------------------------------------------------*
*&  Include           ZFIDOCZP_F01
*&---------------------------------------------------------------------*
*
*&---------------------------------------------------------------------*
*&      Form  OBTENER_DOCTOS_ZP
*&---------------------------------------------------------------------*
FORM OBTENER_DOCTOS_ZP.

  AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
    ID 'BUKRS' FIELD so_bukrs-low.
  IF sy-subrc <> 0.
    MESSAGE e899(fi) WITH 'No esta autorizado para operar esta sociedad'.
  ENDIF.

  SELECT bukrs, belnr, gjahr, blart, cpudt, budat, bktxt
         into TABLE @data(ti_bkpf)
    FROM bkpf
    WHERE bukrs in @so_bukrs and
          blart =  @c_zp     and
          CPUDT in @so_CPUDT and
          STGRD = ' '.

  IF sy-subrc eq 0.
     LOOP at ti_bkpf into data(wa_bkpf).
          MOVE-CORRESPONDING wa_bkpf to wa_tabla.
          move WA_BKPF-BLART         to wa_tabla-ZP_BLART.
          move wa_tabla-bktxt+0(08)  to wa_tabla-LAUFD.
          move wa_tabla-bktxt+9(06)  to wa_tabla-LAUFI.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*          SELECT single  lifnr IDENTIF_PAGO UBHKT HBKID HKTID
*                 INTO   (wa_tabla-lifnr, wa_tabla-IDENTIF_PAGO, wa_tabla-UBHKT,
*                         wa_tabla-HBKID, wa_tabla-HKTID)
*                 from REGUH where LAUFD = wa_tabla-LAUFD and
*                                  LAUFI = wa_tabla-LAUFI and
*                                  XVORL = c_XVORL        and
*                                  VBLNR = wa_tabla-belnr.
*
* NEW CODE
          SELECT lifnr IDENTIF_PAGO UBHKT HBKID HKTID
          UP TO 1 ROWS 
                 INTO   (wa_tabla-lifnr, wa_tabla-IDENTIF_PAGO, wa_tabla-UBHKT,
                         wa_tabla-HBKID, wa_tabla-HKTID)
                 from REGUH where LAUFD = wa_tabla-LAUFD and
                                  LAUFI = wa_tabla-LAUFI and
                                  XVORL = c_XVORL        and
                                  VBLNR = wa_tabla-belnr ORDER BY PRIMARY KEY.

          ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

          APPEND wa_tabla to ti_tabla.

     endloop.
     modify ZFI_DOC_ZPSAZR FROM TABLE TI_TABLA.
*    MESSAGE i899(fi) WITH 'Registros ZP procesados'.
*  else.
*     MESSAGE i899(fi) WITH 'NO hay registros ZP a procesar'.
  endif.
*
ENDFORM.                    " OBTENER_DOCTOS_ZP

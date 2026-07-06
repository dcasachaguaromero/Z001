FUNCTION ZFI_CONSULTAS_PAGOS.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     VALUE(BUKRS) TYPE  BUKRS
*"     VALUE(RUT) TYPE  STCD1
*"     VALUE(DOCUMENTO) TYPE  XBLNR1
*"     VALUE(FECHADOC) TYPE  BLDAT
*"  EXPORTING
*"     VALUE(ESTADO) TYPE  CHAR01
*"     VALUE(MENSAJE) TYPE  CHAR70
*"  TABLES
*"      DETALLE STRUCTURE  ZFI_CONSULTA_PAGO2
*"----------------------------------------------------------------------
tables:BSIK,
       BSAK,
       BSIP,
       reguh,
       regup,
       payr,
       bkpf.
  DATA: lifnr LIKE vf_kred-lifnr,
        XBELNR LIKE bsip-BELNR.
  CLEAR: detalle.


  DATA: bsip_p type standard table of bsip with header line.
  REFRESH: detalle.
  SELECT SINGLE lifnr INTO lifnr FROM vf_kred
                                 WHERE  bukrs = bukrs
                                 AND    stcd1 = rut.
  IF sy-subrc <> 0.
    estado = 'E'.
    CONCATENATE 'Rut No Registrado como proveedor para sociedad' bukrs INTO mensaje SEPARATED BY space.
  ELSE.

* Se agrega query para obtener numero de documento contable no nulo
    SELECT * INTO CORRESPONDING FIELDS OF TABLE  bsip_p
      FROM bsip
      INNER JOIN bkpf
      ON   bkpf~gjahr = bsip~gjahr
      AND  bkpf~belnr = bsip~belnr
      AND  bkpf~bukrs = bsip~bukrs
      AND  bkpf~stblg EQ space
      WHERE bsip~bukrs  = bukrs
      AND   bsip~lifnr  = lifnr
      AND   bsip~waers  = 'CLP'
      AND   bsip~bldat   = fechadoc
      AND   bsip~xblnr  = documento
      and   bsip~SHKZG  = 'H'.

      LOOP AT bsip_p.
          XBELNR = bsip_p-BELNR.
      ENDLOOP.
* Genero el query con numero contable que no tienen anulacion asociada XBELNR
       SELECT SINGLE * FROM bsip
        WHERE bukrs  = bukrs
        AND   lifnr  = lifnr
        AND   waers  = 'CLP'
        AND   bldat   = fechadoc
      AND   xblnr     = documento
         and BELNR  = XBELNR
      and   SHKZG  = 'H'.

    IF sy-subrc <> 0.
      estado = 'E'.
      mensaje =  'Documento no contabilizado para pago'.
    ELSE.
      SELECT SINGLE * FROM bsik WHERE lifnr = lifnr
                                AND bukrs   =  bukrs
                                AND gjahr   =  bsip-gjahr
                                AND belnr   =  bsip-belnr
                                AND buzei   =  bsip-buzei
                                AND xstov   = ''.

      IF sy-subrc = 0.
        estado = 'P'.
        mensaje =  'Documento Contabilizado Pendiente de Pago'.
        MOVE-CORRESPONDING bsik TO detalle.
      ELSE.
        SELECT SINGLE * FROM bsak WHERE  bukrs =  bukrs
                          AND belnr =  bsip-belnr
                          AND gjahr =  bsip-gjahr
                          AND buzei =  bsip-buzei
                          AND xstov = ''.
        IF sy-subrc <> 0.
          estado = 'E'.
          mensaje =  'Documento registrado pero sin contabilizacion'.
        ELSE.
          MOVE-CORRESPONDING bsak TO detalle.
          SELECT SINGLE * FROM  reguh WHERE zbukr = bsak-bukrs
                                      AND   vblnr = bsak-augbl
                                      AND   zaldt = bsak-augdt.
          IF sy-subrc <> 0.
            estado = 'P'.
            mensaje =  'Documento Contabilizado Pagado. Sin propuesta de pago'.
          ELSE.
            MOVE-CORRESPONDING  reguh  TO detalle.
            IF reguh-rzawe = 'C'.
              SELECT SINGLE * FROM payr WHERE zbukr = bsak-bukrs
                                        AND   vblnr = bsak-augbl
                                        AND   gjahr = bsak-gjahr.
              IF sy-subrc <> 0.
                estado = 'P'.
                mensaje =  'Documento Pagado con Cheque. Sin cheque emitido'.
              ELSE.
                MOVE-CORRESPONDING  payr  TO detalle.

                IF payr-xbanc = 'X'.
                  estado = 'P'.
                  mensaje =  'Documento Pagado con Cheque. Cheque ya cobrado'.
                ELSE.
                  estado = 'P'.
                  mensaje =  'Documento Pagado con Cheque. Cheque pendiente de cobro'.
                ENDIF.
              ENDIF.
            ELSE.
              IF reguh-rzawe  = 'T'.
                estado = 'P'.
                mensaje =  'Documento Pagado via transferencia bancaria '.
              ELSEIF reguh-rzawe  = 'V'.
                estado = 'P'.
                mensaje =  'Documento Pagado via vale vista '.
              ELSE.
                estado = 'P'.
                mensaje =  'Documento Pagado via otros medios'.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
      APPEND detalle.
    ENDIF.
  ENDIF.





ENDFUNCTION.

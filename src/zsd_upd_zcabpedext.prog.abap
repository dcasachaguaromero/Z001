*&---------------------------------------------------------------------*
*& Report  ZSD_UPD_ZCABPEDEXT
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT  zsd_upd_zcabpedext.

TABLES: zcabpedext.

SELECT-OPTIONS: s_nucore   FOR zcabpedext-znum_doc_core,
                s_zblart   FOR zcabpedext-zblart,
                s_pedido   FOR zcabpedext-pedido.

START-OF-SELECTION.

  UPDATE zcabpedext
    SET pedido     = ''
        factura    = ''
        error      = ''
        error_e    = ''
        log_error  = ''
    WHERE znum_doc_core IN s_nucore  AND
          zblart        IN s_zblart  AND
          pedido        IN s_pedido.

  MESSAGE i899(m3) WITH 'Proceso finalizado'.

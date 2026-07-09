*&---------------------------------------------------------------------*
*&  Include           ZFIMDP001_TOP
*&---------------------------------------------------------------------*
DATA: BEGIN OF t2_bsis OCCURS 0,
    bukrs TYPE bsis-bukrs,
    hkont TYPE bsis-hkont,
    belnr TYPE bsis-belnr,
    gjahr TYPE bsis-gjahr,
    buzei TYPE bsis-buzei,
    bldat TYPE bsis-bldat,
    wrbtr TYPE bsis-wrbtr,
END OF t2_bsis.

DATA: BEGIN OF t2_bsas OCCURS 0,
    bukrs TYPE bsas-bukrs,
    hkont TYPE bsas-hkont,
    augbl TYPE bsas-augbl,
    belnr TYPE bsas-belnr,
    gjahr TYPE bsas-gjahr,
END OF t2_bsas.

DATA: BEGIN OF t_payr OCCURS 0,
    zbukr TYPE payr-zbukr,
    hbkid TYPE payr-hbkid,
    hktid TYPE payr-hktid,
    chect TYPE payr-chect,
    lifnr TYPE payr-lifnr,
    vblnr TYPE payr-vblnr,
END OF t_payr.

TYPES: BEGIN OF t_jdatos ,
    bukrs  TYPE bukrs,
    hbkid  TYPE hbkid,
    hktid  TYPE hktid,
    chect  TYPE chect,
    jdatos TYPE APQ_GRPN,
    lote   TYPE zjdatos_edocheq-lote,
END OF t_jdatos.

TYPES: BEGIN OF t_jdsecu,
  jdatos TYPE APQ_GRPN,
  secuencia TYPE zjdatos_secuen-secuencia,
  bukrs  TYPE bukrs,
  hbkid  TYPE hbkid,
  hktid  TYPE hktid,
  chect  TYPE chect,
END OF t_jdsecu.

TYPES: BEGIN OF t_lfa1,
  lifnr  TYPE lfa1-lifnr,
  sortl  TYPE lfa1-sortl,
END OF t_lfa1.

TYPES: BEGIN OF t_bkpf,
  bukrs TYPE bkpf-bukrs,
  belnr TYPE bkpf-belnr,
  gjahr TYPE bkpf-gjahr,
  budat TYPE bkpf-budat,
  xblnr TYPE bkpf-xblnr,
END OF t_bkpf.


DATA: GT_JDATOS TYPE TABLE OF T_JDATOS,
      GW_JDATOS TYPE          T_JDATOS.
DATA: GT_SECUEN TYPE TABLE OF t_jdsecu,
      GW_SECUEN TYPE          t_jdsecu.
DATA: GT_LFA1   TYPE TABLE OF t_lfa1,
      GW_LFA1   TYPE          t_lfa1.
DATA: GT_BKPF   TYPE TABLE OF t_bkpf,
      GW_BKPF   TYPE          t_bkpf.

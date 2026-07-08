*&---------------------------------------------------------------------*
*&  Include           ZFI_INR_01_INC
*&---------------------------------------------------------------------*

DATA: BEGIN OF t_alv OCCURS 0 ,
       bukrs      LIKE bkpf-bukrs     ,
       belnr      LIKE bkpf-belnr     ,
       blart      LIKE bkpf-blart     ,
       gjahr      LIKE bkpf-gjahr     ,
       dmbtr      LIKE bseg-dmbtr     ,
       sakto      LIKE mseg-sakto     ,
       kostl      LIKE bseg-kostl     ,
       shkzg      LIKE bseg-shkzg     ,
       zzunid_pro LIKE mseg-zzunid_pro,
       iva        LIKE bseg-dmbtr     ,
       iva_nr     LIKE bseg-dmbtr     ,
       rut_terc   LIKE mseg-zzrut_terc,
       referencia LIKE bkpf-xblnr     ,
       doc_fac    LIKE bkpf-belnr     ,
       tip_fac    LIKE bkpf-blart     ,
       budat      LIKE bkpf-budat     ,
      END OF t_alv.

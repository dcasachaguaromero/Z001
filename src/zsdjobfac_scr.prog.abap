*&---------------------------------------------------------------------*
*&  Include           ZSDJOBFAC_SCR
*&---------------------------------------------------------------------*
SELECT-OPTIONS   so_n_cor FOR  zcabpedext-znum_doc_core.
SELECT-OPTIONS   so_blart FOR  zstr_mon_fac-zblart.
PARAMETERS       p_monat  LIKE bkpf-monat.
SELECT-OPTIONS   so_fp    FOR  zcabpedext-fecventes.
SELECT-OPTIONS   so_via   FOR  zstr_mon_fac-zlsch.
SELECT-OPTIONS   so_f_c   FOR  zcabpedext-fec_car.
SELECT-OPTIONS   so_h_c   FOR  zcabpedext-hor_car.
PARAMETERS       p_spr    TYPE c.
PARAMETERS       p_error  TYPE c.
PARAMETERS       p_err_e  TYPE c.
PARAMETERS       p_elec   TYPE ztdea-dea NO-DISPLAY.

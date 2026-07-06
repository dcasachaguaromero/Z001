*&---------------------------------------------------------------------*
*&  Include           ZFIPG002_TOP
*&---------------------------------------------------------------------*
TABLES: zfipg002_cab,
        zfipg002_det,
        zfipg003,
        zfipg003_est,
        zfipg003_a_est,
        t001,
        reguh ,
        reguv,
        zfirmadigital,
        zfirma_digital,
        t042z,
        zfimotemisan.

DATA: resp(01),
      band         TYPE c,
      soc_pago(04).

DATA: BEGIN OF int_tabla  OCCURS 1.
        INCLUDE STRUCTURE zfipg003_est.
      DATA  END OF int_tabla.


DATA : BEGIN OF texcel  OCCURS 1,
         descr(50),
         estado(10),
         listopara(50),
         laufi(50),
         laufd(50),
         hbkid(50),
         zfbdt(50),
         xzzmot_emis(50),
         monto(50),
         nchequ(50),
         ult_remesa(50),
         tot_remesa(50),
         nchequ_s(50),
         nhojas(50),
         msg(50),
       END OF  texcel.

DATA : BEGIN OF int_tabla1  OCCURS 1.
         INCLUDE STRUCTURE zfipg003_a_est.
       DATA   END OF int_tabla1.

** Modificado por L_FOUBERT 05.07.2013 Defin. Estr. REGUH
TYPES: BEGIN OF t_reguh,
         xvorl TYPE reguh-xvorl,
         vblnr TYPE reguh-vblnr,
         rbetr TYPE reguh-rbetr,
         zbukr TYPE reguh-zbukr,
       END OF t_reguh.
DATA: gw_reguh TYPE t_reguh.
** END Modificació por L_FOUBERT 05.07.2013 Defin. Estr. REGUH

DATA: fill(4)       TYPE n,
      swerror(01)   TYPE n,
      swprimera(01) TYPE n,
      sw_ok(01),
      accion(01),
      titulo(40),
      ws_land       TYPE land1,
      resto(3)      TYPE n.

DATA ti_pcec LIKE STANDARD TABLE OF pcec WITH HEADER LINE.
DATA ln_pcec TYPE i.

* Tablas Dynpro
CONTROLS: tabla  TYPE TABLEVIEW USING SCREEN 150.

CONTROLS: tabla1 TYPE TABLEVIEW USING SCREEN 250.

DATA cols  LIKE LINE OF tabla-cols.

DATA : BEGIN OF tab OCCURS 0,
         fcode LIKE rsmpe-func,
       END OF tab.

DATA : itab TYPE TABLE OF bdcmsgcoll WITH HEADER LINE.

DATA: nfirma1(70) TYPE c,
      dir_org1    TYPE rlgrap-filename,
      dir_des1    TYPE rlgrap-filename,
      pass1(25)   TYPE c.
DATA: nfirma2(70) TYPE c,
      dir_org2    TYPE rlgrap-filename,
      dir_des2    TYPE rlgrap-filename,
      pass2(25)   TYPE c,
      v_detalle   TYPE ztipodetalle.

DATA: ti_firma     TYPE STANDARD TABLE OF zfirmadigital WITH HEADER LINE,
      firma1       TYPE zfirmadigital,
      firma2       TYPE zfirmadigital,
      okcode       TYPE sy-ucomm,
      pasword1     TYPE char50,
      pasword2     TYPE char50,
      estado1(10)  TYPE c,
      estado2(10)  TYPE c,
      source       TYPE char50,
      destination  TYPE char50,
      pwd          TYPE char50,
      tdname_001   TYPE bdcdata-fval,
      filename_004 TYPE bdcdata-fval,
      tdname_005   TYPE bdcdata-fval,
      tdname_008   TYPE bdcdata-fval,
      messtab      TYPE STANDARD TABLE OF bdcmsgcoll WITH HEADER LINE,
      rfcdest      TYPE rfcdes-rfcdest,
      v_fecha      LIKE reguh-laufd,
      v_nomina     LIKE f110v-laufi,
      v_fecpag     LIKE reguh-laufd,
      v_resfon     TYPE zresfon,
      v_numche(10) TYPE n,
      v_archivo    LIKE rlgrap-filename,
      archivo      LIKE rlgrap-filename,
      par_tes      TYPE c,
      v_bankl      LIKE t012-bankl.

DATA : gv_waers    TYPE waers,
       gv_linsel   TYPE sytabix.   "V1-CNN ECDK925124 22.05.2024

*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES04 > *
*& Description: < ReSQ Correction > *
*& Date: <24-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Modulpool         ZFITR013
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

PROGRAM  zfitr035.

TABLES: t001,
        reguh,
        t042z,
        lfa1,
        *lfa1,
        zfitr035_est,
        zfitr035_est1,
        zfitr035_est2,
        zagencia,
        regup,
        bseg,
        t012t,
        bkpf,
        zctarechazo,
        lfb1.

* Tablas Dynpro
CONTROLS: tabla   TYPE TABLEVIEW USING SCREEN 100.

* Tablas Dynpro
CONTROLS: tabla2  TYPE TABLEVIEW USING SCREEN 100.

CONTROLS: tabla3  TYPE TABLEVIEW USING SCREEN 300.

DATA : BEGIN OF tab OCCURS 0,
         fcode LIKE rsmpe-func,
       END OF tab.

DATA cols  LIKE LINE OF tabla-cols.

DATA : BEGIN OF tage  OCCURS 0,
          bukrs          LIKE  zagencia-bukrs,
          zzcod_unidad   LIKE  zagencia-zzcod_unidad,
          zzdescr        LIKE  zagencia-zzdescr,
       END OF tage.

DATA : BEGIN OF tcuenta  OCCURS 0,
          bukrs          LIKE  zctarechazo-bukrs,
          rzawe          LIKE  zctarechazo-rzawe,
          hkont_orig     LIKE  zctarechazo-hkont_orig,
          rzawe_d        LIKE  zctarechazo-rzawe_d,
          hkont_dest     LIKE  zctarechazo-hkont_dest,
          hbkid_dest     LIKE  zctarechazo-hbkid_dest,
          hktid_dest     LIKE  zctarechazo-hktid_dest,
END OF tcuenta.

DATA : BEGIN OF tabla_trab  OCCURS 1.
        INCLUDE STRUCTURE zfitr035_est.
DATA  END OF tabla_trab.

DATA : BEGIN OF tabla_aux  OCCURS 1.
        INCLUDE STRUCTURE zfitr035_est.
DATA  END OF tabla_aux.

DATA : BEGIN OF int_tabla  OCCURS 1.
        INCLUDE STRUCTURE zfitr035_est.
DATA  END OF int_tabla.

DATA : BEGIN OF int_tabla2  OCCURS 1.
        INCLUDE STRUCTURE zfitr035_est1.
DATA  END OF int_tabla2.

DATA : BEGIN OF int_tabla2_aux  OCCURS 1.
        INCLUDE STRUCTURE zfitr035_est1.
DATA  END OF int_tabla2_aux.


DATA : BEGIN OF int_tabla3 OCCURS 1.
        INCLUDE STRUCTURE zfitr035_est2.
DATA  END OF int_tabla3.

DATA: monto_p       LIKE reguh-rbetr,
      canti_p(6) TYPE p DECIMALS 0,
      fill(4)       TYPE n,
      motivo_rechazo_gen(30),
      monto_i       LIKE reguh-rbetr,
      canti_i(6)    TYPE p DECIMALS 0,
      resp(01),
      salir(02).

DATA : BEGIN OF tabsrd  OCCURS 1,
       sociedad(4),
       fecha_registro TYPE date ,
       comprobante_rechazo(13),
       rut_afiliado(10),
       monto_pago(9) TYPE p DECIMALS 0,
       banco_pagado(6),
       via_pago(1),
       fecha_vencimiento TYPE date ,
       motivo_emision(15),
       agencia_origen(10) ,
       folio_documento(15),
       motivo_rechazo(30),
       motivo_tesoreria(10),
       usuario_responsable(10).
DATA  END OF tabsrd.

TYPE-POOLS: truxs.

TYPES: BEGIN OF type_excel,
         fecha(10)         TYPE c, "Codigo Banco
         rutemp(10)        TYPE c, "Codigo TD interno
         rsocial(50)       TYPE c, "Descripcion Tipo DOcumento Interno
         sociedad(04)      TYPE c, "Descripcion Tipo DOcumento Interno
         arch(20)          TYPE c, "Código TD del Banco
         emision(20)        TYPE c, "Código TD del Banco
         rutpr(10)         TYPE c, "Indicador FAC - NCR
         dvrutpr(1)        TYPE c, "Indicador FAC - NCR
         nombrepr(50)      TYPE c, "Descripcion Tipo DOcumento Interno
         cuenta(20)        TYPE c, "Descripcion Tipo DOcumento Interno
         valor(20)         TYPE c, "Descripcion Tipo DOcumento Interno
         motivo(50)        TYPE c, "Descripcion Tipo DOcumento Interno
         desbanco(50)         TYPE c, "Descripcion Tipo DOcumento
         banco(10)      TYPE c, "Descripcion Tipo DOcumento Interno
    END OF type_excel.

DATA: tl_exc TYPE STANDARD TABLE OF type_excel WITH HEADER LINE.

SELECTION-SCREEN BEGIN OF BLOCK marco1 WITH FRAME TITLE text-001.

PARAMETER : bukrs    LIKE bkpf-bukrs     VALUE CHECK  OBLIGATORY .

PARAMETER : v_hbkid LIKE  reguh-hbkid OBLIGATORY.

SELECT-OPTIONS : v_fecha  FOR reguh-valut OBLIGATORY.

PARAMETER  : rzawe LIKE  reguh-rzawe OBLIGATORY.

PARAMETER  : monto_r LIKE  reguh-rbetr OBLIGATORY.

PARAMETER  : archivo     TYPE rlgrap-filename DEFAULT 'C:\'.

SELECTION-SCREEN END OF BLOCK marco1 .

*---------------------------------------------------------------------------------
AT SELECTION-SCREEN ON VALUE-REQUEST FOR archivo.
  CONSTANTS: c_ext_exl   TYPE string     VALUE '*.XLS'.

  DATA: lt_filetable TYPE filetable,
        lx_filetable TYPE file_table,
        wl_sel_text  TYPE string,
        lv_rc TYPE i.

  CLEAR archivo.

  wl_sel_text = text-s01.

  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    EXPORTING
      window_title            = wl_sel_text
      default_extension       = c_ext_exl
    CHANGING
      file_table              = lt_filetable
      rc                      = lv_rc
    EXCEPTIONS
      file_open_dialog_failed = 1
      cntl_error              = 2
      error_no_gui            = 3
      not_supported_by_gui    = 4
      OTHERS                  = 5.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
*Begin of change: ReSQ Correction INDEX READ on an unsorted Internal TABLE 24/12/2019 EY_DES04 ECDK917080 *
SORT LT_FILETABLE .
*End of change: ReSQ Correction for INDEX READ on an unsorted Internal TABLE 24/12/2019 EY_DES04 ECDK917080 *
    READ TABLE lt_filetable INTO lx_filetable INDEX 1.
    CHECK sy-subrc EQ 0.
    archivo = lx_filetable-filename.
  ENDIF.

AT SELECTION-SCREEN ON bukrs.

  AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
     ID 'BUKRS' FIELD bukrs.

  IF sy-subrc <> 0.
    MESSAGE e526(icc_tr) WITH bukrs.
  ENDIF.

  SELECT SINGLE * FROM t001 WHERE bukrs = bukrs.


AT SELECTION-SCREEN ON rzawe.

  SELECT SINGLE * FROM t042z WHERE land1 = 'CL'
                             AND   zlsch = rzawe.
  IF sy-subrc <> 0.
    MESSAGE e001(z1) WITH 'Medio de Pago no Existe' rzawe.
  ENDIF.

*  IF rzawe = 'C'.
*
*    MESSAGE e016(z1) WITH 'Medio de Pago debe ser distinto de cheque' .
*  ENDIF.

AT SELECTION-SCREEN ON v_hbkid.

  SELECT SINGLE * FROM t012t WHERE spras = sy-langu
                             AND   bukrs = bukrs
                             AND   hbkid = v_hbkid.

  IF sy-subrc <> 0.
    MESSAGE e016(z1) WITH 'Banco no existe ' .
  ENDIF.

INITIALIZATION.
  t001-waers = 'CLP'.



START-OF-SELECTION.


  PERFORM cargo_planilla.

  SELECT *  FROM zagencia INTO CORRESPONDING FIELDS OF TABLE tage.
  SELECT *  FROM zctarechazo INTO CORRESPONDING FIELDS OF TABLE tcuenta
                             WHERE bukrs = bukrs
                             AND rzawe_d <> ''.

  SORT tage    BY  bukrs  zzcod_unidad.
  SORT tcuenta BY bukrs rzawe hkont_orig rzawe_d.


  CLEAR:   monto_p,   canti_p,
           monto_i,   canti_i.

  REFRESH: int_tabla, int_tabla2.
  PERFORM carga_tabla.
  CALL SCREEN 100.


END-OF-SELECTION.


*&---------------------------------------------------------------------*
*&      Form  cargo_planilla
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM cargo_planilla.
  DATA: it_raw TYPE truxs_t_text_data.

  REFRESH:  tl_exc.

  CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
    EXPORTING
*     I_FIELD_SEPERATOR    =
*     i_line_header        = 'X'
      i_tab_raw_data       = it_raw       " WORK TABLE
      i_filename           = archivo
    TABLES
      i_tab_converted_data = tl_exc[]    "ACTUAL DATA
    EXCEPTIONS
      conversion_failed    = 1
      OTHERS               = 2.

  IF ( sy-subrc <> 0 ).
    MESSAGE 'Error al cargar planilla' TYPE 'I' DISPLAY LIKE 'E'.
  ELSE.
    DELETE  tl_exc INDEX 1.                    "eliminar la cabecera
  ENDIF.

ENDFORM.                    "cargo_planilla

INCLUDE zbatchinput.

INCLUDE zfitr035_100.

INCLUDE zfitr035_200.

INCLUDE zfitr035_300.

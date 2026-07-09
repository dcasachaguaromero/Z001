*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES04 > *
*& Description: < ReSQ Correction > *
*& Date: <24-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Report  ZFITR0050
*&---------------------------------------------------------------------
*&  Compañía   : Banmedica
*&  Autor      : Crystalis Consulting Chile - Pablo Cabezas Melendez
*&  Funcional  : Crystalis Consulting Chile - Oscar Agudelo Prado
*&  Fecha      : 30.08.2013
*&  Objetivo   : Solución integral de pagos
*&--------------------------------------------------------------------
* Proceso: 1003 CAMBIO - NUEVO PAGO
* Proceso: 1010 REVALIDAC CHEQUE MT
* Proceso: 1011 REEMISION CHEQ MT
*--------------------------------------------------------------------*
* Pestaña: CAMBIO PAGO POR CHEQUE
* Pestaña: CAMBIO PAGO POR COMPROBANTE
*--------------------------------------------------------------------*
REPORT  ZFITR0050.

TYPE-POOLS: slis.

tables: bsad, bsid, ZFITR020_T05, payr, bseg, t100.
**********************************************************************
*     tabla  ALV de salida.
**********************************************************************
TYPES: BEGIN OF out,
       flag         TYPE c,                  "Flag para ejecutar la funcion
       BUKRS        like bsis-BUKRS,         "Sociedad
       HKONT        like bsis-HKONT,         "Cuenta de mayor de la contabilidad principal
       zuonr        like bsis-zuonr,         "Número de asignación
       GJaHR        like bsis-GJaHR,         "Ejercicio
       BELNR        like bsis-BELNR,         "Número de un documento contable
       BUZEI        like bsis-BUZEI,         "Número del apunte contable dentro del documento contable
       BUDAT        like bsis-BUDAT,         "Fecha de contabilización en el documento
       bldat        like bsis-bldat,         "Fecha de documento en documento
       blart        like bsis-blart,         "Clase de documento
       SHKZG        like bsis-SHKZG,         "Indicador debe/haber
       WRBTR        like bsis-WRBTR,         "Importe en la moneda del documento
       WAERS        like bsis-WAERS,         "Clave de moneda
       HBKID        like ZFITR020_T05-hbkid, "Clave breve para banco propio
       HKTID        like ZFITR020_T05-HKTID, "type n LENGTH 5 ,        "Clave breve para un banco/cuenta
       CHECT        like payr-chect,         "Nº de cheque
       hkontd       like bseg-hkont,         "Cuenta de mayor de la contabilidad principal(cta destino)
       lifnr        like bseg-lifnr,         "Número de cuenta del proveedor o acreedor
       zlsch        like bseg-ZLSCH,         "Vía de pago
       field_style  TYPE lvc_t_styl,         "FOR DISABLE cell
       ESTADO       type c LENGTH 10,        "segun la cuenta de mayor: emitido, revalidado, caduco,etc.
       ZZMOT_EMIS   like bseg-ZZMOT_EMIS,    "Motivos de emisión
       multi        type c,
      END OF out.

DATA: itab   TYPE TABLE OF out WITH HEADER LINE.
DATA: t_itab TYPE TABLE OF out WITH HEADER LINE.
************************************************************************
*             Tablas Internas                                          *
************************************************************************
TYPES: BEGIN OF ty_bsis,
        BUKRS like bsis-BUKRS, "Sociedad
        HKONT like bsis-HKONT, "Cuenta de mayor de la contabilidad principal
        zuonr like bsis-zuonr, "Número de asignación
        GJaHR like bsis-GJaHR, "Ejercicio
        BELNR like bsis-BELNR, "Número de un documento contable
        BUZEI like bsis-BUZEI, "Número del apunte contable dentro del documento contable
        BUDAT like bsis-BUDAT, "Fecha de contabilización en el documento
        bldat like bsis-bldat, "Fecha de documento en documento
        blart like bsis-blart, "Clase de documento
        SHKZG like bsis-SHKZG, "Indicador debe/haber
        WRBTR like bsis-WRBTR, "Importe en la moneda del documento
        WAERS like bsis-WAERS, "Clave de moneda
        marca type c,
        belnr_orig like bsis-BELNR,
        gjahr_orig like bsis-GJaHR,
       END OF ty_bsis.

DATA: ti_bsis TYPE TABLE OF ty_bsis,
      wa_bsis LIKE LINE OF ti_bsis.

TYPES: BEGIN OF ty_ZFITR020_T05,
        BUKRS       like bsis-BUKRS              , "Sociedad
        CTA_SALDO   like ZFITR020_T05-CTA_SALDO  , "Cuenta de mayor
        CTA_DEPOS   like ZFITR020_T05-CTA_DEPOS  , "Cuenta de mayor
        CTA_CHEQS   like ZFITR020_T05-CTA_CHEQS  , "Cuenta de mayor
        CTA_CARGOS  like ZFITR020_T05-CTA_CARGOS , "Cuenta de mayor
        CTA_ABONOS  like ZFITR020_T05-CTA_ABONOS , "Cuenta de mayor
        CTA_TRANS   like ZFITR020_T05-CTA_TRANS  , "Cuenta de mayor
        CTA_CDCO_F  like ZFITR020_T05-CTA_CDCO_F , "Cuenta de mayor
        CTA_CDCO_E  like ZFITR020_T05-CTA_CDCO_E , "Cuenta de mayor
        CTA_CDCO_F2 like ZFITR020_T05-CTA_CDCO_F2, "Cuenta de mayor
        REVALIDAD   like ZFITR020_T05-REVALIDAD  , "Cuenta de mayor
        HBKID     like ZFITR020_T05-HBKID        , "Clave breve para banco propio
        HKTID     like ZFITR020_T05-HKTID        , "Clave breve para un banco/cuenta
       END OF ty_ZFITR020_T05.

DATA: ti_ZFITR020_T05 TYPE TABLE OF ty_ZFITR020_T05,
      wa_ZFITR020_T05 LIKE LINE OF ti_ZFITR020_T05.

TYPES: BEGIN OF ty_bseg,
        bukrs       like bsas-BUKRS     , "Sociedad
        belnr       like bsas-belnr     , "Número de un documento contable
        gjahr       like bseg-GJaHR     , "Ejercicio
        lifnr       like bseg-lifnr     , "Número de cuenta del proveedor o acreedor
        hkont       like bseg-HKONT     , "Cuenta de mayor de la contabilidad principal
        ZLSCH       like bseg-ZLSCH     , "Vía de pago
        ZZMOT_EMIS  like bseg-ZZMOT_EMIS, "Motivos de emisión
        chect       like payr-chect     , "Nº de cheque
       END OF ty_bseg.

DATA: ti_bseg TYPE TABLE OF ty_bseg,
      wa_bseg LIKE LINE OF ti_bseg.

TYPES: BEGIN OF ty_payr,
        ZBUKR       like payr-ZBUKR, "Sociedad pagadora
        VBLNR       like payr-VBLNR, "Número del documento de pago
        GJAHR       like payr-GJAHR, "Ejercicio
        chect       like payr-chect, "Nº de cheque
        HBKID       like payr-HBKID, "Clave breve para banco propio
        HKTID       like payr-HKTID, "Clave breve para un banco/cuenta
        RZAWE       like payr-RZAWE, "Vía de pago
        UBHKT       like payr-UBHKT, "Nº de cta.mayor para nuestra cta.bancaria / cta.transitoria
        ZALDT       like payr-ZALDT, "Fecha de pago prevista (vencimiento 1)
        RWBTR       like payr-RWBTR, "Importe pagado en la moneda del pago
        WAERS       like payr-WAERS, "Clave de moneda
        multi_kunnr like bsik-lifnr,
        multi_lifnr like bsid-kunnr,
        multi_bukrs like bvor-bukrs,
        multi_belnr like bvor-belnr,
        multi_gjahr like bvor-gjahr,
       END OF ty_payr.

DATA: ti_payr TYPE TABLE OF ty_payr,
      wa_payr LIKE LINE OF ti_payr.

TYPES: BEGIN OF ty_bkpf,
        bukrs like bkpf-BUKRS,
        belnr like bkpf-belnr,
        gjahr like bkpf-GJaHR,
        bvorg like bkpf-bvorg,
        multi_kunnr like bsik-lifnr,
        multi_lifnr like bsid-kunnr,
        multi_bukrs like bvor-bukrs,
        multi_belnr like bvor-belnr,
        multi_gjahr like bvor-gjahr,
        ingre_bukrs like bkpf-BUKRS,
        ingre_belnr like bkpf-belnr,
        ingre_gjahr like bkpf-GJaHR,
       END OF ty_bkpf.

DATA: ti_bkpf TYPE TABLE OF ty_bkpf,
      wa_bkpf LIKE LINE OF ti_bkpf.

TYPES: BEGIN OF ty_bse,
        BUKRS_CLR like bse_clr-BUKRS_CLR, "Sociedad
        BELNR_CLR like bse_clr-BELNR_CLR, "Número de un documento contable
        GJAHR_CLR like bse_clr-GJAHR_CLR, "Ejercicio
        belnr     like bse_clr-belnr    , "Número de un documento contable
        bukrs     like bse_clr-BUKRS    , "Sociedad
        gjahr     like bse_clr-GJaHR    , "Ejercicio
        agzei     like bse_clr-agzei    , "Posición de compensación
        buzei     like bse_clr-BUZEI    , "Número del apunte contable dentro del documento contable
        END OF ty_bse.

DATA: ti_bse TYPE TABLE OF ty_bse,
      wa_bse LIKE LINE OF ti_bse.

types: begin of ty_return,                    "tabla de retorno de mensaje de la funcion
        bukrs      like bsas-BUKRS          , "segundo alv de salida
        belnr      like bsas-BELNR          ,
        gjahr      like bsas-GJaHR          ,
        chect      like payr-CHECT          ,
        TYPE       like bapiret2-TYPE       ,
        ID         like bapiret2-ID         ,
        NUMBER     like bapiret2-NUMBER     ,
        MESSAGE_V1 like bapiret2-MESSAGE_V1 ,
        MESSAGE_V2 like bapiret2-MESSAGE_V2 ,
        MESSAGE_V3 like bapiret2-MESSAGE_V3 ,
        MESSAGE_V4 like bapiret2-MESSAGE_V4 ,
        MESSAGE    type c LENGTH 150        ,
        MESSAGE2   type c LENGTH 150        ,
    end of ty_return.

data: ti_return         TYPE TABLE OF ty_return WITH HEADER LINE.
************************************************************************
*     Estructura de parámetros:   ALV
************************************************************************
DATA: it_fieldcat   TYPE lvc_t_fcat,
      wa_fieldcat   TYPE lvc_s_fcat,
      gd_tab_group  TYPE slis_t_sp_group_alv,
      gd_layout     TYPE lvc_s_layo,
      gd_repid      LIKE sy-repid.

data: REF_GRID      TYPE REF TO CL_GUI_ALV_GRID.
*--------------------------------------------------------------------*
*   variables para funcion
*--------------------------------------------------------------------*
data: tabname       type c length 4.
data: l_clase_doc   type blart.
data: l_nom_proceso type string.
data: l_texto       type string.
data: l_cta_contrap type hkont.
data: l_fecha       type BUdat.

data: l_t_blntab  type blntab  occurs 0 with header line.
data: l_t_ftpost  type ftpost  occurs 0 with header line.
data: l_t_ftclear type ftclear occurs 0 with header line.
data: l_t_fttax   type fttax   occurs 0 with header line.

data: l_group     like apqi-groupid,
      l_tproceso  type c length 5.

data l_ver_batch  type c.
data c_fipi_trans_compensacion    like sy-tcode value 'FB05'.
*--------------------------------------------------------------------*
*   variables batchinput
*--------------------------------------------------------------------*
DATA: bdcdata TYPE STANDARD TABLE OF bdcdata WITH HEADER LINE.
DATA: messtab TYPE STANDARD TABLE OF bdcmsgcoll WITH HEADER LINE.
data: w_mode value 'N'.
*--------------------------------------------------------------------*
*   Primera pestaña: CAMBIO PAGO POR CHEQUE
*--------------------------------------------------------------------*
selection-screen begin of screen 101 as subscreen.
selection-screen begin of block b1 with frame title text-t00.
PARAMETERS       :   p_bukrs1   like payr-ZBUKR memory id buk.
PARAMETERS       :   p_hbkid1   like payr-hbkid
                   , p_hktid1   like payr-hktid  .
PARAMETERS       :   p_budat1   like BSAD-budat DEFAULT sy-datum.
SELECT-OPTIONS   :   p_chect1  FOR payr-chect no INTERVALS.
selection-screen end of block b1.
selection-screen end of screen 101.
*--------------------------------------------------------------------*
*   Segunda pestaña: CAMBIO PAGO POR COMPROBANTE
*--------------------------------------------------------------------*
selection-screen begin of screen 102 as subscreen.
selection-screen begin of block b2 with frame title text-t03.
PARAMETERS       :   p_bukrs2   like payr-ZBUKR memory id buk
                   , p_hbkid2   like payr-hbkid
                   , p_hktid2   like payr-hktid  ..
PARAMETERS       :   p_budat2   like BSAD-budat DEFAULT sy-datum.
SELECT-OPTIONS   :   p_belnr2   FOR BSAD-BELNR no INTERVALS.
PARAMETERS       :   p_gjahr2   like BSAD-gjahr.
selection-screen end of block b2.
selection-screen end of screen 102.
*--------------------------------------------------------------------*

selection-screen begin of tabbed block t1 for 20 lines.
selection-screen tab (30) name1 user-command ucomm1 default screen 101.
selection-screen tab (30) name2 user-command ucomm2 default screen 102.
selection-screen end of block t1.

AT SELECTION-SCREEN.
  "determino el tab que se ejecuto el programa y lo asigno a la variable
  "tabname para hacer procesos de busquedas distintos
  CASE sy-dynnr.
    WHEN 1000.
      CASE sy-ucomm.
        WHEN 'UCOMM1'.  tabname = 101.
        WHEN 'UCOMM2'.  tabname = 102.
      ENDCASE.
  ENDCASE.

INITIALIZATION.
  name1 = 'CAMBIO PAGO POR CHEQUE'.
  name2 = 'CAMBIO PAGO POR COMPROBANTE'.

*------------------------------------------------------------------------------
* Comienzo de Programa
*------------------------------------------------------------------------------
START-OF-SELECTION.
  "dependiendo del tab que venga se realizan busquedas distintas las cuales
  "tienen un unico alv de salida
*--------------------------------------------------------------------*
*   CAMBIO PAGO POR CHEQUE
*--------------------------------------------------------------------*
  if tabname eq '101' or tabname is INITIAL.
    if p_bukrs1 is INITIAL.
      MESSAGE 'El campo sociedad no puede estar vacio' type 'E'.
    endif.
    PERFORM selecciona.
    PERFORM crea_alv.
*--------------------------------------------------------------------*
*   CAMBIO PAGO POR COMPROBANTE
*--------------------------------------------------------------------*
  elseif tabname eq '102'.
    if p_bukrs2 is INITIAL.
      MESSAGE 'El campo sociedad no puede estar vacio' type 'E'.
    endif.
    PERFORM selecciona2.
    PERFORM crea_alv2.
  endif.

  PERFORM alv_report.

*&---------------------------------------------------------------------*
*&      Form  ALV_REPORT
*&---------------------------------------------------------------------*
*   Se llenan las estructuras necesarias del ALV principal
*--------------------------------------------------------------------*
FORM alv_report .
  PERFORM set_specific_field_attributes.
  PERFORM alv_ini_fieldcat.
  PERFORM layout_build .
  PERFORM alv_listado.
ENDFORM.                    " ALV_REPORT
*&---------------------------------------------------------------------*
*&      Form  ALV_INI_FIELDCAT
*&---------------------------------------------------------------------*
*     "catalogo de salida ALV principal
*--------------------------------------------------------------------*
FORM alv_ini_fieldcat .

  wa_fieldcat-fieldname = 'FLAG'.
  wa_fieldcat-scrtext_m = 'Flag'.
  wa_fieldcat-edit = 'X'.
  wa_fieldcat-checkbox = 'X'.
  wa_fieldcat-outputlen = 1.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR  wa_fieldcat.
*BUKRS
  wa_fieldcat-fieldname = 'BUKRS'.
  wa_fieldcat-scrtext_m = 'Sociedad'.
  wa_fieldcat-outputlen = 4.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR  wa_fieldcat.
**HKONT
  wa_fieldcat-fieldname = 'HKONT'.
  wa_fieldcat-scrtext_m = 'Libro Mayor'.
  wa_fieldcat-outputlen = 10.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR  wa_fieldcat.
**GJaHR
  wa_fieldcat-fieldname = 'GJAHR'.
  wa_fieldcat-scrtext_m = 'Periodo'.
  wa_fieldcat-outputlen = 4.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR  wa_fieldcat.
*  bsis-zuonr.
  wa_fieldcat-fieldname = 'ZUONR'.
  wa_fieldcat-scrtext_m = 'Asignacion'.
  wa_fieldcat-outputlen = 18.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR  wa_fieldcat.
*BELNR
  wa_fieldcat-fieldname = 'BELNR'.
  wa_fieldcat-scrtext_m = 'Nº documento'.
  wa_fieldcat-outputlen = 10.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR  wa_fieldcat.
*BUZEI
  wa_fieldcat-fieldname = 'BUZEI'.
  wa_fieldcat-scrtext_m = 'Posición'.
  wa_fieldcat-outputlen = 3.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR  wa_fieldcat.
*BUDAT
  wa_fieldcat-fieldname = 'BUDAT'.
  wa_fieldcat-scrtext_m = 'Fecha contab.'.
  wa_fieldcat-outputlen = 10.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR  wa_fieldcat.
*  bsis-BLDAT
  wa_fieldcat-fieldname = 'BLDAT'.
  wa_fieldcat-scrtext_m = 'Fecha doc.'.
  wa_fieldcat-outputlen = 10.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR  wa_fieldcat.
*  bsis-BLART
  wa_fieldcat-fieldname = 'BLART'.
  wa_fieldcat-scrtext_m = 'Clase doc.'.
  wa_fieldcat-outputlen = 2.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR  wa_fieldcat.
*SHKZG
  wa_fieldcat-fieldname = 'SHKZG'.
  wa_fieldcat-scrtext_m = 'Debe/Haber'.
  wa_fieldcat-outputlen = 1.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR  wa_fieldcat.
*WRBTR
  wa_fieldcat-fieldname = 'WRBTR'.
  wa_fieldcat-scrtext_m = 'Importe'.
  wa_fieldcat-do_sum     = 'X'.
  wa_fieldcat-tabname    = 'ITAB'.
  wa_fieldcat-cfieldname  = 'WAERS'.
  wa_fieldcat-outputlen = 15.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR  wa_fieldcat.
*WAERS
  wa_fieldcat-fieldname = 'WAERS'.
  wa_fieldcat-scrtext_m = 'Moneda'.
  wa_fieldcat-outputlen = 5.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR  wa_fieldcat.
*ZZMOT_EMIS
  wa_fieldcat-fieldname = 'ZZMOT_EMIS'.
  wa_fieldcat-scrtext_m = 'Emisión'.
  wa_fieldcat-outputlen = 10.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR  wa_fieldcat.
*HBKID
  wa_fieldcat-fieldname = 'HBKID'.
  wa_fieldcat-scrtext_m = 'Banco propio'.
  wa_fieldcat-outputlen = 5.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR  wa_fieldcat.
*HKTID
  wa_fieldcat-fieldname = 'HKTID'.
  wa_fieldcat-scrtext_m = 'ID.cuenta'.
  wa_fieldcat-lzero = 'X'.
  wa_fieldcat-outputlen = 5.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR  wa_fieldcat.
*CHECT
  wa_fieldcat-fieldname = 'CHECT'.
  wa_fieldcat-scrtext_m = 'Nº cheque'.
  wa_fieldcat-outputlen = 13.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR  wa_fieldcat.

  wa_fieldcat-fieldname = 'HKONTD'.
  wa_fieldcat-scrtext_m = 'Cta. Destino'.
  wa_fieldcat-outputlen = 10.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR  wa_fieldcat.

  wa_fieldcat-fieldname = 'LIFNR'.
  wa_fieldcat-scrtext_m = 'Acreedor'.
  wa_fieldcat-outputlen = 10.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR  wa_fieldcat.

  wa_fieldcat-fieldname = 'ZLSCH'.
  wa_fieldcat-scrtext_m = 'Vía pago'.
  wa_fieldcat-outputlen = 1.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR  wa_fieldcat.

  wa_fieldcat-fieldname = 'ESTADO'.
  wa_fieldcat-scrtext_m = 'ESTAD.ACT'.
  wa_fieldcat-outputlen = 10.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR  wa_fieldcat.

  wa_fieldcat-fieldname = 'MULTI'.
  wa_fieldcat-scrtext_m = 'Multi Soc.'.
  wa_fieldcat-outputlen = 1.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR  wa_fieldcat.

  DATA: nfilas(5) TYPE c.
  DATA: nfilas1 TYPE i.
  DESCRIBE TABLE itab LINES  nfilas1.
  MOVE nfilas1 TO nfilas.
  DATA: vl_texto(25) TYPE c.
  CONCATENATE 'Número de filas' nfilas INTO vl_texto SEPARATED BY space.
  MESSAGE vl_texto TYPE 'S'.
*--------------------------------------------------------------------*
* Ejemplo catalogo.
*--------------------------------------------------------------------*
* CLEAR alv_git_fieldcat.
*  alv_git_fieldcat-fieldname = 'MATNR'.
*  alv_git_fieldcat-seltext_s = 'Material'.
*  alv_git_fieldcat-seltext_m = 'Material'.
*  alv_git_fieldcat-seltext_l = 'Material'.
*  alv_git_fieldcat-outputlen = 18.
*  alv_git_fieldcat-ref_fieldname = 'MATNR'.
*  alv_git_fieldcat-ref_tabname   = 'MARA'.
*  alv_git_fieldcat-edit_mask = '==ALPHA'. "conversion_exit_alpha_output
  "  APPEND alv_git_fieldcat TO alv_git_fieldcat.

  "  CLEAR alv_git_fieldcat.
  "  alv_git_fieldcat-fieldname = 'FKIMG'.
  "  alv_git_fieldcat-seltext_s = 'Ctd.fact.'.
  "  alv_git_fieldcat-seltext_m = 'Ctd.facturada'.
  "  alv_git_fieldcat-seltext_l = 'Cantidad facturada'.
  "  alv_git_fieldcat-just        = 'R'.
  "  alv_git_fieldcat-qtabname    = 'ITAB'.
  "  alv_git_fieldcat-qfieldname  = 'VRKME'.
  "  alv_git_fieldcat-outputlen = 13.
  "  APPEND alv_git_fieldcat TO alv_git_fieldcat.

  "  CLEAR alv_git_fieldcat.
  "  alv_git_fieldcat-fieldname   = 'NETWR'.
  "  alv_git_fieldcat-seltext_s   = 'Valor neto'.
  "  alv_git_fieldcat-seltext_m   = 'Valor neto'.
  "  alv_git_fieldcat-seltext_l   = 'Valor neto'.
  "  alv_git_fieldcat-just        = 'R'.
  "  alv_git_fieldcat-ctabname    = 'ITAB'.
  "  alv_git_fieldcat-cfieldname  = 'WAERK'.
  " alv_git_fieldcat-outputlen   = 18.
  "  APPEND alv_git_fieldcat TO alv_git_fieldcat.

  "  CLEAR alv_git_fieldcat.
  "  alv_git_fieldcat-fieldname = 'WAERK'.
  "  alv_git_fieldcat-seltext_s = 'Moneda'.
  "  alv_git_fieldcat-seltext_m = 'Moneda doc.'.
  "  alv_git_fieldcat-seltext_l = 'Moneda del documento'.
  "  alv_git_fieldcat-outputlen = 5.
  "  APPEND alv_git_fieldcat TO alv_git_fieldcat.

ENDFORM.                    " ALV_INI_FIELDCAT
*&---------------------------------------------------------------------*
*&      Form  LAYOUT_BUILD
*&---------------------------------------------------------------------*
*   Layout alv principal
*--------------------------------------------------------------------*
FORM layout_build ." USING    u_lf_layout TYPE slis_layout_alv.
*  * Set layout field for field attributes(i.e. input/output)
  gd_layout-stylefname = 'FIELD_STYLE'.
  gd_layout-zebra      = 'X'.
  gd_layout-CWIDTH_OPT = 'X'. "optimizacion del tamaño de las columnas

ENDFORM.                    " LAYOUT_BUILD
*&---------------------------------------------------------------------*
*&      Form  ALV_LISTADO
*&---------------------------------------------------------------------*
*     Despliega el alv principal
*--------------------------------------------------------------------*
FORM alv_listado .

  gd_repid = sy-repid.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY_LVC'
    EXPORTING
      i_callback_program       = gd_repid
      i_callback_pf_status_set = 'FRM_PF_STATUS'
      i_callback_user_command  = 'USER_COMMAND'
      is_layout_lvc            = gd_layout
      it_fieldcat_lvc          = it_fieldcat
      i_save                   = 'X'
    TABLES
      t_outtab                 = itab
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
ENDFORM.                    " ALV_LISTAD
*&---------------------------------------------------------------------*
*&      Form  USER_COMMAND
*&---------------------------------------------------------------------*
*       User_command del alv principal
*----------------------------------------------------------------------*
FORM user_command USING r_ucomm LIKE sy-ucomm
                           rs_selfield TYPE slis_selfield.
  "marca el checkbox si fue seleccionado
  IF REF_GRID IS INITIAL.
    CALL FUNCTION 'GET_GLOBALS_FROM_SLVC_FULLSCR'
      IMPORTING
        E_GRID = REF_GRID.
  ENDIF.

  IF NOT REF_GRID IS INITIAL.
    CALL METHOD REF_GRID->CHECK_CHANGED_DATA.
  endif.

  CASE r_ucomm.
    WHEN 'PICK' OR '&IC1'."click sobre el alv
      IF rs_selfield-fieldname = 'BELNR'.
        READ TABLE itab with key BELNR = rs_selfield-value.
        SET PARAMETER ID 'BLN' FIELD rs_selfield-value.
        SET PARAMETER ID 'BUK' FIELD itab-BUKRS.
        SET PARAMETER ID 'GJR' FIELD itab-GJaHR.
        CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
      ENDIF.
      IF rs_selfield-fieldname = 'FLAG'. "deseleccion o selecciona
        READ TABLE itab index rs_selfield-tabindex.
        if itab-flag = 'X'.
          clear itab-flag.
        elseif itab-flag is INITIAL and itab-ZZMOT_EMIS is NOT INITIAL .
          itab-flag = 'X'.
        endif.
        MODIFY itab INDEX rs_selfield-tabindex.
        rs_selfield-refresh = 'X'.
      endif.

    WHEN '&ALL2'."marca todos
      LOOP AT itab.
        if itab-ZZMOT_EMIS is not INITIAL.
          itab-flag = 'X'.
          MODIFY itab INDEX sy-tabix.
        ENDIF.
      ENDLOOP.
      rs_selfield-refresh = 'X'.

    WHEN '&SAL2'."deselecciona todos
      LOOP AT itab.
        CLEAR itab-flag.
        MODIFY itab INDEX sy-tabix.
      ENDLOOP.
      rs_selfield-refresh = 'X'.

    When '&CONTA'. "ejecuta funcion sobre los que esten seleccionados
      refresh ti_return.
      loop at itab where flag = 'X'.
        MOVE-CORRESPONDING itab to t_itab.
        PERFORM carga_datos.
        perform carga_tablas.
        perform ejecuta_funcion.
      endloop.
      PERFORM display_messages .

  ENDCASE.
ENDFORM.                    "USER_COMMAND
*&---------------------------------------------------------------------*
*&      Form  FRM_PF_STATUS
*&---------------------------------------------------------------------*
*   Status del alv de salida principal (se agergo un boton: "&CONTA")
*----------------------------------------------------------------------*
FORM frm_pf_status USING rt_extab TYPE slis_t_extab.
*  First i copy PF-STATUS SAPLKKBL STANDARD_FULLSCREEN
  SET PF-STATUS 'STANDARD2' .
ENDFORM.                    "FRM_PF_STATUS.
*&---------------------------------------------------------------------*
*&      Form  SET_SPECIFIC_FIELD_ATTRIBUTES
*&---------------------------------------------------------------------*
*   deshabilito el check box de la linea si la via de pago viene vacia
*----------------------------------------------------------------------*
FORM SET_SPECIFIC_FIELD_ATTRIBUTES .
  DATA ls_stylerow TYPE lvc_s_styl .
  DATA lt_styletab TYPE lvc_t_styl .

  LOOP AT itab .
    if itab-ZZMOT_EMIS is INITIAL.
      ls_stylerow-fieldname = 'FLAG'.
      ls_stylerow-style = cl_gui_alv_grid=>mc_style_disabled.
      INSERT ls_stylerow into table itab-field_style.
      modify itab.
    endif.
  ENDLOOP.
ENDFORM.                    " SET_SPECIFIC_FIELD_ATTRIBUTES*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  carga_tablas
*&---------------------------------------------------------------------*
*   Se cargan las tablas internas a usar por la funcion
*--------------------------------------------------------------------*
form carga_tablas.
  refresh l_t_ftclear.  clear l_t_ftclear.
  refresh l_t_ftpost.   CLEAR l_t_ftpost.
  clear wa_bkpf.

  l_t_ftclear-agkoa = 'S'.          "CONSTANTE
  l_t_ftclear-agkon = t_itab-hkont. "HKONT ALV
  l_t_ftclear-agbuk = t_itab-BUKRS. "SOCIEDAD ALV
  l_t_ftclear-xnops = 'X'.          "CONSTANTE
*    l_t_ftclear-xfifo = ' '.
*    l_t_ftclear-agums = l_cme.
*    l_t_ftclear-avsid = ' '.
  l_t_ftclear-selfd = 'BELNR'.      "CONSTANTE
  CONCATENATE t_itab-BELNR t_itab-GJaHR into l_t_ftclear-selvon ."= t_itab-belnr."BELNR ALV
*    l_t_ftclear-selbis = ' '.
  append l_t_ftclear.

  if itab-multi eq 'X'.

    read table ti_bsis into wa_bsis with key BUKRS = t_itab-BUKRS
                                             belnr = t_itab-belnr
                                             gjahr = t_itab-GJaHR.

    READ TABLE ti_bkpf into wa_bkpf with key bukrs = wa_bsis-BUKRS
                                             belnr = wa_bsis-belnr_orig
                                             gjahr = wa_bsis-GJaHR.

*    READ TABLE ti_bkpf into wa_bkpf with key bukrs = t_itab-BUKRS
*                                             belnr = t_itab-belnr
*                                             gjahr = t_itab-GJaHR.

    l_t_ftclear-agkoa = 'K'.          "CONSTANTE
    l_t_ftclear-agkon = wa_bkpf-multi_lifnr. "HKONT ALV
    l_t_ftclear-agbuk = wa_bkpf-multi_bukrs. "SOCIEDAD ALV
    l_t_ftclear-xnops = 'X'.          "CONSTANTE
    l_t_ftclear-selfd = 'BELNR'.      "CONSTANTE
    CONCATENATE wa_bkpf-multi_belnr wa_bkpf-multi_gjahr into l_t_ftclear-selvon.
    append l_t_ftclear.

    l_t_ftclear-agkoa = 'D'.          "CONSTANTE
    l_t_ftclear-agkon = wa_bkpf-multi_kunnr. "HKONT ALV
    l_t_ftclear-agbuk = wa_bkpf-ingre_bukrs. "SOCIEDAD ALV
    l_t_ftclear-xnops = 'X'.          "CONSTANTE
    l_t_ftclear-selfd = 'BELNR'.      "CONSTANTE
    CONCATENATE wa_bkpf-ingre_belnr wa_Bkpf-ingre_gjahr into l_t_ftclear-selvon.
    append l_t_ftclear.
  endif.

**---------------------------------------------------------------------
* BLDAT ALV
**---------------------------------------------------------------------
  l_t_ftpost-stype = 'K'.
  l_t_ftpost-count = '1'.
  l_t_ftpost-fnam = 'BKPF-BLDAT'.
  CONCATENATE t_itab-bldat+6(2) t_itab-bldat+4(2) t_itab-bldat(4) into l_t_ftpost-fval. CONDENSE l_t_ftpost-fval.
  append l_t_ftpost.
**---------------------------------------------------------------------
* Fe.contabilización DATO DE ENTRADA
**---------------------------------------------------------------------
  l_t_ftpost-fnam = 'BKPF-BUDAT'. "fecha de entrada
  CONCATENATE l_fecha+6(2) l_fecha+4(2) l_fecha(4) into l_t_ftpost-fval . condense l_t_ftpost-fval.
  append l_t_ftpost.
**---------------------------------------------------------------------
* MES FECHA DE CONTB DATO DE ENTRADA
**---------------------------------------------------------------------
  l_t_ftpost-fnam = 'BKPF-MONAT'. "mes fecha de entrada
  l_t_ftpost-fval = l_fecha+4(2).
  append l_t_ftpost.
**---------------------------------------------------------------------
* SOCIEDAD ALV
**---------------------------------------------------------------------
  if itab-multi eq 'X'.

    read table ti_bsis into wa_bsis with key BUKRS = t_itab-BUKRS
                                             belnr = t_itab-belnr
                                             gjahr = t_itab-GJaHR.

    READ TABLE ti_bkpf into wa_bkpf with key bukrs = wa_bsis-BUKRS
                                             belnr = wa_bsis-belnr_orig
                                             gjahr = wa_bsis-GJaHR.

    l_t_ftpost-fnam = 'BKPF-BUKRS'. "Sociedad Pantalla de entrada
    l_t_ftpost-fval = wa_bkpf-multi_bukrs.
    append l_t_ftpost.

  ELSE.
    l_t_ftpost-fnam = 'BKPF-BUKRS'. "Sociedad Pantalla de entrada
    l_t_ftpost-fval = t_itab-bukrs.
    append l_t_ftpost.

  ENDIF.
**---------------------------------------------------------------------
*  TABLA ZFITR020_T03
*  lo lleno en una subrutina dependiendo del proceso
**---------------------------------------------------------------------
  l_t_ftpost-fnam = 'BKPF-BLART'. "Clase de documento
  l_t_ftpost-fval = l_clase_doc.
  append l_t_ftpost.
**---------------------------------------------------------------------
*  CONSTANTE
**---------------------------------------------------------------------
  l_t_ftpost-fnam = 'BKPF-WAERS'. "Tipo de moneda
  l_t_ftpost-fval = 'CLP'.
  append l_t_ftpost.
**---------------------------------------------------------------------
*    "CAMPO CHEQUE DEL ALV SI ES VACIO COLOCAR BELNR + gjahr DEL ALV
**---------------------------------------------------------------------
  l_t_ftpost-fnam = 'BKPF-XBLNR'.
  if t_itab-CHECT is not INITIAL.
    l_t_ftpost-fval = t_itab-chect.
  else.
    CONCATENATE t_itab-BELNR t_itab-GJaHR into l_t_ftpost-fval .
  endif.
  append l_t_ftpost.
**---------------------------------------------------------------------
*   CONSTANTE:
*  lo lleno en una subrutina dependiendo del proceso
**---------------------------------------------------------------------
  l_t_ftpost-fnam = 'BKPF-BKTXT'. "Nombre de proceso
  l_t_ftpost-fval = l_nom_proceso.
  append l_t_ftpost.
**---------------------------------------------------------------------
*  CONCATENA
**---------------------------------------------------------------------
  l_t_ftpost-fnam = 'RF05A-AUGTX'. "Nombre de proceso
  CONCATENATE l_nom_proceso ' - '  t_itab-HBKID ' - ' t_itab-HKTID into l_texto SEPARATED BY space.
  l_t_ftpost-fval = l_texto.
  append l_t_ftpost.
**---------------------------------------------------------------------
*   CONSTANTE
**---------------------------------------------------------------------
  l_t_ftpost-fnam = 'RF05A-NEWBS'.
  l_t_ftpost-fval = '31'.
  append l_t_ftpost.
**---------------------------------------------------------------------
*  LIFNR ALV
**---------------------------------------------------------------------
  l_t_ftpost-fnam = 'RF05A-NEWKO'.
  l_t_ftpost-fval = t_itab-lifnr.
  append l_t_ftpost.
**---------------------------------------------------------------------
*  CTA_DTINO - ALV
**---------------------------------------------------------------------
  l_t_ftpost-fnam = 'BSEG-HKONT'.
  l_t_ftpost-fval = t_itab-HKONTD.
  append l_t_ftpost.
**---------------------------------------------------------------------
* IMPORTE ALV
**---------------------------------------------------------------------
  data: l_monto(15) type c.
  l_t_ftpost-fnam = 'BSEG-WRBTR'.
  write t_itab-WRBTR to l_monto currency 'CLP'.
  condense l_monto no-gaps.
  l_t_ftpost-fval = l_monto.
  append l_t_ftpost.
**---------------------------------------------------------------------
*  VIA DE PAGO - ALV
**---------------------------------------------------------------------
  l_t_ftpost-fnam = 'BSEG-ZLSCH'.
  l_t_ftpost-fval = t_itab-zlsch.
  append l_t_ftpost.
**---------------------------------------------------------------------
*  CAMPO CHEQUE DEL ALV SI ES VACIO COLOCAR BELNR + gjahr DEL ALV
**---------------------------------------------------------------------
  l_t_ftpost-fnam = 'BSEG-ZUONR'.
  if t_itab-CHECT is not INITIAL.
    l_t_ftpost-fval = t_itab-chect.
  else.
    CONCATENATE t_itab-BELNR t_itab-GJaHR into l_t_ftpost-fval .
  endif.
  append l_t_ftpost.
**---------------------------------------------------------------------
*  CONCATENA
**---------------------------------------------------------------------
  l_t_ftpost-fnam = 'BSEG-SGTXT'.
  CONCATENATE l_nom_proceso ' - ' t_itab-HBKID ' - ' t_itab-HKTID into l_texto SEPARATED BY space.
  l_t_ftpost-fval = l_texto.
  append l_t_ftpost.
**---------------------------------------------------------------------
*  BANCO PROPIO - ALV
**---------------------------------------------------------------------
  l_t_ftpost-fnam = 'BSEG-HBKID'. "
  l_t_ftpost-fval = t_itab-HBKID.
  append l_t_ftpost.
**---------------------------------------------------------------------
*  MOTIVO EMISION - ALV
**---------------------------------------------------------------------
  l_t_ftpost-fnam = 'BSEG-ZZMOT_EMIS'.
  l_t_ftpost-fval = t_itab-ZZMOT_EMIS.
  append l_t_ftpost.
**---------------------------------------------------------------------
*  Lote
**---------------------------------------------------------------------
  l_t_ftpost-fnam = 'BSEG-XREF1'.
  l_t_ftpost-fval = t_itab-zuonr+1(12).
  append l_t_ftpost.


endform.                    " CARGA_TABLAS
*&---------------------------------------------------------------------*
*&      Form  ejecuta_funcion
*&---------------------------------------------------------------------*
*   Funcion estandar POSTING_INTERFACE_CLEARING y batch input tx fch9
*--------------------------------------------------------------------*
form ejecuta_funcion.

  l_group = sy-tcode.
*********************************
*Cambiar modo de visualizacion
* A	Visual.pant.(todas)
* E	Visualizar sólo errores
* N	Sin visualización

  l_ver_batch = 'N'.
*********************************
*--- Posting interface start
  call function 'POSTING_INTERFACE_START'
    EXPORTING
      i_function         = 'C'    " Using Call Transaction
      i_group            = l_group
      i_mode             = l_ver_batch
      i_update           = 'S'
      i_user             = sy-uname
      i_xbdcc            = 'X'
    EXCEPTIONS
      client_incorrect   = 1
      function_invalid   = 2
      group_name_missing = 3
      mode_invalid       = 4
      update_invalid     = 5
      others             = 6.
  if sy-subrc <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
           with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.

  call function 'POSTING_INTERFACE_CLEARING'
     exporting
     i_auglv       = 'UMBUCHNG'
     i_tcode       = c_fipi_trans_compensacion
     i_sgfunct     = 'C'
     i_no_auth     = ' '
  importing
       e_msgid     = sy-msgid
       e_msgno     = sy-msgno
       e_msgty     = sy-msgty
       e_msgv1     = sy-msgv1
       e_msgv2     = sy-msgv2
       e_msgv3     = sy-msgv3
       e_msgv4     = sy-msgv4
*      e_subrc     = sy-subrc
     tables
       t_blntab      = l_t_blntab
       t_ftclear     = l_t_ftclear
       t_ftpost      = l_t_ftpost
       t_fttax       = l_t_fttax

  exceptions
    clearing_procedure_invalid       = 1
    clearing_procedure_missing       = 2
    table_t041a_empty                = 3
    transaction_code_invalid         = 4
    amount_format_error              = 5
    too_many_line_items              = 6
    company_code_invalid             = 7
    screen_not_found                 = 8
    no_authorization                 = 9
    others                           = 10.

  commit work.

*  message id sy-msgid type sy-msgty number sy-msgno
*       with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.

  "lleno la tabla de salida del proceso con el mensaje
  "de la interfaz mas algunos datos adicinales
  clear ti_return.
  ti_return-TYPE        = sy-msgty.
  ti_return-ID          = sy-msgid.
  ti_return-NUMBER      = sy-msgno.
  ti_return-BELNR       = t_itab-BELNR.
  ti_return-BUKRS       = SY-MSGV2.
  ti_return-GJaHR       = t_itab-GJaHR.

  "mensaje estandar a string
  PERFORM convierte_mensaje USING sy-msgid sy-msgno CHANGING ti_return-message.
  ti_return-MESSAGE_V1  = sy-msgv1.

  if ti_return-MESSAGE_V1 is not INITIAL and t_itab-CHECT is not INITIAL.
    perform anula_cheque USING t_itab-chect t_itab-HBKID t_itab-HKTID t_itab-BUKRS.

    "mensaje estandar a string
    PERFORM convierte_mensaje USING sy-msgid sy-msgno CHANGING ti_return-message2.
    ti_return-MESSAGE_V2 = sy-msgv1.

  endif.
  append ti_return.

  call function 'POSTING_INTERFACE_END'
* EXPORTING
*   I_BDCIMMED                    = ' '
*   I_BDCSTRTDT                   = NO_DATE
*   I_BDCSTRTTM                   = NO_TIME
    exceptions
      session_not_processable       = 1
      others                        = 2
            .
  if sy-subrc <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.

endform.                    " EJECUTA_FUNCION
*&---------------------------------------------------------------------*
*&      Form  CARGA_DATOS
*&---------------------------------------------------------------------*
*       Se llena el nombre del proceso y la clase de documento
*       segun el id de proceso.
*----------------------------------------------------------------------*
FORM CARGA_DATOS .
  DATA: LV_EXISTE TYPE C.

  "si el motivo esta marcado como especial(maternal)
  "tienen distintas clases de documentos y nombres de procesos
  "que dependen de las cuentas, si no, es un proceso normal.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE MATERNAL INTO LV_EXISTE
*    FROM ZMOT_EMIS
*    WHERE ZZMOT_EMIS = t_itab-ZZMOT_EMIS.
*
* NEW CODE
  SELECT MATERNAL
  UP TO 1 ROWS  INTO LV_EXISTE
    FROM ZMOT_EMIS
    WHERE ZZMOT_EMIS = t_itab-ZZMOT_EMIS ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

  IF LV_EXISTE EQ 'X'.
    if t_itab-HKONT+9(1) eq '2' or t_itab-HKONT+9(1) eq '5'.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT single CLASE_DOC CAMBIO_ESTADO into (l_clase_doc, l_nom_proceso)
*        from ZFITR020_T03
*        where ID_PROCESO = '1010'. 
*
* NEW CODE
      SELECT CLASE_DOC CAMBIO_ESTADO
      UP TO 1 ROWS  into (l_clase_doc, l_nom_proceso)
        from ZFITR020_T03
        where ID_PROCESO = '1010' ORDER BY PRIMARY KEY. 

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01"XH; REEMISION CHEQ MT

    ELSEIF t_itab-HKONT+9(1) eq '6' or t_itab-HKONT+9(1) eq '7'.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT single CLASE_DOC CAMBIO_ESTADO into (l_clase_doc, l_nom_proceso)
*        from ZFITR020_T03
*        where ID_PROCESO = '1011'. 
*
* NEW CODE
      SELECT CLASE_DOC CAMBIO_ESTADO
      UP TO 1 ROWS  into (l_clase_doc, l_nom_proceso)
        from ZFITR020_T03
        where ID_PROCESO = '1011' ORDER BY PRIMARY KEY. 

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01"XI; REVALIDAC CHEQUE MT

    endif.
  else.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT single CLASE_DOC CAMBIO_ESTADO into (l_clase_doc, l_nom_proceso)
*      from ZFITR020_T03
*      where ID_PROCESO = '1003'. 
*
* NEW CODE
    SELECT CLASE_DOC CAMBIO_ESTADO
    UP TO 1 ROWS  into (l_clase_doc, l_nom_proceso)
      from ZFITR020_T03
      where ID_PROCESO = '1003' ORDER BY PRIMARY KEY. 

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01"XA; CAMBIO - NUEVO PAGO

  endif.

  "dependiendo del tab se asigna a l_fecha para hacer mas generica la funcion
  if tabname eq '101' or tabname is INITIAL.
    l_fecha = p_budat1.
  elseif tabname eq '102'.
    l_fecha = p_budat2.
  endif.

ENDFORM.                    " CARGA_DATOS
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_MESSAGES
*&---------------------------------------------------------------------*
*       Despliega el alv de resultado de la funcion.
*----------------------------------------------------------------------*
FORM display_messages .
  DATA: t_fieldcat      TYPE slis_t_fieldcat_alv.
  DATA: t_events        TYPE slis_alv_event OCCURS 0.
  data: g_repid like sy-cprog.

  PERFORM fieldcat_init_salida USING t_fieldcat[].

  DATA event TYPE slis_alv_event.

  event-name = slis_ev_user_command.
  event-form = 'USER_COMMAND2'.
  APPEND event TO t_events.

*------------------------------------------------------------------
* resultado funcion en alv de Salida tipo lista
*------------------------------------------------------------------
  g_repid = sy-cprog.

  CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
    EXPORTING
      i_callback_program = g_repid
*      i_callback_pf_status_set = 'FRM_PF_STATUS2'
      it_fieldcat        = t_fieldcat[]
      it_events          = t_events
    TABLES
      t_outtab           = ti_return.

ENDFORM.                    " DISPLAY_MESSAGES
*&---------------------------------------------------------------------*
*&      Form  FIELDCAT_INIT_SALIDA
*&---------------------------------------------------------------------*
*      Catalogo de salida del alv tipo lista
*----------------------------------------------------------------------*
FORM FIELDCAT_INIT_SALIDA  USING   rt_fieldcat TYPE slis_t_fieldcat_alv.
  DATA: ls_fieldcat TYPE slis_fieldcat_alv.
  DATA: pos TYPE i VALUE 1.

  CLEAR  : rt_fieldcat.
  REFRESH: rt_fieldcat.

  CLEAR ls_fieldcat.
  pos = pos + 1.
  ls_fieldcat-col_pos       =  pos.
  ls_fieldcat-fieldname     = 'BUKRS'.
  ls_fieldcat-seltext_s     = 'Sociedad'.
  ls_fieldcat-seltext_l     = 'Sociedad'.
  ls_fieldcat-outputlen     = '12'.
  ls_fieldcat-just          = 'R'.
  APPEND ls_fieldcat TO  rt_fieldcat.

  CLEAR ls_fieldcat.
  pos = pos + 1.
  ls_fieldcat-col_pos       =  pos.
  ls_fieldcat-fieldname     = 'BELNR'.
  ls_fieldcat-seltext_s     = 'Documento'.
  ls_fieldcat-seltext_l     = 'Documento'.
  ls_fieldcat-outputlen     = '15'.
  ls_fieldcat-just          = 'R'.
  APPEND ls_fieldcat TO  rt_fieldcat.

  CLEAR ls_fieldcat.
  pos = pos + 1.
  ls_fieldcat-col_pos       =  pos.
  ls_fieldcat-fieldname     = 'MESSAGE_V1'.
  ls_fieldcat-seltext_s     = 'Nuevo Doc.'.
  ls_fieldcat-seltext_l     = 'Nuevo documento'.
  ls_fieldcat-outputlen     = '10'.
  ls_fieldcat-just          = 'R'.
  APPEND ls_fieldcat TO  rt_fieldcat.

  CLEAR ls_fieldcat.
  pos = pos + 1.
  ls_fieldcat-col_pos       =  pos.
  ls_fieldcat-fieldname     = 'MESSAGE'.
  ls_fieldcat-seltext_s     = 'MESSAGE'.
  ls_fieldcat-seltext_l     = 'MESSAGE'.
  ls_fieldcat-outputlen     = '50'.
  ls_fieldcat-just          = 'L'.
  APPEND ls_fieldcat TO  rt_fieldcat.

  CLEAR ls_fieldcat.
  pos = pos + 1.
  ls_fieldcat-col_pos       =  pos.
  ls_fieldcat-fieldname     = 'MESSAGE_V2'.
  ls_fieldcat-seltext_s     = 'Cheque anu.'.
  ls_fieldcat-seltext_l     = 'Cheque anulado'.
  ls_fieldcat-outputlen     = '10'.
  ls_fieldcat-just          = 'R'.
  APPEND ls_fieldcat TO  rt_fieldcat.

  CLEAR ls_fieldcat.
  pos = pos + 1.
  ls_fieldcat-col_pos       =  pos.
  ls_fieldcat-fieldname     = 'MESSAGE2'.
  ls_fieldcat-seltext_s     = 'MESSAGE2'.
  ls_fieldcat-seltext_l     = 'MESSAGE2'.
  ls_fieldcat-outputlen     = '36'.
  ls_fieldcat-just          = 'L'.
  APPEND ls_fieldcat TO  rt_fieldcat.

ENDFORM.                    " FIELDCAT_INIT_SALIDA
*&---------------------------------------------------------------------*
*&      Form  user_command2
*&---------------------------------------------------------------------*
*       user_command del alv de resultado de la funcion
*----------------------------------------------------------------------*
FORM user_command2 USING r_ucomm LIKE sy-ucomm
                           rs_selfield TYPE slis_selfield.

  CASE r_ucomm.
    WHEN 'PICK' OR '&IC1'. "click en alv
      IF rs_selfield-fieldname = 'MESSAGE_V1'.
        if rs_selfield-value is not INITIAL.
          READ TABLE ti_return with key BELNR = rs_selfield-value.
          SET PARAMETER ID 'BLN' FIELD rs_selfield-value.
          SET PARAMETER ID 'BUK' FIELD ti_return-BUKRS.
          SET PARAMETER ID 'GJR' FIELD ti_return-GJaHR.
          CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
        endif.
      ENDIF.
  ENDCASE.
ENDFORM.                    "USER_COMMAND
*&---------------------------------------------------------------------*
*&      Form  FRM_PF_STATUS
*&---------------------------------------------------------------------*
*       Status del alv de resultado de la funcion.
*----------------------------------------------------------------------*
FORM frm_pf_status2 USING rt_extab TYPE slis_t_extab.
*  First i copy PF-STATUS SAPLKKBL STANDARD_FULLSCREEN
*  SET PF-STATUS 'STANDARD2' .
ENDFORM.                    "FRM_PF_STATUS.
*&---------------------------------------------------------------------*
*&      Form  SELECCIONA
*&---------------------------------------------------------------------*
*     Rescate de datos correspondiente al primer tab
*     CAMBIO PAGO POR CHEQUE
*--------------------------------------------------------------------*
FORM selecciona .
*  rangos y variables
  ranges: r_budat for bsas-augdt.
  data: lv_zuonr like bsis-zuonr.
  data: lv_bukrs like bkpf-BUKRS.
  data: lv_gjahr like bkpf-GJaHR.
  data: lv_belnr like bkpf-belnr.
  data: lv_lifnr like bsik-lifnr.
  data: lv_kunnr like bsid-kunnr.

  "rescato las cuentas de la tabla mantenedora.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  select * into CORRESPONDING FIELDS OF TABLE ti_ZFITR020_T05
*    from ZFITR020_T05
*    where bukrs eq p_bukrs1
*      and hbkid eq p_hbkid1
*      and hktid eq p_hktid1.
*
* NEW CODE
  SELECT *
 into CORRESPONDING FIELDS OF TABLE ti_ZFITR020_T05
    from ZFITR020_T05
    where bukrs eq p_bukrs1
      and hbkid eq p_hbkid1
      and hktid eq p_hktid1 ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

  READ TABLE ti_ZFITR020_T05 into wa_ZFITR020_T05 index 1.

  loop at p_chect1.

    "rescato los cheques para luego buscar las partidas abiertas
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*    select * APPENDING CORRESPONDING FIELDS OF TABLE ti_payr
*      from payr
*      where ZBUKR eq p_bukrs1
*        and hbkid eq p_hbkid1
*        and hktid eq p_hktid1
*        and chect eq p_chect1-low
*        and voidr eq '00'"cheque NO anulado
*        and xbanc eq ' ' "cheque NO cobrado
*            .
*
* NEW CODE
    SELECT * APPENDING CORRESPONDING FIELDS OF TABLE ti_payr

      from payr
      where ZBUKR eq p_bukrs1
        and hbkid eq p_hbkid1
        and hktid eq p_hktid1
        and chect eq p_chect1-low
        and voidr eq '00'"cheque NO anulado
        and xbanc eq ' ' "cheque NO cobrado
             ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
  endloop.
  if sy-subrc <> 0.
    MESSAGE 'NO SE SELECCIONARON PARTIDAS PARA LA CONSULTA' type 'E'.
  endif.

  loop at ti_payr into wa_payr.
    clear wa_bkpf.
    "SE NECESITA UBICAR EL MAESTRO A QUIEN SE LE PAGO
    "EL CUAL ESTA EN EL DOCUMENTO ORIGEN QUE ENTREGA LA PAYR

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT single * into CORRESPONDING FIELDS OF wa_bkpf
*      from bkpf
*      where BUKRS eq wa_payr-zBUKR
*        and belnr eq wa_payr-VBLNR
*        and GJaHR eq wa_payr-GJaHR.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  into CORRESPONDING FIELDS OF wa_bkpf
      from bkpf
      where BUKRS eq wa_payr-zBUKR
        and belnr eq wa_payr-VBLNR
        and GJaHR eq wa_payr-GJaHR ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

    "se verifica si es multisociedad
    if wa_bkpf-bvorg is not INITIAL.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT single bukrs GJaHR BELNR into (lv_bukrs, lv_gjahr, lv_belnr)
*        from bvor
*        where bvorg eq wa_bkpf-bvorg
*          and BUKRS <> p_bukrs1.
*
* NEW CODE
      SELECT bukrs GJaHR BELNR
      UP TO 1 ROWS  into (lv_bukrs, lv_gjahr, lv_belnr)
        from bvor
        where bvorg eq wa_bkpf-bvorg
          and BUKRS <> p_bukrs1 ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      select single lifnr into lv_lifnr "el acreedor
*        from bsik
*        where bukrs eq lv_bukrs
*          and GJaHR eq lv_gjahr
*          and belnr eq lv_belnr.
*
* NEW CODE
      SELECT lifnr
      UP TO 1 ROWS  into lv_lifnr "el acreedor
        from bsik
        where bukrs eq lv_bukrs
          and GJaHR eq lv_gjahr
          and belnr eq lv_belnr ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT single kunnr into lv_kunnr "el deudor
*        from bsid
*        where bukrs eq wa_payr-zBUKR
*          and GJaHR eq wa_payr-GJaHR
*          and belnr eq wa_payr-VBLNR.
*
* NEW CODE
      SELECT kunnr
      UP TO 1 ROWS  into lv_kunnr "el deudor
        from bsid
        where bukrs eq wa_payr-zBUKR
          and GJaHR eq wa_payr-GJaHR
          and belnr eq wa_payr-VBLNR ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

      wa_payr-multi_kunnr = lv_kunnr.
      wa_payr-multi_lifnr = lv_lifnr.
      wa_payr-multi_bukrs = lv_bukrs.
      wa_payr-multi_belnr = lv_belnr.
      wa_payr-multi_gjahr = lv_gjahr.



      modify ti_payr from wa_payr TRANSPORTING multi_kunnr
                                               multi_lifnr
                                               multi_bukrs
                                               multi_belnr
                                               multi_gjahr.

      wa_bkpf-ingre_bukrs = wa_payr-zBUKR.
      wa_bkpf-ingre_belnr = wa_payr-VBLNR.
      wa_bkpf-ingre_gjahr = wa_payr-GJaHR.

      wa_bkpf-multi_kunnr = lv_kunnr.
      wa_bkpf-multi_lifnr = lv_lifnr.
      wa_bkpf-multi_bukrs = lv_bukrs.
      wa_bkpf-multi_belnr = lv_belnr.
      wa_bkpf-multi_gjahr = lv_gjahr.
      APPEND wa_bkpf to ti_bkpf.
    endif.


    if wa_bkpf-bvorg is not INITIAL.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      select single * into CORRESPONDING FIELDS OF wa_bse
*        from bse_clr "FOR ALL ENTRIES IN ti_bsis
*        where BUKRS_CLR = wa_bkpf-multi_bukrs
*          and BELNR_CLR = wa_bkpf-multi_belnr
*          and GJAHR_CLR = wa_bkpf-multi_gjahr
*              .
*
* NEW CODE
      SELECT *
      UP TO 1 ROWS  into CORRESPONDING FIELDS OF wa_bse
        from bse_clr "FOR ALL ENTRIES IN ti_bsis
        where BUKRS_CLR = wa_bkpf-multi_bukrs
          and BELNR_CLR = wa_bkpf-multi_belnr
          and GJAHR_CLR = wa_bkpf-multi_gjahr
               ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
      APPEND wa_bse to ti_bse.
    else.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      select single * into CORRESPONDING FIELDS OF wa_bse
*        from bse_clr
*        where BUKRS_CLR = wa_payr-zBUKR
*          and BELNR_CLR = wa_payr-VBLNR
*          and GJAHR_CLR = wa_payr-GJaHR .
*
* NEW CODE
      SELECT *
      UP TO 1 ROWS  into CORRESPONDING FIELDS OF wa_bse
        from bse_clr
        where BUKRS_CLR = wa_payr-zBUKR
          and BELNR_CLR = wa_payr-VBLNR
          and GJAHR_CLR = wa_payr-GJaHR  ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

      APPEND wa_bse to ti_bse.
    endif.

    "se consultar el acreedor y el motivo de emision
SELECT *
into CORRESPONDING FIELDS OF wa_bseg
from bseg
where belnr = wa_bse-BELNR
and GJaHR = wa_bse-GJaHR
and bukrs = wa_bse-BUKRS
and buzei = wa_Bse-buzei
*Begin of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 24/12/2019 EY_DES04 ECDK917080 *
*and ZZMOT_EMIS <> ' ' .
AND ZZMOT_EMIS <> ' ' ORDER BY PRIMARY KEY.
*End of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 24/12/2019 EY_DES04 ECDK917080 *
      wa_bseg-chect = wa_payr-chect.
      APPEND wa_bseg to ti_bseg.
    ENDSELECT.
  endloop.

*SE DEBE UBICAR EL UNICO DOCUMENTO QUE TENGA LA PARTIDA ABIERTA
*PARA COMPENSAR Y GENERAR UNA NUEVA PARTIDA, ESTE DOCUMENTO
*PUEDER SER EL ORIGINAL U OTRO.
  loop at ti_payr into wa_payr.
*UBICAR LA PARTIDA ABIERTA CON EL FIN DE SABER SI EL DOCUMENTO
*DE LA PAYR ES SUFICIENTE
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*    select * into CORRESPONDING FIELDS OF wa_bsis
*      from bsis
*      where bukrs eq wa_payr-ZBUKR
*        and ( hkont eq wa_payr-UBHKT
*           or hkont eq wa_ZFITR020_T05-CTA_SALDO
*           or hkont eq wa_ZFITR020_T05-CTA_DEPOS
*           or hkont eq wa_ZFITR020_T05-CTA_CHEQS
*           or hkont eq wa_ZFITR020_T05-CTA_CARGOS
*           or hkont eq wa_ZFITR020_T05-CTA_ABONOS
*           or hkont eq wa_ZFITR020_T05-CTA_TRANS
*           or hkont eq wa_ZFITR020_T05-CTA_CDCO_F
*           or hkont eq wa_ZFITR020_T05-CTA_CDCO_E
*           or hkont eq wa_ZFITR020_T05-CTA_CDCO_F2
*           or hkont eq wa_ZFITR020_T05-REVALIDAD )
*        and GJaHR eq wa_payr-GJaHR
*        and BELNR eq wa_payr-vbLNR
*          .
*
* NEW CODE
    SELECT *
 into CORRESPONDING FIELDS OF wa_bsis
      from bsis
      where bukrs eq wa_payr-ZBUKR
        and ( hkont eq wa_payr-UBHKT
           or hkont eq wa_ZFITR020_T05-CTA_SALDO
           or hkont eq wa_ZFITR020_T05-CTA_DEPOS
           or hkont eq wa_ZFITR020_T05-CTA_CHEQS
           or hkont eq wa_ZFITR020_T05-CTA_CARGOS
           or hkont eq wa_ZFITR020_T05-CTA_ABONOS
           or hkont eq wa_ZFITR020_T05-CTA_TRANS
           or hkont eq wa_ZFITR020_T05-CTA_CDCO_F
           or hkont eq wa_ZFITR020_T05-CTA_CDCO_E
           or hkont eq wa_ZFITR020_T05-CTA_CDCO_F2
           or hkont eq wa_ZFITR020_T05-REVALIDAD )
        and GJaHR eq wa_payr-GJaHR
        and BELNR eq wa_payr-vbLNR
           ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

      wa_bsis-belnr_orig = wa_payr-vbLNR.
      APPEND wa_bsis to ti_bsis.
    ENDSELECT.
    if sy-subrc <> 0.
      "si la busqueda no es satisfactoria se reemplaza
      "se busca el n° de cheque en el campo asignacion
      clear lv_zuonr.
      lv_zuonr = wa_payr-CHECT.

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*      select *
*        into CORRESPONDING FIELDS OF   wa_bsis
*        from bsis
*        where bukrs eq wa_payr-ZBUKR
*          and ( hkont eq wa_payr-UBHKT
*           or hkont eq wa_ZFITR020_T05-CTA_SALDO
*           or hkont eq wa_ZFITR020_T05-CTA_DEPOS
*           or hkont eq wa_ZFITR020_T05-CTA_CHEQS
*           or hkont eq wa_ZFITR020_T05-CTA_CARGOS
*           or hkont eq wa_ZFITR020_T05-CTA_ABONOS
*           or hkont eq wa_ZFITR020_T05-CTA_TRANS
*           or hkont eq wa_ZFITR020_T05-CTA_CDCO_F
*           or hkont eq wa_ZFITR020_T05-CTA_CDCO_E
*           or hkont eq wa_ZFITR020_T05-CTA_CDCO_F2
*           or hkont eq wa_ZFITR020_T05-REVALIDAD )
**          and GJaHR eq wa_payr-GJaHR
*          and ZUONR eq lv_zuonr
*            .
*
* NEW CODE
      SELECT *

        into CORRESPONDING FIELDS OF   wa_bsis
        from bsis
        where bukrs eq wa_payr-ZBUKR
          and ( hkont eq wa_payr-UBHKT
           or hkont eq wa_ZFITR020_T05-CTA_SALDO
           or hkont eq wa_ZFITR020_T05-CTA_DEPOS
           or hkont eq wa_ZFITR020_T05-CTA_CHEQS
           or hkont eq wa_ZFITR020_T05-CTA_CARGOS
           or hkont eq wa_ZFITR020_T05-CTA_ABONOS
           or hkont eq wa_ZFITR020_T05-CTA_TRANS
           or hkont eq wa_ZFITR020_T05-CTA_CDCO_F
           or hkont eq wa_ZFITR020_T05-CTA_CDCO_E
           or hkont eq wa_ZFITR020_T05-CTA_CDCO_F2
           or hkont eq wa_ZFITR020_T05-REVALIDAD )
*          and GJaHR eq wa_payr-GJaHR
          and ZUONR eq lv_zuonr
             ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
        wa_Bsis-marca = 'X'.
        wa_bsis-belnr_orig = wa_payr-vbLNR.
        APPEND wa_bsis to ti_bsis.
      ENDSELECT.
    endif.
  endloop.


ENDFORM.                    "selecciona
*&---------------------------------------------------------------------*
*&      Form  CREA_ALV
*&---------------------------------------------------------------------*
*      Armamos el AlV de salida para la pestaña
*      CAMBIO PAGO POR CHEQUE
*----------------------------------------------------------------------*
FORM CREA_ALV .
  refresh itab.

  loop at ti_bsis into wa_bsis.
    clear itab.
    clear wa_payr.
    clear wa_bse.
    clear wa_bseg.
    clear wa_bkpf.

    MOVE-CORRESPONDING wa_bsis to itab.
    "el flag marca la diferenciacion de la obtencion del
    "dato en la payr si viene marcado se por que se ingreso
    "a la payr con el cheque
    if wa_bsis-marca eq 'X'.
      READ TABLE ti_payr into wa_payr with key ZBUKR = wa_bsis-BUKRS
                                               chect = wa_bsis-zuonr.

      if wa_payr-multi_belnr is not initial.
        itab-multi = 'X'.
      endif.

    else.
      "preguntamos si el documento es intercompany
      READ TABLE ti_bkpf into wa_Bkpf with key bukrs = wa_bsis-BUKRS
                                               belnr = wa_bsis-BELNR_orig
                                               gjahr = wa_bsis-GJaHR.

      if wa_bkpf-bvorg is not INITIAL.
        "s es intercompany se busca con el doc intercompany
        read table ti_bse into wa_bse with key BUKRS_CLR = wa_bkpf-multi_bukrs
                                               BELNR_CLR = wa_bkpf-multi_belnr
                                               GJAHR_CLR = wa_bkpf-multi_gjahr.

        READ TABLE ti_payr into wa_payr with key multi_bukrs = wa_bse-BUKRS_clr
                                                 multi_belnr = wa_bse-BELNR_CLR.
        itab-multi = 'X'.
      else.
        "si NO es intercompany
        read table ti_bse into wa_bse with key BUKRS_CLR = wa_bsis-BUKRS
                                               BELNR_CLR = wa_bsis-BELNR
                                               GJAHR_CLR = wa_bsis-GJaHR.

        READ TABLE ti_payr into wa_payr with key ZBUKR = wa_bse-BUKRS_clr
                                                 vblnr = wa_bse-BELNR_CLR.
      endif.
    endif.
    "si el registro no existe en la payr se salta la posicion.
    if sy-subrc <> 0.
      continue.
    endif.

    itab-HBKID = wa_payr-HBKID.
    itab-hktid = wa_payr-HKTID.
    itab-CHECT = wa_payr-CHECT.

    READ TABLE ti_bseg into wa_bseg with key CHECT = wa_payr-CHECT.

    itab-hkontd     = wa_bseg-HKONT.
    itab-lifnr      = wa_bseg-lifnr.
    itab-ZLSCH      = wa_bseg-ZLSCH.
    itab-ZZMOT_EMIS = wa_bseg-ZZMOT_EMIS.

    if wa_bsis-HKONT+9(1) eq '2'.
      itab-ESTADO = 'EMISION'.
    elseif wa_bsis-HKONT+9(1) eq '5'.
      itab-ESTADO = 'EMISION'.
    elseif wa_bsis-HKONT+9(1) eq '6'.
      itab-ESTADO = 'CAD.FIS'.
    elseif wa_bsis-HKONT+9(1) eq '7'.
      itab-ESTADO = 'CAD.ELC'.
    elseif wa_bsis-HKONT+9(1) eq '9'.
      itab-ESTADO = 'REVALIDADO'.
    endif.

    APPEND itab.
  endloop.

ENDFORM.                    " CREA_ALV
*&---------------------------------------------------------------------*
*&      Form  SELECCIONA2
*&---------------------------------------------------------------------*
*     Se seleccionan los datos correspondientes al segundo tab
*     CAMBIO PAGO POR COMPROBANTE
*----------------------------------------------------------------------*
FORM SELECCIONA2 .
* rangos y variables
  RAnges: r_budat for bsas-augdt.
  data: lv_zuonr like bsis-zuonr.
  data: lv_bukrs like bkpf-BUKRS.
  data: lv_gjahr like bkpf-GJaHR.
  data: lv_belnr like bkpf-belnr.
  data: lv_lifnr like bsik-lifnr.
  data: lv_kunnr like bsid-kunnr.

  "Rescatamos los cuentas correspondientes en la tabla mantenedora
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  select * into CORRESPONDING FIELDS OF TABLE ti_ZFITR020_T05
*    from ZFITR020_T05
*    where bukrs eq p_bukrs2
*      and hbkid eq p_hbkid2
*      and hktid eq p_hktid2.
*
* NEW CODE
  SELECT *
 into CORRESPONDING FIELDS OF TABLE ti_ZFITR020_T05
    from ZFITR020_T05
    where bukrs eq p_bukrs2
      and hbkid eq p_hbkid2
      and hktid eq p_hktid2 ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

  READ TABLE ti_ZFITR020_T05 into wa_ZFITR020_T05 index 1.

  loop at p_belnr2.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT single * into CORRESPONDING FIELDS OF wa_bkpf
*      from bkpf
*      where BUKRS eq p_bukrs2
*        and belnr eq p_belnr2-low
*        and GJaHR eq p_gjahr2.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  into CORRESPONDING FIELDS OF wa_bkpf
      from bkpf
      where BUKRS eq p_bukrs2
        and belnr eq p_belnr2-low
        and GJaHR eq p_gjahr2 ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

    if wa_bkpf-bvorg is not INITIAL.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT single bukrs GJaHR BELNR into (lv_bukrs, lv_gjahr, lv_belnr)
*        from bvor
*        where bvorg eq wa_bkpf-bvorg
*          and BUKRS <> p_bukrs2.
*
* NEW CODE
      SELECT bukrs GJaHR BELNR
      UP TO 1 ROWS  into (lv_bukrs, lv_gjahr, lv_belnr)
        from bvor
        where bvorg eq wa_bkpf-bvorg
          and BUKRS <> p_bukrs2 ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      select single lifnr into lv_lifnr "el acreedor
*        from bsik
*        where bukrs eq lv_bukrs
*          and GJaHR eq lv_gjahr
*          and belnr eq lv_belnr.
*
* NEW CODE
      SELECT lifnr
      UP TO 1 ROWS  into lv_lifnr "el acreedor
        from bsik
        where bukrs eq lv_bukrs
          and GJaHR eq lv_gjahr
          and belnr eq lv_belnr ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT single kunnr into lv_kunnr "el deudor
*        from bsid
*        where bukrs eq p_bukrs2
*          and GJaHR eq p_gjahr2
*          and belnr eq p_belnr2-low.
*
* NEW CODE
      SELECT kunnr
      UP TO 1 ROWS  into lv_kunnr "el deudor
        from bsid
        where bukrs eq p_bukrs2
          and GJaHR eq p_gjahr2
          and belnr eq p_belnr2-low ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

      wa_bkpf-multi_kunnr = lv_kunnr.
      wa_bkpf-multi_lifnr = lv_lifnr.
      wa_bkpf-multi_bukrs = lv_bukrs.
      wa_bkpf-multi_belnr = lv_belnr.
      wa_bkpf-multi_gjahr = lv_gjahr.

      wa_bkpf-ingre_bukrs = p_bukrs2.
      wa_bkpf-ingre_belnr = p_belnr2-low.
      wa_bkpf-ingre_gjahr = p_gjahr2.
      APPEND wa_bkpf to ti_bkpf.

    endif.

    "PRIMERO SE VERIFICA SI EL COMPROBANTE CORRESPONDE A
    "UN CHEQUE ENTRANDO A LA PAYR
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*    select * APPENDING CORRESPONDING FIELDS OF TABLE ti_payr
*      from payr
*      where ZBUKR eq p_bukrs2
*        and hbkid eq p_hbkid2
*        and hktid eq p_hktid2
*        and VBLNR eq p_belnr2-low
*        and GJaHR eq p_gjahr2
*        AND voidr eq '00' "cheque NO anulado
*        and xbanc eq ' '  "cheque NO cobrado
*            .
*
* NEW CODE
    SELECT * APPENDING CORRESPONDING FIELDS OF TABLE ti_payr

      from payr
      where ZBUKR eq p_bukrs2
        and hbkid eq p_hbkid2
        and hktid eq p_hktid2
        and VBLNR eq p_belnr2-low
        and GJaHR eq p_gjahr2
        AND voidr eq '00' "cheque NO anulado
        and xbanc eq ' '  "cheque NO cobrado
             ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

  endloop.

*Si la consulta a la PAYR es exitosa es porque el comprobante
*corresponde a Cheques de lo contrario corresponde a Vale Vista
*u Orden de pago
  if ti_payr[] is initial."if sy-subrc <> 0.

    loop at p_belnr2.
      "CONSULTA DE PARTIDA ABIERTA POR COMPROBANTE ORIGINAL
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*      select *
*      into CORRESPONDING FIELDS OF wa_bsis
*        from bsis
*        where bukrs eq p_bukrs2
*        and ( hkont eq wa_ZFITR020_T05-CTA_SALDO
*           or hkont eq wa_ZFITR020_T05-CTA_DEPOS
*           or hkont eq wa_ZFITR020_T05-CTA_CHEQS
*           or hkont eq wa_ZFITR020_T05-CTA_CARGOS
*           or hkont eq wa_ZFITR020_T05-CTA_ABONOS
*           or hkont eq wa_ZFITR020_T05-CTA_TRANS
*           or hkont eq wa_ZFITR020_T05-CTA_CDCO_F
*           or hkont eq wa_ZFITR020_T05-CTA_CDCO_E
*           or hkont eq wa_ZFITR020_T05-CTA_CDCO_F2
*           or hkont eq wa_ZFITR020_T05-REVALIDAD )
*          and GJaHR eq p_gjahr2
*          and BELNR eq p_belnr2-low.
*
* NEW CODE
      SELECT *

      into CORRESPONDING FIELDS OF wa_bsis
        from bsis
        where bukrs eq p_bukrs2
        and ( hkont eq wa_ZFITR020_T05-CTA_SALDO
           or hkont eq wa_ZFITR020_T05-CTA_DEPOS
           or hkont eq wa_ZFITR020_T05-CTA_CHEQS
           or hkont eq wa_ZFITR020_T05-CTA_CARGOS
           or hkont eq wa_ZFITR020_T05-CTA_ABONOS
           or hkont eq wa_ZFITR020_T05-CTA_TRANS
           or hkont eq wa_ZFITR020_T05-CTA_CDCO_F
           or hkont eq wa_ZFITR020_T05-CTA_CDCO_E
           or hkont eq wa_ZFITR020_T05-CTA_CDCO_F2
           or hkont eq wa_ZFITR020_T05-REVALIDAD )
          and GJaHR eq p_gjahr2
          and BELNR eq p_belnr2-low ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

        wa_bsis-belnr_orig = p_belnr2-low.
        wa_bsis-GJaHR_orig = p_gjahr2.
        APPEND wa_bsis to ti_bsis.
      ENDSELECT.
    endloop.

*    IF SY-SUBRC <> 0.
    if ti_bsis[] is INITIAL.
      loop at p_belnr2.
        "SI LA CONSULTA ES NEGATIVA  SE PROCEDE A CONSULTAR
        "EN LA BSIS POR EL CAMPO ASIGNACION ZOUNR = belnr + gjahr
        clear lv_zuonr.
        CONCATENATE p_belnr2-low p_gjahr2 into lv_zuonr.

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*        select *
*          into CORRESPONDING FIELDS OF wa_bsis
*            from bsis
*            where bukrs eq p_bukrs2
*            and ( hkont eq wa_ZFITR020_T05-CTA_SALDO
*               or hkont eq wa_ZFITR020_T05-CTA_DEPOS
*               or hkont eq wa_ZFITR020_T05-CTA_CHEQS
*               or hkont eq wa_ZFITR020_T05-CTA_CARGOS
*               or hkont eq wa_ZFITR020_T05-CTA_ABONOS
*               or hkont eq wa_ZFITR020_T05-CTA_TRANS
*               or hkont eq wa_ZFITR020_T05-CTA_CDCO_F
*               or hkont eq wa_ZFITR020_T05-CTA_CDCO_E
*               or hkont eq wa_ZFITR020_T05-CTA_CDCO_F2
*               or hkont eq wa_ZFITR020_T05-REVALIDAD )
**              and GJaHR eq p_gjahr2 "cuando entra por cheque es
*              and ZUONR eq lv_zuonr  "independiente del año
*                  .
*
* NEW CODE
        SELECT *

          into CORRESPONDING FIELDS OF wa_bsis
            from bsis
            where bukrs eq p_bukrs2
            and ( hkont eq wa_ZFITR020_T05-CTA_SALDO
               or hkont eq wa_ZFITR020_T05-CTA_DEPOS
               or hkont eq wa_ZFITR020_T05-CTA_CHEQS
               or hkont eq wa_ZFITR020_T05-CTA_CARGOS
               or hkont eq wa_ZFITR020_T05-CTA_ABONOS
               or hkont eq wa_ZFITR020_T05-CTA_TRANS
               or hkont eq wa_ZFITR020_T05-CTA_CDCO_F
               or hkont eq wa_ZFITR020_T05-CTA_CDCO_E
               or hkont eq wa_ZFITR020_T05-CTA_CDCO_F2
               or hkont eq wa_ZFITR020_T05-REVALIDAD )
*              and GJaHR eq p_gjahr2 "cuando entra por cheque es
              and ZUONR eq lv_zuonr  "independiente del año
                   ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
          wa_bsis-belnr_orig = p_belnr2-low.
          wa_bsis-GJaHR_orig = p_gjahr2.
          APPEND wa_bsis to ti_bsis.
        ENDSELECT.
      endloop.
    ENDIF.

  else.
    loop at ti_payr into wa_payr.
*SE DEBE UBICAR EL UNICO DOCUMENTO QUE TENGA LA PARTIDA ABIERTA
*PARA COMPENSAR Y GENERAR UNA NUEVA PARTIDA, ESTE DOCUMENTO
*PUEDER SER EL ORIGINAL U OTRO.

      "CONSULTA DE PARTIDA ABIERTA POR COMPROBANTE ORIGINAL
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*      select *
*        into CORRESPONDING FIELDS OF wa_bsis
*        from bsis
*        where bukrs eq wa_payr-ZBUKR
*        and ( hkont eq wa_payr-UBHKT
*           or hkont eq wa_ZFITR020_T05-CTA_SALDO
*           or hkont eq wa_ZFITR020_T05-CTA_DEPOS
*           or hkont eq wa_ZFITR020_T05-CTA_CHEQS
*           or hkont eq wa_ZFITR020_T05-CTA_CARGOS
*           or hkont eq wa_ZFITR020_T05-CTA_ABONOS
*           or hkont eq wa_ZFITR020_T05-CTA_TRANS
*           or hkont eq wa_ZFITR020_T05-CTA_CDCO_F
*           or hkont eq wa_ZFITR020_T05-CTA_CDCO_E
*           or hkont eq wa_ZFITR020_T05-CTA_CDCO_F2
*           or hkont eq wa_ZFITR020_T05-REVALIDAD )
*          and GJaHR eq wa_payr-GJaHR
*          and BELNR eq wa_payr-vbLNR
*            .
*
* NEW CODE
      SELECT *

        into CORRESPONDING FIELDS OF wa_bsis
        from bsis
        where bukrs eq wa_payr-ZBUKR
        and ( hkont eq wa_payr-UBHKT
           or hkont eq wa_ZFITR020_T05-CTA_SALDO
           or hkont eq wa_ZFITR020_T05-CTA_DEPOS
           or hkont eq wa_ZFITR020_T05-CTA_CHEQS
           or hkont eq wa_ZFITR020_T05-CTA_CARGOS
           or hkont eq wa_ZFITR020_T05-CTA_ABONOS
           or hkont eq wa_ZFITR020_T05-CTA_TRANS
           or hkont eq wa_ZFITR020_T05-CTA_CDCO_F
           or hkont eq wa_ZFITR020_T05-CTA_CDCO_E
           or hkont eq wa_ZFITR020_T05-CTA_CDCO_F2
           or hkont eq wa_ZFITR020_T05-REVALIDAD )
          and GJaHR eq wa_payr-GJaHR
          and BELNR eq wa_payr-vbLNR
             ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
        wa_bsis-belnr_orig = wa_payr-vbLNR.
        wa_bsis-GJaHR_orig = wa_payr-GJaHR.
        APPEND wa_bsis to ti_bsis.
      ENDSELECT.
*      if sy-subrc <> 0.
      if ti_bsis[] is INITIAL.
        "SI LA CONSULTA ES NEGATIVA  SE PROCEDE A CONSULTAR
        "EN LA BSIS POR EL CAMPO ASIGNACION ZOUNR = chect
        clear lv_zuonr.
        lv_zuonr = wa_payr-CHECT.

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*        select *
*          into CORRESPONDING FIELDS OF wa_bsis
*          from bsis
*          where bukrs eq wa_payr-ZBUKR
*          and ( hkont eq wa_payr-UBHKT
*             or hkont eq wa_ZFITR020_T05-CTA_SALDO
*             or hkont eq wa_ZFITR020_T05-CTA_DEPOS
*             or hkont eq wa_ZFITR020_T05-CTA_CHEQS
*             or hkont eq wa_ZFITR020_T05-CTA_CARGOS
*             or hkont eq wa_ZFITR020_T05-CTA_ABONOS
*             or hkont eq wa_ZFITR020_T05-CTA_TRANS
*             or hkont eq wa_ZFITR020_T05-CTA_CDCO_F
*             or hkont eq wa_ZFITR020_T05-CTA_CDCO_E
*             or hkont eq wa_ZFITR020_T05-CTA_CDCO_F2
*             or hkont eq wa_ZFITR020_T05-REVALIDAD )
**            and GJaHR eq wa_payr-GJaHR "cuando entra por cheque es
*            and ZUONR eq lv_zuonr       "independiente del año
*              .
*
* NEW CODE
        SELECT *

          into CORRESPONDING FIELDS OF wa_bsis
          from bsis
          where bukrs eq wa_payr-ZBUKR
          and ( hkont eq wa_payr-UBHKT
             or hkont eq wa_ZFITR020_T05-CTA_SALDO
             or hkont eq wa_ZFITR020_T05-CTA_DEPOS
             or hkont eq wa_ZFITR020_T05-CTA_CHEQS
             or hkont eq wa_ZFITR020_T05-CTA_CARGOS
             or hkont eq wa_ZFITR020_T05-CTA_ABONOS
             or hkont eq wa_ZFITR020_T05-CTA_TRANS
             or hkont eq wa_ZFITR020_T05-CTA_CDCO_F
             or hkont eq wa_ZFITR020_T05-CTA_CDCO_E
             or hkont eq wa_ZFITR020_T05-CTA_CDCO_F2
             or hkont eq wa_ZFITR020_T05-REVALIDAD )
*            and GJaHR eq wa_payr-GJaHR "cuando entra por cheque es
            and ZUONR eq lv_zuonr       "independiente del año
               ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
          wa_bsis-belnr_orig = wa_payr-vbLNR.
          wa_bsis-GJaHR_orig = wa_payr-GJaHR.
          APPEND wa_bsis to ti_bsis.
        ENDSELECT.

      endif.
    endloop.
  endif.

  if ti_bsis[] is INITIAL.
    MESSAGE 'No se encontraron partidas abiertas' type 'E'.
  endif.
  loop at ti_bsis into wa_bsis.
    clear wa_bkpf.
    READ TABLE ti_bkpf into wa_Bkpf with key bukrs      = wa_bsis-bukrs
                                             belnr      = wa_bsis-belnr_orig
                                             gjahr      = wa_bsis-GJaHR.

    if wa_bkpf-bvorg is not INITIAL.

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*      select * APPENDING CORRESPONDING FIELDS OF TABLE ti_bse
*        from bse_clr "FOR ALL ENTRIES IN ti_bsis
*        where BUKRS_CLR = wa_bkpf-multi_bukrs
*          and BELNR_CLR = wa_bkpf-multi_belnr
*          and GJAHR_CLR = wa_bkpf-multi_gjahr
*              .
*
* NEW CODE
      SELECT * APPENDING CORRESPONDING FIELDS OF TABLE ti_bse

        from bse_clr "FOR ALL ENTRIES IN ti_bsis
        where BUKRS_CLR = wa_bkpf-multi_bukrs
          and BELNR_CLR = wa_bkpf-multi_belnr
          and GJAHR_CLR = wa_bkpf-multi_gjahr
               ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
    else.

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*      select * APPENDING CORRESPONDING FIELDS OF TABLE ti_bse
*        from bse_clr "FOR ALL ENTRIES IN ti_bsis
*        where BUKRS_CLR = wa_bsis-BUKRS
*          and BELNR_CLR = wa_bsis-belnr_orig
*          and GJAHR_CLR = wa_bsis-GJAHR_orig
*              .
*
* NEW CODE
      SELECT * APPENDING CORRESPONDING FIELDS OF TABLE ti_bse

        from bse_clr "FOR ALL ENTRIES IN ti_bsis
        where BUKRS_CLR = wa_bsis-BUKRS
          and BELNR_CLR = wa_bsis-belnr_orig
          and GJAHR_CLR = wa_bsis-GJAHR_orig
               ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
    endif.
  endloop.

  if ti_bse[] is not INITIAL.
    "consulta el acreedor y el motivo de emision
SELECT * INTO CORRESPONDING FIELDS OF TABLE ti_bseg
from bseg FOR ALL ENTRIES IN ti_Bse
where belnr = ti_bse-BELNR
and GJaHR = ti_bse-GJaHR
and bukrs = ti_bse-BUKRS
and buzei = ti_bse-BUZEI
and ZZMOT_EMIS <> ' '
*Begin of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 24/12/2019 EY_DES04 ECDK917080 *
*.
ORDER BY PRIMARY KEY.
*End of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 24/12/2019 EY_DES04 ECDK917080 *
  endif.

ENDFORM.                    " SELECCIONA2
*&---------------------------------------------------------------------*
*&      Form  CREA_ALV2
*&---------------------------------------------------------------------*
*       Crea el ALV de salida de la segunda pestaña
*       CAMBIO PAGO POR COMPROBANTE
*----------------------------------------------------------------------*
FORM CREA_ALV2 .
  refresh itab.

  loop at ti_bsis into wa_bsis.
    clear itab.
    clear wa_payr.
    CLEAR wa_bse.
    clear wa_bseg.
    clear wa_bkpf.

    MOVE-CORRESPONDING wa_bsis to itab.

    READ TABLE ti_payr into wa_payr with key ZBUKR =  wa_bsis-BUKRS
                                             VBLNR  = wa_bsis-BELNR_orig.

    itab-HBKID = p_hbkid2.
    itab-hktid = p_hktid2.
    itab-CHECT = wa_payr-CHECT.

    READ TABLE ti_bkpf into wa_Bkpf with key bukrs = wa_bsis-bukrs
                                             belnr = wa_bsis-belnr_orig
                                             gjahr = wa_bsis-GJaHR.

    if wa_bkpf-bvorg is not INITIAL.
      read table ti_bse into wa_bse with key BUKRS_CLR = wa_bkpf-multi_bukrs
                                             BELNR_CLR = wa_bkpf-multi_belnr
                                             GJAHR_CLR = wa_bkpf-multi_gjahr.
      itab-multi = 'X'.

    else.
      read table ti_bse into wa_bse with key BUKRS_CLR = wa_bsis-BUKRS
                                             BELNR_CLR = wa_bsis-belnr_orig
                                             GJAHR_CLR = wa_bsis-GJaHR_orig.
      clear itab-multi.
    endif.
    READ TABLE ti_bseg into wa_bseg with key bukrs = wa_bse-BUKRS
                                             belnr = wa_bse-belnr
                                             GJaHR = wa_bse-GJaHR.


    itab-hkontd     = wa_bseg-HKONT.
    itab-lifnr      = wa_bseg-lifnr.
    itab-ZLSCH      = wa_bseg-ZLSCH.
    itab-ZZMOT_EMIS = wa_bseg-ZZMOT_EMIS.

    if wa_bsis-HKONT+9(1) eq '2'.
      itab-ESTADO = 'EMISION'.
    elseif wa_bsis-HKONT+9(1) eq '5'.
      itab-ESTADO = 'EMISION'.
    elseif wa_bsis-HKONT+9(1) eq '6'.
      itab-ESTADO = 'CAD.FIS'.
    elseif wa_bsis-HKONT+9(1) eq '7'.
      itab-ESTADO = 'CAD.ELC'.
    elseif wa_bsis-HKONT+9(1) eq '9'.
      itab-ESTADO = 'REVALIDADO'.
    endif.

    APPEND itab.
  endloop.

ENDFORM.                                                    " CREA_ALV2
*&---------------------------------------------------------------------*
*&      Form  bdc
*&---------------------------------------------------------------------*
*       Subrutina que asigna los valores correspondiente a la
*       estructura del batch input
*----------------------------------------------------------------------*
FORM bdc  USING    a
                   b
                   c.

  CLEAR bdcdata.
  IF a = 'X'.
    bdcdata-program   = b.
    bdcdata-dynpro    = c.
    bdcdata-dynbegin  = a.
  ELSE.
    bdcdata-fnam = b.
    WRITE c TO bdcdata-fval LEFT-JUSTIFIED.
  ENDIF.
  APPEND bdcdata.

ENDFORM.                    " BDC
*&---------------------------------------------------------------------*
*&      Form  ANULA_CHEQUE
*----------------------------------------------------------------------*
*      Anula cheques del alv con batch input tx: fch9
*----------------------------------------------------------------------*
FORM ANULA_CHEQUE  USING    ITAB_CHECT like payr-CHECT
                            ITAB_HBKID like payr-HBKID
                            ITAB_HKTID like payr-HKTID
                            ITAB_BUKRS like payr-ZBUKR.
  REFRESH bdcdata.
  CLEAR bdcdata.
*--------------------------------------------------------------------*
*Cambiar modo de visualizacion
* A	Visual.pant.(todas)
* E	Visualizar sólo errores
* N	Sin visualización
  w_mode = 'N'.
*--------------------------------------------------------------------*
  PERFORM bdc USING:
            'X' 'SAPMFCHK' '0800',            "ingresa al programa
            '' 'BDC_CURSOR' 'PAYR-ZBUKR',     "se posiciona en el campo sociedad
            '' 'PAYR-ZBUKR' ITAB_BUKRS,       "asigna el valor correspondiente
            '' 'BDC_CURSOR' 'PAYR-HBKID',     "se posiciona en el cambo banco propio
            '' 'PAYR-HBKID' ITAB_HBKID,       "asigna el valor correspondiente
            '' 'BDC_CURSOR' 'PAYR-HKTID',     "se posiciona en el campo cuentas
            '' 'PAYR-HKTID' ITAB_HKTID,       "asigna el valor correspondiente
            '' 'BDC_CURSOR' 'PAYR-CHECT',     "se posiciona en el campo cheque
            '' 'PAYR-CHECT' ITAB_CHECT,       "asigna el valor correspondiente
            '' 'BDC_CURSOR' 'PAYR-VOIDR',     "se posiciona en el motivo de anulacion
            '' 'PAYR-VOIDR' '99',             "asigna el motivo constante
            '' 'BDC_OKCODE' '=EDEL'.          "
  CALL TRANSACTION 'FCH9' USING bdcdata MODE w_mode UPDATE 'S' MESSAGES INTO messtab.

ENDFORM.                    " ANULA_CHEQUE
*&---------------------------------------------------------------------*
*&      Form  CONVIERTE_MENSAJE
*&---------------------------------------------------------------------*
*       Convierte en string el mensaje estandar
*----------------------------------------------------------------------*
FORM CONVIERTE_MENSAJE  USING    P_SY_MSGID like sy-msgid
                                 P_SY_MSGNO like sy-msgno
                        CHANGING RETURN_MESSAGE   .

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE * FROM t100 WHERE sprsl = 'S'
*                             AND   arbgb = sy-msgid
*                             AND   msgnr = sy-msgno.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  FROM t100 WHERE sprsl = 'S'
                             AND   arbgb = sy-msgid
                             AND   msgnr = sy-msgno ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
  IF sy-subrc = 0.
    return_message = t100-text.
    IF return_message CS '&1'.
      REPLACE '&1' WITH sy-msgv1 INTO return_message.
      REPLACE '&2' WITH sy-msgv2 INTO return_message.
      REPLACE '&3' WITH sy-msgv3 INTO return_message.
      REPLACE '&4' WITH sy-msgv4 INTO return_message.
    ELSE.
      REPLACE '&' WITH sy-msgv1 INTO return_message.
      REPLACE '&' WITH sy-msgv2 INTO return_message.
      REPLACE '&' WITH sy-msgv3 INTO return_message.
      REPLACE '&' WITH sy-msgv4 INTO return_message.
    ENDIF.
    CONDENSE return_message.
  endif.

ENDFORM.                    " CONVIERTE_MENSAJE

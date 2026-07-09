*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES02 > *
*& Description: < ReSQ Correction > *
*& Date: <24-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Report  ZFITR0040
*&---------------------------------------------------------------------
*&  Compañía   : Banmedica
*&  Autor      : Crystalis Consulting Chile - Pablo Cabezas Melendez
*&  Funcional  : Crystalis Consulting Chile - Oscar Agudelo Prado
*&  Fecha      : 30.08.2013
*&  Objetivo   : Solución integral de pagos
*&--------------------------------------------------------------------
* Proceso: 1006 REVALIDAC CHEQUE
*--------------------------------------------------------------------*
* Pestaña: REVEVALIDACION CHEQUE
*--------------------------------------------------------------------*
REPORT  ZFITR0040.

TYPE-POOLS: slis.

tables: bsad, bsid, ZFITR020_T05, payr, bseg, t100.
**********************************************************************
*     tabla  ALV de salida.
**********************************************************************
TYPES: BEGIN OF out,
       flag         TYPE c,                   "Flag para ejecutar la funcion
       BUKRS        like bsis-BUKRS,          "Sociedad
       HKONT        like bsis-HKONT,          "Cuenta de mayor de la contabilidad principal
       zuonr        like bsis-zuonr,          "Número de asignación
       GJaHR        like bsis-GJaHR,          "Ejercicio
       BELNR        like bsis-BELNR,          "Número de un documento contable
       BUZEI        like bsis-BUZEI,          "Número del apunte contable dentro del documento contable
       BUDAT        like bsis-BUDAT,          "Fecha de contabilización en el documento
       bldat        like bsis-bldat,          "Fecha de documento en documento
       blart        like bsis-blart,          "Clase de documento
       SHKZG        like bsis-SHKZG,          "Indicador debe/haber
       WRBTR        like bsis-WRBTR,          "Importe en la moneda del documento
       WAERS        like bsis-WAERS,          "Clave de moneda
       HBKID        like ZFITR020_T05-hbkid,  "Clave breve para banco propio
       HKTID        type n LENGTH 5 ,         "Clave breve para un banco/cuenta
       CHECT        like payr-chect,          "Nº de cheque
       field_style  TYPE lvc_t_styl,          "FOR DISABLE cell
       ESTADO       type c LENGTH 10,         "segun la cuenta de mayor: emitido, revalidado, caduco,etc.
       ZZMOT_EMIS   like bseg-ZZMOT_EMIS,     "Motivos de emisión
       Multi        type c                 ,"si es multisociedad que se marque el flag
       maternal     TYPE c,
      END OF out.

DATA: itab TYPE TABLE OF out WITH HEADER LINE.
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
       END OF ty_bsis.

DATA: ti_bsis TYPE TABLE OF ty_bsis,
      wa_bsis LIKE LINE OF ti_bsis.

TYPES: BEGIN OF ty_ZFITR020_T05                  ,
        BUKRS      like bsis-BUKRS               , "Sociedad
        CTA_CHEQS  like ZFITR020_T05-CTA_CHEQS   , "Cuenta de mayor
        CTA_TRANS  like ZFITR020_T05-CTA_TRANS   , "Cuenta de mayor
        CTA_CDCO_E like ZFITR020_T05-CTA_CDCO_E  , "Cuenta de mayor
        CTA_CDCO_F like ZFITR020_T05-CTA_CDCO_F  , "Cuenta de mayor
        REVALIDAD  like ZFITR020_T05-REVALIDAD   , "Cuenta de mayor
        HBKID      like ZFITR020_T05-HBKID       , "Clave breve para banco propio
        HKTID      like ZFITR020_T05-HKTID       , "Clave breve para un banco/cuenta
       END OF ty_ZFITR020_T05.

DATA: ti_ZFITR020_T05 TYPE TABLE OF ty_ZFITR020_T05,
      wa_ZFITR020_T05 LIKE LINE OF ti_ZFITR020_T05.

TYPES: BEGIN OF ty_bsas,
        belnr like bsas-belnr, "Número de un documento contable
        GJAHR like bsas-GJAHR, "Ejercicio
        AUGBL like bsas-AUGBL, "Número del documento de compensación
        bukrs like bsas-BUKRS, "Sociedad
        budat like bsas-budat, "Fecha de contabilización en el documento
        gjahr_bsis like bsas-GJaHR, "periodo del documento a compensar
        bukrs_bsis like bsas-bukrs,
        multi      type c,
       END OF ty_bsas.

DATA: ti_bsas TYPE TABLE OF ty_bsas WITH HEADER LINE,
      wa_bsas LIKE LINE OF ti_bsas.
DATA: ti_bsas2 TYPE TABLE OF ty_bsas WITH HEADER LINE.

TYPES: BEGIN OF ty_bseg,
        bukrs like bsas-BUKRS          , "Sociedad
        belnr like bsas-belnr          , "Número de un documento contable
        gjahr like bseg-GJaHR          , "Ejercicio
        ZLSCH like bseg-ZLSCH          , "Vía de pago
        ZZMOT_EMIS like bseg-ZZMOT_EMIS, "Motivos de emisión
       END OF ty_bseg.

DATA: ti_bseg TYPE TABLE OF ty_bseg,
      wa_bseg LIKE LINE OF ti_bseg.

TYPES: BEGIN OF ty_payr,
        ZBUKR like payr-ZBUKR, "Sociedad pagadora
        VBLNR like payr-VBLNR, "Número del documento de pago
        GJAHR like payr-GJAHR, "Ejercicio
        chect like payr-chect, "Nº de cheque
        HBKID like payr-HBKID, "Clave breve para banco propio
        HKTID like payr-HKTID, "Clave breve para un banco/cuenta
        RZAWE like payr-RZAWE, "Vía de pago
        UBHKT like payr-UBHKT, "Nº de cta.mayor para nuestra cta.bancaria / cta.transitoria
        ZALDT like payr-ZALDT, "Fecha de pago prevista (vencimiento 1)
        RWBTR like payr-RWBTR, "Importe pagado en la moneda del pago
        WAERS like payr-WAERS, "Clave de moneda
       END OF ty_payr.

DATA: ti_payr TYPE TABLE OF ty_payr,
      wa_payr LIKE LINE OF ti_payr.

TYPES: BEGIN OF ty_payr_aux   , "(Para convertir del campo chect a zuonr de 13 a 18 caracteres)
        ZBUKR like payr-ZBUKR , "Sociedad pagadora
        VBLNR like payr-VBLNR , "Número del documento de pago
        GJAHR like payr-GJAHR , "Ejercicio
        chect type c LENGTH 18, "Nº de cheque
        HBKID like payr-HBKID , "Clave breve para banco propio
        HKTID like payr-HKTID , "Clave breve para un banco/cuenta
        RZAWE like payr-RZAWE , "Vía de pago
        UBHKT like payr-UBHKT , "Nº de cta.mayor para nuestra cta.bancaria / cta.transitoria
        ZALDT like payr-ZALDT , "Fecha de pago prevista (vencimiento 1)
        RWBTR like payr-RWBTR , "Importe pagado en la moneda del pago
        WAERS like payr-WAERS , "Clave de moneda
       END OF ty_payr_aux.

DATA: ti_payr_aux TYPE TABLE OF ty_payr_aux,
      wa_payr_aux LIKE LINE OF ti_payr_aux .

types: begin of ty_return,                    "tabla de retorno de mensaje de la funcion
        bukrs      like bsas-BUKRS          , "alv de salida 2
        belnr      like bsas-BELNR          ,
        gjahr      like bsas-GJaHR          ,
        TYPE       like bapiret2-TYPE       ,
        ID         like bapiret2-ID         ,
        NUMBER     like bapiret2-NUMBER     ,
        MESSAGE_V1 like bapiret2-MESSAGE_V1 ,
        MESSAGE_V2 like bapiret2-MESSAGE_V2 ,
        MESSAGE_V3 like bapiret2-MESSAGE_V3 ,
        MESSAGE_V4 like bapiret2-MESSAGE_V4 ,
        MESSAGE    type c LENGTH 150,
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

data: l_t_blntab  type blntab occurs 0 with header line.
data: l_t_ftpost  type ftpost occurs 0 with header line.
data: l_t_ftclear type ftclear occurs 0 with header line.
data: l_t_fttax type fttax occurs 0 with header line.

data: l_group like apqi-groupid,
      l_tproceso(5) type c.

data l_ver_batch type c.
data c_fipi_trans_compensacion    like sy-tcode value 'FB05'.
*--------------------------------------------------------------------*
*   Primera pestaña: REVEVALIDACION CHEQUE
*--------------------------------------------------------------------*
selection-screen begin of screen 101 as subscreen.
selection-screen begin of block b1 with frame title text-t00.
PARAMETERS       :   p_bukrs1   like payr-ZBUKR memory id buk  OBLIGATORY.
PARAMETERS       :   p_hbkid1   like payr-hbkid OBLIGATORY
                   , p_hktid1   like payr-hktid  OBLIGATORY.
PARAMETERS       :   p_budat1   like BSAD-budat DEFAULT sy-datum OBLIGATORY.
SELECT-OPTIONS   :   p_chect1   FOR  payr-chect no INTERVALS OBLIGATORY.
selection-screen end of block b1.
selection-screen end of screen 101.
*--------------------------------------------------------------------*

selection-screen begin of tabbed block t1 for 20 lines.
selection-screen tab (30) name1 user-command ucomm1 default screen 101.
selection-screen end of block t1.

AT SELECTION-SCREEN.
  "determino el tab que se ejecuto el programa y lo asigno a la variable
  "tabname para hacer procesos de busquedas distintos
  CASE sy-dynnr.
    WHEN 1000.
      CASE sy-ucomm.
        WHEN 'UCOMM1'.  tabname = 101.
      ENDCASE.
  ENDCASE.

INITIALIZATION.
  name1 = 'REVEVALIDACION CHEQUE'.

*------------------------------------------------------------------------------
* Comienzo de Programa
*------------------------------------------------------------------------------
START-OF-SELECTION.
  "dependiendo del tab que venga se realizan busquedas distintas las cuales
  "tienen un unico alv de salida
*--------------------------------------------------------------------*
*   REVEVALIDACION CHEQUE
*--------------------------------------------------------------------*
  if tabname eq '101' or tabname is INITIAL.
    if p_bukrs1 is INITIAL.
      MESSAGE 'El campo sociedad no puede estar vacio' type 'E'.
    endif.
    PERFORM selecciona.
    PERFORM crea_alv.
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

  wa_fieldcat-fieldname = 'ESTADO'.
  wa_fieldcat-scrtext_m = 'ESTAD.ACT'.
  wa_fieldcat-outputlen = 10.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR  wa_fieldcat.


  wa_fieldcat-fieldname = 'MULTI'.
  wa_fieldcat-scrtext_m = 'Doc.Multi'.
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

* Set layout field for field attributes(i.e. input/output)
  gd_layout-stylefname = 'FIELD_STYLE'.
  gd_layout-zebra      = 'X'.
  gd_layout-CWIDTH_OPT = 'X'.
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
    WHEN 'PICK' OR '&IC1'. "click sobre el alv
      IF rs_selfield-fieldname = 'BELNR'.
        READ TABLE itab with key BELNR = rs_selfield-value.
        SET PARAMETER ID 'BLN' FIELD rs_selfield-value.
        SET PARAMETER ID 'BUK' FIELD itab-BUKRS.
        SET PARAMETER ID 'GJR' FIELD itab-GJaHR.
        CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
      ENDIF.
      IF rs_selfield-fieldname = 'FLAG'. "deseleccion o selecciona
        READ TABLE itab index rs_selfield-tabindex.
        if itab-flag = 'X' and itab-ZZMOT_EMIS is not INITIAL.
          clear itab-flag.
        elseif itab-flag is INITIAL and itab-ZZMOT_EMIS is NOT INITIAL and itab-maternal is INITIAL.
          itab-flag = 'X'.
        endif.
        MODIFY itab INDEX rs_selfield-tabindex.
        rs_selfield-refresh = 'X'.
      endif.

    WHEN '&ALL2'. "marca todos
      LOOP AT itab.
        if itab-ZZMOT_EMIS is not INITIAL and itab-maternal is INITIAL.
          itab-flag = 'X'.
          MODIFY itab INDEX sy-tabix.
        ENDIF.
      ENDLOOP.
      rs_selfield-refresh = 'X'.

    WHEN '&SAL2'. "deselecciona todos
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

  "deshabilito el check box de la linea si la via de pago viene vacia
  LOOP AT itab .
    if itab-ZZMOT_EMIS is INITIAL or itab-MATERNAL eq 'X'.
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

  l_t_ftclear-agkoa = 'S'.          "CONSTANTE
  l_t_ftclear-agkon = t_itab-hkont. "HKONT ALV
  l_t_ftclear-agbuk = t_itab-BUKRS. "SOCIEDAD ALV
  l_t_ftclear-xnops = 'X'.          "CONSTANTE
*    l_t_ftclear-xfifo = ' '.
*    l_t_ftclear-agums = l_cme.
*    l_t_ftclear-avsid = ' '.
  l_t_ftclear-selfd = 'BELNR'.      "CONSTANTE
  CONCATENATE t_itab-BELNR t_itab-GJaHR into l_t_ftclear-selvon." = t_itab-belnr."BELNR ALV
*    l_t_ftclear-selbis = ' '.
  append l_t_ftclear.
**---------------------------------------------------------------------
*  BUDAT ALV
**---------------------------------------------------------------------
  l_t_ftpost-stype = 'K'.
  l_t_ftpost-count = '1'.
  l_t_ftpost-fnam = 'BKPF-BLDAT'.
  CONCATENATE t_itab-budat+6(2) t_itab-budat+4(2) t_itab-budat(4) into l_t_ftpost-fval. CONDENSE l_t_ftpost-fval.
  append l_t_ftpost.
**---------------------------------------------------------------------
*  Fe.contabilización DATO DE ENTRADA
**---------------------------------------------------------------------
  l_t_ftpost-fnam = 'BKPF-BUDAT'. "fecha de entrada
  CONCATENATE l_fecha+6(2) l_fecha+4(2) l_fecha(4) into l_t_ftpost-fval . condense l_t_ftpost-fval.
  append l_t_ftpost.
**---------------------------------------------------------------------
*  MES FECHA DE CONTB DE ENTRADA
**---------------------------------------------------------------------
  l_t_ftpost-fnam = 'BKPF-MONAT'. "mes fecha de entrada
  l_t_ftpost-fval = l_fecha+4(2).
  append l_t_ftpost.
**---------------------------------------------------------------------
*  SOCIEDAD ALV
**---------------------------------------------------------------------
  l_t_ftpost-fnam = 'BKPF-BUKRS'. "Sociedad Pantalla de entrada
  l_t_ftpost-fval = t_itab-bukrs.
  append l_t_ftpost.
**---------------------------------------------------------------------
*  TABLA ZFITR020_T03-TIPO_CTA CLASE_DOC 1006
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
*  ZOUNR ALV
**---------------------------------------------------------------------
  "CAMPO CHEQUE DEL ALV SI ES VACIO COLOCAR BELNR DEL ALV
  l_t_ftpost-fnam = 'BKPF-XBLNR'.
  l_t_ftpost-fval = t_itab-zuonr.
  append l_t_ftpost.
**---------------------------------------------------------------------
*  CONSTANTE
**---------------------------------------------------------------------
  l_t_ftpost-fnam = 'BKPF-BKTXT'. "Nombre de proceso
  l_t_ftpost-fval = l_nom_proceso."'REVALIDAC CHEQUE'.
  append l_t_ftpost.
**---------------------------------------------------------------------
*  CONCATENA "REVALIDACION CHEQUE"+ BANCO ALV+ ID DE CTA ALV
**---------------------------------------------------------------------
  l_t_ftpost-fnam = 'RF05A-AUGTX'.
  CONCATENATE l_nom_proceso ' - '  t_itab-HBKID ' - ' t_itab-HKTID into l_texto SEPARATED BY space.
  l_t_ftpost-fval = l_texto.
  append l_t_ftpost.
**---------------------------------------------------------------------
*  CONSTANTE
**---------------------------------------------------------------------
  l_t_ftpost-fnam = 'RF05A-NEWBS'.
  l_t_ftpost-fval = '50'.
  append l_t_ftpost.
**---------------------------------------------------------------------
*  CONSULTAR TABLA ZFITR020_T05 CAMPO REVALIDAD CON SOCIEDAD ALV - BANCO PROPIO ALV
**---------------------------------------------------------------------
  l_t_ftpost-fnam = 'RF05A-NEWKO'.
  l_t_ftpost-fval = l_cta_contrap.
  append l_t_ftpost.
**---------------------------------------------------------------------
* IMPORTE ALV
**---------------------------------------------------------------------
  data: l_monto(15) type c.
  l_t_ftpost-fnam = 'BSEG-WRBTR'. "monto
  write t_itab-WRBTR to l_monto currency 'CLP'.
  condense l_monto no-gaps.
  l_t_ftpost-fval = l_monto.
  append l_t_ftpost.
**---------------------------------------------------------------------
*  ZOUNR ALV
**---------------------------------------------------------------------
  l_t_ftpost-fnam = 'BSEG-ZUONR'.
  l_t_ftpost-fval = t_itab-zuonr.
  append l_t_ftpost.
**---------------------------------------------------------------------
*  CONCATENA "REVALIDACION CHEQUE"+ BANCO ALV+ ID DE CTA ALV
**---------------------------------------------------------------------
  l_t_ftpost-fnam = 'BSEG-SGTXT'.
  CONCATENATE l_nom_proceso ' - ' t_itab-HBKID ' - ' t_itab-HKTID into l_texto SEPARATED BY space.
  l_t_ftpost-fval = l_texto.
  append l_t_ftpost.
**---------------------------------------------------------------------
*  Fe.contabilización DATO DE ENTRADA
**---------------------------------------------------------------------
  l_t_ftpost-fnam = 'BSEG-VALUT'. "
  CONCATENATE l_fecha+6(2) l_fecha+4(2) l_fecha(4) into l_t_ftpost-fval . condense l_t_ftpost-fval.
  append l_t_ftpost.
**---------------------------------------------------------------------
*  MOTIVO EMISION ALV
**---------------------------------------------------------------------
  l_t_ftpost-fnam = 'COBL-ZZMOT_EMIS'.
  l_t_ftpost-fval = t_itab-ZZMOT_EMIS.
  append l_t_ftpost.

endform.                    " CARGA_TABLAS
*&---------------------------------------------------------------------*
*&      Form  ejecuta_funcion
*&---------------------------------------------------------------------*
*   Funcion estandar POSTING_INTERFACE_CLEARING
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
  ti_return-BUKRS       = t_itab-BUKRS.
  ti_return-GJaHR       = t_itab-GJaHR.

  "mensaje estandar a string
  PERFORM convierte_mensaje USING sy-msgid sy-msgno CHANGING ti_return-message.
  ti_return-MESSAGE_V1  = sy-msgv1.

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
*       text
*----------------------------------------------------------------------*
*       Se llena el nombre del proceso y la clase de documento
*       segun el id de proceso.
*----------------------------------------------------------------------*
FORM CARGA_DATOS .
  "se llenan los datos de la funcion segun la id del proceso
  SELECT single CLASE_DOC CAMBIO_ESTADO into (l_clase_doc, l_nom_proceso)
    from ZFITR020_T03
    where ID_PROCESO = '1006'. "XD; REVALIDAC CHEQUE

  if tabname eq '101' or tabname is INITIAL.
    l_fecha = p_budat1.
  endif.

  "localiza la contrapartida
  select single REVALIDAD into l_cta_contrap
    from ZFITR020_T05
    where bukrs = t_itab-BUKRS
      and hbkid = t_itab-HBKID
      and HKTID = t_itab-HKTID.

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
  ls_fieldcat-seltext_s     = 'MESSAGE_V1'.
  ls_fieldcat-seltext_l     = 'MESSAGE_V1'.
  ls_fieldcat-outputlen     = '10'.
  ls_fieldcat-just          = 'R'.
  APPEND ls_fieldcat TO  rt_fieldcat.

  CLEAR ls_fieldcat.
  pos = pos + 1.
  ls_fieldcat-col_pos       =  pos.
  ls_fieldcat-fieldname     = 'MESSAGE'.
  ls_fieldcat-seltext_s     = 'MESSAGE'.
  ls_fieldcat-seltext_l     = 'MESSAGE'.
  ls_fieldcat-outputlen     = '120'.
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
*--------------------------------------------------------------------*
* CONSISTE EN QUE UN CHEQUE CADUCO MEDIANTE LA FIRMA EN EL RESPALDO
* DEL CHEQUE QUEDA NUEVAMENTE DISPONIBLE PARA EL COBRO
*&---------------------------------------------------------------------*
*   REVEVALIDACION CHEQUE
*--------------------------------------------------------------------*
FORM selecciona .
*  rangos y variables
  RAnges: r_budat for bsas-augdt.

  "rescato las cuentas de la tabla mantenedora.
  select * into CORRESPONDING FIELDS OF TABLE ti_ZFITR020_T05
    from ZFITR020_T05
    where bukrs eq p_bukrs1
      and hbkid eq p_hbkid1
      and hktid eq p_hktid1.

  READ TABLE ti_ZFITR020_T05 into wa_ZFITR020_T05 index 1.

  select * into CORRESPONDING FIELDS OF TABLE ti_payr
    from payr
    where ZBUKR eq p_bukrs1
      and hbkid eq p_hbkid1
      and hktid eq p_hktid1
      and chect in p_chect1
      and voidr eq '00'"cheque anulado
      and xbanc eq ' ' "cheque cobrado
         .

  if sy-subrc <> 0.
    MESSAGE 'NO SE SELECCIONARON PARTIDAS PARA LA CONSULTA' type 'E'.
  endif.

  "se cambia el tipo de dato para la consulta a la bsis
  "payr-chect a bsis-zuonr (de 13 a 18 caracteres)
  loop at ti_payr into wa_payr.
    wa_payr_aux-ZBUKR = wa_payr-ZBUKR.
    wa_payr_aux-VBLNR = wa_payr-VBLNR.
    wa_payr_aux-GJAHR = wa_payr-GJAHR.
    wa_payr_aux-chect = wa_payr-chect.
    wa_payr_aux-HBKID = wa_payr-HBKID.
    wa_payr_aux-HKTID = wa_payr-HKTID.
    wa_payr_aux-RZAWE = wa_payr-RZAWE.
    wa_payr_aux-UBHKT = wa_payr-UBHKT.
    wa_payr_aux-ZALDT = wa_payr-ZALDT.
    wa_payr_aux-RWBTR = wa_payr-RWBTR.
    wa_payr_aux-WAERS = wa_payr-WAERS.
    append wa_payr_aux to ti_payr_aux.
  endloop.

  "SE BUSCA LA PARTIDA ABIERTA APARTIR DEL CHEQUE
  select * into CORRESPONDING FIELDS OF TABLE ti_bsis
    from bsis FOR ALL ENTRIES IN ti_payr_aux
    where bukrs eq ti_payr_aux-ZBUKR
      and ( hkont eq ti_payr_aux-UBHKT
         or hkont eq wa_ZFITR020_T05-cTA_CDCO_E
         or hkont eq wa_ZFITR020_T05-cTA_CDCO_F
         or hkont eq wa_ZFITR020_T05-REVALIDAD )
        and ZUONR eq ti_payr_aux-chect
          .

  loop at ti_bsis into wa_bsis.
    if wa_bsis-HKONT+9(1) eq '2'.
      REFRESH r_budat.
      clear ti_bsas2[]. CLEAR ti_bsas2.
      clear r_budat. CLEAR ti_bsas2[]. CLEAR ti_bsas2.
      CONCATENATE wa_bsis-gjahr '01' '01' into r_budat-low.
      CONCATENATE wa_bsis-gjahr '12' '31' into r_budat-high.
      r_budat-sign = 'I'.
      r_budat-OPTION = 'BT'.
      append r_budat.
      "Se busca el documento general de pago el que tiene
      "el concepto de emision
      SELECT * into CORRESPONDING FIELDS OF   wa_bsas
        from bsas
        where bukrs eq wa_bsis-BUKRS
          and augdt in r_budat
          and augbl eq wa_bsis-BELNR
          and belnr <> wa_bsis-BELNR.

        wa_bsas-gjahr_bsis = wa_bsis-GJaHR. "se  guardan estos campos adicionalmente
        wa_bsas-bukrs_bsis = wa_bsis-BUKRS. "para realizar una sola busqueda para los
        APPEND wa_Bsas to ti_Bsas2.          "dos motivos de emision
      ENDSELECT.

      if  sy-subrc <> 0.
        PERFORM BUSCA_DOC_PAGO_MULTI_COM.
      endif.

      APPEND LINES OF ti_bsas2 to ti_bsas.

      if ti_bsas2[] is not INITIAL.
select * APPENDING CORRESPONDING FIELDS OF TABLE ti_bseg
from bseg FOR ALL ENTRIES IN ti_bsas2
where belnr = ti_bsas2-belnr
and GJaHR = ti_bsas2-GJaHR
and bukrs = ti_bsas2-BUKRS
and ZZMOT_EMIS <> ' '
*Begin of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 24/12/2019 EY_DES02 ECDK917080 *
*.
ORDER BY PRIMARY KEY.
*End of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 24/12/2019 EY_DES02 ECDK917080 *
      endif.
    ELSEIF wa_bsis-HKONT+9(1) eq '6'
        or wa_bsis-HKONT+9(1) eq '7'
        or wa_bsis-HKONT+9(1) eq '9'.

select * APPENDING CORRESPONDING FIELDS OF TABLE ti_bseg
from bseg
where bukrs = wa_bsis-BUKRS
and belnr = wa_bsis-belnr
and GJaHR = wa_bsis-GJaHR
and hkont = wa_bsis-HKONT
and ZZMOT_EMIS <> ' '
*Begin of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 24/12/2019 EY_DES02 ECDK917080 *
*.
ORDER BY PRIMARY KEY.
*End of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 24/12/2019 EY_DES02 ECDK917080 *
    endif.
  endloop.

ENDFORM.                    "selecciona
*&---------------------------------------------------------------------*
*&      Form  CREA_ALV
*&---------------------------------------------------------------------*
*   REVEVALIDACION CHEQUE
*----------------------------------------------------------------------*
FORM CREA_ALV .
  refresh itab.

  loop at ti_bsis into wa_bsis.
    clear itab.
    CLEAR wa_payr.
    clear wa_bsas.
    clear wa_bseg.

    MOVE-CORRESPONDING wa_bsis to itab.

    READ TABLE ti_payr into wa_payr with key ZBUKR = wa_bsis-BUKRS
                                             chect = wa_bsis-zuonr.
    itab-HBKID = wa_payr-HBKID.
    itab-hktid = wa_payr-HKTID.
    itab-CHECT = wa_payr-CHECT.

    "si el registro no existe en la payr se salta la posicion.
    if sy-subrc <> 0.
      continue.
    endif.

    "dependiendo de las cuentas se hicieron distintas busquedas a la
    "bseg.
    if wa_bsis-HKONT+9(1) eq '2'.
      READ TABLE ti_bsas into wa_bsas with key BUKRS_bsis = wa_bsis-BUKRS
                                               augbl = wa_bsis-belnr
                                               gjahr_bsis = wa_bsis-GJaHR.

      itab-Multi = wa_Bsas-Multi.
      READ TABLE ti_bseg into wa_bseg with key bukrs = wa_bsas-BUKRS
                                               belnr = wa_bsas-belnr
                                               GJaHR = wa_bsas-GJaHR.
    elseif wa_bsis-HKONT+9(1) eq '6'
        or wa_bsis-HKONT+9(1) eq '7'
        or wa_bsis-HKONT+9(1) eq '9'.

      READ TABLE ti_bseg into wa_bseg with key bukrs = wa_bsis-BUKRS
                                               belnr = wa_bsis-belnr
                                               GJaHR = wa_bsis-GJaHR.

    endif.
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

    perform verifica_no_maternal USING itab-ZZMOT_EMIS CHANGING itab-MATERNAL.

    APPEND itab.
  endloop.

ENDFORM.                    " CREA_ALV
*&---------------------------------------------------------------------*
*&      Form  CONVIERTE_MENSAJE
*&---------------------------------------------------------------------*
*       Convierte en string el mensaje estandar
*----------------------------------------------------------------------*
FORM CONVIERTE_MENSAJE  USING    P_SY_MSGID like sy-msgid
                                 P_SY_MSGNO like sy-msgno
                        CHANGING RETURN_MESSAGE   .

  SELECT SINGLE * FROM t100 WHERE sprsl = 'S'
                             AND   arbgb = sy-msgid
                             AND   msgnr = sy-msgno.
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
*&---------------------------------------------------------------------*
*&      Form  BUSCA_DOC_PAGO_MULTI_COM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM BUSCA_DOC_PAGO_MULTI_COM .
  data: lv_bvorg like bvor-bvorg.
  data: lv_gjahr2 like ZFITR020_T01-GJAHR.
  data: lv_bukrs2 like ZFITR020_T01-bukrs.
  data: lv_belnr2 like ZFITR020_T01-belnr.

  SELECT single bvorg into lv_bvorg
    from bkpf
    where bukrs = wa_bsis-BUKRS
      and belnr = wa_bsis-BELNR
      and gjahr = wa_bsis-GJaHR.


  select single bukrs GJAHR belnr
     into (lv_bukrs2, lv_gjahr2, lv_belnr2)
   from bvor
   where bvorg = lv_bvorg
     and bukrs <> wa_bsis-BUKRS
     .

  data: lv_gjahr_orig like ZFITR020_T01-GJAHR.
  data: lv_bukrs_orig like ZFITR020_T01-bukrs.
  data: lv_belnr_orig like ZFITR020_T01-belnr.

  "con el documento obtenido buscamos el documento pagado
  select single belnr bukrs GJAHR
      into (lv_belnr_orig, lv_bukrs_orig, lv_gjahr_orig)
    from bse_clr
   where belnr_clr = lv_belnr2
     and bukrs_clr = lv_bukrs2
     and GJAHR_clr = lv_gjahr2.

  if sy-subrc = 0.
    wa_Bsas-belnr      = lv_belnr_orig.
    wa_Bsas-GJAHR      = lv_gjahr_orig.
    wa_Bsas-bukrs      = lv_bukrs_orig.
    wa_Bsas-AUGBL      = wa_bsis-belnr."se guardan estos datos para
    wa_Bsas-gjahr_bsis = wa_bsis-GJaHR."unir el alv y buscar el motivo
    wa_bsas-bukrs_bsis = wa_bsis-BUKRS."de emision cuando es multi sociedad
    wa_Bsas-Multi = 'X'.
    APPEND wa_Bsas to ti_Bsas2.
    clear wa_Bsas.
  endif.
ENDFORM.                    " BUSCA_DOC_PAGO_MULTI_COM
*&---------------------------------------------------------------------*
*&      Form  VERIFICA_NO_MATERNAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_ITAB_MATERNAL  text
*----------------------------------------------------------------------*
FORM VERIFICA_NO_MATERNAL USING p_itab_ZZMOT_EMIS  CHANGING P_ITAB_MATERNAL.

  DATA: LV_EXISTE TYPE C.

  SELECT SINGLE MATERNAL INTO LV_EXISTE
    FROM ZMOT_EMIS
    WHERE ZZMOT_EMIS = p_itab_ZZMOT_EMIS.

  IF LV_EXISTE EQ 'X'.
    P_ITAB_MATERNAL = 'X'.
  endif.

ENDFORM.                    " VERIFICA_NO_MATERNAL

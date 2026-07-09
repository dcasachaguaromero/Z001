*&---------------------------------------------------------------------*
*& Report  ZFITR0070
*&---------------------------------------------------------------------
*&  Compañía   : Banmedica
*&  Autor      : Crystalis Consulting Chile - Pablo Cabezas Melendez
*&  Funcional  : Crystalis Consulting Chile - Oscar Agudelo Prado
*&  Fecha      : 30.08.2013
*&  Objetivo   : Solución integral de pagos
*&--------------------------------------------------------------------
* Proceso:
*--------------------------------------------------------------------*
* Pestaña: ANULACION POR CHEQUE
* Pestaña: ANULACION POR COMPROBANTE
*--------------------------------------------------------------------*
REPORT  ZFITR0070.

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
       HKTID        type n LENGTH 5 ,        "Clave breve para un banco/cuenta
       CHECT        like payr-chect,         "Nº de cheque
       hkontd       like bseg-hkont,         "Cuenta de mayor de la contabilidad principal(cta destino)
       lifnr        like bseg-lifnr,         "Número de cuenta del proveedor o acreedor
       zlsch        like bseg-ZLSCH,         "Vía de pago
       field_style  TYPE lvc_t_styl,         "FOR DISABLE cell
       ESTADO       type c LENGTH 10,        "segun la cuenta de mayor: emitido, revalidado, caduco,etc.
       ZZMOT_EMIS   like bseg-ZZMOT_EMIS,    "Motivos de emisión
       fecha_cal    like bsis-bldat,         "Fecha calculada (dato de entrada - dias de caducidad segun tabla zrangos)
      END OF out.

DATA: itab   TYPE TABLE OF out WITH HEADER LINE.
DATA: t_itab TYPE TABLE OF out WITH HEADER LINE.
************************************************************************
*             Tablas Internas                                          *
************************************************************************
TYPES: BEGIN OF ty_bsis,
        BUKRS     like bsis-BUKRS, "Sociedad
        HKONT     like bsis-HKONT, "Cuenta de mayor de la contabilidad principal
        zuonr     like bsis-zuonr, "Número de asignación
        GJaHR     like bsis-GJaHR, "Ejercicio
        BELNR     like bsis-BELNR, "Número de un documento contable
        BUZEI     like bsis-BUZEI, "Número del apunte contable dentro del documento contable
        BUDAT     like bsis-BUDAT, "Fecha de contabilización en el documento
        bldat     like bsis-bldat, "Fecha de documento en documento
        blart     like bsis-blart, "Clase de documento
        SHKZG     like bsis-SHKZG, "Indicador debe/haber
        WRBTR     like bsis-WRBTR, "Importe en la moneda del documento
        WAERS     like bsis-WAERS, "Clave de moneda
        fecha_cal like bsis-bldat,"Fecha calculada (dato de entrada - dias de caducidad segun tabla zrangos)
        marca     type c,
       END OF ty_bsis.

DATA: ti_bsis TYPE TABLE OF ty_bsis,
      wa_bsis LIKE LINE OF ti_bsis.

TYPES: BEGIN OF ty_payr,
        ZBUKR like payr-ZBUKR,
        VBLNR like payr-VBLNR,
        GJAHR like payr-GJAHR,
        chect like payr-chect,
        HBKID like payr-HBKID,
        HKTID like payr-HKTID,
        RZAWE like payr-RZAWE,
        UBHKT like payr-UBHKT,
        ZALDT like payr-ZALDT,
        RWBTR like payr-RWBTR,
        WAERS like payr-WAERS,
       END OF ty_payr.

DATA: ti_payr TYPE TABLE OF ty_payr,
      wa_payr LIKE LINE OF ti_payr.

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

TYPES: BEGIN OF ty_ZRANGOS,
        MOTIVOEMISION like ZRANGOS_PRESCRI-MOTIVOEMISION,
        dias          like ZRANGOS_PRESCRI-dias,
        hkont         like ZRANGOS_PRESCRI-hkont,
       END OF ty_ZRANGOS.

data: ti_ZRANGOS TYPE TABLE OF ty_zrangos,
      wa_zrangos LIKE LINE OF ti_ZRANGOS.

types: begin of ty_return,                  "tabla de retorno de mensaje de la funcion
        bukrs      like bsas-BUKRS          , "alv de salida 2
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
data: wa_return         LIKE LINE OF ti_return.
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
data: l_t_fttax   type fttax occurs 0 with header line.

data: l_group     like apqi-groupid,
      l_tproceso  type c LENGTH 5.

data l_ver_batch type c.
data c_fipi_trans_compensacion    like sy-tcode value 'FB05'.
*--------------------------------------------------------------------*
*   variables batchinput
*--------------------------------------------------------------------*
DATA: bdcdata TYPE STANDARD TABLE OF bdcdata WITH HEADER LINE.
DATA: messtab TYPE STANDARD TABLE OF bdcmsgcoll WITH HEADER LINE.
data: w_mode value 'N'.
*--------------------------------------------------------------------*
*   Primera pestaña: ANULACION POR COMPROBANTE
*--------------------------------------------------------------------*
selection-screen begin of screen 101 as subscreen.
selection-screen begin of block b1 with frame title text-t00.
SELECT-OPTIONS   :   p_bukrs1   for  BSAD-BUKRS no INTERVALS no-EXTENSION.
PARAMETERS       :   p_budat1   like BSAD-budat DEFAULT sy-datum.
SELECT-OPTIONS   :   p_belnr1   FOR  BSAD-BELNR no INTERVALS.
SELECT-OPTIONS   :   p_gjahr1   for  BSAD-gjahr no INTERVALS no-EXTENSION.
selection-screen end of block b1.
selection-screen end of screen 101.
*--------------------------------------------------------------------*
* Segunda pestaña: ANULACION POR CHEQUE
*--------------------------------------------------------------------*
selection-screen begin of screen 102 as subscreen.
selection-screen begin of block b2 with frame title text-t03.
SELECT-OPTIONS   :   p_bukrs2   for payr-ZBUKR memory id buk no INTERVALS no-EXTENSION.
SELECT-OPTIONS   :   p_hbkid2   for payr-hbkid no INTERVALS no-EXTENSION.
SELECT-OPTIONS   :   p_hktid2   for payr-hktid   no INTERVALS no-EXTENSION.
PARAMETERS       :   p_budat2   like BSAD-budat DEFAULT sy-datum.
SELECT-OPTIONS   :   p_chect2   for payr-CHECT no INTERVALS.
selection-screen end of block b2.
selection-screen end of screen 102.

*--------------------------------------------------------------------*

selection-screen begin of tabbed block t1 for 20 lines.
selection-screen tab (30) name2 user-command ucomm2 default screen 102.
selection-screen tab (30) name1 user-command ucomm1 default screen 101.
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
  name1 = 'ANULACION POR COMPROBANTE'.
  name2 = 'ANULACION POR CHEQUE'.

*------------------------------------------------------------------------------
* Comienzo de Programa
*------------------------------------------------------------------------------
START-OF-SELECTION.
  "dependiendo del tab que venga se realizan busquedas distintas las cuales
  "tienen un unico alv de salida
*--------------------------------------------------------------------*
*   ANULACION POR COMPROBANTE
*--------------------------------------------------------------------*
  if tabname eq '101' .
    if p_bukrs1 is INITIAL.
      MESSAGE 'El campo sociedad no puede ser vacio' TYPE 'E'.
    endif.
    if p_budat1  is INITIAL.
      MESSAGE 'El campo Fe.contabilización no puede ser vacio' type 'E'.
    endif.
    if p_belnr1  is INITIAL.
      MESSAGE 'El campo Nº documento no puede ser vacio' TYPE 'E'.
    endif.
    if p_gjahr1 is INITIAL.
      MESSAGE 'El campo ejercicio no puede ser vacio' TYPE 'E'.
    endif.

    PERFORM selecciona.
    PERFORM crea_alv.
*--------------------------------------------------------------------*
*   PRESCRIPCION POR CHEQUE
*--------------------------------------------------------------------*
  elseif tabname eq '102' or tabname is INITIAL.
    if p_bukrs2 is INITIAL.
      MESSAGE 'El campo sociedad pagadora no puede ser vacio' TYPE 'E'.
    endif.
    if p_hbkid2 is INITIAL.
      MESSAGE 'El campo Banco propio no puede ser vacio' TYPE 'E'.
    endif.
    if p_hktid2 is INITIAL.
      MESSAGE 'El campo ID de cuenta no puede ser vacio' TYPE 'E'.
    endif.
    if p_budat2 is INITIAL.
      MESSAGE 'El campo Fe.contabilización no puede ser vacio' type 'E'.
    endif.
    if p_chect2 is INITIAL.
      MESSAGE 'El campo Nº de cheque no puede ser vacio' TYPE 'E'.
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
  if tabname  eq'101' or tabname is INITIAL.
    wa_fieldcat-fieldname = 'BLART'.
    wa_fieldcat-scrtext_m = 'Clase doc.'.
    wa_fieldcat-outputlen = 2.
    APPEND wa_fieldcat TO it_fieldcat.
    CLEAR  wa_fieldcat.
  endif.
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
*  *CHECT
  wa_fieldcat-fieldname = 'CHECT'.
  wa_fieldcat-scrtext_m = 'Nº cheque'.
  wa_fieldcat-outputlen = 13.
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
*
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
FORM layout_build ." USING    u_lf_layout TYPE slis_layout_alv.
* Set layout field for field attributes(i.e. input/output)
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
      IF rs_selfield-fieldname = 'FLAG'."deseleccion o selecciona
        READ TABLE itab index rs_selfield-tabindex.
        if itab-flag = 'X'.
          clear itab-flag.
        else.
          itab-flag = 'X'.
        endif.
        MODIFY itab INDEX rs_selfield-tabindex.
        rs_selfield-refresh = 'X'.
      endif.

    WHEN '&ALL2'."marca todos
      LOOP AT itab.
*        if itab-ZZMOT_EMIS is not INITIAL.
          itab-flag = 'X'.
          MODIFY itab INDEX sy-tabix.
*        ENDIF.
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
*        perform carga_tablas.
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

*  LOOP AT itab .
*    if itab-ZZMOT_EMIS is INITIAL.
*      ls_stylerow-fieldname = 'FLAG'.
*      ls_stylerow-style = cl_gui_alv_grid=>mc_style_disabled.
*      INSERT ls_stylerow into table itab-field_style.
*      modify itab.
*    endif.
*  ENDLOOP.
ENDFORM.                    " SET_SPECIFIC_FIELD_ATTRIBUTES*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  carga_tablas
*&---------------------------------------------------------------------*
*
*--------------------------------------------------------------------*
form carga_tablas.

endform.                    " CARGA_TABLAS
*&---------------------------------------------------------------------*
*&      Form  ejecuta_funcion
*&---------------------------------------------------------------------*
*     anulaciones por comprabantes y cheques
*--------------------------------------------------------------------*
form ejecuta_funcion.
  "
  if t_itab-HKONT+9(1) eq '2'.
    PERFORM anula_cheque USING  t_itab-BELNR t_ITAB-BUKRS
                                t_itab-GJaHR t_ITAB-HBKID
                                t_ITAB-HKTID t_ITAB-CHECT
                                L_FECHA.
  ELSE.
    PERFORM ANULA_COMPROBANTE USING t_ITAB-BELNR t_ITAB-BUKRS
                                    t_ITAB-GJAHR l_fecha .
  endif.

endform.                    " EJECUTA_FUNCION
*&---------------------------------------------------------------------*
*&      Form  CARGA_DATOS
*&---------------------------------------------------------------------*
*       Se llena el nombre del proceso y la clase de documento
*       segun el id de proceso.
*----------------------------------------------------------------------*
FORM CARGA_DATOS .
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
*     PRESCRIPCION POR COMPROBANTE
*--------------------------------------------------------------------*
FORM selecciona .
  ranges: r_hkont FOR bsis-hkont.

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  select * into CORRESPONDING FIELDS OF TABLE ti_ZFITR020_T05
*       from ZFITR020_T05
*       where bukrs in p_bukrs1.
*
* NEW CODE
  SELECT *
 into CORRESPONDING FIELDS OF TABLE ti_ZFITR020_T05
       from ZFITR020_T05
       where bukrs in p_bukrs1 ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

  loop at ti_ZFITR020_T05 into wa_ZFITR020_T05.
    CLEAR r_hkont.
    r_hkont-low    = wa_ZFITR020_T05-CTA_SALDO.
    r_hkont-sign   = 'I'.
    r_hkont-OPTION = 'EQ'.
    APPEND r_hkont.

    CLEAR r_hkont.
    r_hkont-low    = wa_ZFITR020_T05-CTA_DEPOS.
    r_hkont-sign   = 'I'.
    r_hkont-OPTION = 'EQ'.
    APPEND r_hkont.

    CLEAR r_hkont.
    r_hkont-low    = wa_ZFITR020_T05-CTA_CARGOS.
    r_hkont-sign   = 'I'.
    r_hkont-OPTION = 'EQ'.
    APPEND r_hkont.

    CLEAR r_hkont.
    r_hkont-low    = wa_ZFITR020_T05-CTA_ABONOS.
    r_hkont-sign   = 'I'.
    r_hkont-OPTION = 'EQ'.
    APPEND r_hkont.

    CLEAR r_hkont.
    r_hkont-low    = wa_ZFITR020_T05-CTA_CDCO_F.
    r_hkont-sign   = 'I'.
    r_hkont-OPTION = 'EQ'.
    APPEND r_hkont.

    CLEAR r_hkont.
    r_hkont-low    = wa_ZFITR020_T05-CTA_CDCO_E.
    r_hkont-sign   = 'I'.
    r_hkont-OPTION = 'EQ'.
    APPEND r_hkont.

    CLEAR r_hkont.
    r_hkont-low    = wa_ZFITR020_T05-CTA_CDCO_F2 .
    r_hkont-sign   = 'I'.
    r_hkont-OPTION = 'EQ'.
    APPEND r_hkont.

    CLEAR r_hkont.
    r_hkont-low    = wa_ZFITR020_T05-CTA_CHEQS.
    r_hkont-sign   = 'I'.
    r_hkont-OPTION = 'EQ'.
    APPEND r_hkont.

    CLEAR r_hkont.
    r_hkont-low    = wa_ZFITR020_T05-CTA_TRANS.
    r_hkont-sign   = 'I'.
    r_hkont-OPTION = 'EQ'.
    APPEND r_hkont.

    CLEAR r_hkont.
    r_hkont-low    = wa_ZFITR020_T05-revalidad.
    r_hkont-sign   = 'I'.
    r_hkont-OPTION = 'EQ'.
    APPEND r_hkont.
  ENDLOOP.

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT * into CORRESPONDING FIELDS OF TABLE ti_bsis
*    from bsis
*    where bukrs in p_bukrs1
*      and BELNR in p_belnr1
*      and HKONT in r_hkont
*      and GJaHR eq p_gjahr1-low.
*
* NEW CODE
  SELECT *
 into CORRESPONDING FIELDS OF TABLE ti_bsis
    from bsis
    where bukrs in p_bukrs1
      and BELNR in p_belnr1
      and HKONT in r_hkont
      and GJaHR eq p_gjahr1-low ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  select * into CORRESPONDING FIELDS OF TABLE ti_payr
*    from payr FOR ALL ENTRIES IN ti_bsis
*    where zbukr = ti_bsis-BUKRS
*      and vblnr = ti_bsis-belnr
*      and gjahr = ti_bsis-gjahr.
*
* NEW CODE
  SELECT *
 into CORRESPONDING FIELDS OF TABLE ti_payr
    from payr FOR ALL ENTRIES IN ti_bsis
    where zbukr = ti_bsis-BUKRS
      and vblnr = ti_bsis-belnr
      and gjahr = ti_bsis-gjahr ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03


ENDFORM.                    "selecciona
*&---------------------------------------------------------------------*
*&      Form  CREA_ALV
*&---------------------------------------------------------------------*
*       Armamos el AlV de salida para la pestaña
*       ANULACION POR COMPROBANTE
*----------------------------------------------------------------------*
FORM CREA_ALV .
  refresh itab.

  loop at ti_bsis into wa_bsis.
    MOVE-CORRESPONDING wa_bsis to itab.


    if wa_bsis-HKONT+9(1) eq '2'.
      read table ti_payr into wa_payr with key zbukr = wa_bsis-BUKRS
                                         VBLNR = wa_bsis-BELNR
                                         GJaHR = wa_bsis-GJaHR.
      itab-CHECT = wa_payr-CHECT.
      READ TABLE ti_ZFITR020_T05 into wa_ZFITR020_T05 with key bukrs      = wa_bsis-BUKRS
                                                               CTA_CHEQS = wa_bsis-HKONT.
    elseif wa_bsis-HKONT+9(1) eq '5'.
      READ TABLE ti_ZFITR020_T05 into wa_ZFITR020_T05 with key bukrs      = wa_bsis-BUKRS
                                                         CTA_TRANS = wa_bsis-HKONT.

    elseif wa_bsis-HKONT+9(1) eq '6'.
      READ TABLE ti_ZFITR020_T05 into wa_ZFITR020_T05 with key bukrs      = wa_bsis-BUKRS
                                                               CTA_CDCO_f = wa_bsis-HKONT.
    elseif wa_bsis-HKONT+9(1) eq '7'.
      READ TABLE ti_ZFITR020_T05 into wa_ZFITR020_T05 with key bukrs      = wa_bsis-BUKRS
                                                               CTA_CDCO_e = wa_bsis-HKONT.
    elseif wa_bsis-HKONT+9(1) eq '9'.
      READ TABLE ti_ZFITR020_T05 into wa_ZFITR020_T05 with key bukrs      = wa_bsis-BUKRS
                                                               REVALIDAD = wa_bsis-HKONT.
    endif.
    itab-HBKID = wa_ZFITR020_T05-HBKID.
    itab-HKTID = wa_ZFITR020_T05-HKTID.
    APPEND itab.
  endloop.


ENDFORM.                    " CREA_ALV
*&---------------------------------------------------------------------*
*&      Form  SELECCIONA2
*&---------------------------------------------------------------------*
*     Rescate de datos correspondiente al primer tab
*     ANULACION POR CHEQUE
*--------------------------------------------------------------------*
FORM SELECCIONA2 .

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  select * into CORRESPONDING FIELDS OF TABLE ti_payr
*    from payr
*    where zbukr in p_bukrs2
*      and HBKID in p_hbkid2
*      and HKTID in p_hktid2
*      and chect in p_chect2
*      .
*
* NEW CODE
  SELECT *
 into CORRESPONDING FIELDS OF TABLE ti_payr
    from payr
    where zbukr in p_bukrs2
      and HBKID in p_hbkid2
      and HKTID in p_hktid2
      and chect in p_chect2
       ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  select * into CORRESPONDING FIELDS OF TABLE ti_ZFITR020_T05
*      from ZFITR020_T05
*      where bukrs in p_bukrs2
*        and hbkid in p_hbkid2
*        and hktid in p_hktid2 .
*
* NEW CODE
  SELECT *
 into CORRESPONDING FIELDS OF TABLE ti_ZFITR020_T05
      from ZFITR020_T05
      where bukrs in p_bukrs2
        and hbkid in p_hbkid2
        and hktid in p_hktid2  ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03


ENDFORM.                    " SELECCIONA2
*&---------------------------------------------------------------------*
*&      Form  CREA_ALV2
*&---------------------------------------------------------------------*
*       Armamos el AlV de salida para la pestaña
*       PRESCRIPCION POR CHEQUE
*----------------------------------------------------------------------*
FORM CREA_ALV2 .
  refresh itab.

  loop at ti_payr into wa_payr.
    itab-BUKRS = wa_payr-ZBUKR .
    itab-BELNR = wa_payr-VBLNR .
    itab-GJaHR = wa_payr-GJAHR .
    itab-CHECT = wa_payr-chect .
    itab-HBKID = wa_payr-HBKID .
    itab-HKTID = wa_payr-HKTID .
    itab-zlsch = wa_payr-RZAWE .
    itab-HKONT = wa_payr-UBHKT .
    itab-bldat = wa_payr-ZALDT .
    itab-BUDAT = wa_payr-ZALDT .
    itab-WRBTR = wa_payr-RWBTR .
    itab-WAERS = wa_payr-WAERS .

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
*&      Form  ANULA_COMPROBANTE
*&---------------------------------------------------------------------*
*      Anula comprobantes del alv con batch input tx: fbra - fb08
*----------------------------------------------------------------------*
FORM ANULA_COMPROBANTE USING    ITAB_BELNR
                            ITAB_BUKRS
                            ITAB_GJAHR
                            l_fecha .
  clear ti_return.
*  ti_return-TYPE        = sy-msgty.
*  ti_return-ID          = sy-msgid.
*  ti_return-NUMBER      = sy-msgno.
  ti_return-BELNR       = ITAB_BELNR.
  ti_return-BUKRS       = ITAB_BUKRS.
  ti_return-GJaHR       = ITAB_GJAHR.

  REFRESH bdcdata.
  CLEAR bdcdata.
*--------------------------------------------------------------------*
*Cambiar modo de visualizacion
* A	Visual.pant.(todas)
* E	Visualizar sólo errores
* N	Sin visualización
  w_mode = 'N'.
*--------------------------------------------------------------------*
  PERFORM bdc USING: "BATCH (GRABACION SM35 ANULAFBRA)
            'X' 'SAPMF05R' '0100'         ,   "ingresa al programa
            '' 'BDC_CURSOR' 'RF05R-AUGBL' ,   "
            '' 'RF05R-AUGBL' ITAB_BELNR   ,   "
            '' 'BDC_CURSOR' 'RF05R-BUKRS' ,   "se posiciona en el campo sociedad
            '' 'RF05R-BUKRS' ITAB_BUKRS   ,   "asigna el valor correspondiente
            '' 'BDC_CURSOR' 'RF05R-GJAHR' ,   "
            '' 'RF05R-GJAHR' ITAB_GJAHR   ,   "

            '' 'BDC_OKCODE' '=RAGL'       .   "
  CALL TRANSACTION 'FBRA' USING bdcdata MODE w_mode UPDATE 'S' MESSAGES INTO messtab.

  PERFORM convierte_mensaje USING sy-msgid sy-msgno CHANGING ti_return-message.
  ti_return-MESSAGE_V1  = sy-msgv1.

  REFRESH bdcdata.
  CLEAR bdcdata.
  PERFORM bdc USING: "BATCH (GRABACION SM35 ANULAFB08)
            'X' 'SAPMF05A' '0105'        ,  "ingresa al programa
            '' 'BDC_CURSOR' 'RF05A-BELNS',  "
            '' 'RF05A-BELNS' ITAB_BELNR  ,  "
            '' 'BDC_CURSOR' 'BKPF-BUKRS' ,  "se posiciona en el campo sociedad
            '' 'BKPF-BUKRS'  ITAB_BUKRS  ,  "asigna el valor correspondiente
            '' 'BDC_CURSOR' 'RF05A-GJAHS',  "
            '' 'RF05A-GJAHS' ITAB_GJAHR  ,  "

            '' 'BDC_CURSOR' 'UF05A-STGRD',  "se posiciona en el cambo banco propio
            '' 'UF05A-STGRD' '02'        ,  "asigna el valor correspondiente
            '' 'BDC_CURSOR' 'BSIS-BUDAT' ,  "se posiciona en el campo cuentas
            '' 'BSIS-BUDAT' l_fecha      ,  "asigna el valor correspondiente
            '' 'BDC_CURSOR' 'BSIS-MONAT' ,  "se posiciona en el campo cheque
            '' 'BSIS-MONAT' l_fecha+4(2) ,  "asigna el valor correspondiente

            '' 'BDC_OKCODE' '=BU'      .  "
  CALL TRANSACTION 'FB08' USING bdcdata MODE w_mode UPDATE 'S' MESSAGES INTO messtab.

  PERFORM convierte_mensaje USING sy-msgid sy-msgno CHANGING ti_return-message2.
  ti_return-MESSAGE_V2 = sy-msgv1.
  APPEND ti_return.

ENDFORM.                    " ANULA_COMPROBANTE
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
*&---------------------------------------------------------------------*
*&      Form  ANULA_CHEQUE
*&---------------------------------------------------------------------*
*      Anula cheques del alv con batch input tx: fch8
*----------------------------------------------------------------------*
FORM ANULA_CHEQUE  USING    ITAB_BELNR
                            ITAB_BUKRS
                            ITAB_GJAHR
                            ITAB_HBKID
                            ITAB_HKTID
                            ITAB_CHECT
                            L_FECHA.

  clear ti_return.
*  ti_return-TYPE        = sy-msgty.
*  ti_return-ID          = sy-msgid.
*  ti_return-NUMBER      = sy-msgno.
  ti_return-BELNR       = ITAB_BELNR.
  ti_return-BUKRS       = ITAB_BUKRS.
  ti_return-GJaHR       = ITAB_GJAHR.

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
            'X' 'SAPMFCHK' '0800'         ,   "ingresa al programa
            '' 'BDC_CURSOR' 'PAYR-ZBUKR'  ,   "
            '' 'PAYR-ZBUKR' ITAB_BUKRS    ,   "
            '' 'BDC_CURSOR' 'PAYR-HBKID'  ,   "se posiciona en el campo sociedad
            '' 'PAYR-HBKID' ITAB_HBKID    ,   "asigna el valor correspondiente
            '' 'BDC_CURSOR' 'PAYR-HKTID'  ,   "
            '' 'PAYR-HKTID' ITAB_HKTID    ,   "
            '' 'BDC_CURSOR' 'PAYR-CHECT'  ,   "
            '' 'PAYR-CHECT' ITAB_CHECT    ,   "
            '' 'BDC_CURSOR' 'PAYR-VOIDR'  ,   "
            '' 'PAYR-VOIDR' '99'          ,   "
            '' 'BDC_CURSOR' 'UF05A-STGRD' ,   "
            '' 'UF05A-STGRD' '02'         ,   "
            '' 'BDC_CURSOR' 'RF05R-BUDAT' ,   "
            '' 'RF05R-BUDAT' l_fecha      ,   "
            '' 'BDC_CURSOR' 'RF05R-MONAT' ,   "
            '' 'RF05R-MONAT' l_fecha+4(2) ,   "

            '' 'BDC_OKCODE' '=RAGL'       ,
            'X' 'SAPMFCHK' '0800'         ,
            '' 'BDC_OKCODE' '/EEND'       .
  CALL TRANSACTION 'FCH8' USING bdcdata MODE w_mode UPDATE 'S' MESSAGES INTO messtab.

  PERFORM convierte_mensaje USING sy-msgid sy-msgno CHANGING ti_return-message.
  ti_return-MESSAGE_V1  = sy-msgv1.
  APPEND ti_return.

ENDFORM.                    " ANULA_CHEQUE

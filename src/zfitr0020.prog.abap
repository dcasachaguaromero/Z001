*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES02 > *
*& Description: < ReSQ Correction > *
*& Date: <24-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Report  ZFITR0020
*&---------------------------------------------------------------------
*&  Compañía   : Banmedica
*&  Autor      : Crystalis Consulting Chile - Pablo Cabezas Melendez
*&  Funcional  : Crystalis Consulting Chile - Oscar Agudelo Prado
*&  Fecha      : 30.08.2013
*&  Objetivo   : Solución integral de pagos
*&--------------------------------------------------------------------
* Proceso: 1005 CADUCA ELECTRONICO
*--------------------------------------------------------------------*
* Pestaña: CAD MASIVO ELECTRONICO
* Pestaña: CAD ELECT POR CHEQUE
* Pestaña: CAD ELECT POR COMPROBANTE
*--------------------------------------------------------------------*
REPORT  zfitr0020.

TYPE-POOLS: slis.

TABLES: bsad, bsid, zfitr020_t05, payr, bseg, t100.

TYPES: BEGIN OF out, "tabla de salida.
         flag        TYPE c                  , "Flag para ejecutar la funcion
         bukrs       LIKE bsis-bukrs         , "Sociedad
         hkont       LIKE bsis-hkont         , "Cuenta de mayor de la contabilidad principal
         zuonr       LIKE bsis-zuonr         , "Número de asignación
         gjahr       LIKE bsis-gjahr         , "Ejercicio
         belnr       LIKE bsis-belnr         , "Número de un documento contable
         buzei       LIKE bsis-buzei         , "Número del apunte contable dentro del documento contable
         budat       LIKE bsis-budat         , "Fecha de contabilización en el documento
         blart       LIKE bsis-blart         , "Clase de documento
         shkzg       LIKE bsis-shkzg         , "Indicador debe/haber
         wrbtr       LIKE bsis-wrbtr         , "Importe en la moneda del documento
         waers       LIKE bsis-waers         , "Clave de moneda
         zzmot_emis  LIKE bseg-zzmot_emis    , "Motivos de emisión
         hbkid       LIKE zfitr020_t05-hbkid , "Clave breve para banco propio
*       HKTID        type n LENGTH 5         ,"Clave breve para un banco/cuenta                             "comentado 17.10.2014
         hktid       TYPE payr-hktid         , "Clave breve para un banco/cuenta                              "agregado  17.10.2014
         chect       LIKE payr-chect         , "Nº de cheque
         field_style TYPE lvc_t_styl         , "FOR DISABLE cell
         estado      TYPE c LENGTH 10        , "segun la cuenta de mayor: emitido, revalidado, caduco,etc.
         multi       TYPE c                 , "si es multisociedad que se marque el flag
         multi_bukrs LIKE bsas-bukrs               , "alv de salida 2
         multi_belnr LIKE bsas-belnr,
         multi_gjahr LIKE bsas-gjahr,
       END OF out.

DATA: itab   TYPE TABLE OF out WITH HEADER LINE.
DATA: t_itab TYPE TABLE OF out WITH HEADER LINE.

DATA: v_mater     TYPE zmot_emis-maternal,                           "agregado 17.10.2014
      v_val       TYPE char1,                                        "agregado 17.10.2014
      v_hkont     TYPE zmot_emis-cta_cade,                           "agregado 17.10.2014
      wa_bse_clr  TYPE bse_clr,                                      "agregado 17.10.2014
      wa_bse_clr2 TYPE bse_clr,                                      "agregado 17.10.2014
      wa_bseg2    TYPE bseg.                                         "agregado 17.10.2014
DATA: bdcdata TYPE STANDARD TABLE OF bdcdata WITH HEADER LINE.        "agregado 17.10.2014
DATA: messtab TYPE STANDARD TABLE OF bdcmsgcoll WITH HEADER LINE.     "agregado 17.10.2014
DATA: w_mode VALUE 'N'.                                               "agregado 17.10.2014
************************************************************************
*             Tablas Internas                                          *
************************************************************************
TYPES: BEGIN OF ty_bsis,
         bukrs      LIKE bsis-bukrs, "Sociedad
         hkont      LIKE bsis-hkont, "Cuenta de mayor de la contabilidad principal
         zuonr      LIKE bsis-zuonr, "Número de asignación
         gjahr      LIKE bsis-gjahr, "Ejercicio
         belnr      LIKE bsis-belnr, "Número de un documento contable
         buzei      LIKE bsis-buzei, "Número del apunte contable dentro del documento contable
         budat      LIKE bsis-budat, "Fecha de contabilización en el documento
         blart      LIKE bsis-blart, "Clase de documento
         shkzg      LIKE bsis-shkzg, "Indicador debe/haber
         wrbtr      LIKE bsis-wrbtr, "Importe en la moneda del documento
         waers      LIKE bsis-waers, "Clave de moneda
         marca      TYPE c         , "Flag, si el docuemtno es rescatado con zuonr = chect
         xburk      LIKE payr-xbukr, " si es multi sociedad guardamos el dato de la payr
         vblnr_payr LIKE payr-vblnr,
         zbukr_payr LIKE payr-zbukr,
         gjahr_payr LIKE payr-gjahr,
       END OF ty_bsis.

DATA: ti_bsis TYPE TABLE OF ty_bsis,
      wa_bsis LIKE LINE OF ti_bsis.

TYPES: BEGIN OF ty_zfitr020_t05,
         bukrs     LIKE bsis-bukrs            , "Sociedad
         cta_cheqs LIKE zfitr020_t05-cta_cheqs,
         cta_trans LIKE zfitr020_t05-cta_trans,
         revalidad LIKE zfitr020_t05-revalidad,
         hbkid     LIKE zfitr020_t05-hbkid    , "Clave breve para banco propio
         hktid     LIKE zfitr020_t05-hktid    , "Clave breve para un banco/cuenta
       END OF ty_zfitr020_t05.

DATA: ti_zfitr020_t05 TYPE TABLE OF ty_zfitr020_t05,
      wa_zfitr020_t05 LIKE LINE OF ti_zfitr020_t05.


TYPES: BEGIN OF ty_bsas,
         belnr      LIKE bsas-belnr     , "Número de un documento contable
         gjahr      LIKE bsas-gjahr     , "Ejercicio
         bukrs      LIKE bsas-bukrs     , "Sociedad
         augbl      LIKE bsas-augbl     , "Número del documento de compensación
         budat      LIKE bsas-budat     , "Fecha de contabilización en el documento
         gjahr_bsis LIKE bsas-gjahr, "periodo del documento a compensar
         bukrs_bsis LIKE bsas-bukrs,
         multi      TYPE c,
       END OF ty_bsas.

DATA: ti_bsas TYPE TABLE OF ty_bsas WITH HEADER LINE,
      wa_bsas LIKE LINE OF ti_bsas.

TYPES: BEGIN OF ty_bsas_aux,
         belnr LIKE bsas-belnr, "Número de un documento contable
         gjahr LIKE bsas-gjahr, "Ejercicio
         bukrs LIKE bsas-bukrs,
       END OF ty_bsas_aux.

DATA: ti_bsas_aux TYPE TABLE OF ty_bsas_aux WITH HEADER LINE,
      wa_bsas_aux LIKE LINE OF ti_bsas_aux.

TYPES: BEGIN OF ty_bseg,
         bukrs      LIKE bsas-bukrs           , "Sociedad
         belnr      LIKE bsas-belnr           , "Número de un documento contable
         gjahr      LIKE bseg-gjahr           , "Ejercicio
         zlsch      LIKE bseg-zlsch           , "Vía de pago
         zzmot_emis LIKE bseg-zzmot_emis , "Motivos de emisión
       END OF ty_bseg.

DATA: ti_bseg TYPE TABLE OF ty_bseg,
      wa_bseg LIKE LINE OF ti_bseg.

TYPES: BEGIN OF ty_payr,
         zbukr LIKE payr-zbukr, "Sociedad pagadora
         vblnr LIKE payr-vblnr, "Número del documento de pago
         gjahr LIKE payr-gjahr, "Ejercicio
         chect LIKE payr-chect, "Nº de cheque
         hbkid LIKE payr-hbkid, "Clave breve para banco propio
         hktid LIKE payr-hktid, "Clave breve para un banco/cuenta
         rzawe LIKE payr-rzawe, "Vía de pago
         ubhkt LIKE payr-ubhkt, "Nº de cta.mayor para nuestra cta.bancaria / cta.transitoria
         zaldt LIKE payr-zaldt, "Fecha de pago prevista (vencimiento 1)
         rwbtr LIKE payr-rwbtr, "Importe pagado en la moneda del pago
         waers LIKE payr-waers, "Clave de moneda
         xbukr LIKE payr-xbukr, "si el cheque es cheque es multisociedad
         voidr LIKE payr-voidr,
         xbanc LIKE payr-xbanc,
       END OF ty_payr.

DATA: ti_payr TYPE TABLE OF ty_payr,
      wa_payr LIKE LINE OF ti_payr.

TYPES: BEGIN OF ty_return,                    "tabla de retorno de mensaje de la funcion
         bukrs       LIKE bsas-bukrs               , "alv de salida 2
         belnr       LIKE bsas-belnr,
         gjahr       LIKE bsas-gjahr,
         multi_bukrs LIKE bsas-bukrs               , "alv de salida 2
         multi_belnr LIKE bsas-belnr,
         multi_gjahr LIKE bsas-gjahr,
         type        LIKE bapiret2-type,
         id          LIKE bapiret2-id,
         number      LIKE bapiret2-number,
         message_v1  LIKE bapiret2-message_v1,
         message_v2  LIKE bapiret2-message_v2,
         message_v3  LIKE bapiret2-message_v3,
         message_v4  LIKE bapiret2-message_v4,
         message     TYPE c LENGTH 150,
         message2    TYPE c LENGTH 150        ,                               "Agregado 17.10.2014
       END OF ty_return.
DATA: ti_return         TYPE TABLE OF ty_return WITH HEADER LINE.
************************************************************************
*     Estructura de parámetros:   ALV
************************************************************************
DATA: it_fieldcat  TYPE lvc_t_fcat,
      wa_fieldcat  TYPE lvc_s_fcat,
      gd_tab_group TYPE slis_t_sp_group_alv,
      gd_layout    TYPE lvc_s_layo,
      gd_repid     LIKE sy-repid.

DATA: ref_grid      TYPE REF TO cl_gui_alv_grid.
*--------------------------------------------------------------------*
*   Variables para el matchcode
*--------------------------------------------------------------------*
DATA: input_output(20) TYPE c,
      fld(20)          TYPE c, "nombre del campo
      off              TYPE i,
      val(20)          TYPE c, "valor en el campo
      len              TYPE i. "largo del valor

FIELD-SYMBOLS: <campo> TYPE any.
*--------------------------------------------------------------------*
*   variables para funcion
*--------------------------------------------------------------------*
DATA: tabname       TYPE c LENGTH 4.
DATA: l_clase_doc   TYPE blart.
DATA: l_nom_proceso TYPE string.
DATA: l_texto       TYPE string.
DATA: l_cta_contrap TYPE hkont.
DATA: l_fecha       TYPE budat.


DATA: l_t_blntab  TYPE blntab  OCCURS 0 WITH HEADER LINE.
DATA: l_t_ftpost  TYPE ftpost  OCCURS 0 WITH HEADER LINE.
DATA: l_t_ftclear TYPE ftclear OCCURS 0 WITH HEADER LINE.
DATA: l_t_fttax   TYPE fttax   OCCURS 0 WITH HEADER LINE.

DATA: l_group       LIKE apqi-groupid,
      l_tproceso(5) TYPE c.
DATA: flag_ini TYPE c.
DATA l_ver_batch TYPE c.
DATA c_fipi_trans_compensacion LIKE sy-tcode VALUE 'FB05'.
*--------------------------------------------------------------------*
*   Primera pestaña: CAD MASIVO ELECTRONICO
*--------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF SCREEN 101 AS SUBSCREEN.
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-t00.
SELECT-OPTIONS   :   p_bukrs1   FOR  payr-zbukr NO INTERVALS MEMORY ID buk. " OBLIGATORY
SELECT-OPTIONS   :   p_hbkid1   FOR payr-hbkid NO-EXTENSION NO INTERVALS. "MATCHCODE OBJECT H_T012
SELECT-OPTIONS   :   p_hktid1   FOR payr-hktid NO-EXTENSION NO INTERVALS.
SELECT-OPTIONS   :   p_budat1   FOR  bsad-budat DEFAULT sy-datum NO-EXTENSION NO INTERVALS.
PARAMETERS       :   p_dcadu1    TYPE n LENGTH 3 .
SELECTION-SCREEN END OF BLOCK b1.
SELECTION-SCREEN END OF SCREEN 101.
*--------------------------------------------------------------------*
* Segunda pestaña: CAD ELECT POR CHEQUE
*--------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF SCREEN 102 AS SUBSCREEN.
SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-t02.
SELECT-OPTIONS   :   p_bukrs2   FOR payr-zbukr MEMORY ID buk NO-EXTENSION NO INTERVALS.
SELECT-OPTIONS   :   p_hbkid2   FOR payr-hbkid NO-EXTENSION NO INTERVALS.
SELECT-OPTIONS   :   p_hktid2   FOR payr-hktid NO-EXTENSION NO INTERVALS.
SELECT-OPTIONS   :   p_budat2   FOR bsad-budat DEFAULT sy-datum NO-EXTENSION NO INTERVALS.
PARAMETERS       :   p_dcadu2   TYPE n LENGTH 3  .
SELECT-OPTIONS   :   p_chect2   FOR payr-chect NO INTERVALS.
SELECTION-SCREEN END OF BLOCK b2.
SELECTION-SCREEN END OF SCREEN 102.
*--------------------------------------------------------------------*
* Tercera pestaña: CAD ELECT POR COMPROBANTE
*--------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF SCREEN 103 AS SUBSCREEN.
SELECTION-SCREEN BEGIN OF BLOCK b3 WITH FRAME TITLE TEXT-t03.
SELECT-OPTIONS   :   p_bukrs3   FOR payr-zbukr MEMORY ID buk NO-EXTENSION NO INTERVALS.
SELECT-OPTIONS   :   p_hbkid3   FOR payr-hbkid NO-EXTENSION NO INTERVALS.
SELECT-OPTIONS   :   p_hktid3   FOR  payr-hktid  NO-EXTENSION NO INTERVALS.
SELECT-OPTIONS   :   p_budat3   FOR bsad-budat DEFAULT sy-datum NO-EXTENSION NO INTERVALS.
PARAMETERS       :   p_dcadu3   TYPE n  LENGTH 3  .
SELECT-OPTIONS   :   p_belnr3   FOR bsad-belnr NO INTERVALS.
SELECT-OPTIONS   :   p_gjahr3   FOR bsad-gjahr NO-EXTENSION NO INTERVALS.
SELECTION-SCREEN END OF BLOCK b3.
SELECTION-SCREEN END OF SCREEN 103.
*--------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF TABBED BLOCK t1 FOR 20 LINES.
SELECTION-SCREEN TAB (30) name1 USER-COMMAND ucomm1 DEFAULT SCREEN 101.
SELECTION-SCREEN TAB (30) name2 USER-COMMAND ucomm2 DEFAULT SCREEN 102.
SELECTION-SCREEN TAB (30) name3 USER-COMMAND ucomm3 DEFAULT SCREEN 103.
SELECTION-SCREEN END OF BLOCK t1.

AT SELECTION-SCREEN.
  "determino el tab que se ejecuto el programa y lo asigno a la variable
  "tabname para hacer procesos de busquedas distintos
  CASE sy-dynnr.
    WHEN 1000.
      CASE sy-ucomm.
        WHEN 'UCOMM1'.  tabname = 101.
        WHEN 'UCOMM2'.  tabname = 102.
        WHEN 'UCOMM3'.  tabname = 103.
      ENDCASE.
  ENDCASE.

**-------------------------------------------------------------------------
** Eventos de Parámetros de Selección
**-------------------------------------------------------------------------
AT SELECTION-SCREEN ON p_hktid1.
  DATA: lv_lines TYPE i.
  IF p_hktid1-low IS NOT INITIAL.
    DESCRIBE TABLE p_bukrs1 LINES lv_lines.
    IF lv_lines > 1.
      MESSAGE e002(sy) WITH 'Id de cuenta no permitida con varias sociedades'.
    ENDIF.
  ENDIF.

AT SELECTION-SCREEN ON p_hbkid1.
  DATA: lv_lines TYPE i.
  IF p_hbkid1-low IS NOT INITIAL.
    DESCRIBE TABLE p_bukrs1 LINES lv_lines.
    IF lv_lines > 1.
      MESSAGE e002(sy) WITH 'Banco propio no permitida con varias sociedades'.
    ENDIF.
  ENDIF.
*
AT SELECTION-SCREEN ON p_dcadu1.
  IF p_dcadu1 > 90.
    MESSAGE e002(sy) WITH 'Dias de caducidad no puede ser mayor a 90 dias'.
  ENDIF.

AT SELECTION-SCREEN ON p_dcadu2.
  IF p_dcadu2 > 90.
    MESSAGE e002(sy) WITH 'Dias de caducidad no puede ser mayor a 90 dias'.
  ENDIF.

AT SELECTION-SCREEN ON p_dcadu3.
  IF p_dcadu3 > 90.
    MESSAGE e002(sy) WITH 'Dias de caducidad no puede ser mayor a 90 dias'.
  ENDIF.



AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_hbkid1-low.
  DATA : indice    LIKE sy-tabix.
  DATA: return_tab TYPE TABLE OF ddshretval WITH HEADER LINE.

  DATA: BEGIN OF it_mov OCCURS 0,
          bukrs TYPE t012-bukrs,
          hbkid TYPE t012-hbkid,
        END OF it_mov.

  SELECT bukrs hbkid INTO TABLE it_mov
    FROM t012
    WHERE bukrs IN p_bukrs1.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'P_HBKID1'
      dynpprog        = sy-cprog
      dynpnr          = sy-dynnr
      dynprofield     = space
      window_title    = 'Banco'
      value_org       = 'S'
    TABLES
      value_tab       = it_mov
      return_tab      = return_tab
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

*Begin of change: ReSQ Correction INDEX READ on an unsorted Internal TABLE 24/12/2019 EY_DES02 ECDK917080 *
  SORT return_tab .
*End of change: ReSQ Correction for INDEX READ on an unsorted Internal TABLE 24/12/2019 EY_DES02 ECDK917080 *
  READ TABLE return_tab INDEX 1.

  "obtengo el fieldtext donde esta el cursor
  GET CURSOR FIELD fld OFFSET off VALUE val LENGTH len.
  ASSIGN (fld) TO <campo>.
  MOVE return_tab-fieldval TO <campo>.

  "se rescatan los dias a caducar segun tabla de configuracion.

AT SELECTION-SCREEN OUTPUT.

  IF flag_ini IS INITIAL.
    flag_ini = 'X'.
    DATA: lv_caduco TYPE c LENGTH 2.
    SELECT SINGLE valor INTO lv_caduco
      FROM zfitr020_t04
      WHERE nombre = 'D_CADUCO'.

    p_dcadu1 = lv_caduco.
    p_dcadu2 = lv_caduco.
    p_dcadu3 = lv_caduco.

  ENDIF.

  LOOP AT SCREEN.
    IF screen-name = 'P_DCADU1' OR
       screen-name = 'P_DCADU2' OR
       screen-name = 'P_DCADU3' .

      screen-input = 0.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.
*---------------------------------------------------------------------*
*                    INITIALIZATION
*---------------------------------------------------------------------*
INITIALIZATION.
  name1 = 'CAD MASIVO ELECTRONICO'.
  name2 = 'CAD ELECT POR CHEQUE'.
  name3 = 'CAD ELECT POR COMPROBANTE'.


*------------------------------------------------------------------------------
* Comienzo de Programa
*------------------------------------------------------------------------------
START-OF-SELECTION.
  "dependiendo del tab que venga se realizan busquedas distintas las cuales
  "tienen un unico alv de salida
*--------------------------------------------------------------------*
*   Primera pestaña: CAD MASIVO ELECTRONICO
*--------------------------------------------------------------------*
  IF tabname EQ '101' OR tabname IS INITIAL.
    IF p_bukrs1 IS INITIAL.
      MESSAGE 'El campo sociedad no puede estar vacio' TYPE 'E'.
    ENDIF.
    PERFORM selecciona.
    PERFORM crea_alv.
*--------------------------------------------------------------------*
* Segunda pestaña: CAD ELECT POR CHEQUE
*--------------------------------------------------------------------*
  ELSEIF tabname EQ '102'.
    IF p_bukrs2 IS INITIAL.
      MESSAGE 'El campo sociedad no puede estar vacio' TYPE 'E'.
    ENDIF.
    PERFORM selecciona2.
    PERFORM crea_alv2.
*--------------------------------------------------------------------*
* Tercera pestaña: CAD ELECT POR COMPROBANTE
*--------------------------------------------------------------------*
  ELSEIF tabname EQ '103'.
    IF p_bukrs3 IS INITIAL.
      MESSAGE 'El campo sociedad no puede estar vacio' TYPE 'E'.
    ELSEIF p_gjahr3 IS INITIAL.
      MESSAGE 'El campo ejercicio no puede ser vacio' TYPE 'E'.
    ENDIF.
    PERFORM selecciona3.
    PERFORM crea_alv3.
  ENDIF.

  PERFORM alv_report.

  PERFORM job.
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

  wa_fieldcat-fieldname = 'ZUONR'.
  wa_fieldcat-scrtext_m = 'Asignacion'.
  wa_fieldcat-outputlen = 18.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR  wa_fieldcat.
**GJaHR
  wa_fieldcat-fieldname = 'GJAHR'.
  wa_fieldcat-scrtext_m = 'Periodo'.
  wa_fieldcat-outputlen = 4.
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

  wa_fieldcat-fieldname = 'BLART'.
  wa_fieldcat-scrtext_m = 'Clase Doc.'.
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

*  * Set layout field for field attributes(i.e. input/output)
  gd_layout-stylefname = 'FIELD_STYLE'.
  gd_layout-zebra             = 'X'.
  gd_layout-cwidth_opt = 'X'.
ENDFORM.                    " LAYOUT_BUILD
*&---------------------------------------------------------------------*
*&      Form  ALV_LISTADO
*&---------------------------------------------------------------------*
*     Despliega el alv principal
*--------------------------------------------------------------------*
FORM alv_listado .

  IF sy-batch IS INITIAL.
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
  ENDIF.
ENDFORM.                    " ALV_LISTADO
*&---------------------------------------------------------------------*
*&      Form  USER_COMMAND
*&---------------------------------------------------------------------*
*       User_command del alv principal
*----------------------------------------------------------------------*
FORM user_command USING r_ucomm LIKE sy-ucomm
                           rs_selfield TYPE slis_selfield.
  "marca el checkbox si fue seleccionado
  IF ref_grid IS INITIAL.
    CALL FUNCTION 'GET_GLOBALS_FROM_SLVC_FULLSCR'
      IMPORTING
        e_grid = ref_grid.
  ENDIF.

  IF NOT ref_grid IS INITIAL.
    CALL METHOD ref_grid->check_changed_data.
  ENDIF.

  CASE r_ucomm.
    WHEN 'PICK' OR '&IC1'."click sobre el alv
      IF rs_selfield-fieldname = 'BELNR'.
        READ TABLE itab WITH KEY belnr = rs_selfield-value.
        SET PARAMETER ID 'BLN' FIELD rs_selfield-value.
        SET PARAMETER ID 'BUK' FIELD itab-bukrs.
        SET PARAMETER ID 'GJR' FIELD itab-gjahr.
        CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
      ENDIF.
      IF rs_selfield-fieldname = 'FLAG'."deseleccion o selecciona
        READ TABLE itab INDEX rs_selfield-tabindex.
        IF itab-flag = 'X'.
          CLEAR itab-flag.
        ELSEIF itab-flag IS INITIAL AND itab-zzmot_emis IS NOT INITIAL.
          itab-flag = 'X'.
        ENDIF.
        MODIFY itab INDEX rs_selfield-tabindex.
        rs_selfield-refresh = 'X'.
      ENDIF.

    WHEN '&ALL2'."marca todos
      LOOP AT itab.
        IF itab-zzmot_emis IS NOT INITIAL.
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

    WHEN '&CONTA'."ejecuta funcion sobre los que esten seleccionados
      REFRESH ti_return.
      LOOP AT itab WHERE flag = 'X'.

        MOVE-CORRESPONDING itab TO t_itab.
        PERFORM carga_datos.
        PERFORM carga_tablas.
        PERFORM ejecuta_funcion.
      ENDLOOP.
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
FORM set_specific_field_attributes .
  DATA ls_stylerow TYPE lvc_s_styl .
  DATA lt_styletab TYPE lvc_t_styl .

  "deshabilito el check box de la linea si la via de pago viene vacia
  LOOP AT itab .
    IF itab-zzmot_emis IS INITIAL.
      ls_stylerow-fieldname = 'FLAG'.
      ls_stylerow-style = cl_gui_alv_grid=>mc_style_disabled.
      INSERT ls_stylerow INTO TABLE itab-field_style.
      MODIFY itab.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " SET_SPECIFIC_FIELD_ATTRIBUTES*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  carga_tablas
*&---------------------------------------------------------------------*
*   Se cargan las tablas internas a usar por la funcion
*--------------------------------------------------------------------*
FORM carga_tablas.
  CLEAR: v_val, v_hkont, wa_bseg2, wa_bse_clr.                                    "agregado 17.10.2014
  PERFORM validar_emision.                                                        "Agregado 17.10.2014
  REFRESH l_t_ftclear.  CLEAR l_t_ftclear.
  REFRESH l_t_ftpost.   CLEAR l_t_ftpost.


**--------------------------------------------------------------------*
**    Agregado 23.10.2014
**--------------------------------------------------------------------*
*  DATA: fecha_in   TYPE budat,
*        fecha_fin  TYPE budat,
*        belnr      TYPE bsis-BELNR,
*        gjahr      TYPE BSE_CLR-gjahr_clr,
*        v_belnr    TYPE bsis-BELNR,
*        v_budat    TYPE budat,
*        v_hkont    TYPE bsas-hkont.
*
*  IF v_val EQ 'X'.
*
*    CLEAR: v_belnr, v_budat, v_hkont, wa_bse_clr.
*    belnr = t_itab-belnr.
*    gjahr = t_itab-gjahr.
*
*    IF t_itab-hkont+9(1) EQ '9'.
*
*
*
*      SELECT SINGLE CTA_CHEQS
*      INTO v_hkont
*      FROM ZFITR020_T05
*      WHERE bukrs = t_itab-bukrs
*      AND   HBKID = t_itab-hbkid
*      AND   hktid = t_itab-hktid.
*
*      WHILE v_belnr IS INITIAL.
*
*        SELECT SINGLE *
*        INTO CORRESPONDING FIELDS OF wa_bse_clr
*        FROM BSE_CLR
*        WHERE bukrs_clr = t_itab-bukrs
*        AND belnr_clr = belnr
*        AND gjahr_clr = gjahr.
*
*        CONCATENATE wa_bse_clr-gjahr '01' '01' INTO fecha_in .
*        CONCATENATE wa_bse_clr-gjahr '12' '31' INTO fecha_fin .
*
*        SELECT SINGLE belnr budat
*        INTO (v_belnr, v_budat)
*        FROM bsas
*        WHERE bukrs = t_itab-bukrs
*        AND hkont = v_hkont
*        AND augdt BETWEEN fecha_in AND fecha_fin
*        AND augbl = wa_bse_clr-belnr
*        AND belnr NE wa_bse_clr-belnr.
*
*        IF sy-subrc EQ 0.
*          t_itab-belnr = v_belnr.
*          t_itab-budat = v_budat.
*          t_itab-gjahr = v_budat(4).
*        ELSE.
*          belnr = wa_bse_clr-belnr.
*          gjahr = wa_bse_clr-gjahr.
*        ENDIF.
*
*      ENDWHILE.
*    ENDIF.
*  ENDIF.
**--------------------------------------------------------------------*
**    Fin Agregado 23.10.2014
**--------------------------------------------------------------------*



  l_t_ftclear-agkoa = 'S'.            "CONSTANTE
  l_t_ftclear-agkon = t_itab-hkont.   "HKONT ALV
  l_t_ftclear-agbuk = t_itab-bukrs.   "SOCIEDAD ALV
  l_t_ftclear-xnops = 'X'.            "CONSTANTE
*    l_t_ftclear-xfifo = ' '.
*    l_t_ftclear-agums = l_cme.
*    l_t_ftclear-avsid = ' '.
  l_t_ftclear-selfd = 'BELNR'.        "CONSTANTE
  CONCATENATE t_itab-belnr t_itab-gjahr INTO l_t_ftclear-selvon." = t_itab-belnr.  "BELNR ALV
*    l_t_ftclear-selbis = ' '.
  APPEND l_t_ftclear.
**---------------------------------------------------------------------
*  BUDAT ALV
**---------------------------------------------------------------------
  l_t_ftpost-stype = 'K'.
  l_t_ftpost-count = '1'.
  l_t_ftpost-fnam = 'BKPF-BLDAT'.
  CONCATENATE t_itab-budat+6(2) t_itab-budat+4(2) t_itab-budat(4) INTO l_t_ftpost-fval. CONDENSE l_t_ftpost-fval.
  APPEND l_t_ftpost.
**---------------------------------------------------------------------
*  Fe.contabilización DATO DE ENTRADA
**---------------------------------------------------------------------
  l_t_ftpost-fnam = 'BKPF-BUDAT'.
  CONCATENATE l_fecha+6(2) l_fecha+4(2) l_fecha(4) INTO l_t_ftpost-fval . CONDENSE l_t_ftpost-fval."p_budat1."l_fecpop.
  APPEND l_t_ftpost.
**---------------------------------------------------------------------
*  MES DATO DE ENTRADA
**---------------------------------------------------------------------
  l_t_ftpost-fnam = 'BKPF-MONAT'.
  l_t_ftpost-fval = l_fecha+4(2).
  APPEND l_t_ftpost.
**---------------------------------------------------------------------
*  SOCIEDAD ALV
**---------------------------------------------------------------------
  l_t_ftpost-fnam = 'BKPF-BUKRS'. "Sociedad
  l_t_ftpost-fval = t_itab-bukrs.
  APPEND l_t_ftpost.
**---------------------------------------------------------------------
*  TABLA ZFITR020_T03-TIPO_CTA CLASE_DOC 1005
*  lo lleno en una subrutina dependiendo del proceso
**---------------------------------------------------------------------
  l_t_ftpost-fnam = 'BKPF-BLART'. "Clase de documento
  l_t_ftpost-fval = l_clase_doc.
  APPEND l_t_ftpost.
**---------------------------------------------------------------------
*  CONSTANTE
**---------------------------------------------------------------------
  l_t_ftpost-fnam = 'BKPF-WAERS'. "Tipo de moneda
  l_t_ftpost-fval = 'CLP'.
  APPEND l_t_ftpost.
**---------------------------------------------------------------------
*  CAMPO CHEQUE DEL ALV SI ES VACIO COLOCAR BELNR+GJHAR DEL ALV
**---------------------------------------------------------------------
  l_t_ftpost-fnam = 'BKPF-XBLNR'.
  IF t_itab-chect IS NOT INITIAL.
    l_t_ftpost-fval = t_itab-chect.
  ELSE.
    CONCATENATE t_itab-belnr t_itab-gjahr INTO l_t_ftpost-fval .
  ENDIF.
  APPEND l_t_ftpost.
**---------------------------------------------------------------------
*  CONSTANTE
*  lo lleno en una subrutina dependiendo del proceso
**---------------------------------------------------------------------
  l_t_ftpost-fnam = 'BKPF-BKTXT'. "Nombre de proceso
  l_t_ftpost-fval = l_nom_proceso."'CADUCO ELECTRONICO'.
  APPEND l_t_ftpost.
**---------------------------------------------------------------------
*  CONCATENA "CADUCO ELECTRONICO"+"VIA D EPAGO ALV"+BANCO ALV+ ID DE CTA ALV
**---------------------------------------------------------------------
  l_t_ftpost-fnam = 'RF05A-AUGTX'. "Nombre de proceso
  CONCATENATE l_nom_proceso ' - '  t_itab-hbkid ' - ' t_itab-hktid INTO l_texto SEPARATED BY space.
  l_t_ftpost-fval = l_texto.
  APPEND l_t_ftpost.
**---------------------------------------------------------------------
*  CONSTANTE
**---------------------------------------------------------------------
  l_t_ftpost-fnam = 'RF05A-NEWBS'.
  IF v_val EQ 'X'.                                                        "Agregado 17.10.2014
    l_t_ftpost-fval = '31'.                                               "Agregado 17.10.2014
  ELSE.                                                                   "Agregado 17.10.2014
    l_t_ftpost-fval = '50'.
  ENDIF.
  APPEND l_t_ftpost.
**---------------------------------------------------------------------
*  CONSULTAR TABLA ZFITR020_T05 CAMPO CTA_CDCO.E CON SOCIEDAD ALV - BANCO PROPIO ALV - ID CTA ALV
*  lo lleno en una subrutina
**---------------------------------------------------------------------
  l_t_ftpost-fnam = 'RF05A-NEWKO'.
  IF v_val EQ 'X'.                                                        "Agregado 17.10.2014
    l_t_ftpost-fval = wa_bseg2-lifnr.                                     "Agregado 17.10.2014
  ELSE.                                                                   "Agregado 17.10.2014
    l_t_ftpost-fval = l_cta_contrap.
  ENDIF.
  APPEND l_t_ftpost.
**---------------------------------------------------------------------
*  Cuenta de mayor                                                          "ini agregado 17.10.2014
**---------------------------------------------------------------------
  IF v_val EQ 'X'.
    l_t_ftpost-fnam = 'BSEG-HKONT'.
    l_t_ftpost-fval = v_hkont.
    APPEND l_t_ftpost.
  ENDIF.                                                                    "fin agregado 17.10.2014
**---------------------------------------------------------------------
*  IMPORTE ALV
**---------------------------------------------------------------------
  DATA: l_monto(15) TYPE c.
  l_t_ftpost-fnam = 'BSEG-WRBTR'. "monto
  WRITE t_itab-wrbtr TO l_monto CURRENCY 'CLP'.
  CONDENSE l_monto NO-GAPS.
  l_t_ftpost-fval = l_monto.
  APPEND l_t_ftpost.
**---------------------------------------------------------------------
*  CAMPO CHEQUE DEL ALV SI ES VACIO COLOCAR BELNR+GJHAR DEL ALV
**---------------------------------------------------------------------
  l_t_ftpost-fnam = 'BSEG-ZUONR'.
  IF t_itab-chect IS NOT INITIAL.
    l_t_ftpost-fval = t_itab-chect.
  ELSE.
    CONCATENATE t_itab-belnr t_itab-gjahr INTO l_t_ftpost-fval .
  ENDIF.
  APPEND l_t_ftpost.
**---------------------------------------------------------------------
*  CONCATENA "CADUCO ELECTRONICO"+"VIA D EPAGO ALV"+BANCO ALV+ ID DE CTA ALV
**---------------------------------------------------------------------
  l_t_ftpost-fnam = 'BSEG-SGTXT'.
  CONCATENATE l_nom_proceso ' - ' t_itab-hbkid ' - ' t_itab-hktid INTO l_texto SEPARATED BY space.
  l_t_ftpost-fval = l_texto.
  APPEND l_t_ftpost.

  IF v_val NE 'X'.
**---------------------------------------------------------------------
*  Fe.contabilización DATO DE ENTRADA
**---------------------------------------------------------------------
    l_t_ftpost-fnam = 'BSEG-VALUT'.
    CONCATENATE l_fecha+6(2) l_fecha+4(2) l_fecha(4) INTO l_t_ftpost-fval . CONDENSE l_t_ftpost-fval."p_budat1."l_fecpop.
    APPEND l_t_ftpost.
  ENDIF.

**---------------------------------------------------------------------
*  MOTIVO EMISION ALV
**---------------------------------------------------------------------
  IF v_val EQ 'X'.
    l_t_ftpost-fnam = 'BSEG-ZZMOT_EMIS'.
    l_t_ftpost-fval = t_itab-zzmot_emis.
    APPEND l_t_ftpost.
  ELSE.
    l_t_ftpost-fnam = 'COBL-ZZMOT_EMIS'.
    l_t_ftpost-fval = t_itab-zzmot_emis.
    APPEND l_t_ftpost.
  ENDIF.
**---------------------------------------------------------------------
*  Banco Propio                                                             "ini agregado 17.10.2014
**---------------------------------------------------------------------
  IF v_val EQ 'X'.
    l_t_ftpost-fnam = 'BSEG-HBKID'.
    l_t_ftpost-fval = wa_bseg2-hbkid.
    APPEND l_t_ftpost.
  ENDIF.
**---------------------------------------------------------------------
*  refkey2
**---------------------------------------------------------------------
  IF v_val EQ 'X'.
    l_t_ftpost-fnam = 'BSEG-XREF3'.
    CONCATENATE wa_bseg2-belnr wa_bseg2-gjahr ' ' wa_bseg2-buzei INTO l_t_ftpost-fval.
    APPEND l_t_ftpost.
  ENDIF.                                                                    "fin agregado 17.10.2014

ENDFORM.                    " CARGA_TABLAS
*&---------------------------------------------------------------------*
*&      Form  ejecuta_funcion
*&---------------------------------------------------------------------*
*   Funcion estandar POSTING_INTERFACE_CLEARING
*--------------------------------------------------------------------*
FORM ejecuta_funcion.

  l_group = 'ZFITR0020'."sy-tcode.                                 "modificado para job de fondo
*********************************
*Cambiar modo de visualizacion
* A	Visual.pant.(todas)
* E	Visualizar sólo errores
* N	Sin visualización

  l_ver_batch = 'N'.
*********************************
*--- Posting interface start
  CALL FUNCTION 'POSTING_INTERFACE_START'
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
      OTHERS             = 6.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
           WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  CALL FUNCTION 'POSTING_INTERFACE_CLEARING'
    EXPORTING
      i_auglv                    = 'UMBUCHNG'
      i_tcode                    = c_fipi_trans_compensacion
      i_sgfunct                  = 'C'
      i_no_auth                  = ' '
    IMPORTING
      e_msgid                    = sy-msgid
      e_msgno                    = sy-msgno
      e_msgty                    = sy-msgty
      e_msgv1                    = sy-msgv1
      e_msgv2                    = sy-msgv2
      e_msgv3                    = sy-msgv3
      e_msgv4                    = sy-msgv4
*     e_subrc                    = sy-subrc
    TABLES
      t_blntab                   = l_t_blntab
      t_ftclear                  = l_t_ftclear
      t_ftpost                   = l_t_ftpost
      t_fttax                    = l_t_fttax
    EXCEPTIONS
      clearing_procedure_invalid = 1
      clearing_procedure_missing = 2
      table_t041a_empty          = 3
      transaction_code_invalid   = 4
      amount_format_error        = 5
      too_many_line_items        = 6
      company_code_invalid       = 7
      screen_not_found           = 8
      no_authorization           = 9
      OTHERS                     = 10.

  COMMIT WORK.

*  message id sy-msgid type sy-msgty number sy-msgno
*       with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.

  "lleno la tabla de salida del proceso con el mensaje
  "de la interfaz mas algunos datos adicinales
  CLEAR ti_return.
  ti_return-type        = sy-msgty.
  ti_return-id          = sy-msgid.
  ti_return-number      = sy-msgno.
  ti_return-belnr       = t_itab-belnr.
  ti_return-bukrs       = t_itab-bukrs.
  ti_return-gjahr       = t_itab-gjahr.

  IF t_itab-multi IS NOT INITIAL.

    ti_return-multi_bukrs = t_itab-multi_bukrs.
    ti_return-multi_belnr = t_itab-multi_belnr.
    ti_return-multi_gjahr = t_itab-multi_gjahr.

  ENDIF.
  "mensaje estandar a string
  PERFORM convierte_mensaje USING sy-msgid sy-msgno CHANGING ti_return-message.
  ti_return-message_v1  = sy-msgv1.
*--------------------------------------------------------------------*
*  ini agregado 17.10.2014 anula cheque
*--------------------------------------------------------------------*
  IF v_val EQ 'X'.
    IF ti_return-message_v1 IS NOT INITIAL AND t_itab-chect IS NOT INITIAL.
      PERFORM anula_cheque USING t_itab-chect t_itab-hbkid t_itab-hktid t_itab-bukrs.

      "mensaje estandar a string
      PERFORM convierte_mensaje USING sy-msgid sy-msgno CHANGING ti_return-message2.
      ti_return-message_v2 = sy-msgv1.

    ENDIF.
  ENDIF.
*--------------------------------------------------------------------*
*  fin agregado 17.10.2014
*--------------------------------------------------------------------*

  APPEND ti_return.

  CALL FUNCTION 'POSTING_INTERFACE_END'
* EXPORTING
*   I_BDCIMMED                    = ' '
*   I_BDCSTRTDT                   = NO_DATE
*   I_BDCSTRTTM                   = NO_TIME
    EXCEPTIONS
      session_not_processable = 1
      OTHERS                  = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    " EJECUTA_FUNCION
*&---------------------------------------------------------------------*
*&      Form  CARGA_DATOS
*&---------------------------------------------------------------------*
*       Se llena el nombre del proceso y la clase de documento
*       segun el id de proceso.
*----------------------------------------------------------------------*
FORM carga_datos .

  SELECT SINGLE clase_doc cambio_estado INTO (l_clase_doc, l_nom_proceso)
    FROM zfitr020_t03
    WHERE id_proceso = '1005'.

  IF tabname EQ '101' OR tabname IS INITIAL.
    l_fecha = p_budat1-low.
  ELSEIF tabname EQ '102'.
    l_fecha = p_budat2-low.
  ELSEIF tabname EQ '103'.
    l_fecha = p_budat3-low.
  ENDIF.
  "se busca la cuenta de la contrapartida
  SELECT SINGLE cta_cdco_e INTO l_cta_contrap
    FROM zfitr020_t05
    WHERE bukrs = t_itab-bukrs
      AND hbkid = t_itab-hbkid
      AND hktid = t_itab-hktid.

ENDFORM.                    " CARGA_DATOS
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_MESSAGES
*&---------------------------------------------------------------------*
*       Despliega el alv de resultado de la funcion.
*----------------------------------------------------------------------*
FORM display_messages .
  DATA: t_fieldcat      TYPE slis_t_fieldcat_alv.
  DATA: t_events        TYPE slis_alv_event OCCURS 0.
  DATA: g_repid LIKE sy-cprog.

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
*     i_callback_pf_status_set = 'FRM_PF_STATUS2'
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
FORM fieldcat_init_salida  USING   rt_fieldcat TYPE slis_t_fieldcat_alv.
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

*  CLEAR ls_fieldcat.
*  pos = pos + 1.
*  ls_fieldcat-col_pos       =  pos.
*  ls_fieldcat-fieldname     = 'MULTI_'.
*  ls_fieldcat-seltext_s     = 'Multi'.
*  ls_fieldcat-seltext_l     = 'Multi'.
*  ls_fieldcat-outputlen     = '1'.
*  APPEND ls_fieldcat TO  rt_fieldcat.




ENDFORM.                    " FIELDCAT_INIT_SALIDA
*&---------------------------------------------------------------------*
*&      Form  user_command2
*&---------------------------------------------------------------------*
*       user_command del alv de resultado de la funcion
*----------------------------------------------------------------------*
FORM user_command2 USING r_ucomm LIKE sy-ucomm
                           rs_selfield TYPE slis_selfield.

  CASE r_ucomm.
    WHEN 'PICK' OR '&IC1'. "doble click en alv
      IF rs_selfield-fieldname = 'MESSAGE_V1'.
        IF rs_selfield-value IS NOT INITIAL.
          READ TABLE ti_return WITH KEY belnr = rs_selfield-value.
          IF ti_return-multi_belnr IS NOT INITIAL.
            SET PARAMETER ID 'BLN' FIELD rs_selfield-value.
            SET PARAMETER ID 'BUK' FIELD ti_return-multi_bukrs.
            SET PARAMETER ID 'GJR' FIELD ti_return-multi_gjahr.
            CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
          ELSE.
            SET PARAMETER ID 'BLN' FIELD rs_selfield-value.
            SET PARAMETER ID 'BUK' FIELD ti_return-bukrs.
            SET PARAMETER ID 'GJR' FIELD ti_return-gjahr.
            CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
          ENDIF.
        ENDIF.
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
  SET PF-STATUS 'STANDARD2' .
ENDFORM.                    "FRM_PF_STATUS.
*&---------------------------------------------------------------------*
*&      Form  SELECCIONA
*&---------------------------------------------------------------------*
*     Rescate de datos correspondiente al primer tab
*     CAD MASIVO ELECTRONICO
*--------------------------------------------------------------------*
FORM selecciona .
*  rangos y variables
  DATA:   lv_budat TYPE budat.
  RANGES: r_hkont FOR bsis-hkont.
  RANGES: r_budat FOR bsas-augdt.

  "si el banco propio y la cuenta son vacias se debe traer
  "todas las cuentas y bancos asociados a la sociedad.
  IF p_hbkid1 IS NOT INITIAL AND p_hktid1 IS NOT INITIAL.
    "rescato las cuentas de la tabla mantenedora.
    SELECT * INTO CORRESPONDING FIELDS OF TABLE ti_zfitr020_t05
      FROM zfitr020_t05
      WHERE bukrs IN p_bukrs1
        AND hbkid IN p_hbkid1
        AND hktid IN p_hktid1.

    IF sy-subrc <> 0.
      MESSAGE 'combinacion no existente en tabla de cuentas' TYPE 'E'.
    ENDIF.
    "armo el rango de cuentas
    LOOP AT ti_zfitr020_t05 INTO wa_zfitr020_t05.
      CLEAR r_hkont.
      r_hkont-low    = wa_zfitr020_t05-cta_cheqs.
      r_hkont-sign   = 'I'.
      r_hkont-option = 'EQ'.
      APPEND r_hkont.

*      CLEAR r_hkont.
*      r_hkont-low    = wa_ZFITR020_T05-CTA_TRANS.
*      r_hkont-sign   = 'I'.
*      r_hkont-OPTION = 'EQ'.
*      APPEND r_hkont.

      CLEAR r_hkont.
      r_hkont-low    = wa_zfitr020_t05-revalidad.
      r_hkont-sign   = 'I'.
      r_hkont-option = 'EQ'.
      APPEND r_hkont.

    ENDLOOP.
  ELSE.

    SELECT * INTO CORRESPONDING FIELDS OF TABLE ti_zfitr020_t05
      FROM zfitr020_t05
      WHERE bukrs IN p_bukrs1.
    "armo el rango de cuentas
    LOOP AT ti_zfitr020_t05 INTO wa_zfitr020_t05.
      CLEAR r_hkont.
      r_hkont-low    = wa_zfitr020_t05-cta_cheqs.
      r_hkont-sign   = 'I'.
      r_hkont-option = 'EQ'.
      APPEND r_hkont.
*comentado * se elimina porque corresponde a vale vistas y este proceso se maneja por otro programa
*      CLEAR r_hkont.
*      r_hkont-low    = wa_ZFITR020_T05-CTA_TRANS.
*      r_hkont-sign   = 'I'.
*      r_hkont-OPTION = 'EQ'.
*      APPEND r_hkont.

      CLEAR r_hkont.
      r_hkont-low    = wa_zfitr020_t05-revalidad.
      r_hkont-sign   = 'I'.
      r_hkont-option = 'EQ'.
      APPEND r_hkont.
    ENDLOOP.
  ENDIF.
  "si el campo fecha viene vacio se debe usar la fecha
  "del sistema
  IF p_budat1-low IS INITIAL.
    p_budat1-low = sy-datum.
  ENDIF.
  lv_budat = p_budat1-low - p_dcadu1.

  "se buscan las partidas abiertas
  SELECT * INTO CORRESPONDING FIELDS OF TABLE ti_bsis
    FROM bsis
    WHERE bukrs IN p_bukrs1
      AND hkont IN r_hkont
      AND budat < lv_budat
      AND ( blart EQ 'ZP' OR blart EQ 'XD' OR blart EQ 'ZA' ).

  IF sy-subrc <> 0.
    MESSAGE 'No se encontraron partidas abiertas' TYPE 'E'.
  ENDIF.

  "se buscan los cheques asociados a las partidas
  "abiertas encontradas
  SELECT * INTO CORRESPONDING FIELDS OF TABLE ti_payr
    FROM payr FOR ALL ENTRIES IN ti_bsis
    WHERE zbukr = ti_bsis-bukrs
      AND vblnr = ti_bsis-belnr
      AND gjahr = ti_bsis-gjahr.

  LOOP AT ti_bsis INTO wa_bsis.
    REFRESH r_budat.
    CLEAR r_budat.
    CONCATENATE wa_bsis-gjahr '01' '01' INTO r_budat-low.
    CONCATENATE wa_bsis-gjahr '12' '31' INTO r_budat-high.
    r_budat-sign = 'I'.
    r_budat-option = 'BT'.
    APPEND r_budat.
    "Se busca el documento general de pago el que tiene
    "el concepto de emision
    SELECT * INTO CORRESPONDING FIELDS OF wa_bsas
      FROM bsas
      WHERE bukrs IN p_bukrs1
        AND augdt IN r_budat
        AND augbl = wa_bsis-belnr
        AND belnr <> wa_bsis-belnr.

      wa_bsas-bukrs_bsis = wa_bsis-bukrs.
      wa_bsas-gjahr_bsis = wa_bsis-gjahr.
      APPEND wa_bsas TO ti_bsas.
    ENDSELECT.

    IF sy-subrc <> 0 AND wa_bsis-blart = 'ZP'.
      PERFORM busca_doc_pago_multi_com.
    ENDIF.
  ENDLOOP.

*  if ti_bsas[] is INITIAL.
*    MESSAGE 'No se encontraron datos' type 'E'.
*  endif.

  ti_bsas_aux[] = ti_bsas[].
  SORT ti_bsas_aux BY belnr gjahr.
  DELETE ADJACENT DUPLICATES FROM ti_bsas_aux.

  DATA: lv_lines TYPE i.
  DESCRIBE TABLE ti_bsas_aux LINES lv_lines.
  IF lv_lines > 0.

    SELECT * INTO CORRESPONDING FIELDS OF TABLE ti_bseg
    FROM bseg FOR ALL ENTRIES IN ti_bsas_aux
    WHERE belnr = ti_bsas_aux-belnr
    AND gjahr = ti_bsas_aux-gjahr
    AND zlsch <> ' '
    AND zzmot_emis <> ' '
*Begin of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 24/12/2019 EY_DES02 ECDK917080 *
*.
    ORDER BY PRIMARY KEY.
*End of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 24/12/2019 EY_DES02 ECDK917080 *
    "en el caso de las cuentas que terminan en 7 y 9 la
    "busqueda se hace directo en la bseg con el documento.
    SELECT * APPENDING CORRESPONDING FIELDS OF TABLE ti_bseg
    FROM bseg FOR ALL ENTRIES IN ti_bsis
    WHERE bukrs = ti_bsis-bukrs
    AND belnr = ti_bsis-belnr
    AND gjahr = ti_bsis-gjahr
*Begin of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 24/12/2019 EY_DES02 ECDK917080 *
*and HKONT = ti_bsis-HKONT.
    AND hkont = ti_bsis-hkont ORDER BY PRIMARY KEY.
*End of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 24/12/2019 EY_DES02 ECDK917080 *
  ENDIF.

ENDFORM.                    "selecciona
*&---------------------------------------------------------------------*
*&      Form  CREA_ALV
*&---------------------------------------------------------------------*
*       Armamos el AlV de salida para la pestaña
*       CAD MASIVO ELECTRONICO
*----------------------------------------------------------------------*
FORM crea_alv .
  REFRESH itab.

  LOOP AT ti_bsis INTO wa_bsis.
    CLEAR wa_bsas.
    CLEAR wa_bseg.
    CLEAR wa_zfitr020_t05.
    CLEAR wa_payr.
    CLEAR itab.

    MOVE-CORRESPONDING wa_bsis TO itab.
    IF wa_bsis-hkont+9(1) EQ '2' OR wa_bsis-hkont+9(1) EQ '5'.
*      read TABLE ti_bsas into wa_bsas with key bukrs = wa_bsis-bukrs
*                                               augbl = wa_bsis-belnr
**                                             BELNR <> wa_bsis-belnr
*                                             AUGDT "rango a partir de gjahr?
      .




      READ TABLE ti_bsas INTO wa_bsas WITH KEY bukrs_bsis = wa_bsis-bukrs
                                               augbl = wa_bsis-belnr
                                               gjahr_bsis = wa_bsis-gjahr.

      itab-multi = wa_bsas-multi.
      itab-multi_bukrs = wa_bsas-belnr.
      itab-multi_belnr = wa_bsas-gjahr.
      itab-multi_gjahr = wa_bsas-bukrs.



      READ TABLE ti_bseg INTO wa_bseg WITH KEY bukrs = wa_bsas-bukrs
                                               belnr = wa_bsas-belnr
                                               gjahr = wa_bsas-gjahr.

    ELSEIF wa_bsis-hkont+9(1) EQ '9'.
      READ TABLE ti_bseg INTO wa_bseg WITH KEY bukrs = wa_bsis-bukrs
                                               belnr = wa_bsis-belnr
                                               gjahr = wa_bsis-gjahr.
    ENDIF.
* ini - Waldo Alarcón - Visionone - 01-06-2020
*    itab-ZZMOT_EMIS = wa_bseg-ZZMOT_EMIS.
    IF sy-subrc EQ 0.
      itab-zzmot_emis = wa_bseg-zzmot_emis.
    ELSE.
      CLEAR     itab-zzmot_emis.
    ENDIF.
* fin - Waldo Alarcón - Visionone - 01-06-2020

    IF wa_bsis-hkont+9(1) EQ '2'.
      READ TABLE ti_payr INTO wa_payr WITH KEY zbukr = wa_bsis-bukrs
                                               vblnr = wa_bsis-belnr
                                               gjahr = wa_bsis-gjahr.
      itab-chect = wa_payr-chect.

      READ TABLE ti_zfitr020_t05 INTO wa_zfitr020_t05 WITH KEY bukrs     = itab-bukrs
                                                               cta_cheqs = wa_bsis-hkont.

      itab-estado = 'EMISION'.
    ELSEIF wa_bsis-hkont+9(1) EQ '5'.

      READ TABLE ti_zfitr020_t05 INTO wa_zfitr020_t05 WITH KEY bukrs     = itab-bukrs
                                                               cta_trans = wa_bsis-hkont.

      itab-estado = 'EMISION'.
    ELSEIF wa_bsis-hkont+9(1) EQ '6'.
      itab-estado = 'CAD.FIS'.
    ELSEIF wa_bsis-hkont+9(1) EQ '7'.
      itab-estado = 'CAD.ELC'.
    ELSEIF wa_bsis-hkont+9(1) EQ '9'.
      READ TABLE ti_zfitr020_t05 INTO wa_zfitr020_t05 WITH KEY bukrs     = itab-bukrs
                                                               revalidad = wa_bsis-hkont.
      itab-chect = wa_bsis-zuonr.
      itab-estado = 'REVALIDADO'.
    ENDIF.

    itab-hbkid = wa_zfitr020_t05-hbkid.
    itab-hktid = wa_zfitr020_t05-hktid.

    APPEND itab.

  ENDLOOP.
ENDFORM.                    " CREA_ALV
*&---------------------------------------------------------------------*
*&      Form  SELECCIONA2
*&---------------------------------------------------------------------*
*     Rescate de datos correspondiente al segundo tab
*     CAD ELECT POR CHEQUE
*--------------------------------------------------------------------*
FORM selecciona2 .
*  *  rangos y variables
  RANGES: r_budat FOR bsas-augdt.
  DATA:   lv_gjahr TYPE gjahr.
  DATA:   lv_budat TYPE datum.

  SELECT * INTO CORRESPONDING FIELDS OF TABLE ti_payr
    FROM payr
    WHERE zbukr IN p_bukrs2
      AND hbkid IN p_hbkid2
      AND hktid IN p_hktid2
      AND chect IN p_chect2
      AND voidr EQ '00'"cheque NO anulado
      AND xbanc EQ ' ' "cheque NO cobrado
            .

  IF sy-subrc <> 0.
    MESSAGE 'NO SE SELECCIONARON PARTIDAS PARA LA CONSULTA' TYPE 'E'.
  ENDIF.

  SELECT * INTO CORRESPONDING FIELDS OF TABLE ti_zfitr020_t05
    FROM zfitr020_t05
    WHERE bukrs IN p_bukrs2
      AND hbkid IN p_hbkid2
      AND hktid IN p_hktid2 .

  READ TABLE ti_zfitr020_t05 INTO wa_zfitr020_t05 INDEX 1.

  LOOP AT ti_payr INTO wa_payr.
    "preguntamos si es un cheque multisociedad
*    if wa_payr-xbukr is INITIAL.
    "solo nos interesa las cuentas terminadas en 2.
    "Se espera que en un proceso normal solo se rescaten
    "cuentas terminadas en 2(rescata cheques en cuenta 7)
    IF wa_payr-ubhkt+9(1) <> '2'.
      CONTINUE.
    ENDIF.

    PERFORM busca_partida_abierta_normal.
*    else.
*      PERFORM busca_partida_abierta_multiS.
*    endif.
  ENDLOOP.

  DATA: lv_lines TYPE i.
  DESCRIBE TABLE ti_bsis LINES lv_lines.

  IF lv_lines IS INITIAL.
    MESSAGE 'NO SE SELECCIONARON PARTIDAS ABIERTAS' TYPE 'E'.
  ENDIF.

  LOOP AT ti_bsis INTO wa_bsis.
    "se sabe si el cambo xburk es distinto de inicial el
    "documento es multi sociedad x lo que la busqueda del
    "motivo de emision cambia.
    IF wa_bsis-xburk IS INITIAL.
      PERFORM busca_doc_pago_normal.
    ELSE.
      PERFORM busca_doc_pago_multi.
    ENDIF.
  ENDLOOP.

*  if ti_bsas[] is INITIAL.
*    MESSAGE 'No se encontraron datos' type 'E'.
*  endif.

  ti_bsas_aux[] = ti_bsas[].
  SORT ti_bsas_aux BY belnr gjahr.
  DELETE ADJACENT DUPLICATES FROM ti_bsas_aux.

  DESCRIBE TABLE ti_bsas_aux LINES lv_lines.
  IF lv_lines > 0.

    SELECT * INTO CORRESPONDING FIELDS OF TABLE ti_bseg
    FROM bseg FOR ALL ENTRIES IN ti_bsas_aux
    WHERE belnr = ti_bsas_aux-belnr
    AND gjahr = ti_bsas_aux-gjahr
    AND bukrs = ti_bsas_aux-bukrs
    AND zzmot_emis <> ' '
*Begin of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 24/12/2019 EY_DES02 ECDK917080 *
*.
    ORDER BY PRIMARY KEY.
*End of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 24/12/2019 EY_DES02 ECDK917080 *
  ENDIF.
ENDFORM.                    " SELECCIONA2
*&---------------------------------------------------------------------*
*&      Form  CREA_ALV2
*&---------------------------------------------------------------------*
*       Armamos el AlV de salida para la segunda pestaña
*       CAD ELECT POR CHEQUE
*----------------------------------------------------------------------*
FORM crea_alv2 .
  REFRESH itab.

  LOOP AT ti_bsis INTO wa_bsis.
    CLEAR itab.
    CLEAR wa_payr.
    CLEAR wa_bsas.
    CLEAR wa_bseg.

    MOVE-CORRESPONDING wa_bsis TO itab.
    "si el flag viene marcado entonce se que el cheque
    "viene en el campo asignacion
    IF wa_bsis-marca EQ 'X'.
      READ TABLE ti_payr INTO wa_payr WITH KEY zbukr = wa_bsis-bukrs
                                               chect = wa_bsis-zuonr.
*                                               GJaHR = wa_bsis-GJaHR.            "comentado 24.10.2014
    ELSE .
      READ TABLE ti_payr INTO wa_payr WITH KEY zbukr = wa_bsis-bukrs
                                               vblnr = wa_bsis-belnr.
*                                               GJaHR = wa_bsis-GJaHR.
    ENDIF.

    itab-hbkid = wa_payr-hbkid.
    itab-hktid = wa_payr-hktid.
    itab-chect = wa_payr-chect.

    "Se busca el documento general de pago el que tiene
    "el concepto de emision
    READ TABLE ti_bsas INTO wa_bsas WITH KEY bukrs_bsis = wa_bsis-bukrs
                                             augbl      = wa_bsis-belnr
                                             gjahr_bsis = wa_bsis-gjahr.
    itab-multi = wa_bsas-multi.
    READ TABLE ti_bseg INTO wa_bseg WITH KEY bukrs = wa_bsas-bukrs
                                             belnr = wa_bsas-belnr
                                             gjahr = wa_bsas-gjahr.
* ini - Waldo Alarcón - Visionone - 01-06-2020
*    itab-zzmot_emis = wa_bseg-zzmot_emis.
    IF sy-subrc EQ 0.
      itab-zzmot_emis = wa_bseg-zzmot_emis.
    ELSE.
      CLEAR itab-zzmot_emis.
    ENDIF.
* fin - Waldo Alarcón - Visionone - 01-06-2020

    IF wa_bsis-hkont+9(1) EQ '2'.
      itab-estado = 'EMISION'.
    ELSEIF wa_bsis-hkont+9(1) EQ '5'.
      itab-estado = 'EMISION'.
    ELSEIF wa_bsis-hkont+9(1) EQ '6'.
      itab-estado = 'CAD.FIS'.
    ELSEIF wa_bsis-hkont+9(1) EQ '7'.
      itab-estado = 'CAD.ELC'.
    ELSEIF wa_bsis-hkont+9(1) EQ '9'.
      itab-chect = wa_bsis-zuonr.
      itab-estado = 'REVALIDADO'.
    ENDIF.

    APPEND itab.
  ENDLOOP.

ENDFORM.                                                    " CREA_ALV2
*&---------------------------------------------------------------------*
*&      Form  SELECCIONA3
*&---------------------------------------------------------------------*
*     Rescate de datos correspondiente al tercer tab
*     CAD ELECT POR COMPROBANTE
*--------------------------------------------------------------------*
FORM selecciona3 .
*  rangos y variables
  DATA: lv_budat TYPE budat.
  RANGES: r_hkont FOR bsis-hkont.
  RANGES: r_budat FOR bsas-augdt.
  DATA: lv_lines TYPE i.

  "si el banco propio y la cuenta son vacias se debe traer
  "todas las cuentas y bancos asociados a la sociedad.
  IF p_hbkid3 IS NOT INITIAL AND p_hktid3 IS NOT INITIAL.

    "rescato las cuentas asociadas en la tabla mantenedora
    SELECT * INTO CORRESPONDING FIELDS OF TABLE ti_zfitr020_t05
      FROM zfitr020_t05
      WHERE bukrs IN p_bukrs3
        AND hbkid IN p_hbkid3
        AND hktid IN p_hktid3.

    IF sy-subrc <> 0.
      MESSAGE 'combinacion no existente en tabla de cuentas' TYPE 'E'.
    ENDIF.

    "armo el rango de cuentas
    LOOP AT ti_zfitr020_t05 INTO wa_zfitr020_t05.
      CLEAR r_hkont.
      r_hkont-low    = wa_zfitr020_t05-cta_cheqs.
      r_hkont-sign   = 'I'.
      r_hkont-option = 'EQ'.
      APPEND r_hkont.

*      CLEAR r_hkont.
*      r_hkont-low    = wa_ZFITR020_T05-CTA_TRANS.
*      r_hkont-sign   = 'I'.
*      r_hkont-OPTION = 'EQ'.
*      APPEND r_hkont.
    ENDLOOP.
  ELSE.

    "rescato las cuentas asociadas en la tabla mantenedora
    SELECT * INTO CORRESPONDING FIELDS OF TABLE ti_zfitr020_t05
      FROM zfitr020_t05
      WHERE bukrs IN p_bukrs3.

    "armo el rango de cuentas
    LOOP AT ti_zfitr020_t05 INTO wa_zfitr020_t05.
      CLEAR r_hkont.
      r_hkont-low    = wa_zfitr020_t05-cta_cheqs.
      r_hkont-sign   = 'I'.
      r_hkont-option = 'EQ'.
      APPEND r_hkont.

*      CLEAR r_hkont.
*      r_hkont-low    = wa_ZFITR020_T05-CTA_TRANS.
*      r_hkont-sign   = 'I'.
*      r_hkont-OPTION = 'EQ'.
*      APPEND r_hkont.
    ENDLOOP.
  ENDIF.

  "si el campo fecha viene vacio se debe usar la fecha
  "del sistema
  IF p_budat3-low IS INITIAL.
    p_budat3-low = sy-datum.
  ENDIF.
  lv_budat = p_budat3-low - p_dcadu3.

  "se buscan las partidas abiertas.
  SELECT * INTO CORRESPONDING FIELDS OF TABLE ti_bsis
    FROM bsis
    WHERE bukrs IN p_bukrs3
      AND hkont IN r_hkont
      AND gjahr IN p_gjahr3
      AND belnr IN p_belnr3
      AND budat < lv_budat
      AND blart EQ 'ZP'.

  IF sy-subrc = 0.

    LOOP AT ti_bsis INTO wa_bsis.
      REFRESH r_budat.
      CLEAR r_budat.
      CONCATENATE wa_bsis-gjahr '01' '01' INTO r_budat-low.
      CONCATENATE wa_bsis-gjahr '12' '31' INTO r_budat-high.
      r_budat-sign = 'I'.
      r_budat-option = 'BT'.
      APPEND r_budat.
      "Se busca el documento general de pago el que tiene
      "el concepto de emision
      SELECT * INTO CORRESPONDING FIELDS OF wa_bsas
        FROM bsas
        WHERE bukrs IN p_bukrs3
          AND augdt IN r_budat
          AND augbl = wa_bsis-belnr
          AND belnr <> wa_bsis-belnr.

        wa_bsas-bukrs_bsis = wa_bsis-bukrs.
        wa_bsas-gjahr_bsis = wa_bsis-gjahr.
        APPEND wa_bsas TO ti_bsas.
      ENDSELECT.

      IF sy-subrc <> 0 AND wa_bsis-blart = 'ZP'.
        PERFORM busca_doc_pago_multi_com.
      ENDIF.
    ENDLOOP.

*    if ti_bsas[] is INITIAL.
*      MESSAGE 'No se encontraron datos' type 'E'.
*    endif.

    ti_bsas_aux[] = ti_bsas[].
    SORT ti_bsas_aux BY belnr gjahr.
    DELETE ADJACENT DUPLICATES FROM ti_bsas_aux.

    DESCRIBE TABLE ti_bsas_aux LINES lv_lines.
    IF lv_lines > 0.
      SELECT * INTO CORRESPONDING FIELDS OF TABLE ti_bseg
      FROM bseg FOR ALL ENTRIES IN ti_bsas_aux
      WHERE belnr = ti_bsas_aux-belnr
      AND gjahr = ti_bsas_aux-gjahr
      AND zzmot_emis <> ' '
*Begin of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 24/12/2019 EY_DES02 ECDK917080 *
*.
      ORDER BY PRIMARY KEY.
*End of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 24/12/2019 EY_DES02 ECDK917080 *

      SELECT * INTO CORRESPONDING FIELDS OF TABLE ti_payr
        FROM payr FOR ALL ENTRIES IN ti_bsis
        WHERE zbukr = ti_bsis-bukrs
          AND vblnr = ti_bsis-belnr
          AND gjahr = ti_bsis-gjahr.
    ENDIF.
*  else.
*    MESSAGE 'No se encuentran partidas abiertas' type 'E'.
  ENDIF.

ENDFORM.                    " SELECCIONA3
*&---------------------------------------------------------------------*
*&      Form  CREA_ALV3
*&---------------------------------------------------------------------*
*       Armamos el AlV de salida para la tercera pestaña
*       CAD ELECT POR COMPROBANTE
*----------------------------------------------------------------------*
FORM crea_alv3 .
  REFRESH itab.

  LOOP AT ti_bsis INTO wa_bsis.
    CLEAR wa_bsas.
    CLEAR wa_bseg.
    CLEAR wa_zfitr020_t05.
    CLEAR wa_payr.
    CLEAR itab.

    MOVE-CORRESPONDING wa_bsis TO itab.

    READ TABLE ti_bsas INTO wa_bsas WITH KEY bukrs_bsis = wa_bsis-bukrs
                                             augbl      = wa_bsis-belnr
                                             gjahr_bsis = wa_bsis-gjahr.
    itab-multi = wa_bsas-multi.
    READ TABLE ti_bseg INTO wa_bseg WITH KEY bukrs = wa_bsas-bukrs
                                             belnr = wa_bsas-belnr
                                             gjahr = wa_bsas-gjahr.
* ini - Waldo Alarcón - Visionone - 01-06-2020
*    itab-zzmot_emis = wa_bseg-zzmot_emis.
    IF sy-subrc EQ 0.
      itab-zzmot_emis = wa_bseg-zzmot_emis.
    ELSE.
      CLEAR itab-zzmot_emis.
    ENDIF.
* fin - Waldo Alarcón - Visionone - 01-06-2020

    IF wa_bsis-hkont+9(1) EQ '2'.
      READ TABLE ti_zfitr020_t05 INTO wa_zfitr020_t05 WITH KEY bukrs     = itab-bukrs
                                                               cta_cheqs = wa_bsis-hkont.

      READ TABLE ti_payr INTO wa_payr WITH KEY zbukr = wa_bsis-bukrs
                                               vblnr = wa_bsis-belnr
                                               gjahr = wa_bsis-gjahr
                                               voidr = '00'
                                               xbanc = ' '.
      itab-chect = wa_payr-chect.

      itab-estado = 'EMISION'.
    ELSEIF wa_bsis-hkont+9(1) EQ '5'.
      READ TABLE ti_zfitr020_t05 INTO wa_zfitr020_t05 WITH KEY bukrs     = itab-bukrs
                                                               cta_trans = wa_bsis-hkont.
      itab-estado = 'EMISION'.
    ELSEIF wa_bsis-hkont+9(1) EQ '6'.
      itab-estado = 'CAD.FIS'.
    ELSEIF wa_bsis-hkont+9(1) EQ '7'.
      itab-estado = 'CAD.ELC'.
    ELSEIF wa_bsis-hkont+9(1) EQ '9'.
      itab-estado = 'REVALIDADO'.
    ENDIF.

    itab-hbkid = wa_zfitr020_t05-hbkid.
    itab-hktid = wa_zfitr020_t05-hktid.

    APPEND itab.
  ENDLOOP.
ENDFORM.                                                    " CREA_ALV3
*&---------------------------------------------------------------------*
*&      Form  CONVIERTE_MENSAJE
*&---------------------------------------------------------------------*
*       Convierte en string el mensaje estandar
*----------------------------------------------------------------------*
FORM convierte_mensaje  USING    p_sy_msgid LIKE sy-msgid
                                 p_sy_msgno LIKE sy-msgno
                        CHANGING return_message   .

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
  ENDIF.

ENDFORM.                    " CONVIERTE_MENSAJE
*&---------------------------------------------------------------------*
*&      Form  BUSCA_PARTIDA_ABIERTA_NORMAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM busca_partida_abierta_normal .
  DATA:   lv_gjahr TYPE gjahr.
  DATA:   lv_budat TYPE datum.

  "si el campo fecha viene vacio se debe usar la fecha
  "del sistema
  IF p_budat2-low IS INITIAL.
    p_budat2-low = sy-datum.
  ENDIF.
  lv_gjahr = p_budat2-low(4).
  lv_budat = p_budat2-low - p_dcadu2.

  "se buscan las partidas abiertas con el documento compensado.
  SELECT * INTO CORRESPONDING FIELDS OF   wa_bsis
    FROM bsis
    WHERE bukrs EQ wa_payr-zbukr
      AND hkont EQ wa_payr-ubhkt
      AND gjahr EQ wa_payr-gjahr
      AND belnr EQ wa_payr-vblnr
      AND budat < lv_budat
      AND blart EQ 'ZP'.
    wa_bsis-xburk = wa_payr-xbukr. "si no es inicial este es un
    wa_bsis-zbukr_payr = wa_payr-zbukr.
    wa_bsis-vblnr_payr = wa_payr-vblnr.
    wa_bsis-gjahr_payr = wa_payr-gjahr.
    APPEND wa_bsis TO ti_bsis.     "doc multi sociedad
  ENDSELECT.
  IF sy-subrc <> 0.
    "si la busqueda anterior falla se reemplaza por la busqueda
    "del cheque en el campo zuonr, Este registro si es exitoso se
    "marca con un flag, puesto que el campo cheque viene en el
    "campo asignacion.
    SELECT *
      INTO CORRESPONDING FIELDS OF wa_bsis
      FROM bsis
      WHERE bukrs EQ wa_payr-zbukr
        AND ( hkont EQ wa_payr-ubhkt
         OR hkont EQ wa_zfitr020_t05-revalidad )
        AND zuonr EQ wa_payr-chect
        AND budat < lv_budat.

      wa_bsis-marca = 'X'.
      wa_bsis-xburk = wa_payr-xbukr."si no es inicial este es un

      wa_bsis-zbukr_payr = wa_payr-zbukr.
      wa_bsis-vblnr_payr = wa_payr-vblnr.
      wa_bsis-gjahr_payr = wa_payr-gjahr.
      APPEND wa_bsis TO ti_bsis.    "doc multi sociedad
    ENDSELECT.
  ENDIF.
ENDFORM.                    " BUSCA_PARTIDA_ABIERTA_NORMAL
*&---------------------------------------------------------------------*
*&      Form  BUSCA_PARTIDA_ABIERTA_MULTIS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM busca_partida_abierta_multis .

ENDFORM.                    " BUSCA_PARTIDA_ABIERTA_MULTIS
*&---------------------------------------------------------------------*
*&      Form  BUSCA_DOC_PAGO_NORMAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM busca_doc_pago_normal .
  RANGES: r_budat FOR bsas-augdt.
  DATA:   lv_gjahr TYPE gjahr.
  DATA:   lv_budat TYPE datum.

  REFRESH r_budat.
  CLEAR r_budat.
  CONCATENATE wa_bsis-gjahr '01' '01' INTO r_budat-low.
  CONCATENATE wa_bsis-gjahr '12' '31' INTO r_budat-high.
  r_budat-sign = 'I'.
  r_budat-option = 'BT'.
  APPEND r_budat.
  "Se busca el documento general de pago el que tiene
  "el concepto de emision
  SELECT * INTO CORRESPONDING FIELDS OF wa_bsas
    FROM bsas
    WHERE bukrs EQ wa_bsis-bukrs
      AND augdt IN r_budat
      AND augbl EQ wa_bsis-belnr
      AND belnr <> wa_bsis-belnr
    .
    wa_bsas-gjahr_bsis = wa_bsis-gjahr. "se  guardan estos campos adicionalmente
    wa_bsas-bukrs_bsis = wa_bsis-bukrs. "para realizar una sola busqueda para los
    APPEND wa_bsas TO ti_bsas.          "dos motivos de emision
  ENDSELECT.
ENDFORM.                    " BUSCA_DOC_PAGO_NORMAL
*&---------------------------------------------------------------------*
*&      Form  BUSCA_DOC_PAGO_MULTI
*&---------------------------------------------------------------------*
*       multisociedad
*----------------------------------------------------------------------*
FORM busca_doc_pago_multi .
  DATA: lv_bvorg LIKE bvor-bvorg.
  DATA: lv_gjahr2 LIKE zfitr020_t01-gjahr.
  DATA: lv_bukrs2 LIKE zfitr020_t01-bukrs.
  DATA: lv_belnr2 LIKE zfitr020_t01-belnr.

  "aca buscamos el documento multisociedad en la otra sociedad
  SELECT SINGLE bvorg
      INTO (lv_bvorg)
    FROM bvor
    WHERE belnr = wa_bsis-vblnr_payr
      AND bukrs = wa_bsis-zbukr_payr
      AND gjahr = wa_bsis-gjahr_payr
      .

  "busco: Número de operación contabilización multisociedades
  SELECT SINGLE bukrs gjahr belnr
      INTO (lv_bukrs2, lv_gjahr2, lv_belnr2)
    FROM bvor
    WHERE bvorg = lv_bvorg
      AND bukrs <> wa_bsis-zbukr_payr
      .

  DATA: lv_gjahr_orig LIKE zfitr020_t01-gjahr.
  DATA: lv_bukrs_orig LIKE zfitr020_t01-bukrs.
  DATA: lv_belnr_orig LIKE zfitr020_t01-belnr.

  "con el documento obtenido buscamos el documento pagado
  SELECT SINGLE belnr bukrs gjahr
      INTO (lv_belnr_orig, lv_bukrs_orig, lv_gjahr_orig)
    FROM bse_clr
   WHERE belnr_clr = lv_belnr2
     AND bukrs_clr = lv_bukrs2
     AND gjahr_clr = lv_gjahr2.

  IF sy-subrc = 0.
    wa_bsas-belnr      = lv_belnr_orig.
    wa_bsas-gjahr      = lv_gjahr_orig.
    wa_bsas-bukrs      = lv_bukrs_orig.
    wa_bsas-augbl      = wa_bsis-belnr."se guardan estos datos para
    wa_bsas-gjahr_bsis = wa_bsis-gjahr."unir el alv y buscar el motivo
    wa_bsas-bukrs_bsis = wa_bsis-bukrs."de emision cuando es multi sociedad
    wa_bsas-multi = 'X'.
    APPEND wa_bsas TO ti_bsas.
    CLEAR wa_bsas.
  ENDIF.

ENDFORM.                    " BUSCA_DOC_PAGO_MULTI
*&---------------------------------------------------------------------*
*&      Form  BUSCA_DOC_PAGO_MULTI_COM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM busca_doc_pago_multi_com .
  DATA: lv_bvorg LIKE bvor-bvorg.
  DATA: lv_gjahr2 LIKE zfitr020_t01-gjahr.
  DATA: lv_bukrs2 LIKE zfitr020_t01-bukrs.
  DATA: lv_belnr2 LIKE zfitr020_t01-belnr.

  SELECT SINGLE bvorg INTO lv_bvorg
    FROM bkpf
    WHERE bukrs = wa_bsis-bukrs
      AND belnr = wa_bsis-belnr
      AND gjahr = wa_bsis-gjahr.


  SELECT SINGLE bukrs gjahr belnr
     INTO (lv_bukrs2, lv_gjahr2, lv_belnr2)
   FROM bvor
   WHERE bvorg = lv_bvorg
     AND bukrs <> wa_bsis-bukrs
     .

  DATA: lv_gjahr_orig LIKE zfitr020_t01-gjahr.
  DATA: lv_bukrs_orig LIKE zfitr020_t01-bukrs.
  DATA: lv_belnr_orig LIKE zfitr020_t01-belnr.

  "con el documento obtenido buscamos el documento pagado
  SELECT SINGLE belnr bukrs gjahr
      INTO (lv_belnr_orig, lv_bukrs_orig, lv_gjahr_orig)
    FROM bse_clr
   WHERE belnr_clr = lv_belnr2
     AND bukrs_clr = lv_bukrs2
     AND gjahr_clr = lv_gjahr2.

  IF sy-subrc = 0.
    wa_bsas-belnr      = lv_belnr_orig.
    wa_bsas-gjahr      = lv_gjahr_orig.
    wa_bsas-bukrs      = lv_bukrs_orig.
    wa_bsas-augbl      = wa_bsis-belnr."se guardan estos datos para
    wa_bsas-gjahr_bsis = wa_bsis-gjahr."unir el alv y buscar el motivo
    wa_bsas-bukrs_bsis = wa_bsis-bukrs."de emision cuando es multi sociedad
    wa_bsas-multi = 'X'.
    APPEND wa_bsas TO ti_bsas.
    CLEAR wa_bsas.
  ENDIF.

ENDFORM.                    " BUSCA_DOC_PAGO_MULTI_COM
*&---------------------------------------------------------------------*
*&      Form  VALIDAR_EMISION
*&---------------------------------------------------------------------*
*       Objetivo verificar el campo emision para maternales
*----------------------------------------------------------------------*
FORM validar_emision .

  IF t_itab-zzmot_emis IS NOT INITIAL AND t_itab-multi IS INITIAL.
    SELECT SINGLE maternal cta_cade
      INTO (v_mater, v_hkont)
      FROM zmot_emis
     WHERE zzmot_emis  = t_itab-zzmot_emis
      AND  bukrs       = t_itab-bukrs.

    IF v_mater IS INITIAL.
      v_val = 'X'.

*--------------------------------------------------------------------*
*    Agregado 23.10.2014
*--------------------------------------------------------------------*
      DATA: fecha_in    TYPE budat,
            fecha_fin   TYPE budat,
            belnr       TYPE bsis-belnr,
            l_belnr_ini TYPE bsis-belnr,
            gjahr       TYPE bse_clr-gjahr_clr,
            l_gjahr_ini TYPE bse_clr-gjahr_clr,
            l_budat_ini TYPE budat,
            v_belnr     TYPE bsis-belnr,
            v_budat     TYPE budat,
            l_hkont     TYPE bsas-hkont,
            cont        TYPE i VALUE 0.



      CLEAR: v_belnr, v_budat, l_hkont, wa_bse_clr2.
      cont = 0.
      belnr = t_itab-belnr.
      gjahr = t_itab-gjahr.
      l_belnr_ini = t_itab-belnr.
      l_gjahr_ini = t_itab-gjahr.
      l_budat_ini = t_itab-budat.

      IF t_itab-hkont+9(1) EQ '9'.



        SELECT SINGLE cta_cheqs
        INTO l_hkont
        FROM zfitr020_t05
        WHERE bukrs = t_itab-bukrs
        AND   hbkid = t_itab-hbkid
        AND   hktid = t_itab-hktid.

        WHILE v_belnr IS INITIAL OR cont EQ 30.

          SELECT SINGLE *
          INTO CORRESPONDING FIELDS OF wa_bse_clr2
          FROM bse_clr
          WHERE bukrs_clr = t_itab-bukrs
          AND belnr_clr = belnr
          AND gjahr_clr = gjahr.

          CONCATENATE wa_bse_clr2-gjahr '01' '01' INTO fecha_in .
          CONCATENATE wa_bse_clr2-gjahr '12' '31' INTO fecha_fin .

          SELECT SINGLE belnr budat
          INTO (v_belnr, v_budat)
          FROM bsas
          WHERE bukrs = t_itab-bukrs
          AND hkont = l_hkont
          AND augdt BETWEEN fecha_in AND fecha_fin
          AND augbl = wa_bse_clr2-belnr
          AND belnr NE wa_bse_clr2-belnr.

          IF sy-subrc EQ 0.
            t_itab-belnr = v_belnr.
            t_itab-budat = v_budat.
            t_itab-gjahr = v_budat(4).
          ELSE.
            belnr = wa_bse_clr2-belnr.
            gjahr = wa_bse_clr2-gjahr.
          ENDIF.
          cont = cont + 1.
        ENDWHILE.
      ENDIF.

*--------------------------------------------------------------------*
*    Fin Agregado 23.10.2014
*--------------------------------------------------------------------*

      SELECT SINGLE *
        INTO CORRESPONDING FIELDS OF wa_bse_clr
        FROM bse_clr
       WHERE bukrs_clr = t_itab-bukrs
         AND belnr_clr = t_itab-belnr
         AND gjahr_clr = t_itab-gjahr.

      IF sy-subrc EQ 0.

*ResQ Comment:Correction not required as Select Single is used 24/12/2019 EY_DES02 ECDK917080 *
        SELECT SINGLE *
          INTO CORRESPONDING FIELDS OF wa_bseg2
          FROM bseg
         WHERE bukrs = t_itab-bukrs
           AND belnr = wa_bse_clr-belnr
           AND gjahr = wa_bse_clr-gjahr
           AND buzei = wa_bse_clr-buzei.
      ENDIF.
      t_itab-belnr = l_belnr_ini.
      t_itab-budat = l_budat_ini.
      t_itab-gjahr = l_gjahr_ini.

    ENDIF.
  ENDIF.

ENDFORM.                    " VALIDAR_EMISION
*&---------------------------------------------------------------------*
*&      Form  ANULA_CHEQUE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_ITAB_CHECT  text
*      -->P_T_ITAB_HBKID  text
*      -->P_T_ITAB_HKTID  text
*      -->P_T_ITAB_BUKRS  text
*----------------------------------------------------------------------*
FORM anula_cheque  USING    itab_chect LIKE payr-chect
                            itab_hbkid LIKE payr-hbkid
                            itab_hktid LIKE payr-hktid
                            itab_bukrs LIKE payr-zbukr.
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
        '' 'PAYR-ZBUKR' itab_bukrs,       "asigna el valor correspondiente
        '' 'BDC_CURSOR' 'PAYR-HBKID',     "se posiciona en el cambo banco propio
        '' 'PAYR-HBKID' itab_hbkid,       "asigna el valor correspondiente
        '' 'BDC_CURSOR' 'PAYR-HKTID',     "se posiciona en el campo cuentas
        '' 'PAYR-HKTID' itab_hktid,       "asigna el valor correspondiente
        '' 'BDC_CURSOR' 'PAYR-CHECT',     "se posiciona en el campo cheque
        '' 'PAYR-CHECT' itab_chect,       "asigna el valor correspondiente
        '' 'BDC_CURSOR' 'PAYR-VOIDR',     "se posiciona en el motivo de anulacion
        '' 'PAYR-VOIDR' '99',             "asigna el motivo constante
        '' 'BDC_OKCODE' '=EDEL'.          "
  CALL TRANSACTION 'FCH9' USING bdcdata MODE w_mode UPDATE 'S' MESSAGES INTO messtab.

ENDFORM.                    " ANULA_CHEQUE
*&---------------------------------------------------------------------*
*&      Form  BDC
*&---------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
FORM bdc   USING    a
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
*&      Form  JOB
*&---------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
FORM job .
  DATA: rs_selfield TYPE slis_selfield.

*  IF REF_GRID IS INITIAL.
*    CALL FUNCTION 'GET_GLOBALS_FROM_SLVC_FULLSCR'
*    IMPORTING
*      E_GRID = REF_GRID.
*  ENDIF.
*
*  IF NOT REF_GRID IS INITIAL.
*    CALL METHOD REF_GRID->CHECK_CHANGED_DATA.
*  ENDIF.

  IF sy-batch IS NOT INITIAL.
    LOOP AT itab.
      IF itab-zzmot_emis IS NOT INITIAL.
        itab-flag = 'X'.
        MODIFY itab INDEX sy-tabix.
      ENDIF.
    ENDLOOP.
    rs_selfield-refresh = 'X'.

    REFRESH ti_return.
    LOOP AT itab WHERE flag = 'X'.

      MOVE-CORRESPONDING itab TO t_itab.
      PERFORM carga_datos.
      PERFORM carga_tablas.
      PERFORM ejecuta_funcion.
    ENDLOOP.
    PERFORM display_messages .

  ENDIF.

ENDFORM.                    " JOB

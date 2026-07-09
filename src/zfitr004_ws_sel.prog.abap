*&---------------------------------------------------------------------*
*&  Include           ZFITR004_WS_SEL
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
* Parametros
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK marco1 WITH FRAME TITLE TEXT-001.
PARAMETERS : p_proc RADIOBUTTON GROUP cero DEFAULT 'X' USER-COMMAND wbs.
*
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 10(25) TEXT-m10    MODIF ID rep.
PARAMETERS : par_tes RADIOBUTTON GROUP test DEFAULT 'X' USER-COMMAND tst
                                            MODIF ID rep.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 10(25) TEXT-m11    MODIF ID rep.
PARAMETERS : par_di  RADIOBUTTON GROUP test MODIF ID rep. " Ejecución real
SELECTION-SCREEN END OF LINE.
* REPORTE
PARAMETERS : p_repo RADIOBUTTON GROUP cero.
SELECTION-SCREEN SKIP 1.
PARAMETERS : p_bukrs  LIKE bkpf-bukrs,
             v_hbkid  LIKE bseg-hbkid      MODIF ID rep,
             v_fechai LIKE bkpf-budat      MODIF ID rep,
             v_fechat LIKE bkpf-budat      MODIF ID rep,
             v_fecrem LIKE bkpf-budat      MODIF ID rep.
SELECT-OPTIONS : s_datum FOR wa_selec-datum MODIF ID wbs,
                 s_uname FOR wa_selec-uname MODIF ID wbs.
*
PARAMETERS : p_server      TYPE string MODIF ID ser NO-DISPLAY.
PARAMETERS : p_archiv      TYPE string MODIF ID ve1
                                            DEFAULT 'C:\TRANSFER\'.
SELECTION-SCREEN SKIP.
SELECTION-SCREEN BEGIN OF BLOCK marco2 WITH FRAME TITLE TEXT-002.
PARAMETERS : p_conven(10) AS LISTBOX VISIBLE LENGTH 20       MODIF ID web,
             p_tipopa(21) AS LISTBOX VISIBLE LENGTH 30       MODIF ID web.

SELECTION-SCREEN END OF BLOCK marco2 .
SELECTION-SCREEN END OF BLOCK marco1 .

INITIALIZATION.
  PERFORM carga_datos.

*&---------------------------------------------------------------------*
*&     Validación de parámetros ingresados
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN ON p_bukrs.
  CHECK sy-ucomm NE 'TST' AND sy-ucomm NE 'WBS'.
  CLEAR wa_sociedad.
  IF p_bukrs IS NOT INITIAL.
    AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
       ID 'BUKRS' FIELD p_bukrs
       ID 'ACTVT' FIELD '03'.
    IF sy-subrc <> 0.
      MESSAGE e526(icc_tr) WITH p_bukrs.
    ELSE.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE *
*            FROM t001 WHERE bukrs = p_bukrs.
*
* NEW CODE
      SELECT *
      UP TO 1 ROWS 
            FROM t001 WHERE bukrs = p_bukrs ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

      PERFORM validacion_accesos USING p_bukrs.
    ENDIF.
  ELSE.
    MESSAGE e666(fi).
  ENDIF.

AT SELECTION-SCREEN ON v_hbkid.
  CHECK sy-ucomm NE 'TST' AND sy-ucomm NE 'WBS' AND p_repo IS INITIAL.
  IF v_hbkid IS INITIAL.
    MESSAGE e899(fi) WITH 'Ingrese Banco Propio'.
  ELSE.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE bankl INTO  p_bankl
*         FROM  t012 WHERE  bukrs EQ p_bukrs
*                      AND  hbkid EQ v_hbkid.
*
* NEW CODE
    SELECT bankl
    UP TO 1 ROWS  INTO  p_bankl
         FROM  t012 WHERE  bukrs EQ p_bukrs
                      AND  hbkid EQ v_hbkid ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    IF p_bankl NE '016'.
      MESSAGE e899(fi) WITH 'Solo seleccionar banco propio del BCI'.
    ENDIF.
  ENDIF.

AT SELECTION-SCREEN ON v_fechai.
  CHECK sy-ucomm NE  'TST' AND sy-ucomm NE 'WBS' AND p_repo IS INITIAL.
  IF v_fechai IS INITIAL.
    MESSAGE e899(fi) WITH 'Ingrese Fecha Vencimiento Desde'.
  ENDIF.

AT SELECTION-SCREEN ON v_fechat.
  CHECK sy-ucomm NE  'TST' AND sy-ucomm NE 'WBS' AND p_repo IS INITIAL.
  IF v_fechat IS INITIAL.
    MESSAGE e899(fi) WITH 'Ingrese Fecha Vencimiento Hasta'.
  ENDIF.

AT SELECTION-SCREEN ON v_fecrem.
  CHECK sy-ucomm NE  'TST' AND sy-ucomm NE 'WBS' AND p_repo IS INITIAL.
  IF v_fecrem IS INITIAL.
    MESSAGE e899(fi) WITH 'Ingrese Fecha Remesa'.
  ENDIF.

AT SELECTION-SCREEN ON p_conven.
  CHECK sy-ucomm NE  'TST' AND sy-ucomm NE 'WBS' AND p_proc EQ gc_x AND par_di EQ gc_x.
  IF p_conven IS INITIAL.
    MESSAGE e899(fi) WITH 'Indique Convenio de la Sociedad'.
  ELSE.
    wa_selec-convenio = |{ p_conven ALPHA = IN }|.
    SELECT SINGLE convenio INTO @DATA(lv_convenio)
           FROM zfitr016 WHERE bukrs    EQ @p_bukrs
                           AND convenio EQ @wa_selec-convenio.
    IF sy-subrc NE 0.
      MESSAGE e899(fi) WITH 'Convenio ingresado no corresponde a la Sociedad'.
    ENDIF.
  ENDIF.

AT SELECTION-SCREEN ON p_tipopa.
  CHECK sy-ucomm NE  'TST' AND sy-ucomm NE 'WBS' AND p_proc EQ gc_x AND par_di EQ gc_x.
  IF p_tipopa IS INITIAL.
    MESSAGE e899(fi) WITH 'Indique Tipo de pago de la Sociedad'.
  ELSE.
    SPLIT p_tipopa AT '_' INTO wa_selec-convenio
                               wa_selec-tipo_pago.
    SELECT SINGLE tipo_pago INTO @DATA(lv_tipo_pago)
           FROM zfitr016 WHERE bukrs     EQ @p_bukrs
                           AND convenio  EQ @wa_selec-convenio
                           AND tipo_pago EQ @wa_selec-tipo_pago.
    IF sy-subrc NE 0.
      MESSAGE e899(fi) WITH 'Tipo Pago ingresado no corresponde'
                            'a la Sociedad y Convenio'.
    ENDIF.
  ENDIF.

AT SELECTION-SCREEN ON BLOCK marco1.
  CHECK sy-ucomm NE 'TST' AND sy-ucomm NE 'WBS' AND p_proc EQ gc_x.
  CLEAR wa_zfitr016.
  CHECK p_bukrs  IS NOT INITIAL AND p_conven IS NOT INITIAL AND
        p_tipopa IS NOT INITIAL.
  SPLIT p_tipopa AT '_' INTO wa_selec-convenio
                             wa_selec-tipo_pago.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE * INTO wa_zfitr016
*       FROM zfitr016 WHERE bukrs     EQ p_bukrs
*                       AND convenio  EQ p_conven
*                       AND tipo_pago EQ wa_selec-tipo_pago.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  INTO wa_zfitr016
       FROM zfitr016 WHERE bukrs     EQ p_bukrs
                       AND convenio  EQ p_conven
                       AND tipo_pago EQ wa_selec-tipo_pago ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
  IF sy-subrc NE 0.
    MESSAGE e899(fi) WITH 'No existe registro en tabla ZFITR016 de'
                          'Parámetros WS, para los datos ingresados'.
  ENDIF.

AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    CASE screen-group1.
      WHEN 'VE1'.
        CHECK par_di EQ gc_x OR p_repo EQ gc_x.
        screen-active = 0.
      WHEN 'REP'.
        CHECK p_repo EQ gc_x.
        screen-active = 0.
      WHEN 'WEB'.
        CHECK p_repo EQ gc_x OR par_tes EQ gc_x.
        screen-active = 0.
      WHEN 'SER'.
        screen-input  = 0.
        IF par_di EQ gc_x OR p_repo EQ gc_x.
          screen-active = 0.
        ENDIF.
      WHEN 'WBS'.
        CHECK p_proc EQ gc_x.
        screen-active = 0.
    ENDCASE.
    MODIFY SCREEN.
  ENDLOOP.

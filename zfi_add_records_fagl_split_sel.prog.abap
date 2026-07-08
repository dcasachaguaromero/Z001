*&---------------------------------------------------------------------*
*&  Include           ZFI_ADD_RECORDS_FAGL_SPLIT_SEL
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
* SELECTION-SCREEN
*----------------------------------------------------------------------*
SELECTION-SCREEN: BEGIN OF BLOCK b3 WITH FRAME TITLE TEXT-t03.
PARAMETERS: p_bukrs1 TYPE bukrs   OBLIGATORY,
            p_gjahr1 TYPE gjahr   OBLIGATORY,
            p_belnr1 TYPE bkpf-belnr   OBLIGATORY.
SELECTION-SCREEN: END OF BLOCK b3.

SELECTION-SCREEN: BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-t01.
PARAMETERS: p_bukrs TYPE bukrs   OBLIGATORY,
            p_gjahr TYPE gjahr   OBLIGATORY.
SELECT-OPTIONS: s_belnr FOR bkpf-belnr OBLIGATORY.
SELECTION-SCREEN: END OF BLOCK b1.
*
SELECTION-SCREEN: BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-t02.
PARAMETERS: p_ins RADIOBUTTON GROUP r1 DEFAULT 'X',
            p_del RADIOBUTTON GROUP r1.
SELECTION-SCREEN SKIP.
PARAMETERS: p_buzei TYPE buzei.
SELECTION-SCREEN: END OF BLOCK b2.

*--------------------------------------------------------------------*
* INITIALIZATION
*--------------------------------------------------------------------*
INITIALIZATION.

  AUTHORITY-CHECK OBJECT 'S_TCODE'
            ID 'TCD' FIELD gc_tcode.

  IF sy-subrc <> 0.
*   Falta autorización para transacción &
    MESSAGE e077(s#) WITH gc_tcode.
  ENDIF.

*----------------------------------------------------------------------
* AT SELECTION-SCREEN
*----------------------------------------------------------------------
AT SELECTION-SCREEN ON p_bukrs.

  SELECT SINGLE FROM t001 FIELDS @abap_true
    WHERE bukrs = @p_bukrs
    INTO @DATA(lv_result).

  IF sy-subrc <> 0.
*   La sociedad & no está prevista
    MESSAGE e165(f5) WITH p_bukrs.
  ENDIF.

  AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
           ID 'BUKRS' FIELD p_bukrs
           ID 'ACTVT' FIELD '02'.

  IF sy-subrc <> 0.
*   Ud. carece de autorización para la sociedad &.
    MESSAGE e460(f5) WITH p_bukrs.
  ENDIF.

*--------------------------------
AT SELECTION-SCREEN ON p_buzei.

  IF NOT p_del IS INITIAL AND p_buzei IS INITIAL.
*   Para borrar debe indicar la posición
    MESSAGE e032.
  ENDIF.

*-------------------
AT SELECTION-SCREEN.

  IF NOT p_del IS INITIAL.

    SELECT FROM fagl_splinfo
      FIELDS belnr, bukrs, gjahr, buzei
      WHERE bukrs  = @p_bukrs
        AND belnr IN @s_belnr
        AND gjahr  = @p_gjahr
      ORDER BY belnr
      INTO TABLE @DATA(gt_sel).

    IF sy-subrc <> 0.
*     No se encontró documento para borrar
      MESSAGE e033.
    ENDIF.

    CLEAR: gv_cuenta.

    LOOP AT gt_sel INTO DATA(ls_sel_x).
      AT NEW belnr.
        gv_cuenta = gv_cuenta + 1.
      ENDAT.
    ENDLOOP.

    IF gv_cuenta > 1.
*     Seleccione solo un documento a borrar
      MESSAGE e030.
    ENDIF.

    READ TABLE gt_sel INTO DATA(ls_sel) WITH KEY buzei = p_buzei.
    IF sy-subrc <> 0.
*     No se encontró la posición del documento a borrar
      MESSAGE e031.
    ELSE.
      gv_belnr_del = ls_sel-belnr.
    ENDIF.
  ENDIF.

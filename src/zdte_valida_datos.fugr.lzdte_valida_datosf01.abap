*----------------------------------------------------------------------*
***INCLUDE LZDTE_VALIDA_DATOSF01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  CONVERT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_LV_PARTY  text
*----------------------------------------------------------------------*
FORM convert  CHANGING p_campo.

  TRANSLATE p_campo TO UPPER CASE.
  REPLACE ALL OCCURRENCES OF '.' IN p_campo WITH '' .
  CONDENSE p_campo NO-GAPS.

ENDFORM.                    " CONVERT
*&---------------------------------------------------------------------*
*&      Form  VALIDA_OC1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_WA_DATA  text
*----------------------------------------------------------------------*
FORM valida_oc1   TABLES p_data LIKE   ti_ref[].

  CLEAR lv_null.

  LOOP AT p_data.
    IF p_data-tpodocref EQ '801' AND p_data-folioref IS INITIAL.
      lv_null = 'X'.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " VALIDA_OC1
*&---------------------------------------------------------------------*
*&      Form  VALIDA_OC2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_WA_DATA  text
*----------------------------------------------------------------------*
FORM valida_oc2  TABLES p_data LIKE   ti_ref[].

  CLEAR lv_tipo.

  DATA lv_mwskz TYPE ekpo-mwskz.

  READ TABLE p_data INDEX 1.

  IF p_data-tipodte EQ '33'. "factura afecta

    LOOP AT p_data.
      IF p_data-tpodocref  EQ '801'.
        CLEAR lv_mwskz.
        SELECT SINGLE mwskz INTO lv_mwskz
        FROM ekpo
        WHERE ebeln EQ p_data-folioref.

        IF lv_mwskz EQ 'C0'.
          lv_tipo = 'X'.
        ENDIF.
      ENDIF.
    ENDLOOP.

  ELSE.
    LOOP AT p_data.
      IF p_data-tpodocref  EQ '801'.
        CLEAR lv_mwskz.

        SELECT SINGLE mwskz INTO lv_mwskz
        FROM ekpo
        WHERE ebeln EQ p_data-folioref.

        IF lv_mwskz NE 'C0'.
          lv_tipo = 'X'.
        ENDIF.
      ENDIF.
    ENDLOOP.

  ENDIF.


ENDFORM.                    " VALIDA_OC2
*&---------------------------------------------------------------------*
*&      Form  VALIDA_OC3
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_WA_DATA  text
*----------------------------------------------------------------------*
FORM valida_oc3  TABLES p_data LIKE   ti_ref[].

  DATA lv_bukrs3 TYPE ekpo-bukrs.

  CLEAR lv_exist.

  LOOP AT p_data.
    IF p_data-tpodocref  EQ '801'.
      CLEAR lv_bukrs3.

      SELECT SINGLE bukrs INTO lv_bukrs3
      FROM ekko
      WHERE ebeln EQ p_data-folioref.
      IF sy-subrc EQ 0.
        IF lv_bukrs3 NE lv_bukrs.
          lv_exist = 'X'.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " VALIDA_OC3
*&---------------------------------------------------------------------*
*&      Form  VALIDA_OC4
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_WA_DATA  text
*----------------------------------------------------------------------*
FORM valida_oc4  TABLES p_data LIKE ti_ref[].

  CLEAR lv_corr.

  DATA: lv_lifnr  TYPE ekko-lifnr,
        lv_lifnr2 TYPE ekko-lifnr.

  READ TABLE p_data INDEX 1.

  SELECT SINGLE lifnr
    INTO lv_lifnr
    FROM lfa1
   WHERE stcd1 EQ p_data-rutemisor.

  LOOP AT p_data.
    IF p_data-tpodocref  EQ '801'.
      CLEAR lv_lifnr2.

      SELECT SINGLE lifnr INTO lv_lifnr2
      FROM ekko
      WHERE ebeln EQ p_data-folioref.

      IF lv_lifnr NE lv_lifnr2.
        lv_corr = 'X'.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " VALIDA_OC4
*&---------------------------------------------------------------------*
*&      Form  VALIDA_HES1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_WA_DATA  text
*----------------------------------------------------------------------*
FORM valida_hes1  TABLES p_data LIKE   ti_ref[].

  CLEAR lv_null2.

  LOOP AT p_data.
    IF p_data-tpodocref EQ '802' AND p_data-folioref IS INITIAL.
      lv_null2 = 'X'.
    ENDIF.
  ENDLOOP.


ENDFORM.                    " VALIDA_HES1
*&---------------------------------------------------------------------*
*&      Form  VALIDA_HES2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_WA_DATA  text
*----------------------------------------------------------------------*
FORM valida_hes2  TABLES p_data LIKE   ti_ref[].
  CLEAR lv_hes.

  TYPES: BEGIN OF ty_hes_oc,
           pos       TYPE i,
           tpo(3)    TYPE c,
           folio(10) TYPE c,
         END OF ty_hes_oc.

  DATA: ti_hes_oc  TYPE STANDARD TABLE OF ty_hes_oc,
        wa_hes_oc  TYPE ty_hes_oc,
        ti_hes_oc2 TYPE STANDARD TABLE OF ty_hes_oc,
        wa_hes_oc2 TYPE ty_hes_oc,
        wa_ekbe    TYPE ekbe,
        lv_rel     TYPE c,
        lv_pos     TYPE i.

  lv_pos = 0.

  LOOP AT p_data.
    IF p_data-tpodocref  IS NOT INITIAL.
      CLEAR wa_hes_oc.
      lv_pos =  lv_pos + 1.
      wa_hes_oc-pos   = lv_pos.
      wa_hes_oc-tpo   = p_data-tpodocref.
      wa_hes_oc-folio = p_data-folioref.
      APPEND wa_hes_oc TO ti_hes_oc.
    ENDIF.
  ENDLOOP.


  ti_hes_oc2[] = ti_hes_oc[].

  LOOP AT ti_hes_oc INTO wa_hes_oc WHERE tpo EQ '802'.

    CLEAR lv_rel.

    LOOP AT ti_hes_oc2 INTO wa_hes_oc2 WHERE tpo EQ '801'.

      SELECT SINGLE *
        INTO wa_ekbe
        FROM ekbe
       WHERE ebeln EQ wa_hes_oc2-folio
         AND vgabe EQ '9'
         AND belnr EQ wa_hes_oc-folio.

      IF sy-subrc EQ 0.
* marca que encontro relacion hes - oc
        lv_rel = 'X'.
      ENDIF.

    ENDLOOP.

* si no encontro relacion, marca error en lv_hes
    IF lv_rel IS INITIAL.
      lv_hes = 'X'.
    ENDIF.

  ENDLOOP.

ENDFORM.                    " VALIDA_HES2

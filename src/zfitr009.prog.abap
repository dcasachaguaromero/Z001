*&---------------------------------------------------------------------*
*& Report  ZFITR009
*&
*&---------------------------------------------------------------------*
*&
*& Reporte de Cheuqes Seguro
*& Carlos hidalgo - Quintec 31.05.2010
*&---------------------------------------------------------------------*

INCLUDE zfitr009_top.
INCLUDE zfitr009_f01.

*----------------------------------------------------------------------*
* AT SELECTION-SCREEN                                                  *
*----------------------------------------------------------------------*
AT SELECTION-SCREEN ON p_bukrs.

  AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
     ID 'BUKRS' FIELD p_bukrs.

  IF sy-subrc <> 0.
*--------'No authorization for company code &'------------------------
    MESSAGE e526(icc_tr) WITH p_bukrs.
  ENDIF.

  DATA: e_record   LIKE  t001,
        e_valid(1) TYPE c.

  IF p_bukrs NE space.
    CALL FUNCTION 'VALIDATE_COMPANY_CODE'
      EXPORTING
        i_company  = p_bukrs
      IMPORTING
        e_record   = e_record
        e_valid    = e_valid
      EXCEPTIONS
        incomplete = 1
        OTHERS     = 2.
    IF e_valid = 0.
* error sociedad no existe.
      MESSAGE e001(z001) WITH p_bukrs.
    ENDIF.
  ENDIF.

AT SELECTION-SCREEN ON p_hbkid.

  IF p_hbkid NE space AND p_bukrs NE space.
    SELECT * FROM t012k INTO TABLE gt_t012k
            WHERE bukrs = p_bukrs
            AND   hbkid = p_hbkid.
    IF sy-subrc NE 0.
      MESSAGE e002(z001) WITH p_hbkid p_bukrs.
* error HBKID no es valido para la Sociedad.
    ENDIF.
  ENDIF.

AT SELECTION-SCREEN ON p_hktid.
  IF p_hbkid NE space AND  p_hktid NE space AND p_bukrs NE space.
    SELECT * FROM t012k INTO TABLE gt_t012k
           WHERE bukrs = p_bukrs
           AND   hbkid = p_hbkid
           AND   hktid = p_hktid.
    IF sy-subrc NE 0.
      MESSAGE e003(z001) WITH p_bukrs p_hbkid p_hktid.
* error HKTID no es valido para la Sociedad.
    ENDIF.
  ENDIF.

  IF p_hbkid IS INITIAL AND p_hktid IS NOT INITIAL.
    MESSAGE e004(z001) WITH p_bukrs p_hbkid p_hktid.
  ENDIF.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_hktid.
  PERFORM module_match1.


*----------------------------------------------------------------------*
* START-OF-SELECTION                                                   *
*----------------------------------------------------------------------*
START-OF-SELECTION.

  gs_test-repid = sy-repid.

  PERFORM get_description_bukrs
              USING
                 p_bukrs
              CHANGING
                 g_butxt.

  PERFORM select_data.



*----------------------------------------------------------------------*
* END-OF-SELECTION                                                     *
*----------------------------------------------------------------------*
END-OF-SELECTION.

  PERFORM display_fullscreen.

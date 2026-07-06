*----------------------------------------------------------------------*
***INCLUDE LZV_T042I01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  CHECK_0020_1  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_0020_1 INPUT.

  IF t001-bukrs NE zv_t042-bukrs.
    SELECT SINGLE * FROM t001 WHERE bukrs =  zv_t042-bukrs.
  ENDIF.

* ------ Existiert absendender Buchungskreis ? -------------------------
  IF zv_t042-absbu NE space.
    PERFORM t001_lesen USING zv_t042-absbu.
    IF sy-subrc NE 0.
      MESSAGE e001(f3) WITH zv_t042-absbu.
    ELSE.
      absbu_t = *t001-butxt.
    ENDIF.
  ELSE.
    absbu_t = space.
  ENDIF.

* ------ Existiert zahlender Buchungskreis? ----------------------------
  PERFORM t001_lesen USING zv_t042-zbukr.
  IF sy-subrc NE 0.
    MESSAGE e001(f3) WITH zv_t042-zbukr.
  ENDIF.
  IF  zv_t042-xskr1 NE space  AND zv_t042-sktug GT 0.
    MESSAGE w056(f3).
  ENDIF.

* ------ Zahlender Buchungskreis mit Buchungskreis verträglich ? -------
  IF  zv_t042-zbukr NE space AND zv_t042-zbukr NE zv_t042-bukrs.
    IF t001-waers    NE *t001-waers OR t001-wt_newwt NE *t001-wt_newwt
    OR t001-land1    NE *t001-land1.
      MESSAGE e063(f3) WITH *t001-bukrs.
    ENDIF.
    CALL FUNCTION 'FI_CURRENCY_INFORMATION'
      EXPORTING
        i_bukrs = t001-bukrs
        i_land1 = t001-land1
        i_rcomp = t001-rcomp
      IMPORTING
        e_x001  = x001.
    CALL FUNCTION 'FI_CURRENCY_INFORMATION'
      EXPORTING
        i_bukrs = *t001-bukrs
        i_land1 = *t001-land1
        i_rcomp = *t001-rcomp
      IMPORTING
        e_x001  = *x001.
    *x001-bukrs = x001-bukrs.
    IF x001 NE *x001.
      MESSAGE e063(f3) WITH *t001-bukrs.
    ENDIF.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0020  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0020 INPUT.

  CASE ok_code.
    WHEN 'INFO'.
      CLEAR ok_code.

      CALL FUNCTION 'FI_DOCUMENTATION_SHOW'
        EXPORTING
          ic_fname = 'PAYING_CC_INFO'.

    WHEN 'ZBUK'.
      CLEAR ok_code.

      SUBMIT rf42bshw AND RETURN
                      WITH zbukr = zv_t042-zbukr.
    WHEN 'ZLOG'.

      PERFORM muestra_log USING zv_t042-bukrs
                                zv_t042-absbu.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  F4_ULSK1  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE f4_ulsk1 INPUT.
  PERFORM dynp_values_read IN PROGRAM saplfcdp USING 'ZV_T042-ULSK1'.
  IF view_action = 'S'.
    aktyp = 'A'.
  ELSEIF view_action = 'U'.
    aktyp = 'V'.
  ENDIF.
  CALL FUNCTION 'F_VALUES_T074U_LIST'
    EXPORTING
      i_aktyp       = aktyp
      i_koart       = 'K'
      i_umskz_liste = f4hlp-fieldvalue
    IMPORTING
      e_umskz_liste = f4-ulsxx.
  zv_t042-ulsk1 = f4-ulsxx.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  F4_ULSK2  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE f4_ulsk2 INPUT.
  PERFORM dynp_values_read IN PROGRAM saplfcdp USING 'ZV_T042-ULSK2'.
  IF view_action = 'S'.
    aktyp = 'A'.
  ELSEIF view_action = 'U'.
    aktyp = 'V'.
  ENDIF.
  CALL FUNCTION 'F_VALUES_T074U_LIST'
    EXPORTING
      i_aktyp       = aktyp
      i_koart       = 'K'
      i_umskz_liste = f4hlp-fieldvalue
    IMPORTING
      e_umskz_liste = f4-ulsxx.
  zv_t042-ulsk2 = f4-ulsxx.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  F4_ULSD1  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE f4_ulsd1 INPUT.
  PERFORM dynp_values_read IN PROGRAM saplfcdp USING 'ZV_T042-ULSD1'.
  IF view_action = 'S'.
    aktyp = 'A'.
  ELSEIF view_action = 'U'.
    aktyp = 'V'.
  ENDIF.
  CALL FUNCTION 'F_VALUES_T074U_LIST'
    EXPORTING
      i_aktyp       = aktyp
      i_koart       = 'D'
      i_umskz_liste = f4hlp-fieldvalue
    IMPORTING
      e_umskz_liste = f4-ulsxx.
  zv_t042-ulsd1 = f4-ulsxx.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  F4_ULSD2  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE f4_ulsd2 INPUT.
  PERFORM dynp_values_read IN PROGRAM saplfcdp USING 'ZV_T042-ULSD2'.
  IF view_action = 'S'.
    aktyp = 'A'.
  ELSEIF view_action = 'U'.
    aktyp = 'V'.
  ENDIF.
  CALL FUNCTION 'F_VALUES_T074U_LIST'
    EXPORTING
      i_aktyp       = aktyp
      i_koart       = 'D'
      i_umskz_liste = f4hlp-fieldvalue
    IMPORTING
      e_umskz_liste = f4-ulsxx.
  zv_t042-ulsd2 = f4-ulsxx.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  GRABA_DATOS  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE graba_datos INPUT.

  MOVE: sy-datum TO zt042_user-datum ,
        sy-uname TO zt042_user-uname ,
        sy-uzeit TO zt042_user-uzeit .
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  BNAME  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE bname INPUT.
  CHECK zt042_user-username IS INITIAL AND
        zt042_user-absbu  IS NOT INITIAL.
  MESSAGE e899(fi) WITH 'Ingrese Usuario'.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  ABSBU  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE absbu INPUT.
  CHECK zt042_user-username IS NOT INITIAL AND
        zt042_user-absbu    IS INITIAL.
  MESSAGE e899(fi) WITH 'Ingrese Sociedad Emisora'.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  F4_ZBUKR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE f4_zbukr INPUT.

  PERFORM help_zbukr CHANGING zv_t042-zbukr.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  VALIDA_ZBUKR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE valida_zbukr INPUT.

  PERFORM valida_zbukr USING zv_t042-zbukr.
ENDMODULE.

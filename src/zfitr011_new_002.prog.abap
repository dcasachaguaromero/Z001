*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES02 > *
*& Description: < ReSQ Correction > *
*& Date: <24-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  Include           ZFITR011_NEW_002
*&---------------------------------------------------------------------*

MODULE status_0200 OUTPUT.
  REFRESH tab.
  MOVE 'CONT' TO tab-fcode.
  APPEND tab.

  SET  PF-STATUS 'ZFITR011' EXCLUDING tab.
  SET  TITLEBAR 'T01'.
ENDMODULE.                             " STATUS_0100  OUTPUT

MODULE status_0250 OUTPUT.
  REFRESH tab.
  MOVE 'CONT' TO tab-fcode.
  APPEND tab.

  MOVE 'SELECT' TO tab-fcode.
  APPEND tab.
  MOVE 'DESELECT' TO tab-fcode.
  APPEND tab.

  SET  PF-STATUS 'ZFITR011' EXCLUDING tab.
  SET  TITLEBAR 'T01'.

ENDMODULE.                             " STATUS_0100  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
MODULE user_command_0200 INPUT.

  CASE sy-ucomm.
    WHEN 'CANCL'.
      LEAVE TO SCREEN 0.
    WHEN 'ACTUAL'.
      PERFORM actualiza.
  ENDCASE.

  CLEAR sy-ucomm.

ENDMODULE.                             " USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0250  INPUT
*&---------------------------------------------------------------------*
MODULE user_command_0250 INPUT.

  CASE sy-ucomm.
    WHEN 'CANCL'.
      LEAVE TO SCREEN 0.
    WHEN 'ACTUAL'.
      PERFORM actualiza_250.
  ENDCASE.

  CLEAR sy-ucomm.

ENDMODULE.                             " USER_COMMAND_0250  INPUT
*----------------------------------------------------------------------*
*  MODULE valida-grilla_0200 INPUT
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
MODULE valida-grilla_0200 INPUT.

*Begin of change: ReSQ Correction for MODIFY on an unsorted Internal Table 24/12/2019 EY_DES02 ECDK917080 *
  SORT int_tabla2 .
*End of change: ReSQ Correction for MODIFY on an unsorted Internal Table 24/12/2019 EY_DES02 ECDK917080 *
  MODIFY int_tabla2 FROM zfitr011_est_002  INDEX tabla2-current_line
     TRANSPORTING sel.

ENDMODULE.                    "valida-grilla_0200 INPUT
*----------------------------------------------------------------------*
*  MODULE valida-grilla_0250 INPUT
*----------------------------------------------------------------------*
MODULE valida-grilla_0250 INPUT.

*Begin of change: ReSQ Correction for MODIFY on an unsorted Internal Table 24/12/2019 EY_DES02 ECDK917080 *
  SORT int_tabla2 .
*End of change: ReSQ Correction for MODIFY on an unsorted Internal Table 24/12/2019 EY_DES02 ECDK917080 *
  MODIFY int_tabla2 FROM zfitr011_est_002  INDEX tabla3-current_line
     TRANSPORTING sel.

ENDMODULE.                    "valida-grilla_0200 INPUT
*----------------------------------------------------------------------*
*  MODULE fill_table_control_0200 OUTPUT
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
MODULE fill_table_control_0200 OUTPUT.

*ReSQ: No Need Of Change Internal Table INT_TABLA2 Already Sorted
  READ TABLE int_tabla2 INTO zfitr011_est_002 INDEX tabla2-current_line.

ENDMODULE.                 " FILL_TABLE_CONTROL_0100  OUTPUT
*----------------------------------------------------------------------*
*  MODULE fill_table_control_0250 OUTPUT
*----------------------------------------------------------------------*
MODULE fill_table_control_0250 OUTPUT.

*ReSQ: No Need Of Change Internal Table INT_TABLA2 Already Sorted
  READ TABLE int_tabla2 INTO zfitr011_est_002 INDEX tabla3-current_line.

ENDMODULE.                 " FILL_TABLE_CONTROL_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Form  actualiza
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM actualiza.
  totalsel  = 0.
  LOOP AT int_tabla2.
    IF int_tabla2-sel = 'X'.
      totalsel  = totalsel  + int_tabla2-monto.
    ENDIF.
    IF sw_dato = '1'.
      READ TABLE tdev  WITH KEY codigo_identificacion = int_tabla2-identif_pago.

      IF sy-subrc = 0.
        tdev-estado = int_tabla2-sel.
        MODIFY tdev INDEX sy-tabix.
      ENDIF.
    ELSE.
*Begin of change: ReSQ Correction for READ STATEMENT WITH BINARY AND WITHOUT SORTING 24/12/2019 EY_DES02 ECDK917080 *
      SORT tdep BY estado_pago cuenta_cargo correl numero_lote secuencia fecha_recepcion .
*End of change: ReSQ Correction for READ STATEMENT WITH BINARY AND WITHOUT SORTING 24/12/2019 EY_DES02 ECDK917080 *
      READ TABLE tdep   WITH KEY    estado_pago  = int_tabla-estado_pago
                                    cuenta_cargo = int_tabla-ctactedev
                                    correl      = int_tabla-correl
                                    numero_lote = int_tabla-lotedev
                                    secuencia = int_tabla2-sec
                                    fecha_recepcion = int_tabla-fechadev
                                    BINARY SEARCH.
      IF sy-subrc = 0.
        tdep-estado = int_tabla2-sel.
        MODIFY tdep INDEX sy-tabix.
      ENDIF.
    ENDIF.

  ENDLOOP.

ENDFORM.                    "actualiza
*&---------------------------------------------------------------------*
*&      Form  actualiza_250
*&---------------------------------------------------------------------*
FORM actualiza_250.
  totalsel  = 0.
  LOOP AT int_tabla2.
    IF int_tabla2-sel = 'X'.
      totalsel  = totalsel  + int_tabla2-monto.
    ENDIF.
    IF sw_dato = '1'.
      READ TABLE tdev  WITH KEY codigo_identificacion = int_tabla2-identif_pago.
      IF sy-subrc = 0.
        tdev-estado = int_tabla2-sel.
        MODIFY tdev INDEX sy-tabix.
      ENDIF.
    ELSE.
*Begin of change: ReSQ Correction for READ STATEMENT WITH BINARY AND WITHOUT SORTING 24/12/2019 EY_DES02 ECDK917080 *
      SORT tdep BY estado_pago cuenta_cargo numero_lote correl secuencia fecha_recepcion .
*End of change: ReSQ Correction for READ STATEMENT WITH BINARY AND WITHOUT SORTING 24/12/2019 EY_DES02 ECDK917080 *
      READ TABLE tdep   WITH KEY   estado_pago     = gs_outtab-estado_pago
                                   cuenta_cargo    = gs_outtab-ctactedev
                                   numero_lote     = gs_outtab-lotedev
                                   correl          = gs_outtab-correl
                                   secuencia       = int_tabla2-sec
                                   fecha_recepcion = gs_outtab-fechadev
                                    BINARY SEARCH.
      IF sy-subrc = 0.
        tdep-estado = int_tabla2-sel.
        MODIFY tdep INDEX sy-tabix.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDFORM.                    "actualiza

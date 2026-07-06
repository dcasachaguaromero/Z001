*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES02 > *
*& Description: < ReSQ Correction > *
*& Date: <20-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  Include           ZFIPG002_300
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&  Include           ZFIPG002_200
*&---------------------------------------------------------------------*
MODULE status_0300 OUTPUT.
  REFRESH tab.
  REFRESH tab.
  MOVE 'PROP' TO tab-fcode.
  APPEND tab.
  MOVE 'REFR' TO tab-fcode.
  APPEND tab.
  MOVE 'PAGO' TO tab-fcode.
  APPEND tab.
  MOVE 'MOD' TO tab-fcode.
  APPEND tab.

  DATA: BEGIN OF lt_acc OCCURS 0.
          INCLUDE STRUCTURE zfitr009.
  DATA: END OF lt_acc.

  DATA: s_fecha    TYPE RANGE OF budat,
        g_fecha    LIKE LINE OF s_fecha.

  CLEAR lt_acc. REFRESH lt_acc.
  SELECT * INTO TABLE lt_acc
     FROM zfitr009
      WHERE usnam = sy-uname.

  IF sy-subrc = 0.
    SORT lt_acc DESCENDING BY datum uzeit.
    READ TABLE lt_acc INDEX 1.
    REFRESH s_fecha. CLEAR s_fecha.
    g_fecha-sign   = 'I'.
    g_fecha-option = 'BT'.
    g_fecha-low    = lt_acc-datab.
    g_fecha-high   = lt_acc-datbi.
    APPEND g_fecha TO s_fecha.

    IF not sy-datum IN s_fecha.
      MOVE 'MODREF' TO tab-fcode.
      APPEND tab.
    ENDIF.
  else.
      MOVE 'MODREF' TO tab-fcode.
      APPEND tab.
  ENDIF.

  SET  PF-STATUS 'ZFIPG003' EXCLUDING tab.
  SET  TITLEBAR 'T01'.


ENDMODULE.                             " STATUS_0100  OUTPUT


*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
MODULE user_command_0300 INPUT.
  DATA linmod(5) TYPE n.

  CASE sy-ucomm.

    WHEN 'SELALL'.
      CLEAR sy-ucomm.
      PERFORM marco_todo_300.
    WHEN 'DESALL'.
      CLEAR sy-ucomm.
      PERFORM desmarco_todo_300.
    WHEN 'CANC'.
      LEAVE TO SCREEN 0.
    WHEN 'RW'.
      LEAVE TO SCREEN 0.
    WHEN 'SEL'.
      GET CURSOR FIELD cursorfield.
      GET CURSOR LINE xlinea.
      IF xlinea > 0 AND xlinea <= tabla3-lines.
        xlinea = xlinea + tabla3-top_line - 1.
*Begin of change: ReSQ Correction INDEX READ on an unsorted Internal TABLE 20/12/2019 EY_DES02 ECDK917080 *
*SORT INT_TABLA3 . "JOROZCO 24.01.2020
*End of change: ReSQ Correction for INDEX READ on an unsorted Internal TABLE 20/12/2019 EY_DES02 ECDK917080 *
        READ TABLE int_tabla3 INDEX xlinea.
        PERFORM detalle_doc.
      ENDIF.

    WHEN 'MODMASS'.
      linmod = 0.
      LOOP AT int_tabla3 WHERE sel = 'X'.
        linmod = linmod + 1.

      ENDLOOP .
      IF linmod > 0.
        CLEAR *bseg.
        CALL SCREEN 800 STARTING AT 10 05 ENDING AT 80 20.
      ELSE .
        MESSAGE e004(zfi) WITH 'Debe seleccionar a lo menos una linea.'.
      ENDIF.

    WHEN 'MODREF'.
      linmod = 0.
      LOOP AT int_tabla3 WHERE sel = 'X'.
        linmod = linmod + 1.

      ENDLOOP .
      IF linmod > 0.
        CLEAR *bseg.
        CALL SCREEN 900 STARTING AT 10 05 ENDING AT 80 20.
      ELSE .
        MESSAGE e004(zfi) WITH 'Debe seleccionar a lo menos una linea.'.
      ENDIF.



    WHEN 'EXCEL'.
      REFRESH texcel.
      LOOP AT int_tabla3.

        IF sy-tabix = 1.

          texcel-zzmot_emis = 'Mot. Emisión'.
          texcel-blart = 'C.Docto.'.
          texcel-gjahr = 'Año'.
          texcel-belnr = 'Documento FI'.
          texcel-buzei = 'Lin.'.
          texcel-zfbdt = 'Fecha base'.
          texcel-hbkid = 'Banco propio'.
          texcel-zlsch = 'Vía Pago'.
          texcel-wrbtr = 'Monto'.
          texcel-shkzg = 'D/H'.
          texcel-lifnr = 'Acreedor'.
          texcel-zuonr = 'Docto.Pago'.
          texcel-zz_agencia = 'Agencia'.
          texcel-msg = 'Mensaje'.

          APPEND texcel.

        ENDIF.
        MOVE-CORRESPONDING int_tabla3 TO texcel.
        WRITE int_tabla3-wrbtr   TO texcel-wrbtr CURRENCY t001-waers.
        WRITE int_tabla3-zfbdt   TO texcel-zfbdt DD/MM/YYYY .

        APPEND texcel.

      ENDLOOP.

      CALL FUNCTION 'WS_EXCEL'
        TABLES
          data          = texcel
        EXCEPTIONS
          unknown_error = 1
          OTHERS        = 2.


  ENDCASE.

  CLEAR sy-ucomm.

ENDMODULE.                             " USER_COMMAND_0100  INPUT

**&---------------------------------------------------------------------
**&      Module  FILL_TABLE_CONTROL  OUTPUT
**&---------------------------------------------------------------------
**   Lleno grilla con valores desde tabla
**----------------------------------------------------------------------
*&      Module  FILL_TABLE_CONTROL_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE fill_table_control_0300 OUTPUT.

*ReSQ: No Need Of Change Internal Table INT_TABLA3 Already Sorted
  READ TABLE int_tabla3 INTO zfipg200_b_est INDEX tabla3-current_line.

ENDMODULE.                 " FILL_TABLE_CONTROL_0100  OUTPUT


*----------------------------------------------------------------------*
*  MODULE valida-grilla_0300 INPUT
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
MODULE valida-grilla_0300 INPUT.

*ReSQ: No Need Of Change Internal Table INT_TABLA3 Already Sorted
  MODIFY int_tabla3 FROM zfipg200_b_est INDEX tabla3-current_line
     TRANSPORTING sel.

ENDMODULE.                 " VALIDA-GRILLA_0100  INPUT
*&---------------------------------------------------------------------*
*&      Form  DETALLE_DOC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM detalle_doc .
  SET PARAMETER ID 'BLN' FIELD int_tabla3-belnr.
  SET PARAMETER ID 'BUK' FIELD bukrs.
  SET PARAMETER ID 'GJR' FIELD int_tabla3-gjahr.
  CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.


ENDFORM.                    " DETALLE_DOC

*&---------------------------------------------------------------------*
*&      Form  marco_todo_800
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM marco_todo_300.

  LOOP AT int_tabla3.
    int_tabla3-sel = 'X'.
    MODIFY int_tabla3.
  ENDLOOP.

ENDFORM.                    " MARCO_TODO

*&---------------------------------------------------------------------*
*&      Form  DESMARCO_TODO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM desmarco_todo_300.

  LOOP AT int_tabla3.
    int_tabla3-sel = ''.
    MODIFY int_tabla3.
  ENDLOOP.

ENDFORM.                    " DESMARCO_TODO

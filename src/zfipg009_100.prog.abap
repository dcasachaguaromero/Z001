*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES02 > *
*& Description: < ReSQ Correction > *
*& Date: <20-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  Include           ZFIPG008_100
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
*   INCLUDE ZCLPRFI_SIMFIN12_100_I                                      *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.

  REFRESH tab.
  MOVE 'IMPR' TO tab-fcode.
  APPEND tab.
  MOVE 'CANCL' TO tab-fcode.
  APPEND tab.



  SET  PF-STATUS 'ZFIPG009' EXCLUDING tab.
  SET  TITLEBAR 'T01'.


ENDMODULE.                             " STATUS_0100  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100_EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100_exit INPUT.
  CASE sy-ucomm.
    WHEN 'BACK' OR '%EX' OR 'RW'.
      LEAVE TO SCREEN 0.
    WHEN '%EX' OR 'RW'.
      LEAVE PROGRAM.
  ENDCASE.

  CLEAR sy-ucomm.

ENDMODULE.                 " USER_COMMAND_0100_EXIT  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  CASE sy-ucomm.
    WHEN 'REFR'.
      PERFORM proceso.
    WHEN 'ORD1'. " ordenamiento de grilla ascendente
      READ TABLE tabla-cols INTO cols WITH KEY selected = 'X'.
      IF sy-subrc = 0.
        SORT int_tabla STABLE BY (cols-screen-name+13) ASCENDING.
        cols-selected = ' '.
*Begin of change: ReSQ Correction for MODIFY on an unsorted Internal Table 20/12/2019 EY_DES02 ECDK917080 *
SORT TABLA-COLS .
*End of change: ReSQ Correction for MODIFY on an unsorted Internal Table 20/12/2019 EY_DES02 ECDK917080 *
        MODIFY tabla-cols FROM cols INDEX sy-tabix.
      ENDIF.
    WHEN 'ORD2'. " ordenamiento de grilla descendente
      READ TABLE tabla-cols INTO cols WITH KEY selected = 'X'.
      IF sy-subrc = 0.
        SORT int_tabla STABLE BY (cols-screen-name+13) DESCENDING.
        cols-selected = ' '.
*ReSQ: No Need Of Change Internal Table TABLA-COLS Already Sorted
        MODIFY tabla-cols FROM cols INDEX sy-tabix.
      ENDIF.
    WHEN 'MARCA'.
      CLEAR sy-ucomm.
      PERFORM marco_todo.

    WHEN 'DESMAR'.
      CLEAR sy-ucomm.
      PERFORM desmarco_todo.

    WHEN 'ELIM'.
      CLEAR sy-ucomm.

      CALL FUNCTION 'POPUP_TO_CONFIRM'
        EXPORTING
          titlebar              = 'Confirmación '
          text_question         = 'Esta Seguro de Borrar Informacion?'
          default_button        = '2'
          display_cancel_button = 'X'
        IMPORTING
          answer                = resp.

      IF sy-subrc = 0 AND resp = '1'.
        PERFORM eliminar.
        PERFORM proceso.
      ENDIF.
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
MODULE fill_table_control_0100 OUTPUT.
  READ TABLE int_tabla INTO zfipg003_est INDEX tabla-current_line.

ENDMODULE.                 " FILL_TABLE_CONTROL_0100  OUTPUT

*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  VALIDA-GRILLA_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE valida-grilla_0100 INPUT.

  MODIFY int_tabla FROM zfipg003_est INDEX tabla-current_line
    TRANSPORTING sel.

ENDMODULE.                 " VALIDA-GRILLA_0100  INPUT

*&---------------------------------------------------------------------*
*&      Form  marco_todo
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM marco_todo .
  LOOP AT int_tabla.
    int_tabla-sel = 'X'.
    MODIFY int_tabla.
  ENDLOOP.

ENDFORM.                    " MARCO_TODO
*&---------------------------------------------------------------------*
*&      Form  DESMARCO_TODO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM desmarco_todo .
  LOOP AT int_tabla.
    int_tabla-sel = ''.
    MODIFY int_tabla.
  ENDLOOP.

ENDFORM.                    "desmarco_todo
*&---------------------------------------------------------------------*
*&      Form  eliminar
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM eliminar .
  LOOP AT int_tabla.
    IF int_tabla-sel = 'X'.

      UPDATE zfipg002_det
                 SET    estado = 'P'
                 WHERE  bukrs = bukrs
                 AND    nproceso = int_tabla-nproceso
                 AND    laufi    = int_tabla-laufi
                 AND    laufd    = int_tabla-laufd
                 AND    hbkid    = int_tabla-hbkid
                 and    XZZMOT_EMIS = 'TFONDOS'.

    ENDIF.

  ENDLOOP.

ENDFORM.                  " DESMARCO_TODO

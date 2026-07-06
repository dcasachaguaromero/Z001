*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES02 > *
*& Description: < ReSQ Correction > *
*& Date: <24-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  Include           ZFIPG006_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  VALUE_ORG1  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE value_org1 INPUT.
*    call function 'GUI_CREATE_DIRECTORY'
*           exporting
*             dirname = ZFIPG003-dir_org1
*           exceptions
*             failed  = 1
*             others  = 2.
  CONCATENATE '/IMGFIRM/' zfipg003-bukrs '/' INTO valor.

  SELECT ruta_sap   FROM zfirma_digital
    INTO TABLE ti_tabla
    WHERE ruta_sap_corta  = valor.
  IF sy-subrc = 0.
    REFRESH it_match.
    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
        EXPORTING
          retfield        = 'RUTA_SAP'
          window_title    = 'Directorio Sap'
          value_org       = 'S'
*      multiple_choice = 'X'
        TABLES
          value_tab       = ti_tabla
          return_tab      = it_match
        EXCEPTIONS
          parameter_error = 1
          no_values_found = 2
          OTHERS          = 3.
*Si todo es correcto
    IF sy-subrc EQ 0.
*Begin of change: ReSQ Correction INDEX READ on an unsorted Internal TABLE 24/12/2019 EY_DES02 ECDK917080 *
SORT IT_MATCH .
*End of change: ReSQ Correction for INDEX READ on an unsorted Internal TABLE 24/12/2019 EY_DES02 ECDK917080 *
      READ TABLE it_match INDEX 1.
      MOVE it_match-fieldval TO zfipg003-dir_org1.
    ENDIF.
  ENDIF.
*  CALL FUNCTION '/SAPDMC/LSM_F4_SERVER_FILE'
*   EXPORTING
*     directory              = direc
**   FILEMASK               = ' '
*   IMPORTING
*     serverfile             = zfipg003-dir_org1
*   EXCEPTIONS
*     canceled_by_user       = 1
*     OTHERS                 = 2.
*  IF sy-subrc <> 0.
** MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
**         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*  ENDIF.
*clear direc.
*  CALL FUNCTION 'WS_FILENAME_GET'
*    EXPORTING
*      def_filename     = ZFIPG003-dir_org1
*      mask             = ',*.bmp.'
*      mode             = 'O'
*      title            = 'Upload File'(078)
*    IMPORTING
*      filename         = ZFIPG003-dir_org1
*    EXCEPTIONS
*      inv_winsys       = 1
*      no_batch         = 2
*      selection_cancel = 3
*      selection_error  = 4
*      OTHERS           = 5.

ENDMODULE.                 " VALUE_ORG1  INPUT
*&---------------------------------------------------------------------*
*&      Module  VALUE_ORG2  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE value_org2 INPUT.
  CONCATENATE '/IMGFIRM/' zfipg003-bukrs '/' INTO valor.

  SELECT ruta_sap   FROM zfirma_digital
    INTO TABLE ti_tabla
    WHERE ruta_sap_corta  = valor.
  IF sy-subrc = 0.

    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
        EXPORTING
          retfield        = 'RUTA_SAP'
         window_title     = 'Directorio Sap'
          value_org       = 'S'
*      multiple_choice = 'X'
        TABLES
          value_tab       = ti_tabla
          return_tab      = it_match
        EXCEPTIONS
          parameter_error = 1
          no_values_found = 2
          OTHERS          = 3.
*Si todo es correcto
    IF sy-subrc EQ 0.
*ReSQ: No Need Of Change Internal Table IT_MATCH Already Sorted
      READ TABLE it_match INDEX 1.
      MOVE it_match-fieldval TO zfipg003-dir_org2.
    ENDIF.
  ENDIF.
*  CALL FUNCTION 'WS_FILENAME_GET'
*    EXPORTING
*      def_filename     = ZFIPG003-dir_org2
*      mask             = ',*.bmp.'
*      mode             = 'O'
*      title            = 'Upload File'(078)
*    IMPORTING
*      filename         = ZFIPG003-dir_org2
*    EXCEPTIONS
*      inv_winsys       = 1
*      no_batch         = 2
*      selection_cancel = 3
*      selection_error  = 4
*      OTHERS           = 5.



ENDMODULE.                 " VALUE_ORG2  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
  CASE sy-ucomm.
    WHEN 'EXECUTE'.
      p_bukrs = zfipg003-bukrs.
      CALL SCREEN 200.
    WHEN 'ELIMINAR'.
      DELETE zfipg003 FROM zfipg003.
      IF sy-subrc EQ 0.
        MESSAGE 'Sociedad eliminada de la tabla ZFIPG003' TYPE 'I'.
        CALL SCREEN 100.
      ELSE.
        MESSAGE 'No existe la sociedad indicada' TYPE 'W'.
      ENDIF.

  ENDCASE.

  CLEAR sy-ucomm.
ENDMODULE.                 " USER_COMMAND_0100  INPUT

**&---------------------------------------------------------------------*
**&      Module  VALUE_DES3  INPUT
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
*MODULE value_des3 INPUT.
*  CALL FUNCTION 'WS_FILENAME_GET'
*    EXPORTING
*      def_filename     = ZFIPG003-dir_des3
*      mask             = ',*.bmp.'
*      mode             = 'O'
*      title            = 'Upload File'(078)
*    IMPORTING
*      filename         = ZFIPG003-dir_des3
*    EXCEPTIONS
*      inv_winsys       = 1
*      no_batch         = 2
*      selection_cancel = 3
*      selection_error  = 4
*      OTHERS           = 5.
*
*ENDMODULE.                 " VALUE_DES3  INPUT
*&---------------------------------------------------------------------*
*&      Module  VALUE_ORG2  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE value_org3 INPUT.

  CONCATENATE '/IMGFIRM/' zfipg003-bukrs '/' INTO valor.

  SELECT ruta_sap   FROM zfirma_digital
    INTO TABLE ti_tabla
    WHERE ruta_sap_corta  = valor.
  IF sy-subrc = 0.

    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
        EXPORTING
          retfield        = 'RUTA_SAP'
         window_title     = 'Directorio Sap'
          value_org       = 'S'
*      multiple_choice = 'X'
        TABLES
          value_tab       = ti_tabla
          return_tab      = it_match
        EXCEPTIONS
          parameter_error = 1
          no_values_found = 2
          OTHERS          = 3.
*Si todo es correcto
    IF sy-subrc EQ 0.
*ReSQ: No Need Of Change Internal Table IT_MATCH Already Sorted
      READ TABLE it_match INDEX 1.
      MOVE it_match-fieldval TO zfipg003-dir_org3.
    ENDIF.
  ENDIF.
ENDMODULE.                 " VALUE_ORG2  INPUT

*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.

  SET PF-STATUS 'STATUS100'.
  SET TITLEBAR 'ACT. TABLA'.

ENDMODULE.                 " STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0200 INPUT.
  CASE sy-ucomm.
    WHEN 'SAVE' OR 'EXECUTE' OR 'EJECUTAR'.
      MODIFY zfipg003.
      IF sy-subrc EQ 0.
        MESSAGE 'Tabla de Firmas: ZFIPG003 Actualizada exitosamente' TYPE 'I'.
        CALL SCREEN 100.
      ELSE.
        MESSAGE 'Error actualizando la tabla ZFIPG003' TYPE 'E'.
      ENDIF.

  ENDCASE.

  CLEAR sy-ucomm.
ENDMODULE.                 " USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0200  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0200 OUTPUT.
  SET PF-STATUS 'STATUS200'.
  SET TITLEBAR 'ACT. TABLA'.

  SELECT SINGLE * FROM zfipg003 WHERE bukrs = p_bukrs.
  IF sy-subrc <> 0.
    CLEAR zfipg003.
    zfipg003-bukrs = p_bukrs.
  ENDIF.


ENDMODULE.                 " STATUS_0200  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100_EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100_exit INPUT.

  CASE sy-ucomm.
    WHEN 'BACK' OR '%EX' OR 'RW'.
      LEAVE TO SCREEN 100.
    WHEN '%EX' OR 'EXIT'.
      LEAVE PROGRAM.
  ENDCASE.
  CLEAR sy-ucomm.
ENDMODULE.                 " USER_COMMAND_0100_EXIT  INPUT

*&---------------------------------------------------------------------*
*& Report  ZIMP_CHEQUE_REVALIDA
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  zimp_cheque_revalida.
TABLES : zfirmadigital.
DATA: ti_firma TYPE STANDARD TABLE OF zfirmadigital WITH HEADER LINE,
      firma1 TYPE zfirmadigital,
      firma2 TYPE zfirmadigital,
      okcode TYPE sy-ucomm,
      pasword1 TYPE char50,
      pasword2 TYPE char50,
      estado1(10) TYPE c,
      estado2(10) TYPE c,
      source TYPE char50,
      destination TYPE char50,
      pwd TYPE char50,
      tdname_001 TYPE bdcdata-fval,
      treval TYPE bdcdata-fval,
      filename_004 TYPE bdcdata-fval,
      tdname_005 TYPE bdcdata-fval,
      tdname_008 TYPE bdcdata-fval,
      messtab TYPE STANDARD TABLE OF bdcmsgcoll WITH HEADER LINE,
      rfcdest TYPE rfcdes-rfcdest,
      error(1),
      ejecuta(1),
      noexito(1).

DATA: exctab(10) OCCURS 0 WITH HEADER LINE.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.
PARAMETERS: bukrs TYPE zfirmadigital-bukrs.
SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE text-002.
PARAMETERS: nfirma1 TYPE zfirmadigital-tdname,
            dir_org1 TYPE rlgrap-filename,
            dir_des1 TYPE rlgrap-filename,
            pass1(25)  TYPE c OBLIGATORY.
SELECTION-SCREEN END OF BLOCK b2.
SELECTION-SCREEN END OF BLOCK b1.

INITIALIZATION.
  GET PARAMETER ID 'BUK' FIELD bukrs.
  CLEAR: noexito, ejecuta, nfirma1, dir_des1, error.

*AT SELECTION-SCREEN ON VALUE-REQUEST FOR dir_org1.
*  CALL FUNCTION 'WS_FILENAME_GET'
*    EXPORTING
*      def_filename     = dir_org1
*      mask             = ',*.bmp.'
*      mode             = 'O'
*      title            = 'Upload File'(078)
*    IMPORTING
*      filename         = dir_org1
*    EXCEPTIONS
*      inv_winsys       = 1
*      no_batch         = 2
*      selection_cancel = 3
*      selection_error  = 4
*      OTHERS           = 5.

*AT SELECTION-SCREEN ON VALUE-REQUEST FOR dir_des1.
*  CALL FUNCTION 'WS_FILENAME_GET'
*    EXPORTING
*      def_filename     = dir_des1
*      mask             = ',*.bmp.'
*      mode             = 'O'
*      title            = 'Upload File'(078)
*    IMPORTING
*      filename         = dir_des1
*    EXCEPTIONS
*      inv_winsys       = 1
*      no_batch         = 2
*      selection_cancel = 3
*      selection_error  = 4
*      OTHERS           = 5.

AT SELECTION-SCREEN OUTPUT.

  SELECT SINGLE nfirma3 dir_des3 dir_org3 FROM zfipg003
  INTO (nfirma1, dir_des1, dir_org1)
  WHERE bukrs = bukrs.

  LOOP AT SCREEN.
    IF screen-name  = 'BUKRS'    OR
      screen-name   = 'NFIRMA1'  OR
      screen-name   = 'DIR_ORG1' OR
      screen-name   = 'DIR_DES1'.
      screen-input  = '0'.
      screen-output = '1'.
      MODIFY SCREEN.
    ENDIF.
    IF screen-name EQ 'PASS1'.
      screen-invisible = '1'.
      MODIFY SCREEN.
    ENDIF.
    IF screen-name EQ 'PASS2'.
      screen-invisible = '1'.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

START-OF-SELECTION.
  PERFORM procesa.
  IF noexito IS INITIAL.
    LEAVE TO SCREEN 0.
  ELSE.
    PERFORM mensaje USING noexito.
    IF noexito IS INITIAL.
      LEAVE TO SCREEN 0.
    ENDIF.
  ENDIF.

*&---------------------------------------------------------------------*
*&      Form  procesa
*&---------------------------------------------------------------------*
FORM procesa.
* Siempre se borra la firma como medida de precaución al iniciar el proceso
  CLEAR destination.
  destination = dir_des1.
  CALL FUNCTION 'Z_DEL_FIRMA'
    EXPORTING
      destination = destination.

  CLEAR ejecuta.
  ejecuta = 'X'.
  EXPORT ejecuta TO MEMORY ID 'EJE'.
  PERFORM sube_firmas.
  EXPORT nfirma1 TO MEMORY ID 'FIR'.
  EXPORT dir_des1 TO MEMORY ID 'DES'.
ENDFORM.                    "procesa

*&---------------------------------------------------------------------*
*&      Form  sube_firmas
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM sube_firmas.
  SELECT SINGLE * FROM zfirmadigital WHERE bukrs EQ bukrs AND orden EQ 3.
  IF sy-subrc EQ 0.
    rfcdest = zfirmadigital-rfcdest.
****Firma1***************
    source = dir_org1.
    destination = dir_des1.
    pwd = pass1.
    CALL FUNCTION 'S_DES_FIRMA'
      EXPORTING
        SOURCE      = SOURCE
        destination = destination
        pwd         = pwd
        rfcdest     = rfcdest.

    IF sy-subrc EQ 0.
      tdname_001 = nfirma1.
      treval = nfirma1.
      filename_004 = dir_des1.
      tdname_005 = nfirma1.
      tdname_008 = nfirma1.
      REFRESH messtab.
      CLEAR messtab.
      CALL FUNCTION 'ZSUBEFIRMA'
        EXPORTING
          tdname_001     = tdname_001
          filename_004   = filename_004
          tdname_005     = tdname_005
          autoheight_007 = ''
          tdname_008     = tdname_008
        TABLES
          messtab        = messtab.

      LOOP AT messtab.
        IF messtab-msgtyp EQ 'E'.
          CALL FUNCTION 'Z_DEL_FIRMA'
            EXPORTING
              destination = destination.
*          MESSAGE 'No se puede desencriptar firma 1' TYPE 'I'.
          error = 'X'.
          EXPORT error TO MEMORY ID 'ERR'.
          noexito = '3'.
        ENDIF.
      ENDLOOP.
      CALL FUNCTION 'Z_DEL_FIRMA'
        EXPORTING
          destination = destination.
    ELSE.
      noexito = '2'.
    ENDIF.
  ELSE.
    noexito = '1'.
  ENDIF.
ENDFORM.                    "sube_firmas

* Se llama a rutina de impresión en reporte Revalidador
*    PERFORM imprime_data IN PROGRAM zfimdp_revalidador_f0r.

FORM borra_firmas.
*Borra firmas*********************************
  IMPORT nfirma1 FROM MEMORY ID 'FIR'.
  IMPORT dir_des1 FROM MEMORY ID 'DES'.
  tdname_001 = nfirma1.
  CALL FUNCTION 'ZBORRAFIRMA'
    EXPORTING
      tdname_001 = tdname_001
      tdname_004 = tdname_001
      tdname_006 = tdname_001.

  destination = dir_des1.
  CALL FUNCTION 'Z_DEL_FIRMA'
    EXPORTING
      destination = destination.

ENDFORM.                    "borra_firmas
**********************************************

*&---------------------------------------------------------------------*
*&      Form  MENSAJE
*&---------------------------------------------------------------------*
FORM mensaje  USING p_noexito.
  DATA: texto1(40),
        texto2(40),
        v_answer(1).

  CLEAR: texto1, texto2.
*  CASE p_noexito.
*    WHEN '1'.
*      texto1 = 'Error en tabla ZFIRMADIGITAL.'.
*      texto2 = 'Favor revisar'.
*    WHEN '2'.
*      texto1 = 'Problemas en función S_DES_FIRMA.'.
*      texto2 = 'Favor revisar'.
*    WHEN '3'.
*      texto1 = 'Problemas en función ZSUBEFIRMA.'.
*      texto2 = 'Favor revisar'.
*  ENDCASE.
  texto1 = 'Problemas al desencriptar imagen.'.
  texto2 = 'Favor Revisar'.
  CALL FUNCTION 'POPUP_TO_DECIDE_WITH_MESSAGE'
    EXPORTING
      defaultoption  = '1'
      diagnosetext1  = texto1
      diagnosetext2  = texto2
      textline1      = '¿Corrige información nuevamente?'
      text_option1   = 'Si'
      text_option2   = 'No'
      titel          = 'Desencriptación de firmas'
      cancel_display = ' '
    IMPORTING
      answer         = v_answer.

  IF v_answer = 1.    " Respuesta diferente a SI
    SET PARAMETER ID 'BUK' FIELD bukrs.
    CALL TRANSACTION 'ZIMP_CHEQUE_REVALIDA'.
*    CALL SELECTION-SCREEN 1000.
    LEAVE PROGRAM.
  ELSE.
    noexito = ' '.
  ENDIF.
ENDFORM.                    " MENSAJE

INCLUDE zimp_cheque_revalida_f01.
